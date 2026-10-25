# Práctica 1 — Laboratorio 3
## Respuestas a las preguntas de comprobación
### Instalación del entorno Oracle
## 8.1.1. Docker
### 1. ¿Qué diferencia hay entre una imagen y un contenedor? Usa como ejemplo lo que hiciste en los ejercicios G2 y G4.
Imagen de Docker: Especie de plantilla que contiene los archivos, programas y configuraciones necesarios para ejecutar una aplicación. Se puede entender como el punto de partida a partir del cual se crean los contenedores.
Contenedor: Instancia creada a partir de esa imagen. Tiene su propio entorno de ejecución y se puede iniciar, detener o eliminar sin que desaparezca necesariamente la imagen original.
En G2 se emplea ‘hello-world’. Cuando es ejecutado ‘docker run hello-world’, Docker buscó la imagen y, si no estaba descargada, la obtuvo de Docker Hub. Después generó un contenedor que mostró un mensaje y terminó su ejecución.
En G4 se utiliza ‘docker run -it --name prueba alpine:3.20 sh’. En este caso, el contenedor permite el acceso a una terminal de Alpine Linux y la ejecución comandos dentro de ella.
La principal diferencia es que la imagen proporciona los elementos necesarios para crear un contenedor, mientras que el contenedor es el entorno donde se ejecutan los procesos.
Además, una misma imagen puede ser utilizada para la creación de varios contenedores independientes; es la razón por la cual es posible eliminar un contenedor de pruebas y crear otro a partir de la misma imagen sin necesidad de descargarla nuevamente.

### 2. En el Ejercicio G5 el archivo ‘nota.txt’ desapareció y en el G6 no. Explica por qué.
En G5 se crea un archivo llamado ‘nota.txt’ dentro del sistema de archivos de un contenedor de Alpine. Mientras ese contenedor existía, podía accederse al archivo y consultar su contenido.
Sin embargo, tras la eliminación del contenedor y la creación de otro diferente. Al intentar acceder nuevamente a ‘nota.txt’, se podía comprobar como ya no estaba disponible.
Esto sucedió porque el archivo se había guardado en la capa escribible del primer contenedor. Al eliminar ese contenedor, también desapareció su sistema de archivos particular.
En G6 es empleada una solución diferente: Generar un volumen de Docker llamado ‘datos-prueba’ y realizar su montaje en ‘/datos’ del contenedor.
Cuando es guardado ‘nota.txt’ dentro de ‘/datos’, el archivo queda almacenado en el volumen, no exclusivamente en la capa escribible del contenedor. Por eso, aunque sea eliminase el contenedor y se pudo generar otro utilizando el mismo volumen, pudiendo recuperar el archivo.
La diferencia muestra el concepto fundamental, es decir, el contenedor el contenedor ejecuta la aplicación, mientras que el volumen permite conservar los datos independientemente de ella.
En la instalación de Oracle es aplicada esta idea mediante el volumen ‘oralab-26ai-data’, que almacena los archivos de la base de datos. Así se evita la perdida de las tablas y la información si se necesita recrear el contenedor.

### 3. ¿Qué diferencia hay entre ‘docker ps’ y ‘docker ps -a’, y qué significa ‘STATUS = Exited (0)’?
‘docker ps’ muestra los contenedores que están funcionando en ese momento. Es útil cuando se desea comprobar qué servicios permanecen activos. Ej.:  Tras la ejecución de este comando durante la práctica, se podía comprobar si el contenedor ‘oralab-26ai’ estaba en ejecución.
‘docker ps -a’ muestra todos los contenedores, incluidos los que están funcionando, los que se han detenido y los que ya han terminado su ejecución.
La diferencia es que el primero muestra solamente los contenedores activos, mientras que el segundo permite consultar también su historial de estados.
Cuando Docker muestra ‘Exited (0)’, significa que el proceso principal del contenedor ha terminado y ha devuelto el código de salida cero. Normalmente, este código indica que el proceso ha finalizado correctamente. Esto sucede con ‘hello-world’, es decir, es ejecutada su tarea, muestra un mensaje y termina. Por tanto, encontrarlo detenido no significa necesariamente que haya ocurrido un error.
Con estas detenidas observaciones se puede comprender que un contenedor detenido no tiene por qué ser un contenedor que haya fallado. Para interpretar su estado, también se debe conocer qué trabajo tenía que realizar.
### 4. En ‘-p 8181:8181’, ¿qué número corresponde a tu equipo y cuál al contenedor? ¿Qué pasaría con ‘-p 80:8080’ en el ejercicio de nginx?
La opción ‘-p’ de Docker permite publicar un puerto del contenedor para acceder a él desde nuestro equipo.
La sintaxis es ‘-p puerto_del_equipo:puerto_del_contenedor’
Por tanto, cuando se escribe ‘-p 8181:8181’, el primer número corresponde al puerto de nuestro ordenador y el segundo al puerto del contenedor. 
En G7 se emplea nginx con el comando ‘docker run -d --name web -p 8080:80 nginx:alpine’. Con esta configuración, Docker enviaba las conexiones recibidas en el puerto 8080 de nuestro equipo al puerto 80 del contenedor, que es donde nginx estaba escuchando. Así podíamos abrir su página desde ‘http://localhost:8080’.
Si hubiera sido utilizado ‘-p 80:8080’, se hubiera hecho lo contrario, es decir, Docker hubiera enviado las conexiones del puerto 80 de nuestro ordenador al puerto 8080 del contenedor.

El problema es que nginx estaba configurado para escuchar en el puerto 80, no en el 8080. Por tanto, la página no habría funcionado con esa configuración.
Es por esto que debe ser esencial conocer tanto el puerto a utilizar en nuestro ordenador como el puerto en el que realmente escucha la aplicación dentro del contenedor.
También se puede comprobar con Oracle, aunque inicialmente se publica el puerto 8181, eso no significa que Database Actions estuviera disponible. Para su uso se tuvo que instalar ORDS por separado y configurar su servidor web en el puerto 8080.
### 5. ¿Por qué un contenedor de Oracle se queda en marcha y el de ‘hello-world’ termina solo?
La duración de un contenedor depende fundamentalmente de su proceso principal.
En el caso de ‘hello-world’, el programa tiene una tarea muy sencilla: mostrar un mensaje informativo y terminar. Una vez realizada esa operación, ya no queda ningún proceso principal que mantener, por lo que Docker detiene el contenedor.
Sin embargo, una base de datos Oracle funciona como un servicio. Su motor debe permanecer activo para atender conexiones, ejecutar consultas SQL, administrar usuarios y permitir el acceso a los datos. Es por esto que el contenedor ‘oralab-26ai’ continúa funcionando mientras su proceso principal permanece en ejecución.
Además, durante el laboratorio es comprobado como aparecía con el estado ‘healthy’. Esto significa que Docker había ejecutado satisfactoriamente las comprobaciones de salud configuradas para el contenedor.
En este caso se aprende que no todos los contenedores están diseñados para permanecer activos. Algunos pueden ejecutar tareas que terminan rápidamente y otros mantienen sus servicios disponibles de forma continua.

### 6. ¿Qué es el digest de una imagen y por qué lo registramos si ya sabemos que usamos ‘:latest’?
Digest: Identificador basado en un hash criptográfico que permite reconocer de manera precisa el contenido de una imagen de Docker.
Cuando una imagen es utilizada con la etiqueta ‘latest’, esta siendo solicitada una versión que el fabricante identifica con esa etiqueta. Sin embargo, ‘latest’ no representa necesariamente una versión fija. Ej.: Oracle puede publicar una actualización y modificar la imagen a la que apunta ‘latest’. Si se descarga la imagen antes y después de esa actualización, se pueden obtener contenidos diferentes utilizando aparentemente el mismo nombre.
Digest se dedica a resolver este problema debido que permite identificar el contenido concreto de la imagen descargada.
Durante este tercer laboratorio, se registra el digest SHA-256 de la imagen oficial de Oracle. Esto proporciona una referencia precisa para saber qué imagen se utilizó al preparar el entorno. Por tanto, la etiqueta facilita localizar una imagen, mientras que el digest permite identificar exactamente su contenido.
Esta distinción es importante para la trazabilidad y la reproducibilidad, especialmente cuando se requiere la investigación de errores o la repetición de una instalación en otro equipo.

### 7. ¿Qué comando borraría realmente los datos de Oracle? ¿Por qué ‘docker rm oralab-26ai’ no lo hace?
En el laboratorio se han almacenado los datos de Oracle en un volumen persistente llamado ‘oralab-26ai-data’. Este volumen es un recurso independiente del contenedor y se encuentra gestionado por Docker; es por ello que los archivos de la base de datos pueden conservarse, aunque sea eliminado el contenedor que los utiliza.
Si se ejecuta ‘docker rm oralab-26ai’, es eliminado el contenedor, pero no se borra automáticamente el volumen con nombre donde están almacenados los datos. Para eliminar ese almacenamiento se debería ejecutar ‘docker volume rm oralab-26ai-data’, siempre que no existieran contenedores que estuvieran utilizando ese volumen.
La diferencia es importante porque eliminar un contenedor y eliminar la información de una base de datos son operaciones distintas.
Esto permite que pueda generarse un nuevo contenedor Oracle y se pueda volver a montar el volumen existente para recuperar la información, siempre que sea empleada una configuración compatible. Por ello, el comando que realmente pondría en peligro los datos persistentes es el que elimina el volumen, no simplemente el que elimina el contenedor.

## 8.1.2. Git, organización y evidencia
### 8. ¿Por qué este laboratorio se hace dentro del repositorio ‘oracle-database-lab’, con Issue, branch y Pull Request, en vez de en una carpeta aparte?
El objetivo no consiste únicamente en instalar una base de datos Oracle, sino también en aprender a realizar esa instalación de forma organizada, documentada y reproducible. Por eso se emplea el repositorio ‘oracle-database-lab’ en lugar de guardar los scripts y documentos en una carpeta independiente sin control de versiones.
Primero se genera una Issue. En este caso, por generaciones anteriores, es la número 5; este número sirve para identificar y describir el trabajo que debe ser realizado. Después se genera la rama ‘chore/5-install-oracle-environment’, que permite trabajar sin modificar directamente la rama principal ‘main’. A medida que se avanza, se van realizando commits para registrar los scripts, las migraciones y las verificaciones.
La Pull Request se toma como el mecanismo que permite presentar estos cambios para su revisión antes de incorporarlos al ‘main’. Este procedimiento ofrece varias ventajas, desde consultar el historial, pasando por la localización de modificaciones concretas y la detección de errores, hasta la facilitación para que otra persona comprenda cómo se ha preparado el entorno.
Es decir, Git permite conservar tanto el resultado final como la evolución del trabajo. Es así que el ejercicio se transforma de una mecanización en la cual guardar los archivos en una carpeta sin historial a un proyecto profesional en el que se puede desarrollar cada persona.

### 9. ¿Qué diferencia hay entre ‘source 00-config.sh’ y ‘bash 00-config.sh’? ¿Por qué usamos ‘source’?
La principal diferencia está en el entorno donde se ejecutan las instrucciones del archivo.
Cuando se ejecuta un script mediante ‘bash’, se inicia un nuevo proceso de Bash. Las variables que se crean dentro de ese proceso pertenecen a él y, normalmente, dejan de estar disponibles cuando termina. Pero, cuando se ejecuta ‘source’, las instrucciones del archivo se ejecutan dentro de la sesión de terminal que ya tenemos abierta. Esto permite que las variables y funciones definidas en el archivo permanezcan disponibles para los comandos que ejecutemos después.
En el laboratorio se ha creado ‘scripts/deployment/env/00-config.sh’ para centralizar los nombres y rutas de nuestro entorno. Allí definimos variables como ‘CONT_NAME’, ‘VOL_NAME’, ‘SERVICE_PDB’, ‘EVID’ y ‘ORDS_PORT’.
Con la ejecución de ‘source scripts/deployment/env/00-config.sh’, todas esas constantes quedan disponibles en nuestra terminal. Es así que se pueden escribir comandos usando ‘$CONT_NAME’ o ‘$EVID’ en lugar de repetir constantemente los nombres y rutas completos.
Se debe recordar que ‘source’ sirve para incorporar la configuración a la sesión actual, mientras que ‘bash’ ejecuta el archivo en un proceso independiente.

### 10. Explica cada parte del nombre ‘20260915T091230Z_02-docker.script.log’.
Este nombre sigue una convención que permite identificar las evidencias de manera ordenada. La primera parte, ‘20260915’, indica la fecha en la que se generó el archivo: 15 de septiembre de 2026. La letra ‘T’ separa la fecha de la hora. A continuación, ‘091230’ representa las 09 horas, 12 minutos y 30 segundos. La letra ‘Z’ indica que esa hora está expresada en UTC. Después, ‘_02’ identifica el número del paso o evidencia dentro del laboratorio. ‘docker’ describe el contenido del registro, mientras que ‘.script.log’ señala que se trata de un archivo de registro de una sesión de terminal.
En el proyecto se utiliza esta estructura para ordenar las evidencias y relacionarlas con los scripts correspondientes. Por tanto, el nombre permite conocer cuándo se generó el archivo, a qué paso pertenece y qué tipo de información contiene sin necesidad de abrirlo.
### 11. ¿Para qué sirve ‘.gitattributes’ y qué error evita?
‘.gitattributes’ permite implementar reglas en el trato de Git sobre determinados tipos de archivos. En este caso se ha empleado para normalizar los finales de línea de los scripts y documentos. 
Esto es necesario porque Windows y Linux utilizan habitualmente convenciones diferentes. Windows suele emplear CRLF, mientras que Linux utiliza LF. Aunque esta diferencia no siempre es visible al abrir un archivo, puede provocar problemas cuando intentamos ejecutar scripts creados o modificados desde Windows en un entorno Linux.
Ej.: Un script Bash con finales de línea incorrectos puede producir errores relacionados con caracteres inesperados o con la interpretación de su primera línea. Al configurar ‘.gitattributes’ se indica a Git que mantenga los finales de línea adecuados para nuestros archivos ‘.sh’, ‘.sql’ y ‘.md’. De esta forma se consigue que el repositorio sea más coherente y se reducen los problemas al trabajar desde diferentes sistemas operativos.
Por tanto, ‘.gitattributes’ ayuda a mantener la compatibilidad de los archivos y evita errores que pueden aparecer por diferencias entre Windows y Linux.

### 12. ¿Por qué en este Pull Request elegimos ‘Create a merge commit’ en lugar de ‘Squash and merge’?
Durante el laboratorio se han realizado commits separados para registrar las diferentes etapas de la instalación y configuración de Oracle. Esta organización permite identificar cuándo se ha incorporado cada script, cuándo se han creado las migraciones y cuándo se han verificado las herramientas.
Si se utilizara ‘Squash and merge’, Git reuniría los commits de nuestra rama en uno solo al integrarla en ‘main’. Aunque el estado final de los archivos se conservaría, se perdería la separación entre los diferentes pasos en el historial principal.
En cambio, ‘Create a merge commit’ permite incorporar la rama conservando sus commits individuales y creando un commit adicional que registra la integración. Esto es especialmente útil en este laboratorio para la constatación de cómo ha sido realizado el trabajo y no solamente observar su resultado final. Es por este motivo que se ha utilizado ‘Create a merge commit’ cuando la Pull Request haya recibido la revisión correspondiente.
La ventaja principal es poder conservar la trazabilidad del proceso, facilitando de manera comprensible la evolución del entorno Oracle y la localización de posibles errores en una fase concreta.

## 8.1.3. Seguridad
### 13. Describe las cuatro capas de la estrategia de contraseñas (Parte D) y qué pasaría si te saltas la primera.
Durante la práctica se sigue una estrategia de seguridad formada por cuatro medidas complementarias para evitar que las contraseñas terminaran accidentalmente en Git.
La primera medida consiste en guardar los valores reales en un archivo privado, ‘config/.env’, y mantenerlo fuera del control de versiones mediante ‘.gitignore’.
La segunda consiste en la creación de una plantilla llamada ‘config/.env.example’. Esta plantilla contiene los nombres de las variables que necesita el proyecto, pero utiliza valores de ejemplo en lugar de contraseñas reales.

La tercera medida es comprobar que Git ignora correctamente el archivo privado. Para ello se ejecuta ‘git check-ignore -v config/.env’, que permitió verificar qué regla de ‘.gitignore’ estaba protegiéndolo.
La cuarta consiste en no escribir las contraseñas reales directamente en los comandos de la terminal. En su lugar, son cargadas las variables desde ‘config/.env’ y se utilizan cuando las necesitan los scripts.
Si la primera medida fuera olvidada, y las contraseñas fueran guardadas en archivos versionados, se podrían incorporar accidentalmente a un commit. Esto sería una vulnerabilidad porque Git conserva el historial de modificaciones. Aunque después fuera eliminada la contraseña del archivo, podría seguir apareciendo en un commit anterior. Por tanto, las cuatro medidas actúan conjuntamente para mantener separados el código del proyecto y sus credenciales privadas.

### 14. ¿Por qué no escribimos la contraseña directamente en el comando ‘docker run’, aunque el script no se suba a Git?
No deben ser escritas las contraseñas directamente en los comandos porque pueden quedar registradas en lugares que no siempre se tienen en cuenta. Ej.: Bash puede guardar los comandos que escribimos en su historial. Si fuera introducida una contraseña en un comando ‘docker run’, esta podría permanecer almacenada en texto claro.
Dependiendo de cómo se ejecuten los procesos, determinados argumentos o datos de configuración pueden resultar accesibles mediante herramientas de administración o diagnóstico. En el laboratorio se cumple la regla de evitar escribir la contraseña real en los scripts. En su lugar es almacenada en ‘config/.env’ y cargada mediante variables como ‘ORACLE_PWD’. Después se emplean esas variables al ejecutar los comandos que necesitaban autenticarse. Esto reduce el riesgo de introducir accidentalmente las credenciales en el historial de comandos o en los archivos del repositorio.
Sin embargo, también es importante recordar que las variables de entorno no son una solución de seguridad absoluta. Docker puede conservar información de configuración que incluya valores sensibles, por lo que sigue siendo necesario proteger el acceso al equipo y al motor Docker.
La idea fundamental es que una contraseña se gestione como información privada y no como una parte más del código o de los comandos que se escriben.

### 15. Si descubres tu contraseña en un commit ya publicado, ¿basta con borrarla en un commit nuevo? ¿Qué debes hacer?
No sería suficiente con eliminar la contraseña del archivo y crear otro commit, porque Git conserva el historial de versiones anteriores. Aunque el archivo actual ya no contuviera la contraseña, cualquier persona con acceso al historial podría llegar a encontrarla en el commit donde apareció originalmente. Por eso, si descubriéramos una contraseña publicada, deberíamos considerarla como una vulnerabilidad.

El primer paso es la sustitución por una contraseña nueva para que el valor expuesto dejara de permitir el acceso al sistema. Después, se debe revisar el alcance del problema, comprobar si esa credencial se ha utilizado en otros servicios y coordinar la eliminación de la información sensible del historial del repositorio. También es necesario comunicar lo ocurrido a las personas responsables del proyecto, especialmente si el commit ya se hubiera compartido con otros usuarios.
En el laboratorio, antes de publicar la rama, se comprobaban los archivos que registrados de Git y su historial para comprobar que no hemos incluido credenciales privadas. Es por esto que eliminar una contraseña de la versión actual no significa que haya desaparecido del historial. La medida básica es cambiar la credencial comprometida y corregir la exposición.

## 8.1.4. Oracle y herramientas
### 16. ¿Por qué no usamos ‘SPOOL’ ni ‘@archivo.sql’ con ‘sqlplus’ dentro del contenedor, y qué hicimos en su lugar?
Durante una parte del laboratorio se emplea SQL*Plus dentro del contenedor de Oracle, mientras que nuestros archivos de trabajo estaban guardados en el repositorio de Ubuntu. Esto implicaba que SQL*Plus y nuestros scripts no estuvieran trabajando directamente sobre el mismo sistema de archivos.
Si se hubiera empleado ‘SPOOL’ para generar un archivo, SQL*Plus lo habría guardado dentro del contenedor, no directamente en la carpeta de evidencias de nuestro repositorio. Algo parecido ocurriría con ‘@archivo.sql’, donde SQL*Plus intentaría buscar ese archivo dentro del contenedor. Como nuestros scripts estaban en Ubuntu, no podría ser localizado mediante una ruta que solo existiera en el equipo anfitrión.
Como solución al problema, se usan dos mecanismos de Bash. El primero, la redirección de entrada ‘<’; esta permite enviar el contenido de un archivo SQL desde Ubuntu hacia SQL*Plus. El segundo mecanismo fue ‘tee’, permitiendo mostrar la salida de un comando en la terminal y, al mismo tiempo, guardarla en un archivo de registro.
De esta forma se pudo ejecutar SQL*Plus dentro del contenedor y mantener los scripts y las evidencias en el repositorio de Ubuntu. Más adelante, cuando se instaló SQLcl directamente en Ubuntu, sí se pudo utilizar ‘SPOOL’ para guardar resultados en nuestro propio sistema de archivos.
Este ejercicio ayuda a comprender la diferencia entre ejecutar una herramienta dentro de un contenedor y ejecutarla directamente en el equipo anfitrión.

### 17. ¿Qué hace ‘WHENEVER SQLERROR EXIT SQL.SQLCODE’ al inicio de V000 y V001, y qué pasaría sin esa línea?
Esta instrucción indica a SQL*Plus que debe detener la ejecución cuando encuentre un error SQL o PL/SQL y devolver un código de salida relacionado con ese error. En el laboratorio es utilizada al principio de las migraciones V000 y V001, que se encargaron de preparar los cinco entornos de negocio y sus correspondientes tablas.
Su importancia está en que una migración contiene varias instrucciones que deben ser ejecutadas correctamente para obtener la estructura prevista. Si alguna de ellas falla, es necesario detectarlo y evitar que el proceso continúe como si todo hubiera funcionado.
Sin ‘WHENEVER SQLERROR EXIT SQL.SQLCODE’, SQL*Plus podría mostrar un error y seguir ejecutando otras sentencias. Esto haría muy difícil conocer si se completó con éxito la migración o si dejó la base de datos en un estado parcialmente configurado.
También se tendrá en cuenta que detener una migración no significa deshacer automáticamente todo lo ejecutado anteriormente.
En Oracle, muchas instrucciones de definición de datos, como ‘CREATE TABLE’, realizan confirmaciones implícitas. Por eso, si se produce un error después de la ejecución de algunas de ellas, es posible que esos cambios ya se hayan aplicado.
Por consecuente, esta instrucción mejora la detección de errores y permite identificar que una migración ha fallado, aunque no garantiza que todos los cambios anteriores se reviertan.

### 18. ¿Qué es una migración y por qué V000 y V001 no se deben editar una vez aplicadas?
Migración: archivo que contiene instrucciones destinadas a modificar la estructura de una base de datos de manera ordenada y controlada. Su finalidad es que los cambios puedan documentarse, reproducirse y mantenerse bajo control de versiones.
En el laboratorio son utilizadas dos migraciones principales. La primera, ‘V000__setup_entornos_negocio.sql’, creó los tablespaces y los usuarios correspondientes a los cinco entornos de negocio. La segunda, ‘V001__create_esquemas_negocio.sql’, creó las tablas de esos entornos. Al finalizar, comprobamos que teníamos cinco esquemas con un total de catorce tablas.
No deberían ser modificadas estas migraciones después de aplicarlas porque sus archivos dejarían de representar fielmente las instrucciones utilizadas para construir la base de datos. Esto provocaría una diferencia entre el historial documentado y el estado real del entorno.
En caso de ser necesaria la introducción de cambios posteriores, lo adecuado es la creación de una nueva migración que describiera esas modificaciones sin alterar las anteriores. De esta manera, se podría seguir la evolución de la estructura de Oracle y conocer qué operaciones se realizaron en cada etapa.
Por tanto, las migraciones son una forma de llevar un historial ordenado de la estructura de la base de datos.

### 19. ¿Por qué en SQL Developer se usa el servicio ‘FREEPDB1’ y no ‘FREE’ ni un SID?
Oracle utiliza una arquitectura denominada multitenant. Esta permite que una base de datos contenedora, o CDB, albergue distintas bases de datos conectables, conocidas como PDB.

En nuestro entorno, ‘FREE’ es el servicio asociado al contenedor raíz de Oracle, mientras que ‘FREEPDB1’ es el servicio de la base conectable donde hemos preparado los objetos de trabajo del laboratorio. Esta diferencia es importante porque no se desea conectarse indiscriminadamente a cualquier parte de Oracle. Es necesario al acceso a la base que contiene nuestros usuarios, esquemas y tablas. Por eso, al configurar SQL Developer, se emplea ‘localhost’ como servidor, el puerto ‘1521’ y ‘FREEPDB1’ como nombre del servicio. 
También conviene distinguir entre un SID y un nombre de servicio. El SID identifica una instancia de Oracle, mientras que un nombre de servicio permite indicar el servicio de base de datos al que uno se quiere conectar.
Durante el laboratorio se ejecutó una consulta que mostraba que nuestra instancia se llamaba ‘FREE’. Sin embargo, eso no significa que deba ser utilizado tal nombre para acceder a los esquemas de negocio que están dentro de ‘FREEPDB1’.
La idea principal es que la instancia ejecuta Oracle, mientras que la PDB es el entorno donde se han creado y administrado nuestros datos. Esta distinción ayuda a evitar errores al conectarnos y realizar operaciones administrativas.

### 20. ¿Qué aporta SQLcl frente a SQL*Plus, y por qué un DBA debe dominar ambas?
SQL*Plus: herramienta tradicional de Oracle que permite conectarse a una base de datos y ejecutar instrucciones SQL y PL/SQL desde una terminal. Es especialmente útil para tareas de administración, automatización y ejecución de scripts, y continúa estando presente en numerosos entornos Oracle.
SQLcl: herramienta más moderna que ofrece funciones adicionales, como autocompletado, historial de comandos, mejoras en los formatos de salida y otras utilidades que facilitan el trabajo con SQL.
Durante el laboratorio es utilizado SQL*Plus dentro del contenedor para comprobar el funcionamiento de Oracle y ejecutar scripts de configuración. Posteriormente se instala SQLcl en Ubuntu, se verifica que funciona y se realiza una sesión en la que se emplea ‘SPOOL’ para guardar los resultados.
La diferencia principal es que SQL*Plus ofrece una herramienta tradicional, sencilla y ampliamente utilizada, mientras que SQLcl proporciona funciones que hacen más cómodo el trabajo diario.
Un administrador de bases de datos debe dominar ambas porque puede encontrarse con entornos donde solo esté disponible SQL*Plus y con otros donde SQLcl permita trabajar de manera más eficiente. Además, conocer las dos herramientas permite entender mejor cómo administrar Oracle sin depender exclusivamente de programas gráficos como SQL Developer.

## 8.1.5. Entorno de trabajo
### 21. ¿Por qué el curso pasa de Git Bash a Ubuntu en WSL 2? Da al menos dos problemas concretos de Git Bash que desaparecen en Ubuntu.
En los laboratorios anteriores se usa Git Bash porque era una herramienta suficiente para trabajar con Git desde Windows. Sin embargo, al comenzar este laboratorio era necesario el manejo de herramientas de administración de sistemas, Docker y Oracle, cuyo funcionamiento está muy relacionado con Linux.
Git Bash proporciona una emulación de Bash y de determinadas utilidades de Unix, pero no constituye por sí mismo un sistema Linux completo. Uno de sus problemas es la conversión de rutas; determinadas rutas de estilo Linux pueden transformarse en rutas de Windows al ejecutar comandos, lo que puede causar problemas con argumentos de Docker. Otro problema aparece al utilizar contenedores interactivos mediante ‘docker run -it’, porque Git Bash puede presentar errores relacionados con la terminal y necesitar soluciones adicionales como ‘winpty’.
Además, Git Bash no incluye de forma nativa todas las herramientas habituales de administración de Linux, como ‘free’, ‘ss’ o ‘htop’.
Ubuntu en WSL 2 permite el trabajo con un entorno Linux real dentro de Windows, utilizando sus rutas, permisos, herramientas y gestor de paquetes. Esto facilita el uso de Docker Desktop, que puede integrarse con WSL 2 para poder trabajar desde Ubuntu.
Por tanto, pasar a Ubuntu permite la practica en un entorno mucho más parecido al que se utiliza en servidores y proyectos profesionales, reduciendo los problemas que aparecen al depender de una emulación de Bash en Windows.

### 22. ¿Por qué clonamos el repositorio en ‘~/oracle-database-lab’ y no trabajamos sobre la carpeta de Windows (‘/mnt/c/...’)? ¿Y por qué recomendamos Bash frente a Zsh para los scripts del curso?
Se clona el repositorio dentro del sistema de archivos de Ubuntu porque es el entorno desde el que se ejecutan nuestros scripts, se administra Docker y se trabaja con Oracle.
Aunque WSL 2 permite acceder a los archivos de Windows mediante rutas como ‘/mnt/c/...’, trabajar directamente sobre ellas puede introducir diferencias relacionadas con los permisos de los archivos, el tratamiento de determinadas operaciones y el rendimiento.
En cambio, con ‘~/oracle-database-lab’, el repositorio queda dentro del sistema de archivos de Linux y podemos trabajar con su comportamiento habitual.
Esto resulta útil cuando se ejecutan scripts Bash, se utiliza Git, son creados directorios o se modifican archivos que deben respetar los permisos y convenciones de Linux.
También es recomendable el uso de Bash porque todos los scripts del laboratorio están preparados para ese intérprete. De hecho, muchos comienzan con la instrucción ‘#!/usr/bin/env bash’, que indica que deben ejecutarse utilizando Bash.
Aunque Zsh es otra shell muy completa, existen diferencias de sintaxis y comportamiento entre ambas que pueden provocar resultados distintos si determinadas instrucciones son ejecutadas directamente en una sesión interactiva.

Al utilizar Bash se mantiene un entorno homogéneo. De esta forma se puede conseguir que el repositorio, en compañía a los procedimientos, sean más fáciles de reproducir en otros entornos Linux, sin tener que introducir adaptaciones innecesarias.
