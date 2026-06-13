<?php
/**
 * Deactivation logic.
 *
 * @package Acme_Notes
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Runs once on plugin deactivation. Never destroys data here — that belongs in
 * uninstall.php.
 */
class Acme_Notes_Deactivator {

	/**
	 * Clean up transient/scheduled state only.
	 *
	 * @return void
	 */
	public static function deactivate() {
		// Nothing persistent to clean up in this reference plugin.
	}
}
