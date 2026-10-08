source "${BREW_PREFIX}/libexec/lib/helpers/test/get-credentials.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/get-project-name.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"

get_remote_plugin_version_test() {
	local slug="${1:?get_remote_plugin_version_test: plugin slug is required}"
	local SERVER DOMAIN PROJECT_NAME SITE_DIR RESULT

	SERVER=$(get_1pass_var "Servers" "PK1" "server")
	DOMAIN=$(get_1pass_var "Servers" "PK1" "domain")
	PROJECT_NAME=$(get_project_name)

	if [[ -z "$PROJECT_NAME" ]]; then
		echo "❌ Could not determine project name" >&2
		return 1
	fi

	SITE_DIR="/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs"

	get_plesk_credentials "$PROJECT_NAME" "$DOMAIN" || { echo "❌ Failed to get Plesk credentials" >&2; return 1; }

	RESULT=$(ssh -T -o IgnoreUnknown=UseKeychain "${SERVER}" <<EOF
	set -e
	bash -lc '
		cd ${SITE_DIR}
		wp plugin get ${slug} --field=version
	'
EOF
	) || { echo "❌ Could not read remote version for plugin '$slug' on test" >&2; return 1; }

	echo "$RESULT"
}

update_remote_plugin_test() {
	local slug="${1:?update_remote_plugin_test: plugin slug is required}"
	local SERVER DOMAIN PROJECT_NAME SITE_DIR

	SERVER=$(get_1pass_var "Servers" "PK1" "server")
	DOMAIN=$(get_1pass_var "Servers" "PK1" "domain")
	PROJECT_NAME=$(get_project_name)

	if [[ -z "$PROJECT_NAME" ]]; then
		echo "❌ Could not determine project name" >&2
		return 1
	fi

	SITE_DIR="/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs"

	get_plesk_credentials "$PROJECT_NAME" "$DOMAIN" || { echo "❌ Failed to get Plesk credentials" >&2; return 1; }

	ssh -T -o IgnoreUnknown=UseKeychain "${SERVER}" <<EOF
	set -e
	bash -lc '
		cd ${SITE_DIR}
		wp plugin update ${slug}
	'
EOF
}
