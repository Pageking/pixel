#!/bin/bash
IFS=$'\n'
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../check-public-folder.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../get-project-name.sh"
source "$(dirname "${BASH_SOURCE[0]}")/get-cw-bearer.sh"
check_public_folder
get_cw_bearer

matchProjectToProdApp() {
	local PROJECT_NAME
	PROJECT_NAME=$(get_project_name)

	# SELECT SERVER
	SERVERS=$(curl -s GET "https://api.cloudways.com/api/v1/server" \
  		-H "Authorization: Bearer $ACCESS_TOKEN")

	select server in $(echo "$SERVERS" | jq -r '.servers[].label'); 
	do
		echo "You selected server: $server"
		# Fetch server details
		SERVER_DETAILS=$(echo "$SERVERS" | jq -r --arg LABEL "$server" '.servers[] | select(.label == $LABEL)')
		SERVER_LABEL=$(echo "$SERVER_DETAILS" | jq -r '.label')
		SERVER_ID=$(echo "$SERVER_DETAILS" | jq -r '.id')
		SERVER_IP=$(echo "$SERVER_DETAILS" | jq -r '.public_ip')
		SERVER_USER=$(echo "$SERVER_DETAILS" | jq -r '.master_user')
		SERVER_PASS=$(echo "$SERVER_DETAILS" | jq -r '.master_password')

		 # Iterate through each app
        echo "$SERVER_DETAILS" | jq -c '.apps[]' | while read -r app; do

            APP_ID=$(echo "$app" | jq -r '.id')
            APP_LABEL=$(echo "$app" | jq -r '.label')
            APP_NAME=$(echo "$app" | jq -r '.sys_user')
			echo "$APP_LABEL:"
            
            # echo -e "\n=== $APP_LABEL (ID: $APP_ID) ==="
            
            # Get git deployment history for this app
            GIT_HISTORY=$(curl -s -X GET "https://api.cloudways.com/api/v1/git/history" \
                -H "Authorization: Bearer $ACCESS_TOKEN" \
				-H "Content-Type: application/json" \
				-d "{
					\"server_id\": \"$SERVER_ID\",
					\"app_id\": \"$APP_ID\"
				}")

            # Check if there's any deployment history
            if [[ $(echo "$GIT_HISTORY" | jq -r '.logs | length') -gt 0 ]]; then
                # echo "$GIT_HISTORY" | jq -r '.logs[] | "- Git URL: \(.git_url)"'
				GIT_URL=$(echo "$GIT_HISTORY" | jq -r '.logs[].git_url')
				REPO_NAME=$(echo "$GIT_URL" | sed -E 's/.*\/([^/]+)\.git$/\1/')

				echo "Checking: $REPO_NAME against $PROJECT_NAME"
				if [ "$REPO_NAME" = "$PROJECT_NAME" ]; then
                    echo "✅ Match found! This app is using the same repository."
					echo "$APP_NAME" > /tmp/matched_app_name
                else
                    echo "❌ No match for this app"
                fi
            else
                echo "No git deployment history found, skipping application."
            fi
		done
		break
	done
	if [ -f /tmp/matched_app_name ]; then
        MATCHED_APP_NAME=$(cat /tmp/matched_app_name)
        export MATCHED_APP_NAME
        rm /tmp/matched_app_name
    fi
}