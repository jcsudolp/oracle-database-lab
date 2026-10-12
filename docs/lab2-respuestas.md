<div align="center">

<img src="../images/banner-p1-lab2.png" alt="Portada de Laboratorio 2 de Práctica 1. GitHub Team Workflow" width="100%">

### Bases de Datos - Ingeniería Informática

**Curso académico 2026/2027 · Práctica I · Laboratorio II**

!\[Documentación](https://img.shields.io/badge/Documento-Preguntas\_de\_comprobaci%C3%B3n-17365D)
!\[GitHub](https://img.shields.io/badge/GitHub-Team\_Workflow-24292F?logo=github\&logoColor=white)
!\[Formato](https://img.shields.io/badge/Formato-Markdown-496E8A?logo=markdown\&logoColor=white)

*Issues · Branches · Commits · Pull Requests · Code Review*

</div>

## 

## Preguntas de comprobación



**1.¿Por qué un Issue sin criterios de aceptación es un problema, aunque la descripción general parezca clara?**

<details>
<summary>Leer respuesta</summary>

Un Issue puede describir una necesidad de forma comprensible y, aun así, dejar dudas sobre qué se considera terminado. <sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

\---

**2. Explica la diferencia entre "Refs #N" y "Closes #N" en un mensaje de commit o en la descripción de un Pull Request.**

<details>
<summary>Leer respuesta</summary>

Refs #N es una referencia cruzada: relaciona el texto con el Issue N, pero no solicita cerrarlo. Closes #N emplea una palabra clave \[...]<sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

\---

**3. ¿Qué ocurre exactamente si intentas hacer git push directamente sobre una branch main protegida? ¿Es un error tuyo o un fallo del sistema?**

<details>
<summary>Leer respuesta</summary>

Si main está protegida con una regla aplicable que obliga a pasar por un PR y quien hace push no tiene permiso de excepción, el servidor remoto rechaza la actualización. <sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

\---

**4. Un compañero te dice: "he aprobado el PR sin mirar los archivos, total ya me fío". ¿Qué riesgo tiene esa forma de revisar?**

<details>
<summary>Leer respuesta</summary>

La confianza en la persona que propone el cambio no sustituye la revisión de su contenido. Aprobar sin abrir Files changed puede dejar pasar un error lógico \[...]<sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

\---

**5. Si el reviewer pide un cambio y tú ya habías hecho push de tu branch, ¿tienes que abrir un Pull Request nuevo? Explica qué ocurre técnicamente con el PR existente cuando haces un nuevo commit.**

<details>
<summary>Leer respuesta</summary>

No se debe crear otro Pull Request si la corrección pertenece a la misma tarea. <sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

\---

**6. Describe con tus palabras la diferencia entre Merge commit, Squash and merge y Rebase and merge. ¿Cuál usarías para una branch con commits "wip", "fix", "fix2", "ok ya"?**

<details>
<summary>Leer respuesta</summary>

Merge commit incorpora la rama conservando los commits originales y generando un commit de fusión que conecta las dos historias. <sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

\---

**7. ¿Por qué borrar una branch después del merge no elimina el trabajo realizado en ella?**

<details>
<summary>Leer respuesta</summary>

Una rama es una referencia que señala un commit; eliminar su nombre no borra automáticamente las modificaciones que ya están integradas en otro lugar. <sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

\---

**8. ¿Qué información debería contener siempre la descripción de un Pull Request, como mínimo?**

<details>
<summary>Leer respuesta abreviada</summary>

Como mínimo, un PR debe explicar qué pretende conseguir y por qué (Summary), qué archivos o comportamientos se han modificado (Changes), cómo se ha comprobado que funcionan (Testing) y qué Issue o tarea resuelve (Related Issue). <sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

\---

**9. Un reviewer escribe solo "esto está mal" como comentario. ¿Qué le falta a ese comentario para ser útil? Reescríbelo tú con un ejemplo inventado.**

<details>
<summary>Leer respuesta abreviada</summary>

Comentar “esto está mal” no identifica el defecto, ni dónde se halla, ni cómo podría ser corregido. <sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

\---

**10. ¿Qué diferencia hay entre que main esté protegida y que simplemente el equipo "se ponga de acuerdo" en no hacer push directo?**

<details>
<summary>Leer respuesta abreviada</summary>

El acuerdo verbal es una convención del equipo que depende de que todos la recuerden y respeten <sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

\---

**11. Explica con un ejemplo propio la diferencia entre un comentario issue: (blocking) y uno nitpick: (if-minor) en formato Conventional Comments.**

<details>
<summary>Leer respuesta abreviada</summary>

issue: (blocking) expresa que existe un problema que debe resolverse antes de aceptar el cambio, mientras que nitpick: (if-minor) <sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

\---

**12. Si tu próximo commit es feat!: cambia la firma de la función principal de la API, ¿qué tipo de versión SemVer se dispara y por qué?**

<details>
<summary>Leer respuesta abreviada</summary>

En Conventional Commits, el signo ! en feat! comunica que el commit introduce un breaking change, es decir, una modificación incompatible para quienes usan la interfaz anterior. <sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

[↑ Volver al índice](#índice)

\---

**13. ¿Por qué abrir un Draft PR desde el primer commit estructural puede ahorrar tiempo al equipo, aunque parezca más lento para el autor individual?**

<details>
<summary>Leer respuesta abreviada</summary>

Un Draft Pull Request deja visible una propuesta que todavía no está lista para fusionarse. <sub>La versión completa de la respuesta se halla en el PDF adjunto.</sub>

</details>

[↑ Volver al índice](#índice)

<div align="center">

*Laboratorio 2 · GitHub Team Workflow · Documentación académica*

</div>



