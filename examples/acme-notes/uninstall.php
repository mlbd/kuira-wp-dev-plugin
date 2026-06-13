<?php
/**
 * Fired when the plugin is deleted.
 *
 * @package Acme_Notes
 */

if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}

global $wpdb;

// Remove only what this plugin created.
$table = $wpdb->prefix . 'acme_notes';
// phpcs:ignore WordPress.DB.PreparedSQL.InterpolatedNotPrepared, WordPress.DB.DirectDatabaseQuery.SchemaChange
$wpdb->query( "DROP TABLE IF EXISTS $table" );

delete_option( 'acme_notes_db_version' );
