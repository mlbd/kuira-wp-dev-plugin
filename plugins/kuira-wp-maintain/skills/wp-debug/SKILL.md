---
name: wp-debug
description: >
  Turn on WordPress debugging and diagnose runtime errors. Triggers on "enable debug",
  "wp_debug", "debug.log", "white screen", "fatal error", "why is this breaking",
  "check the error log", "debugging". Enables WP_DEBUG safely (via WP-CLI / wp-env,
  not by hand-editing wp-config), tails and interprets debug.log, and traces errors
  to the responsible plugin code. Opt-in: only runs when asked.
allowed-tools: Read, Bash, Grep, Glob
model: sonnet
---

## WordPress Runtime Debugging

When something breaks at runtime — white screen, a fatal, unexpected behavior — the
answer is usually in `debug.log`. This skill enables debugging and reads it.

This skill is **explicitly invoked**. Note: editing `wp-config.php` with `sed`/`awk`
is blocked by the toolkit's bash guard for safety — use WP-CLI (`wp config set`),
which is safe and idempotent, or edit the file by hand.

### 1. Enable debugging (non-destructive)

Via WP-CLI (works inside `wp-env run cli` too):
```bash
wp config set WP_DEBUG true --raw --type=constant
wp config set WP_DEBUG_LOG true --raw --type=constant
wp config set WP_DEBUG_DISPLAY false --raw --type=constant   # log, don't leak to screen
wp config set SCRIPT_DEBUG true --raw --type=constant         # unminified JS/CSS
```

> `WP_DEBUG_DISPLAY false` + `WP_DEBUG_LOG true` is the right combo: errors go to
> `wp-content/debug.log`, never to visitors.

### 2. Watch the log

```bash
# Find it
ls -la wp-content/debug.log 2>/dev/null || echo "no debug.log yet — reproduce the issue first"

# Tail while reproducing
tail -n 100 -f wp-content/debug.log
```

### 3. Interpret — map the error to your code

For each entry, identify:
- **Type:** `Fatal error` (stops execution) vs `Warning`/`Notice`/`Deprecated` (noise
  that can still hide bugs).
- **Origin:** the file/line. Filter to *this* plugin:
  ```bash
  grep "{slug}" wp-content/debug.log | tail -30
  ```
- **Common WP fatals & causes:**
  - `Call to undefined function ...` — calling a WP/WC function before it's loaded
    (hook too early; move to `plugins_loaded`/`init`).
  - `Cannot redeclare ...` — double include; guard with `class_exists`/`function_exists`.
  - `Allowed memory size exhausted` — an unbounded query/loop (see `wp-db`, or add
    `posts_per_page` limits).
  - `Trying to access array offset on null` (8.1) — see `wp-php8`.

### 4. Other signals

- **Query Monitor** plugin — install for in-browser query/hook/HTTP inspection:
  `wp plugin install query-monitor --activate`.
- Slow admin/front page → suspect queries-in-loops or missing transients
  (delegate to the `wp-performance-auditor` agent).

### 5. Finish

Report the root cause (not just the symptom), the exact file:line, the fix, and
whether to turn `WP_DEBUG` back off afterward (`wp config set WP_DEBUG false --raw`)
on anything resembling production.
