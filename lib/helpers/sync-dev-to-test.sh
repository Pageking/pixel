#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/get-credentials.sh"
source "$(dirname "${BASH_SOURCE[0]}")/get-project-name.sh"

sync_dev_to_test() {
SERVER=$(jq -r '.servers.server_1.server' "$CONFIG_PATH")
DOMAIN=$(jq -r '.servers.server_1.domain' "$CONFIG_PATH")
IP=$(jq -r '.servers.server_1.ip' "$CONFIG_PATH")
PROJECT_NAME=$(get_project_name)
get_plesk_credentials "$PROJECT_NAME" "$DOMAIN" || { echo "Failed to get Plesk credentials"; return 1; }
rsync -avzh --progress --delete-after --update "wp-content/plugins" ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/wp-content/
echo "✅ Plugins synchronized"

if [[ -f "database.sql" ]]; then
	echo "🔄 Syncing database.sql to server..."
	scp database.sql ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/
	sshpass -p "${PLESK_PASS}" ssh -T "${PLESK_USER}@${IP}" <<EOF
	set -e
	bash -lc '
		cd httpdocs
		wp db import database.sql
		wp search-replace '${PROJECT_NAME}.local' '${PROJECT_NAME}.${DOMAIN}' --skip-columns=guid

		if [ -f wp-cli.yml ]; then
		echo \"wp-cli.yml already exists — skipping creation.\"
		else
		printf \"%s\n\" \"apache_modules:\" \"  - mod_rewrite\" > wp-cli.yml
		echo \"Created wp-cli.yml with apache_modules: mod_rewrite\"
		fi

		wp rewrite flush --hard
		rm database.sql
	'
EOF
	echo "✅ Database imported"
else
	echo "⚠️ No database.sql file found in the current folder. Skipping database import."
fi
}