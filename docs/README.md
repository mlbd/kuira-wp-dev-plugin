# Kuira WP Dev Toolkit — Documentation

A Claude Code marketplace of four modular plugins for **WordPress plugin development** —
scaffold, build, test, audit, and ship WP plugins without leaving Claude Code.

## Start here

1. **[Getting Started](getting-started.md)** — prerequisites, install the modules, and
   build your first plugin with `/wp-new`, step by step (with what to expect at each step).
2. **[Workflows](workflows.md)** — task-based recipes: add an endpoint, a block, a custom
   table; write tests; audit security; ship to WordPress.org; modernize legacy code.
3. **[Skill & Agent Reference](skills-reference.md)** — every command: what it does, how to
   trigger it, an example prompt, and what it produces.
4. **[FAQ & Expectations](faq.md)** — what you can do, what it *won't* do, requirements,
   Windows notes, cost, troubleshooting, and how to disable things.

## The four modules at a glance

| Module | Install to… | Key commands |
|--------|-------------|--------------|
| **kuira-wp-core** ⭐ | build a plugin | `/wp-new`, `wp-scaffold`, `wp-endpoint`, `wp-block`, `wp-db`, `wp-ui-visual`, `/wp-help` |
| **kuira-wp-quality** | test & audit | `wp-test`, `wp-e2e`, `wp-playground`, `wp-analyze`, `wp-security-audit`, `wp-plugin-check` |
| **kuira-wp-ship** | release & publish | `wp-release`, `wp-deploy`, `wp-readme`, `wp-i18n`, `wp-hook-docs` |
| **kuira-wp-maintain** | fix old code | `wp-modernize`, `wp-php8`, `wp-debug` |

> **Mental model:** this toolkit gives Claude *WordPress expertise + guardrails*. You
> describe what you want in plain language; Claude follows the toolkit's skills to
> produce WPCS-compliant, secure-by-default code — and you stay in control (it confirms
> before installing dependencies or changing config, and never commits unless you ask).

## For contributors

See **[AUTHORING.md](AUTHORING.md)** for how to add a skill, agent, or hook, and the
conventions CI enforces.
