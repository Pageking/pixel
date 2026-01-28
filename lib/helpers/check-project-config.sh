IFS=$'\n\t'

check_project_config() {
	local PROJECT_CONFIG
	PROJECT_CONFIG="$(pwd)/wp-content/themes/pk-theme-child/pixel.json"

	if [[ ! -e "$PROJECT_CONFIG" ]]; then
		echo "❌ Project config not found at $PROJECT_CONFIG"
		echo "Please ensure you are in the correct project directory and that the project-config.json file exists."
		exit 1
	else
		# Check if file exists and is writable
		if [[ ! -w "$PROJECT_CONFIG" ]]; then
			echo "❌ Project config at $PROJECT_CONFIG is not writable"
			exit 1
		fi
	fi

	export PROJECT_CONFIG
}