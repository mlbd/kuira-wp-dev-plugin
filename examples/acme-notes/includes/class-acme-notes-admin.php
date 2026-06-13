<?php
/**
 * Admin UI + asset loading.
 *
 * @package Acme_Notes
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Registers the admin page and enqueues the React bundle.
 */
class Acme_Notes_Admin {

	const HANDLE = 'acme-notes-admin';

	/**
	 * Hook suffix of the plugin's admin page (to scope asset loading).
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
	 *
	 * @return void
	 */
	public function register_menu() {
		$this->hook_suffix = add_menu_page(
			__( 'Acme Notes', 'acme-notes' ),
			__( 'Acme Notes', 'acme-notes' ),
			'edit_posts',
			'acme-notes',
			array( $this, 'render_page' ),
			'dashicons-edit'
		);
	}

	/**
	 * Render the React mount point.
	 *
	 * @return void
	 */
	public function render_page() {
		echo '<div class="wrap"><div id="acme-notes-root"></div></div>';
	}

	/**
	 * Enqueue assets only on this plugin's admin screen.
	 *
	 * @param string $hook Current admin page hook suffix.
	 * @return void
	 */
	public function enqueue_assets( $hook ) {
		if ( $hook !== $this->hook_suffix ) {
			return;
		}

		$asset_file = ACME_NOTES_DIR . 'build/index.asset.php';
		if ( ! file_exists( $asset_file ) ) {
			return; // Run `npm run build` first.
		}

		$asset = include $asset_file;

		wp_enqueue_script( self::HANDLE, ACME_NOTES_URL . 'build/index.js', $asset['dependencies'], $asset['version'], true );
		wp_enqueue_style( self::HANDLE, ACME_NOTES_URL . 'build/index.css', array( 'wp-components' ), $asset['version'] );

		wp_localize_script(
			self::HANDLE,
			'acmeNotesData',
			array(
				'restUrl' => esc_url_raw( rest_url( Acme_Notes_Rest_Controller::REST_NAMESPACE . '/' ) ),
				'nonce'   => wp_create_nonce( 'wp_rest' ),
			)
		);
	}
}
