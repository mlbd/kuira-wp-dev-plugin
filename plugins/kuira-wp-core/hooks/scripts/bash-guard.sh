#!/usr/bin/env bash
# PreToolUse hook: guards against dangerous bash commands in WP projects
# Exit 0 = allow | Exit 2 = block (message to stderr, Claude reads and adjusts)

set -euo pipefail

# Read the tool input JSON from stdin
INPUT=$(cat)

# Pick a JSON parser that actually works. `command -v python3` can resolve to the
# Windows Store alias stub (on PATH but non-functional), so probe before trusting it.
PY=""
for c in python3 python; do
  if command -v "$c" >/dev/null 2>&1 && printf '{}' | "$c" -c 'import json,sys; json.load(sys.stdin)' >/dev/null 2>&1; then
    PY="$c"
    break
  fi
done

# Extract .tool_input.command — prefer jq, fall back to python, then fail open.
if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
elif [ -n "$PY" ]; then
  CMD=$(printf '%s' "$INPUT" | "$PY" -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || echo "")
else
  # No JSON parser available — fail open (cannot inspect the command).
  exit 0
fi

if [ -z "$CMD" ]; then
  exit 0
fi

# --- Block 1: Destructive rm outside safe dirs ---
# (grep -E has no lookahead, so match an absolute-path rm -rf, then allow-list /tmp.)
if echo "$CMD" | grep -qE "rm[[:space:]]+-[a-z]*r[a-z]*f?[a-z]*[[:space:]]+/"; then
  if ! echo "$CMD" | grep -qE "rm[[:space:]]+-[a-z]+[[:space:]]+/(tmp|var/tmp)(/|[[:space:]]|$)"; then
    echo "Blocked: rm -rf on a system path outside /tmp. Confirm this is intentional and run manually." >&2
    exit 2
  fi
fi

# --- Block 2: Dropping WordPress tables ---
if echo "$CMD" | grep -qiE "DROP\s+TABLE|TRUNCATE\s+TABLE"; then
  echo "Blocked: SQL DROP/TRUNCATE detected. Never drop WP tables via Claude. Run manually after backup." >&2
  exit 2
fi

# --- Block 3: Piping curl/wget output to bash (remote code execution risk) ---
if echo "$CMD" | grep -qE "(curl|wget).+\|\s*(bash|sh|php)"; then
  echo "Blocked: Remote script execution via pipe detected. Download the script first, review it, then run." >&2
  exit 2
fi

# --- Block 4: wp-config.php edits via sed/awk ---
if echo "$CMD" | grep -qE "(sed|awk|perl).+wp-config\.php"; then
  echo "Blocked: Automated edit of wp-config.php detected. Edit this file manually to avoid config corruption." >&2
  exit 2
fi

# --- Block 5: Recursive chmod 777 ---
if echo "$CMD" | grep -qE "chmod\s+-R\s+777"; then
  echo "Blocked: chmod -R 777 creates world-writable files — a security vulnerability in WordPress. Use 755 for dirs, 644 for files." >&2
  exit 2
fi

# --- Log allowed commands (async, non-blocking) ---
echo "$(date '+%Y-%m-%d %H:%M:%S') ALLOWED: $CMD" >> /tmp/claude-wp-bash.log 2>/dev/null || true

exit 0
