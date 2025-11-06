#!/bin/bash
IFS=$'\n'
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../get-project-config.sh"

cwCloneMainRepo() {
	if [[ $# -ne 1 ]]; then
        echo "❌ Usage: cwCloneMainRepo <server_user>"
        exit 1
    fi
	local CONFIG_PATH GIT_REPO SERVER_ID APP_FOLDER
	CONFIG_PATH="$HOME/.config/pixel/config.json"
	GIT_REPO="git@github.com:$(jq -r '.github.org' "$CONFIG_PATH")/pk-theme.git"

	SERVER_IP=$(get_project_config .cloudways.server_ip)
	APP_FOLDER=$(get_project_config .cloudways.app_folder)

	ssh -o IgnoreUnknown=UseKeychain $1@$SERVER_IP bash <<EOF
	set -e
	cd applications/$APP_FOLDER/public_html/wp-content/themes/
	git clone $GIT_REPO
EOF

	echo "✅ Main theme clone successful"
}