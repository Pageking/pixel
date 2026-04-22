source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-core-version.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/set-github-var.sh"

prod_set_core_version() {
	local SERVER_USER APP_FOLDER SERVER_IP LOCAL_VERSION CORE_VERSION

	SERVER_IP=$(get_github_var "CLOUDWAYS_SERVER_IP")
	SERVER_USER=$(get_github_var "CLOUDWAYS_SERVER_USER")
	APP_FOLDER=$(get_github_var "CLOUDWAYS_APP_FOLDER")

	if [[ -z "$SERVER_IP" || -z "$SERVER_USER" || -z "$APP_FOLDER" ]]; then
		echo "❌ Missing required GitHub variables. Please ensure CLOUDWAYS_SERVER_IP, CLOUDWAYS_SERVER_USER, and CLOUDWAYS_APP_FOLDER are set."
		exit 1
	fi

	# Compare local pk-theme version with GitHub variable
	LOCAL_VERSION=$(get_core_version)
	CORE_VERSION=$(get_github_var "CORE_VERSION" 2>/dev/null || true)

	if [[ -z "$CORE_VERSION" ]]; then
		echo "❌ CORE_VERSION GitHub variable is not set. Run 'pixel set-core-version' first."
		exit 1
	fi

	if [[ -n "$LOCAL_VERSION" && "$LOCAL_VERSION" != "$CORE_VERSION" ]]; then
		echo "⚠️  Version mismatch detected:"
		echo "   Local pk-theme : $LOCAL_VERSION"
		echo "   GitHub variable: $CORE_VERSION"
		read -rp "Update GitHub variable CORE_VERSION to '$LOCAL_VERSION' before continuing? [y/N]: " update_gh
		if [[ "$update_gh" =~ ^[Yy]$ ]]; then
			set_github_var "CORE_VERSION" "$LOCAL_VERSION"
			CORE_VERSION="$LOCAL_VERSION"
			echo "✅ CORE_VERSION updated to '$CORE_VERSION'."
		fi
	fi

	echo "You are about to set the core version to '$CORE_VERSION' on production."
	read -p "⚠️ Are you sure you want to set the core version to '$CORE_VERSION' on production? ⚠️ [y/N]: " confirm_set_core_version
	if [[ ! "$confirm_set_core_version" =~ ^[Yy]$ ]]; then
		echo "❌ Aborting setting core version."
		exit 1
	fi

	ssh -o IgnoreUnknown=UseKeychain $SERVER_USER@$SERVER_IP bash <<EOF
	set -e
	cd applications/$APP_FOLDER/public_html/wp-content/themes/pk-theme || exit 1
	git fetch --all
	git checkout $CORE_VERSION
	git submodule update --init
EOF

	echo "✅ Core version set to '$CORE_VERSION' on production."
}