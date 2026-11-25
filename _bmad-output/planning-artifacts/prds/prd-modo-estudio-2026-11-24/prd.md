---
title: "PRD — Modo Estudio"
status: final
created: 2026-11-24
updated: 2026-11-25
inputs:
  - _bmad-output/planning-artifacts/modo-estudio-brainstorm.md
  - https://claude.ai/artifact/8mag2oiCXxJWcqUbiSE5Do (wireframes)
  - exactamente-frontend, rama juanpe44/modo-estudio (spike, sin pushear)
  - addendum.md (investigación de comparables, notas visuales)
---

# PRD — Modo Estudio

## 0. Propósito del documento

Este PRD define el Modo Estudio de Exactamente desde la experiencia del estudiante. Es para quien
diseña, arquitecta y parte en épicas la feature. Los términos del Glosario (§3) se usan tal cual en
todo el documento. Los supuestos van marcados `[ASSUMPTION]` y están indexados en §9.

Construye sobre tres insumos: la lluvia de ideas, los wireframes y un spike de implementación. El
spike se trata como **prototipo para aprender, no como especificación**. Lo que el spike mostró que
estaba mal está recogido acá como requisito o como no-objetivo:

- Al abrir un recurso en vista completa, el timer queda tapado.
- El reloj aparecía dos veces (botón del header y pastilla flotante).
- Las reglas anti-trampa (solo cuentan focos completos) contradicen el principio de confiar en el
  estudiante.

## 1. Visión

Hoy un estudiante entra a Exactamente, abre un modelo de examen, pone el temporizador del celular y
estudia. Lo hace varios días. Al final de la semana siente que no estudió lo suficiente, pero no sabe
cuánto estudió de verdad: el esfuerzo no queda en ningún lado.

El Modo Estudio no compite con el celular por ser mejor cronómetro. Compite por **hacer visible el
esfuerzo**: cada sesión queda registrada por materia, y el estudiante puede compararse con su semana
anterior y con sus propias metas. Arrancar tiene que costar lo mismo que en el celular: sin elegir nada, abrir y play.
Mientras estudia, el timer está ahí pero no molesta.

Principio rector: **la herramienta confía en el estudiante**. No vigila, no castiga, no decide por él
qué cuenta como estudio.

## 2. Usuario

### 2.1 Jobs To Be Done

- **Funcional:** saber cuántas horas le dediqué a cada materia esta semana y si llego a lo que me
  propuse.
- **Emocional:** dejar de sentir culpa difusa ("no estudié nada") y reemplazarla por un dato.
- **Contextual:** medir el tiempo sin salir del material que estoy estudiando ni agarrar el celular,
  que es donde me distraigo.

### 2.2 No-usuarios (v1)

- Quien busca estudiar acompañado o competir con otros (copresencia, rankings).
- Quien quiere un control estricto que lo castigue por distraerse.

### 2.3 Recorridos clave

- **UJ-1. Lucía estudia un modelo de examen sin agarrar el celular.**
  - **Persona + contexto:** Lucía, segundo año de Ingeniería, cursa Física y Cálculo II. Falta poco
    para los parciales.
  - **Entrada:** está en la página de Cálculo II en Exactamente y abre un modelo de examen en vista
    completa.
  - **Recorrido:**
    1. Toca el Chip del Timer en la barra del visor. La Materia Activa ya viene puesta en Cálculo II
       y la carrera viene de su perfil.
    2. Toca play.
    3. Resuelve ejercicios con el PDF ocupando la pantalla. El chip muestra el tiempo, chico y sin
       llamar la atención.
    4. A los 50 minutos el chip le avisa que terminó el Foco. Está en mitad de un ejercicio, así que
       sigue: el Tiempo Extra se sigue contando.
    5. Termina el ejercicio y arranca el Descanso.
  - **Clímax:** al terminar el Foco ve "+58 min de Cálculo II · hoy llevás 1 h 40 min".
  - **Resolución:** la Sesión de Estudio queda registrada. Su Racha suma el día.
  - **Caso borde:** se distrajo 15 minutos con el celular en el medio. Después edita la sesión y le
    descuenta esos minutos, o no lo hace. Lo decide ella.

- **UJ-2. Lucía revisa su semana el domingo a la noche.**
  - **Persona + contexto:** la misma Lucía, después de una semana usando el Modo Estudio.
  - **Entrada:** abre las Métricas de Estudio desde el header.
  - **Recorrido:**
    1. Ve el total de la semana contra el de la semana anterior.
    2. Ve su avance contra la Meta Semanal (12 h) y contra cada Meta por Materia (Física 10 h,
       Cálculo II 4 h).
    3. Ve su Racha de días seguidos.
  - **Clímax:** descubre que estudió 9 h, 2 h más que la semana pasada, pero solo 5 h de Física
    contra una meta de 10 h.
  - **Resolución:** sabe qué priorizar la semana siguiente. Ajusta la Meta por Materia de Física si
    no era realista.

- **UJ-3. Lucía estudia en dos dispositivos.** *(fase 2)*
  - **Contexto:** estudia a la mañana en la compu de la facultad y a la noche en su notebook.
  - **Recorrido:**
    1. Inicia sesión con Google en ambos dispositivos.
    2. Sus sesiones de los dos dispositivos se suman en un único historial.
    3. Las sesiones que tenía guardadas antes de loguearse se incorporan a su cuenta. No se pierden.
  - **Clímax:** el total del domingo es el real, no el de un solo dispositivo.

## 3. Glosario

- **Modo Estudio** — La feature completa: timer, registro, metas y métricas.
- **Foco** — Bloque de estudio con duración objetivo (por ejemplo 25 o 50 min). Genera una Sesión de
  Estudio.
- **Descanso** — Bloque de pausa entre Focos. No suma tiempo de estudio.
- **Tiempo Extra** — Minutos de Foco que transcurren después de cumplirse la duración objetivo, hasta
  que el estudiante lo termina o arranca el Descanso.
- **Sesión de Estudio** — Registro de un Foco terminado: materia, carrera, inicio, minutos
  estudiados. Es editable y borrable por el estudiante.
- **Materia Activa** — Materia a la que se acredita el Foco en curso.
- **Chip del Timer** — La única representación del timer en pantalla. Vive en el header o, con el
  visor en vista completa, en la barra superior del visor.
- **Panel del Timer** — Vista expandida que se despliega debajo del Chip del Timer: controles,
  Materia Activa, presets.
- **Meta Semanal** — Horas de estudio que el estudiante se propone para la semana, sumando todas las
  materias.
- **Meta por Materia** — Horas semanales que el estudiante se propone para una materia puntual.
  Opcional.
- **Racha** — Cantidad de días consecutivos con al menos una Sesión de Estudio.
- **Métricas de Estudio** — Vista personal con totales, comparación semanal, metas y Racha.
- **Recurso** — Material de una materia (resumen, parcial o final) que se abre desde su página.
- **Visor** — Vista completa de un Recurso: modal del sitio que ocupa la pantalla y tapa el header.
- **Perfil** — Datos del estudiante (carrera y plan) definidos en el PRD de Roadmap de carrera.
  Este PRD los consume, no los define.

## 4. Funcionalidades

### 4.1 Arranque en un toque

**Descripción:** desde cualquier página de una materia o de un recurso, el Modo Estudio se arranca
sin elegir nada: abrir el chip y play. La Materia Activa sale del contexto y la carrera del Perfil. Desde cualquier otra
página, el estudiante elige carrera y materia en el Panel del Timer. Realiza UJ-1.

#### FR-1: Materia preseleccionada por contexto

El estudiante que abre el Panel del Timer desde una página de materia o de recurso encuentra esa
materia como Materia Activa. Realiza UJ-1.

- Desde `/[id]/parciales` (o resúmenes o finales) la Materia Activa es la materia `id`.
- Desde ese contexto, arrancar un Foco requiere como máximo dos toques: abrir el chip y play.

#### FR-2: Cambiar materia y carrera

El estudiante puede elegir otra carrera y otra materia en el Panel del Timer antes de arrancar un
Foco.

- Sin contexto de materia, el Panel del Timer pide elegir una materia antes de habilitar play.
- Se listan solo materias de la carrera elegida.
- El Panel del Timer ofrece un acceso a las Métricas de Estudio.

#### FR-3: Carrera preseleccionada

La carrera viene preseleccionada a partir del Perfil.

- Si el Perfil tiene carrera, se usa esa.
- Si no hay Perfil (hoy no existe), se usa la última carrera elegida en el Modo Estudio.
- Revisar esta regla cuando el Perfil esté disponible.

### 4.2 Un solo reloj, siempre arriba

**Descripción:** el timer tiene una sola representación en pantalla, el Chip del Timer. En páginas
normales vive en el header, que ya está fijo y siempre visible. Al tocarlo se despliega el Panel del
Timer justo debajo. Cuando el estudiante abre un recurso en vista completa, el header queda tapado, y
el mismo chip aparece en la barra superior del visor, junto a la X. No hay pastilla flotante.
Realiza UJ-1.

#### FR-4: Chip del Timer en el header

El estudiante ve el Chip del Timer en el header en todas las páginas.

- En reposo, el chip muestra un ícono de reloj y el texto "Estudiar"; tocarlo despliega el Panel del
  Timer con play como acción principal.
- Con un Foco o Descanso en curso, muestra el tiempo restante (mm:ss) y el modo.
- Nunca hay dos representaciones del timer visibles al mismo tiempo.

#### FR-5: Chip del Timer en la vista completa de un recurso

Con un recurso abierto en vista completa, el estudiante ve y controla el timer desde la barra
superior del visor, sin cerrarlo.

- Desde el chip del visor el estudiante puede abrir el Panel del Timer y arrancar un Foco, con la
  materia del recurso como Materia Activa (FR-1).
- También puede pausar, reanudar, terminar y ver el tiempo sin cerrar el visor.
- Al cerrar el visor, el chip vuelve al header con el mismo estado.

#### FR-6: El timer sobrevive a la navegación

El Foco en curso sigue corriendo y muestra el tiempo correcto al navegar entre páginas, recargar, o
cerrar y volver a abrir la pestaña.

- El tiempo restante se calcula desde marcas de tiempo, no desde un contador.
- Con dos pestañas abiertas hay un único timer: pausar en una pausa en la otra.
- Una Sesión de Estudio nunca se registra dos veces, aunque haya varias pestañas abiertas.

#### FR-7: Control del Foco

El estudiante puede pausar, reanudar y terminar un Foco, y saltar un Descanso.

- Terminar un Foco antes de tiempo registra los minutos estudiados hasta ese momento
  `[ASSUMPTION]`.

**NFRs de la funcionalidad:**

- El Chip del Timer es chico, minimalista y no distrae. Bordes y gradientes al ~80 % de opacidad (ver
  addendum, notas visuales).
- El chip y el panel son operables con teclado y lectores de pantalla.

### 4.3 Fin del Foco sin interrumpir

**Descripción:** cuando se cumple la duración objetivo, el Modo Estudio avisa pero no corta. Si el
estudiante está en mitad de algo, sigue, y el Tiempo Extra cuenta. El Descanso arranca cuando él
decide. Realiza UJ-1.

#### FR-8: Aviso de fin de Foco

Al cumplirse la duración objetivo, el estudiante recibe un aviso visual en el chip y, si lo activó,
un sonido o una notificación del navegador.

- El aviso no pausa ni cierra el Foco.
- El aviso no abre modales ni tapa el contenido.

#### FR-9: Tiempo Extra

Los minutos posteriores a la duración objetivo se acumulan como Tiempo Extra y se suman a la Sesión
de Estudio.

- El chip muestra el Tiempo Extra (por ejemplo "+08:12").
- El Tiempo Extra se corta cuando el estudiante termina el Foco o arranca el Descanso.
- Que el Tiempo Extra cuente como estudio es coherente con confiar en el estudiante
  `[ASSUMPTION]`.
- Un tope de 60 minutos de Tiempo Extra evita que un Foco olvidado acumule horas sin límite
  `[ASSUMPTION]`. Al alcanzarlo, la sesión se cierra y queda editable. Este tope reemplaza al tope diario de 12 h del spike: no es anti-trampa, es protección contra un timer
  olvidado.

#### FR-10: Descanso a demanda

El estudiante arranca el Descanso cuando quiere, desde el chip o el panel. La opción de que el
Descanso arranque solo existe en la configuración, apagada por defecto `[ASSUMPTION]`. Con esa
opción activada no hay Tiempo Extra: el Foco se cierra al cumplir la duración objetivo.

### 4.4 Registro honesto de sesiones

**Descripción:** cada Foco terminado genera una Sesión de Estudio. El estudiante es dueño de sus
datos: puede corregir lo que no refleja la realidad. Realiza UJ-1 y UJ-2.

#### FR-11: Registro de la Sesión de Estudio

Al terminar un Foco se registra una Sesión de Estudio con materia, carrera, inicio y minutos
(incluido el Tiempo Extra).

- La Sesión de Estudio tiene un identificador propio y estable, que permite deduplicarla entre
  pestañas (FR-6) y al migrarla a la cuenta (FR-23).
- La Sesión de Estudio guarda los identificadores reales de materia y carrera, y también sus nombres.
- Minutos estudiados = tiempo con el Foco corriendo, sin contar pausas, incluido el Tiempo Extra
  `[ASSUMPTION]`.
- La Sesión de Estudio se registra al terminar el Foco, al arrancar el Descanso o al alcanzar el
  tope de Tiempo Extra. En ese último caso registra los minutos hasta el tope y queda editable.
- Si el estudiante cerró la pestaña, al volver se aplica la misma regla con las marcas de tiempo.
- Una sesión se acredita al día y a la semana en que empezó.
- La confirmación incluye el total del día ("+58 min de Cálculo II · hoy llevás 1 h 40 min").
- Al registrarse, el estudiante ve una confirmación ("+58 min de Cálculo II").

#### FR-12: Editar y borrar sesiones

El estudiante puede editar los minutos o la materia de una Sesión de Estudio, y borrarla.

- Los minutos editados van de 1 al máximo registrado por esa sesión: corregir es descontar, no
  agregar. Para agregar tiempo hay carga manual (fase 2).
- No se edita el día ni la hora de inicio.

- Los cambios se reflejan de inmediato en las Métricas de Estudio, las metas y la Racha.

**Out of scope:** cualquier verificación automática de que el estudiante "realmente estudió". La
carga manual de una sesión olvidada queda para fase 2.

### 4.5 Metas

**Descripción:** el estudiante se pone metas para la semana y puede ver su avance en cada momento.
Realiza UJ-2.

#### FR-13: Meta Semanal

El estudiante puede definir y cambiar su Meta Semanal en horas.

- El avance se muestra como horas estudiadas sobre la meta, desde el panel y desde las Métricas de
  Estudio.
- La semana va de lunes a domingo `[ASSUMPTION]`.
- La meta vigente se aplica a la semana en curso y a las siguientes hasta que el estudiante la
  cambie. Las semanas pasadas conservan la meta que tenían.
- Sin meta definida, el avance se muestra solo en horas y se ofrece definir una.

#### FR-14: Meta por Materia

El estudiante puede definir, cambiar o quitar una Meta por Materia para cualquier materia.

- Cada Meta por Materia muestra su propio avance.
- Las Metas por Materia no tienen que sumar la Meta Semanal.

### 4.6 Métricas de Estudio

**Descripción:** vista personal, accesible desde el header, que responde "¿estudié lo suficiente?"
comparando con la semana anterior y con las metas. Realiza UJ-2.

#### FR-15: Semana actual contra la anterior

El estudiante ve el total de horas de la semana actual y la diferencia con la semana anterior.

- La diferencia se muestra con signo y en horas y minutos ("+2 h 10 min").
- La semana anterior es la completa (lunes a domingo); la actual, lo que va de la semana.

#### FR-16: Desglose por materia

El estudiante ve las horas de la semana por materia, junto a su Meta por Materia si la tiene.

#### FR-17: Racha

El estudiante ve su Racha actual.

- Un día cuenta para la Racha con al menos una Sesión de Estudio, de cualquier duración.
- La Racha se calcula en la zona horaria local del estudiante.

#### FR-18: Historial

El estudiante ve un historial de días estudiados (estilo heatmap) y la lista de sesiones, desde donde
puede editarlas (FR-12) `[ASSUMPTION: el heatmap entra en fase 1]`.

#### FR-19: Estado vacío

Sin sesiones registradas, las Métricas de Estudio explican qué se va a ver y cómo arrancar el primer
Foco.

### 4.7 Configuración

**Descripción:** el estudiante ajusta el Modo Estudio a su forma de estudiar, sin que la
configuración sea un paso obligatorio.

#### FR-20: Preferencias

El estudiante puede configurar:

- duración del Foco (con presets 25/50/60) y del Descanso;
- arranque automático del Descanso;
- sonido de aviso;
- notificación del navegador, que pide permiso al activarla.

Valores por defecto: Foco 50 min, Descanso 10 min, arranque automático apagado, sonido encendido,
notificación apagada. Nada es obligatorio para arrancar.

### 4.8 Persistencia de los datos

**Descripción:** el estudiante estudia desde más de un dispositivo, así que el estado final es que
sus datos vivan asociados al Perfil en el backend. La fase 1 es un prototipo local y guarda en el
navegador. Realiza UJ-3 en fase 2.

#### FR-21: Persistencia local (fase 1)

Las Sesiones de Estudio, las metas, la configuración y el estado del timer se guardan en el
navegador, en un formato versionado.

- El formato permite migrar las sesiones al backend sin transformación de significado.

#### FR-22: Persistencia en el Perfil (fase 2)

Las Sesiones de Estudio y las metas del estudiante logueado se guardan en el backend, asociadas a su
Perfil, y se ven iguales en cualquier dispositivo.

#### FR-23: Migración de datos locales (fase 2)

Al loguearse, el estudiante que tenía Sesiones de Estudio en el navegador las ve incorporadas a su
cuenta, sin duplicados.

- Ninguna sesión local "desaparece" al iniciar sesión.
- La configuración queda local al dispositivo `[NON-GOAL fase 2]`.

### 4.9 Requisitos no funcionales transversales

- **No distraer:** ninguna parte del Modo Estudio abre modales, anima ni suena sin que el estudiante
  lo haya pedido. Estética sutil: bordes al ~80 % de opacidad.
- **Robustez del timer:** el tiempo es correcto aunque la pestaña esté en segundo plano, ya que los
  navegadores frenan los timers de pestañas ocultas.
- **Privacidad:** los datos de estudio son personales. No se muestran a otros ni se usan para
  rankings.
- **Mobile:** el chip y el panel funcionan en pantallas chicas `[ASSUMPTION: el panel abre como sheet
  inferior en mobile]`.
- **Sin login en fase 1:** el prototipo funciona sin cuenta.

## 5. No-objetivos

- No es una herramienta de control: no detecta distracción, no castiga, no exige completar bloques.
- No es social: sin copresencia, rankings ni "N estudiantes estudiando ahora".
- No organiza el estudio contra la fecha del parcial (cuenta regresiva, plan de estudio).
- No usa picture-in-picture ni ventanas fuera del navegador: la vista completa del recurso es un
  modal del sitio y alcanza con el chip en su barra.
- No es una app nativa ni una extensión del navegador.

## 6. Alcance por fase

### 6.1 Fase 1: prototipo local

Lo prueba solo el PO, en local. **No se despliega a producción.**

- FR-1 a FR-21 completos, con persistencia en el navegador.
- Carrera preseleccionada desde la última elegida (sin Perfil).

### 6.2 Fase 2: lanzamiento a producción

Requisito para salir a producción: datos asociados al Perfil.

- FR-22 y FR-23 (backend, sincronización entre dispositivos, migración de lo local).
- FR-3 con el Perfil real (depende del PRD de Roadmap de carrera).
- Requiere cambio de contrato: el backend se releasea primero.

### 6.3 Fuera de alcance (backlog)

Quedan en la lluvia de ideas: sonidos ambiente, logros e insignias, resumen compartible, tema por
facultad, acceso rápido a PDFs durante el Foco, tool MCP, y todo lo social.

## 7. Métricas de éxito

**Fase 1 (cualitativa)**

- **SM-1:** el PO usa el Modo Estudio durante una semana real sin volver al temporizador del celular,
  y si corrige una sesión, el resultado refleja lo que pasó. Valida FR-1, FR-4, FR-5 y FR-12.
- **SM-2:** el domingo, las Métricas de Estudio responden "¿estudié lo suficiente?" sin hacer
  cuentas aparte. Valida FR-13 a FR-17.

**Fase 2 (producción)**

- **SM-3:** porcentaje de visitantes semanales de páginas de materia que arrancan al menos un Foco.
- **SM-4:** retención semanal: estudiantes con sesiones en la semana N que vuelven a tener en N+1.
- **SM-6:** porcentaje de estudiantes activos que abren las Métricas de Estudio en la semana: mide
  visibilidad, no solo uso del timer.
- **SM-5:** porcentaje de estudiantes activos con una Meta Semanal definida.

**Contra-métricas (no optimizar)**

- **SM-C1:** horas totales registradas. Son editables por el estudiante y fáciles de inflar; empujar
  este número convierte la herramienta en un juego. Contrapesa SM-3.
- **SM-C2:** largo de la Racha. Optimizarla lleva a mecánicas que castigan cortarla, que es lo que
  causa abandono. Contrapesa SM-4.

## 8. Preguntas abiertas y decisiones provisorias

Estas preguntas se cerraron sin el PO para no bloquear la fase 1. Son provisorias: el PO las
confirma al probar el prototipo.

1. **Tope de Tiempo Extra:** 60 minutos (FR-9).
2. **Chip en el header mobile:** ícono solo en reposo; con el timer corriendo, ícono y mm:ss
   compacto. El panel abre como sheet inferior (FR-4).
3. **Acceso a las Métricas de Estudio:** desde el Panel del Timer y desde el menú del header (§4.6).
4. **Cierre de sesión en fase 2:** se define en el PRD de fase 2 (FR-22).
5. **Foco sin volver:** se registra hasta el tope y queda editable (FR-11).
6. **Edición:** minutos (solo para descontar) y materia; borrar. Sin carga manual en fase 1 (FR-12).
7. **Vigencia de la meta:** se mantiene hasta que se cambie (FR-13).
8. **Perfil:** fase 1 no depende del PRD de Roadmap de carrera; usa la última carrera elegida (FR-3).

## 9. Índice de supuestos

- §4.2 FR-7: terminar un Foco antes de tiempo registra los minutos estudiados hasta ese momento.
- §4.3 FR-9: el Tiempo Extra cuenta como estudio.
- §4.4 FR-11: minutos estudiados = tiempo corriendo sin pausas, incluido el Tiempo Extra.
- §4.3 FR-9: el tope de Tiempo Extra es de 60 minutos.
- §4.3 FR-10: el arranque automático del Descanso viene apagado por defecto.
- §4.5 FR-13: la semana va de lunes a domingo.
- §4.6 FR-18: el heatmap del historial entra en fase 1.
- §4.9: en mobile el Panel del Timer abre como sheet inferior.
