---
name: wp-plugin-check
description: >
  Run the official WordPress Plugin Check (PCP) against a plugin before submitting
  to the wordpress.org directory. Triggers on "plugin check", "PCP", "wordpress.org
  guidelines", "ready for submission", "directory review", "plugin review",
  "submit to wordpress.org", "is my plugin compliant". Runs the same automated
  checks wordpress.org runs on submission and maps results to fix priorities.
  Opt-in: only runs when asked, and confirms before installing the checker.
allowed-tools: Read, Bash, Grep, Glob
model: sonnet
---

## WordPress Plugin Check (PCP)

[Plugin Check](https://wordpress.org/plugins/plugin-check/) is the official tool
from the WordPress.org plugins team. It runs the same automated review your plugin
faces on submission, so passing it removes the most common rejection reasons.

This skill is **explicitly invoked** and confirms before installing the checker.
It complements `wp-security-audit` (security depth) — PCP covers directory
*guidelines* (i18n, readme, prohibited functions, sanitization/escaping, etc.).

### 1. Make the checker available

Preferred — via WP-CLI inside `wp-env` (no global install):
```bash
wp-env run cli wp plugin install plugin-check --activate
```

Or globally on a live/local site:
```bash
wp plugin install plugin-check --activate
```

If neither WP-CLI nor wp-env is present, tell the user PCP needs a WordPress
context (suggest the `wp-test` skill to set up `wp-env` first) and stop — don't
fake the results.

### 2. Run the check

```bash
# Inside wp-env:
wp-env run cli wp plugin check {slug}

# Or directly:
wp plugin check {slug}
```

Useful flags:
- `--format=json` — machine-readable, easier to summarize.
- `--categories=security,plugin_repo` — scope to specific categories.
- `--severity=error` — show only blockers.

### 3. Check categories

| Category | What it flags |
|----------|---------------|
| `general` | PHP errors, file structure, `Requires` headers |
| `security` | Unescaped output, unsanitized input, nonce gaps, prohibited functions |
| `plugin_repo` | readme.txt validity, Stable tag, trademark/naming, "Tested up to" |
| `i18n` | Wrong/missing text domain, untranslated strings, late translation loading |
| `performance` | Enqueue practices, autoloaded option bloat |
| `accessibility` | Admin UI a11y (when applicable) |

### 4. Triage the output

- **ERROR** → must fix before submission; wordpress.org will reject otherwise.
- **WARNING** → fix before submission; many are guideline requirements in practice.
- For each finding, report `file:line`, the rule code, and a concrete fix. Where
  a fix is mechanical (escaping, text domain), offer to apply it — but route any
  security finding back through `wp-security-audit` for a deeper look.

### 5. Re-run until clean

After applying fixes, re-run the check and report the before/after counts. Finish
with a short readiness verdict: "PCP clean — ready to submit" or "N errors / M
warnings remain," plus the single highest-priority item to address next.

> PCP is necessary but not sufficient: it's automated. A human review on
> wordpress.org may still raise issues it can't detect. Treat a clean PCP run as
> the floor, not the ceiling.
