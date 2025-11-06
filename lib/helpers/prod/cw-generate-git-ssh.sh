#!/bin/bash
IFS=$'\n'
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../get-project-config.sh"

cwGenerateGitSSH() {
	local CONFIG_PATH GITHUB_ORG PROJECT_NAME SERVER_LABEL SERVER_ID APP_ID
	CONFIG_PATH="$HOME/.config/pixel/config.json"
	GITHUB_ORG=$(jq -r '.github.org' "$CONFIG_PATH")
	PROJECT_NAME=$(get_project_config .project_name)
	SERVER_LABEL=$(get_project_config .cloudways.server_label)
	SERVER_ID=$(get_project_config .cloudways.server_id)
	APP_ID=$(get_project_config .cloudways.app_id)

	local GENERATE_KEY=$(curl -s -X POST "https://api.cloudways.com/api/v1/git/generateKey" \
		-H "Authorization: Bearer $1" \
		-H "Content-Type: application/json" \
		-d "{
			\"server_id\": \"$SERVER_ID\",
			\"app_id\": \"$APP_ID\"
	}")

	local CW_GIT_SSH_KEY=$(curl -s -X GET "https://api.cloudways.com/api/v1/git/key" \
		-H "Authorization: Bearer $1" \
		-H "Content-Type: application/json" \
		-d "{
			\"server_id\": \"$SERVER_ID\",
			\"app_id\": \"$APP_ID\"
	}" | jq -r ".key")

	echo "$CW_GIT_SSH_KEY" > cw_git_key.pub

	gh repo deploy-key add ./cw_git_key.pub --repo "$GITHUB_ORG/$PROJECT_NAME" --title "Cloudways Production - $SERVER_LABEL"

	rm -f cw_git_key.pub
}