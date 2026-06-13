#!/usr/bin/env bash
# Repo self-validation. Run locally (`bash scripts/validate.sh`) or in CI.
# Checks: every JSON parses, skill/agent frontmatter names match their path,
# required frontmatter keys exist, and shell scripts pass shellcheck (errors only).

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0
err() { echo "FAIL: $*" >&2; fail=1; }
ok()  { echo "ok:   $*"; }

# Pick a JSON parser.
JSON=""
if command -v python3 >/dev/null 2>&1 && printf '{}' | python3 -c 'import json,sys;json.load(sys.stdin)' >/dev/null 2>&1; then
	JSON="python3"
elif command -v node >/dev/null 2>&1; then
	JSON="node"
fi

echo "== JSON =="
while IFS= read -r j; do
	case "$j" in */node_modules/*|*/vendor/*) continue;; esac
	if [ "$JSON" = "python3" ]; then
		python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$j" >/dev/null 2>&1 && ok "$j" || err "invalid JSON: $j"
	elif [ "$JSON" = "node" ]; then
		node -e 'JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))' "$j" >/dev/null 2>&1 && ok "$j" || err "invalid JSON: $j"
	else
		echo "skip: no JSON parser available"
		break
	fi
done < <(find . -name '*.json' -not -path '*/node_modules/*' -not -path '*/vendor/*')

echo "== Plugins =="
for p in plugins/*/; do
	b=$(basename "$p")
	mf="${p}.claude-plugin/plugin.json"
	[ -f "$mf" ] || { err "plugin $b: missing .claude-plugin/plugin.json"; continue; }
	pname=$(grep -m1 '"name"' "$mf" | sed -E 's/.*"name"[: ]*"([^"]+)".*/\1/')
	[ "$pname" = "$b" ] || err "plugin manifest name '$pname' != dir '$b'"
done
ok "plugins checked"

echo "== Skills =="
for f in plugins/*/skills/*/SKILL.md; do
	[ -f "$f" ] || continue
	b=$(basename "$(dirname "$f")")
	name=$(awk -F': *' '/^name:/{print $2; exit}' "$f" | tr -d '\r ')
	[ "$name" = "$b" ] || err "skill name '$name' != folder '$b'"
	grep -q '^description:' "$f" || err "skill $b: missing 'description:'"
	grep -q '^allowed-tools:' "$f" || echo "warn: skill $b: no allowed-tools"
done
ok "skills checked"

echo "== Agents =="
for f in plugins/*/agents/*.md; do
	[ -f "$f" ] || continue
	b=$(basename "$f" .md)
	name=$(awk -F': *' '/^name:/{print $2; exit}' "$f" | tr -d '\r ')
	[ "$name" = "$b" ] || err "agent name '$name' != file '$b'"
	grep -q '^description:' "$f" || err "agent $b: missing 'description:'"
done
ok "agents checked"

echo "== Shell =="
if command -v shellcheck >/dev/null 2>&1; then
	# Severity 'error' only — don't block on style nits, do block on real bugs.
	if shellcheck -S error plugins/*/hooks/scripts/*.sh plugins/*/statusline.sh scripts/*.sh; then
		ok "shellcheck (errors)"
	else
		err "shellcheck found errors"
	fi
else
	echo "skip: shellcheck not installed"
fi

echo
if [ "$fail" -eq 0 ]; then
	echo "ALL CHECKS PASSED"
	exit 0
else
	echo "VALIDATION FAILED"
	exit 1
fi
