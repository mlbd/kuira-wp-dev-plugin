---
name: wp-deploy
description: >
  Set up CI/CD and WordPress.org release automation for a plugin. Triggers on
  "ci", "github actions", "continuous integration", "deploy to wordpress.org",
  "svn deploy", "release workflow", "publish plugin", "automate release". Generates
  GitHub Actions workflows (lint + PHPStan + PHPUnit matrix on PR; build zip and
  deploy to the wordpress.org SVN repo on tag) using the maintained 10up actions.
  Opt-in: only runs when asked, and explains the required secrets first.
allowed-tools: Read, Write, Bash, Glob
model: sonnet
---

## CI/CD + WordPress.org Deploy

Two workflows: **CI** runs quality gates on every PR; **deploy** publishes to the
wordpress.org SVN repository when you push a version tag. This skill is **explicitly
invoked** and tells the user which repo secrets to add before the deploy can work.

### 1. CI workflow — `.github/workflows/ci.yml`

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [ main ]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with: { php-version: '8.2', tools: composer, coverage: none }
      - run: composer install --prefer-dist --no-progress
      - name: PHPCS
        run: composer lint
      - name: PHPStan
        run: composer analyze   # only if wp-analyze was set up; otherwise remove

  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        php: [ '7.4', '8.0', '8.2', '8.3' ]
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with: { php-version: '${{ matrix.php }}', tools: composer, coverage: none }
      - run: composer install --prefer-dist --no-progress
      - run: composer test
```

> Add an `e2e` job (Node + `npm run wp-env start` + `npm run test:e2e`) only if the
> plugin set up `wp-e2e`. Keep CI honest — don't reference scripts the plugin lacks.

### 2. Deploy workflow — `.github/workflows/deploy.yml`

Fires on a semver tag and publishes to wordpress.org via the maintained
`10up/action-wordpress-plugin-deploy`:

```yaml
name: Deploy to WordPress.org

on:
  push:
    tags:
      - '*.*.*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # If the plugin has a JS build, compile before packaging.
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci && npm run build
        if: hashFiles('package.json') != ''

      - name: WordPress.org deploy
        uses: 10up/action-wordpress-plugin-deploy@stable
        env:
          SVN_USERNAME: ${{ secrets.SVN_USERNAME }}
          SVN_PASSWORD: ${{ secrets.SVN_PASSWORD }}
          SLUG: {slug}
```

For the directory listing's banner/icon/screenshots and the readme (without a full
release), add a second job using `10up/action-wordpress-plugin-asset-update@stable`.

### 3. Required repo secrets (tell the user — you can't set these)

- **`SVN_USERNAME`** — the wordpress.org account that owns the plugin.
- **`SVN_PASSWORD`** — that account's password (or a generated deploy password).

Add them under **Settings → Secrets and variables → Actions**. The deploy will fail
loudly without them — that's expected until they're set.

### 4. Pre-flight: what must be true for a green deploy

- The git tag **equals** the `Stable tag` in `readme.txt` and the `Version:` header
  (lean on `wp-release` + `wp-readme` to keep these in lockstep).
- A `.distignore` (or the deploy action's default excludes) keeps dev files
  (`node_modules`, `tests`, `.github`, source `src/`) out of the published zip.
- The plugin already exists on wordpress.org (first publish is a manual submission;
  this automates subsequent releases).

Generate a `.distignore`:
```
/.git
/.github
/node_modules
/tests
/src
/vendor/bin
.distignore
.gitignore
composer.json
composer.lock
package.json
package-lock.json
phpcs.xml.dist
phpstan.neon.dist
playwright.config.js
```

### 5. Finish

Summarize the two workflows created, the secrets the user must add, and the release
ritual: bump version (`wp-release`) → sync `readme.txt` (`wp-readme`) → `git tag
X.Y.Z && git push --tags` → Actions deploys. Confirm CI references only scripts the
plugin actually has.
