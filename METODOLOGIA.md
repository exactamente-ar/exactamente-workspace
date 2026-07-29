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

### 1. Planificar — en el workspace

Desde la raíz, con BMad. El PRD y las stories quedan en `_bmad-output/planning-artifacts/`.

Cada story tiene que declarar **qué repos toca**. Es la información que evita descubrir a
mitad de camino que faltaba media feature en otro lado.

Para algo chico (un fix, un ajuste de copy) esto es innecesario. Se planifica lo que cruza
repos o lo que tiene más de un par de pasos.

### 2. Rama — el mismo nombre en cada repo

```bash
git -C exactamente-backend  checkout -b juanpe44/materias-por-plan
git -C exactamente-frontend checkout -b juanpe44/materias-por-plan
```

Mismo nombre = mirás la lista de ramas de cualquier repo y sabés qué está en vuelo.

### 3. Implementar — backend primero, siempre

**El contrato de la API se define y se mergea en `main` del backend antes de que cualquier
cliente lo consuma.**

Esto ya no depende de que te acuerdes. Si tu feature cambia una respuesta:

```bash
cd exactamente-backend && bun run gen:openapi   # commiteá openapi.json
cd ../exactamente-frontend-admin && pnpm gen:api  # arreglá lo que TS marque
```

Los clientes leen el spec del `main` del backend, así que su CI falla si intentás mergear
contra un contrato que todavía no está mergeado. Y si cambiaste el código del backend sin
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
| `exactamente-backend` | `main` | `quality`, `docker` | solo `juanpe44` |
| `exactamente-frontend` | `master` | `quality` | solo `juanpe44` |
| `exactamente-mcp` | `main` | `quality` | solo `juanpe44` |
| `exactamente-frontend-admin` | — | **sin protección** | cualquiera con write |

En los tres protegidos, `restrictions` limita el merge a `juanpe44` y `enforce_admins` está en
`true`: la protección aplica también a los admins del repo, incluido quien la configuró. Nadie
mergea en rojo, y los otros dos admins (`d4rm5`, `OliverioBPapuccioF`) no mergean a la rama
protegida aunque conserven el rol.

Consecuencia práctica: si un check requerido no llega a correr —típico en el backend, donde
`docker` puede no dispararse en un PR que no toca el build— el PR queda bloqueado y **no hay
bypass**. Se destraba haciendo que el check corra, no salteándolo.

**El admin es la excepción**, y no por decisión: es el único repo privado, y GitHub no permite
branch protection en repos privados fuera del plan Pro. El CI corre igual y falla igual, pero
nada impide mergear en rojo. Hasta que se resuelva —haciéndolo público o pagando Pro— ahí la
disciplina es manual: mirá el check antes de mergear.

En el cuerpo del PR: qué cambia, por qué, y cómo verificarlo.

### 7. Mergear en orden de dependencia

**backend → clientes.** Nunca al revés.

Acordate de lo que significa en el backend: mergear a `main` **despliega a producción**
automáticamente vía Dokploy. No es un merge más.

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

- Ramas: `juanpe44/<nombre-descriptivo>`
- Commits: Conventional Commits (`feat:`, `fix:`, `chore:`, `test:`, `docs:`, `refactor:`, `ci:`, `style:`)
- Autoría: `--author="juanpe44 <juanpe44@users.noreply.github.com>"`
- Ramas por defecto: `master` en el frontend, `main` en los otros tres

---

## Contenido y comunidad

`content/` tiene su propio `CLAUDE.md` con el rol de community manager. Está en este repo
porque es parte del proyecto, pero no se mezcla con el desarrollo: si vas a trabajar
contenido, abrí Claude directamente en `content/`.
