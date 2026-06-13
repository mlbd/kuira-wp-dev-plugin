#!/usr/bin/env bash
# PreToolUse(Bash) hook: OPTIONAL quality gate before `git commit`.
#
# OFF by default — it does nothing unless you opt in by setting:
#     export KUIRA_COMMIT_GATE=1
# When enabled, it blocks a commit if staged PHP has syntax errors or WPCS errors.

set -uo pipefail

# Opt-in only. No env var = no-op = zero burden.
[ "${KUIRA_COMMIT_GATE:-}" = "1" ] || exit 0

INPUT=$(cat)

# Pick a working JSON parser (jq, or a probed python — Windows Store python3 is a stub).
PY=""
for c in python3 python; do
	if command -v "$c" >/dev/null 2>&1 && printf '{}' | "$c" -c 'import json,sys; json.load(sys.stdin)' >/dev/null 2>&1; then
		PY="$c"; break
	fi
done
if command -v jq >/dev/null 2>&1; then
	CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
elif [ -n "$PY" ]; then
	CMD=$(printf '%s' "$INPUT" | "$PY" -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || echo "")
else
	exit 0   # can't inspect the command — fail open
fi

# Only act on `git commit`.
echo "$CMD" | grep -qE "git[[:space:]]+commit" || exit 0

# Staged PHP files only — keep it fast and scoped to what's being committed.
FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep '\.php$' || true)
[ -z "$FILES" ] && exit 0

FAIL=0

# 1. Syntax check.
if command -v php >/dev/null 2>&1; then
	while IFS= read -r f; do
		[ -f "$f" ] || continue
		php -l "$f" >/dev/null 2>&1 || { echo "Commit blocked: PHP syntax error in $f." >&2; FAIL=1; }
	done <<< "$FILES"
fi

# 2. WPCS errors (not warnings) on staged files.
PHPCS=""
if [ -x vendor/bin/phpcs ]; then PHPCS="vendor/bin/phpcs"; elif command -v phpcs >/dev/null 2>&1; then PHPCS="phpcs"; fi
if [ -n "$PHPCS" ]; then
	if ! echo "$FILES" | xargs $PHPCS --standard=WordPress --error-severity=1 --warning-severity=0 >/dev/null 2>&1; then
		echo "Commit blocked: WPCS errors in staged PHP. Fix with: $PHPCS --standard=WordPress <files> (or phpcbf)." >&2
		FAIL=1
	fi
fi

[ "$FAIL" -eq 1 ] && exit 2
exit 0
