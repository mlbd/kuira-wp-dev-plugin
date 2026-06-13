# Workflows

Task-based recipes. Each shows **what to type**, the **steps**, and **what to expect**.
You talk to Claude in plain language — the trigger phrases just help it pick the right
skill. The module each skill lives in is noted; install it if a command isn't available.

> Throughout: skills **confirm before installing dependencies or changing config**, and
> generated code is **WPCS-compliant and secure by default** (nonces, capability checks,
> sanitization, `$wpdb->prepare`, output escaping).

---

## Build a new plugin (the wizard) · core

```
/wp-new
```
Answer the wizard, approve the plan, done. See [Getting Started §4](getting-started.md).
**Expect:** a complete, runnable plugin skeleton + Claude Code project setup.

## Scaffold without the wizard · core

> "scaffold a new WordPress plugin called Acme Notes using React"

**Steps:** Claude asks for the slug/author + stack, confirms, then generates the skeleton.
**Expect:** main file, bootstrap singleton, admin page, `composer.json`, `phpcs.xml.dist`,
and the React/Vue/vanilla build wiring.

---

## Add a secure REST or AJAX endpoint · core

> "add a REST endpoint to save a note, only for logged-in editors"

**Steps:** Claude asks REST vs AJAX, method, who can call it, and the fields; then writes
the handler.
**Expect:** a controller with a real `permission_callback` (capability check), a nonce
path, and per-argument `sanitize_callback`/validation — code that *passes*
`wp-security-audit` instead of failing it.

## Add a custom database table · core

> "add a custom table for notes with a user_id and title, with migrations"

**Expect:** `dbDelta` schema creation on activation, a **version-gated migration** routine
(so updates apply cleanly), prepared CRUD helpers, and uninstall cleanup. Remember to bump
the `*_DB_VERSION` constant when the schema changes — Claude will remind you.

## Add a Gutenberg block · core

> "create a dynamic Gutenberg block that lists recent notes"

**Expect:** a `block.json` (apiVersion 3) block with the `@wordpress/scripts` build —
`edit`/`save` for static, or a server `render.php` for dynamic — plus `register_block_type`.

## Design the admin UI · core (+ Superpowers)

> "design a settings page for the plugin"

**Steps:** `wp-ui-researcher` surveys your existing UI, then `wp-ui-visual` routes to the
Superpowers visual companion (if installed) for interactive mockups; otherwise a structured
standalone flow. **Run this before writing templates.**
**Expect:** design directions to approve before any code is written.

---

## Write & run tests · quality

**Unit/integration (PHPUnit + wp-env):**
> "set up testing and write a test for the notes table"

**Expect:** `@wordpress/env` + the WP PHPUnit suite configured, a `tests/` smoke test, and
`composer test` runnable.

**End-to-end (Playwright):**
> "add a Playwright test that opens the settings page and saves a note"

**Expect:** `playwright.config.js` + a spec using `@wordpress/e2e-test-utils-playwright`,
run with `npm run test:e2e`.

**Instant preview (no Docker):**
> "preview this plugin in WordPress Playground"

**Expect:** a `blueprint.json` + a one-line Playground CLI command that boots WP in seconds.

## Static analysis · quality

> "run PHPStan on this plugin"

**Expect:** `szepeviktor/phpstan-wordpress` + WP stubs added, a `phpstan.neon.dist` at a
sane level, and a findings report (with the option to baseline legacy code).

## Security & quality review · quality

> "audit the security of this plugin"   ·   `@wp-security-auditor`

**Expect:** a prioritized report (CRITICAL/WARNING/INFO) covering nonces, capabilities,
sanitization, `$wpdb` prepare, REST `permission_callback`, output escaping, file inclusion,
and dependency vulnerabilities (`composer audit`/`npm audit`).

Other auditors: `@wp-code-reviewer` (WPCS/architecture/perf), `@wp-performance-auditor`
(queries-in-loops, option bloat, caching), `@wp-a11y-auditor` (admin UI, WCAG 2.1 AA).

---

## Internationalize · ship

> "make this plugin translation-ready and generate the .pot"

**Expect:** text-domain consistency verified, untranslated strings wrapped, `languages/` +
`.pot` generated, and JS translations wired (`wp_set_script_translations`).

## Generate the WordPress.org readme.txt · ship

> "generate the wordpress.org readme.txt"

**Expect:** a spec-compliant `readme.txt` (header block, ≤150-char short description, all
sections), with validation that Stable tag matches your version and tags ≤ 5.

## Release & deploy to WordPress.org · ship

1. **Bump + package:** > "prepare a patch release"
   **Expect:** version bumped everywhere, CHANGELOG updated, WPCS check, a dist zip.
2. **Pre-submission check:** > "run Plugin Check" (quality module)
   **Expect:** the official wordpress.org review run locally; fix blockers before submitting.
3. **Automate publishing:** > "set up CI and wordpress.org auto-deploy"
   **Expect:** GitHub Actions for lint+PHPStan+PHPUnit on PR, and an SVN deploy on tag —
   plus the list of repo secrets you must add (`SVN_USERNAME`/`SVN_PASSWORD`).

The release ritual: bump (`wp-release`) → sync `readme.txt` (`wp-readme`) →
`git tag X.Y.Z && git push --tags` → Actions deploys.

---

## Maintain an existing plugin · maintain

**Modernize legacy code:**
> "modernize this plugin — OOP and modern syntax, in small steps"
**Expect:** incremental, reviewable refactors (array shorthand, classes, namespacing),
phpcs/tests kept green between batches, breaking changes flagged not made.

**PHP 8.x compatibility:**
> "check this plugin for PHP 8 compatibility"
**Expect:** a PHPCompatibilityWP scan, fixes for the common 8.0/8.1 breakages, and updated
`Requires PHP` headers.

**Debug a runtime error:**
> "enable debugging and tell me why this is throwing a fatal"
**Expect:** `WP_DEBUG` enabled safely (via WP-CLI, not by hand-editing wp-config),
`debug.log` tailed, and the error traced to the responsible line with a fix.

## Document your hooks · ship

> "generate a HOOKS.md for this plugin"

**Expect:** a reference of every `do_action`/`apply_filters` the plugin fires, with
parameters and source locations — your plugin's extensibility API, documented.
