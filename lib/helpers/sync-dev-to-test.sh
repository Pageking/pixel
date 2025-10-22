#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/get-credentials.sh"
source "$(dirname "${BASH_SOURCE[0]}")/get-project-name.sh"

sync_dev_to_test() {
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

	read -p "Sync the plugins? [y/N]: " sync_plugins_to_test
	if [[ "$sync_plugins_to_test" =~ ^[Yy]$ ]]; then
		rsync -avzh --progress --delete-after --update "wp-content/plugins" ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/wp-content/
		echo "✅ Plugins synchronized"
	fi

	read -p "Sync the uploads folder (media files)? [y/N]: " sync_media_to_test
	if [[ "$sync_media_to_test" =~ ^[Yy]$ ]]; then
		rsync -avzh --progress --delete-after --update "wp-content/uploads" ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/wp-content/
		echo "✅ Uploads synchronized"
	fi

	read -p "Sync the database? [y/N]: " sync_db_to_test
	if [[ -f "database.sql" ]]; then
		echo "🔄 Syncing database.sql to server..."
		scp database.sql ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/
	fi
	if [[ -f "wp-cli.yml" ]]; then
		echo "🔄 Syncing wp-cli.yml to server..."
		scp wp-cli.yml ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/
	fi
	if [[ -f "database.sql" && -f "wp-cli.yml" && "$sync_db_to_test" =~ ^[Yy]$ ]]; then
	sshpass -p "${PLESK_PASS}" ssh -T -o IgnoreUnknown=UseKeychain "${PLESK_USER}@${IP}" <<EOF
	set -e
	bash -lc '
		cd httpdocs
		wp db import database.sql
		wp search-replace '${PROJECT_NAME}.local' '${PROJECT_NAME}.${DOMAIN}'

		wp rewrite flush --hard
		wp cache flush

		rm database.sql
	'
EOF
		echo "✅ Database imported"
	else
		echo "⚠️ No database.sql file found in the current folder. Skipping database import."
	fi
}