---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - _bmad-output/planning-artifacts/prds/prd-modo-estudio-2026-11-24/prd.md
  - _bmad-output/planning-artifacts/ux-modo-estudio.md
  - _bmad-output/planning-artifacts/architecture-modo-estudio.md
---

# Exactamente - Epic Breakdown — Modo Estudio (fase 1)

## Overview

Desglose de la fase 1 del Modo Estudio: prototipo local, solo `exactamente-frontend`, sin cambios
de backend, detrás del flag `PUBLIC_STUDY_MODE` (apagado por defecto). Cada story es un work unit
de un PR y un commit convencional. El spike (`juanpe44/modo-estudio`) es referencia: las stories
portan lo que la arquitectura marca como conservable y arrancan desde `master`.

## Requirements Inventory

### Functional Requirements

FR-1: Desde `/[id]/parciales|resumenes|finales` la Materia Activa es esa materia; arrancar requiere como máximo dos toques.
FR-2: En el Panel del Timer se puede elegir carrera y materia; sin contexto, play queda deshabilitado hasta elegir; solo materias de la carrera elegida; acceso a Métricas.
FR-3: Carrera preseleccionada: la del Perfil o, sin Perfil, la última elegida.
FR-4: Chip del Timer en el header en todas las páginas: reposo "Estudiar"; corriendo, mm:ss y modo; nunca dos representaciones visibles.
FR-5: Con el Visor abierto, el chip está en su barra superior y permite abrir el panel, arrancar, pausar, reanudar y terminar; al cerrar el Visor, el chip vuelve al header con el mismo estado.
FR-6: El timer sobrevive a navegación, recarga y pestaña cerrada; marcas de tiempo; una sola instancia entre pestañas; ninguna sesión se registra dos veces.
FR-7: Pausar, reanudar y terminar un Foco; saltar un Descanso; terminar antes registra lo corrido.
FR-8: Aviso de fin de Foco en el chip (y sonido/notificación si se activó) sin pausar, cerrar, abrir modales ni tapar contenido.
FR-9: Tiempo Extra visible ("+08:12"), suma a la sesión, se corta al terminar o arrancar Descanso; tope de 60 min cierra la sesión y queda editable.
FR-10: Descanso a demanda; opción de arranque automático (apagada) que elimina el Tiempo Extra.
FR-11: Registro de sesión con id estable, ids y nombres de materia/carrera, minutos sin pausas incluido Tiempo Extra; se registra al terminar, al arrancar Descanso o al alcanzar el tope; regla de pestaña cerrada; acreditada al día de inicio; confirmación con total del día.
FR-12: Editar minutos (1 al máximo registrado) o materia, y borrar; no se editan día ni hora; cambios inmediatos en métricas, metas y Racha.
FR-13: Meta Semanal en horas; avance en panel y métricas; semana lunes a domingo; vigencia hasta que cambie; semanas pasadas conservan su meta; sin meta se ofrece definirla.
FR-14: Meta por Materia: definir, cambiar, quitar; avance propio; no tienen que sumar la semanal.
FR-15: Total de la semana actual y diferencia con signo contra la semana anterior completa.
FR-16: Horas de la semana por materia junto a su Meta por Materia.
FR-17: Racha actual: días con al menos una sesión, en hora local.
FR-18: Historial estilo heatmap y lista de sesiones editable.
FR-19: Estado vacío de métricas que explica qué se va a ver y cómo arrancar.
FR-20: Preferencias: Foco (presets 25/50/60) y Descanso, arranque automático, sonido, notificación (pide permiso). Defaults 50/10/apagado/encendido/apagado.
FR-21: Persistencia local versionada, migrable al backend sin transformar significado.

### NonFunctional Requirements

NFR-1: No distraer: nada abre modales, anima ni suena sin pedido; bordes y gradientes al ~80 % de opacidad.
NFR-2: Robustez del timer en pestañas en segundo plano.
NFR-3: Privacidad: datos personales, sin rankings ni exposición.
NFR-4: Mobile: chip y panel funcionan en pantallas chicas (panel como sheet inferior).
NFR-5: Sin login en fase 1.
NFR-6: Chip y panel operables con teclado y lector de pantalla.

### Additional Requirements

- AR-1 (AD-11): el Modo Estudio está detrás de `PUBLIC_STUDY_MODE === 'true'`; con cualquier otro valor no se monta ninguna isla y `/estudio` responde 404. Previews y producción quedan apagados.
- AR-2 (AD-1..AD-3): modelo de timer con `runningSince` + `accumulatedMs`; cuatro eventos de registro; regla de pestaña cerrada con el mismo `tick`.
- AR-3 (AD-4..AD-6): modelos de sesión, metas con vigencia y claves `exactamente:<name>:vN` definidos en la arquitectura; las claves v1 del spike no se leen.
- AR-4 (AD-7, AD-8): un store singleton por página; sync entre pestañas por `storage`; un único motor de reloj montado en el chip del header.
- AR-5 (AD-10): contexto de materia como JSON `#study-context` emitido por `Layout.astro`.
- AR-6: TDD obligatorio (AGENTS.md del repo); `pnpm test`, `lint`, `typecheck` y `build` en verde.
- AR-7: sin dependencias nuevas; todo HTTP vía `api.ts`.

### UX Design Requirements

UX-DR1: Estados del chip (reposo, Foco, Tiempo Extra, pausa, Descanso) en desktop y mobile según UX §B.4 y colores de UX §A.2.
UX-DR2: Panel como popover debajo del chip (desktop) y sheet inferior (mobile); orden y acciones de UX §B.4.
UX-DR3: Configuración como vista dentro del panel, guardado inmediato.
UX-DR4: Toast de confirmación anclado al chip visible, `role="status"`, 6 s.
UX-DR5: Métricas en el orden de UX §B.9; edición de metas y sesiones en línea, sin modales.
UX-DR6: Piso de accesibilidad de UX §B.7 (nombre accesible del chip, región live solo para transiciones, foco y `Esc`).

### FR Coverage Map

| FR | Story |
|---|---|
| FR-1 | 1.5 |
| FR-2 | 1.4 |
| FR-3 | 1.4, 1.5 |
| FR-4 | 1.4 |
| FR-5 | 1.5 |
| FR-6 | 1.1, 1.3 |
| FR-7 | 1.1, 1.4 |
| FR-8 | 1.6 |
| FR-9 | 1.1, 1.4 |
| FR-10 | 1.1, 1.6 |
| FR-11 | 1.1, 1.2, 1.3, 1.6 |
| FR-12 | 1.2, 1.8 |
| FR-13 | 1.2, 1.4, 1.7 |
| FR-14 | 1.2, 1.7 |
| FR-15 | 1.7 |
| FR-16 | 1.7 |
| FR-17 | 1.7 |
| FR-18 | 1.7, 1.8 |
| FR-19 | 1.7 |
| FR-20 | 1.1, 1.6 |
| FR-21 | 1.2 |

## Epic List

1. **Epic 1: Modo Estudio local (fase 1)** — el estudiante mide su estudio por materia desde el header o el Visor, y ve su semana contra la anterior y sus metas. 8 stories, todas en `exactamente-frontend`.

## Epic 1: Modo Estudio local (fase 1)

Lucía arranca un Foco con dos toques desde la materia que está estudiando, sigue estudiando con el
PDF en pantalla completa, y el domingo sabe cuánto estudió y contra qué meta. Todo en su
navegador, detrás de un flag, sin backend.

Orden de implementación: 1.1 → 1.2 → 1.3 → 1.4 → (1.5, 1.6 en cualquier orden) → 1.7 → 1.8.

### Story 1.1: Dominio del timer con Tiempo Extra, pausas, tope y eventos de registro

**Repo:** exactamente-frontend
**Size:** M
**Commit:** `feat(study): add timer domain with overtime, pause accounting and overtime cap`

As a estudiante,
I want que el timer cuente el tiempo real que estudié, con pausas y tiempo extra,
So that cada sesión registre lo que de verdad pasó.

Alcance: `src/features/study/domain/timer.ts` y `domain/settings.ts` con sus tests (AD-1, AD-2,
AD-3, AD-6 para `StudySettings`). Funciones puras con `now` y `newId` inyectados. Sin UI ni
storage.

**Acceptance Criteria:**

**Given** un timer en `idle` con materia
**When** se ejecuta `start(now)`
**Then** el estado pasa a `focus` con `focusId` nuevo, `startedAt = now`, `runningSince = now` y `targetMs` desde `settings.focusMin`
**And** sin materia, `start` no cambia el estado (FR-2).

**Given** un Foco corriendo 10 min y pausado 5 min, y luego reanudado 3 min
**When** se calcula `elapsed`
**Then** vale 13 min: las pausas no suman (FR-7, FR-11).

**Given** un Foco con `targetMs` de 50 min
**When** `tick` corre con `elapsed` = 58 min y `autoStartBreak` apagado
**Then** el Foco sigue en `focus`, `overtime` = 8 min, `targetNotified = true`, y no se registra sesión (FR-8, FR-9).

**Given** un Foco en Tiempo Extra
**When** se ejecuta `startBreak` o `endFocus`
**Then** la transición devuelve una sesión con `minutes = round(elapsed / 60 000)`, `recordedMinutes` igual y `endReason` `break` o `manual`
**And** `startBreak` deja el estado en `break` con `targetMs` desde `breakMin`; `endFocus`, en `idle` con la misma materia (FR-7, FR-9, FR-10, FR-11).

**Given** un Foco corriendo cuyo `elapsed` llega a `targetMs + 60 min`
**When** corre `tick` (en vivo o al hidratar con `now` horas después)
**Then** se registra una sesión de `targetMs + 60` minutos con `endReason = 'cap'` y el estado pasa a `idle` (FR-9, FR-11, AD-3).

**Given** `autoStartBreak` activado
**When** `tick` alcanza `targetMs`
**Then** se registra una sesión de exactamente `targetMs` con `endReason = 'auto-break'` y arranca el Descanso: no hay Tiempo Extra (FR-10).

**Given** un Foco pausado hace 3 días
**When** corre `tick`
**Then** sigue pausado y no registra nada (AD-3).

**Given** un Foco que termina con `elapsed` < 30 s
**When** se ejecuta `endFocus`
**Then** no se registra sesión y la transición informa `too-short`.

**Given** un Descanso
**When** se ejecuta `skipBreak` o `tick` pasa su `targetMs`
**Then** el estado pasa a `idle` conservando la materia (FR-7, FR-10).

**Given** preferencias guardadas inválidas o vacías
**When** se normalizan
**Then** se obtienen los defaults Foco 50, Descanso 10, arranque automático apagado, sonido encendido, notificación apagada, con Foco acotado a 5–120 y Descanso a 1–30 (FR-20).

### Story 1.2: Sesiones, metas con vigencia y almacenamiento versionado

**Repo:** exactamente-frontend
**Size:** M
**Depends on:** 1.1
**Commit:** `feat(study): add session and goal models with versioned local storage`

As a estudiante,
I want que mis sesiones y metas se guarden en el navegador y se puedan corregir,
So that mis datos reflejen lo que estudié aunque cierre la pestaña.

Alcance: `domain/sessions.ts`, `domain/goals.ts`, `utils/studyStorage.ts` y tests (AD-4, AD-5,
AD-6).

**Acceptance Criteria:**

**Given** una lista de sesiones que ya contiene el id `X`
**When** se agrega otra sesión con id `X`
**Then** la lista no cambia (FR-6, FR-11)
**And** no existe ningún tope diario de minutos.

**Given** una sesión con `recordedMinutes = 58`
**When** se edita a 43, a 0 o a 70
**Then** 43 se acepta; 0 y 70 se rechazan (rango 1–58) y `startedAt` nunca cambia (FR-12).

**Given** una sesión
**When** se cambia su materia
**Then** se guardan juntos `subjectId`, `subjectName`, `careerId`, `careerName` y se actualiza `updatedAt` (FR-11, FR-12).

**Given** una Meta Semanal de 12 h desde el lunes 3/11 y un cambio a 10 h el miércoles 12/11
**When** se consulta la meta de la semana del 3/11 y de la del 10/11
**Then** devuelve 12 h y 10 h respectivamente; las semanas siguientes devuelven 10 h (FR-13).

**Given** una Meta por Materia quitada en la semana en curso
**When** se consulta esa semana y la anterior
**Then** la actual no tiene meta y la anterior conserva la suya (FR-14).

**Given** el almacenamiento
**When** se escriben sesiones, metas, preferencias, timer y última carrera
**Then** se usan las claves `exactamente:studySessions:v2`, `studyGoals:v1`, `studySettings:v2`, `studyTimer:v2`, `studyLastCareer:v1`, con envoltorio `{ version, ... }` en sesiones y metas (FR-21)
**And** datos corruptos, de forma vieja (v1 del spike) o con storage bloqueado se leen como "nada guardado" sin lanzar errores.

### Story 1.3: Store compartido con sincronización entre islas y pestañas

**Repo:** exactamente-frontend
**Size:** M
**Depends on:** 1.2
**Commit:** `feat(study): add shared study store with cross-tab sync`

As a estudiante,
I want un único timer aunque tenga varias pestañas abiertas,
So that pausar en una pause en todas y ninguna sesión se cuente dos veces.

Alcance: `store/studyStore.ts`, `hooks/useStudy.ts`, `hooks/useStudyEngine.ts` y tests (AD-7,
AD-8). Porta la arquitectura del store del spike con las acciones nuevas.

**Acceptance Criteria:**

**Given** dos stores creados sobre el mismo storage (dos pestañas simuladas)
**When** uno pausa el Foco
**Then** el otro, al recibir el evento `storage`, muestra el Foco pausado con el mismo tiempo (FR-6).

**Given** dos stores con el mismo Foco en Tiempo Extra
**When** ambos ejecutan `startBreak` casi a la vez
**Then** queda una sola sesión guardada y solo uno emite el evento de confirmación (FR-6, FR-11).

**Given** un timer guardado corriendo desde hace 2 h con Foco de 50 min
**When** el store hidrata
**Then** registra la sesión del tope (110 min) y queda en `idle` (FR-9, FR-11, AD-3).

**Given** el store
**When** se llaman `editSession`, `deleteSession`, `setWeeklyGoal` o `setSubjectGoal`
**Then** el snapshot y el storage se actualizan y los suscriptores se notifican de inmediato (FR-12, FR-13, FR-14).

**Given** `useStudy`
**When** el timer está en Foco
**Then** expone `remainingMs`, `overtimeMs`, `todayMinutes`, `weekMinutes` y la Meta Semanal vigente.

**Given** `useStudyEngine` montado y la pestaña oculta
**When** vuelve a ser visible
**Then** corre `tick` y el tiempo mostrado es el correcto (NFR-2).

### Story 1.4: Chip del Timer en el header y Panel, detrás del flag

**Repo:** exactamente-frontend
**Size:** L
**Depends on:** 1.3
**Commit:** `feat(study): add header timer chip and panel behind PUBLIC_STUDY_MODE`

As a estudiante,
I want un reloj chico en el header que se abre en un panel con play,
So that arranque a estudiar sin salir de la página ni agarrar el celular.

Alcance: `flag.ts`, `StudyChip` (`placement="header"`, monta motor), `StudyPanel`,
`SubjectPicker` adaptado, cambios en `Header.astro` y `Layout.astro`, `.env.example`, estilos al
80 %. No incluye contexto de página, Visor, alertas ni configuración.

**Acceptance Criteria:**

**Given** `PUBLIC_STUDY_MODE` ausente o distinto de `'true'`
**When** se renderizan `Layout` y `Header`
**Then** no aparece ninguna isla ni markup del Modo Estudio (test de `.astro`, AR-1).

**Given** el flag activo y el timer en reposo
**When** se mira el header
**Then** en desktop se ve el chip con ícono y "Estudiar"; en mobile, solo el ícono, visible en la barra junto al menú (no dentro del menú) (FR-4, UX-DR1).

**Given** el chip en reposo
**When** el estudiante lo toca
**Then** se abre el panel debajo del chip (desktop) o como sheet inferior (mobile) con play como acción principal (FR-4, NFR-4, UX-DR2).

**Given** el panel sin materia elegida
**When** el estudiante elige carrera
**Then** solo se listan materias de esa carrera, play se habilita al elegir materia, y la carrera queda guardada como última elegida (FR-2, FR-3).

**Given** un Foco corriendo, en Tiempo Extra, pausado o un Descanso
**When** se mira el chip
**Then** muestra `mm:ss` restante y el modo, `+mm:ss` en Tiempo Extra, ícono de pausa en pausa, y color teal en Descanso (FR-4, FR-9, UX-DR1).

**Given** el panel abierto con un Foco
**When** el estudiante usa Pausar, Reanudar, Terminar foco, Arrancar descanso o Saltar descanso
**Then** el timer cambia según la Story 1.1 y el panel muestra el primario de UX §B.4 (FR-7, FR-10).

**Given** el panel en reposo
**When** el estudiante elige el preset 25, 50 o 60
**Then** el próximo Foco dura eso (FR-20).

**Given** el panel
**When** se mira el pie
**Then** muestra "Hoy", "Semana: X de Meta" (o "Definir meta") y el link "Ver métricas" a `/estudio` (FR-2, FR-13).

**Given** el chip con foco de teclado
**When** se presiona Enter, se navega el panel con Tab y se presiona `Esc`
**Then** el panel abre, es operable y al cerrar el foco vuelve al chip; el nombre accesible del chip incluye estado y tiempo (NFR-6, UX-DR6).

**Given** la rama de implementación
**When** se revisa el diff
**Then** no existen `StudyWidget`, `StudyPill` ni `StudyHeaderButton`, y no hay dependencias nuevas.

### Story 1.5: Materia por contexto y chip en el Visor

**Repo:** exactamente-frontend
**Size:** M
**Depends on:** 1.4
**Commit:** `feat(study): preselect subject from page context and show chip in resource viewer`

As a estudiante,
I want que el panel ya traiga la materia que estoy mirando y que el reloj siga visible en pantalla completa,
So that arranque con dos toques y no pierda el tiempo de vista al abrir un PDF.

Alcance: `context.ts`, prop `studyContext` en `Layout.astro`, páginas `/[id]/*.astro`,
`StudyChip placement="viewer"` dentro de `CardResource.tsx`, `setViewerOpen` (AD-9, AD-10).

**Acceptance Criteria:**

**Given** el timer en reposo y el estudiante en `/[id]/parciales` (o resúmenes o finales)
**When** abre el panel
**Then** la Materia Activa es la materia `id` y arrancar requiere solo abrir el chip y play (FR-1).

**Given** una materia que pertenece a varias carreras y una última carrera elegida que está entre ellas
**When** se preselecciona
**Then** se usa esa carrera; si no está, la primera carrera de la materia (FR-3).

**Given** un Foco en curso de Física
**When** el estudiante navega a una página de Cálculo II
**Then** la Materia Activa sigue siendo Física.

**Given** el flag activo y un recurso abierto en vista completa
**When** se mira la barra superior del Visor
**Then** está el chip, a la izquierda de la X, con el mismo estado que el header (FR-5).

**Given** el Visor abierto
**When** el estudiante abre el chip del Visor
**Then** puede arrancar un Foco con la materia del recurso, pausar, reanudar y terminar sin cerrar el Visor, y el panel queda por encima del PDF (FR-5).

**Given** el panel del header abierto
**When** se abre el Visor
**Then** el panel del header se cierra y solo el chip del Visor está visible (FR-4).

**Given** un Foco corriendo con el Visor abierto
**When** se cierra el Visor
**Then** el chip del header muestra el mismo estado y tiempo (FR-5).

**Given** el flag apagado
**When** se abre el Visor
**Then** la barra no tiene chip y `CardResource` no toca el store (AR-1).

### Story 1.6: Aviso de fin de Foco, confirmación de sesión y configuración

**Repo:** exactamente-frontend
**Size:** M
**Depends on:** 1.4
**Commit:** `feat(study): add end-of-focus alerts, session toast and settings`

As a estudiante,
I want enterarme de que terminó el Foco sin que me corte, ver cuánto sumé y ajustar duraciones y avisos,
So that siga concentrado y el timer se adapte a cómo estudio.

Alcance: `useStudyAlerts` y `alerts.ts` adaptados, `StudyToast` anclado al chip visible, región
`aria-live`, `StudySettings` como vista del panel.

**Acceptance Criteria:**

**Given** un Foco que alcanza su duración
**When** está activado el sonido o la notificación
**Then** suena una vez y/o aparece una notificación del navegador, el chip pasa a Tiempo Extra, y no se abre el panel, ningún modal ni overlay (FR-8, NFR-1).

**Given** el mismo Foco con dos pestañas abiertas o tras recargar
**When** ya se avisó
**Then** no se vuelve a avisar (`targetNotified`).

**Given** que se registra una sesión de 58 min de Cálculo II y hoy había 42 min
**When** se muestra la confirmación
**Then** aparece debajo del chip visible "+58 min de Cálculo II · hoy llevás 1 h 40 min", con `role="status"`, se cierra sola a los 6 s y tiene link "Ver" (FR-11, UX-DR4).

**Given** una sesión cerrada por el tope
**When** se muestra la confirmación
**Then** indica que se cerró al llegar a 1 h de Tiempo Extra y que se puede corregir (FR-9).

**Given** el panel
**When** el estudiante abre Configuración
**Then** puede cambiar Foco (presets 25/50/60 o valor), Descanso, arranque automático del Descanso, sonido y notificación; los cambios se guardan al instante y no afectan al Foco en curso (FR-20, UX-DR3).

**Given** el switch de notificación
**When** se activa y el navegador niega el permiso
**Then** el switch vuelve a apagado con el mensaje "Tu navegador bloqueó las notificaciones" (FR-20).

**Given** un lector de pantalla
**When** arranca un Foco, termina, empieza el Descanso o se registra una sesión
**Then** la región live anuncia solo esa transición, nunca el conteo (NFR-6).

### Story 1.7: Página de Métricas de Estudio con metas, Racha y heatmap

**Repo:** exactamente-frontend
**Size:** L
**Depends on:** 1.4
**Commit:** `feat(study): add study metrics page with goals, streak and heatmap`

As a estudiante,
I want ver mi semana contra la anterior y contra mis metas,
So that sepa si estudié lo suficiente y qué priorizar.

Alcance: `pages/estudio.astro` (gate del flag, `prerender = false`), `StudyMetrics`,
`utils/metrics.ts` portado y recortado, `MetricsCharts` (`WeekChart`, `SubjectBars` con meta,
`Heatmap`), edición en línea de metas.

**Acceptance Criteria:**

**Given** el flag apagado
**When** se pide `/estudio`
**Then** responde 404 (AR-1).

**Given** 9 h esta semana y 6 h 50 min la semana anterior completa
**When** se abre `/estudio`
**Then** se ve "9 h" y "+2 h 10 min que la semana pasada"; con menos, el signo es "−" (FR-15).

**Given** una Meta Semanal de 12 h
**When** se mira la tarjeta de la semana
**Then** se ve "9 h de 12 h" con barra; sin meta, "Definir meta" con edición en línea (FR-13).

**Given** Física con meta 10 h y 5 h estudiadas, y Química con meta 3 h y 0 h
**When** se mira "Por materia"
**Then** ambas aparecen con su avance contra la meta, y se puede definir, cambiar o quitar la meta de cada una en línea (FR-14, FR-16).

**Given** un cambio de meta en la semana en curso
**When** se consulta una semana pasada
**Then** muestra la meta que tenía (FR-13).

**Given** sesiones ayer y anteayer, ninguna hoy
**When** se mira la Racha
**Then** muestra 2 días y "Estudiá hoy para sumar el día"; la Racha se calcula en hora local (FR-17).

**Given** una sesión que empezó el domingo 23:40 y terminó el lunes 00:30
**When** se agregan los totales
**Then** cuenta para el domingo y para la semana del domingo (FR-11).

**Given** historial de varias semanas
**When** se mira el heatmap
**Then** muestra 26 semanas por día con 5 niveles y cada celda tiene etiqueta accesible (FR-18, UX-DR6).

**Given** ninguna sesión registrada
**When** se abre `/estudio`
**Then** se ve el estado vacío que explica qué se va a ver y un botón que abre el panel del header (FR-19).

### Story 1.8: Lista de sesiones con edición y borrado

**Repo:** exactamente-frontend
**Size:** M
**Depends on:** 1.7
**Commit:** `feat(study): add editable session history`

As a estudiante,
I want corregir o borrar una sesión que no refleja lo que estudié,
So that mis métricas digan la verdad.

Alcance: `metrics/SessionList.tsx` dentro de `/estudio`, edición en línea con `SubjectPicker`.

**Acceptance Criteria:**

**Given** sesiones registradas
**When** se mira la sección "Sesiones"
**Then** se listan agrupadas por día, de la más reciente a la más antigua, 20 por página con "Ver más", con hora de inicio, materia y minutos (FR-18).

**Given** una sesión de 58 min
**When** el estudiante toca "Editar", baja a 43 y guarda
**Then** la sesión queda en 43 min y los totales de la semana, la Meta por Materia, la Meta Semanal y la Racha se actualizan sin recargar (FR-12).

**Given** el formulario de edición
**When** se intenta poner 0 o más de 58
**Then** no se puede guardar y se ve "máx. 58"; día y hora de inicio son solo lectura (FR-12).

**Given** una sesión
**When** se cambia su materia por otra de otra carrera
**Then** la sesión pasa a sumar en la nueva materia (FR-12).

**Given** una sesión
**When** el estudiante toca "Borrar" y confirma en la misma fila
**Then** desaparece y, si era la única del día, ese día deja de contar para la Racha (FR-12, FR-17)
**And** no se abre ningún modal (NFR-1).

**Given** dos pestañas con `/estudio` abiertas
**When** se edita una sesión en una
**Then** la otra refleja el cambio (FR-6).
