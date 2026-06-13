<?php
/**
 * PHPUnit bootstrap — loads the WP test suite, then the plugin.
 *
 * @package Acme_Notes
 */

$_tests_dir = getenv( 'WP_TESTS_DIR' );
if ( ! $_tests_dir ) {
	$_tests_dir = rtrim( sys_get_temp_dir(), '/\\' ) . '/wordpress-tests-lib';
}

require_once $_tests_dir . '/includes/functions.php';

tests_add_filter(
	'muplugins_loaded',
	static function () {
		require dirname( __DIR__ ) . '/acme-notes.php';
	}
);

require $_tests_dir . '/includes/bootstrap.php';
