# Kuira WP Dev Plugin

> Claude Code plugin for WordPress plugin development — WPCS enforcement, security auditing, visual UI companion routing, and Oasis Workflow Pro patterns.

## What's Inside

| Component | Count | Purpose |
|-----------|-------|---------|
| Skills | 5 | WP context, release, security audit, UI/visual routing, Oasis Workflow |
| Agents | 3 | Security auditor, code reviewer, UI researcher |
| Hooks | 3 events | PostToolUse WPCS, PreToolUse bash guard, Stop notification |
| MCP | 2 servers | GitHub, Fetch |

---

## Install

### Step 1 — Install Superpowers first (required for Visual Companion)

```bash
# Inside Claude Code
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

### Step 2 — Install this plugin

**Option A — Global (all projects):**
```bash
cp -r kuira-wp-dev-plugin ~/.claude/plugins/kuira-wp-dev-plugin
```
Unzip the zip first if installing from `kuira-wp-dev-plugin.zip`:
```bash
unzip kuira-wp-dev-plugin.zip -d ~/.claude/plugins/
```

**Option B — Project-only:**
```bash
unzip kuira-wp-dev-plugin.zip -d .claude/plugins/
```

**Option C — Via plugin URL (if hosted):**
```bash
claude --plugin-url https://your-host.com/kuira-wp-dev-plugin.zip
```

### Step 3 — Reload

```bash
/reload-plugins
```

Verify with `/plugin` — you should see `kuira-wp-dev-plugin` in the list.

---

## Skills Reference

### `wp-context` (auto-loads on PHP projects)
Always-active WordPress coding standards. Tabs, escaping, sanitization, HPOS patterns.
No manual trigger needed — loads automatically on any `.php` file.

### `wp-ui-visual`
**Trigger phrases:** "design", "UI", "UX", "layout", "mockup", "component", "admin page", "form design"

Routes to Superpowers visual companion → opens browser dashboard with layout cards, color options, component alternatives. Run BEFORE writing any templates or React components.

Flow:
```
You: "design a settings page for Mockivo"
  → wp-ui-researcher gathers existing UI context
  → wp-ui-visual routes to Superpowers brainstorming
  → Visual companion opens in browser
  → You approve design direction
  → Claude writes the code
```

### `wp-release`
**Trigger phrases:** "prepare release", "bump version", "build zip", "ready to deploy"

Version bump → CHANGELOG → WPCS fix → dist zip.

### `wp-security-audit`
**Trigger phrases:** "audit security", "check vulnerabilities", "is this safe"

Auto-triggers after writing AJAX handlers, REST endpoints, DB queries.
Delegates to `wp-security-auditor` agent (haiku model, cheap scan).

### `oasis-workflow`
**Trigger phrases:** "editorial workflow", "sign-off", "get-inbox", "oasis", "OW"

Auto-loads inside `oasis-workflow-pro/` directories. Includes known bug notes (sign-off ability, get-inbox user_id requirement).

---

## Agents Reference

| Agent | Model | Trigger |
|-------|-------|---------|
| `wp-security-auditor` | haiku | Security-related code, "audit" |
| `wp-code-reviewer` | sonnet | After features, "review my code" |
| `wp-ui-researcher` | haiku | Before UI/UX design tasks |

Invoke explicitly: `@wp-security-auditor` or `@wp-code-reviewer`

---

## Hooks

| Hook | Matcher | Action |
|------|---------|--------|
| PreToolUse | Bash | Blocks: rm -rf system paths, DROP TABLE, curl pipe to bash, wp-config sed, chmod 777 |
| PostToolUse | Write/Edit on `.php` | Runs phpcs → auto-fixes with phpcbf if errors found |
| Stop | — | Desktop notification (Linux notify-send / macOS osascript) |

---

## Superpowers Integration

This plugin is designed to work **alongside** Superpowers, not replace it.

```
Superpowers handles:    methodology (clarify → plan → TDD → verify)
kuira adds:          domain knowledge (WPCS, WP hooks, security, release)
```

For any UI/UX task, the flow is:
1. `wp-ui-researcher` (haiku) surveys existing UI patterns — fast, cheap
2. `wp-ui-visual` hands off to Superpowers `/superpowers:brainstorming`
3. Superpowers visual companion opens in browser
4. You approve the design
5. Claude writes PHP/React/CSS — `wp-context` enforces WPCS throughout
6. `wp-code-reviewer` reviews the result
7. `wp-security-audit` checks for vulnerabilities
8. `wp-release` builds the zip

---

## Projects This Covers

- **Oasis Workflow Pro** — `oasis-workflow` skill + known bug patterns
- **Formcierge** — `wp-ui-visual` for form field design, `wp-security-audit` for REST endpoints
- **Mockivo** — `wp-ui-visual` for canvas component design, `wp-release` for dist zips
- **Postyra** — `oasis-workflow` patterns, `wp-release` for build
- **Lineflow** — `wp-security-audit` for WooCommerce REST hooks

---

## File Structure

```
kuira-wp-dev-plugin/
├── .claude-plugin/
│   └── plugin.json          ← manifest
├── skills/
│   ├── wp-context/SKILL.md  ← auto-loads on PHP
│   ├── wp-ui-visual/SKILL.md ← visual companion routing
│   ├── wp-release/SKILL.md  ← release workflow
│   ├── wp-security-audit/SKILL.md ← security scanning
│   └── oasis-workflow/SKILL.md ← OW Pro patterns
├── agents/
│   ├── wp-security-auditor.md ← haiku, read-only scan
│   ├── wp-code-reviewer.md   ← sonnet, quality review
│   └── wp-ui-researcher.md   ← haiku, UI context survey
├── hooks/
│   ├── hooks.json            ← hook configuration
│   └── scripts/
│       ├── bash-guard.sh     ← PreToolUse safety gate
│       └── wpcs-check.sh     ← PostToolUse WPCS enforcement
├── .mcp.json                 ← GitHub + Fetch MCP
├── settings.json             ← model + permissions defaults
└── README.md
```
