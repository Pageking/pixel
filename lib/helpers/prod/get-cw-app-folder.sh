IFS=$'\n'

getAppFolder() {
	local SERVER_LIST=$(curl -s GET "https://api.cloudways.com/api/v1/server" \
	-H "Authorization: Bearer $1")

	export APP_FOLDER_NAME=$(echo "$SERVER_LIST" | jq -r --arg SERVER_ID $2 --arg APP_ID $3 '.servers[] | select(.id == ($SERVER_ID)) | .apps[] | select(.id == $APP_ID) | .sys_user')
}