source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"

clean() {
	check_public_folder || return 1

	local theme_dir="wp-content/themes/pk-theme-child"
	[ -d "$theme_dir" ] || { echo "No child-theme found"; return 1; }

	(
		cd "$theme_dir" || exit 1

		echo "🧹 Removing node_modules..."
		rm -rf node_modules

		echo "📦 Reinstalling dependencies..."
		npm ci
	)
}
