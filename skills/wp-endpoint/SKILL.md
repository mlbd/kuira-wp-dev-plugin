---
name: wp-endpoint
description: >
  Scaffold a secure WordPress REST API route or admin-ajax handler. Triggers on
  "add endpoint", "rest route", "rest api", "register_rest_route", "ajax handler",
  "create endpoint", "api endpoint", "admin-ajax", "wp_ajax". Generates handlers
  that are secure by default — permission_callback, nonce verification, capability
  checks, and per-arg sanitization/validation — so they pass wp-security-audit
  instead of failing it. Opt-in: only runs when asked.
allowed-tools: Read, Write, Bash, Glob
model: sonnet
---

## Secure Endpoint Scaffolder

Most WordPress vulnerabilities come from endpoints written without auth or
sanitization. This skill generates them **secure by default**, so the output
passes `wp-security-audit` and Plugin Check.

### 1. Clarify (ask, don't assume)

- **REST or AJAX?** Prefer **REST** for anything new (versioned, discoverable,
  testable). Use AJAX only when integrating with legacy `admin-ajax` code.
- **Method:** GET (read) / POST / PUT / DELETE (state-changing).
- **Who can call it?** public / any logged-in user / a specific capability
  (e.g. `manage_options`, `edit_posts`). **There is no "skip auth" option** —
  a public read still gets an explicit `__return_true` with a comment.
- **Input fields** and their types (for the args schema).

### 2. REST route (preferred) — secure pattern

```php
<?php
/**
 * REST controller.
 *
 * @package {Package_Name}
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Registers and handles the {slug}/v1 routes.
 */
class {Class}_Rest_Controller {

	const NAMESPACE = '{slug}/v1';

	/**
	 * Constructor.
	 */
	public function __construct() {
		add_action( 'rest_api_init', array( $this, 'register_routes' ) );
	}

	/**
	 * Register routes.
	 */
	public function register_routes() {
		register_rest_route(
			self::NAMESPACE,
			'/items',
			array(
				array(
					'methods'             => WP_REST_Server::CREATABLE, // POST
					'callback'            => array( $this, 'create_item' ),
					'permission_callback' => array( $this, 'can_edit' ),
					'args'                => array(
						'title' => array(
							'required'          => true,
							'type'              => 'string',
							'sanitize_callback' => 'sanitize_text_field',
							'validate_callback' => function ( $value ) {
								return is_string( $value ) && '' !== trim( $value );
							},
						),
						'count' => array(
							'type'              => 'integer',
							'default'           => 0,
							'sanitize_callback' => 'absint',
						),
					),
				),
			)
		);
	}

	/**
	 * Capability gate. Never return __return_true for state changes.
	 *
	 * @return bool|WP_Error
	 */
	public function can_edit() {
		if ( ! current_user_can( 'manage_options' ) ) {
			return new WP_Error( 'rest_forbidden', __( 'Insufficient permissions.', '{slug}' ), array( 'status' => 403 ) );
		}
		return true;
	}

	/**
	 * Handle the request. Args are already sanitized by the schema above.
	 *
	 * @param WP_REST_Request $request Request.
	 * @return WP_REST_Response|WP_Error
	 */
	public function create_item( WP_REST_Request $request ) {
		$title = $request->get_param( 'title' );
		$count = $request->get_param( 'count' );

		// ... business logic ...

		return new WP_REST_Response(
			array(
				'ok'    => true,
				'title' => $title,
				'count' => $count,
			),
			201
		);
	}
}
```

Instantiate it from the bootstrap class. The nonce: the JS client sends the
`wp_create_nonce( 'wp_rest' )` value (the scaffold's `{prefix}Data.nonce`) as the
**`X-WP-Nonce`** header — REST cookie auth verifies it automatically; no manual
`check_ajax_referer` needed for REST.

### 3. admin-ajax handler — secure pattern

```php
add_action( 'wp_ajax_{prefix}_save', array( $this, 'ajax_save' ) );
// Only add wp_ajax_nopriv_* if the action is genuinely for logged-out users.

/**
 * Handle the AJAX save.
 */
public function ajax_save() {
	// 1. Nonce (CSRF).
	check_ajax_referer( '{prefix}_save', 'nonce' );

	// 2. Capability.
	if ( ! current_user_can( 'manage_options' ) ) {
		wp_send_json_error( array( 'message' => __( 'Forbidden.', '{slug}' ) ), 403 );
	}

	// 3. Sanitize EVERY input at the boundary.
	$title = isset( $_POST['title'] ) ? sanitize_text_field( wp_unslash( $_POST['title'] ) ) : '';
	if ( '' === $title ) {
		wp_send_json_error( array( 'message' => __( 'Title is required.', '{slug}' ) ), 400 );
	}

	// ... business logic ...

	wp_send_json_success( array( 'title' => $title ) );
}
```

> The nonce for AJAX is a separate one (`wp_create_nonce( '{prefix}_save' )`),
> printed/localized for the page and sent as the `nonce` POST field.

### 4. Secure-by-default checklist (verify before finishing)

- [ ] `permission_callback` present and **not** `__return_true` for any write
- [ ] AJAX handler calls `check_ajax_referer()` first
- [ ] Capability check (`current_user_can`) on privileged actions
- [ ] Every input has a `sanitize_callback` (REST) or `sanitize_*` + `wp_unslash` (AJAX)
- [ ] DB writes use `$wpdb->prepare()` (see `wp-db`)
- [ ] Output escaped if the handler renders HTML
- [ ] Errors return proper status codes (`WP_Error` / `wp_send_json_error`)

Then suggest running `wp-security-audit` to confirm the new code is clean.
