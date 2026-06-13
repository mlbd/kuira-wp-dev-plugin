<?php
/**
 * Plugin Name: Clean Demo
 * Description: The corrected counterpart to vuln-demo.php — every planted issue fixed. Reference for what the auditors expect.
 * Version: 0.0.0
 *
 * @package Clean_Demo
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

// [V1 fixed] Nonce + capability gate before doing anything.
add_action( 'wp_ajax_clean_save', 'clean_save' );
function clean_save() {
	check_ajax_referer( 'clean_save', 'nonce' );

	if ( ! current_user_can( 'manage_options' ) ) {
		wp_send_json_error( array( 'message' => __( 'Forbidden.', 'clean-demo' ) ), 403 );
	}

	// [V2 fixed] Sanitize input at the boundary.
	$name = isset( $_POST['name'] ) ? sanitize_text_field( wp_unslash( $_POST['name'] ) ) : '';
	update_option( 'clean_name', $name );

	// [V3 fixed] Escape on output.
	wp_send_json_success( array( 'message' => esc_html( $name ) ) );
}

// [V4 fixed] Cast/prepare the query.
function clean_lookup() {
	global $wpdb;
	$id    = isset( $_GET['id'] ) ? absint( wp_unslash( $_GET['id'] ) ) : 0;
	$table = $wpdb->prefix . 'clean';
	// phpcs:ignore WordPress.DB.PreparedSQL.InterpolatedNotPrepared
	return $wpdb->get_results( $wpdb->prepare( "SELECT * FROM $table WHERE id = %d", $id ) );
}

// [V5 fixed] Real permission_callback requiring a capability.
add_action(
	'rest_api_init',
	function () {
		register_rest_route(
			'clean/v1',
			'/delete',
			array(
				'methods'             => 'POST',
				'callback'            => 'clean_delete',
				'permission_callback' => static function () {
					return current_user_can( 'delete_posts' );
				},
				'args'                => array(
					'id' => array(
						'required'          => true,
						'type'              => 'integer',
						'sanitize_callback' => 'absint',
					),
				),
			)
		);
	}
);
function clean_delete( WP_REST_Request $request ) {
	global $wpdb;
	// [V6 fixed] Sanitized param + prepared query.
	$id    = (int) $request->get_param( 'id' );
	$table = $wpdb->prefix . 'clean';
	// phpcs:ignore WordPress.DB.PreparedSQL.InterpolatedNotPrepared
	$wpdb->query( $wpdb->prepare( "DELETE FROM $table WHERE id = %d", $id ) );
	return new WP_REST_Response( array( 'deleted' => $id ), 200 );
}

// [V7 fixed] Whitelist templates; never include a user-controlled path.
function clean_render() {
	$allowed = array( 'list', 'detail' );
	$key     = isset( $_GET['tpl'] ) ? sanitize_key( wp_unslash( $_GET['tpl'] ) ) : 'list';
	if ( ! in_array( $key, $allowed, true ) ) {
		$key = 'list';
	}
	include plugin_dir_path( __FILE__ ) . 'templates/' . $key . '.php';
}
