# Runbook — Recuperación de un datafile Oracle

## 1. Incidente y síntomas

**Escenario:** pérdida del datafile `academia01.dbf`, perteneciente a `TBS_ACADEMIA` en `FREEPDB1`.

**Errores detectados:**
- `ORA-01116`: error al abrir un datafile.
- `ORA-01110`: identifica el archivo afectado (n.º 16).
- `ORA-27041`: fallo del sistema operativo al abrirlo.
- `Linux Error 2`: archivo inexistente.
- `ORA-63999`: Oracle puede cerrar la PDB por un fallo de medios.

## 2. Diagnóstico previo

Conectar como SYSDBA y verificar:

```sql
ARCHIVE LOG LIST;
SELECT name, open_mode FROM v$pdbs;
SELECT file#, name, status FROM v$datafile WHERE file# = 16;
```

Comprobar que existe una copia RMAN recuperable:

```rman
LIST BACKUP OF DATAFILE 16;
```

Confirmar la disponibilidad del redo necesario antes de restaurar.

## 3. Procedimiento de recuperación

**Caso A — FREEPDB1 permanece READ WRITE**

Desde SQL*Plus:

```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER DATABASE DATAFILE 16 OFFLINE;
```

Desde RMAN:

```rman
RESTORE DATAFILE 16;
RECOVER DATAFILE 16;
```

Finalmente, desde SQL*Plus:

```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER DATABASE DATAFILE 16 ONLINE;
```

**Caso B — FREEPDB1 está MOUNTED**

Esperar a que termine el cierre de la PDB. Después, desde RMAN:

```rman
RESTORE DATAFILE 16;
RECOVER DATAFILE 16;
```

Desde SQL*Plus:

```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER DATABASE DATAFILE 16 ONLINE;
ALTER SESSION SET CONTAINER = CDB$ROOT;
ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;
```

## 4. Verificación

```sql
SELECT name, open_mode FROM v$pdbs;
ALTER SESSION SET CONTAINER = FREEPDB1;
SELECT estudiante_id, estado
FROM admin_academia.aca_estudiantes
WHERE estudiante_id = 104;
```

Confirmar que `FREEPDB1` está en `READ WRITE`, el datafile vuelve a estar disponible y las consultas funcionan.

## 5. Resultados del simulacro

- **Archivo afectado:** `academia01.dbf`, n.º 16.
- **Situación observada:** `FREEPDB1` pasó a `MOUNTED`.
- **Recuperación:** RMAN `RESTORE` + `RECOVER`.
- **Comprobación:** estudiante 104 en `EGRESADO` tras recuperar.
- **RPO:** 0; no se perdió el cambio confirmado.
- **RTO de reparación:** 7 segundos.
- **RTO desde el fallo:** 8 segundos.
- **Estado final:** `FREEPDB1` en `READ WRITE`.

## 6. Comunicación y cierre

Informar al DBA responsable y al equipo de operaciones. Registrar los errores, la causa, las evidencias RMAN y las métricas RTO/RPO. Cerrar el incidente únicamente después de verificar la recuperación del servicio y de los datos.
