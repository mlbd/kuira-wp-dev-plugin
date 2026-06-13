#!/usr/bin/env bash
# PreToolUse hook: guards against dangerous bash commands in WP projects
# Exit 0 = allow | Exit 2 = block (message to stderr, Claude reads and adjusts)

set -euo pipefail

# Read the tool input JSON from stdin
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

if [ -z "$CMD" ]; then
  exit 0
fi

# --- Block 1: Destructive rm outside safe dirs ---
if echo "$CMD" | grep -qE "rm\s+-rf?\s+/(?!(tmp|var/tmp|home/[^/]+/tmp))"; then
  echo "Blocked: rm -rf on a system path outside /tmp. Confirm this is intentional and run manually." >&2
  exit 2
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
