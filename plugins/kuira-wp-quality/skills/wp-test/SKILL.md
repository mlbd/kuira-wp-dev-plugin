---
name: wp-test
description: >
  Set up and run automated tests for a WordPress plugin. Triggers on "write tests",
  "unit test", "integration test", "phpunit", "set up testing", "test coverage",
  "wp-env", "local wordpress environment", "spin up wordpress". Configures
  @wordpress/env (local Docker WP) and the PHPUnit WordPress test suite, writes
  WP_UnitTestCase / REST / AJAX tests, and runs them. Opt-in: only runs when asked,
  and confirms before installing dependencies.
allowed-tools: Read, Write, Bash, Glob
model: sonnet
---

## WordPress Plugin Testing

This skill is **explicitly invoked** — it will not auto-install anything. Before
adding dev dependencies or Docker config, summarize what you're about to add and
confirm with the user.

Two layers, usually set up together:

1. **`@wordpress/env`** — a throwaway Docker WordPress to run/integration-test against.
2. **PHPUnit + WP test suite** — `WP_UnitTestCase` with WordPress loaded.

### 1. Local environment — `@wordpress/env`

Add as a dev dependency (requires Docker running):

```jsonc
// package.json
{
	"devDependencies": { "@wordpress/env": "^10.0.0" },
	"scripts": {
		"wp-env": "wp-env",
		"test:php": "wp-env run tests-cli --env-cwd=wp-content/plugins/{slug} composer test"
	}
}
```

`.wp-env.json` at the plugin root:
```json
{
	"core": null,
	"plugins": [ "." ],
	"config": { "WP_DEBUG": true, "WP_DEBUG_LOG": true }
}
```

- `npm install` then `npm run wp-env start` → WP at http://localhost:8888 (admin `admin`/`password`).
- `npm run wp-env stop` to shut down; `wp-env clean all` to reset.

### 2. PHPUnit + WordPress test suite

Add dev dependencies (PHPUnit version must match the PHP version under test):

```
composer require --dev --no-update \
  yoast/phpunit-polyfills:^2.0 \
  wp-phpunit/wp-phpunit:^6.5 \
  phpunit/phpunit:^9.6
composer update
```

`phpunit.xml.dist`:
```xml
<?xml version="1.0"?>
<phpunit
	bootstrap="tests/bootstrap.php"
	colors="true"
	convertErrorsToExceptions="true"
	convertWarningsToExceptions="true">
	<testsuites>
		<testsuite name="{slug}">
			<directory suffix="-test.php">./tests/</directory>
		</testsuite>
	</testsuites>
</phpunit>
```

`tests/bootstrap.php`:
```php
<?php
/**
 * PHPUnit bootstrap — loads the WP test suite then the plugin.
 *
 * @package {Package_Name}
 */

$_tests_dir = getenv( 'WP_TESTS_DIR' );
if ( ! $_tests_dir ) {
	$_tests_dir = rtrim( sys_get_temp_dir(), '/\\' ) . '/wordpress-tests-lib';
}

require_once $_tests_dir . '/includes/functions.php';

tests_add_filter(
	'muplugins_loaded',
	function () {
		require dirname( __DIR__ ) . '/{slug}.php';
	}
);

require $_tests_dir . '/includes/bootstrap.php';
```

Add `"scripts": { "test": "phpunit" }` to `composer.json`.

> Inside `wp-env`, `WP_TESTS_DIR` is provided by the `tests-cli` service, so
> `npm run test:php` works without installing the test suite manually. Outside
> wp-env, run the WP `install-wp-tests.sh` script once to provision it.

### 3. Writing tests

**Basic unit test** — `tests/sample-test.php`:
```php
<?php
/**
 * @package {Package_Name}
 */

class Sample_Test extends WP_UnitTestCase {

	public function test_plugin_is_loaded() {
		$this->assertTrue( function_exists( '{prefix}_run' ) );
	}

	public function test_option_default() {
		$this->assertSame( '', get_option( '{prefix}_setting', '' ) );
	}
}
```

**REST endpoint test** (use the dispatcher, not HTTP):
```php
class Rest_Test extends WP_UnitTestCase {

	public function test_endpoint_requires_auth() {
		$request  = new WP_REST_Request( 'GET', '/{slug}/v1/items' );
		$response = rest_get_server()->dispatch( $request );
		$this->assertSame( 401, $response->get_status() );
	}

	public function test_endpoint_returns_items_for_admin() {
		wp_set_current_user( self::factory()->user->create( array( 'role' => 'administrator' ) ) );
		$response = rest_get_server()->dispatch( new WP_REST_Request( 'GET', '/{slug}/v1/items' ) );
		$this->assertSame( 200, $response->get_status() );
	}
}
```

**AJAX test** — extend `WP_Ajax_UnitTestCase` and assert on the `WPAjaxDieStopException`.

Use `self::factory()` for posts/users/terms. Each test runs in a transaction and
rolls back, so the DB stays clean.

### 4. Run

```
npm run wp-env start     # if testing through wp-env
composer test            # or: npm run test:php
```

Report: how many tests passed/failed, the command used, and any failure output.
If a feature has no test, suggest the highest-value one to add next (usually the
permission_callback on a REST route or the nonce check on an AJAX handler).
