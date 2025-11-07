#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../env/get-github-var.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../check-public-folder.sh"
check_public_folder

sync_dev_to_prod() {
	local APP_FOLDER SERVER_IP SERVER_USER
	SERVER_IP=$(get_github_var "CLOUDWAYS_SERVER_IP")
	SERVER_USER=$(get_github_var "CLOUDWAYS_SERVER_USER")
	APP_FOLDER=$(get_github_var "CLOUDWAYS_APP_FOLDER")

	if [[ -f "database.sql" ]]; then
		echo "🔄 Syncing database.sql to server..."
		scp database.sql $SERVER_USER@$SERVER_IP:/home/master/applications/$APP_FOLDER/public_html/
		
		ssh $SERVER_USER@$SERVER_IP <<EOF
			set -e
			bash -lc '
			cd /home/master/applications/$APP_FOLDER/public_html/
			if [ -f database.sql ]; then
				wp db import database.sql
				rm database.sql
				echo "✅ Database imported successfully."
			else
				echo "❌ database.sql file not found on server."
				exit 1
			fi
			'
EOF
		# Remove local copy after successful sync
		rm database.sql
	fi

	rsync -avzh --progress --delete-after --update "wp-content/plugins" "${SERVER_USER}@${SERVER_IP}:/home/master/applications/${APP_FOLDER}/public_html/wp-content/"
	exit 0
}