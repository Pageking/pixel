# Personal data that is never pulled to a developer's machine: Gravity Forms submissions and WooCommerce orders.
# Single source of truth for the pull scripts (sync-prod-to-dev, sync-test-to-dev).

PIXEL_MIGRATEDB_PHP_DIR="${BREW_PREFIX}/libexec/lib/helpers/env/migratedb"

# Table names without prefix. Matched against the end of the remote table names, so `wp_` vs. a custom prefix doesn't matter.
PIXEL_EXCLUDED_TABLES=(
	# Gravity Forms entries (2.3+)
	gf_entry
	gf_entry_meta
	gf_entry_notes
	gf_draft_submissions
	# Gravity Forms entries (pre-2.3 legacy tables)
	rg_lead
	rg_lead_detail
	rg_lead_detail_long
	rg_lead_meta
	rg_lead_notes
	rg_incomplete_submissions
	# WooCommerce orders (HPOS)
	wc_orders
	wc_orders_meta
	wc_order_addresses
	wc_order_operational_data
	# WooCommerce order items (both storage types)
	woocommerce_order_items
	woocommerce_order_itemmeta
	# WooCommerce analytics, derived from orders
	wc_order_stats
	wc_order_product_lookup
	wc_order_tax_lookup
	wc_order_coupon_lookup
	wc_customer_lookup
	# WooCommerce download permissions/logs, tied to orders and customer emails
	woocommerce_downloadable_product_permissions
	wc_download_log
)

# Orders stored as posts (legacy storage / HPOS placeholders / subscriptions). WP Migrate also drops their
# postmeta and comments (order notes). Post types that don't exist on the remote are ignored.
PIXEL_EXCLUDED_POST_TYPES=(
	shop_order
	shop_order_refund
	shop_order_placehold
	shop_subscription
)

# Rewrites the caller's `mdb_command` array (bash dynamic scoping, bash 3.2 has no namerefs).
# Expects mdb_command to start with `wp migratedb pull ...`.
apply_personal_data_exclusions() {
	local tables post_types

	if [[ "${mdb_command[0]}" != "wp" || "${mdb_command[2]}" != "pull" ]]; then
		echo "❌ apply_personal_data_exclusions: expected a 'wp migratedb pull' command." >&2
		return 1
	fi

	tables=$(IFS=,; echo "${PIXEL_EXCLUDED_TABLES[*]}")
	post_types=$(IFS=,; echo "${PIXEL_EXCLUDED_POST_TYPES[*]}")

	# Drop the leading `wp` with unset instead of "${mdb_command[@]:1}": bash 3.2 joins a sliced array into a
	# single word inside an array assignment when IFS has no space, which turns the whole command into one argument.
	unset 'mdb_command[0]'
	mdb_command=(
		env "PIXEL_MDB_EXCLUDE_TABLES=$tables"
		wp "--require=${PIXEL_MIGRATEDB_PHP_DIR}/exclude-tables.php"
		"${mdb_command[@]}"
		"--exclude-post-types=$post_types"
	)
}

# Run after a successful pull: recreates the skipped tables (empty) so Gravity Forms/WooCommerce keep working,
# and empties them so no data from an earlier, unfiltered pull stays behind locally.
reset_personal_data_tables() {
	local tables
	tables=$(IFS=,; echo "${PIXEL_EXCLUDED_TABLES[*]}")

	echo "🧹 Emptying local Gravity Forms entry and WooCommerce order tables..."
	PIXEL_MDB_EXCLUDE_TABLES="$tables" wp eval-file "${PIXEL_MIGRATEDB_PHP_DIR}/reset-tables.php"
}
