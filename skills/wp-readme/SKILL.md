---
name: wp-readme
description: >
  Generate or fix a WordPress.org-format readme.txt. Triggers on "readme.txt",
  "wordpress.org readme", "wp.org readme", "plugin readme", "generate readme",
  "stable tag", "tested up to", "upgrade notice", "plugin directory listing".
  Produces a spec-compliant readme.txt (header block, short description, sections,
  changelog, upgrade notice) and validates it against WordPress.org rules. Note:
  readme.txt (WordPress.org format) is distinct from README.md (GitHub) — this
  skill is for readme.txt.
allowed-tools: Read, Write, Bash, Glob
model: sonnet
paths:
  - "**/readme.txt"
  - "**/*.php"
---

## WordPress.org `readme.txt` Generator

`readme.txt` is the file the WordPress.org plugin directory parses to build the
public listing. It is **not** Markdown — it uses a specific WordPress-flavored
format. Get the header fields wrong and the plugin won't display or update correctly.

### 1. Gather data (read, don't invent)

Pull real values from the plugin instead of guessing:

```bash
# Main plugin file + header
grep -rl "Plugin Name:" --include="*.php" . | head -1
grep -E "Plugin Name:|Version:|Requires at least:|Tested up to:|Requires PHP:|Text Domain:|Author:|License:" *.php
```

Confirm with the user anything not derivable: **Contributors** (WordPress.org
usernames, not display names), **Donate link**, **Tags** (max 5, lowercase),
short description wording.

### 2. The header block — every field matters

```
=== {Plugin Name} ===
Contributors: {wporg-username-1}, {wporg-username-2}
Donate link: {https://... or omit the line}
Tags: {tag1}, {tag2}, {tag3}
Requires at least: 6.0
Tested up to: 6.5
Requires PHP: 7.4
Stable tag: {X.Y.Z}
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html
```

**Hard rules:**
- **`Stable tag`** must exactly match the `Version:` in the main plugin file, AND a
  matching SVN tag must exist for the directory to serve it. Never set `Stable tag: trunk`
  for a released plugin.
- **`Tags`** — maximum 5. WordPress.org ignores extras. Use lowercase, comma-separated.
- **`Contributors`** — WordPress.org login names only. A display name with spaces breaks the avatar lookup.
- **`Tested up to`** — only the WP version `major.minor` (e.g. `6.5`), no patch.
- **`License`** in readme.txt is conventionally written `GPLv2 or later` (human form),
  even though the plugin header uses the SPDX `GPL-2.0-or-later`.

### 3. Short description

The first non-header line is the **short description**. Hard limit **150 characters**,
plain text, no markup. It's what shows in search results.

```bash
# Quick length check after writing
awk 'NR==1{next} NF{print length": "$0; exit}' readme.txt
```

### 4. Required & recommended sections

```
== Description ==

{Full prose. Blank line between paragraphs. Lists use * bullets.}

== Installation ==

1. Upload the plugin folder to `/wp-content/plugins/`.
2. Activate through the 'Plugins' menu in WordPress.
3. {any post-activation setup}

== Frequently Asked Questions ==

= {A question} =

{The answer.}

== Screenshots ==

1. {Caption for screenshot-1.png/jpg in assets/}
2. {Caption for screenshot-2.png}

== Changelog ==

= {X.Y.Z} - YYYY-MM-DD =
* {change}

== Upgrade Notice ==

= {X.Y.Z} =
{Short, <= 300 chars. Why a user should upgrade. Shown in the update nag.}
```

### 5. Formatting rules (WordPress-flavored, not Markdown)

- Section headers: `== Title ==`. Sub-headers (FAQ/changelog entries): `= Title =`.
- **Emphasis:** `**bold**`, `*italic*` — but **headings use `==`/`=`, never `#`**.
- Links: `[text](url)` is supported; bare URLs autolink.
- Code: indent with a tab or wrap in backticks. No fenced ``` blocks.
- Keep `== Changelog ==` newest-first. Mirror it from `CHANGELOG.md` if one exists.

### 6. Screenshots convention

Screenshot files live in the SVN `assets/` directory (not the plugin zip), named
`screenshot-1.png`, `screenshot-2.png`, … The numbered captions under
`== Screenshots ==` map to them in order.

### 7. Validate before finishing

1. **Stable tag == plugin Version** — diff them explicitly and report if they differ.
2. **Short description ≤ 150 chars.**
3. **≤ 5 tags.**
4. **Required headers present:** Stable tag, Requires at least, Tested up to, License.
5. Point the user to the official validator: <https://wordpress.org/plugins/developers/readme-validator/>

Report a short summary: fields filled, any mismatches found, and what still needs
a human decision (contributors, donate link, final tag list).
