# Cómo colaborar

Cuatro repos separados, una sola forma de tocarlos. Esta es la versión corta y operativa; el
ciclo completo con los porqués está en [METODOLOGIA.md](METODOLOGIA.md).

---

## Antes de tu primer commit

1. **Pedí acceso** a la org `exactamente-ar` — ver [COLLABORATORS.md](COLLABORATORS.md).
2. **Corré `./setup.sh`** desde la raíz del workspace. Ver [README.md](README.md).
3. **Configurá tu identidad de git** en cada repo, o global:
   ```bash
   git config --global user.name  "Tu Nombre"
   git config --global user.email "tu-usuario@users.noreply.github.com"
   ```
   Los commits van a nombre de quien los escribe. **No pases `--author`.**
4. **Sumate a [COLLABORATORS.md](COLLABORATORS.md)** en tu primer PR al workspace.

---

## Qué hay para hacer

Todo está en el **[tablero del proyecto](https://github.com/orgs/exactamente-ar/projects/2)**.

- **Para tomar algo:** elegí un issue en **Ready** (si es tu primera vez, buscá
  `good first issue`), comentá que lo tomás y esperá a que te lo asignen. Así no hay dos
  personas haciendo lo mismo. Con un agente: `/exactamente-take-issue` desde la raíz del
  workspace lo lista, te lo asigna, crea la rama y te arma el contexto — no implementa, eso lo
  arrancás vos.
- **Si planificaste algo con BMad:** `/exactamente-publish-stories` sube la épica y sus stories
  como issues. Cualquiera puede publicar; lo tuyo entra en **Inbox** y un maintainer lo prioriza.
- **Si tenés una idea o encontraste un bug:** abrí un issue con el template que corresponda.
  Entra en **Inbox**; si se acepta pasa a **Backlog**, y se refina antes de llegar a **Ready**.
- **Algo en `needs-discussion`** todavía no tiene una decisión tomada: opiná en el issue, pero no
  arranques a codear.

Cómo se decide el tamaño de cada cosa (bug, feature, épica) está en
[METODOLOGIA.md](METODOLOGIA.md#1-planificar--en-el-workspace-publicar-en-el-tablero).

---

## Regla de oro: abrí tu agente en la raíz del workspace

Si usás Claude Code, Codex o Cursor, abrilos **acá**, no dentro de un repo. No es preferencia:
las skills de proyecto se cargan solo desde el directorio donde arrancaste, mientras que el
contexto de cada repo se carga solo al tocar sus archivos. Desde la raíz tenés las dos cosas;
desde adentro de un repo perdés las skills compartidas y BMad.

---

## El ciclo

### 1. Rama — el mismo nombre en cada repo que toques

```bash
git -C exactamente-backend  checkout -b <tu-usuario>/materias-por-plan origin/develop
git -C exactamente-frontend checkout -b <tu-usuario>/materias-por-plan origin/master
```

En el backend, desde **`develop`**. En los clientes, desde su rama principal. Ver
[Releases](#releases).

El prefijo es **tu** usuario de GitHub. Mismo nombre en cada repo = mirando la lista de ramas de
cualquiera sabés qué está en vuelo y de quién.

### 2. Backend primero, siempre

**El contrato de la API tiene que estar en `main` del backend antes de que cualquier cliente lo
consuma.** En el backend eso significa release (`develop` → `main`): mergear a `develop` no
alcanza, porque el `check:api` de los clientes lee el spec de `main`. Nadie escribe a mano los tipos de la API: el backend publica el spec y los
3 clientes generan sus tipos desde ahí.

Si tu cambio toca la forma de una respuesta:

```bash
cd exactamente-backend && bun run gen:openapi      # y commiteás openapi.json
cd ../exactamente-frontend-admin && pnpm gen:api   # y arreglás lo que TS marque
```

Los dos pasos, o el CI de alguno de los cuatro repos se pone en rojo. Esto no depende de que te
acuerdes: `check:openapi` en el backend y `check:api` en cada cliente fallan si lo commiteado no
coincide con lo generado.

### 3. TDD

Test que falla primero, y **verlo fallar**. Después el código mínimo para que pase. Un test que
pasa de entrada no probó nada — puede estar verde porque la aserción es trivial, porque el mock
devuelve lo que espera, o porque no ejecuta lo que creés.

Las reglas concretas son las del repo donde estés parado; están en su `CLAUDE.md` / `AGENTS.md`.

### 4. Commits — Conventional Commits

`feat:`, `fix:`, `chore:`, `test:`, `docs:`, `refactor:`, `ci:`, `style:`. Commitlint los valida
en el hook, así que un mensaje mal formado no llega ni a la rama.

### 5. Los gates corren solos

En los 4 repos, sin que tengas que acordarte:

| Cuándo | Qué |
|---|---|
| `commit` | prettier sobre los staged, eslint, tests afectados |
| mensaje de commit | commitlint |
| `push` | typecheck + suite completa |
| PR | CI: typecheck, lint, format:check, test, build |

El backend suma un job de `docker build`, porque `main` despliega a producción.

Si un hook te molesta, arreglá la causa. `--no-verify` es para emergencias reales.

**Tus tests no pueden depender de tu `.env`.** Se comprueba fácil: movés el `.env` fuera del repo
y corrés la suite. Si agregás una variable obligatoria, agregala también al setup de tests y al
`.env.example` — en el mismo PR.

### 6. Un PR por repo afectado

En el cuerpo: qué cambia, por qué, y cómo verificarlo. CI en verde es requisito bloqueante.

### 7. Mergear en orden de dependencia

**backend → release del backend → clientes.** Nunca al revés. Y acordate de lo que significa el
release: llegar a `main` despliega a `api.exactamente.com.ar` automáticamente. No es un merge más.

### 8. Cerrar

Borrá las ramas mergeadas. Los artefactos de la feature quedan en `_bmad-output/`.

---

## Quién puede mergear

| Repo | Rama protegida | Checks requeridos | Quién mergea |
|---|---|---|---|
| `exactamente-backend` | `main`, `develop` | `quality`, `docker` | solo `juanpe44` |
| `exactamente-frontend` | `master` | `quality` | solo `juanpe44` |
| `exactamente-mcp` | `main` | `quality` | solo `juanpe44` |
| `exactamente-frontend-admin` | — | **sin protección** | cualquiera con write |

**Si no sos `juanpe44`:** podés abrir PRs y el CI corre igual, pero el botón de merge no va a
estar disponible ni con todo en verde. Abrí el PR, avisá, y lo mergea él. No es un permiso mal
puesto — es a propósito, porque mergear a `main` del backend despliega a producción.

El admin es la excepción y no por decisión: es el único repo privado, y GitHub no permite branch
protection en repos privados fuera del plan Pro. El CI corre y falla igual, pero nada impide
mergear en rojo. Ahí la disciplina es manual: **mirá el check antes de mergear.**

---

## Releases

Esquema híbrido. El backend usa Git Flow liviano, porque su `main` despliega a producción con
migraciones incluidas y conviene que eso sea un acto aparte. Los clientes usan GitHub Flow: Vercel
y Cloudflare ya dan previews y rollback.

En los 4, [release-please](https://github.com/googleapis/release-please) mantiene abierto un
**Release PR** (`chore(<rama>): release X.Y.Z`) que acumula el `CHANGELOG.md` y sube la versión
según los commits:

| Commit | Versión |
|---|---|
| `fix:` | patch — `1.2.3` → `1.2.4` |
| `feat:` | minor — `1.2.3` → `1.3.0` |
| `feat!:` o footer `BREAKING CHANGE:` | major — `1.2.3` → `2.0.0` |

Mergear el Release PR crea el tag `vX.Y.Z` y el GitHub Release. **Versión, tags y
`CHANGELOG.md` no se tocan a mano.**

### Clientes (frontend, admin, mcp)

La rama sale de `master`/`main` y el PR vuelve ahí. Cuando quieras cortar versión, mergeás el
Release PR. Nada más.

### Backend

| Rama | Sale de | PR a | Para qué |
|---|---|---|---|
| `<tu-usuario>/<feature>` | `develop` | `develop` | Features y fixes normales |
| `develop` | — | `main` | Release: lo que llega a producción |
| `<tu-usuario>/<hotfix>` | `main` | `main` | Hotfix urgente de producción |

**Release:**

1. Mergear el Release PR en `develop` → queda el tag.
2. PR `develop` → `main`, mergeado con **merge commit** (nunca squash ni rebase: el commit del
   tag tiene que quedar en la historia de `main`). Eso despliega.

**Hotfix:** solo para algo roto en producción que no puede esperar lo que hay en `develop`.

1. Rama desde `main`, PR a `main`. Al mergear, despliega.
2. PR `main` → `develop` con merge commit. **No es opcional**: sin él, el próximo release no
   trae el fix y lo pisa.

El hotfix no tiene tag propio: sale en el CHANGELOG del próximo release.

### El token

El workflow usa el secret de org `RELEASE_PLEASE_TOKEN`, un PAT con `contents` y
`pull-requests` en escritura sobre los 4 repos. `GITHUB_TOKEN` no sirve por dos motivos: la org
no deja que Actions abra PRs, y un PR abierto con ese token no dispara el CI, así que el Release
PR quedaría trabado por los checks requeridos.

**Excepción: el admin.** Es privado y el plan Free no comparte secrets de org con repos privados,
así que ahí el mismo token se carga como secret **del repo**:
`gh secret set RELEASE_PLEASE_TOKEN -R exactamente-ar/exactamente-frontend-admin`. Y el token tiene
que incluir ese repo en *Repository access*: si no, el workflow falla con `Not Found`. Al rotar el
token, actualizá el secret de org **y** el del admin.

---

## Antes de cambiar algo compartido

`.codegraph/` indexa **los 4 repos juntos** en un grafo de símbolos. Es lo único en el workspace
que los ve como una sola cosa — `grep` no cruza fronteras de repo.

Antes de tocar un schema en `exactamente-backend/src/schemas/`, preguntale por el símbolo: te da
los consumidores en los 3 clientes, no solo en el backend.

```bash
codegraph explore "ResourceSchema AdminResource"
```

Una regla: **no indexes por repo.** El índice de la raíz ya los incluye; uno local queda viejo y
gana por cwd sobre el bueno.

---

## Qué no versionamos

- Los 4 repos de producto — tienen el suyo, están en `.gitignore`
- `.env` y cualquier secreto. Los `.env.example` sí, y son la fuente de verdad
- `.claude/settings.local.json` y `_bmad/config.user.toml` — config personal
- `.codegraph/` — se regenera, pesa ~9 MB
- `content/` — material de marca, no de desarrollo
