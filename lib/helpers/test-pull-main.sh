#!/bin/bash
IFS=$'\n'
set -e

source "$(dirname "${BASH_SOURCE[0]}")/get-credentials.sh"
source "$(dirname "${BASH_SOURCE[0]}")/get-project-name.sh"

test_pull_main() {
  	local CONFIG_PATH="$HOME/.config/pixel/config.json"
	
	# --- Load config safely ---
	local SERVER DOMAIN IP REPO
	SERVER=$(jq -r '.servers.server_1.server' "$CONFIG_PATH")
	DOMAIN=$(jq -r '.servers.server_1.domain' "$CONFIG_PATH")
	IP=$(jq -r '.servers.server_1.ip' "$CONFIG_PATH")
	REPO=$(jq -r '.github.main_repo' "$CONFIG_PATH")

	# --- Validate config ---
	for var in SERVER DOMAIN IP REPO; do
		if [[ -z "${!var}" || "${!var}" == "null" ]]; then
			echo "❌ Config error: $var is empty"
			exit 1
		fi
	done

	# --- Project name ---
	local PROJECT_NAME
	PROJECT_NAME=$(get_project_name)
	if [[ -z "$PROJECT_NAME" ]]; then
		echo "❌ Could not determine project name"
		exit 1
	fi

	local THEME_DIR
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