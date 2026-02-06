#!/bin/bash
IFS=$'\n'
set -e

source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/set-github-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/set-github-secret.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/get-project-name.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/prod/get-cw-app-folder.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/prod/get-cw-bearer.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/prod/cw-generate-git-ssh.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/prod/cw-clone-project-repo.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/prod/cw-clone-main-repo.sh"
check_public_folder
get_cw_bearer

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
	break;
done

while true; do
	read -p "Cloudways application label: " CW_LABEL
	if [ -n "$CW_LABEL" ]; then
		break
	else
		echo "Application label cannot be empty. Please enter a value."
	fi
done

NEW_APP=$(curl -s POST "https://api.cloudways.com/api/v1/app" \
	-H "Authorization: Bearer $ACCESS_TOKEN" \
	-H "Content-Type: application/json" \
	-d "{
		\"server_id\": $SERVER_ID,
		\"application\": \"wordpress\",
		\"app_label\": \"$CW_LABEL\"
	}")

echo "$NEW_APP" | jq '.'

if [ "$(echo "$NEW_APP" | jq -r '.status')" != true ]; then
	echo "Failed to create new app"
	exit 1
fi

OP_ID=$(echo "$NEW_APP" | jq -r '.operation_id')
echo "Operation ID: $OP_ID"

while true; do
	APP_STATUS=$(curl -s GET "https://api.cloudways.com/api/v1/operation/$OP_ID" \
		-H "Authorization: Bearer $ACCESS_TOKEN")

	if [ "$(echo "$APP_STATUS" | jq -r '.operation.is_completed')" != "0" ]; then
		APP_ID=$(echo "$APP_STATUS" | jq -r '.operation.app_id')
		echo "✅ App created successfully"
		break
	fi
	echo "⏳ App creation in progress..."
	sleep 5
done

echo "✅ New app created successfully with ID: $APP_ID"

getAppFolder "$ACCESS_TOKEN" "$SERVER_ID" "$APP_ID"
echo "App folder name: $APP_FOLDER_NAME"

CLOUDWAYS_API_KEY=$(get_1pass_var "Servers" "Cloudways" "api_key")
set_github_secret "CLOUDWAYS_API_KEY" "$CLOUDWAYS_API_KEY"

set_github_var "CLOUDWAYS_APP_FOLDER" "$APP_FOLDER_NAME"
set_github_var "CLOUDWAYS_SERVER_IP" "$SERVER_IP"
set_github_var "CLOUDWAYS_SERVER_ID" "$SERVER_ID"
set_github_var "CLOUDWAYS_SERVER_USER" "$SERVER_USER"
set_github_var "CLOUDWAYS_SERVER_LABEL" "$SERVER_LABEL"
set_github_var "CLOUDWAYS_APP_ID" "$APP_ID"

cwGenerateGitSSH "$ACCESS_TOKEN"

cwCloneProjectRepo "$ACCESS_TOKEN"

cwCloneMainRepo "$SERVER_USER"

read -p "Do you also want to sync the plugins and database? [y/N]: " sync_to_prod
if [[ "$sync_to_prod" =~ ^[Yy]$ ]]; then
	source "${BREW_PREFIX}/libexec/lib/helpers/prod/sync-dev-to-prod.sh"
	sync_dev_to_prod
fi