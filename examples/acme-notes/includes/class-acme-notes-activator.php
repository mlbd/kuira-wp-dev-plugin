<?php
/**
 * Activation logic.
 *
 * @package Acme_Notes
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Runs once on plugin activation.
 */
class Acme_Notes_Activator {

	/**
	 * Create tables and seed the DB version.
	 *
	 * @return void
	 */
	public static function activate() {
		require_once ACME_NOTES_DIR . 'includes/class-acme-notes-db.php';
		Acme_Notes_DB::install();
	}
}
