<?php
/**
 * Plugin Name: Vuln Demo (DO NOT USE)
 * Description: INTENTIONALLY VULNERABLE code. A fixture for testing the kuira security/quality auditors. Never ship this.
 * Version: 0.0.0
 *
 * @package Vuln_Demo
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

// [V1] AJAX handler with NO nonce (CSRF) and NO capability check (privilege escalation).
add_action( 'wp_ajax_vuln_save', 'vuln_save' );
function vuln_save() {
	// [V2] Unsanitized input written straight to an option.
	$name = $_POST['name'];
	update_option( 'vuln_name', $name );

	// [V3] Unescaped output of request data (reflected XSS).
	echo 'Saved: ' . $_POST['name'];
	wp_die();
}

// [V4] SQL injection: $_GET interpolated into the query with no prepare().
function vuln_lookup() {
	global $wpdb;
	$id = $_GET['id'];
	return $wpdb->get_results( "SELECT * FROM {$wpdb->prefix}vuln WHERE id = $id" );
}

// [V5] REST route exposing a destructive action with permission_callback __return_true.
add_action(
	'rest_api_init',
	function () {
		register_rest_route(
			'vuln/v1',
			'/delete',
			array(
				'methods'             => 'POST',
				'callback'            => 'vuln_delete',
				'permission_callback' => '__return_true',
			)
		);
	}
);
function vuln_delete( $request ) {
	global $wpdb;
	// [V6] Unsanitized REST param in a DELETE with no prepare().
	$id = $request['id'];
	$wpdb->query( "DELETE FROM {$wpdb->prefix}vuln WHERE id = $id" );
	return array( 'deleted' => $id );
}

// [V7] File inclusion from a user-controlled path (LFI / potential RCE).
function vuln_render() {
	$tpl = $_GET['tpl'];
	include $tpl . '.php';
}
