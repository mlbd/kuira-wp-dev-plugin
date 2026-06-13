---
name: wp-release
description: >
  WordPress plugin release prep. Triggers on "prepare release", "bump version",
  "ready to deploy", "build zip", "release v", "tag release", "publish plugin".
  Handles semantic version bump, CHANGELOG update, WPCS final check, and dist zip.
allowed-tools: Read, Write, Bash, Glob
model: sonnet
run-in-subagent: false
paths:
  - "**/*.php"
  - "**/readme.txt"
  - "**/CHANGELOG.md"
---

## WordPress Plugin Release Workflow

### 1. Read Current Version

Locate the main plugin file (contains `Plugin Name:` header):

```bash
grep -r "Plugin Name:" --include="*.php" . | head -5
```

Read the plugin header block and extract:
- `Version:`
- `Tested up to:`
- `Requires at least:`
- `Requires PHP:`

### 2. Determine Bump Type

Ask the user if not specified:
- **patch** (1.0.x) — bug fixes only
- **minor** (1.x.0) — new features, backward-compatible
- **major** (x.0.0) — breaking changes

### 3. Update Version in All Locations

Update version in:
1. Main plugin file header (`Version: X.X.X`)
2. Any `define('PLUGIN_VERSION', 'X.X.X')` constant
3. `readme.txt` `Stable tag: X.X.X`
4. `package.json` if present

Use `sed` for precision — never rewrite entire files.

### 4. Update CHANGELOG.md

Prepend new entry:
```markdown
## [X.X.X] - YYYY-MM-DD

### Added
- (list new features)

### Fixed
- (list bug fixes)

### Changed
- (list changes)
```

Get today's date: `date +%Y-%m-%d`

### 5. WPCS Final Check

```bash
# Run phpcs — report only, don't block release on warnings
if command -v vendor/bin/phpcs &> /dev/null; then
  vendor/bin/phpcs --standard=WordPress --report=summary . 2>&1 | tail -20
elif command -v phpcs &> /dev/null; then
  phpcs --standard=WordPress --report=summary . 2>&1 | tail -20
else
  echo "phpcs not found — skipping WPCS check"
fi
```

If errors (not warnings) are found, run phpcbf to auto-fix:
```bash
vendor/bin/phpcbf --standard=WordPress . 2>&1 | tail -10
```

### 6. Build Distribution Zip

```bash
PLUGIN_SLUG=$(basename $(pwd))
VERSION=$(grep "Version:" *.php | head -1 | awk '{print $NF}')
DIST_DIR="dist"
ZIP_NAME="${PLUGIN_SLUG}-${VERSION}.zip"

mkdir -p $DIST_DIR

# Exclude dev files from zip
zip -r "$DIST_DIR/$ZIP_NAME" . \
  --exclude="*.git*" \
  --exclude="node_modules/*" \
  --exclude="vendor/bin/*" \
  --exclude="tests/*" \
  --exclude="*.DS_Store" \
  --exclude="dist/*" \
  --exclude="*.log" \
  --exclude="*.lock" \
  --exclude=".claude*" \
  --exclude="*.env*"

echo "Built: $DIST_DIR/$ZIP_NAME ($(du -sh $DIST_DIR/$ZIP_NAME | cut -f1))"
```

### 7. Release Summary

Report:
- New version number
- Zip file path and size
- WPCS status (clean / X errors fixed / warnings remaining)
- Files changed
- Suggested git tag command: `git tag v{version} && git push origin v{version}`
