#!/usr/bin/env bash
# PostToolUse hook: runs WPCS on the file just written/edited
# Exit 0 = no issues or only warnings (continue) | non-zero = errors found (shown to user)

set -uo pipefail

# Read the tool input JSON from stdin
INPUT=$(cat)

# Pick a JSON parser that actually works (Windows Store `python3` stub is on PATH
# but non-functional, so probe before trusting it).
PY=""
for c in python3 python; do
  if command -v "$c" >/dev/null 2>&1 && printf '{}' | "$c" -c 'import json,sys; json.load(sys.stdin)' >/dev/null 2>&1; then
    PY="$c"
    break
  fi
done

# Extract the edited file path — prefer jq, fall back to python, then skip.
if command -v jq >/dev/null 2>&1; then
  FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.path // .tool_input.file_path // ""' 2>/dev/null || echo "")
elif [ -n "$PY" ]; then
  FILE=$(printf '%s' "$INPUT" | "$PY" -c 'import sys,json; d=json.load(sys.stdin).get("tool_input",{}); print(d.get("path") or d.get("file_path") or "")' 2>/dev/null || echo "")
else
  exit 0
fi

# Only run on PHP files
if [ -z "$FILE" ] || [[ "$FILE" != *.php ]]; then
  exit 0
fi

# Don't check vendor files
if echo "$FILE" | grep -qE "vendor/|node_modules/|\.git/"; then
  exit 0
fi

# Find phpcs
PHPCS=""
if [ -x "$(pwd)/vendor/bin/phpcs" ]; then
  PHPCS="$(pwd)/vendor/bin/phpcs"
elif command -v phpcs &>/dev/null; then
  PHPCS="phpcs"
else
  # phpcs not installed — skip silently
  exit 0
fi

# Find phpcbf
PHPCBF=""
if [ -x "$(pwd)/vendor/bin/phpcbf" ]; then
  PHPCBF="$(pwd)/vendor/bin/phpcbf"
elif command -v phpcbf &>/dev/null; then
  PHPCBF="phpcbf"
fi

# Run phpcs on the edited file
RESULT=$($PHPCS --standard=WordPress --report=code --colors=0 "$FILE" 2>&1) || PHPCS_EXIT=$?

if [ "${PHPCS_EXIT:-0}" -eq 0 ]; then
  # Clean — silent
  exit 0
fi

# Count errors vs warnings
ERRORS=$(echo "$RESULT" | grep -c "| ERROR" 2>/dev/null || echo "0")
WARNINGS=$(echo "$RESULT" | grep -c "| WARNING" 2>/dev/null || echo "0")

if [ "$ERRORS" -gt 0 ] && [ -n "$PHPCBF" ]; then
  # Auto-fix with phpcbf
  FIX_RESULT=$($PHPCBF --standard=WordPress "$FILE" 2>&1) || true
  FIXED=$(echo "$FIX_RESULT" | grep "A TOTAL OF" | grep -o "[0-9]* SNIFF" | head -1 || echo "0")

  echo ""
  echo "╔═ WPCS: $FILE ═╗"
  echo "  Auto-fixed $ERRORS error(s) with phpcbf."
  if [ "$WARNINGS" -gt 0 ]; then
    echo "  $WARNINGS warning(s) remain (non-blocking):"
    echo "$RESULT" | grep "WARNING" | head -5
  fi
  echo "╚════════════════╝"
elif [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "╔═ WPCS ERRORS: $FILE ═╗"
  echo "$RESULT" | grep "ERROR" | head -10
  echo "  Run: vendor/bin/phpcbf --standard=WordPress $FILE"
  echo "╚════════════════════╝"
fi

exit 0
