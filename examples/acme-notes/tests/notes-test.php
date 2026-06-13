<?php
/**
 * Tests for the notes table + REST routes.
 *
 * @package Acme_Notes
 */

/**
 * @group acme-notes
 */
class Notes_Test extends WP_UnitTestCase {

	public function set_up() {
		parent::set_up();
		Acme_Notes_DB::install();
	}

	public function test_table_exists_after_install() {
		global $wpdb;
		$table = Acme_Notes_DB::table();
		// phpcs:ignore WordPress.DB.PreparedSQL.InterpolatedNotPrepared
		$found = $wpdb->get_var( $wpdb->prepare( 'SHOW TABLES LIKE %s', $table ) );
		$this->assertSame( $table, $found );
	}

	public function test_create_and_list_note() {
		$user_id = self::factory()->user->create( array( 'role' => 'editor' ) );
		wp_set_current_user( $user_id );

		$id = Acme_Notes_DB::create( 'Hello' );
		$this->assertGreaterThan( 0, $id );

		$notes = Acme_Notes_DB::for_user( $user_id );
		$this->assertCount( 1, $notes );
		$this->assertSame( 'Hello', $notes[0]['title'] );
	}

	public function test_create_route_requires_capability() {
		wp_set_current_user( self::factory()->user->create( array( 'role' => 'subscriber' ) ) );

		$request = new WP_REST_Request( 'POST', '/acme-notes/v1/notes' );
		$request->set_param( 'title', 'Nope' );
		$response = rest_get_server()->dispatch( $request );

		$this->assertSame( 403, $response->get_status() );
	}
}
