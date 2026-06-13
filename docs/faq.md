# FAQ & Expectations

Honest answers about what this toolkit does, what it doesn't, and what to expect.

---

## What is this, exactly?

A set of **Claude Code plugins** — Markdown skills, agent definitions, JSON config, and
shell hooks. It doesn't run as a server or a WordPress plugin. It configures *Claude* with
WordPress expertise, secure-by-default code patterns, and guardrails, so that when you ask
Claude to do WP work, it does it the right way.

## What can I do with it?

End to end across a plugin's life:
- **Create** a new plugin (`/wp-new`) — React/Vue/vanilla, optionally with blocks,
  WooCommerce/HPOS, settings, REST/AJAX, custom tables, cron.
- **Build** features — secure endpoints, Gutenberg blocks, custom tables/migrations.
- **Design** admin UI with a visual companion.
- **Test** — PHPUnit (wp-env), Playwright E2E, instant Playground previews.
- **Verify** — PHPStan static analysis; security/code/performance/accessibility audits;
  the official Plugin Check.
- **Ship** — version bump + dist zip, readme.txt, i18n, GitHub Actions CI, wordpress.org
  auto-deploy.
- **Maintain** — modernize legacy code, fix PHP 8.x compatibility, debug runtime errors.

## What does it *not* do?

- It **doesn't replace your judgment.** Generated code is correct, secure scaffolding with
  `// TODO`s where your real business logic goes. Review it.
- It **doesn't host or run WordPress for you** beyond launching `wp-env`/Playground locally.
- It **isn't a substitute for real testing.** It sets up and writes tests; you should run
  them and add coverage for your actual features.
- It **doesn't guarantee wordpress.org approval** — Plugin Check catches the automated
  blockers, but a human review may still raise issues.
- The auditors are **heuristic scanners**, not formal verification. They catch the common,
  high-value issues; they're a strong floor, not a proof of security.

## What should I expect from generated code?

- **WPCS-compliant** (tabs, escaping, sanitization) — the on-save hook even auto-fixes.
- **Secure by default** — nonces, capability checks, `permission_callback`, `$wpdb->prepare`.
- **Minimal but correct** — runnable, lint-clean skeletons, not finished features.
- **Context-aware** — Claude reads your existing code and adapts, so exact output varies
  between runs and projects. That's a feature (it fits your project) and a reason to review.

## Do I have to install all four modules?

No. Install **kuira-wp-core** and add the others only if you want them. Skills are inert
until invoked, so extra modules cost you nothing at rest — but installing only what you use
keeps `/wp-help` focused.

## Will it do things without asking?

No surprises by design:
- Skills that install dependencies or change config **confirm first**.
- `/wp-new` shows a **plan and waits for approval** before writing files.
- It **never commits** unless you ask (and `/wp-new` lets you pick manual / auto-commit /
  never — the "never" option even denies `git commit`).
- Hooks are **low-noise**: SessionStart is silent unless deps are missing; the commit gate
  is **off** unless you set `KUIRA_COMMIT_GATE=1`.

## What are the requirements?

Only **Claude Code ≥ 2.0** and `git` are required. PHP/Composer, Node, Docker, and `jq` are
optional and unlock more — the toolkit degrades gracefully without them (a missing tool
means a skill skips that step, never an error).

## Does it work on Windows?

Yes. The hook scripts are Bash and run under **Git Bash** (bundled with Git for Windows).
The toolkit specifically handles the Windows Store `python3` stub and includes a Windows
(BurntToast) path for the completion notification.

## How much does it cost?

It's free and open source (GPL-2.0-or-later). It does consume Claude usage like any other
work — the auditor agents deliberately use cheaper models (haiku) for file traversal to
keep scans inexpensive.

## How do I see everything available?

Run **`/wp-help`** for the full command map of whatever modules you've installed.

## Troubleshooting

- **A command isn't recognized** → its module probably isn't installed. `/wp-help` lists
  what's available; install the relevant `kuira-wp-*` module.
- **The WPCS hook does nothing on save** → `phpcs` isn't installed. Run `composer install`
  in the plugin (the SessionStart hook reminds you).
- **`wp-env` won't start** → Docker isn't running. Use `wp-playground` for a Docker-free
  alternative.
- **Hooks seem inactive** → on Windows, confirm you're running Claude Code with Git Bash
  available; the scripts also need `jq` or `python` to parse tool input (else they skip).
- **The commit gate is blocking me** → it's opt-in; unset `KUIRA_COMMIT_GATE` to disable.

## How do I disable or remove things?

- **A whole module:** `/plugin uninstall kuira-wp-<module>@kuira-marketplace`.
- **The commit gate:** unset `KUIRA_COMMIT_GATE` (it's off by default anyway).
- **The statusline:** it's off unless you enabled it; remove the `statusLine` setting.

## How do I contribute or report a problem?

See [CONTRIBUTING.md](../CONTRIBUTING.md) and [AUTHORING.md](AUTHORING.md). Report security
issues privately per [SECURITY.md](../SECURITY.md).
