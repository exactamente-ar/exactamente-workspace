# Addendum — Modo Estudio

## Investigación de comparables (2026-11-24)

Síntesis de búsqueda web. Fuentes en su mayoría agregadores de reviews; poco Reddit.

| Producto | Qué retiene | Quejas relevantes |
|---|---|---|
| Forest | Árbol que muere si salís; gamificación | Sin pausa, tope free, volver a la app para cada break |
| Flora | Árboles con amigos, apuestas | Timer trabado, castigo rígido, login Facebook para lo social |
| Focus To-Do | Pomodoro + tareas + tiempo por proyecto | Sonido duplicado, upsell, sync desfasado |
| Pomofocus | Web sin login, reportes, tiempo en pestaña | Datos anónimos "desaparecían" al loguearse |
| YPT | Tiempo por materia, heatmap, grupos | No se pueden borrar sesiones mal contadas; presión social |
| StudyStream | Copresencia, rankings | Free capado a 1 h/día |
| Toggl | Detección de inactividad opt-in | — |
| Khan | Rachas con umbral bajo | — |

Aprendizajes:
1. Datos locales sin login se pierden al migrar a cuenta si no hay migración explícita (Pomofocus).
2. Timer en pestaña de fondo se desfasa con `setInterval` (throttling de Chrome); basarse en timestamps.
3. Timer visible sobre contenido en pantalla completa: solo Document Picture-in-Picture (Chromium 116+). Fuera de eso: título de pestaña.
4. Tiempo por materia + heatmap es lo más valorado; editar/borrar sesiones es pedido concreto.
5. Rachas retienen pero cortarlas causa abandono; umbral bajo ayuda.
6. Timers olvidados inflan métricas; mitigación tipo idle-detection.
7. Castigos rígidos (sin pausa) molestan.
8. Social/rankings motivan pero presionan y requieren cuenta: fuera de fase 1.

## Notas visuales (UX)

- Bordes sutiles: gradientes y bordes al ~80 % de opacidad; a opacidad plena resaltan demasiado. Aplica al chip del timer y a la UI de estudio en general.
- Un único reloj visible: chip en el header; dentro del visor a pantalla completa, el mismo chip en su barra superior junto a la X.
