create_layout() {
	local layout_slug layyout_label layout_category
	local TEMPLATE_DIR="$HOME/.config/pixel/templates"

	if ! [[ -d "$TEMPLATE_DIR" ]]; then
		echo "Missing templates folder in your /.config/pixel/. Setting a standard template for the usual files can increase your productivity!"
	fi

	# Validate slug parameter
	if ! [[ -n "$1" ]]; then
		echo "🤦 No layout slug given."
		exit 1
	fi

	if ! [[ "$1" =~ ^[a-z0-9_]+$ ]]; then
		echo "❌ Invalid slug. Use only lowercase letters, numbers, and underscores."
		exit 1
	fi

	layout_slug="$1"

	# Validate label parameter
	if ! [[ -n "$2" ]]; then
		echo "🤦 No layout label given."
		exit 1
	fi

	layout_label="$2"

	# Set default category if not provided
	if ! [[ -n "$3" ]]; then
		layout_category='Content'
	else
		layout_category="$3"
	fi

	# Navigate to layouts directory
	cd wp-content/themes/pk-theme-child/flex/content/layouts/ || { echo "No layouts folder found"; exit 1; }

	# Check if layout already exists
	if [[ -d "$layout_slug" ]]; then
		echo "Layout $layout_slug already exists."
		echo "❌ Cancelling creation of $layout_slug."
		exit 0
	else
		read -rp "📝 Create $layout_slug layout? [Y/n] " create_layout
		if [[ "$create_layout" =~ ^[Nn]$ ]]; then
			echo "❌ Cancelling creation of $layout_slug."
			exit 0
		fi
	fi

	# Create layout directory
	mkdir -p "$layout_slug"
	cd "$layout_slug" || { echo "Could not find folder $layout_slug."; exit 1; }

	# Function to replace placeholders in templates
	replace_placeholders() {
		local content="$1"
		content="${content//\{\{slug\}\}/$layout_slug}"
		content="${content//\{\{label\}\}/$layout_label}"
		content="${content//\{\{category\}\}/$layout_category}"
		echo "$content"
	}

	# Create frontend.php
	if [[ -f "$TEMPLATE_DIR/frontend.php" ]]; then
		echo "📄 Using frontend.php template from /.config/pixel/templates/"
		template_content=$(cat "$TEMPLATE_DIR/frontend.php")
		replaced_content=$(replace_placeholders "$template_content" "$layout_slug" "$layout_label")
		echo "$replaced_content" > frontend.php
	else
		touch frontend.php
	fi

	# Create fields.php
	if [[ -f "$TEMPLATE_DIR/fields.php" ]]; then
		echo "📄 Using fields.php template from /.config/pixel/templates/"
		template_content=$(cat "$TEMPLATE_DIR/fields.php")
		replaced_content=$(replace_placeholders "$template_content" "$layout_slug" "$layout_label")
		echo "$replaced_content" > fields.php
	else
		touch fields.php
	fi

	# Create script.js
	if [[ -f "$TEMPLATE_DIR/script.js" ]]; then
		echo "📄 Using script.js template from /.config/pixel/templates/"
		template_content=$(cat "$TEMPLATE_DIR/script.js")
		replaced_content=$(replace_placeholders "$template_content" "$layout_slug" "$layout_label")
		echo "$replaced_content" > script.js
	else
		touch script.js
	fi

	# Create style.css
	if [[ -f "$TEMPLATE_DIR/style.css" ]]; then
		echo "📄 Using style.css template from /.config/pixel/templates/"
		template_content=$(cat "$TEMPLATE_DIR/style.css")
		replaced_content=$(replace_placeholders "$template_content" "$layout_slug" "$layout_label")
		echo "$replaced_content" > style.css
	else
		touch style.css
	fi

	echo "✅ Layout '$layout_slug' created successfully!"
	echo "📁 Location: $(pwd)"
	echo ""
	echo "Files created:"
	ls -l
}