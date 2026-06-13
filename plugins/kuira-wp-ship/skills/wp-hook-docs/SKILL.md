---
name: wp-hook-docs
description: >
  Generate a developer reference of every action and filter a plugin fires. Triggers
  on "document hooks", "hook reference", "list all hooks", "do_action filters docs",
  "generate HOOKS.md", "extensibility docs". Scans for do_action/apply_filters,
  extracts names, parameters, and surrounding docblocks, and writes a HOOKS.md so
  other developers can extend the plugin. Opt-in: only runs when asked.
allowed-tools: Read, Write, Bash, Grep, Glob
model: sonnet
---

## Hook Reference Generator

A plugin's hooks are its public API for other developers. Undocumented hooks may as
well not exist. This skill produces a `HOOKS.md` from the source.

This skill is **explicitly invoked**.

### 1. Find every hook the plugin fires

```bash
grep -rnE "do_action(_ref_array)?\(|apply_filters(_ref_array)?\(" --include="*.php" . \
  | grep -v "/vendor/" | grep -v "/node_modules/"
```

Capture, for each:
- **Name** — the first string argument (note dynamic names like `"{$prefix}_save"`).
- **Type** — action (`do_action`) or filter (`apply_filters`).
- **Parameters** — the args passed after the name.
- **Context** — the `file:line` and the docblock directly above the call, if any.

> Distinguish hooks the plugin **fires** (its API) from core/third-party hooks it
> only **listens to** (`add_action`/`add_filter`) — document the former.

### 2. Prefer existing docblocks

WordPress convention is to document a hook inline right above it:
```php
/**
 * Fires before an item is saved.
 *
 * @param int   $item_id The item ID.
 * @param array $data    The sanitized data.
 */
do_action( '{prefix}_before_save', $item_id, $data );
```
Use that docblock when present. Where one is missing, infer a description from the
surrounding code and **flag it** so the developer can confirm/improve it.

### 3. Write `HOOKS.md`

```markdown
# Hooks Reference — {Plugin Name}

Hooks this plugin provides for extending its behavior.

## Actions

### `{prefix}_before_save`
Fires before an item is saved.

| Param | Type | Description |
|-------|------|-------------|
| `$item_id` | int | The item ID. |
| `$data` | array | The sanitized data. |

**Source:** `includes/class-foo.php:120`

## Filters

### `{prefix}_save_args`
Filters the arguments before saving. Return the modified array.

| Param | Type | Description |
|-------|------|-------------|
| `$args` | array | The save arguments. |

**Source:** `includes/class-foo.php:98`
```

### 4. Finish

Report how many actions/filters were documented, which lacked docblocks (so the
developer can add them at the source — the durable fix), and suggest committing
`HOOKS.md` and linking it from the README.
