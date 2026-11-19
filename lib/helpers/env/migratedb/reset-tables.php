<?php
/**
 * Run by Pixel with `wp eval-file <this file>` after a pull.
 *
 * The tables in PIXEL_MDB_EXCLUDE_TABLES were skipped by the pull, but wp_options came along, so Gravity Forms
 * and WooCommerce think their schema is up to date. This recreates any missing tables and empties the existing
 * ones, so no personal data from an earlier, unfiltered pull stays on this machine.
 */

global $wpdb;

$suffixes = array_filter( array_map( 'trim', explode( ',', (string) getenv( 'PIXEL_MDB_EXCLUDE_TABLES' ) ) ) );
if ( empty( $suffixes ) ) {
	WP_CLI::error( 'PIXEL_MDB_EXCLUDE_TABLES is empty, nothing to reset.' );
}

// Both use dbDelta, so they only create what's missing.
if ( class_exists( 'WC_Install' ) && method_exists( 'WC_Install', 'create_tables' ) ) {
	WC_Install::create_tables();
}
if ( function_exists( 'gf_upgrade' ) ) {
	gf_upgrade()->upgrade_schema();
}

$emptied = array();
foreach ( $suffixes as $suffix ) {
	$table = $wpdb->prefix . $suffix;

	if ( $wpdb->get_var( $wpdb->prepare( 'SHOW TABLES LIKE %s', $wpdb->esc_like( $table ) ) ) !== $table ) {
		continue;
	}

	if ( false === $wpdb->query( "TRUNCATE TABLE `{$table}`" ) ) {
		WP_CLI::warning( "Could not empty {$table}: {$wpdb->last_error}" );
		continue;
	}

	$emptied[] = $table;
}

WP_CLI::success( empty( $emptied ) ? 'No personal data tables present locally.' : 'Emptied: ' . implode( ', ', $emptied ) );
