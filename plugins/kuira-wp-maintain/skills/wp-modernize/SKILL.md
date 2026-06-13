---
name: wp-modernize
description: >
  Modernize legacy WordPress plugin code. Triggers on "modernize", "refactor legacy",
  "convert to OOP", "clean up old code", "array shorthand", "add namespacing",
  "update coding style". Incrementally moves procedural code toward classes, applies
  modern PHP syntax, and tightens structure — verifying with WPCS/tests after each
  step. Opt-in: only runs when asked, works in small reviewable batches, never a
  big-bang rewrite.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

## Modernize Legacy WordPress Code

Legacy plugins accrete global functions, `array()` everywhere, and no autoloading.
This skill modernizes **incrementally and safely** — small batches, lint/tests
green between each, so behavior never silently changes.

This skill is **explicitly invoked**. Before refactoring, confirm scope and make
sure there's a way to verify (tests via `wp-test`, or at least a clean phpcs run).

### Guardrails (state these up front)

- Work in **small, reviewable steps** — one concern at a time, not the whole plugin.
- **Preserve all public hook names and function signatures** other code/themes depend
  on. Renaming a hook or a public function is a breaking change — flag it, don't do it
  silently.
- Run `vendor/bin/phpcbf` + `vendor/bin/phpcs` (and tests, if present) after each batch.
- Keep behavior identical — this is refactoring, not feature work.

### Modernization passes (apply the ones the user wants)

**1. Syntax (low-risk, mechanical)**
- `array()` → `[]` (WPCS `Generic.Arrays.DisallowLongArraySyntax` autofixes this).
- Yoda conditions where WPCS requires them.
- Add type declarations on new/internal methods where safe (params + return).
- `phpcbf` handles most of this — run it first and review the diff.

**2. Structure (medium-risk)**
- Group related global functions into a class with `::get_instance()` or static
  methods; keep thin wrapper functions so external callers don't break.
- Replace scattered `global $var` with class properties or the options API.
- Extract long functions (>30 lines) into named private methods.

**3. Autoloading & namespacing (higher-risk — confirm explicitly)**
- Introduce a `Vendor\Plugin` namespace and PSR-4 autoloading via composer:
  ```json
  "autoload": { "psr-4": { "{Vendor}\\{Plugin}\\": "includes/" } }
  ```
- Migrate class files to `class-name.php` → namespaced classes one at a time.
- Keep `class_alias()` for any renamed public class until a major version.

**4. Replace deprecated APIs**
- Swap deprecated WP functions for current equivalents (e.g. `get_page()` →
  `get_post()`, `wp_get_http()` → `wp_remote_get()`).
- For WooCommerce: direct `$order->post` / `get_post_meta` on orders → CRUD methods
  (`$order->get_meta()`), which is also HPOS-safe.

### Finish

Report each batch applied, confirm phpcs/tests are green, and list anything that
*would* be a breaking change (so the user can decide to defer it to a major version).
Suggest `wp-php8` next if targeting newer PHP, and `wp-test` to lock behavior before
deeper refactors.
