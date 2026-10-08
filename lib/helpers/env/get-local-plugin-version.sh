source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"

get_local_plugin_version() {
	local slug="${1:?get_local_plugin_version: plugin slug is required}"
	local result

	check_public_folder

	result=$(wp plugin get "$slug" --field=version 2>/dev/null) || {
		echo "❌ Could not read local version for plugin '$slug'. Is it installed?" >&2
		return 1
	}

	echo "$result"
}
