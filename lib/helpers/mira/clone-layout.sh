source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"
check_public_folder

clone_layout() {
	source "${BREW_PREFIX}/libexec/lib/helpers/mira/list.sh"
	local layout_name layout_path dest_path
	layout_name="$1"
	# Validate arguments
    if [ -z "$layout_name" ]; then
        echo "Usage: pixel mira clone <block-name>"
        echo ""
        echo "Available blocks:"
		list_mira
        exit 1
    fi

	if [[ ! "$layout_name" =~ ^mira_ ]]; then
		layout_name="mira_$layout_name"
	fi

	layout_path="$MIRA_LAYOUTS/$layout_name"
	if [ ! -d "$layout_path" ]; then
        echo "❓ Block '$layout_name' not found in Mira repository"
        echo ""
        list_mira
        exit 1
    fi

	dest_path="wp-content/themes/pk-theme-child/flex/content/layouts/$layout_name"
	# Check if block already exists
    if [ -d "$dest_path" ]; then
        echo "⚠️ Layout '$layout_name' already exists in this project"
		exit 1
    fi

	# Copy the block
    echo "📦 Cloning $layout_name..."
    cp -r "$layout_path" "$dest_path"

	if [ $? -eq 0 ]; then
        echo "Copied to $dest_path"
        echo "🎉 Done! Block $layout_name is now available."
    else
        echo "Failed to copy block"
        exit 1
    fi
}