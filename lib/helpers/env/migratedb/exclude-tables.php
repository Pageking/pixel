<?php
/**
 * Loaded by Pixel with `wp --require=<this file> migratedb pull ...`.
 *
 * Removes the tables listed in PIXEL_MDB_EXCLUDE_TABLES (comma separated, without table prefix) from the
 * migration, so their rows never leave the remote site. WP Migrate's CLI builds the table list on the machine
 * that runs the command, so this needs no code on the remote site.
 *
 * Only applies to pulls; pushes are left untouched.
 */

if ( ! class_exists( 'WP_CLI' ) ) {
	return;
}

WP_CLI::add_wp_hook(
	'wpmdb_cli_tables_to_migrate',
	function ( $tables, $profile = null ) {
		static $logged = false;

		if ( ! is_array( $tables ) || ! is_array( $profile ) || ! isset( $profile['action'] ) || 'pull' !== $profile['action'] ) {
			return $tables;
		}

		$suffixes = array_filter( array_map( 'trim', explode( ',', (string) getenv( 'PIXEL_MDB_EXCLUDE_TABLES' ) ) ) );
		if ( empty( $suffixes ) ) {
			return $tables;
		}

		$kept     = array();
		$excluded = array();

		foreach ( $tables as $table ) {
			$is_excluded = false;

			foreach ( $suffixes as $suffix ) {
				$needle = '_' . $suffix;
				if ( substr( $table, -strlen( $needle ) ) === $needle ) {
					$is_excluded = true;
					break;
				}
			}

			if ( $is_excluded ) {
				$excluded[] = $table;
			} else {
				$kept[] = $table;
			}
		}

		if ( ! $logged ) {
			$logged = true;
			if ( empty( $excluded ) ) {
				WP_CLI::log( '🔒 No Gravity Forms entry or WooCommerce order tables found on the remote site.' );
			} else {
				WP_CLI::log( '🔒 Skipping tables with personal data: ' . implode( ', ', $excluded ) );
			}
		}

		return $kept;
	},
	// After WP Migrate's own filters (10 and 99) have built the final list.
	100,
	2
);
