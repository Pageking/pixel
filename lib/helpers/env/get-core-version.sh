source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"

get_core_version() {
	local RESULT
	if [[ -d "pk-theme" ]]; then
		cd "pk-theme" || exit 1
		RESULT=$(git describe --tags --abbrev=0 2>/dev/null || true)
		echo "$RESULT"
		return
	fi
	check_public_folder
	cd "wp-content/themes/pk-theme" || exit 1
	# Construct the path to the core version file

	RESULT=$(git describe --tags --abbrev=0 2>/dev/null || true)

	echo "$RESULT"
}