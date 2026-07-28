#!/usr/bin/env bash
#
# Avisa cuando se toca un schema del backend y openapi.json queda atrás.
#
# El contrato es el invariante más frágil del workspace: editar src/schemas/ sin
# regenerar deja el spec desactualizado, y eso no se descubre hasta que el CI de
# alguno de los cuatro repos se pone en rojo. Este hook lo dice en el momento.
#
# Se apaga solo: en cuanto openapi.json es más nuevo que el schema, no dice nada.
#
# Entrada: JSON de PostToolUse por stdin. Salida: JSON con additionalContext, o nada.

set -euo pipefail

INPUT="$(cat)"
FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')"

[ -n "$FILE" ] || exit 0

# Solo los schemas de salida del backend. src/validators/ es entrada y no toca el spec.
case "$FILE" in
  */exactamente-backend/src/schemas/*) ;;
  *) exit 0 ;;
esac

BACKEND="${FILE%%/src/schemas/*}"
SPEC="$BACKEND/openapi.json"

# Sin spec todavía no hay nada que comparar.
[ -f "$SPEC" ] || exit 0
[ -f "$FILE" ] || exit 0

mtime() { stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null; }

SPEC_AT="$(mtime "$SPEC")"
FILE_AT="$(mtime "$FILE")"

[ -n "$SPEC_AT" ] && [ -n "$FILE_AT" ] || exit 0
[ "$FILE_AT" -gt "$SPEC_AT" ] || exit 0

jq -n --arg f "${FILE##*/}" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: (
      "Tocaste \($f) y openapi.json quedó atrás. El contrato se propaga a mano:\n" +
      "  cd exactamente-backend && bun run gen:openapi   # y commiteá openapi.json\n" +
      "  cd <cliente> && pnpm gen:api                    # en cada cliente afectado\n" +
      "Sin eso, check:openapi en el backend y check:api en los clientes fallan en CI.\n" +
      "Para saber qué clientes toca: codegraph_explore sobre el símbolo que cambiaste."
    )
  }
}'
