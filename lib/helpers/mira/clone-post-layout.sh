source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"
check_public_folder

clone_post_layout() {
	source "${BREW_PREFIX}/libexec/lib/helpers/mira/list-post.sh"
	local source_name local_name layout_path dest_path
	source_name="$1"
	local_name="$2"

	if [ -z "$source_name" ] || [ -z "$local_name" ]; then
		echo "Usage: pixel mira clone-post <source-layout> <new-name>"
		echo ""
		list_mira_post
		exit 1
	fi

	if [[ ! "$source_name" =~ ^mira_ ]]; then
		source_name="mira_$source_name"
	fi

	layout_path="$MIRA_POST_LAYOUTS/$source_name"
	if [ ! -d "$layout_path" ]; then
		echo "❓ Post layout '$source_name' not found in Mira repository"
		echo ""
		list_mira_post
		exit 1
	fi

	dest_path="wp-content/themes/pk-theme-child/flex/content/post-layouts/$local_name"
	if [ -d "$dest_path" ]; then
		echo "⚠️ Post layout '$local_name' already exists in this project"
		exit 1
	fi

	if [[ -e "$layout_path/components.json" ]]; then
		source "${BREW_PREFIX}/libexec/lib/helpers/mira/clone-component.sh"
		clone_component "$layout_path/components.json"
	fi

	echo "📦 Cloning $source_name as $local_name..."
	if rsync -r --exclude="components.json" "$layout_path/" "$dest_path/"; then
		find "$dest_path" -type f \( -name "*.php" -o -name "*.css" -o -name "*.js" \) \
			-exec sed -i '' "s/${source_name}/${local_name}/g" {} \;
		echo "Copied to $dest_path"
		echo "🎉 Done! Post layout '$local_name' is now available."
	else
		echo "Failed to copy post layout"
		exit 1
	fi
}
