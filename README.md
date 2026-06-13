# Kuira WP Dev Plugin

> A Claude Code plugin that pre-configures Claude for **WordPress plugin development** — scaffold new plugins, enforce WordPress Coding Standards (WPCS), audit security, route UI/UX work to a visual companion, and automate releases. Install it once and start building plugins with sensible guardrails already in place.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## What's Inside

| Component | Count | Purpose |
|-----------|-------|---------|
| Skills | 13 | `/wp-new` wizard, scaffold, WP context, secure endpoints, blocks, custom tables, testing, i18n, readme.txt, plugin check, release, security audit, UI/visual routing |
| Agents | 3 | Security auditor, code reviewer, UI researcher |
| Hooks | 4 events | PreToolUse bash guard, PostToolUse WPCS, Stop notification, failure hint |
| MCP | 2 servers | GitHub, Fetch |

Everything is plain Markdown, JSON, and shell — no build step, no runtime dependencies.

---

## Install

This repo is a Claude Code **plugin marketplace**. The cleanest way to install it is from inside Claude Code:

```bash
# 1. Add this repo as a marketplace
/plugin marketplace add mlbd/kuira-wp-dev-plugin

# 2. Install the plugin from it
/plugin install kuira-wp-dev-plugin@kuira-marketplace
```

> **Recommended companion — Superpowers.** The `wp-ui-visual` skill routes UI/UX work to the Superpowers visual companion when it's available. Install it first for the full experience:
> ```bash
> /plugin marketplace add obra/superpowers-marketplace
> /plugin install superpowers@superpowers-marketplace
> ```
> Without Superpowers, `wp-ui-visual` falls back to a built-in standalone workflow — nothing breaks.

### Manual install (alternative)

Clone into your Claude config and reload:

```bash
git clone https://github.com/mlbd/kuira-wp-dev-plugin ~/.claude/plugins/kuira-wp-dev-plugin
```

Then run `/plugin` to confirm `kuira-wp-dev-plugin` appears in the list.

### Requirements

- **Claude Code** `>= 2.0.0`
- **A POSIX shell for hooks.** Hook scripts are Bash and use `jq`. On macOS/Linux they run as-is; on **Windows** they run under Git Bash (bundled with Git for Windows). Without `jq` the hooks degrade gracefully and simply skip.
- **`phpcs` / `phpcbf`** (optional) — the WPCS hook auto-lints PHP on save when PHP_CodeSniffer with the WordPress standard is available (locally via `vendor/bin` or globally). If it's missing, the hook silently skips.

---

## Quick Start — `/wp-new`

The fastest way in. Type the command in Claude Code:

```bash
/wp-new
```

It runs an interactive wizard — multiple-choice questions for your **frontend stack**
(React / Vue / vanilla), **distribution target** (wordpress.org or self-hosted),
**Gutenberg blocks**, **WooCommerce**, plus which **features** (settings page,
REST/AJAX, custom tables, cron) and **dev tooling** (testing, i18n, Plugin Check, CI)
you want. Then it asks what the plugin should do, **shows you the plan, waits for your
OK**, and generates a tailored plugin skeleton with all the right assets/libraries —
*and* the Claude Code project setup (`CLAUDE.md` + `.claude/settings.json`) so Claude
is already oriented in your new project.

Under the hood it just composes the focused skills below, so you can also run any of
them directly if you'd rather assemble things piece by piece.

---

## Skills Reference

### `wp-new` (the wizard)
**Invoke as:** `/wp-new` — or "new plugin wizard", "start a wordpress plugin interactively"

Interactive onboarding → tailored plugin generation. Asks your stack/distribution/
features/tooling, takes a free-text description, confirms the plan, then builds the
file structure + Claude Code setup by composing the skills below. Start here.

### `wp-scaffold`
**Trigger phrases:** "new plugin", "create a plugin", "scaffold a plugin", "start a wordpress plugin", "bootstrap plugin"

Generates a complete, WPCS-compliant plugin skeleton from scratch — main file with the full header block, singleton bootstrap class, activator/deactivator, an admin page that enqueues assets, `composer.json` wired to WPCS, a `phpcs.xml.dist` ruleset, and the standard directory layout.

It asks which **frontend stack** you want and wires up the whole build pipeline accordingly:

| Stack | Tooling set up | Output |
|-------|----------------|--------|
| **React** (recommended) | `@wordpress/scripts` — zero-config JSX/SCSS, auto dependency extraction | `build/index.js` + `build/index.asset.php` |
| **Vue** | `vite` + `@vitejs/plugin-vue`, loaded as an ES module | `assets/dist/{slug}.js` |
| **Vanilla** | plain `assets/js` + `assets/css`, enqueued with the `jquery` dependency | no build step |

Every stack gets a mount point printed in the admin page and a `wp_localize_script` payload with the REST URL + nonce, so you can call the API authenticated from the first line of JS. Run `composer install`, `npm install && npm run build`, and activate.

### `wp-readme`
**Trigger phrases:** "readme.txt", "wordpress.org readme", "generate readme", "stable tag", "upgrade notice"

Generates or fixes a spec-compliant WordPress.org `readme.txt` (the directory-listing file, distinct from this `README.md`) — header block, ≤150-char short description, Description/Installation/FAQ/Screenshots/Changelog/Upgrade Notice sections — and validates the rules that commonly break listings (Stable tag matching the plugin version, ≤5 tags, required headers).

### `wp-context` (auto-loads on PHP projects)
Always-active WordPress coding standards: tabs, escaping, sanitization, nonce/capability gates, text-domain discipline, HPOS patterns. No manual trigger — loads automatically on any `.php` file.

### `wp-ui-visual`
**Trigger phrases:** "design", "UI", "UX", "layout", "mockup", "component", "admin page", "form design"

Routes design work to the Superpowers visual companion (interactive layout cards, color palettes, component alternatives in your browser) when installed, or a structured standalone workflow when not. Run it **before** writing templates or React components.

### `wp-release`
**Trigger phrases:** "prepare release", "bump version", "build zip", "ready to deploy"

Semantic version bump across all locations → CHANGELOG → WPCS final check → distribution zip.

### `wp-security-audit`
**Trigger phrases:** "audit security", "check vulnerabilities", "is this safe"

Auto-triggers after writing AJAX handlers, REST endpoints, or DB queries. Delegates to the `wp-security-auditor` agent (haiku model — a cheap, read-only scan).

> The skills below are **opt-in** — they only run when you ask for them, and they confirm before installing dependencies or changing config.

### `wp-endpoint`
**Trigger phrases:** "add endpoint", "rest route", "ajax handler", "register_rest_route", "api endpoint"

Scaffolds a REST route or admin-ajax handler that's **secure by default** — `permission_callback`, nonce verification, capability checks, and per-arg sanitization/validation baked in, so the output passes `wp-security-audit` instead of failing it.

### `wp-block`
**Trigger phrases:** "gutenberg block", "create block", "block.json", "dynamic block"

Scaffolds a `block.json`-based block (apiVersion 3) with the `@wordpress/scripts` build — `edit`/`save` for static blocks or a server `render.php` for dynamic, plus PHP `register_block_type`.

### `wp-db`
**Trigger phrases:** "custom table", "dbdelta", "migration", "schema upgrade", "db version"

Generates `dbDelta`-correct schema creation, **version-gated migrations** (the part most plugins get wrong on update), prepared CRUD helpers, and uninstall cleanup.

### `wp-test`
**Trigger phrases:** "write tests", "phpunit", "set up testing", "wp-env", "spin up wordpress"

Configures `@wordpress/env` (local Docker WP) and the PHPUnit WordPress test suite, writes `WP_UnitTestCase` / REST / AJAX tests, and runs them.

### `wp-i18n`
**Trigger phrases:** "translation", "i18n", "make-pot", "text domain check", "localization"

Verifies text-domain consistency, wraps untranslated strings, generates the `.pot` template, and wires up JavaScript translations (`wp_set_script_translations`).

### `wp-plugin-check`
**Trigger phrases:** "plugin check", "PCP", "ready for submission", "wordpress.org guidelines"

Runs the official **Plugin Check** — the same automated review wordpress.org runs on submission — and maps results to fix priorities. Complements `wp-security-audit`.

---

## Agents Reference

| Agent | Model | Trigger |
|-------|-------|---------|
| `wp-security-auditor` | haiku | Security-related code, "audit" |
| `wp-code-reviewer` | sonnet | After features, "review my code" |
| `wp-ui-researcher` | haiku | Before UI/UX design tasks |

Invoke explicitly with `@wp-security-auditor` or `@wp-code-reviewer`.

---

## Hooks

| Hook | Matcher | Action |
|------|---------|--------|
| PreToolUse | Bash | Blocks: `rm -rf` on system paths, `DROP`/`TRUNCATE TABLE`, curl/wget piped to a shell, automated `wp-config.php` edits, `chmod -R 777` |
| PostToolUse | Write/Edit on `.php` | Runs phpcs → auto-fixes with phpcbf when errors are found |
| Stop | — | Desktop notification (Linux `notify-send` / macOS `osascript`; no-op elsewhere) |
| PostToolUseFailure | Bash | Adds a diagnostic hint when a Bash command fails |

---

## A Typical Flow

1. **`wp-scaffold`** — generate a fresh plugin skeleton (or open an existing one)
2. **`wp-ui-researcher`** (haiku) surveys existing UI patterns — fast, cheap
3. **`wp-ui-visual`** hands off to the Superpowers visual companion
4. You approve a design direction
5. Claude writes PHP/React/CSS — **`wp-context`** enforces WPCS throughout
6. **`wp-code-reviewer`** reviews the result
7. **`wp-security-audit`** checks for vulnerabilities
8. **`wp-release`** builds the distribution zip

```
Superpowers handles:   methodology (clarify → plan → TDD → verify)
kuira adds:            WordPress domain knowledge (scaffolding, WPCS, hooks, security, release)
```

---

## File Structure

```
kuira-wp-dev-plugin/
├── .claude-plugin/
│   ├── plugin.json              ← plugin manifest
│   └── marketplace.json         ← marketplace manifest
├── skills/
│   ├── wp-new/SKILL.md          ← /wp-new interactive wizard (start here)
│   ├── wp-scaffold/SKILL.md     ← generate a new plugin (React / Vue / vanilla)
│   ├── wp-context/SKILL.md      ← auto-loads on PHP, enforces WPCS
│   ├── wp-endpoint/SKILL.md     ← secure REST/AJAX handler scaffolder
│   ├── wp-block/SKILL.md        ← Gutenberg block scaffolder
│   ├── wp-db/SKILL.md           ← dbDelta schema + migrations
│   ├── wp-test/SKILL.md         ← wp-env + PHPUnit testing
│   ├── wp-i18n/SKILL.md         ← translation readiness + .pot
│   ├── wp-readme/SKILL.md       ← WordPress.org readme.txt generator
│   ├── wp-plugin-check/SKILL.md ← official Plugin Check (PCP)
│   ├── wp-ui-visual/SKILL.md    ← visual companion routing
│   ├── wp-release/SKILL.md      ← release workflow
│   └── wp-security-audit/SKILL.md ← security scanning
├── agents/
│   ├── wp-security-auditor.md   ← haiku, read-only scan
│   ├── wp-code-reviewer.md      ← sonnet, quality review
│   └── wp-ui-researcher.md      ← haiku, UI context survey
├── hooks/
│   ├── hooks.json               ← hook configuration
│   └── scripts/
│       ├── bash-guard.sh        ← PreToolUse safety gate
│       └── wpcs-check.sh        ← PostToolUse WPCS enforcement
├── .mcp.json                    ← GitHub + Fetch MCP servers
├── settings.json                ← model + permissions defaults
├── CONTRIBUTING.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```

---

## Configuration Notes

- **MCP servers** (`.mcp.json`) include a GitHub server that reads `${GITHUB_TOKEN}` from your environment. It's optional — set the variable to enable GitHub operations, or remove the server if you don't need it.
- **Permissions** (`settings.json`) pre-allow common WP dev commands (`php`, `composer`, `wp`, `git`, `npm`, …) and deny obviously destructive ones. Adjust to taste.

---

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Good first contributions: new WP/WooCommerce patterns for `wp-context`, additional security checks, or cross-platform hook improvements.

## License

[MIT](LICENSE) © Mohammad Limon Mia
