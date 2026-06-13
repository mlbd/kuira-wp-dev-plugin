---
name: wp-db
description: >
  Create and migrate custom database tables in a WordPress plugin. Triggers on
  "custom table", "dbdelta", "database schema", "create table", "migration",
  "schema upgrade", "db version", "alter table", "$wpdb". Generates dbDelta-correct
  schema creation on activation, version-gated upgrade routines, prepared CRUD
  helpers, and uninstall cleanup. Opt-in: only runs when asked.
allowed-tools: Read, Write, Bash, Grep, Glob
model: sonnet
---

## Custom Tables & Migrations

Custom tables are where plugins most often introduce SQL injection and broken
upgrades. This skill follows the two rules that prevent both: **`dbDelta` for
schema**, **`$wpdb->prepare()` for every query with input**.

> First ask: does this really need a custom table? Post meta, options, or a CPT are
> often enough and survive core changes better. Only scaffold a table when the data
> is genuinely relational/high-volume.

### 1. dbDelta is picky — formatting matters

`dbDelta()` parses the SQL string with strict expectations. Get these wrong and it
silently fails to create or alter the table:

- **Two spaces** between `PRIMARY KEY` and the `(column)`.
- Each field on its **own line**.
- `KEY` not `INDEX`; give every key a name.
- Lowercase column types (`int`, `varchar`) by convention.
- Use `$wpdb->get_charset_collate()` for the charset clause.
- **Do not** use `IF NOT EXISTS` — dbDelta handles create-vs-alter itself.

### 2. Schema creation (on activation)

```php
/**
 * Create or update the custom table. Safe to run repeatedly (dbDelta diffs it).
 */
function {prefix}_create_tables() {
	global $wpdb;

	$table   = $wpdb->prefix . '{prefix}_items';
	$charset = $wpdb->get_charset_collate();

	$sql = "CREATE TABLE $table (
		id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
		user_id bigint(20) unsigned NOT NULL DEFAULT 0,
		title varchar(191) NOT NULL DEFAULT '',
		status varchar(20) NOT NULL DEFAULT 'draft',
		created_at datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
		PRIMARY KEY  (id),
		KEY user_id (user_id),
		KEY status (status)
	) $charset;";

	require_once ABSPATH . 'wp-admin/includes/upgrade.php';
	dbDelta( $sql );

	update_option( '{prefix}_db_version', {PREFIX}_DB_VERSION );
}
```

Define `define( '{PREFIX}_DB_VERSION', '1.0.0' );` in the main file and call
`{prefix}_create_tables()` from the activation hook. Note `varchar(191)` — the safe
max for a `utf8mb4` indexed column on older MySQL.

### 3. Version-gated migrations

Activation hooks **don't fire on plugin updates**, so check the stored version on
load and run incremental upgrades:

```php
add_action(
	'plugins_loaded',
	function () {
		$installed = get_option( '{prefix}_db_version', '0' );
		if ( version_compare( $installed, {PREFIX}_DB_VERSION, '<' ) ) {
			{prefix}_migrate( $installed );
		}
	}
);

/**
 * Run incremental migrations from $from up to the current version.
 *
 * @param string $from Installed DB version.
 */
function {prefix}_migrate( $from ) {
	// Re-running dbDelta applies additive column/key changes safely.
	{prefix}_create_tables();

	// Data migrations that dbDelta can't express go here, gated by version:
	// if ( version_compare( $from, '1.1.0', '<' ) ) { ... backfill ... }

	update_option( '{prefix}_db_version', {PREFIX}_DB_VERSION );
}
```

### 4. Prepared CRUD — never interpolate input

```php
global $wpdb;
$table = $wpdb->prefix . '{prefix}_items';

// INSERT — $wpdb->insert prepares for you; pass a format array.
$wpdb->insert(
	$table,
	array(
		'user_id'    => get_current_user_id(),
		'title'      => $title,                 // already sanitized at the boundary
		'created_at' => current_time( 'mysql' ),
	),
	array( '%d', '%s', '%s' )
);
$new_id = $wpdb->insert_id;

// SELECT with input — ALWAYS prepare.
$rows = $wpdb->get_results(
	$wpdb->prepare( "SELECT * FROM $table WHERE status = %s AND user_id = %d", $status, $user_id ),
	ARRAY_A
);

// UPDATE / DELETE — use the helper forms with format arrays.
$wpdb->update( $table, array( 'status' => 'done' ), array( 'id' => $id ), array( '%s' ), array( '%d' ) );
$wpdb->delete( $table, array( 'id' => $id ), array( '%d' ) );
```

> The table name itself can't be passed as a `%s` placeholder — build it from
> `$wpdb->prefix` (trusted), never from user input. Add `phpcs:ignore
> WordPress.DB.PreparedSQL` only when you've manually confirmed safety.

### 5. Uninstall cleanup

In `uninstall.php` (runs only on delete), drop the table and remove the version option:

```php
global $wpdb;
$table = $wpdb->prefix . '{prefix}_items';
$wpdb->query( "DROP TABLE IF EXISTS $table" );
delete_option( '{prefix}_db_version' );
```

> For multisite, loop sites with `get_sites()` and repeat per blog, or the data is
> orphaned on secondary sites.

### 6. Finish

Report the table name, columns/keys, the `*_DB_VERSION` constant, and remind the
user to bump `{PREFIX}_DB_VERSION` whenever the schema changes so the migration
runs. Suggest `wp-test` to add a test that asserts the table exists after activation.
