<?php
/**
 * Custom table schema, migrations, and CRUD.
 *
 * @package Acme_Notes
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Data access for the acme_notes table.
 */
class Acme_Notes_DB {

	/**
	 * Fully-qualified table name.
	 *
	 * @return string
	 */
	public static function table() {
		global $wpdb;
		return $wpdb->prefix . 'acme_notes';
	}

	/**
	 * Create/upgrade the table via dbDelta, then store the DB version.
	 *
	 * @return void
	 */
	public static function install() {
		global $wpdb;

		$table   = self::table();
		$charset = $wpdb->get_charset_collate();

		$sql = "CREATE TABLE $table (
			id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
			user_id bigint(20) unsigned NOT NULL DEFAULT 0,
			title varchar(191) NOT NULL DEFAULT '',
			created_at datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
			PRIMARY KEY  (id),
			KEY user_id (user_id)
		) $charset;";

		require_once ABSPATH . 'wp-admin/includes/upgrade.php';
		dbDelta( $sql );

		update_option( 'acme_notes_db_version', ACME_NOTES_DB_VERSION );
	}

	/**
	 * Insert a note for the current user.
	 *
	 * @param string $title Sanitized title.
	 * @return int Inserted row ID, or 0 on failure.
	 */
	public static function create( $title ) {
		global $wpdb;

		$wpdb->insert(
			self::table(),
			array(
				'user_id'    => get_current_user_id(),
				'title'      => $title,
				'created_at' => current_time( 'mysql' ),
			),
			array( '%d', '%s', '%s' )
		);

		return (int) $wpdb->insert_id;
	}

	/**
	 * List notes for a given user.
	 *
	 * @param int $user_id User ID.
	 * @param int $limit   Max rows.
	 * @return array<int, array<string, mixed>>
	 */
	public static function for_user( $user_id, $limit = 20 ) {
		global $wpdb;

		$table = self::table();

		// Table name is built from the trusted prefix; values are prepared.
		// phpcs:ignore WordPress.DB.PreparedSQL.InterpolatedNotPrepared
		$sql = $wpdb->prepare(
			"SELECT id, title, created_at FROM $table WHERE user_id = %d ORDER BY id DESC LIMIT %d",
			$user_id,
			$limit
		);

		// phpcs:ignore WordPress.DB.PreparedSQL.NotPrepared
		$rows = $wpdb->get_results( $sql, ARRAY_A );

		return is_array( $rows ) ? $rows : array();
	}
}
