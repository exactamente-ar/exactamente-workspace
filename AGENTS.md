# Exactamente — Workspace

Este repo no tiene código de producto. Orquesta los 4 repos que sí lo tienen, y guarda
lo que es de todos: metodología, skills, config de agentes, planificación cross-repo.

> Este archivo es el contexto para agentes. `CLAUDE.md` es un symlink a este mismo archivo, así
> que Claude Code, Codex y Cursor leen todos lo mismo — editá `AGENTS.md`, nunca el symlink.
> Para humanos: [`README.md`](README.md), [`CONTRIBUTING.md`](CONTRIBUTING.md) y
> [`COLLABORATORS.md`](COLLABORATORS.md).

**Setup en una máquina nueva:** `./setup.sh` — cloná este repo, corré eso, y queda todo levantado.

Antes necesitás: `git`, `jq`, `bun`, `pnpm`, `node` 22+, `docker` y `python3`. El script los
verifica y aborta con la lista si falta alguno. Opcional pero recomendado: `codegraph`
(`npm i -g @colbymchenry/codegraph`) — sin él, el MCP declarado en `.mcp.json` arranca roto.

Los 5 repos son privados o públicos según el caso, pero todos se clonan igual: **pedí acceso de
colaborador a la org `exactamente-ar` antes de correr el setup**, o el clone del admin falla y el
script se corta a la mitad.

---

## Regla de oro: abrí Claude acá, no dentro de un repo

Siempre en la raíz del workspace. No es una preferencia, es cómo funciona la carga de contexto:

| Qué | Cómo se carga |
|---|---|
| `CLAUDE.md` de subdirectorio | **Bajo demanda**, al tocar archivos de ese subárbol |
| Skills de proyecto (`.claude/skills/`) | **Solo desde el cwd de arranque**, no se heredan |

O sea: abriendo acá tenés las skills del workspace **y** el contexto de cada repo cuando entrás a
sus archivos. Abriendo dentro de `exactamente-backend/` tenés su `CLAUDE.md`, pero perdés todas
las skills compartidas y BMad.

---

## Los 4 repos

| Repo | Qué es | Stack | PM | Dev | Rama | Deploy |
|---|---|---|---|---|---|---|
| `exactamente-backend` | API REST | Bun · Hono · Drizzle · PostgreSQL · R2 | bun | `:3000` | `develop` → `main` | **Dokploy (Hetzner)** |
| `exactamente-frontend` | Sitio público | Astro 5 + islands de React | pnpm | `:4321` | `master` | Vercel |
| `exactamente-frontend-admin` | Panel admin | React 19 + Vite | pnpm | `:5173` | `main` | Vercel |
| `exactamente-mcp` | Servidor MCP | xmcp · Cloudflare Workers | pnpm | `:3001` | `main` | Cloudflare |

Ojo con dos cosas que se confunden seguido:

- **El backend trabaja sobre `develop`; los clientes, directo sobre su rama principal** (`master`
  en el frontend, `main` en admin y mcp). Ver "Releases" más abajo.
- **El backend no usa pnpm, usa bun.** Correr `pnpm install` ahí rompe cosas.

Cada repo tiene su propia documentación (`CLAUDE.md` o `AGENTS.md`) con sus reglas, comandos y
convenciones. Se carga sola cuando tocás sus archivos — no la dupliques acá.

⚠️ **`exactamente-mcp` todavía no tiene la suya.** Ahí no se carga nada: hay que leerle el
`package.json` y el `lefthook.yml` antes de tocar código. Y su `README.md` dice `npm`, que en ese
repo rompe `gen:api` — usa pnpm como los otros dos clientes.

Los 4 comparten el mismo piso de calidad: prettier, eslint, typecheck, tests, lefthook,
commitlint y CI. Los comandos se llaman igual en todos (`test`, `lint`, `typecheck`,
`format:check`) aunque el runner cambie — `bun` en el backend, `pnpm` en el resto.

---

## ⚠️ Producción

**`main` del backend está en producción.** Dokploy buildea y redespliega **solo** al pushear.
No hay paso manual en el medio: mergear a `main` = deploy a `api.exactamente.com.ar`.

Consecuencias prácticas:

- Nada de push directo a `main`. Todo por PR, con CI en verde. A `main` solo llegan el PR de
  release (`develop` → `main`) y los hotfixes.
- El `Dockerfile` corre `bun run db:migrate` en cada arranque → **toda migración que llegue a
  `main` se auto-aplica en producción**. Pensá dos veces antes de agregar un `.sql`.
- El `Dockerfile` solo copia `src`, `scripts`, `drizzle.config.ts`, `tsconfig.json`,
  `package.json` y `bun.lock`. Tocar `package.json` **sí** afecta el build de producción; tocar
  configs de linting/hooks en la raíz del repo, no.
- Un script `prepare` que falle rompe el build entero (`bun install` lo ejecuta y no hay `.git`
  adentro del contenedor). Por eso está como `lefthook install || true`.

`master` del frontend también es producción, pero Vercel da preview deploys y rollback de un
click — el riesgo es bastante menor.

---

## Git

**Este workspace es su propio repo.** No es un paraguas: no hay submodules ni nada que
enganche los 4 repos. Están en `.gitignore`.

Desde la raíz, git opera sobre el workspace. Para los repos de producto, `-C`:

```bash
git -C exactamente-backend status
git -C exactamente-frontend log --oneline -5
```

Convenciones, en los 5 repos:

- Ramas: `<tu-usuario>/<nombre-descriptivo>` — tu usuario de GitHub, no el de otro. El prefijo
  existe para que mirando la lista de ramas se sepa quién tiene qué en vuelo.
- Commits: [Conventional Commits](https://www.conventionalcommits.org/) — commitlint los valida
- Autoría: la de tu `git config`. **No pasar `--author`**: los commits van a nombre de quien los
  escribe.

### Releases

Esquema híbrido: Git Flow liviano en el backend, GitHub Flow en los clientes. En backend, frontend y mcp,
[release-please](https://github.com/googleapis/release-please) mantiene un **Release PR** que sube
la versión y escribe `CHANGELOG.md` desde los Conventional Commits. Mergearlo crea el tag
`vX.Y.Z` y el GitHub Release. **Versión, tags y `CHANGELOG.md` no se editan a mano.**

| Repo | Ramas de trabajo salen de | Release PR sobre | Producción |
|---|---|---|---|
| backend | `develop` | `develop` | PR `develop` → `main`, con **merge commit** |
| frontend | `master` | `master` | mergear el PR de trabajo |
| mcp | `main` | `main` | mergear el PR de trabajo |
| admin | `main` | — **sin release-please** | mergear el PR de trabajo |

Hotfix del backend: rama desde `main` → PR a `main` → PR `main` → `develop` (obligatorio, o el
próximo release lo pisa). Detalle en `CONTRIBUTING.md`.

El workflow usa el secret de org `RELEASE_PLEASE_TOKEN`: la org no deja que Actions abra PRs con
`GITHUB_TOKEN`, y un PR abierto con ese token no dispararía el CI.

---

## Trabajar una feature que cruza repos

El detalle está en `METODOLOGIA.md`. Lo que no se negocia:

1. **El backend se releasea primero.** Ningún cliente mergea contra un contrato que no está en
   `main` del backend, y al backend se llega por `develop` → `main`: mergear a `develop` no
   alcanza.
2. **Misma rama en cada repo afectado.** `<tu-usuario>/<feature>` en los que toque.
3. **TDD**, con las reglas del repo donde estés parado.
4. **Un PR por repo**, con CI en verde.

---

## El contrato de la API

El backend publica su contrato y los 3 clientes generan sus tipos desde ahí. **Nadie escribe a
mano los tipos de la API.**

| Dónde | Qué |
|---|---|
| `exactamente-backend/src/schemas/` | La fuente: ~12 entidades en Zod |
| `exactamente-backend/openapi.json` | El spec generado, versionado |
| `/docs` y `/openapi.json` | La referencia navegable, servida por el backend |
| `<cliente>/src/**/api.d.ts` | Los tipos generados, versionados |

### Cambiar la forma de una respuesta

```bash
# 1. editás el schema en exactamente-backend/src/schemas/
cd exactamente-backend && bun run gen:openapi     # y commiteás openapi.json

# 2. en cada cliente afectado
cd ../exactamente-frontend-admin && pnpm gen:api  # y arreglás lo que TS marque
```

**Los dos pasos, o el CI de alguno de los cuatro repos se pone en rojo.** `check:openapi` en el
backend y `check:api` en cada cliente fallan si lo commiteado no coincide con lo generado. Eso
convierte el olvido en imposible, en vez de improbable.

El orden "backend primero" ya no es solo disciplina: los clientes leen el spec del `main` del
backend, así que no pueden mergear contra un contrato que todavía no está releaseado. Una épica
con cambio de contrato necesita un release del backend a mitad de camino.

Hay un hook que avisa en el momento: al editar `src/schemas/`, si `openapi.json` quedó atrás,
`.claude/hooks/openapi-drift.sh` lo dice sin esperar al CI. Se apaga solo al regenerar.

### Cómo se engancha cada cliente

- **`admin`** y **`mcp`**: alias directos, sus tipos eran un espejo de la API.
- **`frontend`**: `Pick` de los campos que usa. Sus tipos son view models que mezclan datos de
  la API con datos locales (las correlativas salen de constantes del repo), así que un alias
  completo mezclaría dominios. La garantía es la misma.

### Lo que esto NO garantiza

Que el schema coincida con lo que el handler **devuelve de verdad**. `hono-openapi` no compara
el `c.json()` contra el schema declarado: si escribís mal un schema, el contrato queda coherente
entre los 4 repos y equivocado en los 4.

Cerrarlo requiere tests de contrato — levantar la app en CI con un postgres de servicio, pegarle
a cada endpoint y validar la respuesta real. Pendiente.

---

## CodeGraph — el único índice que cruza los 4 repos

`.codegraph/` en la raíz indexa **los 4 repos juntos** en un grafo de símbolos. Es la única
herramienta del workspace que los ve como una sola cosa: `grep` no cruza fronteras de repo, y
`Read` te obliga a saber de antemano qué archivo abrir.

**Antes de grep/find/Read, `codegraph_explore`.** Una llamada devuelve el código fuente verbatim
de los símbolos relevantes agrupado por archivo, más quién los llama.

### Para qué sirve acá, concretamente

Antes de cambiar un schema en `exactamente-backend/src/schemas/`, preguntale por el símbolo. Te
da los consumidores **en los 3 clientes**, no solo en el backend. Ese es el paso que hoy se hace
a ojo y es la causa de que un cambio de contrato aparezca roto recién en el CI de otro repo.

```bash
codegraph explore "ResourceSchema AdminResource"   # CLI, mismo output que el MCP
codegraph status                                    # 345 archivos, 4 repos
```

Devuelve además un "blast radius" por símbolo, con aviso cuando algo no tiene tests que lo cubran.

### Dos reglas

- **No indexar por repo.** El índice de la raíz ya los incluye. Uno local queda viejo, y gana por
  cwd sobre el bueno — ya pasó con `exactamente-frontend`.
- El índice se regenera y pesa ~9 MB: está gitignoreado. `setup.sh` lo crea en una máquina nueva.

---

## Estructura

```
AGENTS.md            este archivo — contexto de desarrollo para agentes
CLAUDE.md            symlink a AGENTS.md
README.md            qué es Exactamente y cómo levantarlo — entrada para humanos
CONTRIBUTING.md      cómo colaborar: ramas, commits, PRs, gates
COLLABORATORS.md     quién es quién, permisos, cómo pedir acceso
METODOLOGIA.md       cómo se trabaja una feature, de punta a punta
setup.sh             levanta todo en una máquina nueva
repos.json           mapa de los 4 repos (url, rama, gestor, puerto)
skills-lock.json     skills vendorizadas que no instala BMad — setup.sh verifica sus hashes
.claude/skills/      skills compartidas + las de BMad; propias: exactamente-publish-stories
                     (épica BMad → issues en el tablero) y exactamente-take-issue (tomar un issue)
_bmad/custom/        overrides de equipo de BMad (las stories salen publicables)
.claude/settings.json  permisos de codegraph + superpowers off (BMad es la metodología acá)
.claude/hooks/       avisos automáticos — hoy solo el drift de openapi.json
.mcp.json            servidores MCP del workspace (codegraph)
.codegraph/          índice de los 4 repos — gitignoreado, lo crea setup.sh
_bmad/               metodología BMad — instalación única, acá
_bmad-output/        PRDs, épicas, stories, artefactos de test
exactamente-*/        los 4 repos (ignorados, ver repos.json)
```
