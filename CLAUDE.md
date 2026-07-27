# Exactamente — Workspace

Este repo no tiene código de producto. Orquesta los 4 repos que sí lo tienen, y guarda
lo que es de todos: metodología, skills, config de agentes, planificación cross-repo.

**Setup en una máquina nueva:** `./setup.sh` — cloná este repo, corré eso, y queda todo levantado.

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

La única excepción razonable: una sesión de contenido/marketing puede arrancar en `content/`.

---

## Los 4 repos

| Repo | Qué es | Stack | PM | Dev | Rama | Deploy |
|---|---|---|---|---|---|---|
| `exactamente-backend` | API REST | Bun · Hono · Drizzle · PostgreSQL · R2 | bun | `:3000` | `main` | **Dokploy (Hetzner)** |
| `exactamente-frontend` | Sitio público | Astro 5 + islands de React | pnpm | `:4321` | `master` | Vercel |
| `exactamente-frontend-admin` | Panel admin | React 19 + Vite | pnpm | `:5173` | `main` | Vercel |
| `exactamente-mcp` | Servidor MCP | xmcp · Cloudflare Workers | pnpm | `:3001` | `main` | Cloudflare |

Ojo con dos cosas que se confunden seguido:

- **El frontend usa `master`, el resto `main`.** No es un error, es así.
- **El backend no usa pnpm, usa bun.** Correr `pnpm install` ahí rompe cosas.

Cada repo tiene su propia documentación (`CLAUDE.md` o `AGENTS.md`) con sus reglas, comandos y
convenciones. Se carga sola cuando tocás sus archivos — no la dupliques acá.

---

## ⚠️ Producción

**`main` del backend está en producción.** Dokploy buildea y redespliega **solo** al pushear.
No hay paso manual en el medio: mergear a `main` = deploy a `api.exactamente.com.ar`.

Consecuencias prácticas:

- Nada de push directo a `main`. Todo por PR, con CI en verde.
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

- Ramas: `juanpe44/<nombre-descriptivo>`
- Commits: [Conventional Commits](https://www.conventionalcommits.org/) — commitlint los valida
- Autoría: `--author="juanpe44 <juanpe44@users.noreply.github.com>"`

---

## Trabajar una feature que cruza repos

El detalle está en `METODOLOGIA.md`. Lo que no se negocia:

1. **El backend se mergea primero.** Ningún cliente mergea contra un contrato que no está en
   `main` del backend.
2. **Misma rama en cada repo afectado.** `juanpe44/<feature>` en los que toque.
3. **TDD**, con las reglas del repo donde estés parado.
4. **Un PR por repo**, con CI en verde.

---

## TODO — contrato de API compartido

El mismo shape está tipeado **a mano en 4 lugares**, sin nada que verifique que coincidan:

```
exactamente-backend/src/types
exactamente-frontend/src/shared/types  +  src/features/*/types
exactamente-frontend-admin/src/api/*.ts
exactamente-mcp/src/types
```

Por eso existe la regla de "backend primero": es la única protección contra el drift hoy.

Camino cuando se retome: el backend ya valida todo con Zod, así que `@hono/zod-openapi` expone
un `/openapi.json` y los 3 clientes generan tipos con `openapi-typescript`. Fuente única, sin
escribir tipos a mano.

---

## Estructura

```
CLAUDE.md            este archivo — contexto de desarrollo
METODOLOGIA.md       cómo se trabaja una feature, de punta a punta
setup.sh             levanta todo en una máquina nueva
repos.json           mapa de los 4 repos (url, rama, gestor, puerto)
.claude/skills/      skills compartidas + las de BMad
.mcp.json            servidores MCP del workspace (codegraph)
_bmad/               metodología BMad — instalación única, acá
_bmad-output/        PRDs, épicas, stories, artefactos de test
content/             community manager — tiene su propio CLAUDE.md
exactamente-*/        los 4 repos (ignorados, ver repos.json)
```
