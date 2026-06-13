import { useState, useEffect } from '@wordpress/element';
import { Button, Card, CardBody, TextControl, Notice } from '@wordpress/components';
import { __ } from '@wordpress/i18n';
import apiFetch from '@wordpress/api-fetch';

const { restUrl, nonce } = window.acmeNotesData || {};

export default function App() {
	const [ title, setTitle ] = useState( '' );
	const [ notes, setNotes ] = useState( [] );
	const [ error, setError ] = useState( '' );

	useEffect( () => {
		apiFetch( { url: `${ restUrl }notes`, headers: { 'X-WP-Nonce': nonce } } )
			.then( ( res ) => setNotes( res.notes || [] ) )
			.catch( () => setError( __( 'Could not load notes.', 'acme-notes' ) ) );
	}, [] );

	const save = () => {
		apiFetch( {
			url: `${ restUrl }notes`,
			method: 'POST',
			headers: { 'X-WP-Nonce': nonce },
			data: { title },
		} )
			.then( ( note ) => {
				setNotes( [ note, ...notes ] );
				setTitle( '' );
			} )
			.catch( () => setError( __( 'Could not save the note.', 'acme-notes' ) ) );
	};

	return (
		<Card>
			<CardBody>
				<h2>{ __( 'Acme Notes', 'acme-notes' ) }</h2>
				{ error && <Notice status="error" onRemove={ () => setError( '' ) }>{ error }</Notice> }
				<TextControl label={ __( 'Title', 'acme-notes' ) } value={ title } onChange={ setTitle } />
				<Button variant="primary" onClick={ save } disabled={ '' === title.trim() }>
					{ __( 'Save', 'acme-notes' ) }
				</Button>
				<ul>
					{ notes.map( ( note ) => (
						<li key={ note.id }>{ note.title }</li>
					) ) }
				</ul>
			</CardBody>
		</Card>
	);
}
