#!/usr/bin/env bash
#
# Levanta el workspace de Exactamente desde cero.
#
#   git clone https://github.com/exactamente-ar/exactamente-workspace.git
#   cd exactamente-workspace
#   ./setup.sh
#
# Idempotente: si un repo ya está clonado hace fetch en vez de re-clonar,
# así que se puede correr las veces que haga falta.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# ─── Salida ──────────────────────────────────────────────────────────────────

if [ -t 1 ]; then
  BOLD=$'\033[1m'; RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; DIM=$'\033[2m'; OFF=$'\033[0m'
else
  BOLD=''; RED=''; GREEN=''; YELLOW=''; DIM=''; OFF=''
fi

step() { printf '\n%s==>%s %s%s%s\n' "$BOLD" "$OFF" "$BOLD" "$1" "$OFF"; }
ok()   { printf '  %s✓%s %s\n' "$GREEN" "$OFF" "$1"; }
warn() { printf '  %s!%s %s\n' "$YELLOW" "$OFF" "$1"; }
die()  { printf '\n%serror:%s %s\n\n' "$RED" "$OFF" "$1" >&2; exit 1; }

# ─── Prerequisitos ───────────────────────────────────────────────────────────

step "Verificando prerequisitos"

MISSING=()
need() { command -v "$1" >/dev/null 2>&1 || MISSING+=("$1  → $2"); }

need git     "https://git-scm.com/"
need jq      "brew install jq"
need bun     "https://bun.sh/  (curl -fsSL https://bun.sh/install | bash)"
need pnpm    "https://pnpm.io/installation  (npm i -g pnpm)"
need node    "https://nodejs.org/  (v22, la misma que usa Vercel en producción)"
need docker  "https://docs.docker.com/get-docker/  (para el PostgreSQL del backend)"
# Casi todas las skills de BMad resuelven su config con scripts de _bmad/scripts/*.py.
# Ojo: piden python3, no `python` — en macOS `python` a secas no existe.
need python3 "https://www.python.org/downloads/  (lo usan las skills de BMad)"

if [ ${#MISSING[@]} -gt 0 ]; then
  printf '\n%sFaltan estas herramientas:%s\n\n' "$BOLD" "$OFF"
  printf '  %s\n' "${MISSING[@]}"
  die "Instalalas y volvé a correr ./setup.sh"
fi

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$NODE_MAJOR" -lt 22 ]; then
  warn "Node $NODE_MAJOR — producción usa 22. Puede haber diferencias en el build."
else
  ok "node v$(node -p 'process.versions.node')"
fi
ok "git, jq, bun, pnpm, docker, python3"

# codegraph no bloquea: sin él los repos levantan igual, solo se pierde el índice
# cross-repo. Pero .mcp.json lo declara, así que si falta el MCP arranca roto.
if command -v codegraph >/dev/null 2>&1; then
  ok "codegraph $DIM($(codegraph --version 2>/dev/null || echo '?'))$OFF"
  HAS_CODEGRAPH=1
else
  HAS_CODEGRAPH=0
  warn "codegraph no está instalado — .mcp.json lo declara y va a fallar al levantar"
  warn "  instalalo con: npm i -g @colbymchenry/codegraph"
fi

# ─── Clonar / actualizar los repos ───────────────────────────────────────────

step "Clonando los repos de producto"

REPO_COUNT="$(jq '.repos | length' repos.json)"

for i in $(seq 0 $((REPO_COUNT - 1))); do
  NAME="$(jq -r ".repos[$i].name"   repos.json)"
  URL="$(jq  -r ".repos[$i].url"    repos.json)"
  BRANCH="$(jq -r ".repos[$i].branch" repos.json)"

  if [ -d "$NAME/.git" ]; then
    git -C "$NAME" fetch --prune --quiet
    ok "$NAME $DIM(ya estaba — fetch)$OFF"
  else
    git clone --quiet --branch "$BRANCH" "$URL" "$NAME"
    ok "$NAME $DIM(clonado en $BRANCH)$OFF"
  fi
done

# ─── Dependencias ────────────────────────────────────────────────────────────

step "Instalando dependencias"

LOG_DIR="$(mktemp -d)"

for i in $(seq 0 $((REPO_COUNT - 1))); do
  NAME="$(jq -r ".repos[$i].name" repos.json)"
  PM="$(jq   -r ".repos[$i].pm"   repos.json)"
  LOG="$LOG_DIR/$NAME.log"

  case "$PM" in
    bun|pnpm) ;;
    *) die "Gestor desconocido '$PM' para $NAME (revisá repos.json)" ;;
  esac

  printf '  %s…%s %s (%s)\r' "$DIM" "$OFF" "$NAME" "$PM"

  # --frozen-lockfile es lo correcto: instala exactamente lo que dice el
  # lockfile. Si el lockfile falta o quedó desactualizado, NO lo resolvemos
  # por atrás: instalar algo distinto a lo que corre en CI es peor que fallar.
  if (cd "$NAME" && "$PM" install --frozen-lockfile) >"$LOG" 2>&1; then
    ok "$NAME $DIM($PM)$OFF                    "
  else
    printf '\n'
    printf '  %s✗%s %s%s falló al instalar%s\n\n' "$RED" "$OFF" "$BOLD" "$NAME" "$OFF"
    sed 's/^/      /' "$LOG" | tail -20
    printf '\n'
    die "Arreglá eso y volvé a correr ./setup.sh  ${DIM}(log completo: $LOG)${OFF}"
  fi
done

# ─── Archivos de entorno ─────────────────────────────────────────────────────

step "Preparando archivos .env"

NEEDS_ENV=()

for i in $(seq 0 $((REPO_COUNT - 1))); do
  NAME="$(jq -r ".repos[$i].name" repos.json)"

  if [ -f "$NAME/.env" ]; then
    ok "$NAME/.env $DIM(ya existe, no se toca)$OFF"
  elif [ -f "$NAME/.env.example" ]; then
    cp "$NAME/.env.example" "$NAME/.env"
    ok "$NAME/.env $DIM(creado desde .env.example)$OFF"
    NEEDS_ENV+=("$NAME")
  else
    warn "$NAME no tiene .env.example — configuralo a mano si lo necesita"
  fi
done

# ─── Base de datos del backend ───────────────────────────────────────────────

step "Base de datos del backend"

if docker info >/dev/null 2>&1; then
  (cd exactamente-backend && docker compose up -d >/dev/null 2>&1)

  # El contenedor tarda unos segundos en aceptar conexiones.
  for _ in $(seq 1 30); do
    if (cd exactamente-backend && docker compose exec -T postgres pg_isready -U postgres >/dev/null 2>&1); then
      break
    fi
    sleep 1
  done

  ok "PostgreSQL levantado"

  # unaccent: requerida para la búsqueda de materias sin acentos.
  (cd exactamente-backend && docker compose exec -T postgres \
    psql -U postgres -d exactamente -c "CREATE EXTENSION IF NOT EXISTS unaccent;" >/dev/null 2>&1) \
    && ok "extensión unaccent habilitada" \
    || warn "no se pudo habilitar unaccent — corré: docker compose exec postgres psql -U postgres -d exactamente -c 'CREATE EXTENSION IF NOT EXISTS unaccent;'"

  if (cd exactamente-backend && bun db:migrate) >"$LOG_DIR/migrate.log" 2>&1; then
    ok "migraciones aplicadas"
  else
    warn "las migraciones fallaron:"
    sed 's/^/      /' "$LOG_DIR/migrate.log" | tail -10
    warn "reintentá con: cd exactamente-backend && bun db:migrate"
  fi
else
  warn "Docker no está corriendo — arrancalo y después: cd exactamente-backend && docker compose up -d && bun db:migrate"
fi

# ─── Índice de CodeGraph ─────────────────────────────────────────────────────

step "Índice de CodeGraph"

if [ "$HAS_CODEGRAPH" = "1" ]; then
  # Se indexa desde la raíz a propósito: así el grafo cubre los 4 repos a la vez
  # y se puede preguntar por los consumidores de un schema del backend en los
  # clientes. Un .codegraph/ dentro de un repo gana por cwd y queda desactualizado.
  if [ -d .codegraph ]; then
    if codegraph sync >"$LOG_DIR/codegraph.log" 2>&1; then
      ok "índice sincronizado $DIM(ya existía)$OFF"
    else
      warn "el sync falló — reintentá con: codegraph sync"
    fi
  else
    printf '  %s…%s indexando los 4 repos (tarda un rato la primera vez)\r' "$DIM" "$OFF"
    if codegraph init . >"$LOG_DIR/codegraph.log" 2>&1; then
      ok "índice creado                                                    "
    else
      printf '\n'
      warn "no se pudo indexar:"
      sed 's/^/      /' "$LOG_DIR/codegraph.log" | tail -10
      warn "reintentá con: codegraph init ."
    fi
  fi

  for r in exactamente-backend exactamente-frontend exactamente-frontend-admin exactamente-mcp; do
    [ -d "$r/.codegraph" ] && warn "$r tiene su propio .codegraph/ — gana por cwd y queda viejo; borralo"
  done
else
  warn "sin codegraph, sin índice — los agentes caen a grep y pierden la vista cross-repo"
fi

# ─── Skills vendorizadas ─────────────────────────────────────────────────────

step "Verificando skills vendorizadas"

# skills-lock.json declara las skills de .claude/skills/ que NO instala BMad.
# Vienen con el clone: acá solo se comprueba que sigan siendo las que se anotaron.
SKILL_DRIFT=0

while IFS=$'\t' read -r SKILL_NAME SKILL_SHA; do
  SKILL_FILE=".claude/skills/$SKILL_NAME/SKILL.md"

  if [ ! -f "$SKILL_FILE" ]; then
    warn "$SKILL_NAME falta $DIM(declarada en skills-lock.json)$OFF"
    SKILL_DRIFT=1
    continue
  fi

  ACTUAL="$(shasum -a 256 "$SKILL_FILE" | cut -d' ' -f1)"
  if [ "$ACTUAL" = "$SKILL_SHA" ]; then
    ok "$SKILL_NAME"
  else
    warn "$SKILL_NAME cambió desde que se anotó su hash — revisalo antes de actualizarla"
    SKILL_DRIFT=1
  fi
done < <(jq -r '.skills | to_entries[] | "\(.key)\t\(.value.sha256)"' skills-lock.json)

if [ "$SKILL_DRIFT" = "1" ]; then
  warn "si los cambios son a propósito, actualizá los hashes en skills-lock.json"
fi

# ─── Listo ───────────────────────────────────────────────────────────────────

step "Listo"

if [ ${#NEEDS_ENV[@]} -gt 0 ]; then
  printf '\n  %sCompletá los secretos en estos .env antes de arrancar:%s\n' "$BOLD" "$OFF"
  for r in "${NEEDS_ENV[@]}"; do printf '    %s/.env\n' "$r"; done
  printf '  %s(los .example traen placeholders, no credenciales reales)%s\n' "$DIM" "$OFF"
fi

cat <<EOF

  ${BOLD}Levantar cada servicio${OFF} ${DIM}(una terminal por cada uno)${OFF}

    cd exactamente-backend        && bun dev     ${DIM}→ :3000${OFF}
    cd exactamente-frontend       && pnpm dev    ${DIM}→ :4321${OFF}
    cd exactamente-frontend-admin && pnpm dev    ${DIM}→ :5173${OFF}
    cd exactamente-mcp            && pnpm dev    ${DIM}→ :3001${OFF}

  ${BOLD}Trabajar con Claude${OFF}

    Abrí Claude ${BOLD}en esta carpeta${OFF}, no dentro de un repo.
    El porqué está en AGENTS.md. El flujo de trabajo, en CONTRIBUTING.md.

  ${BOLD}Si es tu primera vez acá${OFF}

    README.md  → qué es esto           CONTRIBUTING.md → cómo colaborar
    COLLABORATORS.md → quién es quién  METODOLOGIA.md  → el detalle completo

EOF
