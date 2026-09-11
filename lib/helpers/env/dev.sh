source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"

dev() {
    check_public_folder || return 1
	local theme_dir project_name
    theme_dir="wp-content/themes/pk-theme-child"
    [ -d "$theme_dir" ] || { echo "No child-theme found"; return 1; }
    project_name=$(basename "$(dirname "$(dirname "$PWD")")")

    (
        cd "$theme_dir" || exit 1
        if [ ! -d "node_modules" ]; then
            npm ci || exit 1
        fi
        npm run dev -- --proxy "http://$project_name.local"
    )
}