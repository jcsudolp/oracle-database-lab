#!/usr/bin/env bash
# scripts/lab5/09-multiplexar-controlfile.sh — añade una TERCERA copia del control file (idempotente)
# Procedimiento oficial con SPFILE: 1) ALTER SYSTEM SET control_files ... SCOPE=SPFILE
# 2) SHUTDOWN IMMEDIATE  3) copiar una copia existente al nuevo nombre  4) STARTUP
# NOTA DIDÁCTICA: en producción cada copia va en un disco/controlador distinto. Aquí las tres comparten
# volumen, así que protegen de un borrado o corrupción de UN archivo, no de perder el disco.
set -euo pipefail
source scripts/deployment/env/00-config.sh
NUEVA="$DATA_ROOT/FREE/control03.ctl"

sql() {
  {
    printf 'WHENEVER SQLERROR EXIT FAILURE\n'
    cat
  } | docker exec -i \
      -e NLS_LANG=AMERICAN_AMERICA.AL32UTF8 \
      "$CONT_NAME" sqlplus -s -L / as sysdba
}

ACTUAL=$(printf "SET HEADING OFF FEEDBACK OFF PAGESIZE 0 LINESIZE 400\nSELECT value FROM v\$parameter WHERE name = 'control_files';\nEXIT\n" | sql | xargs)
echo "control_files actual: $ACTUAL"
if [[ "$ACTUAL" == *control03.ctl* ]]; then echo "Ya hay tercera copia: nada que hacer."; exit 0; fi
LISTA="'$(echo "$ACTUAL" | sed "s/, */','/g")','$NUEVA'"
echo "== 1. Nuevo valor en el SPFILE (no en memoria: control_files es estático) =="
printf "ALTER SYSTEM SET control_files = %s SCOPE = SPFILE;\nEXIT\n" "$LISTA" | sql

echo "== 2. Parada limpia de Oracle mediante Docker =="
docker stop --timeout 180 "$CONT_NAME"

echo "== 3. Comprobar que el contenedor está detenido =="
ESTADO=$(docker inspect --format '{{.State.Status}}' "$CONT_NAME")

if [[ "$ESTADO" != "exited" ]]; then
  echo "ERROR: el contenedor no está detenido. Se cancela la copia."
  exit 1
fi

echo "Contenedor detenido correctamente."

CODIGO_SALIDA=$(docker inspect --format '{{.State.ExitCode}}' "$CONT_NAME")
OOM=$(docker inspect --format '{{.State.OOMKilled}}' "$CONT_NAME")

if [[ "$OOM" == "true" ]]; then
  echo "ERROR: el contenedor terminó por falta de memoria."
  exit 1
fi

echo "Código de salida del contenedor: $CODIGO_SALIDA"

echo "== 4. Crear la tercera copia física mediante Ubuntu =="
docker run --rm \
  -v "$VOL_NAME:/data" \
  ubuntu:24.04 \
  sh -ec '
    cd /data/FREE
    test -f control01.ctl
    test -f control02.ctl
    test ! -e control03.ctl

    cp -p control01.ctl control03.ctl
    cmp control01.ctl control03.ctl

    ls -lh control01.ctl control02.ctl control03.ctl
  '

echo "== 5. Arrancar el contenedor Oracle =="
docker start "$CONT_NAME"
bash scripts/ops/esperar-healthy.sh

echo "== 6. Verificar los tres archivos de control =="
printf "SET LINESIZE 120\nCOLUMN name FORMAT A75\nSELECT name, status FROM v\$controlfile;\nEXIT\n" | sql
