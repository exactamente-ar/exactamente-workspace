# Metodología

Cómo se trabaja en Exactamente. Cuatro repos separados, una sola forma de tocarlos.

---

## Arrancar en una máquina nueva

```bash
git clone https://github.com/exactamente-ar/exactamente-workspace.git
cd exactamente-workspace
./setup.sh
```

`setup.sh` verifica prerequisitos, clona los 4 repos, instala dependencias con el gestor
correcto de cada uno, crea los `.env` desde los `.env.example`, levanta PostgreSQL y aplica
las migraciones. Es idempotente — corrélo las veces que quieras.

Después completá los secretos que te haya listado y ya podés levantar todo:

| Repo | Comando | Puerto |
|---|---|---|
| `exactamente-backend` | `bun dev` | 3000 |
| `exactamente-frontend` | `pnpm dev` | 4321 |
| `exactamente-frontend-admin` | `pnpm dev` | 5173 |
| `exactamente-mcp` | `pnpm dev` | 3001 |

El backend necesita Docker corriendo (PostgreSQL). Los otros tres no.

### Variables de entorno

| Repo | Qué necesita |
|---|---|
| backend | `DATABASE_URL`, `JWT_SECRET` (≥32 chars), `CORS_ORIGIN`, `ADMIN_ORIGIN`, credenciales de R2, `GOOGLE_CLIENT_ID` / `_SECRET` / `_REDIRECT_URI`, `RESEND_API_KEY` |
| frontend | `PUBLIC_API_URL` |
| admin | `VITE_API_URL` |
| mcp | URL base de la API |

Los `.env.example` son la fuente de verdad. Si agregás una variable, actualizá el `.example`
en el mismo PR — si no, el `setup.sh` de la próxima persona genera un `.env` incompleto.

---

## El ciclo de una feature

### 1. Planificar — en el workspace, publicar en el tablero

Todo el trabajo vive en el **[tablero de la org](https://github.com/orgs/exactamente-ar/projects/2)**.
Regla: **el issue es la fuente de verdad; el archivo de BMad es el detalle.** Si una story
existe en `_bmad-output/` pero no como issue, para el resto del equipo no existe.

Cuánto se planifica depende del tamaño:

| Caso | Con BMad | En GitHub |
|---|---|---|
| **Bug** | nada, o `bmad-quick-dev` | Issue tipo `Bug` en el repo afectado → **Ready** |
| **Feature chica** (1 repo, pocas horas) | `bmad-quick-dev` o una spec corta | Issue tipo `Feature` con criterios de aceptación → **Ready** |
| **Épica** (cruza repos o tiene varias stories) | brief/PRD → `bmad-create-epics-and-stories` | Issue tipo `Epic` en `exactamente-workspace` + un **sub-issue por story** en el repo donde se implementa |
| **Idea cruda** (de cualquiera) | — | Template "Proponer una idea" → **Inbox**. Se refina con BMad cuando se prioriza |

Columnas del tablero:

| Columna | Qué significa | Cómo llega |
|---|---|---|
| **Inbox** | Entró y nadie lo revisó todavía | Solo: todo issue nuevo cae acá |
| **Backlog** | Aceptado, no es para ahora. **El orden de arriba hacia abajo es la prioridad** | Triage del maintainer |
| **Ready** | Refinado, con criterios de aceptación. Se puede tomar | Después de refinarlo (con BMad si hace falta) |
| **In progress** · **In review** · **Done** | En curso · PR abierto · cerrado | In progress al tomarlo; In review y Done solos, con el PR (`Closes #N`) |

**Triage:** revisar Inbox seguido. Cada issue va a Backlog, directo a Ready si ya está claro, o se
cierra como *not planned*. Refinar es pasar de Backlog a Ready. Lo que se traba discutiéndolo
lleva el label `needs-discussion`, no una columna aparte.

Todo issue cerrado va a Done, y mover una tarjeta a Done cierra el issue. Lo que se descarta se
cierra como *not planned*: termina en Done igual, pero se distingue con el filtro
`reason:"not planned"`.

Solo lo que está en **Ready** se puede tomar: tiene criterios de aceptación y nadie asignado.

En las épicas, cada story se implementa en **un solo repo** (si toca dos, son dos stories) y
lleva `**Repo:**`, `**Size:**` y, si hace falta, `**Depends on:**`. BMad ya las genera así: el
override en `_bmad/custom/bmad-create-epics-and-stories.toml` se lo exige.

**Publicar:** `/exactamente-publish-stories` sobre el `epics.md`. Muestra un preview, y al
confirmar crea el issue `Epic` en `exactamente-workspace`, un sub-issue por story en su repo, los
enlaces "bloqueado por" (los clientes quedan bloqueados por la story de backend), los agrega al
tablero y escribe `github: exactamente-ar/<repo>#N` en el archivo. Es idempotente. Cualquier
colaborador puede publicar, pero solo quien tiene `admin`/`maintain` en el repo puede mandarlo
directo a Backlog o Ready; el resto entra en Inbox.

**Tomar:** `/exactamente-take-issue` lista lo que está en Ready sin asignar. Al elegir uno
verifica que no esté bloqueado, te lo asigna (la asignación es el lock), lo pasa a In progress,
crea la rama y junta el contexto. **No implementa**: eso lo arrancás vos (`bmad-dev-story`).

Un issue con el label `agent-ready` es chico, tiene criterios testeables y ninguna decisión
abierta: lo puede tomar un agente. Sin ese label, un agente no lo toma por su cuenta.

### 2. Rama — el mismo nombre en cada repo

El prefijo es **tu** usuario de GitHub, no el de otro:

```bash
git -C exactamente-backend  checkout -b <tu-usuario>/materias-por-plan origin/develop
git -C exactamente-frontend checkout -b <tu-usuario>/materias-por-plan origin/master
```

En el backend la rama sale de **`develop`**; en los clientes, de su rama principal. El flujo
completo de ramas y versiones está en "Releases" del `CONTRIBUTING.md`.

Mismo nombre en cada repo = mirás la lista de ramas de cualquiera y sabés qué está en vuelo. El
prefijo = sabés de quién.

### 3. Implementar — backend primero, siempre

**El contrato de la API tiene que estar en `main` del backend antes de que cualquier cliente lo
consuma.** Como el backend integra en `develop`, eso implica un release (`develop` → `main`) a
mitad de la épica, antes de mergear los clientes.

Esto ya no depende de que te acuerdes. Si tu feature cambia una respuesta:

```bash
cd exactamente-backend && bun run gen:openapi   # commiteá openapi.json
cd ../exactamente-frontend-admin && pnpm gen:api  # arreglá lo que TS marque
```

Los clientes leen el spec del `main` del backend, así que su CI falla si intentás mergear
contra un contrato que todavía no está releaseado. Y si cambiaste el código del backend sin
regenerar, `check:openapi` te frena ahí mismo.

Antes esto era solo disciplina, y por eso murió `materias-agrupadas`: se mergeó en el admin con
el backend todavía en rama y quedó rota en producción hasta que se dio de baja. Ahora el orden
lo impone la máquina.

Dentro de cada repo, las reglas son las de ese repo:

- `exactamente-frontend/AGENTS.md` — Astro no es Next, TDD obligatorio, production-first
- `exactamente-backend/CLAUDE.md` + los `CLAUDE.*.md` por módulo
- `exactamente-frontend-admin/CLAUDE.md`

### 4. TDD

Test que falla primero, y **verlo fallar**. Después el código mínimo para que pase.

Un test que pasa de entrada no probó nada: puede estar verde porque la aserción es trivial,
porque el mock devuelve lo que espera, o porque no ejecuta lo que creés. Verlo en rojo es lo
que le da valor.

Qué rinde testear y qué no está detallado en el `AGENTS.md` del frontend; aplica igual en los
otros repos.

### 5. Gates automáticos

Corren solos en los 4 repos, no hay que acordarse:

| Cuándo | Qué |
|---|---|
| `commit` | prettier sobre los archivos staged, eslint, tests afectados |
| mensaje de commit | commitlint (Conventional Commits) |
| `push` | typecheck + suite completa |
| PR | CI: typecheck, lint, format:check, test, build |

El backend suma un job de `docker build`: `main` despliega a producción vía Dokploy, así que
si la imagen no compila conviene enterarse en el PR y no en el servidor.

Si un hook te molesta, arreglá la causa. `--no-verify` es para emergencias reales, no para
apurar un commit.

**Los tests no pueden depender de tu `.env`.** Ya pasó en el backend: `env-setup.ts` no
seteaba todas las variables que exige `env.ts`, los tests tomaban el resto del `.env` del dev
y pasaban en local, pero en CI la suite ni arrancaba. Si agregás una variable obligatoria,
agregala también al setup de tests. Se comprueba fácil: movés el `.env` fuera del repo y
corrés la suite.

### 6. PR por repo

Uno por repo afectado, referenciando la story. CI en verde es requisito — está configurado
como bloqueante, no vas a poder mergear en rojo.

| Repo | Rama protegida | Checks requeridos | Quién puede mergear |
|---|---|---|---|
| `exactamente-backend` | `main`, `develop` | `quality`, `docker` | solo `juanpe44` |
| `exactamente-frontend` | `master` | `quality` | solo `juanpe44` |
| `exactamente-mcp` | `main` | `quality` | solo `juanpe44` |
| `exactamente-frontend-admin` | — | **sin protección** | cualquiera con write |

En los tres protegidos, `restrictions` limita el merge a `juanpe44` y `enforce_admins` está en
`true`: la protección aplica también a los admins del repo, incluido quien la configuró. Nadie
mergea en rojo, y los otros admins no mergean a la rama protegida aunque conserven el rol.

**Si no sos `juanpe44`, esto te afecta directo:** podés abrir PRs y el CI corre igual, pero el
botón de merge no va a estar disponible ni con todo en verde. Abrí el PR, avisá, y lo mergea él.
No es un problema de permisos mal puestos: es a propósito, porque mergear a `main` del backend
despliega a producción.

Consecuencia práctica: si un check requerido no llega a correr —típico en el backend, donde
`docker` puede no dispararse en un PR que no toca el build— el PR queda bloqueado y **no hay
bypass**. Se destraba haciendo que el check corra, no salteándolo.

**El admin es la excepción**, y no por decisión: es el único repo privado, y GitHub no permite
branch protection en repos privados fuera del plan Pro. El CI corre igual y falla igual, pero
nada impide mergear en rojo. Hasta que se resuelva —haciéndolo público o pagando Pro— ahí la
disciplina es manual: mirá el check antes de mergear.

En el cuerpo del PR: qué cambia, por qué, y cómo verificarlo.

### 7. Mergear en orden de dependencia

**backend (a `develop`) → release del backend (`develop` → `main`) → clientes.** Nunca al revés.

Acordate de lo que significa el release: llegar a `main` **despliega a producción**
automáticamente vía Dokploy, migraciones incluidas. No es un merge más.

Los clientes cortan versión cuando se mergea su Release PR; el backend, en su release. Ver
"Releases" en el `CONTRIBUTING.md`.

### 8. Cerrar

Borrá las ramas mergeadas. Los artefactos de la feature (retro, decisiones) quedan en
`_bmad-output/`, no dispersos por repo.

---

## Cuando una feature se da de baja

Pasa, y está bien que pase. Lo importante es no dejar código muerto ni perder el trabajo:

1. **Taggear antes de borrar**: `archive/<nombre-feature>` apuntando al último commit, pusheado.
   Recuperable para siempre, sin ensuciar la lista de ramas.
2. **Mirar qué más entró en esos commits.** Un commit rara vez es una sola feature. Antes de
   revertir, revisá archivo por archivo qué es de la feature que se va y qué no.
3. **Remoción quirúrgica, no `git revert`** del merge, salvo que hayas confirmado que el commit
   contenía únicamente esa feature.

Precedente: `archive/materias-agrupadas` (backend, frontend, admin). El commit del admin
mezclaba Subject Groups con detección de duplicados — un revert habría roto una feature viva.

---

## Convenciones de git

- Ramas: `<tu-usuario>/<nombre-descriptivo>` — tu usuario de GitHub
- Commits: Conventional Commits (`feat:`, `fix:`, `chore:`, `test:`, `docs:`, `refactor:`, `ci:`, `style:`)
- Autoría: la de tu `git config`. **No pasar `--author`** — cada uno firma lo suyo
- Ramas por defecto: `develop` en el backend, `master` en el frontend, `main` en admin y mcp
- Versión, tags y `CHANGELOG.md`: los maneja release-please, nunca a mano

