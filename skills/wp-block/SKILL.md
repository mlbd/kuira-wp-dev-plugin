---
name: wp-block
description: >
  Scaffold a Gutenberg / block editor block. Triggers on "gutenberg block",
  "create block", "block.json", "register block", "dynamic block", "static block",
  "block editor", "custom block", "edit.js", "save.js". Generates a block.json-based
  block (apiVersion 3) with the @wordpress/scripts build, edit/save (static) or a
  render.php (dynamic), attributes, and PHP registration. Opt-in: only runs when asked.
allowed-tools: Read, Write, Bash, Glob
model: sonnet
---

## Gutenberg Block Scaffolder

Modern blocks are defined by a **`block.json`** metadata file and built with
`@wordpress/scripts`. This skill creates a block inside an existing plugin.

### 1. Clarify

- **Block name** → `{slug}/{block-slug}` (namespace must match the plugin).
- **Static or dynamic?**
  - **Static** — markup saved into post content (`save.js`). Best for presentational blocks.
  - **Dynamic** — rendered on the server at view time via `render.php`. Required when
    output depends on live data (queries, current user, settings).
- **Attributes** — the editable data (text, url, boolean, etc.).

### 2. File layout (inside the plugin)

```
src/{block-slug}/
├── block.json
├── index.js          ← registerBlockType
├── edit.js           ← editor component
├── save.js           ← static output  (omit for dynamic)
├── render.php        ← server output   (dynamic only)
├── editor.scss       ← editor-only styles
└── style.scss        ← front + editor styles
```

`@wordpress/scripts` compiles `src/{block-slug}/` → `build/{block-slug}/`, copying
`block.json`/`render.php` and emitting the JS/CSS + an `index.asset.php`.

### 3. `block.json` (apiVersion 3)

```json
{
	"$schema": "https://schemas.wp.org/trunk/block.json",
	"apiVersion": 3,
	"name": "{slug}/{block-slug}",
	"version": "0.1.0",
	"title": "{Block Title}",
	"category": "widgets",
	"icon": "smiley",
	"description": "{description}",
	"textdomain": "{slug}",
	"attributes": {
		"content": { "type": "string", "default": "" }
	},
	"supports": { "html": false, "align": [ "wide", "full" ] },
	"editorScript": "file:./index.js",
	"editorStyle": "file:./editor.css",
	"style": "file:./style.css",
	"render": "file:./render.php"
}
```
> Drop the `"render"` line for a static block; keep `save.js`. For a dynamic block,
> keep `"render"` and omit `save.js` (use `save: () => null`).

### 4. `index.js` + `edit.js`

```js
// index.js
import { registerBlockType } from '@wordpress/blocks';
import metadata from './block.json';
import Edit from './edit';
import save from './save'; // omit for dynamic
import './style.scss';

registerBlockType( metadata.name, { edit: Edit, save } );
```

```js
// edit.js
import { useBlockProps, RichText } from '@wordpress/block-editor';
import { __ } from '@wordpress/i18n';

export default function Edit( { attributes, setAttributes } ) {
	const blockProps = useBlockProps();
	return (
		<RichText
			{ ...blockProps }
			tagName="p"
			value={ attributes.content }
			onChange={ ( content ) => setAttributes( { content } ) }
			placeholder={ __( 'Write…', '{slug}' ) }
		/>
	);
}
```

**Static** `save.js`:
```js
import { useBlockProps, RichText } from '@wordpress/block-editor';
export default function save( { attributes } ) {
	return <RichText.Content { ...useBlockProps.save() } tagName="p" value={ attributes.content } />;
}
```

**Dynamic** `render.php` (escape on output):
```php
<?php
/**
 * Dynamic render. $attributes, $content, $block are in scope.
 *
 * @package {Package_Name}
 */
?>
<p <?php echo get_block_wrapper_attributes(); ?>>
	<?php echo esc_html( $attributes['content'] ?? '' ); ?>
</p>
```

### 5. Register in PHP

Point WordPress at the **built** block directory:

```php
add_action(
	'init',
	function () {
		register_block_type( {PREFIX}_DIR . 'build/{block-slug}' );
	}
);
```

`register_block_type()` reads `block.json`, enqueues the scripts/styles, and wires
the `render.php` callback automatically — no manual `wp_enqueue` needed.

### 6. Build & verify

```
npm install   # if @wordpress/scripts isn't already present
npm run build # or: npm start  for watch mode
```

Confirm `build/{block-slug}/block.json` exists, then check the block appears in the
editor inserter. For interactivity on the front end, mention the Interactivity API
(`@wordpress/interactivity` + `viewScriptModule`) as the next step.
