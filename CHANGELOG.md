# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `wp-new` skill — interactive `/wp-new` wizard. Runs a multi-step onboarding
  (frontend stack, wordpress.org vs self-hosted, Gutenberg blocks, WooCommerce,
  features, dev tooling, and git-commit behavior), takes a free-text plugin
  description, confirms a plan, then generates a tailored plugin file structure
  (composing the focused skills) plus the Claude Code project setup (`CLAUDE.md` +
  `.claude/settings.json`). The commit choice is honored: **manual** (default,
  Claude never commits unasked), **auto-commit** (adds a Stop hook), or **never**
  (no git init; `git commit`/`push` denied).
- `wp-scaffold` skill — generates a complete, WPCS-compliant new-plugin skeleton
  (main file + header, singleton bootstrap class, activator/deactivator, an admin
  page that enqueues assets, `composer.json` wired to WPCS, `phpcs.xml.dist`, optional
  WooCommerce/HPOS).
- `wp-scaffold` frontend-stack selection — wires up a full build pipeline for the
  developer's choice of **React** (`@wordpress/scripts`), **Vue** (Vite), or **vanilla**
  (jQuery + CSS), including the admin mount point and a `wp_localize_script` REST
  URL + nonce payload so the API is callable from the first line of JS.
- `wp-readme` skill — generates/validates a spec-compliant WordPress.org `readme.txt`
  (header block, short description, sections, changelog, upgrade notice; checks
  Stable tag ↔ version, ≤5 tags, required headers).
- Six opt-in lifecycle skills (run only when explicitly asked, confirm before
  installing dependencies):
  - `wp-endpoint` — secure-by-default REST/AJAX handler scaffolder (permission_callback,
    nonce, capability, per-arg sanitization).
  - `wp-block` — Gutenberg block scaffolder (`block.json` apiVersion 3, static/dynamic).
  - `wp-db` — `dbDelta` schema creation, version-gated migrations, prepared CRUD, uninstall.
  - `wp-test` — `@wordpress/env` local WP + PHPUnit WordPress test suite, with REST/AJAX tests.
  - `wp-i18n` — text-domain verification, string wrapping, `.pot` generation, JS translations.
  - `wp-plugin-check` — runs the official Plugin Check (PCP) against wordpress.org guidelines.
- `CONTRIBUTING.md`, `CHANGELOG.md`, and GitHub issue/PR templates for the public
  open-source release.

### Changed
- Rewrote `README.md` around the `/plugin marketplace add` install flow and the
  scaffold-first workflow.
- Genericized `wp-context` and `wp-ui-visual` — removed hardcoded private product
  names, text domains, and slugs in favor of neutral placeholders.

### Removed
- `oasis-workflow` skill and all references to specific commercial plugins, so the
  release contains no proprietary/internal content.

### Fixed
- `bash-guard.sh` `rm -rf` guard: replaced an unsupported `grep -E` negative
  lookahead (which silently never matched) with a portable match + `/tmp` allow-list.

## [1.0.0] - 2026-06-13

### Added
- Initial release: `wp-context`, `wp-ui-visual`, `wp-release`, `wp-security-audit`
  skills; `wp-security-auditor`, `wp-code-reviewer`, `wp-ui-researcher` agents;
  PreToolUse/PostToolUse/Stop hooks; GitHub + Fetch MCP servers.
