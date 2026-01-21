#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/get-credentials.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../get-project-name.sh"

sync_test_to_dev() {
	local CONFIG_PATH="$HOME/.config/pixel/config.json"
	
	# --- Load config safely ---
	local SERVER DOMAIN IP
	SERVER=$(jq -r '.servers.server_1.server' "$CONFIG_PATH")
	DOMAIN=$(jq -r '.servers.server_1.domain' "$CONFIG_PATH")
	IP=$(jq -r '.servers.server_1.ip' "$CONFIG_PATH")

	# --- Validate config ---
	for var in SERVER DOMAIN IP; do
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

	# --- Credentials ---
	get_plesk_credentials "$PROJECT_NAME" "$DOMAIN" || { echo "Failed to get Plesk credentials"; return 1; }

	read -p "Sync the plugins? [y/N]: " sync_plugins_from_test
	if [[ "$sync_plugins_from_test" =~ ^[Yy]$ ]]; then
		rsync -avzhq --delete-after --update ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/wp-content/plugins/ "wp-content/plugins/"
		echo "✅ Plugins synchronized"
	fi

	read -p "Sync the uploads folder (media files)? [y/N]: " sync_media_from_test
	if [[ "$sync_media_from_test" =~ ^[Yy]$ ]]; then
		rsync -avzhq --delete-after --update ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/wp-content/uploads/ "wp-content/uploads/"
		echo "✅ Uploads synchronized"
	fi

	read -p "Sync the database? [y/N]: " sync_db_to_test
	if [[ "$sync_db_to_test" =~ ^[Yy]$ ]]; then
	sshpass -p "${PLESK_PASS}" ssh -T -o IgnoreUnknown=UseKeychain "${PLESK_USER}@${IP}" <<EOF
	set -e
	bash -lc '
		cd httpdocs
		wp db export database.sql
		exit
	'
EOF
		rsync -avzhq --update ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/database.sql ./database.sql

	sshpass -p "${PLESK_PASS}" ssh -T -o IgnoreUnknown=UseKeychain "${PLESK_USER}@${IP}" <<EOF
	set -e
	bash -lc '
		cd httpdocs
		rm database.sql
		exit
	'
EOF

		wp db import database.sql
		wp search-replace "${PROJECT_NAME}.${DOMAIN}" "${PROJECT_NAME}.local" --all-tables
		rm database.sql
		echo "✅ Database synchronized"
	fi
}