import { createRoot } from '@wordpress/element';
import App from './app';
import './style.scss';

document.addEventListener( 'DOMContentLoaded', () => {
	const el = document.getElementById( 'acme-notes-root' );
	if ( el ) {
		createRoot( el ).render( <App /> );
	}
} );
