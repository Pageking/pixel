#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/get-project-name.sh"
source "$(dirname "${BASH_SOURCE[0]}")/check-public-folder.sh"
check_public_folder

sync_dev_to_prod() {
	source "$(dirname "${BASH_SOURCE[0]}")/prod/match-project-to-prod-app.sh"
	# Exports variable: MATCHED_APP_NAME
	matchProjectToProdApp

	if [ -z "${MATCHED_APP_NAME:-}" ]; then
		echo "❌ No matching production app found for the current project."
		exit 1
	fi

	if [[ -f "database.sql" ]]; then
		echo "🔄 Syncing database.sql to server..."
		scp database.sql $SERVER_USER@$SERVER_IP:/home/master/applications/$MATCHED_APP_NAME/public_html/
		
		ssh $SERVER_USER@$SERVER_IP <<EOF
	set -e
	bash -lc '
	cd /home/master/applications/$MATCHED_APP_NAME/public_html/
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

	# if [ -n "${1:-}" ] && [ -n "${2:-}" ] && [ -n "${3:-}" ]; then
	# 	rsync -avzh --progress --delete-after --update "wp-content/plugins" "${2}@${1}:/home/master/applications/${3}/public_html/wp-content/"
	# 	exit 0
	# fi
	# rsync -avzh --progress --delete-after --update "wp-content/plugins" "$SERVER_USER@$SERVER_IP:/home/master/applications/$MATCHED_APP_NAME/public_html/wp-content/"
}