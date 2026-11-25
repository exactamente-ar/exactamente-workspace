# Revisión de calidad del PRD — Modo Estudio

- **PRD:** `_bmad-output/planning-artifacts/prds/prd-modo-estudio-2026-11-24/prd.md`
- **Contexto:** `addendum.md`, `.memlog.md`
- **Rúbrica:** `.claude/skills/bmad-prd/assets/prd-validation-checklist.md`
- **Fecha:** 2026-11-25

## Veredicto general

Lo que sostiene el PRD es la tesis: "hacer visible el esfuerzo" en lugar de ser un mejor cronómetro, con el principio de "confiar en el estudiante" como guía. Esa tesis ordena las features, los no-objetivos y las contra-métricas mejor que en la mayoría de los PRDs, y los aprendizajes del spike (reloj tapado, reloj duplicado, reglas anti-trampa) quedaron bien cerrados. El riesgo está en qué cuenta como "hecho": no hay una definición operativa de "minutos estudiados" (pausas, cuándo termina un Foco, el tope del Tiempo Extra, una pestaña cerrada), y el camino principal de UJ-1 (arrancar desde el visor) no está cubierto por el mínimo que pide FR-5. Esto se puede arreglar antes de partir en épicas, y para un prototipo que prueba solo el PO no bloquea, pero las stories que salgan de §4.2–§4.4 hoy quedarían ambiguas.

## Decision-readiness — adequate

Las decisiones grandes están dichas como decisiones y cada una trae su porqué: un solo reloj sin pastilla flotante (§4.2), no usar PiP porque "la vista completa del recurso es un modal del sitio" (§5), el aviso que no corta (§4.3), compararse con la semana anterior y no con la fecha del parcial ni con otros estudiantes (§1, §5). Las contra-métricas SM-C1/SM-C2 reconocen el costo del principio de confianza: si las horas son editables, se pueden inflar. Ese es justo el trade-off que alguien levantaría como objeción, y queda reconocido.

Lo que falta es nombrar las tensiones abiertas. No hay ningún `[NOTE FOR PM]`. La tensión más visible es que FR-9 introduce un tope de Tiempo Extra, que es una forma de control, en un PRD cuyo principio rector es "no vigila, no castiga". El memlog lo resuelve conceptualmente ("cap becomes a sanity guard, not policing"), pero el PRD no lo explica. Además, el tope diario de 12 h del spike desapareció sin que se diga si se descartó o si quedó absorbido por el tope del Tiempo Extra.

Las preguntas abiertas son preguntas reales, salvo la 3, que el propio PRD ya contesta en parte (§4.6 y UJ-2 dicen "desde el header").

### Hallazgos
- **medium** La tensión entre el tope y el principio de confianza no está explicada (§4.3 FR-9, §1) — El tope del Tiempo Extra contradice en apariencia "no vigila, no castiga". El memlog lo define como una protección de cordura contra timers olvidados, no como control. *Fix:* agregar a FR-9 un `[NOTE FOR PM]` o una línea: "el tope protege contra un Foco olvidado, no limita al estudiante; al alcanzarlo, la sesión se cierra y queda editable".
- **medium** El tope diario de 12 h del spike quedó fuera sin decirlo (memlog l.20 contra §4.3) — El memlog dice que el tope pasa a ser una protección de cordura. El PRD solo menciona un tope de Tiempo Extra por Foco. *Fix:* decir explícitamente si existe un tope diario o si el tope por Foco lo reemplaza.
- **low** La pregunta abierta 3 está parcialmente respondida (§8 contra §4.6, UJ-2) — §4.6 y UJ-2 ya dicen "desde el header". *Fix:* reformularla como "¿además del header, se accede desde el Panel del Timer?" o cerrarla.

## Substance over theater — strong

Hay una sola persona, Lucía, y cada paso de sus recorridos produce un requisito: la Materia Activa por contexto, el chip en el visor, el Tiempo Extra, la edición de sesiones, la Meta por Materia. La Visión (§1) es específica: nombra al competidor real (el temporizador del celular) y el dolor concreto ("siente que no estudió lo suficiente, pero no sabe cuánto"). No podría pegarse en otro PRD. Los no-objetivos salen de la investigación de comparables (Forest/Flora para el castigo, StudyStream para lo social), no de una plantilla. Los NFRs de §4.9 están atados al producto: el throttling de pestañas ocultas, los bordes al ~80 %, la privacidad sin rankings.

### Hallazgos
- **low** Defaults sin valor (§4.7 FR-20) — "Todo tiene valores por defecto razonables" es un adjetivo. UJ-1 usa 50 min, y el glosario menciona 25 o 50. *Fix:* fijar los defaults (por ejemplo Foco 50, Descanso 10, sonido apagado, notificación apagada).

## Strategic coherence — strong

La tesis está explícita y el alcance la sigue. La fase 1 prioriza el registro y las Métricas (lo que hace visible el esfuerzo) por encima de los extras (sonidos ambiente, logros), que pasan al backlog. SM-1 y SM-2 validan la tesis directamente: dejar el celular y contestar "¿estudié lo suficiente?" sin hacer cuentas aparte. Hay contra-métricas y cada una dice qué contrapesa. El alcance es de tipo "problem-solving" y la lógica de fases (prototipo local → producción con backend) es coherente con lo que se decidió.

### Hallazgos
- **low** SM-3 mide actividad, no visibilidad (§7) — "Arrancan al menos un Foco" mide adopción del timer, que es justo lo que la tesis dice no perseguir. *Fix:* complementarla con una métrica de fase 2 que toque la visibilidad, por ejemplo el porcentaje de estudiantes activos que abren las Métricas de Estudio en la semana.
- **low** Ninguna SM valida el principio de confianza (§7, FR-12) — No se mide si la edición o el borrado de sesiones se usan, ni si se perciben como honestos. *Fix:* opcional. Agregar una observación cualitativa a SM-1, como "el PO corrige al menos una sesión y el resultado refleja lo que pasó".

## Done-ness clarity — thin

Es la dimensión más floja, y es la que más van a usar las stories. Varios FRs tienen consecuencias que se pueden probar (FR-1 "como máximo dos toques", FR-6 "pausar en una pausa en la otra", FR-8 "no abre modales"), pero la unidad central del producto, los **minutos de una Sesión de Estudio**, no tiene definición operativa. No está claro:

- si el tiempo en pausa (FR-7) se descuenta de los minutos registrados;
- qué evento "termina" el Foco y registra la sesión (FR-11 dice "al terminar un Foco"; UJ-1 lo cierra arrancando el Descanso; FR-9 dice que el Descanso corta el Tiempo Extra, pero no dice que registre la sesión);
- qué pasa cuando se alcanza el tope de FR-9 (¿se cierra solo?, ¿se registra?, ¿con qué minutos?);
- qué pasa si se cierra la pestaña y se vuelve horas después (FR-6 dice que el Foco "sigue corriendo", así que el Tiempo Extra acumula hasta el tope).

Además, FR-15 y FR-16 no tienen viñetas de consecuencia: no se sabe si la diferencia se muestra en horas absolutas o en porcentaje, ni cómo se compara una semana en curso contra una completa. FR-18 no define el rango del heatmap.

### Hallazgos
- **high** "Minutos estudiados" sin definición operativa (§4.2 FR-7, §4.3 FR-9, §4.4 FR-11) — Pausa, fin del Foco, tope y pestaña cerrada producen números distintos según cómo se implementen, y todas las Métricas dependen de eso. *Fix:* agregar a FR-11 una regla explícita: "minutos = tiempo transcurrido en Foco, sin pausas, incluido el Tiempo Extra; la sesión se registra al terminar el Foco, al arrancar el Descanso o al alcanzar el tope; al alcanzar el tope, la sesión se registra con los minutos hasta el tope y queda editable".
- **high** FR-5 no cubre el camino principal de UJ-1 (§4.2 FR-5 contra UJ-1 pasos 1–2) — UJ-1 arranca el Foco desde el chip del visor, con el Panel desplegado y la Materia Activa tomada del recurso. FR-5 solo garantiza "pausar, reanudar y ver el tiempo". *Fix:* hacer que FR-5 incluya abrir el Panel del Timer y arrancar un Foco desde el visor, con la Materia Activa del recurso (FR-1).
- **medium** "Un toque" contra "dos toques" (§1, §4.1, FR-1, memlog l.29) — La Visión y el título de §4.1 prometen un toque; FR-1 y UJ-1 piden dos (abrir el chip y play). *Fix:* alinear el texto: o el chip en reposo tiene play directo (un toque), o la Visión y el título dicen "dos toques".
- **medium** FR-15 y FR-16 sin consecuencias que se puedan probar (§4.6) — No se define el formato de la diferencia ni qué pasa con la semana en curso. *Fix:* viñetas del tipo "la diferencia se muestra en horas con signo (+2 h)" y "la semana anterior es la completa, de lunes a domingo".
- **medium** El alcance de la edición de FR-12 es ambiguo (§4.4 FR-12) — Solo se pueden editar los minutos y la materia. No queda claro si se puede cambiar el día o la hora de inicio, qué límites tienen los minutos (¿0?, ¿más que la duración real?) ni si se puede **agregar una sesión a mano** cuando el estudiante olvidó arrancar el timer, que es coherente con el principio de confianza y no figura ni como requisito ni como no-objetivo. *Fix:* definir los campos editables y los límites, y decidir si la carga manual entra en el alcance o va a §5.
- **medium** Meta Semanal sin reglas de vigencia (§4.5 FR-13, FR-14) — No se sabe si la meta se aplica a todas las semanas siguientes o solo a la actual, si cambiarla a mitad de semana reescribe el pasado, ni qué se muestra si no hay meta definida. *Fix:* agregar "la meta vigente se aplica a la semana en curso y a las siguientes; las semanas pasadas conservan la que tenían" (o lo que se decida) y el comportamiento sin meta.
- **low** El total diario de UJ-1 no tiene FR (UJ-1 clímax contra FR-11) — "hoy llevás 1 h 40 min" no aparece en ningún FR; la confirmación de FR-11 solo muestra "+58 min de Cálculo II". *Fix:* agregar el total del día a la confirmación de FR-11.
- **low** El chip en reposo es vago (§4.2 FR-4) — "Invita a arrancar el Modo Estudio" no se puede verificar. *Fix:* definir qué muestra (ícono y texto o play directo), atado a la decisión de un toque o dos.
- **low** Una sesión que cruza la medianoche (FR-17, FR-13) — No está definido a qué día ni a qué semana se acredita. *Fix:* "se acredita al día y a la semana de su inicio".

## Scope honesty — adequate

Los no-objetivos (§5) hacen trabajo real y cada uno corta un camino tentador (control, social, plan contra el parcial, PiP, app nativa). Las fases están separadas con claridad, y la regla "no se despliega a producción" queda explícita. Los supuestos están marcados y el índice cierra. La densidad de pendientes (6 supuestos y 5 preguntas) es razonable para un prototipo que prueba solo el PO.

Hay omisiones que el lector tiene que inferir: no se dice si la carga manual de sesiones está dentro o fuera; FR-22 sincroniza sesiones y metas pero no la configuración, y no se dice si es a propósito; el tope diario de 12 h del spike desapareció; y el Tiempo Extra que sigue contando (memlog l.36, marcado como `[ASSUMPTION]`) aparece en el PRD como un hecho, sin la marca.

### Hallazgos
- **medium** Supuesto del memlog presentado como hecho (memlog l.36 contra §4.3 FR-9) — En el memlog, que el Tiempo Extra cuente como estudio está registrado como supuesto. En el PRD es un requisito firme y sin marca. *Fix:* confirmarlo con el PO y quitar la marca del memlog, o marcarlo `[ASSUMPTION]` en FR-9 e indexarlo.
- **low** Configuración fuera de la sincronización sin decirlo (§4.8 FR-22) — *Fix:* agregar "la configuración queda local al dispositivo `[NON-GOAL fase 2]`" o incluirla en la sincronización.
- **low** La interacción entre el Descanso automático y el Tiempo Extra no está explicada (FR-10, FR-20 contra FR-9) — Con el Descanso automático activado, nunca habría Tiempo Extra. *Fix:* una línea en FR-10 que lo diga.

## Downstream usability — adequate

Este PRD alimenta UX, arquitectura y stories, así que la dimensión pesa. El glosario es bueno y se usa con consistencia (Chip del Timer, Panel del Timer, Materia Activa). Los IDs FR-1–23, UJ-1–3 y SM-1–5/C1–C2 son contiguos y únicos, y las referencias cruzadas (FR-18 → FR-12, SM → FR) se resuelven.

Hay huecos que van a salir en la arquitectura. FR-23 exige "sin duplicados" y FR-6 dice que una sesión "nunca se registra dos veces", pero en ningún lado se pide que la Sesión de Estudio tenga un **identificador propio y estable**, que es lo que necesitan las dos garantías. Algunos términos que se usan mucho no están en el glosario: "recurso", "visor", "vista completa", "bloque".

### Hallazgos
- **medium** La Sesión de Estudio no tiene un ID estable (§4.4 FR-11, FR-6, FR-21, FR-23) — La deduplicación entre pestañas y la migración sin duplicados dependen de un ID generado en el cliente que no está pedido. *Fix:* agregar a FR-11 o FR-21: "cada Sesión de Estudio tiene un identificador único generado al registrarse, que se conserva en la migración".
- **low** Términos fuera del glosario (§3) — "Recurso", "visor / vista completa" y "bloque" (UJ-1, "al cerrar el bloque") no están definidos. *Fix:* agregarlos al glosario o reemplazar "bloque" por "Foco".

## Shape fit — strong

Es un producto de consumo con UX importante, en un repo existente, y el PRD toma la forma que corresponde: recorridos con protagonista, FRs agrupados por funcionalidad, NFRs por funcionalidad y transversales. Las referencias al código existente que están en el memlog (modal CSS en `CardResource.tsx`, header fijo, falta de carrera guardada) quedaron bien traducidas a decisiones sin meter detalle de implementación en el PRD. El rigor es proporcional a un prototipo que prueba solo el PO. No está sobreformalizado.

### Hallazgos
- (sin hallazgos)

## Notas mecánicas

- **Índice de supuestos:** cierra en las dos direcciones (6 en línea, 6 indexados). Falta el supuesto del Tiempo Extra que sigue contando (memlog l.36) si se decide conservarlo como supuesto.
- **IDs:** FR-1–23, UJ-1–3, SM-1–5, SM-C1–C2 son contiguos y no tienen duplicados.
- **Protagonistas:** los tres UJ nombran a Lucía. UJ-2 y UJ-3 no repiten "Persona + contexto". Se pueden leer sueltos, pero UJ-2 no tiene un bloque de contexto explícito.
- **Cambios de vocabulario:** "bloque" (UJ-1) se usa como sinónimo no definido de Foco. "Arranque en un toque" (§4.1) contra "dos toques" (FR-1).
- **Decisiones del memlog:** todas reflejadas salvo dos. El tope diario de 12 h (l.20) no aparece, y el Tiempo Extra que cuenta (l.36) pasó de supuesto a hecho. La decisión de la burbuja flotante (l.21) quedó correctamente reemplazada (l.43 → §4.2, §5).
- **Secciones requeridas:** están todas para lo que está en juego y para el tipo de producto. Las metas cuantitativas de SM-1 y SM-2 no hacen falta en fase 1 (prototipo del PO). Las de SM-3 a SM-5 se pueden fijar antes de fase 2.
