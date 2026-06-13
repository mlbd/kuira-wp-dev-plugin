---
name: wp-scaffold
description: >
  Scaffold a brand-new WordPress plugin from scratch. Triggers on "new plugin",
  "create a plugin", "scaffold a plugin", "start a wordpress plugin", "bootstrap
  plugin", "generate plugin skeleton", "set up a new wp plugin". Produces a
  WPCS-compliant plugin skeleton with the correct header, file structure,
  activation/deactivation hooks, a singleton bootstrap class, composer.json, a
  WPCS ruleset, AND a fully wired frontend stack the developer chooses (React via
  @wordpress/scripts, Vue via Vite, or vanilla jQuery/CSS) — ready to run
  `npm run build` and develop immediately.
allowed-tools: Read, Write, Bash, Glob
model: sonnet
---

## WordPress Plugin Scaffold Workflow

Use this when the user wants to **start a new plugin**, not edit an existing one.
The goal: a clean, WPCS-compliant skeleton with a working build pipeline they can
develop in straight away.

### 1. Gather the essentials (ask, don't assume)

Ask these — one at a time — if not already provided:

- **Plugin name** (human-readable, e.g. "My Awesome Plugin")
- **Slug** — derive as `kebab-case` (e.g. `my-awesome-plugin`). This is the folder
  name AND the text domain. Confirm it.
- **Description** (one sentence)
- **Author** name and URL
- **WooCommerce / HPOS support?** (changes activation guards)
- **Frontend stack** — THIS DRIVES THE BUILD SETUP. Present the choice explicitly:

  | Option | Use when | What gets wired up |
  |--------|----------|--------------------|
  | **React** (`@wordpress/scripts`) | Default for modern admin UIs, Gutenberg blocks, anything interactive. Matches WP core's own tooling. | `@wordpress/scripts`, `src/index.js`, `build/` output with auto-generated `index.asset.php` dependency file |
  | **Vue** (Vite) | Team prefers Vue, or a standalone SPA-style admin screen | `vite`, `@vitejs/plugin-vue`, `src/main.js` + `App.vue`, build to `assets/dist/` |
  | **Vanilla** (jQuery + CSS) | Simple settings page, no build step wanted | plain `assets/js/admin.js` + `assets/css/admin.css`, enqueued with the `jquery` dependency |

  > Recommend **React** by default — it's what WordPress core uses, `@wordpress/scripts`
  > handles JSX/SCSS/dependency-extraction with zero config, and it produces the
  > `*.asset.php` file that makes script dependencies and cache-busting automatic.
  > But honor the user's choice; all three are first-class below.

Derive a PHP **prefix** from the slug:
- Function prefix: `my_awesome_plugin_` (snake_case)
- Class prefix: `My_Awesome_Plugin`
- Constant prefix: `MY_AWESOME_PLUGIN_` (UPPER_SNAKE)
- JS data object: `myAwesomePluginData` (camelCase)

### 2. Create the directory structure

Common to every stack:

```
{slug}/
├── {slug}.php              ← main plugin file (header + bootstrap)
├── uninstall.php
├── readme.txt              ← generate with the wp-readme skill
├── composer.json
├── phpcs.xml.dist
├── .gitignore
├── includes/
│   ├── class-{slug}.php
│   ├── class-{slug}-activator.php
│   ├── class-{slug}-deactivator.php
│   └── class-{slug}-admin.php   ← registers the admin page + enqueues assets
└── languages/
```

Then add the stack-specific folders from §8. Create directories with `mkdir -p`.

### 3. Main plugin file — `{slug}.php`

```php
<?php
/**
 * Plugin Name:       {Plugin Name}
 * Plugin URI:        {author url or repo}
 * Description:        {description}
 * Version:           0.1.0
 * Requires at least: 6.0
 * Requires PHP:      7.4
 * Author:            {Author}
 * Author URI:        {author url}
 * License:           GPL-2.0-or-later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       {slug}
 * Domain Path:       /languages
 *
 * @package {Package_Name}
 */

// Abort if accessed directly.
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

define( '{PREFIX}_VERSION', '0.1.0' );
define( '{PREFIX}_FILE', __FILE__ );
define( '{PREFIX}_DIR', plugin_dir_path( __FILE__ ) );
define( '{PREFIX}_URL', plugin_dir_url( __FILE__ ) );

require_once {PREFIX}_DIR . 'includes/class-{slug}.php';

register_activation_hook( __FILE__, array( '{Class}_Activator', 'activate' ) );
register_deactivation_hook( __FILE__, array( '{Class}_Deactivator', 'deactivate' ) );

/**
 * Boot the plugin.
 */
function {prefix}_run() {
	return {Class}::get_instance();
}
add_action( 'plugins_loaded', '{prefix}_run' );
```

> If WooCommerce/HPOS was requested, add the HPOS compatibility declaration on
> `before_woocommerce_init` (see WooCommerce `FeaturesUtil::declare_compatibility`).

### 4. Bootstrap class — `includes/class-{slug}.php`

Singleton with `get_instance()`, a private constructor that only registers hooks, a
`load_textdomain()` on `init`, and wiring for the admin class:

```php
<?php
/**
 * Core plugin class.
 *
 * @package {Package_Name}
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Main plugin orchestrator.
 */
class {Class} {

	/**
	 * Singleton instance.
	 *
	 * @var {Class}|null
	 */
	private static $instance = null;

	/**
	 * Get the singleton instance.
	 *
	 * @return {Class}
	 */
	public static function get_instance() {
		if ( null === self::$instance ) {
			self::$instance = new self();
		}
		return self::$instance;
	}

	/**
	 * Constructor — register hooks only.
	 */
	private function __construct() {
		add_action( 'init', array( $this, 'load_textdomain' ) );

		require_once {PREFIX}_DIR . 'includes/class-{slug}-admin.php';
		new {Class}_Admin();
	}

	/**
	 * Load translations.
	 */
	public function load_textdomain() {
		load_plugin_textdomain( '{slug}', false, dirname( plugin_basename( {PREFIX}_FILE ) ) . '/languages' );
	}
}
```

### 5. Activator / Deactivator

`class-{slug}-activator.php` and `class-{slug}-deactivator.php`, each one static
method. Flush rewrite rules on activation only if the plugin registers CPTs. Never
put DB-destructive code in the deactivator — that belongs in `uninstall.php`.

### 6. `composer.json` (WPCS wired up)

```json
{
	"name": "{vendor}/{slug}",
	"description": "{description}",
	"type": "wordpress-plugin",
	"license": "GPL-2.0-or-later",
	"require": { "php": ">=7.4" },
	"require-dev": {
		"squizlabs/php_codesniffer": "^3.9",
		"wp-coding-standards/wpcs": "^3.1",
		"phpcompatibility/phpcompatibility-wp": "^2.1"
	},
	"scripts": { "lint": "phpcs", "lint:fix": "phpcbf" },
	"config": {
		"allow-plugins": { "dealerdirect/phpcodesniffer-composer-installer": true }
	}
}
```

### 7. `phpcs.xml.dist`

```xml
<?xml version="1.0"?>
<ruleset name="{Plugin Name}">
	<description>WPCS ruleset for {Plugin Name}.</description>
	<file>.</file>
	<exclude-pattern>/vendor/*</exclude-pattern>
	<exclude-pattern>/node_modules/*</exclude-pattern>
	<exclude-pattern>/build/*</exclude-pattern>
	<exclude-pattern>/assets/dist/*</exclude-pattern>
	<arg name="extensions" value="php"/>
	<arg value="ps"/>
	<rule ref="WordPress"/>
	<config name="minimum_supported_wp_version" value="6.0"/>
	<config name="testVersion" value="7.4-"/>
	<rule ref="WordPress.WP.I18n">
		<properties>
			<property name="text_domain" type="array" value="{slug}"/>
		</properties>
	</rule>
</ruleset>
```

---

## 8. Frontend stack setup — build ONLY the branch the user chose

Whichever stack is selected, the admin class in §9 prints a single mount point
(`<div id="{slug}-root"></div>`) and enqueues the built assets. Pick one path:

### Path A — React (`@wordpress/scripts`) — recommended

Add `src/` and a `package.json`. `@wordpress/scripts` needs **zero** webpack config.

`package.json`:
```json
{
	"name": "{slug}",
	"version": "0.1.0",
	"private": true,
	"scripts": {
		"start": "wp-scripts start",
		"build": "wp-scripts build",
		"lint:js": "wp-scripts lint-js",
		"format": "wp-scripts format"
	},
	"devDependencies": {
		"@wordpress/scripts": "^27.9.0"
	}
}
```

`src/index.js` (entry — `wp-scripts` compiles it to `build/index.js` + `build/index.asset.php`):
```js
import { createRoot } from '@wordpress/element';
import App from './app';
import './style.scss';

document.addEventListener( 'DOMContentLoaded', () => {
	const el = document.getElementById( '{slug}-root' );
	if ( el ) {
		createRoot( el ).render( <App /> );
	}
} );
```

`src/app.js` (uses WP's own component library so it matches admin styling):
```js
import { useState } from '@wordpress/element';
import { Button, Card, CardBody, TextControl } from '@wordpress/components';
import { __ } from '@wordpress/i18n';

export default function App() {
	const [ name, setName ] = useState( '' );
	return (
		<Card>
			<CardBody>
				<h2>{ __( '{Plugin Name}', '{slug}' ) }</h2>
				<TextControl label={ __( 'Name', '{slug}' ) } value={ name } onChange={ setName } />
				<Button variant="primary">{ __( 'Save', '{slug}' ) }</Button>
			</CardBody>
		</Card>
	);
}
```

`src/style.scss`: an empty/starter stylesheet — `wp-scripts` compiles it to `build/index.css`.

> The generated `build/index.asset.php` returns `array( 'dependencies' => [...], 'version' => '...' )`.
> The admin class (§9, React variant) `include`s it so script deps and cache-busting are automatic.

### Path B — Vue (Vite)

Add `src/` and `vite.config.js`, building into `assets/dist/`.

`package.json`:
```json
{
	"name": "{slug}",
	"version": "0.1.0",
	"private": true,
	"type": "module",
	"scripts": {
		"dev": "vite build --watch",
		"build": "vite build"
	},
	"dependencies": {
		"vue": "^3.4.0"
	},
	"devDependencies": {
		"vite": "^5.4.0",
		"@vitejs/plugin-vue": "^5.1.0"
	}
}
```

`vite.config.js` (fixed output filenames so PHP can enqueue them predictably):
```js
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import { resolve } from 'node:path';

export default defineConfig( {
	plugins: [ vue() ],
	build: {
		outDir: 'assets/dist',
		emptyOutDir: true,
		rollupOptions: {
			input: resolve( __dirname, 'src/main.js' ),
			output: {
				entryFileNames: '{slug}.js',
				assetFileNames: '{slug}.[ext]',
			},
		},
	},
} );
```

`src/main.js`:
```js
import { createApp } from 'vue';
import App from './App.vue';
import './style.css';

const el = document.getElementById( '{slug}-root' );
if ( el ) {
	createApp( App ).mount( el );
}
```

`src/App.vue`:
```vue
<template>
	<div class="{slug}-app">
		<h2>{Plugin Name}</h2>
		<input v-model="name" type="text" />
		<button class="button button-primary">Save</button>
	</div>
</template>

<script setup>
import { ref } from 'vue';
const name = ref( '' );
</script>
```

> Vite outputs an ES module. The admin class (§9, Vue variant) adds `type="module"`
> to the script tag via a `script_loader_tag` filter so the browser loads it correctly.

### Path C — Vanilla (jQuery + CSS) — no build step

Just create the asset files directly:

- `assets/js/admin.js` — a small IIFE using `jQuery` (passed in as `$`):
```js
( function ( $ ) {
	$( function () {
		// {prefix}Data.restUrl / .nonce are available here (see §9).
		console.log( '{Plugin Name} admin loaded' );
	} );
} )( jQuery );
```
- `assets/css/admin.css` — starter stylesheet.

No `package.json` needed for this path.

---

## 9. Admin page + enqueue + pass data to JS — `includes/class-{slug}-admin.php`

This is where the chosen stack actually loads. The class registers a menu page,
prints the mount point, and enqueues assets **only on its own screen**. It also
hands the frontend an authenticated entry point via `wp_localize_script` — REST
URL + nonce — so the developer can call the API on day one.

**Shared shell (all stacks):**
```php
<?php
/**
 * Admin UI + asset loading.
 *
 * @package {Package_Name}
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Registers the admin page and enqueues the frontend bundle.
 */
class {Class}_Admin {

	const HANDLE = '{slug}-admin';

	/**
	 * Hook suffix for the plugin's admin page (to scope asset loading).
	 *
	 * @var string
	 */
	private $hook_suffix = '';

	/**
	 * Constructor.
	 */
	public function __construct() {
		add_action( 'admin_menu', array( $this, 'register_menu' ) );
		add_action( 'admin_enqueue_scripts', array( $this, 'enqueue_assets' ) );
	}

	/**
	 * Add the top-level admin menu page.
	 */
	public function register_menu() {
		$this->hook_suffix = add_menu_page(
			'{Plugin Name}',
			'{Plugin Name}',
			'manage_options',
			'{slug}',
			array( $this, 'render_page' ),
			'dashicons-admin-generic'
		);
	}

	/**
	 * Render the mount point. The chosen JS framework takes over from here.
	 */
	public function render_page() {
		echo '<div class="wrap"><div id="{slug}-root"></div></div>';
	}

	/**
	 * Localized data shared with whichever frontend stack is enqueued.
	 *
	 * @return array
	 */
	private function script_data() {
		return array(
			'restUrl' => esc_url_raw( rest_url( '{slug}/v1/' ) ),
			'nonce'   => wp_create_nonce( 'wp_rest' ),
			'ajaxUrl' => admin_url( 'admin-ajax.php' ),
		);
	}

	/**
	 * Enqueue assets only on this plugin's admin screen.
	 *
	 * @param string $hook Current admin page hook suffix.
	 */
	public function enqueue_assets( $hook ) {
		if ( $hook !== $this->hook_suffix ) {
			return;
		}
		// --- stack-specific enqueue goes here (see below) ---
	}
}
```

**§9 enqueue body — React variant:**
```php
$asset_file = {PREFIX}_DIR . 'build/index.asset.php';
if ( ! file_exists( $asset_file ) ) {
	return; // Run `npm run build` first.
}
$asset = include $asset_file;

wp_enqueue_script( self::HANDLE, {PREFIX}_URL . 'build/index.js', $asset['dependencies'], $asset['version'], true );
wp_enqueue_style( self::HANDLE, {PREFIX}_URL . 'build/index.css', array( 'wp-components' ), $asset['version'] );
wp_localize_script( self::HANDLE, '{prefix}Data', $this->script_data() );
```

**§9 enqueue body — Vue variant** (plus the module-type filter alongside the class):
```php
wp_enqueue_script( self::HANDLE, {PREFIX}_URL . 'assets/dist/{slug}.js', array(), {PREFIX}_VERSION, true );
wp_enqueue_style( self::HANDLE, {PREFIX}_URL . 'assets/dist/{slug}.css', array(), {PREFIX}_VERSION );
wp_localize_script( self::HANDLE, '{prefix}Data', $this->script_data() );
```
```php
// Load the Vite bundle as an ES module.
add_filter(
	'script_loader_tag',
	function ( $tag, $handle ) {
		if ( {Class}_Admin::HANDLE === $handle ) {
			$tag = str_replace( ' src', ' type="module" src', $tag );
		}
		return $tag;
	},
	10,
	2
);
```

**§9 enqueue body — Vanilla variant:**
```php
wp_enqueue_style( self::HANDLE, {PREFIX}_URL . 'assets/css/admin.css', array(), {PREFIX}_VERSION );
wp_enqueue_script( self::HANDLE, {PREFIX}_URL . 'assets/js/admin.js', array( 'jquery' ), {PREFIX}_VERSION, true );
wp_localize_script( self::HANDLE, '{prefix}Data', $this->script_data() );
```

> In JS, the localized data is the global `{prefix}Data` — e.g. `{prefix}Data.restUrl`,
> `{prefix}Data.nonce`. Send the nonce as the `X-WP-Nonce` header on REST calls.

### 10. `readme.txt`

Hand off to the **`wp-readme`** skill to generate a spec-compliant WordPress.org
`readme.txt`. Don't hand-roll the header block here.

### 11. `uninstall.php`

```php
<?php
/**
 * Fired when the plugin is deleted.
 *
 * @package {Package_Name}
 */

if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}

// Remove only the options/tables this plugin created. Be conservative.
```

### 12. `.gitignore` for the new plugin

```gitignore
/vendor/
/node_modules/
/build/
/assets/dist/
*.log
```
(Drop `/build/` for the Vue path and `/assets/dist/` for the React path — keep
whichever your chosen stack emits.)

### 13. Finish — install and verify

1. `composer install` in the plugin dir (so `vendor/bin/phpcs` exists and the
   `wpcs-check` hook can lint going forward).
2. For React/Vue: `npm install` then `npm run build` (or `npm start` / `npm run dev`
   for watch mode). Confirm the expected output exists (`build/index.js` for React,
   `assets/dist/{slug}.js` for Vue).
3. `vendor/bin/phpcs` once to confirm the PHP skeleton is clean.
4. Summarize: slug, text domain, prefix, **chosen frontend stack**, the build command
   to run during development, the file tree created, and the next suggested step
   (e.g. "design the admin screen" → routes through `wp-ui-visual`).

> After scaffolding, `wp-context` auto-loads on every `.php` edit, `wp-security-audit`
> and `wp-release` cover the rest of the lifecycle, and `wp-readme` keeps `readme.txt`
> in sync at release time.
