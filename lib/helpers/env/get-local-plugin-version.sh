source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/version-compare.sh"

get_local_plugin_version() {
	local slug="${1:?get_local_plugin_version: plugin slug is required}"
	local result

	check_public_folder

	result=$(wp plugin get "$slug" --field=version 2>/dev/null) || {
		echo "❌ Could not read local version for plugin '$slug'. Is it installed?" >&2
		return 1
	}

	result=$(extract_version_string "$result")
	if [[ -z "$result" ]]; then
		echo "❌ Could not parse local version for plugin '$slug'." >&2
		return 1
	fi

	echo "$result"
}
