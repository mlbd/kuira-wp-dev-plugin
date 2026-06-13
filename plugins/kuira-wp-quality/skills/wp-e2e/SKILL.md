---
name: wp-e2e
description: >
  Set up and write Playwright end-to-end tests for a WordPress plugin's admin/front
  UI. Triggers on "e2e test", "end to end", "playwright", "browser test", "ui test",
  "test the admin page", "integration test the UI". Uses
  @wordpress/e2e-test-utils-playwright against wp-env, scaffolds the config and a
  real example spec, and runs it. Complements wp-test (PHPUnit unit/integration).
  Opt-in: only runs when asked, and confirms before installing dependencies.
allowed-tools: Read, Write, Bash, Glob
model: sonnet
---

## Playwright E2E Tests for WordPress

`wp-test` covers PHP logic; E2E covers what the user actually clicks — does the
settings page render, does the form save, does the block insert. WordPress now
officially documents Playwright E2E and ships helpers for it.

Requires a running WordPress — use `wp-env` (see `wp-test`). This skill is
**explicitly invoked** and confirms before installing anything.

### 1. Dependencies

```bash
npm install --save-dev \
  @playwright/test \
  @wordpress/e2e-test-utils-playwright
npx playwright install chromium
```

The `@wordpress/e2e-test-utils-playwright` package provides `test`/`expect`
fixtures wired for WordPress: `admin` (navigate wp-admin), `editor` (block editor),
`requestUtils` (REST setup/teardown), `pageUtils`.

### 2. `playwright.config.js`

```js
import { defineConfig, devices } from '@playwright/test';

const { WP_BASE_URL = 'http://localhost:8888' } = process.env;

export default defineConfig( {
	testDir: './tests/e2e',
	fullyParallel: true,
	retries: process.env.CI ? 2 : 0,
	reporter: process.env.CI ? 'github' : 'list',
	use: {
		baseURL: WP_BASE_URL,
		trace: 'on-first-retry',
		storageState: './tests/e2e/.auth/admin.json',
	},
	projects: [ { name: 'chromium', use: { ...devices[ 'Desktop Chrome' ] } } ],
} );
```

Add scripts:
```json
"scripts": {
	"test:e2e": "playwright test",
	"test:e2e:ui": "playwright test --ui"
}
```

### 3. Example spec — `tests/e2e/settings.spec.js`

```js
import { test, expect } from '@wordpress/e2e-test-utils-playwright';

test.describe( '{Plugin Name} admin', () => {
	test.beforeEach( async ( { admin } ) => {
		await admin.visitAdminPage( 'admin.php', 'page={slug}' );
	} );

	test( 'settings page renders the app mount point', async ( { page } ) => {
		await expect( page.locator( '#{slug}-root' ) ).toBeVisible();
	} );

	test( 'saving a value persists', async ( { page } ) => {
		await page.getByLabel( 'Name' ).fill( 'Hello' );
		await page.getByRole( 'button', { name: 'Save' } ).click();
		await expect( page.getByText( 'Saved' ) ).toBeVisible();
	} );
} );
```

> The `admin`/`editor` fixtures log in as administrator automatically and reset
> between runs via `requestUtils` — no manual auth handling.

### 4. Run

```bash
npm run wp-env start     # start the WordPress under test
npm run test:e2e         # headless; or test:e2e:ui for the inspector
```

### 5. Finish

Report pass/fail counts, the screen(s) covered, and the highest-value flow still
untested (usually the plugin's primary action — the thing it exists to do).
Suggest adding the E2E job to CI via `wp-deploy`.
