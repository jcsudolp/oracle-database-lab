# Laboratorio 5 — Oracle DBA Workflow II
## Respuestas de comprobación, simulacros y retrospectiva

**Curso:** BBDD 2026/2027 · **Base:** Oracle Database Free 23.26.3 · **Contenedor:** 'oralab-26ai' · **CDB/PDB:** 'FREE' / 'FREEPDB1' · **Issue:** #9 · **Rama:** 'chore/9-oracle-dba-workflow-ii'.


## Índice

1. Preguntas de comprobación
2. Simulacro final S1–S26
3. Preguntas tipo examen de las partes B–O
4. RTO, RPO y retrospectiva de los cuatro simulacros.
5. Retrospectiva de la FRA llena y valoración del healthcheck.
6. Comprobación de entrega y referencia a evidencias.

<p align="center">★		★		★		★		★</p>

## 1. Preguntas de comprobación

### 1. Compara el paso 6 de tu copia lab4-final con el de la copia lab3-final. ¿Qué demuestra la diferencia?

En la copia **lab4-final** aparecen los archivos 'volumen.tar.gz' (725 MB), 'inventario.txt', 'manifiesto.txt' y 'SHA256SUMS'. La verificación registrada terminó con los cuatro resultados **OK**. En nuestra comprobación externa, la copia anterior **lab3-final** ocupaba **657 MB**, frente a **725 MB** de la del Lab 4: la base había crecido al incorporar objetos y datos. Lo importante del paso 6 no es solo que exista un '.tar.gz', sino comprobar su integridad y que el estado nuevo no sea igual al anterior. **Limitación:** el paquete remitido contiene la evidencia detallada de la copia del Lab 4, pero no el registro íntegro del *paso 6* de la copia del Lab 3; por eso esta comparación de tamaños no se presenta como una comparación literal de ambas salidas de ese paso. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T200320Z_00-backup-lab4.script.log'; tamaños de los dos respaldos comprobados durante la práctica.

<p align="center">★</p>

### 2. Calcula el factor de bloqueo (bfr) de CLIENTE y de PEDIDO con sus estadísticas. ¿Por qué PEDIDO cabe casi el triple de filas por bloque?

El factor de bloqueo es **bfr = filas / bloques**. Para CLIENTE: **100.000 / 1.517 = 65,92 ≈ 66 filas/bloque**. Para PEDIDO: **1.000.000 / 5.320 = 187,97 ≈ 188 filas/bloque**. PEDIDO almacena aproximadamente **188 / 66 = 2,85 veces** más filas por bloque porque cada fila ocupa, de media, **32 bytes**, mientras que en CLIENTE ocupa **102 bytes**. Un bloque admite más filas cortas que largas. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T202233Z_01-perfil-tiendasur-utf8.script.log'.

<p align="center">★</p>

### 3. ¿Por qué el banco de medida ejecuta cada sentencia dos veces y mide solo la segunda?

La primera ejecución puede incorporar trabajo que no es representativo de la consulta repetida: lectura desde disco, carga de bloques en caché, operaciones iniciales del cursor e incluso limpieza de bloques. Al ejecutar dos veces y medir la segunda, comparamos las consultas **en caliente** y reducimos ese sesgo. Así, por ejemplo, nuestra búsqueda de 'id_pedido = 4711' registró **4 buffers** al recuperar una columna de la tabla y **3 buffers** cuando solo pidió la clave cubierta por el índice. No debe confundirse una mejora por caché con una mejora de diseño. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T212232Z_02-anatomia-indice.script.log'.

<p align="center">★</p>

### 4. Con tu evidencia 02: altura, número de hojas y factor de ramificación (fan-out) real de IX_PED_CLIENTE. ¿Qué altura tendría con mil millones de filas?

En 'IX_PED_CLIENTE' medimos **altura 3**, **2.216 hojas**, **6 ramas** y **1.000.000 de entradas**. El *fan-out* real que calcula el guion es **(2.216 + 6 − 1) / 6 ≈ 370**; el máximo estimado es **8028 / 14,8 ≈ 543**. Para **1.000 millones de filas**, la proyección del experimento da **2.208.969 hojas** y **altura 4**; con un acceso adicional a la tabla serían unas **5 lecturas** para encontrar una fila. La razón es que la altura crece logarítmicamente. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T212232Z_02-anatomia-indice.script.log'.

<p align="center">★</p>

### 5. En el volcado de la hoja de PK_CLIENTE, localiza una entrada y descompón el ROWID que guarda en bloque y fila. ¿Por qué no aparece el número de archivo?

En la primera entrada de hoja de 'PK_CLIENTE' leemos 'row#0 ... data:(6): 00 00 03 1b 00 00', junto a la clave hexadecimal 'c1 02', correspondiente a **ID_CLIENTE = 1**. Los primeros **4 bytes** '00 00 03 1b' señalan el **bloque 795 (0x031B)**; los **2 últimos** '00 00' indican la **ranura 0**. En este volcado aparece un ROWID restringido/corto: el formato mostrado utiliza bloque y ranura, sin repetir un número de archivo independiente en la entrada. El volcado corresponde al formato concreto usado por el segmento, no a una regla universal de todos los tipos de ROWID. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T212232Z_02-anatomia-indice.script.log' y el volcado 'docs/bitacora/lab5/evidencia/config/20261123T212232Z_02-volcado-indice.trc.txt'.

<p align="center">★</p>

### 6. Elige tres pruebas de la Parte D y explica, con las lecturas lógicas medidas, por qué un tipo de índice gana al otro.

**Prueba 1 (índice único, Q13):** buscar por DNI pasó de **1.486** a **3 lecturas lógicas** gracias a 'UX_CLI_DNI', que además impidió el duplicado ('ORA-00001'). 
**Prueba 2 (cubriente, Q7):** el historial del cliente bajó de **15 buffers** con el índice simple a **7** con '(id_cliente, fecha)' y a **3** con el cubriente, porque ya no hizo falta leer la tabla. 
**Prueba 3 (bitmap, Q14):** en el almacén analítico la combinación de filtros redujo el trabajo de **4.073** a **528 buffers**. La contrapartida del bitmap es su mala adecuación a escrituras concurrentes. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T213926Z_03-tipos-indice.script.log'.

<p align="center">★</p>

### 7. ¿Por qué IX_PED_FECHA tiene un clustering factor cercano al número de bloques e IX_PED_CLIENTE cercano al de filas? ¿Lo arreglaría un REBUILD?

'IX_PED_FECHA' tiene **CF = 5.220**, cercano a los **5.320 bloques** de PEDIDO; indica que recorrer el índice por fechas suele llevar a filas próximas físicamente. En 'IX_PED_CLIENTE', **CF = 999.041**, casi igual a **1.000.000 de filas**: los pedidos de un cliente están muy dispersos en la tabla, así que un rango puede provocar multitud de saltos entre bloques. Un 'REBUILD' ordena y reconstruye el **índice**, pero no reordena las **filas de la tabla**; por tanto, no arregla ese CF. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T215113Z_04-agrupamiento-equilibrio.script.log'.

<p align="center">★</p>

### 8. Según tu curva de la Parte E, ¿a partir de qué porcentaje deja de compensar cada índice? Compáralo con la fórmula de la Unidad 3.

Para el índice con **CF malo**, la curva muestra **975 buffers al 0,1 %** y **2.004 al 0,2 %**; el optimizador ya elige el recorrido completo desde **0,2 %**. En el punto del **1 %** se miden **9.920 buffers** por índice frente a **5.232** por tabla, de modo que el índice malo es claramente peor. La regla teórica aproximada es **1/bfr = 1/188 ≈ 0,53 %** si se iguala el coste de lectura, y **0,11 %** si la lectura aleatoria cuesta cinco veces la secuencial; el umbral observado del plan se mueve según costes y estimaciones del optimizador. Con **CF bueno**, el índice aún gana al **50 % (3.938 < 5.232)**, pero pierde al **100 % (7.875 > 5.232)**; la curva solo permite situar ese cruce **entre el 50 % y el 100 %**, no fijar un porcentaje exacto. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T215113Z_04-agrupamiento-equilibrio.script.log'.

<p align="center">★</p>

### 9. Explica por qué Q4b ('Gonz%') usa el índice y aun así lee más bloques que un recorrido completo.

El prefijo ''Gonz%'' sí permite delimitar un intervalo en el B-tree, y por eso el plan usa 'INDEX RANGE SCAN'. Pero devuelve **2.056 clientes** repartidos en bloques de tabla; recuperar sus ROWID produce **2.024 lecturas lógicas**. El recorrido completo de CLIENTE aparece con alrededor de **1.486 buffers** en las pruebas comparables de la práctica. Por eso **usar un índice no equivale siempre a leer menos bloques**: la dispersión física y la cantidad de filas recuperadas importan. La comparación debe tener en cuenta que el recorrido completo y la consulta por rango se midieron en escenarios distintos del banco. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T215619Z_05-sargabilidad.script.log' y 'docs/bitacora/lab5/evidencia/script/20261123T213926Z_03-tipos-indice.script.log'.

<p align="center">★</p>

### 10. Con tu evidencia 06: bloques modificados por INSERT con 4, 9 y 5 índices. ¿Qué índices de la propuesta del compañero rechazaste y con qué dato?

En **2.000 INSERT**, la configuración inicial con **4 índices** modificó **20.296 bloques** (**10,1 por fila**); la propuesta con **9 índices** modificó **40.341** (**20,2 por fila**), casi el doble; V005, con **5 índices**, modificó **24.217** (**12,1 por fila**). El redo pasó de **2.570 KB** a **5.016 KB** con la propuesta y quedó en **3.144 KB** con V005. Rechacé como diseño final los índices indiscriminados 'IX_PED_CANAL', 'IX_PED_ESTADO' y el orden redundante 'IX_PED_FEC_CLI'; también se retiró 'IX_PED_IMPORTE' porque no lo usó la carga observada, y 'IX_PED_CLIENTE' fue sustituido por el cubriente que comienza por cliente. 'IX_PED_ESTADO' se reemplazó funcionalmente por el parcial de pendientes. La evidencia de uso mostraba 'NO' para CANAL, FEC_CLI, IMPORTE y CLIENTE. Estas decisiones requieren validar la carga real a largo plazo en producción. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T221207Z_06-indices.script.log'.

<p align="center">★</p>

### 11. Distingue, con tus gráficos de la Parte H, un índice con divisiones 50/50, uno con divisiones 90/10 y uno con patrón cola.

Con **200.000 inserciones**, el índice de claves **aleatorias** realizó **595 divisiones**, ninguna de tipo 90/10: predominaron las divisiones que reparten entradas entre hojas, y quedó en **596 hojas**, con una ocupación de **75,4 %**. 
El de claves **crecientes** registró **398 divisiones, las 398 de tipo 90/10**, terminó con **399 hojas** y **99,9 %** de ocupación: las nuevas claves llegan al extremo derecho. El **patrón cola** es diferente: al insertar por la derecha y borrar por la izquierda quedaron **425 hojas**, **224 vacías** y **70.271 entradas borradas**; su mapa muestra el extremo izquierdo vacío y el derecho lleno. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T224334Z_07a-crecimiento.script.log', 'docs/bitacora/lab5/evidencia/script/20261123T224334Z_07a-grafico-IX_AZAR.script.log', 'docs/bitacora/lab5/evidencia/script/20261123T224334Z_07a-grafico-IX_CRECIENTE.script.log' y 'docs/bitacora/lab5/evidencia/script/20261123T224334Z_07b-grafico-IX_COLA-antes.script.log'.

<p align="center">★</p>

### 12. ¿Qué remedio elegirías para el patrón cola en producción, en horario de servicio, y por qué?

Para aliviarlo **en horario de servicio**, elegiría **'ALTER INDEX ... COALESCE'**, porque fusiona hojas disponibles sin reconstruir por completo el índice. En nuestra prueba pasó de **425 hojas, 70.271 entradas borradas y 226 lecturas** para hallar el mensaje más antiguo a **201 hojas, 0 borradas y 2 lecturas**. Si además necesitase devolver espacio al tablespace, valoraría **'SHRINK SPACE'**: redujo el segmento de **4 MB a 1,69 MB**, con las mismas **2 lecturas**. A medio plazo preferiría particionar por fecha y eliminar particiones antiguas, evitando que el problema reaparezca. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T224334Z_07c-remedios.script.log'.

<p align="center">★</p>

### 13. Con tu evidencia 08: ¿qué valores compara Oracle al abrir para decidir si hace falta recuperación?

Oracle compara el **SCN de checkpoint registrado en el control file** con el **SCN de la cabecera de cada datafile**. En nuestra evidencia, antes del checkpoint el archivo 'system01.dbf' mostraba **3.495.411** en ambos lugares; después de 'ALTER SYSTEM CHECKPOINT', ambos pasaron a **3.499.194**. El 'CURRENT_SCN' ya iba por **3.499.214**, lo que demuestra que el SCN actual puede ser mayor que el último checkpoint sin que ello signifique corrupción. La PDB$SEED conservaba **2.098.101** por estar en solo lectura. Si los SCN requeridos no cuadran o el archivo no se cerró limpiamente, Oracle determina la necesidad de recuperación. **La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261123T230705Z_08-scn-checkpoint.script.log'.

### 14. ¿Qué protege la multiplexación del control file en el mismo volumen y qué no? ¿Cómo se haría en producción?

Nuestras **3 copias** ('control01.ctl', 'control02.ctl', 'control03.ctl') permiten reemplazar una copia dañada por otra buena: en O.B, al faltar 'control03.ctl', Oracle devolvió 'ORA-00205', copiamos 'control01.ctl' y volvimos a abrir la base. Pero **las tres están en el mismo volumen Docker**: si se pierde ese volumen, pueden perderse simultáneamente. En producción se distribuyen entre **discos, controladoras o dominios de fallo diferentes**, además de hacer copias RMAN del control file. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261124T111108Z_14b-perdida-controlfile.script.log' y 'docs/bitacora/lab5/evidencia/script/20261123T233920Z_09-multiplexacion-verificacion.script.log'.

<p align="center">★</p>

### 15. Explica los estados CURRENT, ACTIVE e INACTIVE con tu evidencia 10 y por qué Oracle rechaza los tres borrados del paso 4.

**CURRENT** es el grupo donde LGWR escribe ahora; **ACTIVE** ya no es el actual, pero su contenido todavía podría necesitarse para recuperar la instancia; **INACTIVE** puede reutilizarse porque ya no se necesita para esa recuperación. En la evidencia 10, tras los switches, el grupo **1/sec. 16** figuró 'CURRENT' y el **3/sec. 15**, 'ACTIVE'; después el grupo **2/sec. 17** pasó a 'CURRENT'. Oracle rechaza borrar un grupo 'CURRENT' ('ORA-01623') o su miembro actual ('ORA-01609'); también impide dejar la base con un número de grupos insuficiente ('ORA-01567'). **Salvedad crucial de nuestra ejecución:** trabajábamos con **3 grupos**, así que el tercer borrado que en el ejemplo de 2 grupos produciría 'ORA-01567' **no se ejecutó** para evitar eliminar realmente un grupo; solo se ejecutaron los dos primeros intentos. Por eso no afirmo haber observado aquí 'ORA-01567'. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261124T094214Z_10-redo-1a3.script.log', 'docs/bitacora/lab5/evidencia/script/20261124T094512Z_10-redo-errores.script.log'.

<p align="center">★</p>

### 16. Describe la cadena de causas del escenario de la FRA llena, desde ORA-19815 hasta que la base deja de aceptar cambios.

La cadena es: **FRA sin espacio → ARCn no puede guardar un redo archivado → los grupos dejan de estar disponibles para reutilización → las sesiones pueden quedar esperando 'log file switch (archiving needed)' → la escritura queda bloqueada**. 

En nuestra prueba la FRA se redujo a **2 MB** y el alert log registró **'ORA-19815' (100 % de 2.097.152 bytes)**; al solicitar el archivado aparecieron **'ORA-16038' y 'ORA-19809'**, con la secuencia 20 sin archivar. 

Al restaurar el límite a **4.096 MB**, ARCn archivó las secuencias pendientes y el uso quedó en **10,6 MB**. En este log se observa la incapacidad de archivar; no debemos inventar una espera medida de la aplicación si el registro no la contiene. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261124T095449Z_11-fra-llena.script.log'.

<p align="center">★</p>

### 17. Explica, con los pasos 1 a 4 de tu evidencia 12, la frase "lectores no bloquean a escritores".

La sesión A modificó el estudiante **101** a 'EGRESADO' sin confirmar. Mientras esa transacción estaba abierta, la sesión B hizo un 'SELECT' normal y vio **'ACTIVO'**, el último valor confirmado, reconstruido con undo. A consumía **1 bloque y 1 registro de undo**, y mantenía bloqueos **TM modo 3** y **TX modo 6**. 

B pudo leer sin esperar; sin embargo, cuando intentó 'SELECT ... FOR UPDATE WAIT 3', ya quería bloquear la misma fila y recibió **'ORA-00054'**. Por tanto, una lectura consistente no bloquea al escritor, pero dos escrituras incompatibles sí se bloquean. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261124T101016Z_12-lectura-consistente.script.log'.

<p align="center">★</p>

### 18. ¿Por qué un DELETE genera más undo que un INSERT? ¿Por qué el ROLLBACK también genera redo?

El **INSERT** requiere principalmente información para eliminar lo insertado; el **DELETE** debe conservar en undo la fila anterior y cambios asociados a índices. En nuestras operaciones de **10.000 filas**, INSERT consumió **143 bloques de undo (1.144 KB)**, UPDATE **71 (568 KB)** y DELETE **428 (3.424 KB)**. El rollback también es una modificación que debe ser recuperable tras una caída, por lo que genera redo: fueron **357 KB**, **751 KB** y **4.701 KB** respectivamente. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261124T104744Z_12-undo-y-redo.script.log'.

<p align="center">★</p>

### 19. Con tu evidencia 13: ¿dónde está la garantía de durabilidad justo después del COMMIT? ¿Y después del checkpoint?

**Respuesta.** Después de 'COMMIT', la garantía está en el **redo persistido por LGWR**, no en que DBWn haya escrito los datafiles. En el UPDATE de **20.000 estudiantes**, medimos **7.635 KB de redo**, **11 escrituras LGWR**, **1 commit**, **0 escrituras físicas desde caché** en ese intervalo y **231 bloques sucios** de la tabla. Después del 'CHECKPOINT', DBWn había escrito **591 bloques** de la instancia y la tabla quedó con **0 sucios**; se generaron además **13 KB de redo**. Los 591 son de toda la instancia, incluidos bloques adicionales a la tabla. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261124T105151Z_13-lgwr-dbwn.script.log'.

<p align="center">★</p>

### 20. Simulacro A: explica roll forward y roll back con las filas 102 y 103 y las líneas del alert log.

**Respuesta.** Antes de la caída, el estudiante **102** se cambió a 'EGRESADO' con **COMMIT**, mientras que el **103** se cambió a 'INACTIVO' sin confirmar. Tras 'SHUTDOWN ABORT' y 'STARTUP', vimos **102 = EGRESADO** y **103 = ACTIVO**. El **roll forward** reaplica desde redo los cambios necesarios para reconstruir los bloques; el **roll back** usa undo para eliminar el efecto de la transacción no confirmada. El alert log registró **1.576 KB de redo leído, 234 bloques necesitados de recuperación, 0,87 MB aplicado** y apertura con secuencia **23**. El script restauró después el 102 a 'ACTIVO'. 

**La evidencia está en** 'docs/bitacora/lab5/evidencia/script/20261124T110932Z_14a-caida-instancia.script.log'.

<p align="center">★</p>

### 21. Simulacros C y D: tu RTO y tu RPO en cada uno. ¿Por qué son tan distintos?

**Respuesta.** **C:** la restauración de toda la base tardó **44 s**. El script indicó una **ventana potencial de RPO de 1 s** entre la copia y el fallo; no acredita que se perdieran efectivamente datos de usuario. Restauró **60.000 matrículas**. **D:** recuperar solo el datafile **16** mediante RMAN necesitó **7 s de reparación y 8 s desde el fallo**; **RPO observado = 0**, demostrado porque el estudiante **104** mantenía 'EGRESADO' aunque se había confirmado después de la copia RMAN. Son diferentes porque C reemplaza el estado completo y D reconstruye un solo archivo aplicando redo archivado y online. 

**Las evidencias son** 'docs/bitacora/lab5/evidencia/script/20261124T111221Z_14c-simulacro-restauracion.script.log' y 'docs/bitacora/lab5/evidencia/script/20261124T112146Z_14d-perdida-datafile.script.log'.

<p align="center">★</p>

### 22. Clasifica cada error ORA- del bloque 5 de tu runbook: incidente real, efecto del laboratorio o ruido conocido.

**Respuesta.** En el bloque 5 del healthcheck aparecieron **'ORA-01113' (archivo 22)**, **'ORA-01110' (archivo 16)** y **'ORA-63999'**: son huellas del **simulacro D** (fallo de medios, cierre y posterior reapertura de FREEPDB1); no indican una avería activa, pues la PDB terminó 'READ WRITE'. **'ORA-00202'** ('control03.ctl') y el texto **'ORA-205 signalled'** corresponden al error esperado **'ORA-00205' de la Parte O.B**. **'ORA-00800'** sobre las prioridades LGWR/VKTM es **ruido conocido del entorno Docker**, no el incidente provocado por nosotros. La FRA estaba al **2,4 % (100/4.096 MB)** y los errores de undo en **0**; así, el contexto del healthcheck no muestra problemas pendientes. 

**Las evidencias son** 'docs/bitacora/lab5/evidencia/spool/20261124T113411Z_15-healthcheck.spool.log', 'docs/bitacora/lab5/evidencia/script/20261124T111108Z_14b-perdida-controlfile.script.log' y 'docs/bitacora/lab5/evidencia/script/20261124T112146Z_14d-perdida-datafile.script.log'.


<p align="center">★		★		★</p>


## 2. Simulacro de examen 1Z0-182 (S1–S26, páginas 90–94)

En cada pregunta se conserva el enunciado con todas las opciones y se indica la elección, por qué es correcta y la parte del laboratorio relacionada. Son preguntas diseñadas para practicar, no preguntas oficiales de certificación.

<p align="center">★</p>

S1. Un índice tiene un clustering factor muy cercano al número de filas de la tabla. ¿Qué afirmación es correcta? 

- **A.** Las filas con claves consecutivas están en bloques contiguos de la tabla.
- **B.** Un recorrido por rango del índice visitará casi un bloque distinto de la tabla por cada fila.
- **C.** Reconstruir el índice reducirá el clustering factor.
- **D.** El índice está fragmentado y debe hacerse COALESCE.

**La respuesta correcta es la B.** Un clustering factor cercano al número de filas implica muchos saltos entre bloques de tabla al recorrer un rango. En nuestro índice IX_PED_CLIENTE medimos CF = 999.041 frente a un millón de filas. **Parte:** E.

<p align="center">★</p>

S2. La consulta SELECT * FROM cliente WHERE UPPER(email) = :e hace un recorrido completo aunque existe un índice sobre EMAIL. ¿Qué dos cambios permiten usar un índice? (Elige dos.) 

- **A.** Crear un índice basado en función sobre UPPER(email).
- **B.** Reconstruir el índice sobre EMAIL.
- **C.** Si el email se guarda en minúsculas, escribir WHERE email = LOWER(:e).
- **D.** Recoger estadísticas de la tabla.
- **E.** Añadir el hint FULL.

**La respuesta correcta es la A y C.** Se puede indexar UPPER(email) o dejar la columna libre de funciones usando email = LOWER(:e), si se guardan las direcciones en minúsculas. La reescritura bajó de 1.486 a 4 buffers. **Parte:** D y F.

<p align="center">★</p>

S3. CODIGO_POSTAL es VARCHAR2 y tiene índice. La consulta WHERE codigo_postal = 30001 no lo usa. ¿Por qué? 

- **A.** Los índices no admiten columnas VARCHAR2.
- **B.** Oracle convierte la columna con TO_NUMBER, y el índice está sobre la columna sin convertir.
- **C.** El literal 30001 es demasiado selectivo.
- **D.** Falta un histograma sobre CODIGO_POSTAL.

**La respuesta correcta es la B.** La comparación con el número provoca TO_NUMBER(codigo_postal) sobre la columna VARCHAR2; al comparar con una cadena, bajamos de 5.232 a 106 buffers. **Parte:** F.

<p align="center">★</p>

S4. ¿En qué situación es más apropiado un índice bitmap? 

- **A.** Una columna con millones de valores distintos en un sistema transaccional.
- **B.** Una columna de estado con 4 valores en un almacén de datos que se carga por la noche y se consulta de día.
- **C.** Una clave primaria con muchas inserciones concurrentes.
- **D.** Una columna que se actualiza en cada transacción.

**La respuesta correcta es la B.** Bitmap resulta conveniente para atributos con pocos valores en almacenes de lectura intensiva y cargas por lotes, no para OLTP concurrente. **Parte:** D.

<p align="center">★</p>

S5. Existe un índice compuesto (pais, ciudad). PAIS tiene 5 valores distintos. Una consulta filtra solo por CIUDAD. ¿Qué operación puede elegir el optimizador? 

- **A.** INDEX UNIQUE SCAN
- **B.** INDEX SKIP SCAN
- **C.** INDEX RANGE SCAN sobre la columna PAIS
- **D.** BITMAP CONVERSION

**La respuesta correcta es la B.** Un INDEX SKIP SCAN puede explorar cada valor de la primera columna cuando tiene pocos valores distintos. En nuestra prueba de 40 países, ciudad sola costó 144 buffers, frente a 103 con país y ciudad. **Parte:** D.

<p align="center">★</p>

S6. Quieres comprobar si la aplicación necesita un índice antes de borrarlo, con marcha atrás inmediata. ¿Qué haces? 

- **A.** ALTER INDEX … UNUSABLE
- **B.** ALTER INDEX … INVISIBLE y vigilar el rendimiento
- **C.** DROP INDEX y recrearlo si hay quejas
- **D.** ALTER INDEX … COALESCE

**La respuesta correcta es la B.** INVISIBLE deja de ofrecer el índice al optimizador pero lo conserva mantenido y permite devolverlo a VISIBLE rápidamente. **Parte:** G.

<p align="center">★</p>

S7. Una tabla de mensajes inserta por un extremo y borra por el otro. El índice de la clave crece aunque el número de filas es estable. ¿Qué dos acciones lo resuelven sin bloquear la tabla? (Elige dos.) 

- **A.** ALTER INDEX … COALESCE
- **B.** ALTER INDEX … REBUILD (sin ONLINE)
- **C.** ALTER INDEX … SHRINK SPACE
- **D.** Recoger estadísticas del índice
- **E.** ALTER TABLE … MOVE

**La respuesta correcta es la A y C.** COALESCE fusiona hojas y SHRINK SPACE además devuelve espacio. En la cola de prueba se pasó de 226 a 2 lecturas. **Parte:** H.

<p align="center">★</p>

S8. ¿Qué efecto tiene un índice de clave invertida (REVERSE) sobre una clave secuencial? 

- **A.** Acelera las consultas por rango de la clave.
- **B.** Reparte las inserciones entre muchas hojas, pero impide usar el índice para rangos.
- **C.** Reduce el tamaño del índice a la mitad.
- **D.** Convierte el índice en un IOT.

**La respuesta correcta es la B.** REVERSE dispersa las claves crecientes entre hojas y reduce la hoja caliente, pero destruye el orden útil para búsquedas por rango. **Parte:** H.

<p align="center">★</p>

S9. Una tabla tiene 9 índices. ¿Qué operación NO se encarece por el número de índices? 

- **A.** INSERT
- **B.** DELETE
- **C.** UPDATE de una columna que no está en ningún índice
- **D.** MERGE que inserta filas nuevas

**La respuesta correcta es la C.** Actualizar una columna no indexada no obliga a actualizar las entradas de todos esos índices, a diferencia de INSERT/DELETE; en nuestra prueba UPDATE importe dio un coste muy parecido en escenarios con 4 y 9 índices. **Parte:** G.

<p align="center">★</p>

S10. ¿Qué determina principalmente la altura de un índice B-tree con un número de filas dado? 

- **A.** El clustering factor.
- **B.** El factor de ramificación (entradas por bloque de rama), que depende del tamaño de la clave.
- **C.** El número de columnas de la tabla.
- **D.** El valor de PCTFREE de la tabla.

**La respuesta correcta es la B.** La ramificación depende de cuántas claves caben por rama. Medimos fan-out máximo estimado 543 y altura 3 para un millón de pedidos. **Parte:** C.

<p align="center">★</p>

S11. ¿Qué dos afirmaciones sobre una tabla organizada como índice (IOT) son correctas? (Elige dos.) 

- **A.** Las filas se guardan en el propio índice de la clave primaria.
- **B.** No puede tener índices secundarios.
- **C.** Una búsqueda por clave primaria evita el acceso a un segmento de tabla aparte.
- **D.** No necesita clave primaria.
- **E.** Sus filas tienen ROWID físico fijo.

**La respuesta correcta es la A y C.** En una IOT las filas residen en el propio B-tree de la clave primaria; la búsqueda no exige el salto a un segmento de tabla independiente. **Parte:** D.

<p align="center">★</p>

S12. Al abrir la base, ¿qué compara Oracle para decidir si un datafile necesita recuperación? 

- **A.** El tamaño del datafile con el del diccionario.
- **B.** El SCN de checkpoint del control file con el de la cabecera del datafile.
- **C.** La fecha de modificación del archivo.
- **D.** El número de bloques sucios del buffer cache.

**La respuesta correcta es la B.** El SCN de checkpoint del control file se contrasta con el de las cabeceras de los datafiles; comprobamos 3.499.194 en ambos tras un checkpoint. **Parte:** I.

<p align="center">★</p>

S13. ¿Qué proceso registra el checkpoint en el control file y en las cabeceras de los datafiles? 

- **A.** DBWn
- **B.** LGWR
- **C.** CKPT
- **D.** SMON

**La respuesta correcta es la C.** CKPT registra la información del checkpoint; DBWn escribe bloques de datos y LGWR redo. **Parte:** I.

<p align="center">★</p>

S14. La instancia está en estado NOMOUNT. ¿Qué dos consultas responden sin error? (Elige dos.) 

- **A.** SELECT name FROM v$database;
- **B.** SELECT status FROM v$instance;
- **C.** SELECT username FROM dba_users;
- **D.** SELECT member FROM v$logfile;
- **E.** SELECT name, value FROM v$parameter;

**La respuesta correcta es la B y E.** NOMOUNT ya dispone de estructuras de instancia y parámetros, pero todavía no ha montado el control file para consultas de información de la base. **Parte:** I y J.

<p align="center">★</p>

S15. ¿Cuál es la secuencia correcta para activar el modo ARCHIVELOG? 

- **A.** ALTER DATABASE ARCHIVELOG con la base abierta.
- **B.** SHUTDOWN IMMEDIATE; STARTUP MOUNT; ALTER DATABASE ARCHIVELOG; ALTER DATABASE OPEN;
- **C.** STARTUP NOMOUNT; ALTER DATABASE ARCHIVELOG; ALTER DATABASE MOUNT;
- **D.** ALTER SYSTEM SET log_archive_start = TRUE SCOPE = BOTH;

**La respuesta correcta es la B.** Se cierra limpiamente, se arranca en MOUNT, se activa ARCHIVELOG y se abre la base. **Parte:** L.

<p align="center">★</p>

S16. Se pierde el único miembro de un grupo de redo INACTIVE ya archivado. ¿Qué se hace? 

- **A.** Restaurar la base entera.
- **B.** ALTER DATABASE CLEAR LOGFILE GROUP n para recrearlo.
- **C.** RECOVER DATABASE UNTIL CANCEL.
- **D.** Nada: Oracle lo recrea solo.

**La respuesta correcta es la B.** Para un grupo INACTIVE ya archivado y sin miembro restante, CLEAR LOGFILE permite recrear el redo sin restaurar todos los datafiles; debe corroborarse que realmente es reutilizable. **Parte:** K.

<p align="center">★</p>

S17. ¿Qué dos usos tiene el undo además de permitir ROLLBACK? (Elige dos.) 

- **A.** Lectura consistente.
- **B.** Recuperación de medios de un datafile.
- **C.** Consultas de flashback (AS OF).
- **D.** Archivado del redo.
- **E.** Ordenaciones grandes.

**La respuesta correcta es la A y C.** El undo permite reconstruir la imagen anterior para lectura consistente y FLASHBACK AS OF, además de deshacer transacciones. **Parte:** M.

<p align="center">★</p>

S18. ¿Por qué un cambio en el undo también genera redo? 

- **A.** Porque el undo se guarda en el redo log.
- **B.** Porque los bloques de undo pueden perderse en una caída y hay que poder rehacerlos antes de deshacer.
- **C.** Porque LGWR escribe el undo en los datafiles.
- **D.** No lo genera: el undo es independiente del redo.

**La respuesta correcta es la B.** Los bloques de undo también deben poder reconstruirse tras la caída, para después deshacer correctamente las transacciones sin COMMIT. **Parte:** M.

<p align="center">★</p>

S19. Una sesión recibe "Commit complete". ¿Qué está garantizado? 

- **A.** El redo de la transacción está en el redo log online.
- **B.** Los bloques modificados están en los datafiles.
- **C.** El redo está archivado en la FRA.
- **D.** Se ha hecho un checkpoint.

**La respuesta correcta es la A.** El commit asegura el redo en el online redo log, aunque los bloques sigan sucios en caché: observamos 231 bloques sucios tras COMMIT. **Parte:** N.

<p align="center">★</p>

S20. El parámetro FAST_START_MTTR_TARGET se reduce de 300 a 30. ¿Qué efecto tiene? 

- **A.** Los checkpoints incrementales son más frecuentes y la recuperación de instancia más rápida.
- **B.** LGWR escribe con más frecuencia.
- **C.** Se archivan antes los redo logs.
- **D.** Aumenta la retención de undo.

**La respuesta correcta es la A.** Un objetivo MTTR menor induce checkpoints incrementales más activos para reducir el redo pendiente de recuperación; conlleva más actividad de escritura. **Parte:** I y N.

<p align="center">★</p>

S21. Las sesiones esperan en "log file switch (archiving needed)". ¿Cuál es la causa más probable? 

- **A.** El redo log es demasiado grande.
- **B.** ARCn no puede archivar, por ejemplo porque la FRA está llena.
- **C.** Hay demasiados índices en la tabla.
- **D.** UNDO_RETENTION es demasiado bajo.

**La respuesta correcta es la B.** ARCn no ha archivado los grupos necesarios; una FRA llena es causa típica. Nuestra prueba mostró ORA-19815, ORA-19809 y ORA-16038. **Parte:** L.

<p align="center">★</p>

S22. Una consulta falla con ORA-01116, ORA-01110 y ORA-27041 sobre el datafile de un tablespace de aplicación. La base está en ARCHIVELOG y hay copias de RMAN. ¿Qué es lo PRIMERO que haces para mantener el resto del servicio? 

- **A.** SHUTDOWN ABORT.
- **B.** ALTER DATABASE DATAFILE n OFFLINE.
- **C.** RESTORE DATABASE.
- **D.** ALTER SYSTEM SWITCH LOGFILE.

**La respuesta correcta es la B.** Si la PDB continúa abierta, el primer paso es aislar el datafile no crítico con OFFLINE antes de RESTORE y RECOVER; si Oracle ya cerró la PDB, se sigue la rama MOUNTED como ocurrió en nuestra prueba. **Parte:** O.D.

<p align="center">★</p>

S23. Se pierde un datafile del tablespace SYSTEM. ¿Qué secuencia es correcta? 

- **A.** OFFLINE, RESTORE, RECOVER, ONLINE con la base abierta.
- **B.** SHUTDOWN ABORT, STARTUP MOUNT, RESTORE DATAFILE, RECOVER DATAFILE, ALTER DATABASE OPEN.
- **C.** FLASHBACK TABLESPACE SYSTEM.
- **D.** ALTER DATABASE OPEN RESETLOGS.

**La respuesta correcta es la B.** Si se pierde un archivo de SYSTEM de la raíz, no puede recuperarse en caliente como un tablespace de aplicación. Se monta la base, se restaura y se recupera antes de abrir. **Parte:** O.D y teoría de recuperación.

<p align="center">★</p>

S24. En NOARCHIVELOG se pierde un datafile de aplicación. ¿Qué afirmación es correcta? 

- **A.** Se recupera con RECOVER DATAFILE sin pérdida.
- **B.** Solo se puede restaurar desde una copia en frío y se pierde lo posterior a ella.
- **C.** Se recupera con FLASHBACK DATABASE.
- **D.** SMON lo recupera al arrancar.

**La respuesta correcta es la B.** Sin redo archivado no se puede rehacer todo lo posterior a la copia; normalmente se vuelve a una copia coherente en frío y se pierden cambios posteriores. **Parte:** L y O.C.

<p align="center">★</p>

S25. ¿Qué dos medidas son adecuadas ante ORA-01555 en un informe nocturno? (Elige dos.) 

- **A.** Aumentar el tamaño de los redo logs.
- **B.** Aumentar UNDO_RETENTION y el tamaño del undo.
- **C.** Pasar a NOARCHIVELOG.
- **D.** RETENTION GUARANTEE en el tablespace de undo si la consulta es crítica.
- **E.** Aumentar LOG_BUFFER.

**La respuesta correcta es la B y D.** Ampliar retención y espacio de undo, y valorar RETENTION GUARANTEE cuando sea crítico, ayuda a evitar que se sobrescriba el undo requerido por la consulta. **Parte:** M.

<p align="center">★</p>

S26. ¿Qué vista muestra el uso de la FRA por tipo de archivo? 

- **A.** V$RECOVERY_AREA_USAGE
- **B.** V$ARCHIVE_DEST
- **C.** DBA_FREE_SPACE
- **D.** V$LOG

**La respuesta correcta es la A.** V$RECOVERY_AREA_USAGE distribuye el uso de la FRA por tipo de archivo; V$RECOVERY_FILE_DEST ofrece las cifras globales. **Parte:** L y P.


<p align="center">★		★		★</p>


## 3. Anexo. Preguntas tipo examen por partes

### B1. Parte B (Pág. 12)

B1. Un plan real muestra E-Rows = 25 000 y A-Rows = 20 en el paso de acceso por índice sobre la columna estado. ¿Cuál es la causa más probable? 

- **A.** El índice está fragmentado.
- **B.** Faltan estadísticas con histograma en una columna de distribución sesgada.
- **C.** La tabla tiene filas migradas.
- **D.** La consulta no es sargable.

**La respuesta correcta es la B.** La estimación 25.000 frente a 20 reales indica selectividad mal estimada, compatible con sesgo sin histograma; en nuestro banco ESTADO tiene 4 valores y distribución P = 2 % / C = 90 %.

### C1. Parte C (Pág. 18)

C1. Un índice tiene BLEVEL = 2 en DBA_INDEXES. ¿Cuántas lecturas lógicas necesita, como mínimo, una búsqueda por igualdad sobre su clave única que devuelve una columna que no está en el índice? 

- **A.** 2
- **B.** 3
- **C.** 4
- **D.** 5

**La respuesta correcta es la C.** BLEVEL = 2 implica altura de índice 3; una columna fuera de la clave requiere además 1 bloque de tabla, total mínimo 4.

### C2. Parte C (Pág. 19)

C2. Un índice tiene 2 000 000 de hojas y un factor de ramificación máximo de 500. ¿Qué altura tendrá? 

- **A.** 2
- **B.** 3
- **C.** 4
- **D.** 5

**La respuesta correcta es la C.** Con 2.000.000 de hojas y fan-out 500, hacen falta tres niveles de ramas/recorrido sobre hojas: altura = 1 + techo(log_500(2.000.000)) = 4.

### D1. Parte D (Pág. 23)

D1. Una tabla de hechos se carga una vez por noche y los analistas filtran por combinaciones de región (6 valores), canal (3) y año (5). ¿Qué tipo de índice es más apropiado en esas columnas? 

- **A.** B-tree compuesto (region, canal, anio).
- **B.** Un índice bitmap en cada columna.
- **C.** Un índice basado en funciones.
- **D.** Un clúster hash por region.

**La respuesta correcta es la B.** Los bitmap individuales por región, canal y año permiten combinar filtros por BITMAP AND en un almacén de poca escritura. **Parte:** D.

### D2. Parte D (Pág. 24)

D2. ¿Qué dos afirmaciones sobre un índice cubriente son correctas? (Elige dos.) 

- **A.** Evita el acceso a la tabla si la consulta solo usa columnas del índice.
- **B.** Siempre ocupa menos que la tabla.
- **C.** Encarece cada INSERT y cada UPDATE de sus columnas.
- **D.** Se declara en Oracle con la cláusula INCLUDE.
- **E.** Solo puede tener una columna.

**La respuesta correcta es la A y C.** El cubriente evita acceder a la tabla si contiene todos los datos solicitados, pero aumenta el coste de mantener las columnas indexadas durante escritura.

### E1. Parte E (Pág. 27)

E1. Un índice tiene CLUSTERING_FACTOR = 9 950 000 sobre una tabla de 10 000 000 filas y 80 000 bloques. Una consulta pide el 3 % de las filas por ese índice. ¿Qué plan es razonable? 

- **A.** Rango por índice, porque el 3 % es poco.
- **B.** Recorrido completo de tabla.
- **C.** Reconstruir el índice para mejorar el CF y luego usar el índice.
- **D.** Un índice bitmap.

**La respuesta correcta es la B.** CF ≈ 9.950.000 implica casi un salto de bloque por fila y el 3 % equivale a 300.000 filas; un full scan de 80.000 bloques es razonable.

### F1. Parte F (Pág. 30)

F1. La columna num_factura es VARCHAR2(10) y tiene un índice. ¿Qué predicado impide usarlo? 

- **A.** num_factura = '2025001'
- **B.** num_factura = 2025001
- **C.** num_factura LIKE '2025%'
- **D.** num_factura BETWEEN '2025000' AND '2025999'

**La respuesta correcta es la B.** Comparar un VARCHAR2 con un número puede aplicar TO_NUMBER a la columna e inutilizar el B-tree normal.

### F2. Parte F (Pág. 30)

F2. ¿Qué dos reescrituras convierten WHERE TRUNC(fecha) = DATE '2026-10-18' en una condición sargable equivalente? (Elige dos.) 

- **A.** fecha >= DATE '2026-10-18' AND fecha < DATE '2026-10-19'
- **B.** fecha = DATE '2026-10-18'
- **C.** fecha BETWEEN DATE '2026-10-18' AND DATE '2026-10-18' + INTERVAL '86399' SECOND
- **D.** TO_CHAR(fecha, 'YYYY-MM-DD') = '2026-10-18'
- **E.** fecha + 0 = DATE '2026-10-18'

**La respuesta correcta es la A y C.** Ambas formulan un intervalo del mismo día sin función sobre FECHA; en C, el último segundo de un DATE es 23:59:59. En tipos con fracciones de segundo conviene el intervalo semiabierto A.

### G1. Parte G (Pág. 36)

G1. Quieres comprobar si la aplicación sigue necesitando un índice antes de borrarlo, sin dejar de mantenerlo y pudiendo dar marcha atrás al instante. ¿Qué haces? 

- **A.** ALTER INDEX ... UNUSABLE
- **B.** ALTER INDEX ... INVISIBLE
- **C.** DROP INDEX y recrearlo si hay quejas
- **D.** ALTER INDEX ... NOLOGGING

**La respuesta correcta es la B.** ALTER INDEX ... INVISIBLE permite ensayo reversible sin dejar de mantener el índice.

### G2. Parte G (Pág. 36)

G2. Una tabla tiene 3 índices B-tree y recibe 500 INSERT de una fila por segundo. Con lo medido en esta parte, ¿cuántos bloques modificados por segundo, aproximadamente, añade un cuarto índice? 

- **A.** Unos 500
- **B.** Unos 1000
- **C.** Unos 2000
- **D.** Ninguno: los índices se actualizan al hacer COMMIT

**La respuesta correcta es la B.** Cada índice adicional suma unos dos bloques modificados por INSERT (hoja y undo); 500 inserciones/s × 2 ≈ 1.000 bloques/s.

### H1. Parte H (Pág. 42)

H1. Una tabla de eventos recibe claves crecientes y cada noche se borran los eventos de más de 30 días. La consulta "evento más antiguo pendiente" se ha vuelto lenta. ¿Qué acción resuelve el síntoma en línea y con el menor coste? 

- **A.** ALTER INDEX ... REBUILD
- **B.** ALTER INDEX ... COALESCE
- **C.** Crear el índice como REVERSE
- **D.** DBMS_STATS.GATHER_INDEX_STATS

**La respuesta correcta es la B.** COALESCE remedia en línea las hojas vacías de la izquierda; en nuestro caso bajó de 226 a 2 lecturas.

### H2. Parte H (Pág. 42)

H2. ¿Qué dos afirmaciones sobre un índice REVERSE son correctas? (Elige dos.) 

- **A.** Reduce la contención en la hoja de más a la derecha con claves crecientes.
- **B.** Permite rangos más rápidos que un índice normal.
- **C.** No puede usarse para una condición BETWEEN sobre la clave.
- **D.** Mejora el factor de agrupamiento de la tabla.
- **E.** Evita las divisiones de hoja.

**La respuesta correcta es la A y la C.** REVERSE distribuye inserciones crecientes, pero ya no ofrece búsqueda eficiente BETWEEN sobre el orden original.

### I1. Parte I (Pág. 46)

I1. Al abrir la base, ¿qué compara Oracle para decidir si un datafile necesita recuperación? 

- **A.** El tamaño del datafile con el registrado en el diccionario.
- **B.** El SCN de checkpoint del control file con el de la cabecera del datafile.
- **C.** La fecha de modificación del archivo en el sistema operativo.
- **D.** El número de bloques sucios del buffer cache.

**La respuesta correcta es la B.** El SCN del checkpoint en el control file y en la cabecera del datafile determina la necesidad de recuperación.

### J1. Parte J (Pág. 49)

J1. Una de las tres copias del control file se corrompe con la base abierta. ¿Qué ocurre? 

- **A.** Oracle sigue funcionando con las dos copias restantes sin ningún aviso.
- **B.** La instancia se detiene; hay que sustituir la copia dañada por una sana (o quitarla de CONTROL_FILES) y arrancar.
- **C.** Oracle recrea automáticamente la copia dañada a partir de las otras.
- **D.** Hay que restaurar todos los datafiles desde la última copia.

**La respuesta correcta es la B.** Oracle no puede ignorar sin aviso una copia configurada defectuosa: se sustituye por una sana o se reconfigura CONTROL_FILES antes de montar.

### J2. Parte J (Pág. 49)

J2. ¿Qué dos datos guarda el control file? (Elige dos.) 

- **A.** El nombre y la ubicación de los datafiles y redo logs.
- **B.** Los valores de los parámetros de inicialización.
- **C.** El SCN del último checkpoint.
- **D.** Las contraseñas de los usuarios SYSDBA.
- **E.** Las filas del diccionario de datos.

**La respuesta correcta es la A y C.** El control file registra ubicación de datafiles/redo y los checkpoints, no contraseñas ni las filas del diccionario.

### K1. Parte K (Pág. 52)

K1. Un grupo de redo tiene estado ACTIVE. ¿Qué afirmación es correcta? 

- **A.** LGWR está escribiendo en él.
- **B.** Se puede borrar sin consecuencias.
- **C.** Contiene cambios que aún podrían necesitarse para una recuperación de instancia.
- **D.** Ya ha sido archivado necesariamente.

**La respuesta correcta es la C.** ACTIVE contiene redo aún necesario potencialmente para recuperación; CURRENT es el que LGWR usa ahora.

### L1. Parte L (Pág. 57)

L1. Un DBA ejecuta ALTER SYSTEM SET db_recovery_file_dest = '/u03/fra'; en una base sin FRA configurada y recibe un error. ¿Cuál es la causa? 

- **A.** La base no está en ARCHIVELOG.
- **B.** Falta fijar antes DB_RECOVERY_FILE_DEST_SIZE.
- **C.** DB_RECOVERY_FILE_DEST es estático y exige SCOPE=SPFILE.
- **D.** La ruta debe ser un grupo ASM.

**La respuesta correcta es la B.** Se debe configurar primero DB_RECOVERY_FILE_DEST_SIZE y después la ruta DB_RECOVERY_FILE_DEST.

### L2. Parte L (Pág. 57)

L2. Las sesiones de una base en ARCHIVELOG se quedan esperando en "log file switch (archiving needed)" y las nuevas conexiones reciben ORA-00257. ¿Qué dos acciones resuelven el problema? (Elige dos.) 

- **A.** Aumentar DB_RECOVERY_FILE_DEST_SIZE si hay espacio en disco.
- **B.** Ejecutar ALTER SYSTEM SWITCH LOGFILE repetidamente.
- **C.** Hacer copia de los archivados con RMAN y borrarlos con DELETE INPUT.
- **D.** Pasar la base a NOARCHIVELOG en caliente.
- **E.** Borrar los .arc de la FRA con rm.

**Las respuestas correctas son la A y la C.** Se puede ampliar el límite cuando exista espacio real o gestionar correctamente los archivados ya copiados usando RMAN; no borrar archivos a mano.

### M1. Parte M (Pág. 63)

M1. La sesión A ejecuta un UPDATE de una fila y no confirma. La sesión B consulta esa fila. ¿Qué ve B? 

- **A.** El valor nuevo, porque el bloque del buffer cache ya está modificado.
- **B.** Un error ORA-00054, porque la fila está bloqueada.
- **C.** El valor confirmado anterior, reconstruido con el undo.
- **D.** Nada: la consulta espera hasta que A haga COMMIT o ROLLBACK.

**La respuesta correcta es la C.** La sesión lectora recupera el valor confirmado anterior mediante undo sin esperar el commit ajeno.

### M2. Parte M (Pág. 63)

M2. ¿Qué operación de 10 000 filas genera, en general, MÁS undo? 

- **A.** INSERT
- **B.** UPDATE de una columna no indexada
- **C.** DELETE
- **D.** SELECT … FOR UPDATE

**La respuesta correcta es la C.** DELETE conserva información suficiente para reconstruir las filas eliminadas: medimos 428 bloques de undo frente a 143 del INSERT y 71 del UPDATE.

### M3. Parte M (Pág. 63)

M3. Un informe nocturno falla con ORA-01555. ¿Qué dos medidas son adecuadas? (Elige dos.) 

- **A.** Aumentar el tamaño de los redo logs.
- **B.** Aumentar UNDO_RETENTION y el tamaño del tablespace de undo.
- **C.** Pasar la base a NOARCHIVELOG.
- **D.** Usar RETENTION GUARANTEE en el tablespace de undo si la consulta es crítica.
- **E.** Aumentar LOG_BUFFER.

**Las respuestas correctas son la B y la D.** Es necesario conservar undo el tiempo suficiente: más UNDO_RETENTION/espacio y RETENTION GUARANTEE si la consulta lo exige.

### N1. Parte N (Pág. 67)

N1. Una sesión recibe "Commit complete". ¿Qué está garantizado en ese momento? 

- **A.** El redo de la transacción está escrito en el redo log online.
- **B.** Los bloques modificados están escritos en los datafiles.
- **C.** El redo de la transacción está archivado en la FRA.
- **D.** Se ha hecho un checkpoint.

**La respuesta correcta es la A.** COMMIT garantiza redo escrito por LGWR, no necesariamente bloques de datos enviados por DBWn.

### N2. Parte N (Pág. 67)

N2. ¿En qué dos situaciones escribe DBWn bloques sucios en los datafiles? (Elige dos.) 

- **A.** En cada COMMIT.
- **B.** En un checkpoint.
- **C.** Cuando un proceso servidor no encuentra buffers libres.
- **D.** Cada 3 segundos, siempre.
- **E.** Cuando LGWR termina de escribir el log buffer.

**Las respuestas correctas son la B y la C.** DBWn vacía bloques sucios en checkpoints y cuando hace falta liberar buffers; no escribe toda la tabla en cada commit.

### O1. Parte O (Pág. 77)

O1. Tras un corte de luz, el DBA ejecuta STARTUP. ¿Qué ocurre? 

- **A.** La base queda en MOUNT y hay que ejecutar RECOVER DATABASE manualmente.
- **B.** SMON aplica el redo online y deshace las transacciones no confirmadas; la base abre sin intervención.
- **C.** Hay que restaurar los datafiles desde la última copia porque son inconsistentes.
- **D.** Se pierden las transacciones confirmadas desde el último checkpoint.

**La respuesta correcta es la B.** El arranque normal ejecuta recuperación automática de instancia con redo y undo; comprobado con estudiantes 102 y 103.

### O2. Parte O (Pág. 77)

O2. Una base tiene tres copias del control file. Una se borra con la base cerrada y STARTUP da ORA-00205. ¿Qué dos acciones permiten abrir la base sin perder datos? (Elige dos.) 

- **A.** RECOVER DATABASE USING BACKUP CONTROLFILE.
- **B.** Copiar una de las copias sanas sobre la perdida y montar.
- **C.** ALTER DATABASE OPEN RESETLOGS.
- **D.** Quitar la copia perdida de CONTROL_FILES en el SPFILE, reiniciar y montar.
- **E.** Restaurar todos los datafiles desde la última copia de RMAN.

**Las respuestas correctas son la B y D.** Puede reponerse la copia desde otro control file sano o quitarse la ruta perdida de CONTROL_FILES y volver a arrancar con las existentes.

### O3. Parte O (Pág. 78)

O3. En una base en ARCHIVELOG se pierde el datafile de un tablespace de aplicación. ¿Cuál es la secuencia que lo recupera sin cerrar la base y sin perder datos? 

- **A.** SHUTDOWN ABORT; STARTUP MOUNT; RESTORE DATABASE; RECOVER DATABASE; ALTER DATABASE OPEN RESETLOGS;
- **B.** ALTER DATABASE DATAFILE n OFFLINE; RESTORE DATAFILE n; RECOVER DATAFILE n; ALTER DATABASE DATAFILE n ONLINE;
- **C.** RESTORE DATAFILE n; ALTER DATABASE DATAFILE n ONLINE;
- **D.** FLASHBACK DATABASE TO SCN anterior a la pérdida;

**La respuesta correcta es la B.** Para un datafile no crítico: OFFLINE → RESTORE → RECOVER → ONLINE; si la PDB ya se cerró, variante MOUNTED.

### O4. Parte O (Pág. 78)

O4. Un usuario ejecutó DROP TABLE ventas PURGE; hace 10 minutos. La base está en ARCHIVELOG y hay copias de RMAN. ¿Qué opción recupera la tabla sin perder los cambios hechos en otras tablas? 

- **A.** FLASHBACK TABLE ventas TO BEFORE DROP;
- **B.** Restaurar la última copia completa de la base.
- **C.** SELECT * FROM ventas AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '15' MINUTE);
- **D.** RMAN RECOVER TABLE hasta un instante anterior al DROP.

**La respuesta correcta es la D.** Con PURGE no sirve la papelera, y restaurar toda la base descartaría cambios ajenos; RMAN RECOVER TABLE permite recuperar solo la tabla al instante anterior. **Parte:** O.C.

<p align="center">★		★		★</p>

## 4. Tabla de RTO/RPO y retrospectiva de los cuatro simulacros

| Prueba | Incidente | Mecanismo de recuperación | RTO observado | RPO acreditado |
|---|---|---|---|---|
| **O.A** | 'SHUTDOWN ABORT' | Recuperación de instancia: redo + undo | No cronometrado por el script | **0** para la transacción 102 confirmada |
| **O.B** | Falta 'control03.ctl' | Copia desde 'control01.ctl', MOUNT y OPEN | No cronometrado por el script | **0**: sin pérdida de transacciones observada |
| **O.C** | 'DROP TABLE ... PURGE' | Restauración completa de la copia anterior | **44 s** | Ventana potencial **1 s**; pérdida efectiva no cuantificada |
| **O.D** | Desaparición de 'academia01.dbf' (n.º 16) | RMAN RESTORE + RECOVER, PDB reabierta | **7 s** reparación; **8 s** desde el fallo | **0**: sobrevivió el COMMIT posterior al backup |

### Sucesos y aprendizaje

**Simulacro A.** Me sorprendió que Oracle se recuperara tras 'SHUTDOWN ABORT' sin restauración manual. El alumno 102 retuvo 'EGRESADO' por su 'COMMIT', mientras que el 103 apareció 'ACTIVO', porque su cambio nunca se confirmó. En el alert log se leyeron 1.576 KB de redo y se recuperaron 234 bloques. Una mejora operativa sería capturar además tiempos de indisponibilidad desde una sonda externa: este guion no mide RTO.

**Simulacro B.** El arranque falló con 'ORA-00205' aunque todavía quedaban dos control files sanos. Eso confirma que la multiplexación no significa que Oracle ignore una ruta configurada que falta: el DBA debe intervenir. La copia de 'control01.ctl' permitió reponer 'control03.ctl'. En producción situaría los miembros en dominios de fallo diferentes; en nuestro laboratorio estaban en el mismo volumen.

**Simulacro C.** 'FLASHBACK TABLE' recuperó las 60.000 matrículas cuando el borrado no llevaba 'PURGE'. Después de 'PURGE' fue necesario restaurar toda la base: **44 s** para reparar la pérdida de una sola tabla. El script indicó **1 s** desde la copia al fallo, pero eso es una ventana de posible pérdida, no prueba de datos realmente perdidos. Como mejora valoraría recuperación puntual de tabla mediante RMAN cuando haya copias y redo archivado, para no afectar los cambios de las demás tablas.

**Simulacro D.** El archivo 'academia01.dbf' desapareció y Oracle cerró 'FREEPDB1', que quedó 'MOUNTED'. RMAN recuperó únicamente el datafile 16 y el estudiante 104 conservó 'EGRESADO', confirmado después de la copia. Ese dato prueba un **RPO de 0**. La reparación tardó **7 s** y el tiempo desde el fallo **8 s**, muy inferior a los **44 s** del simulacro C. El procedimiento debe contemplar tanto el camino 'READ WRITE' como el de PDB cerrada ('MOUNTED').

**Conclusión común.** No todos los incidentes requieren restaurar la base completa. El objetivo profesional es diagnosticar el daño y elegir el mecanismo menos invasivo, con copias verificadas, alertas y tiempos medidos. El RTO solo está cuantificado para C y D porque A y B no registraron un cronómetro de servicio; atribuirles segundos sería inventarlos.

**Referencias:** 'docs/bitacora/lab5/evidencia/script/20261124T110932Z_14a-caida-instancia.script.log', 'docs/bitacora/lab5/evidencia/script/20261124T111108Z_14b-perdida-controlfile.script.log', 'docs/bitacora/lab5/evidencia/script/20261124T111221Z_14c-simulacro-restauracion.script.log' y 'docs/bitacora/lab5/evidencia/script/20261124T112146Z_14d-perdida-datafile.script.log'.


<p align="center">★		★		★</p>


## 5. Retrospectiva. FRA llena y healthcheck

### Incidente provocado: FRA de 2 MB

- **Impacto y detección:** al solicitar el archivado, el sistema devolvió 'ORA-16038' y 'ORA-19809'; en el alert log apareció 'ORA-19815' indicando que **2.097.152 bytes** de límite estaban **al 100 %**. En producción esta condición puede desembocar en esperas 'log file switch (archiving needed)' y bloqueo de cambios.
- **Causa raíz:** se redujo de forma deliberada el límite de la FRA por debajo del espacio requerido, para reproducir un fallo de capacidad.
- **Mitigación realizada:** se devolvió el límite a **4.096 MB**, ARCn terminó archivando las secuencias pendientes y la FRA quedó usando **10,6 MB**.
- **Prevención:** alertar de forma anticipada (por ejemplo, antes de llegar al 80 %), conservar una política de retención de copias y controlar que el límite configurado en memoria coincida con el persistido en SPFILE. No borrar los archivos '.arc' con comandos del sistema operativo.
- **Alcance de la La evidencia está en** consta el fallo de archivado y su resolución; la evidencia aportada no muestra una medida de segundos de espera de una sesión de negocio, de modo que no se inventa esa cifra.

**Referencia:** 'docs/bitacora/lab5/evidencia/script/20261124T095449Z_11-fra-llena.script.log'.

### Estado tras los simulacros — Healthcheck de solo lectura

La ejecución mediante 'C##OPS_RO' mostró instancia 'OPEN', CDB y PDB 'READ WRITE', FRA **100 de 4.096 MB (2,4 %)**, **3** control files, **0** grupos redo con un solo miembro, copia RMAN 'DATAFILE FULL COMPLETED' de **38 MB en 3 s**, y **0** errores 'ORA-01555' y **0** errores de espacio de undo. La consulta más larga registrada en 'v$undostat' fue de **363 s**; nuestra retención objetivo de undo era **900 s**. Entre los avisos históricos se identificaron correctamente los fallos esperados de O.B y O.D y el ruido 'ORA-00800' relativo a las prioridades de LGWR/VKTM.

Los índices sin estadísticas eran **8** de ADMIN_CLINICA, **6** de ADMIN_FINTECH, **6** de ADMIN_LOGISTICA y **7** de ADMIN_RETAIL, en total **27**. Es una advertencia contextual, no razón automática para reconstruirlos: en esquemas vacíos puede ser normal.

**Referencia:** 'docs/bitacora/lab5/evidencia/spool/20261124T113411Z_15-healthcheck.spool.log'.


<p align="center">★		★		★</p>


## 6. Estado final y entrega

El script '16-verificacion-final.sh' terminó con **'RESULTADO: TODO OK. Lab 5 listo para entregar.'** Comprobó **100.000 clientes**, **1.000.000 de pedidos**, el paquete 'LAB_TOOLS.MEDIR' válido, los índices definitivos de V005, tres control files, grupos redo con miembros duplicados, 'ARCHIVELOG', FRA persistida de **4 GiB**, copia RMAN y recuperación de **60.000 matrículas**. Los estudiantes **101, 102 y 104** quedaron en 'ACTIVO'. Verificó asimismo las evidencias numeradas **00–15**, las contraseñas fuera del repositorio mediante 'config/.env' y que las copias físicas no se habían versionado.

**Evidencia final:** 'docs/bitacora/lab5/evidencia/script/20261124T113444Z_16-verificacion-final.script.log'.

**Advertencia sobre el control de seguridad Q.2:** los resultados del script de verificación no sustituyen el escaneo específico de secretos en los archivos y la historia de Git. Ese control se debe ejecutar antes del 'push'.

