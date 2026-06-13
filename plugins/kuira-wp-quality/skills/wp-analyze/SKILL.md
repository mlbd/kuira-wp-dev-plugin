---
name: wp-analyze
description: >
  Run PHPStan static analysis on a WordPress plugin. Triggers on "static analysis",
  "phpstan", "type check", "analyse", "find bugs", "psalm", "level up code quality".
  Adds szepeviktor/phpstan-wordpress + WordPress stubs, generates phpstan.neon,
  runs the analysis, interprets findings, and can baseline legacy code. Catches
  type/null/logic bugs that WPCS structurally cannot. Opt-in: only runs when asked,
  and confirms before adding dependencies.
allowed-tools: Read, Write, Bash, Grep, Glob
model: sonnet
---

## PHPStan Static Analysis for WordPress

WPCS checks *style*; PHPStan checks *correctness* — undefined methods, wrong argument
types, null dereferences, unreachable code. It's now common across the WP ecosystem
and is being proposed for WordPress core's own workflow, so it's a safe, modern add.

This skill is **explicitly invoked** and confirms before touching `composer.json`.

### 1. Add the dependencies

```bash
composer require --dev --no-update \
  szepeviktor/phpstan-wordpress:^2.0 \
  php-stubs/wordpress-stubs:^6.5
composer update
```

Add WooCommerce stubs too if the plugin targets WC:
```bash
composer require --dev --no-update php-stubs/woocommerce-stubs:^9.0 && composer update
```

`szepeviktor/phpstan-wordpress` pulls in PHPStan itself and teaches it WP's dynamic
patterns (hooks, `$wpdb`, conditional functions).

### 2. Generate `phpstan.neon.dist`

```neon
includes:
	- vendor/szepeviktor/phpstan-wordpress/extension.neon

parameters:
	level: 5
	paths:
		- includes
		- admin
		- public
		- %currentWorkingDirectory%/{slug}.php
	scanDirectories:
		- vendor/php-stubs
	bootstrapFiles:
		- %currentWorkingDirectory%/{slug}.php
	# Ignore patterns WP makes unavoidable; trim as you raise the level.
	ignoreErrors:
		- '#Function (apply_filters|do_action) invoked with#'
```

Start at **level 5** (sane for existing plugins). Raise toward 8–9 as the code
gets cleaner; each level finds stricter classes of bug.

Add a composer script:
```json
"scripts": { "analyze": "phpstan analyse --memory-limit=1G" }
```

### 3. Run and interpret

```bash
composer analyze        # or: vendor/bin/phpstan analyse
```

Triage the output by class of problem, not line by line:
- **Undefined method/property** → usually a typo or a missing null check on a
  `get_post()` / `wc_get_order()` that can return false/null.
- **Wrong argument type** → a sanitizer returning the wrong shape, or `$_POST` used
  without a cast.
- **Always-true/false condition / dead code** → a logic bug or leftover.

Fix the real bugs; only add to `ignoreErrors` when a finding is a genuine WP false
positive (document why inline).

### 4. Baseline legacy code (optional)

For an existing plugin with many findings, snapshot them so new code is held to the
bar without forcing a big-bang cleanup:
```bash
vendor/bin/phpstan analyse --generate-baseline
```
This writes `phpstan-baseline.neon` (include it in `phpstan.neon.dist`). Burn the
baseline down over time.

### 5. Finish

Report the level, the count of findings by category, what you fixed vs. baselined,
and the single highest-value next fix. Suggest wiring `composer analyze` into CI
(see `wp-deploy`) so regressions are caught on every PR.
