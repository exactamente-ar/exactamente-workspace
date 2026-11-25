---
title: "UX — Modo Estudio (fase 1)"
status: final
created: 2026-11-25
updated: 2026-11-25
mode: headless (fast path)
sources:
  - _bmad-output/planning-artifacts/prds/prd-modo-estudio-2026-11-24/prd.md
  - _bmad-output/planning-artifacts/prds/prd-modo-estudio-2026-11-24/addendum.md
  - wireframes Main / Estados / Config / Metricas (.dc.html, aprobados antes del PRD final)
  - exactamente-frontend, rama juanpe44/modo-estudio (spike)
colors:
  bg: "#131314"
  surface: "#18181b"          # zinc-900, fondo de chip y panel
  surface-raised: "#1c1c20"
  text: "#efefef"
  text-muted: "#a1a1aa"        # zinc-400
  brand-1: "#6b46c1"
  brand-2: "#b83280"
  brand-3: "#f6e05e"
  brand-4: "#38b2ac"
  focus: "#efefef"             # Foco corriendo: texto claro, sin color extra
  overtime: "#f6e05e"          # Tiempo Extra
  break: "#38b2ac"             # Descanso
  danger: "#dc2626"
typography:
  family: "Rubik Variable"
  clock: { size: 14px, weight: 500, features: "tabular-nums" }
  clock-panel: { size: 40px, weight: 500, features: "tabular-nums" }
  label: { size: 12px, weight: 400 }
  body: { size: 14px, weight: 400 }
rounded:
  chip: 9999px
  panel: 16px
  sheet: "16px 16px 0 0"
spacing:
  chip-h: 36px
  chip-px: 12px
  panel-w: 340px
  gutter-mobile: 16px
components:
  gradient-border: "1px, linear-gradient(90deg, {colors.brand-1}, {colors.brand-2}, {colors.brand-3}, {colors.brand-4}) al 80 % de opacidad (alpha cc)"
---

# UX — Modo Estudio (fase 1)

> Documento único que reúne las dos columnas de `bmad-ux`: **Diseño** (cómo se ve, §A) y
> **Experiencia** (cómo funciona, §B). El PRD es la fuente de verdad; este documento gana sobre
> los wireframes cuando difieren. La diferencia principal: **ya no existe la pastilla flotante**
> (wireframe `Estados`); el timer vive en el Chip del Timer del header y, con el Visor abierto, en
> la barra superior del Visor. Los términos en mayúscula son los del Glosario del PRD (§3).

---

## A. Diseño

### A.1 Marca y estilo

Exactamente es oscuro, sobrio y con el gradiente de marca como único acento. El Modo Estudio
hereda eso y baja el volumen: **está ahí, no llama la atención**. Regla de oro visual: si un
elemento del Modo Estudio compite con el PDF que el estudiante está leyendo, está mal.

- Fondo de página `{colors.bg}` (#131314); chip y panel sobre `{colors.surface}`.
- Tipografía Rubik (ya cargada en `Layout.astro`). Los relojes usan `tabular-nums` para que los
  dígitos no "bailen".
- Bordes y gradientes al **~80 % de opacidad** (addendum). El spike usa el gradiente a opacidad
  plena (`constants/styles.ts`): se corrige con alpha `cc` en cada parada del gradiente.
- Sin animaciones decorativas. El borde animado de `search-gradient-border` **no** se usa acá.

### A.2 Colores por estado

| Estado | Texto del reloj | Indicador | Borde del chip |
|---|---|---|---|
| Reposo | — | ícono reloj `{colors.text-muted}` | `white/12` (sin gradiente) |
| Foco corriendo | `{colors.focus}` | punto 6 px con gradiente de marca | gradiente al 80 % |
| Tiempo Extra | `{colors.overtime}` | punto `{colors.overtime}` | gradiente al 80 % |
| Pausado | `{colors.text-muted}` | ícono pausa | `white/24` punteado |
| Descanso | `{colors.break}` | punto `{colors.break}` | `{colors.break}` al 80 % |

El color nunca es el único portador de significado: cada estado tiene además ícono o texto
(ver B.7).

### A.3 Layout y medidas

- **Chip:** alto 36 px, `rounded-full`, padding horizontal 12 px. Ancho mínimo fijo por estado
  para que el header no salte al pasar de "Estudiar" a "49:59".
- **Panel (desktop ≥ 640 px):** popover de 340 px anclado debajo del chip, alineado a su borde
  derecho, separación 8 px. Radio 16 px, borde con gradiente al 80 %, sombra `shadow-2xl
  shadow-black/50` (la misma del header).
- **Sheet (mobile < 640 px):** ancho completo, pegado abajo, radio superior 16 px, alto según
  contenido (máx. 85 vh con scroll interno), con agarradera visual de 32×4 px.
- **Métricas (`/estudio`):** contenedor de página existente (`ContainerPage`), grilla de tarjetas
  de 1 columna en mobile y 2–3 en desktop. Gutter 16 px en mobile.

### A.4 Componentes (visual)

- **Chip del Timer** — ver estados en B.4.
- **Botón primario del panel** — blanco sobre oscuro, como "Subir Recurso" del header. Un solo
  primario por vista.
- **Presets 25 / 50 / 60** — segmented control, el activo con borde gradiente al 80 %.
- **Barra de progreso de meta** — 6 px, pista `white/8`, relleno gradiente de marca al 80 %;
  al superar la meta, relleno completo y texto "Meta cumplida" (sin confeti, sin animación).
- **Toast de confirmación** — superficie `{colors.surface-raised}`, borde gradiente al 80 %,
  anclado debajo del chip visible.
- **Heatmap** — 26 semanas × 7 días, celdas 10 px, 5 niveles de intensidad sobre `{colors.brand-4}`
  (0 = `white/6`). Reutiliza `Heatmap` del spike con la paleta corregida.

### A.5 Qué sí y qué no

- Sí: un único acento por estado; números grandes solo en el panel y en las métricas.
- No: pastillas o burbujas flotantes, badges con contadores, anillos animados en el chip, sonidos
  que el estudiante no activó, colores de facultad (backlog del PRD §6.3).

---

## B. Experiencia

### B.1 Fundamentos

- **Superficie:** web responsive (Astro MPA + islas de React). Desktop y mobile por igual.
- **Sistema de UI:** el del sitio (Tailwind v4 + primitivos shadcn existentes, `FilterCombobox`
  para los selectores). Este documento solo especifica el delta de comportamiento.
- **Sin login** (fase 1). Todo vive en el navegador.
- **Detrás de un flag:** con `PUBLIC_STUDY_MODE` distinto de `'true'` no se ve ningún elemento del
  Modo Estudio y `/estudio` no existe (ver arquitectura).

### B.2 Arquitectura de información

| Superficie | Dónde | Qué entrega | FR | Recorrido |
|---|---|---|---|---|
| Chip del Timer (header) | Header fijo, todas las páginas | Estado y tiempo de un vistazo; abre el panel | FR-4 | UJ-1 |
| Panel del Timer | Debajo del chip (desktop) / sheet inferior (mobile) | Materia Activa, presets, controles, avance del día y la semana, accesos | FR-1, 2, 3, 7, 10, 13 | UJ-1 |
| Configuración | Vista dentro del panel (no es página) | Preferencias | FR-20 | — |
| Chip del Timer (Visor) | Barra superior del Visor, junto a la X | Mismo chip y mismo panel sin cerrar el Visor | FR-5 | UJ-1 |
| Aviso de fin de Foco | En el propio chip (+ sonido/notificación si se activó) | Avisa sin cortar | FR-8, FR-9 | UJ-1 |
| Toast de sesión | Debajo del chip visible | "+58 min de Cálculo II · hoy llevás 1 h 40 min" | FR-11 | UJ-1 |
| Métricas de Estudio | `/estudio` | Semana vs. anterior, metas, Racha, heatmap, sesiones | FR-13–19 | UJ-2 |
| Historial de sesiones | Sección de `/estudio` | Editar minutos/materia, borrar | FR-12, FR-18 | UJ-1 caso borde |

Accesos a Métricas: link "Ver métricas" en el panel (siempre) y entrada "Mis métricas de estudio"
en el menú mobile del header. En desktop el header no tiene menú propio más allá del de usuario,
así que el acceso es el panel `[ASSUMPTION]`.

### B.3 Voz y microcopy

Rioplatense neutro, segunda persona con voseo, igual que el resto del sitio. Frases cortas, sin
signos de exclamación salvo en la Racha. Nunca culpa ("no estudiaste"), siempre dato.

| Momento | Copy |
|---|---|
| Chip en reposo (desktop) | "Estudiar" |
| Panel sin materia | "Elegí una materia para arrancar" |
| Play | "Arrancar foco" |
| Fin de Foco (lector de pantalla / notificación) | "Terminó tu foco de 50 min. El tiempo extra se sigue contando." |
| Chip en Tiempo Extra (accesible) | "Foco cumplido, tiempo extra 8 minutos 12 segundos" |
| Confirmación | "+58 min de Cálculo II · hoy llevás 1 h 40 min" |
| Tope de Tiempo Extra | "Cerramos tu foco al llegar a 1 h de tiempo extra. Podés corregirlo en tus métricas." |
| Foco de menos de 1 min | "El foco duró menos de un minuto y no se registró." |
| Diferencia semanal | "+2 h 10 min que la semana pasada" / "−45 min que la semana pasada" / "Igual que la semana pasada" |
| Sin meta | "Todavía no tenés meta semanal. Definir meta" |
| Estado vacío de métricas | "Acá vas a ver cuánto estudiás por semana y por materia. Abrí el reloj de arriba y arrancá tu primer foco." |
| Borrar sesión | "¿Borrar esta sesión? Sí, borrar · Cancelar" |
| Datos locales | "Tus horas se guardan en este navegador." |

### B.4 Patrones de componente

#### Chip del Timer

Un botón (`<button aria-expanded aria-controls>`) que abre/cierra el panel. Estados:

| Estado | Desktop | Mobile (header) | Clic en el chip |
|---|---|---|---|
| Reposo | ícono reloj + "Estudiar" | ícono reloj solo | Abre panel con play como primario |
| Foco corriendo | punto · `49:59` · "Foco" | ícono + `49:59` | Abre panel |
| Tiempo Extra | punto amarillo · `+08:12` · "Extra" | ícono + `+08:12` | Abre panel con "Arrancar descanso" como primario |
| Pausado | ícono pausa · `31:20` · "Pausa" | ícono pausa + `31:20` | Abre panel con "Reanudar" como primario |
| Descanso | punto teal · `07:45` · "Descanso" | ícono + `07:45` | Abre panel con "Saltar descanso" |

- El reloj muestra el **tiempo restante** en Foco y Descanso, y el **Tiempo Extra con signo +**
  después de la duración objetivo (FR-4, FR-9).
- Mobile: el chip pasa a estar **visible en la barra del header**, junto al botón de menú (hoy el
  botón del spike está oculto bajo `sm` y metido en el menú). Se quita del menú mobile para no
  tener dos representaciones.

#### Panel del Timer

Orden vertical (de arriba abajo):

1. **Materia Activa** — línea resumen "Cálculo II · Ing. en Sistemas" con acción "Cambiar". Al
   tocar "Cambiar" se despliegan dos selectores: Carrera y Materia (solo materias de la carrera
   elegida, FR-2). Sin materia, los selectores se muestran abiertos y play está deshabilitado con
   el texto "Elegí una materia para arrancar". Con un Foco en curso la materia no se puede cambiar
   (se corrige después editando la sesión) `[ASSUMPTION]`.
2. **Reloj grande** (`{typography.clock-panel}`) con el modo debajo ("Foco · 50 min").
3. **Presets 25 / 50 / 60** — solo en reposo. Elegir un preset cambia la duración del Foco en la
   configuración.
4. **Acciones** — un primario y como máximo dos secundarios:
   - Reposo: [Arrancar foco]
   - Foco corriendo: [Pausar] · Terminar foco · Arrancar descanso
   - Tiempo Extra: [Arrancar descanso] · Terminar foco · Pausar
   - Pausado: [Reanudar] · Terminar foco
   - Descanso: [Saltar descanso]
5. **Avance** — "Hoy: 1 h 40 min" y "Semana: 6 h 20 min de 12 h" con barra (o "Definir meta").
6. **Pie** — "Ver métricas" (link a `/estudio`) y botón de engranaje "Configuración".

Cerrar: clic fuera, `Esc`, o volver a tocar el chip. En mobile también arrastrar el sheet hacia
abajo o tocar el fondo atenuado. El panel **no** queda abierto al navegar a otra página.

#### Configuración (vista dentro del panel)

Reemplaza el contenido del panel con un "← Volver". Campos (FR-20):

- Duración del Foco: presets 25/50/60 + campo numérico (5–120 min).
- Duración del Descanso: campo numérico (1–30 min), por defecto 10.
- "Arrancar el descanso solo al terminar el foco" (apagado). Texto de ayuda: "Con esto activado
  no hay tiempo extra: el foco se cierra al cumplir su duración."
- "Sonido al terminar" (encendido).
- "Notificación del navegador" (apagado). Al activarlo se pide permiso; si se niega, el switch
  vuelve a apagado y aparece "Tu navegador bloqueó las notificaciones."
- Nota: "Tus horas se guardan en este navegador."

Los cambios se guardan al instante (sin botón Guardar). Una duración nueva aplica al próximo
Foco, nunca al que está corriendo. Desaparecen del wireframe `Config`: descanso largo, focos hasta
el largo, arrancar el foco solo, tiempo en la pestaña y posición de la pastilla.

#### Chip en el Visor

- Se ubica en la barra superior del Visor, **a la izquierda de la X**, con los mismos estados.
- Abre el mismo panel, anclado debajo del chip (desktop) o como sheet (mobile), **dentro** del
  diálogo del Visor para quedar por encima del PDF.
- Con el Visor abierto, el chip del header queda tapado y su panel/toast no se muestran: hay una
  sola representación visible (FR-4). Si el panel del header estaba abierto al abrir el Visor, se
  cierra.
- Al cerrar el Visor, el chip del header refleja el mismo estado; el foco del teclado vuelve al
  botón que abrió el Visor (comportamiento actual).

#### Toast de confirmación

- Aparece debajo del chip visible al registrarse una Sesión de Estudio (terminar foco, arrancar
  descanso, tope o arranque automático del descanso).
- Contenido: "+58 min de Cálculo II · hoy llevás 1 h 40 min" y link "Ver".
- `role="status"`, se cierra solo a los 6 s; se pausa mientras tiene hover o foco; tiene botón
  cerrar. No tapa el contenido central ni bloquea interacción.

### B.5 Patrones de estado

| Situación | Comportamiento |
|---|---|
| Carga inicial (antes de hidratar) | El chip renderiza en reposo con ancho reservado; al hidratar toma el estado guardado sin saltar de tamaño |
| Navegar, recargar, cerrar y volver | Mismo estado y tiempo correcto (calculado con marcas de tiempo) |
| Volver después del tope | El Foco aparece ya registrado (hasta el tope) y se muestra el toast del tope una vez |
| Dos pestañas | Un único timer: pausar en una pausa en la otra; el toast aparece solo en la pestaña que registró `[ASSUMPTION]` |
| Error cargando carreras/materias | En el selector: "No pudimos cargar las materias. Reintentar". Si hay Materia Activa guardada, play sigue disponible |
| Almacenamiento bloqueado (modo privado, cuota) | El timer funciona en la pestaña; no persiste; sin errores visibles |
| Métricas sin sesiones | Estado vacío (FR-19) con botón "Abrir el reloj" que abre el panel del header |
| Semana actual sin sesiones pero con historial | Totales en 0, comparación contra la anterior visible, heatmap con días pasados |

### B.6 Primitivas de interacción

- **Fin de Foco sin interrumpir (FR-8):** al cumplirse la duración el chip pasa a Tiempo Extra
  (cambio de color y de signo). Si el estudiante lo activó: un sonido corto y/o una notificación
  del navegador. **Nunca** se abre el panel, un modal ni un overlay.
- **Descanso a demanda (FR-10):** el primario del panel en Tiempo Extra es "Arrancar descanso".
  Al terminar el Descanso suena (si está activado) y el chip vuelve a reposo con la misma Materia
  Activa, listo para otro play.
- **Terminar antes de tiempo (FR-7):** "Terminar foco" registra los minutos corridos sin pedir
  confirmación; si fue un error, se corrige o borra en el historial.
- **Editar sesión (FR-12):** en la fila de la sesión, "Editar" expande un formulario en línea:
  minutos (1 al máximo registrado, con el máximo visible: "máx. 58") y materia (mismos selectores
  del panel). "Guardar" / "Cancelar". Fecha y hora de inicio solo lectura.
- **Borrar sesión:** confirmación en línea en la misma fila, no modal.
- **Metas (FR-13, FR-14):** edición en línea en la tarjeta (campo de horas, paso 0,5 h). Meta por
  Materia desde la fila de la materia: "Definir meta" / "Cambiar" / "Quitar". Un cambio aplica a
  la semana en curso y a las siguientes; las semanas pasadas no cambian.

### B.7 Piso de accesibilidad

- Chip: `<button>` con `aria-expanded`, `aria-controls` y nombre accesible completo que incluye
  estado y tiempo ("Modo estudio: foco, quedan 49 minutos"). El texto visible del reloj se marca
  `aria-hidden` para que el lector no lo lea cada segundo.
- Una región `aria-live="polite"` única por página anuncia **solo transiciones** (arrancó foco,
  terminó foco, empezó descanso, sesión registrada), nunca el conteo.
- Panel desktop: `role="dialog"` no modal, foco al primer control al abrir, `Esc` cierra y
  devuelve el foco al chip. Sheet mobile: `role="dialog"` `aria-modal="true"` con foco atrapado.
  Dentro del Visor, el panel respeta el atrapado de foco del Visor.
- Presets como `radiogroup`; switches de configuración como `role="switch"`.
- Contraste AA: textos sobre `{colors.surface}`; el amarillo y el teal se usan sobre oscuro (pasan
  AA para texto ≥ 14 px medio). Estado nunca solo por color (ícono/texto, ver A.2).
- Objetivos táctiles ≥ 44 px en mobile (el chip mide 36 px de alto visual con área táctil de 44).
- `prefers-reduced-motion`: el sheet aparece sin deslizar.
- Heatmap: cada celda con `aria-label` ("lunes 3 de noviembre: 1 h 20 min") y tabla equivalente
  oculta visualmente.

### B.8 Responsive y plataforma

| | Desktop ≥ 640 px | Mobile < 640 px |
|---|---|---|
| Chip en reposo | ícono + "Estudiar" | ícono solo |
| Chip corriendo | punto + mm:ss + modo | ícono + mm:ss |
| Panel | popover debajo del chip | sheet inferior |
| Toast | debajo del chip | debajo del header, ancho completo menos gutter |
| Métricas | grilla 2–3 columnas | 1 columna; heatmap con scroll horizontal propio |

### B.9 Métricas de Estudio (`/estudio`)

Orden de secciones (responde "¿estudié lo suficiente?" de arriba abajo):

1. **Esta semana** — total grande ("9 h"), diferencia con la semana anterior completa con signo
   ("+2 h 10 min que la semana pasada", FR-15) y barra contra la Meta Semanal (FR-13).
2. **Racha** — "5 días seguidos" (FR-17). Si hoy aún no estudió pero ayer sí, la Racha sigue
   viva con el texto "Estudiá hoy para sumar el día". Sin lenguaje de castigo.
3. **Por materia** — filas ordenadas por horas de la semana: nombre, horas, y barra contra la Meta
   por Materia si existe ("5 h de 10 h"). Materias con meta y sin horas también aparecen (FR-14,
   FR-16).
4. **Días de la semana** — barras lunes a domingo (reutiliza `WeekChart` del spike).
5. **Historial** — heatmap de 26 semanas (FR-18).
6. **Sesiones** — lista agrupada por día, de más reciente a más antigua, 20 por página con "Ver
   más" `[ASSUMPTION]`. Cada fila: hora de inicio, materia, minutos, "Editar", "Borrar".

Quedan fuera respecto del wireframe `Metricas`: selector Semana/Mes/Cuatrimestre/Todo, "Cuándo
rendís más" y "Exportar mis datos" (no están en el PRD; backlog).

### B.10 Recorridos clave

**UJ-1 — Lucía estudia un modelo de examen sin agarrar el celular.**

1. En `/[id]/parciales` de Cálculo II abre un parcial en vista completa.
2. Toca el chip de la barra del Visor: el panel ya muestra "Cálculo II · Ing. en Sistemas".
3. Toca "Arrancar foco" (dos toques en total, FR-1).
4. El chip muestra `49:59 · Foco`, chico, junto a la X.
5. A los 50 min el chip pasa a `+00:01 · Extra` en amarillo y suena una campana corta. Nada se abre.
6. Termina el ejercicio, abre el chip y toca "Arrancar descanso".
7. **Clímax:** toast "+58 min de Cálculo II · hoy llevás 1 h 40 min".
8. El chip muestra `09:59 · Descanso` en teal.

**UJ-2 — Lucía revisa su semana el domingo.**

1. Desde el panel toca "Ver métricas".
2. Ve "9 h · +2 h que la semana pasada" y la barra contra 12 h.
3. Ve "5 días seguidos".
4. **Clímax:** en "Por materia", Física muestra "5 h de 10 h".
5. Toca "Cambiar" en la meta de Física y la baja a 7 h: la semana en curso se recalcula; las
   anteriores mantienen 10 h.

**UJ-1, caso borde — corregir una sesión.**

1. En "Sesiones", Lucía toca "Editar" en la sesión de 58 min.
2. Baja a 43 min (el máximo visible es 58) y guarda.
3. El total de la semana, la meta de Cálculo II y la confirmación del día se actualizan al
   instante.

### B.11 Supuestos de este documento

- `[ASSUMPTION]` Desktop accede a Métricas solo desde el panel (no hay menú de header en desktop).
- `[ASSUMPTION]` La Materia Activa no se cambia con un Foco en curso.
- `[ASSUMPTION]` Un Foco de menos de 1 minuto no se registra (el mínimo editable es 1).
- `[ASSUMPTION]` El Descanso no se pausa, solo se salta.
- `[ASSUMPTION]` El toast aparece solo en la pestaña que registró la sesión.
- `[ASSUMPTION]` Lista de sesiones paginada de a 20.
- `[ASSUMPTION]` Rango del heatmap: 26 semanas (como el spike).
