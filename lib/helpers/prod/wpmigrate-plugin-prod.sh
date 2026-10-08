source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"

get_remote_plugin_version_prod() {
	local slug="${1:?get_remote_plugin_version_prod: plugin slug is required}"
	local SERVER_USER SERVER_IP APP_FOLDER RESULT

	SERVER_IP=$(get_github_var "CLOUDWAYS_SERVER_IP")
	SERVER_USER=$(get_github_var "CLOUDWAYS_SERVER_USER")
	APP_FOLDER=$(get_github_var "CLOUDWAYS_APP_FOLDER")

	if [[ -z "$SERVER_IP" || -z "$SERVER_USER" || -z "$APP_FOLDER" ]]; then
		echo "❌ Missing required GitHub variables. Please ensure CLOUDWAYS_SERVER_IP, CLOUDWAYS_SERVER_USER, and CLOUDWAYS_APP_FOLDER are set." >&2
		return 1
	fi

	RESULT=$(ssh -o IgnoreUnknown=UseKeychain "$SERVER_USER@$SERVER_IP" bash <<EOF
	set -e
	cd applications/$APP_FOLDER/public_html || exit 1
	wp plugin get $slug --field=version
EOF
	) || { echo "❌ Could not read remote version for plugin '$slug' on production" >&2; return 1; }

	echo "$RESULT"
}

update_remote_plugin_prod() {
	local slug="${1:?update_remote_plugin_prod: plugin slug is required}"
	local SERVER_USER SERVER_IP APP_FOLDER

	SERVER_IP=$(get_github_var "CLOUDWAYS_SERVER_IP")
	SERVER_USER=$(get_github_var "CLOUDWAYS_SERVER_USER")
	APP_FOLDER=$(get_github_var "CLOUDWAYS_APP_FOLDER")

	if [[ -z "$SERVER_IP" || -z "$SERVER_USER" || -z "$APP_FOLDER" ]]; then
		echo "❌ Missing required GitHub variables. Please ensure CLOUDWAYS_SERVER_IP, CLOUDWAYS_SERVER_USER, and CLOUDWAYS_APP_FOLDER are set." >&2
		return 1
	fi

	ssh -o IgnoreUnknown=UseKeychain "$SERVER_USER@$SERVER_IP" bash <<EOF
	set -e
	cd applications/$APP_FOLDER/public_html || exit 1
	wp plugin update $slug
EOF
}
