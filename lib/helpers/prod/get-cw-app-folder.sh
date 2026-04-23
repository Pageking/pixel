#!/bin/bash
IFS=$'\n'
set -e

getAppFolder() {
	local SERVER_LIST APP_FOLDER_NAME
	SERVER_LIST=$(curl -s GET "https://api.cloudways.com/api/v2/server" \
	-H "Authorization: Bearer $1")
	APP_FOLDER_NAME=$(echo "$SERVER_LIST" | jq -r --arg SERVER_ID "$2" --arg APP_ID "$3" '.servers[] | select(.id == ($SERVER_ID)) | .apps[] | select(.id == $APP_ID) | .sys_user')
	export APP_FOLDER_NAME
}