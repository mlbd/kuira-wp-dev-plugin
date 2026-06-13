---
name: wp-playground
description: >
  Spin up an instant, zero-Docker WordPress to preview or test a plugin using
  WordPress Playground. Triggers on "playground", "wp-playground", "blueprint",
  "preview the plugin", "instant wordpress", "try it without docker", "demo the
  plugin", "playground cli". Generates a Playground Blueprint (infrastructure-as-code
  for the test environment) and launches the plugin in it. Lighter than wp-env for
  demos, quick manual testing, and CI. Opt-in: only runs when asked.
allowed-tools: Read, Write, Bash, Glob
model: sonnet
---

## WordPress Playground (zero-Docker WP)

[WordPress Playground](https://make.wordpress.org/playground/) runs WordPress in
WebAssembly — no Docker, no MySQL, starts in seconds. It's the modern path for
demos, quick manual testing, and lightweight CI. Use it alongside `wp-test`/`wp-e2e`
(which use `wp-env` for heavier integration work).

> **Note:** `@wp-now/wp-now` is **deprecated** (2026) — use the Playground CLI
> (`@wp-playground/cli`) instead. This skill targets the CLI.

This skill is **explicitly invoked** and confirms before installing anything.

### 1. Launch the plugin instantly

From the plugin directory:
```bash
npx @wp-playground/cli@latest server --mount=.:/wordpress/wp-content/plugins/{slug} --blueprint=blueprint.json
```
This mounts the working copy as a plugin and boots WordPress at a local URL. Edits to
the plugin are reflected live.

### 2. Generate a Blueprint — `blueprint.json`

A Blueprint is the exact, reproducible setup for the environment: WP/PHP version,
plugins, theme, content, and setup steps. Treat it as infrastructure-as-code.

```json
{
	"$schema": "https://playground.wordpress.net/blueprint-schema.json",
	"landingPage": "/wp-admin/admin.php?page={slug}",
	"preferredVersions": { "php": "8.2", "wp": "latest" },
	"features": { "networking": true },
	"login": true,
	"steps": [
		{
			"step": "installPlugin",
			"pluginData": { "resource": "literal:directory", "path": "{slug}" }
		},
		{ "step": "setSiteOptions", "options": { "blogname": "{Plugin Name} Demo" } }
	]
}
```

Common steps: `installPlugin`, `installTheme`, `activatePlugin`, `login`,
`runPHP`, `setSiteOptions`, `importWxr` (seed content), `defineWpConfigConsts`
(e.g. enable `WP_DEBUG`).

### 3. Use it for...

- **Manual QA** — `landingPage` drops you straight on the plugin's admin screen,
  already logged in.
- **Demos** — share the Blueprint; anyone can launch the exact same environment at
  playground.wordpress.net (great for bug reports and the README).
- **CI smoke test** — run the Playground CLI headless to assert the plugin activates
  without fatals:
  ```bash
  npx @wp-playground/cli@latest run-blueprint --blueprint=blueprint.json
  ```

### 4. Blueprint authoring tips

- Pin `preferredVersions.php` to the lowest version you support to catch compat
  issues early (pairs with `wp-php8`).
- Use `importWxr` with a small fixture to test against realistic content.
- Keep the Blueprint in the repo (`blueprint.json`) and link "Try it in Playground"
  from the README.

### 5. Finish

Report the launch command, the Blueprint created, and what it sets up. Suggest
committing `blueprint.json` and adding a Playground smoke-test job via `wp-deploy`
for a fast, Docker-free activation check on every PR.
