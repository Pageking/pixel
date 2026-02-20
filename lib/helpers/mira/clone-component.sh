clone_component() {
	local components_json component_name source_path
	components_json="$1"
	
	# Check if the components.json file exists
	if [ ! -f "$components_json" ]; then
		echo "❌ Components file not found: $components_json"
		exit 1
	fi
	
	# Parse and iterate through each component
	jq -r '.[]' "$components_json" | while read -r component_name; do
		# Determine the source path (relative to mira repo)
		source_path="$MIRA_COMPONENTS/$component_name"
		
		# Check if component source exists
		if [ ! -d "$source_path" ]; then
			echo "⚠️ Component '$component_name' source not found: $source_path"
			continue
		fi
		
		# Check if component already exists in the project
		if [ -d "./wp-content/themes/pk-theme-child/flex/components/$component_name" ]; then
			echo "⚠️ Component '$component_name' already exists at /wp-content/themes/pk-theme-child/flex/components/$component_name"
			continue
		fi
		
		# Copy the component
		echo "📦 Cloning component: $component_name..."
		cd "./wp-content/themes/pk-theme-child/flex/components" || exit 1
		rsync -r "$source_path/" "$component_name"
		
		if [ $? -eq 0 ]; then
			echo "✅ Component '$component_name' successfully cloned"
		else
			echo "❌ Failed to clone component '$component_name'"
		fi
	done
}