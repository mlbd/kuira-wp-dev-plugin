# Getting Started

This walks you from zero to a working WordPress plugin, step by step.

---

## 1. Prerequisites

**Required**
- [Claude Code](https://claude.com/claude-code) `>= 2.0.0`
- `git`

**Recommended for the full experience** (each is optional — the toolkit degrades
gracefully if missing):
- **PHP** + **Composer** — for WPCS linting (`phpcs`), static analysis (`phpstan`), and PHPUnit.
- **Node.js** (`>= 18`) — for React/Vue builds and Playwright.
- **Docker** — for `wp-env` (a local WordPress). *Or skip Docker entirely and use
  `wp-playground` instead.*
- **`jq`** — used by the hook scripts. Without it they fall back to `python`, and if
  neither is present they simply skip.

**On Windows:** the hook scripts are Bash and run under **Git Bash** (bundled with
Git for Windows). Everything else works the same.

---

## 2. Install the modules

From inside Claude Code:

```bash
# Add this repository as a plugin marketplace
/plugin marketplace add mlbd/kuira-wp-dev-plugin

# Install the core (everyone needs this)
/plugin install kuira-wp-core@kuira-marketplace
```

Then add any lifecycle stages you want — all optional:

```bash
/plugin install kuira-wp-quality@kuira-marketplace    # testing, analysis, auditing
/plugin install kuira-wp-ship@kuira-marketplace        # release + wordpress.org deploy
/plugin install kuira-wp-maintain@kuira-marketplace    # legacy modernization + debug
```

> **Optional companion — Superpowers.** Powers the `wp-ui-visual` visual companion:
> ```bash
> /plugin marketplace add obra/superpowers-marketplace
> /plugin install superpowers@superpowers-marketplace
> ```

**Expect:** the modules appear when you run `/plugin`.

---

## 3. Verify

```bash
/wp-help
```

**Expect:** a command map listing the skills/agents available from the modules you
installed. If a command you want isn't listed, its module isn't installed.

---

## 4. Build your first plugin with `/wp-new`

This is the fastest path. Type:

```bash
/wp-new
```

Claude runs an **interactive wizard**. Here's what it asks and what to expect:

| Step | You'll be asked | Example answer |
|------|-----------------|----------------|
| Identity | Plugin name, description, author | "Acme Notes", "A simple notes plugin", you |
| Frontend stack | React / Vue / Vanilla | **React** (recommended) |
| Distribution | wordpress.org / self-hosted / both | Both |
| Gutenberg | block or not | No |
| WooCommerce | yes / no | No |
| Features | settings page, REST/AJAX, custom table, cron | Settings + REST + table |
| Quality tooling | testing, E2E, PHPStan, i18n | Testing + PHPStan |
| Ship & integrate | Plugin Check, CI, wp.org deploy, live MCP | (skip for now) |
| Git & commits | manual / auto-commit / never | Manual |
| Purpose | "what should it do?" (free text) | "store short notes per user" |

Then the wizard **shows you a plan** (the file tree + dependencies it will create)
and **waits for your approval** before writing anything.

**Expect after you approve:**
- A new plugin folder with a WPCS-compliant skeleton (main file, bootstrap class,
  admin page, your selected features).
- A `CLAUDE.md` + `.claude/settings.json` so Claude is oriented in the new project.
- A summary telling you the exact next commands to run.

> See [`examples/acme-notes`](../examples/acme-notes) for a complete reference of what
> `/wp-new` produces with a similar configuration.

---

## 5. Build & run it

In the new plugin folder:

```bash
composer install                 # phpcs, phpstan, phpunit
npm install && npm run build     # compile the React admin bundle
```

Then see it live — pick one:

```bash
# Option A: full local WordPress (Docker)
npm run wp-env start             # http://localhost:8888  (admin / password)

# Option B: instant, no Docker
npx @wp-playground/cli@latest server \
  --mount=.:/wordpress/wp-content/plugins/your-slug \
  --blueprint=blueprint.json
```

**Expect:** WordPress opens with your plugin active, landing on its admin page.

---

## 6. What success looks like

- `composer lint` → clean (the on-save hook also auto-fixes as you edit).
- `composer test` → tests pass.
- Your admin screen renders and talks to its REST endpoint with a nonce.

From here, the [Workflows](workflows.md) guide covers adding features, auditing, and
shipping. Stuck? See the [FAQ](faq.md).
