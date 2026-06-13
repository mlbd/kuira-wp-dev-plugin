---
name: wp-i18n
description: >
  Make a WordPress plugin translation-ready (internationalization). Triggers on
  "translation", "i18n", "internationalization", "make-pot", "pot file", "translate",
  "text domain check", "localization", "languages", "translatable strings". Verifies
  text-domain consistency, wraps untranslated strings, generates the .pot template,
  and wires up JavaScript translations. Opt-in: only runs when asked.
allowed-tools: Read, Write, Bash, Grep, Glob
model: sonnet
---

## WordPress Internationalization (i18n)

Goal: every user-facing string is translatable, uses the **one** correct text
domain, and the plugin ships a `.pot` template so translators (and
translate.wordpress.org) can work.

### 1. Confirm the text domain

The text domain must equal the plugin slug (folder name) and appear in the header
`Text Domain:`. Verify it's consistent:

```bash
grep -rn "Text Domain:" --include="*.php" .
# Find translation calls using a DIFFERENT domain than {slug}
grep -rnE "__\(|_e\(|esc_html__\(|esc_attr__\(|_x\(|_n\(" --include="*.php" . \
  | grep -v "'{slug}'" | head -40
```

Flag mismatches. `WordPress.WP.I18n` in the WPCS ruleset (set up by `wp-scaffold`)
catches most of these on save via the `wpcs-check` hook.

### 2. Find unwrapped strings

Look for human-facing output not passing through a translation function:

```bash
# echo/printf of bare quoted strings (candidates for translation)
grep -rnE "echo\s+'(.*[a-zA-Z]{3,}.*)'|esc_html__\(\s*\"" --include="*.php" . | head -30
```

Wrap them with the right function:
- `__( 'text', '{slug}' )` — return a string
- `esc_html__( 'text', '{slug}' )` — return, escaped for HTML
- `esc_attr__( 'text', '{slug}' )` — return, escaped for an attribute
- `_e( 'text', '{slug}' )` / `esc_html_e()` — echo
- `_x( 'text', 'context', '{slug}' )` — disambiguate by context
- `_n( 'one', 'many', $count, '{slug}' )` — pluralization
- Use `printf` + `%s` placeholders, **never** concatenate translated fragments.

> Translation functions must run **after** `init` (not at file load). Loading
> translations too early is a common Plugin Check failure.

### 3. Load the text domain

For a plugin hosted on wordpress.org targeting WP 4.6+, translations load
automatically — but an explicit load is still correct for off-directory plugins:

```php
add_action(
	'init',
	function () {
		load_plugin_textdomain( '{slug}', false, dirname( plugin_basename( {PREFIX}_FILE ) ) . '/languages' );
	}
);
```

Ensure the header has `Domain Path: /languages` and the `languages/` dir exists.

### 4. Generate the `.pot` template

With WP-CLI (preferred):
```bash
wp i18n make-pot . languages/{slug}.pot --slug={slug} --domain={slug}
```

This scans PHP **and** JS/JSX. Re-run it whenever strings change. Translators then
produce `{slug}-{locale}.po/.mo` (e.g. `{slug}-fr_FR.mo`) in `languages/`.

### 5. JavaScript translations (React/Vue/build-step plugins)

```js
import { __ } from '@wordpress/i18n';
const label = __( 'Save', '{slug}' );
```

Tell WordPress to load JS translations for the enqueued handle:
```php
wp_set_script_translations( '{slug}-admin', '{slug}', {PREFIX}_DIR . 'languages' );
```

Generate the JSON translation files from `.po` with `wp i18n make-json languages/`.

### 6. Finish

Report: text domain used, count of strings now wrapped, whether the `.pot` was
generated, and any remaining unwrapped strings worth a human decision (e.g. strings
that are intentionally not translatable like option keys or hook names).
