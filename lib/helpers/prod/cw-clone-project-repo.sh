#!/bin/bash
IFS=$'\n'
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../env/get-github-var.sh"

cwCloneProjectRepo() {
	if [[ $# -ne 1 ]]; then
        echo "❌ Usage: cwCloneProjectRepo <access_token>"
        exit 1
    fi
	local PROJECT_NAME SERVER_ID APP_ID
	PROJECT_NAME=$(get_github_var "PROJECT_NAME")
	SERVER_ID=$(get_github_var "CLOUDWAYS_SERVER_ID")
	APP_ID=$(get_github_var "CLOUDWAYS_APP_ID")

	CW_CLONE_THEME=$(curl -s -X POST "https://api.cloudways.com/api/v1/git/clone" \
	-H "Authorization: Bearer $1" \
	-H "Content-Type: application/json" \
	-d "{
		\"server_id\": \"$SERVER_ID\",
		\"app_id\": \"$APP_ID\",
		\"git_url\": \"git@github.com:Pageking/$PROJECT_NAME.git\",
		\"branch_name\": \"production\",
		\"deploy_path\": \"wp-content/themes/pk-theme-child/\"
	}")
}