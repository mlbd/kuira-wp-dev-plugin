#!/usr/bin/env bash
# Optional WP-aware statusline for Claude Code.
#
# This is NOT enabled automatically (a statusLine setting would override yours).
# To turn it on, add to your settings.json:
#   "statusLine": { "type": "command", "command": "/abs/path/to/statusline.sh" }
# or run /statusline and point it at this file.
#
# Shows the model, and — when you're inside a WordPress plugin — the plugin name
# and version parsed from its main file.

set -uo pipefail
input=$(cat)

_get() { # $1 = jq filter, $2 = fallback
	if command -v jq >/dev/null 2>&1; then
		printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null || true
	fi
}

MODEL=$(_get '.model.display_name'); [ -z "$MODEL" ] && MODEL=$(_get '.model.id'); [ -z "$MODEL" ] && MODEL="Claude"
DIR=$(_get '.workspace.current_dir'); [ -z "$DIR" ] && DIR=$(_get '.cwd'); [ -z "$DIR" ] && DIR="."

cd "$DIR" 2>/dev/null || true
MAIN=$(grep -rlsm1 "Plugin Name:" --include="*.php" . 2>/dev/null | head -1 || true)

if [ -n "$MAIN" ]; then
	NAME=$(grep -m1 "Plugin Name:" "$MAIN" 2>/dev/null | sed 's/.*Plugin Name:[[:space:]]*//' | tr -d '\r')
	VER=$(grep -m1 "Version:" "$MAIN" 2>/dev/null | sed 's/.*Version:[[:space:]]*//' | tr -d '\r')
	printf '%s | wp: %s v%s' "$MODEL" "${NAME:-plugin}" "${VER:-?}"
else
	printf '%s' "$MODEL"
fi
