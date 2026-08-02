# Exactamente — Workspace

Plataforma donde estudiantes de ciencias exactas buscan y comparten recursos universitarios:
parciales, resúmenes y finales. Hoy en producción en **[exactamente.com.ar](https://exactamente.com.ar)**,
con Ingeniería en Sistemas (UBA Exactas) y el resto de las carreras en camino.

Este repositorio **no tiene código de producto**. Orquesta los 4 repos que sí lo tienen, y guarda
lo que es de todos: metodología, skills, configuración de agentes, planificación cross-repo.

---

## Arrancar

```bash
git clone git@github.com:exactamente-ar/exactamente-workspace.git exactamente
cd exactamente
./setup.sh
```

`setup.sh` verifica prerequisitos, clona los 4 repos, instala dependencias con el gestor correcto
de cada uno, crea los `.env` desde los `.env.example`, levanta PostgreSQL, aplica migraciones e
indexa CodeGraph. Es idempotente — corrélo las veces que quieras.

**Antes necesitás dos cosas:**

1. **Acceso de colaborador a la org `exactamente-ar`.** Sin eso, el clone del admin falla y el
   script se corta a la mitad. Ver [COLLABORATORS.md](COLLABORATORS.md).
2. **Las herramientas base:** `git`, `jq`, `bun`, `pnpm`, `node` 22+, `docker` y `python3`. El
   script las verifica y aborta con la lista de lo que falte. Opcional pero recomendado:
   `codegraph` (`npm i -g @colbymchenry/codegraph`).

Después completá los secretos que te haya listado y levantás lo que necesites:

| Repo | Comando | Puerto |
|---|---|---|
| `exactamente-backend` | `bun dev` | 3000 |
| `exactamente-frontend` | `pnpm dev` | 4321 |
| `exactamente-frontend-admin` | `pnpm dev` | 5173 |
| `exactamente-mcp` | `pnpm dev` | 3001 |

Solo el backend necesita Docker corriendo.

---

## Los 4 repos

| Repo | Qué es | Stack | Gestor | Rama | Deploy |
|---|---|---|---|---|---|
| [`exactamente-backend`](https://github.com/exactamente-ar/exactamente-backend) | API REST | Bun · Hono · Drizzle · PostgreSQL · R2 | bun | `main` | Dokploy (Hetzner) |
| [`exactamente-frontend`](https://github.com/exactamente-ar/exactamente-frontend) | Sitio público | Astro 5 + islands de React | pnpm | `master` | Vercel |
| [`exactamente-frontend-admin`](https://github.com/exactamente-ar/exactamente-frontend-admin) | Panel admin | React 19 + Vite | pnpm | `main` | Vercel |
| [`exactamente-mcp`](https://github.com/exactamente-ar/exactamente-mcp) | Servidor MCP | xmcp · Cloudflare Workers | pnpm | `main` | Cloudflare |

Dos cosas que se confunden seguido:

- **El frontend usa `master`, el resto `main`.** No es un error, es así.
- **El backend no usa pnpm, usa bun.** Correr `pnpm install` ahí rompe cosas.

Los 4 repos están en `.gitignore` — este workspace los clona pero no los versiona. No hay
submodules. Para operar sobre ellos desde la raíz, usá `-C`:

```bash
git -C exactamente-backend status
```

---

## ⚠️ Producción

**`main` del backend está en producción.** Dokploy buildea y redespliega solo al pushear: mergear
a `main` = deploy a `api.exactamente.com.ar`. No hay paso manual en el medio, y cada arranque
corre las migraciones pendientes.

`master` del frontend también es producción, pero Vercel da preview deploys y rollback de un
click — el riesgo es bastante menor.

Nada de push directo a ninguna de las dos. Todo por PR con CI en verde. El detalle está en
[CONTRIBUTING.md](CONTRIBUTING.md).

---

## Documentación

| Archivo | Qué responde |
|---|---|
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | Cómo colaborar: ramas, commits, PRs, gates. **Empezá acá.** |
| **[COLLABORATORS.md](COLLABORATORS.md)** | Quién es quién, qué permisos tiene cada uno, cómo pedir acceso |
| **[METODOLOGIA.md](METODOLOGIA.md)** | El ciclo completo de una feature que cruza repos, en detalle |
| **[AGENTS.md](AGENTS.md)** | Contexto para agentes de IA (Claude Code, Codex, Cursor) |

Cada repo de producto tiene además su propia documentación (`CLAUDE.md` o `AGENTS.md`) con sus
reglas y convenciones.

---

## Estructura

```
README.md            este archivo
CONTRIBUTING.md      cómo colaborar
COLLABORATORS.md     quién es quién
METODOLOGIA.md       el ciclo de una feature, de punta a punta
AGENTS.md            contexto para agentes de IA (CLAUDE.md es un symlink a este)
setup.sh             levanta todo en una máquina nueva
repos.json           mapa de los 4 repos (url, rama, gestor, puerto)
skills-lock.json     skills vendorizadas que no instala BMad
.claude/             skills compartidas, hooks y permisos del equipo
.mcp.json            servidores MCP del workspace (codegraph)
.codegraph/          índice de los 4 repos — gitignoreado, lo crea setup.sh
_bmad/               metodología BMad — instalación única, acá
_bmad-output/        PRDs, épicas, stories, artefactos de test
exactamente-*/       los 4 repos (ignorados, ver repos.json)
```
