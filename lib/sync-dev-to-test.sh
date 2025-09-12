#!/bin/bash
sync_dev_to_test() {
SERVER=$(jq -r '.servers.server_1.server' "$CONFIG_PATH")
DOMAIN=$(jq -r '.servers.server_1.domain' "$CONFIG_PATH")
IP=$(jq -r '.servers.server_1.ip' "$CONFIG_PATH")
PROJECT_NAME=$1
PLESK_USER=$2
PLESK_PASS=$3
rsync -avzh --progress --delete-after --update "wp-content/plugins" ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/wp-content/
echo "✅ Plugins synchronized"

if [[ -f "database.sql" ]]; then
	echo "🔄 Syncing database.sql to server..."
	scp database.sql ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/
	sshpass -p "${PLESK_PASS}" ssh -o StrictHostKeyChecking=no "${PLESK_USER}.${IP}" bash <<EOF
	# Exit on first failure
	set -e

	cd httpdocs

	wp db import database.sql
	wp search-replace '${PROJECT_NAME}.local' '${PROJECT_NAME}.${DOMAIN}' --skip-columns=guid
EOF
	echo "✅ Database imported"
else
	echo "⚠️ No database.sql file found in the current folder. Skipping database import."
fi
}