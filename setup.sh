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

need git    "https://git-scm.com/"
need jq     "brew install jq"
need bun    "https://bun.sh/  (curl -fsSL https://bun.sh/install | bash)"
need pnpm   "https://pnpm.io/installation  (npm i -g pnpm)"
need node   "https://nodejs.org/  (v22, la misma que usa Vercel en producción)"
need docker "https://docs.docker.com/get-docker/  (para el PostgreSQL del backend)"

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
ok "git, jq, bun, pnpm, docker"

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

for i in $(seq 0 $((REPO_COUNT - 1))); do
  NAME="$(jq -r ".repos[$i].name" repos.json)"
  PM="$(jq   -r ".repos[$i].pm"   repos.json)"

  printf '  %s…%s %s (%s)\r' "$DIM" "$OFF" "$NAME" "$PM"
  case "$PM" in
    bun)  (cd "$NAME" && bun install  --frozen-lockfile >/dev/null 2>&1) ;;
    pnpm) (cd "$NAME" && pnpm install --frozen-lockfile >/dev/null 2>&1) ;;
    *)    die "Gestor desconocido '$PM' para $NAME (revisá repos.json)" ;;
  esac
  ok "$NAME $DIM($PM)$OFF                    "
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

  (cd exactamente-backend && bun db:migrate >/dev/null 2>&1) \
    && ok "migraciones aplicadas" \
    || warn "las migraciones fallaron — probá a mano: cd exactamente-backend && bun db:migrate"
else
  warn "Docker no está corriendo — arrancalo y después: cd exactamente-backend && docker compose up -d && bun db:migrate"
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
    El porqué está en CLAUDE.md. El flujo de trabajo, en METODOLOGIA.md.

EOF
