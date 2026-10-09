source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"

create_component() {
	local component_slug template_dir components_dir component_dir file template_content

	if [[ -z "${1:-}" ]]; then
		echo "Usage: pixel create-component <component-slug>"
		exit 1
	fi

	if [[ ! "$1" =~ ^[a-z0-9_-]+$ ]]; then
		echo "❌ Invalid component slug. Use only lowercase letters, numbers, hyphens, and underscores."
		exit 1
	fi

	component_slug="$1"
	check_public_folder

	template_dir="$HOME/.config/pixel/components"
	components_dir="wp-content/themes/pk-theme-child/flex/components"
	component_dir="$components_dir/$component_slug"

	if [[ ! -d "$components_dir" ]]; then
		echo "❌ Components folder not found: $components_dir"
		exit 1
	fi

	if [[ -e "$component_dir" ]]; then
		echo "❌ Component '$component_slug' already exists at $component_dir"
		exit 1
	fi

	mkdir "$component_dir"

	for file in fields.php frontend.php style.scss script.js; do
		if [[ -f "$template_dir/$file" ]]; then
			template_content=$(<"$template_dir/$file")
			template_content="${template_content//\{\{slug\}\}/$component_slug}"
			printf '%s\n' "$template_content" > "$component_dir/$file"
		else
			: > "$component_dir/$file"
		fi
	done

	echo "✅ Component '$component_slug' created successfully!"
	echo "📁 Location: $component_dir"
}
