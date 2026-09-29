---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - "Conversación de definición del 2026-09-29 (no hay PRD, arquitectura ni UX para esta iniciativa)"
  - "exactamente-backend/src/db/schema.ts (modelo verificado)"
  - "exactamente-frontend/src/features/home/components/subjects/FacultySelector.tsx (PR #101)"
---

# Exactamente - Epic Breakdown

## Overview

Este documento desglosa en épicas e historias la iniciativa multi-facultad de Exactamente: sumar las facultades de Ciencias Humanas, Ciencias Económicas y Ciencias Veterinarias de la UNICEN a Exactas (FACET), que hoy es la única.

## Requirements Inventory

### Functional Requirements

FR1: La primera vez que un usuario entra al sitio sin facultad elegida, un onboarding le pide que elija una facultad antes de usar la home.
FR2: El onboarding no aparece si el usuario ya tiene una facultad guardada ni si llega con un link que ya define la facultad (`?university=…` o el link de una materia).
FR3: La facultad elegida se guarda en el navegador y se mantiene en visitas posteriores.
FR4: El hero de la home muestra la facultad actual: nombre, imagen y descripción.
FR5: Desde el hero, el usuario puede cambiar de facultad.
FR6: El hero muestra los links rápidos de la facultad actual agrupados por sección (por ejemplo Ingreso o Grupos de estudio).
FR7: Todo el sitio aplica el color de la facultad actual a sus gradientes y acentos: Exactas amarillo, Económicas morado, Veterinarias verde y Humanas celeste.
FR8: Los filtros de materias de la home (carrera, plan, año) muestran solo opciones de la facultad actual.
FR9: El formulario de subida de recursos permite elegir facultad; arranca con la facultad actual y trae las carreras y materias de la que se elija.
FR10: Un administrador puede editar la imagen y la descripción de cada facultad desde el panel admin.
FR11: Un administrador puede crear, editar y eliminar los links rápidos de cada facultad desde el panel admin, y asignar cada link a una sección (por ejemplo Ingreso o Grupos de estudio).
FR11b: Un administrador puede crear, renombrar y eliminar las secciones de links de cada facultad. Cada facultad tiene sus propias secciones. No se puede borrar una sección que todavía tiene links.
FR12: El catálogo tiene cargadas las carreras, planes y materias de Humanas, Económicas y Veterinarias.
FR13: Una materia que comparten varias carreras de una facultad existe una sola vez y sus recursos se ven desde todas esas carreras.

### NonFunctional Requirements

NFR1: El contenido de la home se renderiza igual detrás del onboarding: el modal no lo reemplaza, así los buscadores lo siguen indexando.
NFR2: Cambiar de facultad o de tema no requiere recargar la página.
NFR3: Todas las variantes de color cumplen el contraste WCAG AA en modo claro y oscuro.
NFR4: Cambiar un link rápido, una imagen o una descripción no requiere deploy.
NFR5: Los tipos de la API en los clientes se generan desde `openapi.json`; nadie los escribe a mano. `check:openapi` y `check:api` quedan en verde.
NFR6: El onboarding y el cambio de facultad se pueden usar con teclado y lector de pantalla.

### Additional Requirements

- El modelo `University → Faculty → Career → CareerPlan` ya existe. `subjects` pertenece a la facultad y `career_subjects` es una relación muchos a muchos con `planId`, `year` y `quadmester`. FR13 se cumple cargando bien los datos, sin cambiar el esquema.
- `faculties` hoy tiene solo `name`, `shortName` y `slug`. Hace falta agregarle `imageUrl` y `description` y crear las tablas `faculty_link_sections` (pertenece a la facultad) y `faculty_links` (pertenece a una sección). Las imágenes van a R2. Como no hay reordenamiento, secciones y links se muestran en orden de creación.
- Toda migración que llega a `main` del backend se aplica sola en producción (el Dockerfile corre `db:migrate`). Las migraciones tienen que ser aditivas y sin pérdida de datos.
- El color por facultad es una decisión de diseño: vive en el frontend como un mapa `slug → paleta`, no en la base.
- En `master` del frontend ya están `FacultySelector` y `storedFaculty` (localStorage `exactamente:selectedFaculty:v1`), que llegaron con el PR #101. El onboarding y el hero se construyen sobre eso, sin duplicarlo.
- Orden de merge entre repos: primero el backend y después los clientes.
- Fuera de alcance: correlativas por plan (`subject_prerequisites` no tiene `planId`, pero la vista de correlativas no está montada) y los cambios en `exactamente-mcp`.

### UX Design Requirements

UX-DR1: Diseño en Pencil del onboarding de elección de facultad, en desktop y mobile.
UX-DR2: Diseño en Pencil del hero de facultad (facultad actual, cambiar, imagen, título, descripción, links rápidos), en desktop y mobile.
UX-DR3: Paleta de las 4 facultades para gradientes y acentos, en modo claro y oscuro, siguiendo la estética actual del sitio.

### FR Coverage Map

FR1: Épica 1 - Onboarding de facultad
FR2: Épica 1 - Excepciones del onboarding
FR3: Épica 1 - Facultad guardada
FR4: Épica 1 - Hero con la facultad actual
FR5: Épica 1 - Cambiar de facultad desde el hero
FR6: Épica 1 - Links rápidos por sección en el hero
FR7: Épica 1 - Tema de color por facultad
FR8: Épica 1 - Filtros por facultad actual
FR9: Épica 1 - Upload con elección de facultad
FR10: Épica 1 - Admin: imagen y descripción
FR11: Épica 1 - Admin: links
FR11b: Épica 1 - Admin: secciones de links
FR12: Épica 2 - Catálogo de las 3 facultades
FR13: Épica 2 - Materias compartidas cargadas una sola vez

## Epic List

### Epic 1: Exactamente multi-facultad
El estudiante elige su facultad la primera vez y después la ve siempre en el hero, con su imagen, su descripción, sus links por sección y su color en todo el sitio. Puede cambiarla cuando quiera, y los filtros y el upload trabajan sobre la facultad actual. Los admins editan la identidad y los links sin deploy.
**FRs covered:** FR1, FR2, FR3, FR4, FR5, FR6, FR7, FR8, FR9, FR10, FR11, FR11b

### Epic 2: Catálogo de Humanas, Económicas y Veterinarias
Los estudiantes de Humanas, Económicas y Veterinarias encuentran sus carreras, planes y materias. Las materias que comparten varias carreras se cargan una sola vez.
**FRs covered:** FR12, FR13

## Epic 1: Exactamente multi-facultad
github: exactamente-ar/exactamente-workspace#8

El estudiante elige su facultad la primera vez y después la ve siempre en el hero, con su imagen, su descripción, sus links por sección y su color en todo el sitio. Puede cambiarla cuando quiera, y los filtros y el upload trabajan sobre la facultad actual. Los admins editan la identidad y los links sin deploy.

### Story 1.1: Tema de color por facultad
github: exactamente-ar/exactamente-frontend#108

**Repo:** exactamente-frontend
**Size:** M

As a estudiante,
I want que el sitio use el color de mi facultad,
So that sienta que la página es de mi facultad y no la de otra.

**Acceptance Criteria:**

**Given** existe un mapa `slug de facultad → paleta` en el frontend con Exactas (amarillo), Económicas (morado), Veterinarias (verde) y Humanas (celeste)
**When** la facultad actual es cualquiera de las 4
**Then** los gradientes y acentos de todo el sitio usan la paleta de esa facultad mediante tokens CSS globales, sin colores fijos por componente (FR7)
**And** cambiar la facultad actual cambia el tema sin recargar la página (NFR2)

**Given** la facultad actual no tiene paleta en el mapa (por ejemplo, una facultad recién creada)
**When** se renderiza el sitio
**Then** se usa la paleta de Exactas como default y no se rompe nada

**Given** las 4 paletas
**When** se revisa el contraste en modo claro y oscuro
**Then** el texto sobre gradientes y acentos cumple WCAG AA (NFR3)
**And** hay tests unitarios del mapa y de la resolución del default

### Story 1.2: Diseño del onboarding y el hero de facultad en Pencil
github: exactamente-ar/exactamente-frontend#109

**Repo:** exactamente-frontend
**Size:** M
**Depends on:** 1.1

As a desarrollador del equipo,
I want un diseño aprobado del onboarding y del hero de facultad,
So that implementarlos no dependa de decisiones de layout tomadas sobre la marcha.

**Acceptance Criteria:**

**Given** la estética actual del sitio y las paletas de la historia 1.1
**When** se diseña en Pencil
**Then** existen pantallas del onboarding de elección de facultad en desktop y mobile (UX-DR1)
**And** existen pantallas del hero con facultad actual, botón para cambiarla, imagen, título, descripción y links agrupados por sección, en desktop y mobile (UX-DR2)
**And** el hero se ve al menos con 2 de las 4 paletas aplicadas (UX-DR3)

**Given** el hero puede tener de 0 a muchas secciones de links
**When** se diseña
**Then** están resueltos los casos sin links, sin imagen y con muchas secciones

**Given** el diseño terminado
**When** se entrega
**Then** el archivo `.pen` queda versionado en el repo y el usuario lo aprueba antes de empezar 1.7 y 1.8

### Story 1.3: Imagen y descripción de la facultad en la API
github: exactamente-ar/exactamente-backend#21

**Repo:** exactamente-backend
**Size:** S

As a estudiante,
I want que la API devuelva la imagen y la descripción de cada facultad,
So that el sitio pueda mostrarme la identidad de mi facultad.

**Acceptance Criteria:**

**Given** la tabla `faculties`
**When** se aplica la migración
**Then** tiene las columnas nullable `image_url` y `description`, y la migración es aditiva y sin pérdida de datos (se aplica sola en producción)

**Given** un administrador autenticado
**When** sube una imagen para una facultad por el endpoint admin
**Then** la imagen se guarda en R2 y `image_url` queda apuntando a ella
**And** se rechazan archivos que no sean imagen o que superen el límite de tamaño definido

**Given** un administrador autenticado
**When** actualiza la descripción de una facultad
**Then** el cambio se persiste sin deploy (NFR4)

**Given** un cliente público
**When** pide `GET /faculties`
**Then** cada facultad incluye `imageUrl` y `description`
**And** los schemas Zod están actualizados, `openapi.json` está regenerado y `check:openapi` pasa (NFR5)
**And** hay tests de los endpoints público y admin

### Story 1.4: Secciones y links de la facultad en la API
github: exactamente-ar/exactamente-backend#22

**Repo:** exactamente-backend
**Size:** M

As a estudiante,
I want que la API devuelva los links rápidos de mi facultad agrupados por sección,
So that el sitio me los pueda mostrar ordenados por tema.

**Acceptance Criteria:**

**Given** la base de datos
**When** se aplica la migración
**Then** existe `faculty_link_sections` (id, facultyId, name, createdAt), que pertenece a una facultad
**And** existe `faculty_links` (id, sectionId, label, url, createdAt), que pertenece a una sección
**And** la migración es aditiva y sin pérdida de datos

**Given** un administrador autenticado
**When** usa los endpoints admin
**Then** puede crear, renombrar y eliminar secciones de una facultad (FR11b)
**And** puede crear, editar y eliminar links dentro de una sección (FR11)
**And** se rechaza un link cuya URL no es `http` ni `https`

**Given** una sección que todavía tiene links
**When** un administrador intenta eliminarla
**Then** la API responde con un error de conflicto y no borra nada

**Given** un cliente público
**When** pide los links de una facultad
**Then** recibe las secciones en orden de creación, cada una con sus links en orden de creación
**And** una facultad sin secciones devuelve una lista vacía, no un error
**And** los schemas Zod están actualizados, `openapi.json` está regenerado y `check:openapi` pasa (NFR5)
**And** hay tests de los endpoints público y admin

### Story 1.5: Admin: editar imagen y descripción de la facultad
github: exactamente-ar/exactamente-frontend-admin#12

**Repo:** exactamente-frontend-admin
**Size:** M
**Depends on:** 1.3

As a administrador,
I want editar la imagen y la descripción de cada facultad desde el panel,
So that pueda mantener la identidad de cada facultad sin pedir un deploy.

**Acceptance Criteria:**

**Given** los tipos regenerados con `pnpm gen:api` desde el contrato de la historia 1.3
**When** un administrador abre la edición de una facultad
**Then** ve la imagen y la descripción actuales, o un placeholder si no hay
**And** puede subir una imagen nueva y ver la vista previa antes de guardar
**And** puede editar la descripción y guardarla (FR10)

**Given** la subida falla (archivo inválido, demasiado grande o error de red)
**When** el administrador guarda
**Then** ve el mensaje de error de la API y la imagen anterior queda intacta
**And** `check:api` pasa

### Story 1.6: Admin: administrar secciones y links de la facultad
github: exactamente-ar/exactamente-frontend-admin#13

**Repo:** exactamente-frontend-admin
**Size:** M
**Depends on:** 1.4

As a administrador,
I want crear las secciones y los links rápidos de cada facultad desde el panel,
So that cada facultad muestre sus links de ingreso, grupos de estudio y demás sin deploy.

**Acceptance Criteria:**

**Given** los tipos regenerados con `pnpm gen:api` desde el contrato de la historia 1.4
**When** un administrador entra a los links de una facultad
**Then** ve las secciones con sus links, en orden de creación

**Given** esa pantalla
**When** el administrador opera
**Then** puede crear, renombrar y eliminar secciones (FR11b)
**And** puede crear, editar y eliminar links dentro de una sección, con label y URL (FR11)
**And** eliminar pide confirmación, como en el resto del panel

**Given** una sección que todavía tiene links
**When** el administrador intenta eliminarla
**Then** ve el error de la API que explica que primero tiene que eliminar o mover sus links
**And** `check:api` pasa

### Story 1.7: Onboarding de elección de facultad
github: exactamente-ar/exactamente-frontend#110

**Repo:** exactamente-frontend
**Size:** M
**Depends on:** 1.2

As a estudiante que entra por primera vez,
I want elegir mi facultad al llegar,
So that vea desde el principio las materias que me sirven y no las de otra facultad.

**Acceptance Criteria:**

**Given** un usuario sin facultad guardada que entra a la home sin parámetros de facultad
**When** carga la página
**Then** ve el onboarding del diseño aprobado en 1.2, con las facultades que devuelve la API (FR1)
**And** no puede usar la home hasta elegir una

**Given** el onboarding abierto
**When** el usuario elige una facultad
**Then** se guarda con `storedFaculty` (la clave de localStorage que ya existe), se cierra el onboarding y la home queda filtrada por esa facultad (FR3)
**And** en las visitas siguientes el onboarding no aparece

**Given** un usuario con facultad guardada, o que llega con `?university=…`, o que entra a la página de una materia
**When** carga la página
**Then** el onboarding no aparece (FR2)

**Given** el onboarding abierto
**When** se inspecciona el HTML servido
**Then** el contenido de la home está renderizado detrás del modal, no reemplazado por él (NFR1)

**Given** el onboarding abierto
**When** se navega con teclado o lector de pantalla
**Then** el foco queda atrapado en el modal, las opciones se pueden elegir con teclado y tienen nombre accesible (NFR6)
**And** hay tests de la lógica que decide si se muestra el onboarding

### Story 1.8: Hero de facultad
github: exactamente-ar/exactamente-frontend#111

**Repo:** exactamente-frontend
**Size:** M
**Depends on:** 1.1, 1.2, 1.3, 1.4

As a estudiante,
I want ver mi facultad actual en el inicio, con sus links, y poder cambiarla,
So that tenga a mano lo de mi facultad y pueda pasar a otra si curso en más de una.

**Acceptance Criteria:**

**Given** los tipos regenerados con `pnpm gen:api` desde los contratos de 1.3 y 1.4
**When** se carga la home
**Then** el hero muestra nombre, imagen y descripción de la facultad actual según el diseño de 1.2 (FR4)
**And** muestra los links agrupados por sección, que abren en una pestaña nueva (FR6)
**And** si no hay imagen, links o descripción, se ve el estado vacío diseñado y no un hueco roto

**Given** el hero
**When** el usuario cambia de facultad desde ahí
**Then** se actualizan el hero, el tema (1.1) y los filtros sin recargar la página (FR5, NFR2)
**And** los filtros de carrera, plan y año se reinician y muestran solo opciones de la nueva facultad (FR8)
**And** la elección se guarda con `storedFaculty`

**Given** el `FacultySelector` que hoy está sobre los filtros
**When** el hero ya ofrece cambiar de facultad
**Then** se quita ese selector y sus tests se adaptan o se mueven, sin perder cobertura

**Given** el cambio de facultad
**When** se usa con teclado o lector de pantalla
**Then** es operable y anuncia la facultad seleccionada (NFR6)
**And** `check:api` pasa

### Story 1.9: Upload con elección de facultad
github: exactamente-ar/exactamente-frontend#112

**Repo:** exactamente-frontend
**Size:** S

As a estudiante que sube un recurso,
I want elegir la facultad en el formulario de subida,
So that pueda subir recursos de materias de cualquier facultad.

**Acceptance Criteria:**

**Given** el formulario de upload
**When** se abre
**Then** tiene un campo Facultad antes de Carrera, preseleccionado con la facultad actual (FR9)
**And** las carreras disponibles son solo las de esa facultad

**Given** una facultad elegida
**When** el usuario cambia de facultad
**Then** se limpian carrera, plan y materia, y las carreras se cargan de la facultad nueva

**Given** un usuario sin sesión que empieza a completar el form
**When** va a iniciar sesión y vuelve (el borrador `exactamente_upload_draft`)
**Then** el borrador restaura también la facultad elegida
**And** hay tests de la cascada facultad → carrera → plan → materia

## Epic 2: Catálogo de Humanas, Económicas y Veterinarias
github: exactamente-ar/exactamente-workspace#9

Los estudiantes de Humanas, Económicas y Veterinarias encuentran sus carreras, planes y materias. Las materias que comparten varias carreras se cargan una sola vez.

> ⚠️ `scripts/seed.ts` borra `resources`, `career_subjects`, `subjects` y `subject_prerequisites` antes de volver a insertar, y tiene `facultyId: 'FACET'` escrito a mano. **Nunca se corre contra producción** para cargar facultades nuevas.

### Story 2.1: Importador aditivo de catálogo por facultad
github: exactamente-ar/exactamente-backend#23

**Repo:** exactamente-backend
**Size:** M

As a maintainer,
I want un script que cargue el catálogo de una facultad desde un archivo de datos sin tocar lo que ya existe,
So that pueda sumar facultades a producción sin riesgo de perder los recursos que subieron los usuarios.

**Acceptance Criteria:**

**Given** un archivo de datos por facultad con facultad, carreras, planes y materias, donde cada materia declara las carreras y planes a los que pertenece con su año y cuatrimestre
**When** se corre el script con ese archivo
**Then** crea o actualiza facultad, carreras, planes, materias y filas de `career_subjects` por ID estable
**And** nunca ejecuta un `DELETE` ni modifica filas de otras facultades
**And** correrlo dos veces con el mismo archivo no cambia nada la segunda vez (idempotente)

**Given** la opción `--dry-run`
**When** se corre el script
**Then** muestra cuántas filas crearía o actualizaría en cada tabla y no escribe nada en la base

**Given** un archivo con errores (materia que referencia una carrera o plan inexistente, IDs duplicados, año o cuatrimestre fuera de rango, campos obligatorios vacíos)
**When** se corre el script
**Then** se aborta antes de escribir, con la lista de errores y dónde están
**And** si falla la escritura a mitad, todo se hace dentro de una transacción y no queda nada a medias

**Given** una materia compartida por varias carreras (FR13)
**When** se define en el archivo
**Then** existe una sola vez y se asocia a todas sus carreras; el validador rechaza la misma materia repetida con dos IDs distintos dentro de la facultad (mismo título y año)

**Given** el formato del archivo
**When** alguien lo va a completar con IA desde el PDF de un plan de estudios
**Then** hay un documento con el formato, un ejemplo y el prompt sugerido para la extracción
**And** el `slug` de cada facultad coincide con las claves del mapa de paletas de la historia 1.1 (`humanas`, `economicas`, `veterinarias`)
**And** hay tests del validador y de la idempotencia

### Story 2.2: Catálogo de Ciencias Humanas
github: exactamente-ar/exactamente-backend#24

**Repo:** exactamente-backend
**Size:** M
**Depends on:** 2.1

As a estudiante de Humanas,
I want encontrar mis carreras y materias en Exactamente,
So that pueda buscar y subir recursos de mi facultad.

**Acceptance Criteria:**

**Given** los planes de estudio vigentes de las carreras de Humanas
**When** se arma el archivo de datos (con IA y revisado por una persona)
**Then** incluye todas las carreras con sus planes vigentes y todas sus materias con año y cuatrimestre (FR12)
**And** las materias compartidas entre carreras están una sola vez (FR13)
**And** el archivo pasa la validación del importador

**Given** el archivo validado
**When** un maintainer corre el importador en producción, primero con `--dry-run`
**Then** los conteos del dry-run coinciden con lo esperado y después la carga real deja la facultad visible en el sitio
**And** los recursos y materias de Exactas quedan intactos

### Story 2.3: Catálogo de Ciencias Económicas
github: exactamente-ar/exactamente-backend#25

**Repo:** exactamente-backend
**Size:** M
**Depends on:** 2.1

As a estudiante de Económicas,
I want encontrar mis carreras y materias en Exactamente,
So that pueda buscar y subir recursos de mi facultad.

**Acceptance Criteria:**

**Given** los planes de estudio vigentes de las carreras de Económicas
**When** se arma el archivo de datos (con IA y revisado por una persona)
**Then** incluye todas las carreras con sus planes vigentes y todas sus materias con año y cuatrimestre (FR12)
**And** las materias del tronco común (los primeros años que comparten las carreras) se definen una sola vez y se asocian a todas las carreras que las cursan (FR13)
**And** el archivo pasa la validación del importador

**Given** una materia del tronco común con recursos
**When** se navega desde cualquiera de las carreras que la comparten
**Then** se ven los mismos recursos

**Given** el archivo validado
**When** un maintainer corre el importador en producción, primero con `--dry-run`
**Then** los conteos del dry-run coinciden con lo esperado y después la carga real deja la facultad visible en el sitio
**And** los recursos y materias de las otras facultades quedan intactos

### Story 2.4: Catálogo de Ciencias Veterinarias
github: exactamente-ar/exactamente-backend#26

**Repo:** exactamente-backend
**Size:** M
**Depends on:** 2.1

As a estudiante de Veterinarias,
I want encontrar mis carreras y materias en Exactamente,
So that pueda buscar y subir recursos de mi facultad.

**Acceptance Criteria:**

**Given** los planes de estudio vigentes de las carreras de Veterinarias
**When** se arma el archivo de datos (con IA y revisado por una persona)
**Then** incluye todas las carreras con sus planes vigentes y todas sus materias con año y cuatrimestre (FR12)
**And** las materias compartidas entre carreras están una sola vez (FR13)
**And** el archivo pasa la validación del importador

**Given** el archivo validado
**When** un maintainer corre el importador en producción, primero con `--dry-run`
**Then** los conteos del dry-run coinciden con lo esperado y después la carga real deja la facultad visible en el sitio
**And** los recursos y materias de las otras facultades quedan intactos
