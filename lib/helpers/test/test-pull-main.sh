#!/bin/bash
IFS=$'\n'
set -e

source "${BREW_PREFIX}/libexec/lib/helpers/test/get-credentials.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/get-project-name.sh"

test_pull_main() {	
	# --- Load vars safely ---
	local SERVER DOMAIN REPO PROJECT_NAME THEME_DIR
	SERVER=$(get_1pass_var "Servers" "PK1" "server")
	DOMAIN=$(get_1pass_var "Servers" "PK1" "domain")
	REPO=$(get_1pass_var "Servers" "GitHub" "main_repo")

	# --- Validate config ---
	for var in SERVER DOMAIN REPO; do
		if [[ -z "${!var}" || "${!var}" == "null" ]]; then
			echo "❌ Config error: $var is empty"
			exit 1
		fi
	done

	# --- Project name ---
	PROJECT_NAME=$(get_project_name)
	if [[ -z "$PROJECT_NAME" ]]; then
		echo "❌ Could not determine project name"
		exit 1
	fi

	THEME_DIR="/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/wp-content/themes/${REPO}"

	# --- Credentials ---
	get_plesk_credentials "$PROJECT_NAME" "$DOMAIN" || { echo "Failed to get Plesk credentials"; return 1; }

	ssh -T -o IgnoreUnknown=UseKeychain "${SERVER}" <<EOF
	set -e
	bash -lc '
		cd /
		cd ${THEME_DIR}

		git config --global --add safe.directory ${THEME_DIR}
		git fetch origin main
		git pull origin main
	'
EOF
	
}