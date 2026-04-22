source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-core-version.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/set-github-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"

set_core_version() {
	local LOCAL_VERSION GH_VERSION
	check_public_folder
	LOCAL_VERSION=$(get_core_version)

	if [[ -z "$LOCAL_VERSION" ]]; then
		echo "⚠️ No local core version found in wp-content/themes/pk-theme. Skipping."
		exit 1
	fi

	GH_VERSION=$(get_github_var "CORE_VERSION" 2>/dev/null || true)

	if [[ "$LOCAL_VERSION" == "$GH_VERSION" ]]; then
		echo "✅ CORE_VERSION is already in sync at '$LOCAL_VERSION'. Nothing to update."
		exit 0
	fi

	echo "⚠️  Version mismatch detected:"
	echo "   Local pk-theme : $LOCAL_VERSION"
	echo "   GitHub variable: ${GH_VERSION:-"(not set)"}"
	read -rp "Update GitHub variable CORE_VERSION to '$LOCAL_VERSION'? [y/N]: " confirm
	if [[ "$confirm" =~ ^[Yy]$ ]]; then
		set_github_var "CORE_VERSION" "$LOCAL_VERSION" || {
			echo "❌ Failed to set GitHub variable 'CORE_VERSION'."
			exit 1
		}
		echo "✅ CORE_VERSION updated to '$LOCAL_VERSION'."
	else
		echo "❌ Aborted. GitHub variable was not changed."
		exit 1
	fi
}