source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-core-version.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/set-github-var.sh"

set_core_version() {
	local CORE_VERSION
	check_public_folder
	CORE_VERSION=$(get_core_version)

	if [[ -n "$CORE_VERSION" ]]; then
		echo "📌 Setting core version to '$CORE_VERSION' in GitHub variable..."
		set_github_var "CORE_VERSION" "$CORE_VERSION" || {
			echo "❌ Failed to set GitHub variable 'CORE_VERSION'."
			exit 1
		}
		echo "✅ Core version '$CORE_VERSION' set successfully."
	else
		echo "⚠️ No core version found. Skipping setting GitHub variable."
		exit 1
	fi
}