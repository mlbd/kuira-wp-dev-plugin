<?php
/**
 * REST controller — secure by default.
 *
 * @package Acme_Notes
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Registers and handles the acme-notes/v1 routes.
 */
class Acme_Notes_Rest_Controller {

	const REST_NAMESPACE = 'acme-notes/v1';

	/**
	 * Constructor.
	 */
	public function __construct() {
		add_action( 'rest_api_init', array( $this, 'register_routes' ) );
	}

	/**
	 * Register routes.
	 *
	 * @return void
	 */
	public function register_routes() {
		register_rest_route(
			self::REST_NAMESPACE,
			'/notes',
			array(
				array(
					'methods'             => WP_REST_Server::READABLE,
					'callback'            => array( $this, 'get_notes' ),
					'permission_callback' => array( $this, 'can_read' ),
				),
				array(
					'methods'             => WP_REST_Server::CREATABLE,
					'callback'            => array( $this, 'create_note' ),
					'permission_callback' => array( $this, 'can_edit' ),
					'args'                => array(
						'title' => array(
							'required'          => true,
							'type'              => 'string',
							'sanitize_callback' => 'sanitize_text_field',
							'validate_callback' => static function ( $value ) {
								return is_string( $value ) && '' !== trim( $value );
							},
						),
					),
				),
			)
		);
	}

	/**
	 * Read permission: any logged-in user may read their own notes.
	 *
	 * @return bool|WP_Error
	 */
	public function can_read() {
		if ( ! is_user_logged_in() ) {
			return new WP_Error( 'rest_forbidden', __( 'You must be logged in.', 'acme-notes' ), array( 'status' => 401 ) );
		}
		return true;
	}

	/**
	 * Edit permission: requires a capability — never __return_true.
	 *
	 * @return bool|WP_Error
	 */
	public function can_edit() {
		if ( ! current_user_can( 'edit_posts' ) ) {
			return new WP_Error( 'rest_forbidden', __( 'Insufficient permissions.', 'acme-notes' ), array( 'status' => 403 ) );
		}
		return true;
	}

	/**
	 * GET /notes — the caller's own notes.
	 *
	 * @return WP_REST_Response
	 */
	public function get_notes() {
		$notes = Acme_Notes_DB::for_user( get_current_user_id() );
		return new WP_REST_Response( array( 'notes' => $notes ), 200 );
	}

	/**
	 * POST /notes — create a note. $title is already sanitized by the args schema.
	 *
	 * @param WP_REST_Request $request Request.
	 * @return WP_REST_Response|WP_Error
	 */
	public function create_note( WP_REST_Request $request ) {
		$title = $request->get_param( 'title' );
		$id    = Acme_Notes_DB::create( $title );

		if ( 0 === $id ) {
			return new WP_Error( 'acme_notes_create_failed', __( 'Could not save the note.', 'acme-notes' ), array( 'status' => 500 ) );
		}

		return new WP_REST_Response(
			array(
				'id'    => $id,
				'title' => $title,
			),
			201
		);
	}
}
