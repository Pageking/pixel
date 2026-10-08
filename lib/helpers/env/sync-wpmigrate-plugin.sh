source "${BREW_PREFIX}/libexec/lib/helpers/env/version-compare.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-local-plugin-version.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/test/wpmigrate-plugin-test.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/prod/wpmigrate-plugin-prod.sh"

WPM_PLUGIN_SLUG="wp-migrate-db-pro"

# sync_wpmigrate_plugin <test|prod>
#
# Compares the local and remote "${WPM_PLUGIN_SLUG}" plugin version and updates whichever
# side (local or remote) is older via WP-CLI, so that `wp migratedb push|pull` doesn't fail
# on a version mismatch.
sync_wpmigrate_plugin() {
	local environment="${1:?sync_wpmigrate_plugin: environment (test|prod) is required}"
	local local_version remote_version

	if [[ "$environment" != "test" && "$environment" != "prod" ]]; then
		echo "❌ Usage: sync_wpmigrate_plugin <test|prod>" >&2
		return 1
	fi

	echo "🔎 Comparing local and $environment versions of '$WPM_PLUGIN_SLUG'..."

	local_version=$(get_local_plugin_version "$WPM_PLUGIN_SLUG") || return 1

	if [[ "$environment" == "test" ]]; then
		remote_version=$(get_remote_plugin_version_test "$WPM_PLUGIN_SLUG") || return 1
	else
		remote_version=$(get_remote_plugin_version_prod "$WPM_PLUGIN_SLUG") || return 1
	fi

	if [[ "$local_version" == "$remote_version" ]]; then
		echo "✅ '$WPM_PLUGIN_SLUG' is already in sync at '$local_version'."
		return 0
	fi

	echo "⚠️  Version mismatch detected for '$WPM_PLUGIN_SLUG':"
	echo "   Local       : $local_version"
	echo "   $environment : $remote_version"

	local side_to_update other_version
	if version_is_older "$local_version" "$remote_version"; then
		side_to_update="local"
		other_version="$remote_version"
	else
		side_to_update="$environment"
		other_version="$local_version"
	fi

	read -rp "Update $side_to_update '$WPM_PLUGIN_SLUG' to match version '$other_version'? [y/N]: " confirm_update
	if [[ ! "$confirm_update" =~ ^[Yy]$ ]]; then
		echo "❌ Aborting plugin version sync. Note that 'wp migratedb' may fail with a version mismatch."
		return 1
	fi

	if [[ "$side_to_update" == "local" ]]; then
		check_public_folder
		wp plugin update "$WPM_PLUGIN_SLUG"
	elif [[ "$environment" == "test" ]]; then
		update_remote_plugin_test "$WPM_PLUGIN_SLUG"
	else
		update_remote_plugin_prod "$WPM_PLUGIN_SLUG"
	fi

	echo "✅ '$WPM_PLUGIN_SLUG' updated on $side_to_update."
}
