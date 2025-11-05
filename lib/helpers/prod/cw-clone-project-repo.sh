#!/bin/bash
IFS=$'\n'
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../get-project-name.sh"

cwCloneProjectRepo() {
	local project_name=$(get_project_name)
	CW_CLONE_THEME=$(curl -s -X POST "https://api.cloudways.com/api/v1/git/clone" \
	-H "Authorization: Bearer $1" \
	-H "Content-Type: application/json" \
	-d "{
		\"server_id\": \"$2\",
		\"app_id\": \"$3\",
		\"git_url\": \"git@github.com:Pageking/$project_name.git\",
		\"branch_name\": \"production\",
		\"deploy_path\": \"wp-content/themes/pk-theme-child/\"
	}")
}