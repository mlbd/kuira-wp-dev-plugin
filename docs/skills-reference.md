# Skill & Agent Reference

Every command in the toolkit: which module it's in, how to trigger it, and what it
produces. **Skills run only when invoked** (except `wp-context`, which is passive), and
each **confirms before installing dependencies or changing config**.

How to trigger a skill: just describe the task in plain language using any of the trigger
phrases. Agents are invoked with `@agent-name`. The `/wp-*` forms are slash commands.

---

## kuira-wp-core — build essentials

| Skill | Trigger (examples) | Produces / does |
|-------|--------------------|-----------------|
| **`/wp-new`** | `/wp-new`, "new plugin wizard" | Interactive wizard → a tailored plugin + Claude Code project setup. The front door. |
| **`wp-scaffold`** | "scaffold a plugin", "create a plugin" | WPCS-compliant skeleton with React/Vue/vanilla build wiring. |
| **`wp-context`** | *(auto-loads on any `.php`)* | Always-on WPCS guidance: tabs, escaping, sanitization, nonce/capability, HPOS. No trigger needed. |
| **`wp-endpoint`** | "add a rest route", "ajax handler" | Secure-by-default REST/AJAX handler (permission_callback, nonce, sanitized args). |
| **`wp-block`** | "create a gutenberg block" | `block.json` block (static or dynamic) with `@wordpress/scripts` build. |
| **`wp-db`** | "custom table", "dbdelta", "migration" | Schema via dbDelta + version-gated migrations + prepared CRUD. |
| **`wp-ui-visual`** | "design", "UI", "admin page layout" | Routes design work to the Superpowers visual companion (or a standalone flow). |
| **`/wp-help`** | `/wp-help`, "list the wp commands" | Read-only map of all skills/agents/hooks. |

**Agent:** `@wp-ui-researcher` (haiku) — surveys existing UI patterns before a design session.

---

## kuira-wp-quality — test, analyze, audit

| Skill | Trigger (examples) | Produces / does |
|-------|--------------------|-----------------|
| **`wp-test`** | "set up testing", "phpunit", "wp-env" | `@wordpress/env` + PHPUnit WP suite + sample tests. |
| **`wp-e2e`** | "playwright", "e2e test" | Playwright config + admin/front UI specs against wp-env. |
| **`wp-playground`** | "playground", "blueprint", "preview without docker" | Instant WASM WordPress + a Blueprint for demos/CI. |
| **`wp-analyze`** | "phpstan", "static analysis" | PHPStan + WP stubs + `phpstan.neon.dist`; finds type/null/logic bugs. |
| **`wp-security-audit`** | "audit security", "is this safe" | Security scan; delegates to the auditor agent. |
| **`wp-plugin-check`** | "plugin check", "ready for submission" | Runs the official wordpress.org Plugin Check. |

**Agents:**
- `@wp-security-auditor` (haiku) — read-only security scan, structured report.
- `@wp-code-reviewer` (sonnet) — WPCS / architecture / performance review.
- `@wp-performance-auditor` (sonnet) — queries-in-loops, autoloaded-option bloat, missing caching.
- `@wp-a11y-auditor` (sonnet) — admin UI accessibility (WCAG 2.1 AA).

---

## kuira-wp-ship — release, publish, docs

| Skill | Trigger (examples) | Produces / does |
|-------|--------------------|-----------------|
| **`wp-release`** | "prepare release", "bump version", "build zip" | Version bump everywhere + CHANGELOG + WPCS check + dist zip. |
| **`wp-deploy`** | "ci", "deploy to wordpress.org" | GitHub Actions CI + wordpress.org SVN deploy on tag (+ `.distignore`). |
| **`wp-readme`** | "readme.txt", "wordpress.org readme" | Spec-compliant `readme.txt` with validation. |
| **`wp-i18n`** | "translation", "make-pot", "i18n" | Text-domain checks, string wrapping, `.pot`, JS translations. |
| **`wp-hook-docs`** | "document hooks", "hook reference" | `HOOKS.md` of every action/filter the plugin fires. |

---

## kuira-wp-maintain — legacy, debug

| Skill | Trigger (examples) | Produces / does |
|-------|--------------------|-----------------|
| **`wp-modernize`** | "modernize", "refactor legacy", "convert to OOP" | Incremental syntax/structure/namespacing modernization. |
| **`wp-php8`** | "php 8 compatibility" | PHPCompatibilityWP scan + fixes; updates `Requires PHP`. |
| **`wp-debug`** | "enable debug", "debug.log", "fatal error" | Enables WP_DEBUG safely + reads/interprets the log. |

---

## Hooks (kuira-wp-core, except where noted)

Hooks are deterministic and **low-noise** — they only speak when there's something to say.

| Hook | When | What it does |
|------|------|--------------|
| **SessionStart** | opening a project | If you're in a WP plugin with uninstalled `composer`/`npm` deps, reminds you to install them. Silent otherwise. |
| **PreToolUse (Bash)** | before a shell command | **bash-guard** blocks dangerous commands (`rm -rf` on system paths, `DROP TABLE`, curl-pipe-to-shell, `wp-config` edits, `chmod 777`). |
| **PreToolUse (Bash)** *(quality)* | before `git commit` | **commit-gate** (opt-in, `KUIRA_COMMIT_GATE=1`) blocks commits with PHP syntax/WPCS errors. Off by default. |
| **PostToolUse (PHP write)** | after editing a `.php` file | Fast `php -l` syntax check, then phpcs → auto-fix with phpcbf. |
| **Stop** | task complete | Desktop notification (Linux/macOS/Windows). |

**Optional statusline:** `statusline.sh` (in core) shows the current plugin name + version.
Enable via `/statusline` or a `statusLine` entry in your settings — it's not auto-enabled.

---

## A note on how skills behave

These are **AI-driven** skills, not deterministic generators. The toolkit gives Claude the
right procedure, standards, and code patterns — but Claude still reads your project and
adapts. That means output is high-quality and context-aware, and also that you should
**review what it produces** (it generates correct, secure stubs with `// TODO`s where your
business logic goes — it sets the table, you cook the meal). See the [FAQ](faq.md) for more
on expectations.
