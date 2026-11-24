# Modo Estudio — Lluvia de ideas

> Estado: ideación (2026-11-24). Todavía no es épica ni PRD. Próximo paso: wireframes interactivos.
> Repo afectado en la fase 1: `exactamente-frontend` (solo frontend, sin cambio de contrato).

## Visión

Un pomodoro con la estética de Exactamente, accesible desde el header, que acompaña al estudiante
mientras navega el sitio y registra cuánto estudió de cada materia. Las horas acumuladas alimentan
una vista de métricas personal.

Ejemplo: elijo la carrera, la materia "Cálculo 1" y un foco de 1 h. Al completarlo, queda
registrada 1 h de Cálculo 1.

## Hechos del código que condicionan el diseño

- El frontend es Astro MPA **sin View Transitions**: cada navegación recarga la página. Que el
  timer "te siga" requiere persistir su estado.
- Ya existe login con Google (`src/features/auth`, `AuthContext`).
- No hay store global (ni nanostores ni zustand).
- Header: `src/shared/components/Header.astro`, montado en `src/layouts/Layout.astro`.

## Decisiones tomadas

| Tema | Decisión | Motivo |
|---|---|---|
| Dónde viven las horas | **Solo localStorage** en la fase 1 | Cero backend y sin login. La migración al backend es un plan aparte. |
| Persistencia entre páginas | **Rehidratar** el widget en cada página desde localStorage | No toca el resto del sitio. View Transitions implicaría adaptar todos los scripts. |
| Siguiente paso | **Wireframes primero**, después épica BMad | Igual que multi-facultad: decidir el diseño sobre algo visible. |

Implicancia de localStorage: el formato tiene que ser **versionado** (`{ version, sessions[] }`) y
usar los **IDs reales de materia y carrera**, para que la migración futura sea un envío masivo al
backend sin transformación.

## Fase 1 (MVP) — solo frontend

1. **Timer basado en timestamps**, no en un contador con `setInterval`: se guarda
   `{ startedAt, durationMs, pausedAt, subjectId }` y el tiempo restante se recalcula al cargar.
   Sobrevive a la navegación, al refresh y al cierre de la pestaña.
2. **Widget flotante** (isla React con `client:load` en `Layout.astro`): pastilla mínima en una
   esquina con anillo de progreso, expandible a panel.
3. **Botón en el header** que abre y cierra el modo estudio.
4. **Configuración**: duración de foco, descanso corto y largo, ciclos, auto-inicio, sonido y
   notificaciones del navegador.
5. **Selección carrera → materia** al iniciar (reutiliza la facultad elegida en el onboarding de
   multi-facultad).
6. **Registro de sesiones**: al completar un foco se guarda `{ subjectId, careerId, minutes, date }`.
   Solo cuentan los minutos de foco reales.
7. **Vista de métricas** (`/estudio`):
   - Total de horas, por materia y por carrera.
   - Heatmap de días estudiados (estilo GitHub) y racha.
   - Gráfico semanal y mejor horario del día.

## Backlog de ideas futuras

| Idea | Dependencia |
|---|---|
| Migración localStorage → backend (tabla `study_sessions`, endpoints, openapi; backend primero) | requiere backend |
| Sincronización multi-dispositivo al loguearse con Google | requiere backend |
| Botón "Estudiar esta materia" en la página de materia, con la materia preseleccionada | solo-front |
| Acceso rápido a los PDFs de la materia mientras corre el pomodoro | solo-front |
| Metas semanales ("10 h de Cálculo antes del parcial") | solo-front |
| Cuenta regresiva a la fecha del parcial | solo-front |
| Logros, insignias y niveles por materia | solo-front |
| Progreso por año de la carrera, cruzado con el plan de estudios | solo-front |
| Sonidos ambiente (lluvia, lo-fi, biblioteca) | solo-front |
| Modo foco que atenúa el resto de la UI | solo-front |
| Resumen semanal compartible como imagen (marketing orgánico) | solo-front |
| Tema del widget según el color de la facultad | solo-front (depende de multi-facultad) |
| "N estudiantes estudiando Cálculo ahora" | requiere backend |
| Ranking anónimo por materia o facultad, dato agregado para la home | requiere backend |
| Tool MCP "cuánto estudié esta semana" | requiere backend |

## Riesgos

- **Trampa / pestaña olvidada**: solo contar focos completados y aplicar un tope diario razonable.
- **Varias pestañas abiertas**: un único timer, coordinado con `BroadcastChannel` o el evento
  `storage`.
- **Notificaciones**: requieren permiso; fallback con sonido y el tiempo restante en el título de
  la pestaña.
- **Pérdida de datos**: localStorage se borra si el usuario limpia el navegador. Aceptado en la
  fase 1; lo resuelve la migración al backend.

## Próximos pasos

1. Wireframes interactivos (artifact) con los tokens reales del frontend: header + pastilla,
   panel expandido, configuración y vista `/estudio`, con un timer funcional.
2. Cerrar el diseño con el usuario.
3. Épica BMad → stories → tablero.
