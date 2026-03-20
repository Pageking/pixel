source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"

prod_set_core_version() {
	local SERVER_USER APP_FOLDER SERVER_IP CORE_VERSION NEW_VERSION

	SERVER_IP=$(get_github_var "CLOUDWAYS_SERVER_IP")
	SERVER_USER=$(get_github_var "CLOUDWAYS_SERVER_USER")
	APP_FOLDER=$(get_github_var "CLOUDWAYS_APP_FOLDER")
	CORE_VERSION=$(get_github_var "CORE_VERSION")
	NEW_VERSION="$1"

	if [[ -z "$SERVER_IP" || -z "$SERVER_USER" || -z "$APP_FOLDER" ]]; then
		echo "❌ Missing required GitHub variables. Please ensure CLOUDWAYS_SERVER_IP, CLOUDWAYS_SERVER_USER, and CLOUDWAYS_APP_FOLDER are set."
		exit 1
	fi

	if [[ -z "$CORE_VERSION" ]]; then
		echo "⚠️ CORE_VERSION is not set. Defaulting to 'main' branch."
		CORE_VERSION="main"
	fi

	if [[ -z "$NEW_VERSION" ]]; then
		echo "❌ New core version is not provided."
		exit 1
	fi

	echo "You are currently on core version '$CORE_VERSION'. You want to switch to '$NEW_VERSION' on production."
	read -p "⚠️ Are you sure you want to set the core version to '$NEW_VERSION' on production? ⚠️ [y/N]: " confirm_set_core_version
	if [[ ! "$confirm_set_core_version" =~ ^[Yy]$ ]]; then
		echo "❌ Aborting setting core version."
		exit 1
	fi

	ssh -o IgnoreUnknown=UseKeychain $SERVER_USER@$SERVER_IP bash <<EOF
	set -e
	cd applications/$APP_FOLDER/public_html/wp-content/themes/pk-theme || exit 1
	git fetch --all
	git checkout $CORE_VERSION
EOF

	echo "✅ Main theme clone successful"
}