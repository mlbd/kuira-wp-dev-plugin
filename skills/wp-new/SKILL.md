---
name: wp-new
description: >
  Interactive new-plugin wizard. Invoke as /wp-new (or "new plugin wizard",
  "start a wordpress plugin interactively", "configure a new plugin", "bootstrap a
  wordpress plugin", "set up a wp plugin from scratch"). Runs a multi-step
  onboarding (frontend stack, wordpress.org vs self-hosted, Gutenberg blocks,
  WooCommerce, features, dev tooling), takes a free-text description of the plugin,
  then generates a tailored, WPCS-compliant plugin file structure with all required
  assets/libraries AND the Claude Code project setup (CLAUDE.md + .claude/settings.json).
  Confirms the plan before writing anything.
allowed-tools: AskUserQuestion, Read, Write, Bash, Glob
model: sonnet
---

## `/wp-new` — Interactive New-Plugin Wizard

This is the front door for "create a new WordPress plugin with everything set up."
It **asks** what the developer needs, then **composes** the other kuira skills
(`wp-scaffold`, `wp-block`, `wp-db`, `wp-endpoint`, `wp-test`, `wp-i18n`,
`wp-readme`) to generate exactly that — nothing they didn't ask for.

> Always **propose the full plan and confirm before writing files.** The developer
> stays in control of what gets created.

---

### Step 1 — Identity (ask in prose)

Greet briefly, then ask for:
- **Plugin name** (human-readable) → derive the **slug** (`kebab-case`) and confirm it.
- **One-sentence description.**
- **Author** name + URL (offer to reuse the git user / a sensible default).

Derive the prefixes from the slug (function `my_plugin_`, class `My_Plugin`,
constant `MY_PLUGIN_`, JS `myPluginData`). Don't ask for these — derive and show them.

### Step 2 — Configuration (use the AskUserQuestion tool — this is the "onboarding")

Run the interactive picker. **Batch A** (one AskUserQuestion call, 4 questions, each single-select):

1. **Frontend stack** — header `Frontend`
   - `React (@wordpress/scripts)` — *Recommended. Matches WP core tooling; zero-config JSX/SCSS + auto dependency extraction.*
   - `Vue (Vite)` — *Vue 3 SPA-style admin, built with Vite, loaded as an ES module.*
   - `Vanilla (jQuery + CSS)` — *No build step; plain enqueued assets.*

2. **Distribution target** — header `Distribution`
   - `WordPress.org directory` — *Adds readme.txt, GPL headers, assets/ guidance, Plugin Check.*
   - `Self-hosted / private` — *Skip the wordpress.org-specific files.*
   - `Both` — *wp.org-ready but also fine to distribute privately.*

3. **Block editor** — header `Gutenberg`
   - `Include a Gutenberg block` — *Scaffold a block.json block (static or dynamic).*
   - `No blocks` — *Classic admin UI only.*

4. **WooCommerce** — header `WooCommerce`
   - `Yes — WooCommerce + HPOS` — *Add the HPOS compatibility declaration and WC-aware patterns.*
   - `No` — *Standard WordPress plugin.*

**Batch B** (a second AskUserQuestion call, multi-select where noted):

1. **Features to include** — header `Features`, **multiSelect: true**
   - `Settings page` — *Admin menu + options page.*
   - `REST / AJAX endpoints` — *Secure-by-default handlers (via wp-endpoint).*
   - `Custom database table(s)` — *dbDelta schema + migrations (via wp-db).*
   - `Scheduled tasks (WP-Cron)` — *A cron event + scheduler.*

2. **Dev tooling** — header `Tooling`, **multiSelect: true**
   - `Testing (wp-env + PHPUnit)` — *Local Docker WP + WP test suite (via wp-test).*
   - `i18n / translation-ready` — *languages/ + .pot generation (via wp-i18n).*
   - `Plugin Check (PCP)` — *wordpress.org compliance checking (via wp-plugin-check).*
   - `GitHub Actions CI` — *Lint + test workflow on PR.*

> If the user picks "Other" / adds notes on any question, honor them. If they skip a
> question, fall back to the recommended/default option and say so.

### Step 3 — The plugin's purpose (ask in prose)

Ask: **"In a few sentences, what should this plugin actually do?"** Capture the
real feature intent — this is what makes the skeleton *tailored* rather than empty.
From the answer, plan a handful of concrete starter files (e.g. a feature class, a
shortcode, a settings section, a CPT) — **stubs with correct structure**, not full
implementations.

### Step 4 — Propose the plan, then confirm

Print a concise plan and wait for a yes:
- Resolved identity (name, slug, text domain, prefixes).
- Chosen stack + every selected feature/tooling option.
- The **file tree** that will be created.
- The **dependencies** that will be added (composer require-dev, npm deps).
- The **Claude Code setup** files (CLAUDE.md, .claude/settings.json).

Do not write files until the user confirms (or adjusts).

### Step 5 — Generate (compose the other skills)

Create `{slug}/` and build only the selected parts, following the referenced skills
so logic stays DRY:

| Selection | Follow | Produces |
|-----------|--------|----------|
| Always | `wp-scaffold` §2–§9 | Main file + header, bootstrap singleton, activator/deactivator, admin class, composer.json, phpcs.xml.dist, uninstall.php, .gitignore |
| Frontend = React/Vue/Vanilla | `wp-scaffold` §8 (matching path) | package.json + build config + src/ + enqueue wiring |
| Block editor | `wp-block` | `src/{block}/` (block.json, edit/save or render.php) + register_block_type |
| Custom table | `wp-db` | schema create on activation + version-gated migration + prepared CRUD |
| REST/AJAX | `wp-endpoint` | secure controller/handler (permission_callback, nonce, sanitization) |
| Settings page | `wp-scaffold` admin class | options page via Settings API |
| WP-Cron | this skill | `wp_schedule_event` registration + a sample callback |
| Testing | `wp-test` | .wp-env.json, phpunit.xml.dist, tests/bootstrap.php + a smoke test |
| i18n | `wp-i18n` | languages/ + Domain Path + load_plugin_textdomain + .pot note |
| Distribution = wp.org/Both | `wp-readme` | readme.txt (Stable tag = version) |
| GitHub Actions CI | this skill | `.github/workflows/ci.yml` (phpcs + phpunit) |

Merge dependencies intelligently — one `composer.json`, one `package.json` — rather
than overwriting between steps.

### Step 6 — Claude Code project setup (generate these too)

This is the "pre-setup" payoff: the new plugin opens with Claude already oriented.

**`{slug}/CLAUDE.md`** — tailored to the answers:
```markdown
# {Plugin Name}

{one-line description}

## Facts
- Slug / text domain: `{slug}`
- Prefixes: fn `{prefix}_`, class `{Class}_`, const `{PREFIX}_`
- Frontend stack: {React | Vue | Vanilla}
- Build: `{npm run build | npm run dev | (no build step)}`
- Distribution: {wordpress.org | self-hosted | both}
- WooCommerce/HPOS: {yes | no}

## Conventions
- WordPress Coding Standards (tabs, escaping on output, sanitization on input).
- Nonce + capability checks on every REST/AJAX handler.
- Text domain `{slug}` on every user-facing string.
{if custom table}- DB schema changes require bumping `{PREFIX}_DB_VERSION` so migrations run.

## Commands
- Lint:  `composer lint`   Fix: `composer lint:fix`
{if testing}- Test:  `composer test`  (start env: `npm run wp-env start`)
{if build}- Build: `npm run build`  Watch: `{npm start | npm run dev}`

## Toolkit
This project pairs with the kuira-wp-dev-plugin skills (wp-context auto-loads on PHP;
use wp-endpoint / wp-db / wp-block / wp-security-audit / wp-release as needed).
```

**`{slug}/.claude/settings.json`** — sane permissions for WP dev:
```json
{
	"permissions": {
		"allow": [
			"Bash(php:*)", "Bash(composer:*)", "Bash(wp:*)", "Bash(npm:*)",
			"Bash(npx:*)", "Bash(git:*)"
		],
		"deny": [ "Bash(rm -rf /*)", "Bash(chmod -R 777*)" ]
	}
}
```

(Only add an `.mcp.json` if the developer asks for MCP servers — don't assume.)

### Step 7 — Install & verify (confirm before running)

Offer to:
1. `composer install` (so `vendor/bin/phpcs` exists for the on-save WPCS hook).
2. `npm install && npm run build` for React/Vue.
3. `vendor/bin/phpcs` once to confirm the skeleton is clean.

Then summarize: slug, stack, every feature generated, the file tree, the exact
commands to start developing, and the recommended next step (usually
`wp-ui-visual` to design the first screen, or `wp-endpoint` to add the first route).

> Keep generated code as **correct, minimal stubs** — enough structure to run and
> lint clean, with `// TODO` markers where the developer fills in real logic. The
> wizard sets the table; it doesn't cook the whole meal.
