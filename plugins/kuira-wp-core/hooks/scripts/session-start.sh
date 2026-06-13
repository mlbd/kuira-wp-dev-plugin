#!/usr/bin/env bash
# SessionStart hook: surface *actionable* WordPress-plugin context.
# Intentionally silent unless there's something worth doing — never a burden.

set -uo pipefail

# Detect a WP plugin in the working dir: a PHP file with a "Plugin Name:" header.
MAIN=$(grep -rlsm1 "Plugin Name:" --include="*.php" . 2>/dev/null | head -1 || true)
[ -z "$MAIN" ] && exit 0   # not a WP plugin — stay quiet

NOTES=""
# Composer dependencies declared but not installed (phpcs/phpstan won't run).
if [ -f composer.json ] && [ ! -d vendor ]; then
	NOTES="${NOTES}- Composer deps not installed: run \`composer install\` (enables phpcs/phpstan + the WPCS save hook).\n"
fi
# Node dependencies declared but not installed (no frontend build).
if [ -f package.json ] && [ ! -d node_modules ]; then
	NOTES="${NOTES}- Node deps not installed: run \`npm install\` then \`npm run build\`.\n"
fi

# Nothing actionable — don't add noise.
[ -z "$NOTES" ] && exit 0

PLUGIN=$(grep -m1 "Plugin Name:" "$MAIN" 2>/dev/null | sed 's/.*Plugin Name:[[:space:]]*//' | tr -d '\r' || echo "plugin")
printf 'WordPress plugin "%s" detected — setup reminders:\n%b' "$PLUGIN" "$NOTES"
exit 0
