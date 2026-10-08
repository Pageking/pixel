source "${BREW_PREFIX}/libexec/lib/helpers/test/get-credentials.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/get-project-name.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/check-ssh-connection.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/version-compare.sh"

# wp-cli must run as the site's own Plesk user (not the root/SERVER SSH alias) — Plesk
# does not recognize/permit `wp` commands over the root connection, matching the
# PLESK_USER/PLESK_PASS + sshpass pattern already used for `wp` calls in lib/init-test.sh.
#
# Exports PLESK_USER, PLESK_PASS (via get_plesk_credentials) and WPM_TEST_IP on success.
_wpmigrate_plugin_test_connect() {
	local PROJECT_NAME

	PROJECT_NAME=$(get_project_name)
	if [[ -z "$PROJECT_NAME" ]]; then
		echo "❌ Could not determine project name" >&2
		return 1
	fi

	WPM_TEST_IP=$(get_1pass_var "Servers" "PK1" "ip")
	export WPM_TEST_IP

	# Redirect these helpers' informational stdout to stderr: callers capture this
	# function's stdout via command substitution and must only see the plugin version.
	get_plesk_credentials "$PROJECT_NAME" "$(get_1pass_var "Servers" "PK1" "domain")" >&2 || { echo "❌ Failed to get Plesk credentials" >&2; return 1; }

	check_ssh_connection "${PLESK_USER}@${WPM_TEST_IP}" "$PLESK_PASS" 5 10 >&2
}

get_remote_plugin_version_test() {
	local slug="${1:?get_remote_plugin_version_test: plugin slug is required}"
	local RESULT

	_wpmigrate_plugin_test_connect || return 1

	RESULT=$(sshpass -p "${PLESK_PASS}" ssh -T -o IgnoreUnknown=UseKeychain -o PreferredAuthentications=password -o PubkeyAuthentication=no -o IdentitiesOnly=yes "${PLESK_USER}@${WPM_TEST_IP}" <<EOF
	set -e
	bash -lc '
		cd httpdocs
		wp plugin get ${slug} --field=version
	'
EOF
	) || { echo "❌ Could not read remote version for plugin '$slug' on test" >&2; return 1; }

	RESULT=$(extract_version_string "$RESULT")
	if [[ -z "$RESULT" ]]; then
		echo "❌ Could not parse remote version for plugin '$slug' on test" >&2
		return 1
	fi

	echo "$RESULT"
}

update_remote_plugin_test() {
	local slug="${1:?update_remote_plugin_test: plugin slug is required}"

	_wpmigrate_plugin_test_connect || return 1

	sshpass -p "${PLESK_PASS}" ssh -T -o IgnoreUnknown=UseKeychain -o PreferredAuthentications=password -o PubkeyAuthentication=no -o IdentitiesOnly=yes "${PLESK_USER}@${WPM_TEST_IP}" <<EOF
	set -e
	bash -lc '
		cd httpdocs
		wp plugin update ${slug}
	'
EOF
}
