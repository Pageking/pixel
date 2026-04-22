source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"

clone_project() {
	check_public_folder

	# Ensure themes don't already exist
	if [[ -d "wp-content/themes/pk-theme" ]]; then
		echo "❌ Error: 'wp-content/themes/pk-theme' already exists. Remove it before running this command."
		exit 1
	fi
	if [[ -d "wp-content/themes/pk-theme-child" ]]; then
		echo "❌ Error: 'wp-content/themes/pk-theme-child' already exists. Remove it before running this command."
		exit 1
	fi

	# Check wp-migrate-db-pro is installed (required for database syncing)
	if [[ ! -d "wp-content/plugins/wp-migrate-db-pro" ]]; then
		echo "❌ Error: Plugin 'wp-migrate-db-pro' is not installed."
		echo "📦 Please install the WP Migrate DB Pro plugin before running this command."
		exit 1
	fi

	local GITHUB_ORG MAIN_REPO
	GITHUB_ORG=$(get_1pass_var "Servers" "GitHub" "org")
	MAIN_REPO=$(get_1pass_var "Servers" "GitHub" "main_repo")

	local SELECTED_REPO
	if [[ -n "${1:-}" ]]; then
		# Project name provided directly — skip the interactive menu
		SELECTED_REPO="$1"
		if ! gh repo view "$GITHUB_ORG/$SELECTED_REPO" --json name &>/dev/null; then
			echo "❌ Error: Repository '$GITHUB_ORG/$SELECTED_REPO' does not exist or is not accessible."
			exit 1
		fi
		echo "📌 Using project: '$SELECTED_REPO'"
	else
		# Fetch all repos for the org and present a select menu
		echo "🔍 Fetching repositories..."
		local REPO_NAMES
		REPO_NAMES=$(gh search repos --owner "$GITHUB_ORG" -L 100 --json name | jq -r '.[].name' | sort)

		if [[ -z "$REPO_NAMES" ]]; then
			echo "❌ No repositories found for '$GITHUB_ORG'."
			exit 1
		fi

		select SELECTED_REPO in $REPO_NAMES; do
			if [[ -n "$SELECTED_REPO" ]]; then
				echo "📌 Selected project: '$SELECTED_REPO'"
				break
			fi
			echo "⚠️  Invalid selection. Please enter a number from the list."
		done
	fi

	# Clone child theme first — it holds the GitHub variables needed below
	echo "📦 Cloning '$SELECTED_REPO' into wp-content/themes/pk-theme-child..."
	git clone "https://github.com/$GITHUB_ORG/$SELECTED_REPO.git" "wp-content/themes/pk-theme-child" &>/dev/null;
	echo "✅ Cloned child theme '$SELECTED_REPO'"

	# Read CORE_VERSION from the project repo's GitHub variables
	echo "🔍 Reading CORE_VERSION from GitHub variables..."
	local CORE_VERSION
	CORE_VERSION=$(get_github_var "CORE_VERSION")

	if [[ -z "$CORE_VERSION" ]]; then
		echo "❌ Error: CORE_VERSION is not set in the GitHub variables for '$SELECTED_REPO'."
		echo "💡 You can set it using: pixel set-core-version"
		exit 1
	fi

	# Clone pk-theme at the pinned version with all submodules
	echo "📦 Cloning '$MAIN_REPO' at version '$CORE_VERSION' (with submodules)..."
	git clone -b "$CORE_VERSION" --recurse-submodules \
		"https://github.com/$GITHUB_ORG/$MAIN_REPO.git" \
		"wp-content/themes/pk-theme" &>/dev/null;
	echo "✅ Cloned pk-theme at version '$CORE_VERSION'"

	# Offer an initial sync if connection strings are available
	local TEST_CONN PROD_CONN
	TEST_CONN=$(get_github_var "WPM_TEST_CONNECTION_STRING" 2>/dev/null || true)
	PROD_CONN=$(get_github_var "WPM_PROD_CONNECTION_STRING" 2>/dev/null || true)

	local sync_options=()
	[[ -n "$TEST_CONN" ]]  && sync_options+=("Test environment")
	[[ -n "$PROD_CONN" ]]  && sync_options+=("Production environment")
	sync_options+=("Skip")

	if [[ ${#sync_options[@]} -eq 1 ]]; then
		# Only "Skip" — no connection strings available
		echo "ℹ️  No sync connection strings found. Skipping initial sync."
	else
		echo ""
		echo "🔃 Do you want to do an initial sync from a remote server?"
		local SYNC_CHOICE
		select SYNC_CHOICE in "${sync_options[@]}"; do
			case "$SYNC_CHOICE" in
				"Test environment")
					source "${BREW_PREFIX}/libexec/lib/helpers/test/sync-test-to-dev.sh"
					sync_test_to_dev
					break
					;;
				"Production environment")
					source "${BREW_PREFIX}/libexec/lib/helpers/prod/sync-prod-to-dev.sh"
					sync_prod_to_dev
					break
					;;
				"Skip")
					echo "⏭️  Skipping initial sync."
					break
					;;
				*)
					echo "⚠️  Invalid selection. Please enter a number from the list."
					;;
			esac
		done
	fi

	echo ""
	echo "✅ Project '$SELECTED_REPO' is ready!"
	echo "   📁 wp-content/themes/pk-theme        → @ $CORE_VERSION"
	echo "   📁 wp-content/themes/pk-theme-child   → $SELECTED_REPO"
}
