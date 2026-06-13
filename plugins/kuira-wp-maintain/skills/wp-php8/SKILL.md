---
name: wp-php8
description: >
  Check and fix PHP 8.x compatibility in a WordPress plugin. Triggers on "php 8",
  "php8 compatibility", "php compatibility", "upgrade php version", "deprecated php",
  "phpcompatibility", "requires php". Runs PHPCompatibilityWP, flags breaking changes
  (removed each(), stricter type juggling, named args, nullable params), fixes them,
  and updates the Requires PHP header. Opt-in: only runs when asked.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

## PHP 8.x Compatibility

WordPress runs on hosts spanning PHP 7.2–8.3+. PHP 8.0/8.1 introduced changes that
silently break older plugins (warnings become errors, removed functions). This skill
finds and fixes them.

This skill is **explicitly invoked** and confirms before changing code.

### 1. Scan with PHPCompatibility

```bash
composer require --dev --no-update phpcompatibility/phpcompatibility-wp:^2.1 && composer update
vendor/bin/phpcs -p . \
  --standard=PHPCompatibilityWP \
  --runtime-set testVersion 7.4- \
  --extensions=php
```

`testVersion 7.4-` means "7.4 and up" — it reports anything that breaks on any
supported version through 8.3.

### 2. Common PHP 8.0/8.1 breakages to fix

- **`each()` removed (8.0)** — replace with `foreach` / `current()`+`next()`.
- **`create_function()` removed (8.0)** — use a closure.
- **Stricter type errors** — passing `null` to non-nullable internal params now
  throws (e.g. `strlen(null)`, `trim(null)`). Guard with `?? ''` or null checks.
  This is the #1 real-world 8.1 breakage in WP plugins.
- **`{}` string/array access removed (8.0)** — `$str{0}` → `$str[0]`.
- **Optional-before-required param deprecation (8.0)** — reorder so required come first.
- **Dynamic properties deprecated (8.2)** — declare class properties explicitly, or
  add `#[\AllowDynamicProperties]` on classes that genuinely need them.
- **`utf8_encode()`/`utf8_decode()` deprecated (8.2)** — use `mb_convert_encoding()`.

### 3. Verify

- Re-run the PHPCompatibility scan until clean (or only intentional ignores remain).
- If tests exist (`wp-test`), run them on the target PHP version.
- Static analysis (`wp-analyze`) catches many null-to-non-nullable cases too — run it
  if set up.

### 4. Update the headers

Once clean, set the floor accurately:
- Main plugin file: `Requires PHP: 7.4` (or whatever you actually support).
- `readme.txt`: `Requires PHP:` matching.
- `composer.json`: `"require": { "php": ">=7.4" }`.

### Finish

Report findings by severity, what was fixed vs. intentionally ignored, the PHP
version range now verified clean, and the headers updated.
