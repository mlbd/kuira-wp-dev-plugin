---
name: wp-help
description: >
  Explain the kuira WordPress toolkit — list every skill, agent, hook, and how they
  fit the plugin lifecycle. Invoke as /wp-help, or triggers on "what can this plugin
  do", "list the wp commands", "kuira help", "which skill should I use", "wp toolkit
  overview". A read-only orientation guide; it changes nothing.
allowed-tools: Read, Glob
model: haiku
---

## kuira WP Dev Toolkit — Command Map

When invoked, give the user this overview (tailor it to what they're asking). Nothing
here modifies files — it's pure orientation. The single best entry point is **`/wp-new`**.

This toolkit is **four installable plugins** — install only what you need:
- **kuira-wp-core** — Build + UI + help (this module). `/plugin install kuira-wp-core@kuira-marketplace`
- **kuira-wp-quality** — Quality & correctness (test/analyze/audit). `…install kuira-wp-quality@…`
- **kuira-wp-ship** — Ship (release/deploy/docs). `…install kuira-wp-ship@…`
- **kuira-wp-maintain** — Maintain (modernize/php8/debug). `…install kuira-wp-maintain@…`

If a command below isn't available, its module probably isn't installed — tell the
user which plugin provides it.

### Start here (kuira-wp-core)
- **`/wp-new`** — interactive wizard: asks your stack/distribution/features/tooling/
  commit preference, takes a description, then generates a tailored plugin + Claude
  Code setup. Composes the skills below.

### Build (codegen)
- **`wp-scaffold`** — full plugin skeleton (React / Vue / vanilla).
- **`wp-endpoint`** — secure REST/AJAX handler (auth + nonce + sanitization).
- **`wp-block`** — Gutenberg block (`block.json`, static or dynamic).
- **`wp-db`** — custom tables via dbDelta + version-gated migrations.

### Quality & correctness
- **`wp-context`** — auto-loads on PHP; enforces WPCS as you write.
- **`wp-analyze`** — PHPStan static analysis (type/null/logic bugs).
- **`wp-security-audit`** — security scan (+ `@wp-security-auditor` agent).
- **`wp-test`** — wp-env + PHPUnit (unit/integration).
- **`wp-e2e`** — Playwright browser tests (admin/front UI).
- **`wp-playground`** — instant WASM WordPress + Blueprints (Docker-free demos/testing).

### Polish & docs
- **`wp-ui-visual`** — route UI/UX design to the visual companion.
- **`wp-i18n`** — translation readiness + `.pot`.
- **`wp-readme`** — WordPress.org `readme.txt`.
- **`wp-hook-docs`** — generate a `HOOKS.md` reference of every action/filter fired.

### Maintain & modernize
- **`wp-modernize`** — procedural→OOP, modern syntax, namespacing (incremental).
- **`wp-php8`** — PHP 8.x compatibility check + fixes.
- **`wp-debug`** — enable WP_DEBUG, read/interpret debug.log.

### Ship
- **`wp-plugin-check`** — official Plugin Check (wordpress.org guidelines).
- **`wp-release`** — version bump + CHANGELOG + dist zip.
- **`wp-deploy`** — GitHub Actions CI + wordpress.org SVN deploy on tag.

### Agents (invoke with `@`)
- **`@wp-security-auditor`** (haiku) — security scan.
- **`@wp-code-reviewer`** (sonnet) — WPCS/architecture/perf review.
- **`@wp-ui-researcher`** (haiku) — survey UI patterns before design.
- **`@wp-performance-auditor`** (sonnet) — queries-in-loops, option bloat, caching.
- **`@wp-a11y-auditor`** (sonnet) — admin UI accessibility (WCAG 2.1 AA).

### Hooks (automatic, low-noise)
- **SessionStart** — reminds you to `composer install` / `npm install` if deps are missing (silent otherwise).
- **PreToolUse(Bash)** — blocks dangerous commands; an optional commit quality-gate (off unless `KUIRA_COMMIT_GATE=1`).
- **PostToolUse(PHP)** — `php -l` syntax check + WPCS auto-fix on save.
- **Stop** — desktop notification (Linux/macOS/Windows).

### Opt-in philosophy
Everything except `wp-context` (passive WPCS) and the low-noise hooks is **opt-in** —
skills run only when you invoke them, generated-plugin features are chosen in
`/wp-new`, and the commit-gate is off by default. Nothing is forced.

> Tip: an optional WP-aware statusline ships as `statusline.sh` — enable it via
> `/statusline` or the `statusLine` setting if you want the current plugin + version
> in your status bar.
