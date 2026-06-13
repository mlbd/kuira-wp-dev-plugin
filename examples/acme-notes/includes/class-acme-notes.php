<?php
/**
 * Core plugin class.
 *
 * @package Acme_Notes
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Main plugin orchestrator (singleton).
 */
class Acme_Notes {

	/**
	 * Singleton instance.
	 *
	 * @var Acme_Notes|null
	 */
	private static $instance = null;

	/**
	 * Get the singleton instance.
	 *
	 * @return Acme_Notes
	 */
	public static function get_instance() {
		if ( null === self::$instance ) {
			self::$instance = new self();
		}
		return self::$instance;
	}

	/**
	 * Constructor — wire up hooks and collaborators.
	 */
	private function __construct() {
		add_action( 'init', array( $this, 'load_textdomain' ) );
		add_action( 'plugins_loaded', array( $this, 'maybe_upgrade' ) );

		require_once ACME_NOTES_DIR . 'includes/class-acme-notes-db.php';
		require_once ACME_NOTES_DIR . 'includes/class-acme-notes-rest-controller.php';
		require_once ACME_NOTES_DIR . 'includes/class-acme-notes-admin.php';

		new Acme_Notes_Rest_Controller();
		new Acme_Notes_Admin();
	}

	/**
	 * Load translations.
	 *
	 * @return void
	 */
	public function load_textdomain() {
		load_plugin_textdomain( 'acme-notes', false, dirname( plugin_basename( ACME_NOTES_FILE ) ) . '/languages' );
	}

	/**
	 * Run DB migrations when the stored version is behind.
	 *
	 * @return void
	 */
	public function maybe_upgrade() {
		$installed = get_option( 'acme_notes_db_version', '0' );
		if ( version_compare( $installed, ACME_NOTES_DB_VERSION, '<' ) ) {
			Acme_Notes_DB::install();
		}
	}
}
