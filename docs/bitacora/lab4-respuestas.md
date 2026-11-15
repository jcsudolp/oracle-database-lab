# Laboratorio 4 — Oracle DBA Workflow I
**Asignatura:** Administración de Bases de Datos 26/27 
**Entorno:** Oracle AI Database Free 26ai, Docker, Ubuntu 24.04 y WSL2  
**Issue:** #7
## Introducción
Este documento responde a las 22 preguntas de comprobación y las 12 preguntas tipo examen del Lab. 4.

<p align="center">✦</p>

# Parte I. Preguntas de comprobación
## 1. Respaldo
### 1. ¿Por qué la copia de la Parte B es consistente? ¿Qué pasaría si se tomara con la base abierta?
La copia es consistente porque se realizó tras ‘SHUTDOWN IMMEDIATE’, que finaliza la actividad de la base ordenadamente y permite que los archivos queden en un estado coherente. Se detuvo el contenedor antes de copiar el volumen.
Si fueran copiados manualmente los archivos con la base abierta, algunos podrían representar instantes diferentes, produciendo una copia inconsistente. Una copia en caliente exige un procedimiento apropiado, como RMAN y los mecanismos de recuperación correspondientes.

### 2. ¿Para qué sirven `manifiesto.txt` y `SHA256SUMS`? ¿Qué comprueba `restaurar-estado.sh` antes de tocar nada?
‘manifiesto.txt’ identifica la copia, su fecha, volumen, contenedor, imagen y otros datos necesarios para reconstruir su procedencia. ‘SHA256SUMS’ almacena huellas criptográficas que permiten comprobar si los archivos se han alterado. Antes de modificar el volumen, ‘restaurar-estado.sh’ verifica la integridad mediante SHA-256 y solicita confirmación de la operación. La verificación final confirmó que nuestro backup estaba íntegro.

### 3. Define RPO y RTO con los datos de tu propia copia.
**RPO** es la pérdida de datos máxima aceptable expresada en tiempo. El punto de recuperación es la copia del 15 de noviembre de 2026, identificada como `20261115T130059Z_lab3-final`. Restaurarla puede suponer regresar a ese estado y perder los cambios posteriores no recuperados por otros mecanismos.
**RTO** considerado como el tiempo máximo admisible para restablecer el servicio. En este caso comprendería verificar la copia, restaurar el volumen, arrancar Oracle y comprobar su funcionamiento. No ha sido cronometrada una restauración completa, por lo que no disponemos de un RTO experimental.

<p align="center">✦</p>

## 2. Diagnóstico y correcciones
### 4. ¿Dónde creó Oracle los datafiles de V000 y por qué? ¿Qué parámetro habría evitado el problema?
Oracle creó los cinco datafiles de negocio bajo ‘/opt/oracle/product/26ai/dbhomeFree/dbs/’ porque V000 empleaba rutas relativas y no había un destino OMF apropiado configurado mediante ‘DB_CREATE_FILE_DEST’.
La solución fue reubicarlos en ‘/opt/oracle/oradata/FREE/FREEPDB1/’, dentro del volumen persistente.
El problema evitado con el uso de rutas absolutas correctas o configurando adecuadamente `DB_CREATE_FILE_DEST`.

### 5. ¿Por qué ‘ALTER TABLESPACE ... RENAME DATAFILE’ no basta para mover un archivo?
Este modifica la ruta registrada por Oracle, pero no copia físicamente el archivo. El procedimiento offline requiere poner el tablespace fuera de línea, copiar el datafile, actualizar su referencia y volver a poner el tablespace online. Si la nueva ruta no contiene el archivo, Oracle no podrá abrirlo correctamente.

### 6. ¿Por qué no se edita V000 y se crea V003? ¿Por qué invalidar una contraseña es mejor que borrarla del archivo?
V000 ya había sido ejecutada. Modificarla rompería la trazabilidad de las migraciones.
Solución: Aplicar una migración nueva, V003, que transforma las cuentas ‘ADMIN_*’ en cuentas de solo esquema mediante ‘NO AUTHENTICATION’.
Eliminar una contraseña del archivo actual no la elimina necesariamente del historial de Git. Invalidar su capacidad de autenticación impide que continúe utilizándose para acceder a esas cuentas.

### 7. ¿Qué demuestra la prueba de persistencia y por qué se ejecuta después de reubicar?
Demuestra que los datos sobreviven a la eliminación y recreación del contenedor cuando permanecen almacenados en el volumen Docker. Primero era necesario reubicar los datafiles que estaban fuera del volumen. De lo contrario, al recrear el contenedor podían desaparecer. Después de la prueba permanecían los cinco tablespaces y las tablas de negocio.

<p align="center">✦</p>

## 3. Instancia y arranque
### 8. Con tus evidencias: tres datos que pertenecen a la instancia y tres que pertenecen a la base de datos.
**Instancia:**
- ‘SGA_TARGET = 1536M’.
- ‘PGA_AGGREGATE_TARGET = 512M’.
- 87 entradas de procesos background en `V$PROCESS` durante la medición.
**Base de datos:**
- Nombre: ‘FREE’.
- DBID: ‘1509902213’.
- Modo de archivado: ‘ARCHIVELOG’.
La instancia constituye el entorno de ejecución de memoria y procesos, mientras que la base de datos comprende las estructuras persistentes.

### 9. ¿Qué lee Oracle en NOMOUNT, en MOUNT y en OPEN? Relaciónalo con ORA-01507 y ORA-01219.
**NOMOUNT:** Lee SPFILE/PFILE, reserva la memoria y arranca los procesos. Como los control files aún no están abiertos, consultar ‘V$DATABASE’ puede producir ‘ORA-01507’.
**MOUNT:** Abre los control files y conoce la estructura física de la base, pero todavía no ha abierto los datafiles para el acceso normal al diccionario. Por ello, consultar ‘DBA_TABLES’ puede producir ‘ORA-01219’.
**OPEN:** Abre los archivos necesarios y permite consultar normalmente los objetos de la base y su diccionario, siempre que la PDB también esté abierta.

### 10. ¿Por qué FREEPDB1 se abre sola tras ‘ALTER DATABASE OPEN’? ¿Qué harías si no lo hiciera?
Porque se había guardado su estado mediante ‘SAVE STATE’, permitiendo que Oracle recupere automáticamente su apertura. Si no se abriese, ejecutaríamos:
<div align="center">
ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;
ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE;
</div>

Haciendo una verificación, confirma ‘FREEPDB1’ en ‘READ WRITE’

### 11. Clasifica ORA-00800 y ORA-20013 del alert log: ¿alerta real o ruido conocido? Justifícalo.
‘ORA-00800’, cuando aparece como ‘Set Priority Failed’, se considera una advertencia relacionada con la imposibilidad de establecer prioridades especiales de procesos en determinados contenedores. Observamos esta situación sin que impidiera el funcionamiento de Oracle.
‘ORA-20013’, en el contexto ‘DBMS_QOPATCH’ descrito, puede relacionarse con dificultades para consultar el inventario de parches.
Ambos pueden clasificarse como advertencias conocidas en esos contextos, pero no deben ignorarse sin comprobar su causa. En mi caso, sí consta ‘ORA-00800’ como algo que sucede.

<p align="center">✦</p>

## 4. Parámetros
### 12. Diferencia entre ‘V$PARAMETER’ y ‘V$SPPARAMETER’ con el ejemplo de ‘db_files’.
‘V$PARAMETER’ refleja los valores vigentes para la sesión, mientras que ‘V$SPPARAMETER’ muestra la configuración registrada en el SPFILE. En el experimento, ‘db_files’ permaneció en ‘200’ en memoria cuando escribimos ‘300’ en el SPFILE.
Posteriormente eliminamos ese cambio pendiente mediante:
<div align="center">
ALTER SYSTEM RESET db_files SCOPE = SPFILE;
</div>
La verificación final confirmó el valor ‘200’ y que no quedó una entrada pendiente en el SPFILE.

### 13. ¿Qué hace `SCOPE=BOTH` y cuál es el SCOPE por defecto con SPFILE?
‘SCOPE=BOTH’ modifica simultáneamente el valor en ejecución y su configuración persistente, cuando el parámetro es dinámico. Con SPFILE, el alcance predeterminado de ‘ALTER SYSTEM SET’ para parámetros dinámicos es ‘BOTH’.
En nuestro experimento cambiamos ‘open_cursors’ a ‘500’ en memoria y SPFILE, y posteriormente lo restauramos a ‘300’.

### 14. ¿Por qué PROCESSES rechaza el cambio en memoria, aunque ‘V$PARAMETER’ lo marque IMMEDIATE?
Porque ‘PROCESSES’ condiciona estructuras internas que se dimensionan durante el arranque de la instancia.
En 26ai Free, intentar modificarlo en memoria produjo ‘ORA-02097’ y ‘ORA-02095’, pese a la clasificación mostrada por la vista. Para modificarlo realmente se debe configurar en el SPFILE y reiniciar de manera planificada.

### 15. ¿Para qué sirve versionar el PFILE? Explica "configuration drift".
Versionar el PFILE conserva una representación textual de la configuración de Oracle. Permite comparar modificaciones, documentarlas y recuperar una configuración conocida. La **deriva de configuración** (*configuration drift*) aparece cuando la configuración real deja de coincidir con la registrada o aprobada.
En la práctica, se exporta el SPFILE y los valores de memoria a dos archivos PFILE incluidos en las evidencias (‘07-pfile’ y ‘evidencia/config/initFREE_lab4*.ora’. )

<p align="center">✦</p>

## 5. Memoria y procesos
### 16. ¿Qué modelo de gestión de memoria usa tu instancia? Justifícalo con tres parámetros.
La instancia utiliza **ASMM**, porque:
- ‘MEMORY_TARGET = 0’
- ‘SGA_TARGET = 1536M’
- ‘PGA_AGGREGATE_TARGET = 512M’
Oracle administra automáticamente los componentes de la SGA dentro del presupuesto de ‘SGA_TARGET’, mientras gestiona la PGA por separado.

### 17. Explica las cifras de tu experimento de caché: lecturas lógicas, físicas y tasa de acierto.
En la primera ronda se contabilizaron **463 lecturas lógicas y 267 físicas**. En la segunda, **247 lecturas lógicas y ninguna física**. Las dos devolvieron 17.600 estudiantes activos.
Aplicando la fórmula didáctica del laboratorio:
‘Tasa = (1 - físicas/lógicas) × 100’
La primera ronda obtuvo aproximadamente **42,33 %**, mientras que la segunda alcanzó **100 %**.
El resultado demuestra que reutilizar bloques presentes en memoria evita nuevas lecturas físicas durante la segunda ejecución.

### 18. ¿Por qué no se suma el RSS de los procesos para saber la memoria de la instancia?
Porque el RSS incluye páginas de memoria compartidas entre procesos. En Oracle, varios procesos utilizan una misma SGA. Sumar sus RSS contaría múltiples veces las mismas páginas físicas. Por eso, se emplea ‘V$SGA’, ‘V$PGASTAT’ y herramientas de monitorización del contenedor.

### 19. Relaciona el SPID de LGWR de ‘V$PROCESS’ con el PID de ‘/proc’. ¿Por qué docker top muestra otro número?
En ‘V$PROCESS’, LGWR tenía ‘SPID = 3297’. Desde ‘/proc’, dentro del contenedor, encontramos:
text 3297  103  db_lgwr_FREE
La coincidencia confirma que se trata del mismo proceso.
‘docker top’ puede mostrar el identificador correspondiente al anfitrión, diferente del PID del proceso dentro del contenedor debido a los espacios de nombres de procesos de Docker.

### 20. ¿Qué hace PMON y qué hace SMON? Pon un ejemplo de cada uno.
**PMON** participa en la supervisión de procesos y coordina tareas de limpieza cuando fallan procesos de usuario, con ayuda de procesos como ‘CLMN’. Ej.: detectar un proceso servidor que termina inesperadamente y coordinar la recuperación de sus recursos.
**SMON** realiza tareas de mantenimiento y recuperación de instancia. Ej.: recuperación después de un cierre anormal de Oracle.

<p align="center">✦</p>

## 6. Seguridad
### 21. ¿Por qué C##OPS_RO y no SYSTEM para observar? ¿Qué no puede hacer C##OPS_RO?
Porque ‘C##OPS_RO’ aplica el principio de mínimo privilegio: permite consultar la información necesaria para la observabilidad sin conceder permisos administrativos generales. No está destinado a detener la instancia, modificar parámetros globales ni administrar arbitrariamente usuarios y estructuras.
Con ‘SYSTEM’ asumiríamos privilegios innecesarios para consultas de diagnóstico.

### 22. ¿Qué dos vías de exposición de contraseñas corrige este laboratorio respecto al Lab 3?
La primera es la inclusión de credenciales en migraciones o scripts versionados. V003 eliminó la autenticación de las cuentas de negocio mediante ‘NO AUTHENTICATION’.
La segunda es la exposición de contraseñas en argumentos de comandos, que pueden observarse mediante herramientas de procesos. El ejecutor ‘sysdba.sh’ utiliza autenticación del sistema operativo.
La comprobación J.2 debe verificar adicionalmente que ningún secreto real permanece publicado en los archivos o el historial.

<p align="center">✦</p>

# Parte II. Preguntas tipo examen basadas en escenarios
### P1. Copia en frío de una base de datos
**Escenario:** Un DBA ejecuta ‘SHUTDOWN IMMEDIATE’ y copia todos los datafiles, control files y redo logs online.
**Pregunta:** ¿Qué afirmaciones son correctas? (Elige dos.)
- A. Es una copia consistente: al restaurarla no necesita recuperación con redo.
- B. Solo es válida si la base estaba en modo ARCHIVELOG.
- C. Es una copia inconsistente porque las transacciones en curso se perdieron.
- D. Puede restaurarse y abrirse directamente con STARTUP.
- E. Debe restaurarse con RMAN obligatoriamente.
<p align="center">**Respuestas correctas: A y D.** </p>
La parada limpia garantiza la consistencia de los archivos. Una copia física completa puede restaurarse y abrirse normalmente, sin que RMAN sea obligatorio ni que ARCHIVELOG constituya un requisito para esta copia en frío.

### P2. Sustitución de un disco con datafiles
**Escenario:** Un tablespace de usuario tiene un datafile en un disco que se retirará. La edición es Standard Edition y se permite una breve indisponibilidad.
**Pregunta:** ¿Qué secuencia es correcta?
- A. ‘ALTER DATABASE MOVE DATAFILE’ con la base abierta.
- B. Poner el tablespace OFFLINE, copiar el archivo, ejecutar RENAME DATAFILE y ponerlo ONLINE.
- C. Ejecutar RENAME DATAFILE estando ONLINE para que Oracle lo copie.
- D. Ejecutar SHUTDOWN ABORT, mover el archivo y arrancar.
<p align="center">**Respuesta correcta: B.** </p>
Procedimiento offline indicado por el laboratorio. RENAME DATAFILE cambia la referencia del archivo, pero no realiza la copia física.

### P3. Diferenciar instancia y base de datos
**Escenario:** Un DBA consulta ‘V$INSTANCE’ y ‘V$DATABASE’ con la base abierta.
**Pregunta:** ¿Qué dos afirmaciones son correctas? (Elige dos.)
- A. STARTUP_TIME cambia cada vez que arranca la instancia.
- B. DBID cambia al recrear el contenedor.
- C. CREATED indica cuándo se creó la base, no cuándo arrancó.
- D. Una instancia puede montar dos bases distintas simultáneamente.
- E. V$DATABASE solamente se puede consultar en OPEN.
<p align="center">**Respuestas correctas: A y C.** </p>

STARTUP_TIME pertenece a la instancia, mientras CREATED pertenece a la base persistente. Recrear el contenedor conservando los archivos no modifica el DBID.

### P4. Recuperación en NOMOUNT
**Escenario:** Una instancia Oracle se encuentra en estado NOMOUNT.
**Pregunta:** ¿Qué dos operaciones puede realizar el DBA? (Elige dos.)
- A. Consultar V$PARAMETER.
- B. Consultar DBA_USERS.
- C. Recrear el control file mediante CREATE CONTROLFILE.
- D. Activar ARCHIVELOG.
- E. Renombrar el datafile de SYSTEM.
<p align="center">**Respuestas correctas: A y C.** </p>
En NOMOUNT están disponibles los parámetros y la memoria de la instancia, pero todavía no se han abierto los control files ni los datafiles. Es el estado apropiado para crear o recrear un control file.

### P5. Activación del archivado
**Escenario:** El DBA necesita ejecutar ‘ALTER DATABASE ARCHIVELOG’.
**Pregunta:** ¿En qué etapa debe estar la base?
- A. NOMOUNT.
- B. MOUNT.
- C. OPEN READ WRITE.
- D. OPEN RESTRICTED.
<p align="center">**Respuesta correcta: B.** </p>
La base debe estar montada, con los control files disponibles, pero sin abrirse para el uso normal de las aplicaciones.

### P6. Modificación persistente de parámetros
**Escenario:** Una instancia arrancó utilizando SPFILE y el DBA ejecuta ‘ALTER SYSTEM SET open_cursors = 500;’.
**Pregunta:** ¿Cuál es el resultado?
- A. Cambia solo en memoria.
- B. Cambia en memoria y SPFILE.
- C. Cambia solo en SPFILE.
- D. Falla por no indicar SCOPE.
<p align="center">**Respuesta correcta: B.** </p>
Para un parámetro dinámico, el alcance predeterminado con SPFILE es BOTH.

### P7. Modificación desde una PDB
**Escenario:** Conectado a FREEPDB1, un DBA ejecuta ‘ALTER SYSTEM SET processes = 300 SCOPE = SPFILE;’.
**Pregunta:** ¿Qué ocurre?
- A. Se aplica a FREEPDB1 al reiniciar.
- B. Se aplica a toda la instancia al reiniciar.
- C. Falla con ORA-65040.
- D. Falla con ORA-02095 por ser estático.
<p align="center">**Respuesta correcta: C.** </p>
PROCESSES es un parámetro de instancia y no puede modificarse desde una PDB. El error relevante en este escenario es ORA-65040.

### P8. Recuperación de un SPFILE incorrecto
**Escenario:** Una instancia no consigue arrancar porque el SPFILE contiene un valor erróneo.
**Pregunta:** ¿Qué dos sentencias permiten recuperarla? (Elige dos.)
- A. ‘STARTUP PFILE='/ruta/init_bueno.ora'’.
- B. ‘ALTER SYSTEM RESET ... SCOPE = MEMORY’.
- C. ‘CREATE SPFILE FROM PFILE='/ruta/init_bueno.ora'’.
- D. ‘ALTER DATABASE OPEN RESETLOGS’.
- E. ‘SHUTDOWN ABORT’.
<p align="center">**Respuestas correctas: A y C.** </p>
Primero se arranca con un PFILE válido y después se reconstruye el SPFILE a partir de esa configuración.

### P9. Gestión automática de memoria
**Escenario:** Una instancia tiene MEMORY_TARGET = 0, SGA_TARGET = 2G y DB_CACHE_SIZE = 512M.
**Pregunta:** ¿Qué afirmación es correcta?
- A. El Buffer Cache tendrá siempre exactamente 512 MB.
- B. ASMM administra la SGA y el Buffer Cache no bajará de 512 MB.
- C. AMM administra conjuntamente la SGA y la PGA.
- D. Oracle ignora DB_CACHE_SIZE.
<p align="center">**Respuesta correcta: B.** </p>
Con ASMM, DB_CACHE_SIZE especificado actúa como mínimo para el componente, aunque Oracle puede asignarle más memoria.

### P10. Contenido de la PGA
**Escenario:** Se analiza la memoria de un proceso servidor dedicado.
**Pregunta:** ¿Qué dos estructuras pertenecen a su PGA? (Elige dos.)
- A. Área de ordenación de ORDER BY.
- B. Shared Pool.
- C. Redo Log Buffer.
- D. Memoria de sesión en servidor dedicado.
- E. Database Buffer Cache.
<p align="center">**Respuestas correctas: A y D.** </p>
Las áreas de trabajo y el estado de sesión de un servidor dedicado se encuentran en memoria privada. Los otros tres componentes pertenecen a la SGA.

### P11. Confirmación de una transacción
**Escenario:** Un usuario ejecuta COMMIT.
**Pregunta:** ¿Qué proceso debe completar su escritura antes de devolver el control?
- A. DBWn.
- B. CKPT.
- C. LGWR.
- D. ARCn.
- E. SMON.
<p align="center">**Respuesta correcta: C.** </p>
LGWR garantiza la escritura del redo correspondiente antes de la confirmación síncrona habitual del COMMIT. DBWn puede escribir los bloques de datos modificados posteriormente.

### P12. Procesos fundamentales de Oracle
**Escenario:** El administrador debe identificar dos procesos background obligatorios de una instancia.
**Pregunta:** ¿Cuáles son? (Elige dos.)
- A. ARC0.
- B. PMON.
- C. RECO solo si hay database links.
- D. SMON.
- E. CJQ0.
<p align="center">**Respuestas correctas: B y D.** </p>
PMON y SMON son procesos fundamentales de la instancia. Los restantes tienen funciones específicas y no son los dos solicitados.

<p align="center">✦</p>

# Recopilatorio Respuestas
| Pregunta | Tipo | Respuesta | Situación evaluada |
|---|---|---|---|
| P1 | Dos respuestas | **A y D** | Copia consistente tras SHUTDOWN IMMEDIATE |
| P2 | Una respuesta | **B** | Traslado offline de un datafile |
| P3 | Dos respuestas | **A y C** | Diferenciar instancia y base de datos |
| P4 | Dos respuestas | **A y C** | Operaciones permitidas en NOMOUNT |
| P5 | Una respuesta | **B** | Activación de ARCHIVELOG |
| P6 | Una respuesta | **B** | Alcance por defecto de ALTER SYSTEM |
| P7 | Una respuesta | **C** | Parámetros no modificables desde una PDB |
| P8 | Dos respuestas | **A y C** | Recuperar un SPFILE incorrecto |
| P9 | Una respuesta | **B** | ASMM y mínimo del Buffer Cache |
| P10 | Dos respuestas | **A y D** | Estructuras privadas de PGA |
| P11 | Una respuesta | **C** | LGWR y durabilidad del COMMIT |
| P12 | Dos respuestas | **B y D** | Procesos PMON y SMON |
