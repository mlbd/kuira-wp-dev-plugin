# Kuira WP Dev Toolkit

> A Claude Code **marketplace of four modular plugins** for **WordPress plugin development** — scaffold new plugins, enforce WordPress Coding Standards (WPCS), test, audit, and ship. Install only the lifecycle stages you need; start building with sensible guardrails already in place.

[![License: GPL v2](https://img.shields.io/badge/License-GPLv2-blue.svg)](LICENSE)
[![Validate](https://github.com/mlbd/kuira-wp-dev-plugin/actions/workflows/validate.yml/badge.svg)](https://github.com/mlbd/kuira-wp-dev-plugin/actions/workflows/validate.yml)

## The four modules

Install only what you want — each is a standalone Claude Code plugin in this marketplace.

| Plugin | Install when you want to… | Contents |
|--------|---------------------------|----------|
| **kuira-wp-core** ⭐ | build a WP plugin (start here) | `/wp-new` wizard, scaffold, context (WPCS), endpoints, blocks, DB, UI/visual, help · 8 skills, 1 agent, safety hooks, MCP, statusline |
| **kuira-wp-quality** | test, analyze, and audit | testing (PHPUnit), E2E (Playwright), Playground, PHPStan, security audit, Plugin Check · 6 skills, 4 auditor agents, opt-in commit gate |
| **kuira-wp-ship** | release and publish | release, wordpress.org deploy/CI, readme.txt, i18n, hook docs · 5 skills |
| **kuira-wp-maintain** | fix/modernize existing code | modernize, PHP 8.x compat, debug · 3 skills |

**Totals:** 22 skills, 5 agents across the four. Everything beyond the passive `wp-context` skill and the low-noise core hooks is **opt-in** — skills run only when invoked, generated-plugin features are chosen in `/wp-new`, and the commit gate is off unless you enable it. Run **`/wp-help`** (in core) for the full command map.

Everything is plain Markdown, JSON, and shell — no build step, no runtime dependencies.

---

## Documentation

Full guides live in **[`docs/`](docs/)**:

- **[Getting Started](docs/getting-started.md)** — prerequisites, install, and your first plugin with `/wp-new`, step by step.
- **[Workflows](docs/workflows.md)** — task recipes (add an endpoint/block/table, test, audit, ship, modernize) with what to expect.
- **[Skill & Agent Reference](docs/skills-reference.md)** — every command: trigger, module, and output.
- **[FAQ & Expectations](docs/faq.md)** — what it does, what it won't, requirements, Windows, cost, troubleshooting.

New here? Read **[Getting Started](docs/getting-started.md)** first, then install below.

---

## Install

This repo is a Claude Code **plugin marketplace** with four plugins. From inside Claude Code:

```bash
# 1. Add this repo as a marketplace
/plugin marketplace add mlbd/kuira-wp-dev-plugin

# 2. Install the core (everyone wants this)
/plugin install kuira-wp-core@kuira-marketplace

# 3. Add any lifecycle stages you want (all optional)
/plugin install kuira-wp-quality@kuira-marketplace
/plugin install kuira-wp-ship@kuira-marketplace
/plugin install kuira-wp-maintain@kuira-marketplace
```

> **Recommended companion — Superpowers.** The `wp-ui-visual` skill (in core) routes UI/UX work to the Superpowers visual companion when it's available. Install it for the full experience:
> ```bash
> /plugin marketplace add obra/superpowers-marketplace
> /plugin install superpowers@superpowers-marketplace
> ```
> Without Superpowers, `wp-ui-visual` falls back to a built-in standalone workflow — nothing breaks.

Run `/plugin` to confirm the installed modules appear in the list.

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
**Gutenberg blocks**, **WooCommerce**, which **features** (settings page, REST/AJAX,
custom tables, cron), **dev tooling** (testing, i18n, Plugin Check, CI), and how you
want **git commits** handled (manual / auto-commit / never — set up to match your
choice). Then it asks what the plugin should do, **shows you the plan, waits for your
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

### More opt-in skills

| Skill | Trigger | Does |
|-------|---------|------|
| `wp-analyze` | "phpstan", "static analysis", "type check" | PHPStan + WP stubs; finds type/null/logic bugs WPCS can't |
| `wp-e2e` | "playwright", "e2e", "browser test" | Playwright admin/front-UI tests against wp-env |
| `wp-playground` | "playground", "blueprint", "preview without docker" | Instant WASM WordPress + Blueprint; demos & Docker-free testing |
| `wp-deploy` | "ci", "github actions", "deploy to wordpress.org" | CI workflow + wordpress.org SVN deploy on tag |
| `wp-hook-docs` | "document hooks", "hook reference" | Generates `HOOKS.md` of every action/filter the plugin fires |
| `wp-modernize` | "modernize", "refactor legacy", "convert to OOP" | Incremental syntax/structure/namespacing modernization |
| `wp-php8` | "php 8 compatibility", "phpcompatibility" | PHPCompatibilityWP scan + fixes; updates `Requires PHP` |
| `wp-debug` | "enable debug", "debug.log", "fatal error" | Enables WP_DEBUG safely + reads/interprets the log |
| `wp-help` | `/wp-help`, "list the wp commands" | Read-only map of every skill, agent, and hook |

---

## Agents Reference

| Agent | Model | Trigger |
|-------|-------|---------|
| `wp-security-auditor` | haiku | Security-related code, "audit" |
| `wp-code-reviewer` | sonnet | After features, "review my code" |
| `wp-ui-researcher` | haiku | Before UI/UX design tasks |
| `wp-performance-auditor` | sonnet | "performance audit", "why is this slow", data-heavy code |
| `wp-a11y-auditor` | sonnet | "accessibility", "a11y", "wcag", after building admin UI |

Invoke explicitly with `@wp-security-auditor`, `@wp-performance-auditor`, etc.

---

## Hooks

| Hook | Matcher | Action |
|------|---------|--------|
| SessionStart | — | If you open a WP plugin with uninstalled `composer`/`npm` deps, reminds you to install them. Silent otherwise. |
| PreToolUse | Bash | **bash-guard** blocks `rm -rf` on system paths, `DROP`/`TRUNCATE TABLE`, curl/wget piped to a shell, automated `wp-config.php` edits, `chmod -R 777`. **commit-gate** (opt-in) blocks `git commit` on staged PHP with syntax/WPCS errors. |
| PostToolUse | Write/Edit on `.php` | Fast `php -l` syntax check, then phpcs → auto-fix with phpcbf |
| Stop | — | Desktop notification (Linux `notify-send` / macOS `osascript` / Windows BurntToast) |
| PostToolUseFailure | Bash | Adds a diagnostic hint when a Bash command fails |

**Opt-in commit gate.** The commit gate is **off by default**. Enable it by setting `KUIRA_COMMIT_GATE=1` in your environment — then a `git commit` is blocked if staged PHP files have syntax errors or WPCS errors.

**Optional statusline.** `statusline.sh` shows the current plugin name + version in your status bar. It's not auto-enabled (that would override your own statusline) — turn it on via `/statusline` or a `statusLine` entry in `settings.json` pointing at the script.

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
kuira-wp-dev-plugin/                  ← marketplace repo
├── .claude-plugin/
│   └── marketplace.json              ← lists the 4 plugins
├── plugins/
│   ├── kuira-wp-core/                ← build essentials (start here)
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/                   ← wp-new, wp-scaffold, wp-context, wp-endpoint,
│   │   │                                wp-db, wp-block, wp-ui-visual, wp-help
│   │   ├── agents/                   ← wp-ui-researcher
│   │   ├── hooks/                    ← session-start, bash-guard, wpcs-check, Stop notify
│   │   ├── settings.json
│   │   ├── statusline.sh             ← optional WP-aware statusline
│   │   └── .mcp.json                 ← GitHub + Fetch MCP servers
│   ├── kuira-wp-quality/             ← test · analyze · audit
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/                   ← wp-test, wp-e2e, wp-playground, wp-analyze,
│   │   │                                wp-security-audit, wp-plugin-check
│   │   ├── agents/                   ← security / code-review / performance / a11y
│   │   └── hooks/                    ← commit-gate (opt-in)
│   ├── kuira-wp-ship/                ← release · publish · docs
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/                   ← wp-release, wp-deploy, wp-readme, wp-i18n, wp-hook-docs
│   └── kuira-wp-maintain/            ← legacy · debug
│       ├── .claude-plugin/plugin.json
│       └── skills/                   ← wp-modernize, wp-php8, wp-debug
├── scripts/validate.sh               ← repo self-check (CI runs this)
├── .github/workflows/validate.yml    ← CI: shellcheck + JSON + name/frontmatter
├── docs/AUTHORING.md                 ← contributor guide
├── examples/acme-notes/              ← reference plugin produced by /wp-new
├── fixtures/                         ← vulnerable/ + clean/ (prove the auditors)
├── CONTRIBUTING.md · CODE_OF_CONDUCT.md · SECURITY.md · CHANGELOG.md · README.md
```

---

## Examples & validation

The toolkit is proven, not just described:

- **[`examples/acme-notes`](examples/acme-notes)** — a complete reference plugin
  generated by `/wp-new` (React admin + secure REST controller + custom table +
  PHPUnit tests + Playground Blueprint). It shows exactly what the toolkit produces,
  and CI holds it to the same WPCS standard the toolkit enforces.
- **[`fixtures/`](fixtures)** — `vulnerable/` (seven planted security issues) and
  `clean/` (the fixes). Point `@wp-security-auditor` at `fixtures/vulnerable` to
  verify the auditor catches all seven; `fixtures/README.md` maps each `[Vn]` marker
  to its expected detection. These fixtures already caught (and we fixed) a real
  reflected-XSS detection gap in the concatenated-`echo` form.

## Configuration Notes

- **MCP servers** (`.mcp.json`) include a GitHub server that reads `${GITHUB_TOKEN}` from your environment. It's optional — set the variable to enable GitHub operations, or remove the server if you don't need it.
- **Permissions** (`settings.json`) pre-allow common WP dev commands (`php`, `composer`, `wp`, `git`, `npm`, …) and deny obviously destructive ones. Adjust to taste.

---

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) and the skill/agent/hook conventions in [docs/AUTHORING.md](docs/AUTHORING.md). Before opening a PR, run the repo self-check (the same one CI runs):

```bash
bash scripts/validate.sh
```

It verifies every JSON parses, each skill/agent's frontmatter `name` matches its path, required frontmatter keys exist, and the hook scripts pass `shellcheck`. Good first contributions: new WP/WooCommerce patterns for `wp-context`, additional security checks, or cross-platform hook improvements. Please also read the [Code of Conduct](CODE_OF_CONDUCT.md); report security issues per [SECURITY.md](SECURITY.md).

## License

Licensed under [GPL-2.0-or-later](LICENSE) © Mohammad Limon Mia. WordPress plugins generated by this toolkit also carry `GPL-2.0-or-later` headers — the standard for the WordPress.org directory.
