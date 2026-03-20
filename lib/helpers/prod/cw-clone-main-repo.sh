#!/bin/bash
IFS=$'\n'
set -e

source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"

cwCloneMainRepo() {
	if [[ $# -ne 1 ]]; then
        echo "❌ Usage: cwCloneMainRepo <server_user>"
        exit 1
    fi
	local GIT_REPO SERVER_USER APP_FOLDER CORE_VERSION SERVER_IP
	GIT_REPO="git@github.com:$(get_1pass_var "Servers" "GitHub" "org")/pk-theme.git"

	SERVER_IP=$(get_github_var "CLOUDWAYS_SERVER_IP")
	SERVER_USER=$(get_github_var "CLOUDWAYS_SERVER_USER")
	APP_FOLDER=$(get_github_var "CLOUDWAYS_APP_FOLDER")
	CORE_VERSION=$(get_github_var "CORE_VERSION")

	if [[ -z "$SERVER_IP" || -z "$SERVER_USER" || -z "$APP_FOLDER" || -z "$CORE_VERSION" ]]; then
		echo "❌ Missing required GitHub variables. Please ensure CLOUDWAYS_SERVER_IP, CLOUDWAYS_SERVER_USER, CLOUDWAYS_APP_FOLDER, and CORE_VERSION are set."
		exit 1
	fi

	ssh -o IgnoreUnknown=UseKeychain $SERVER_USER@$SERVER_IP bash <<EOF
	set -e
	cd applications/$APP_FOLDER/public_html/wp-content/themes/
	git clone -b $CORE_VERSION $GIT_REPO
EOF

	echo "✅ Main theme clone successful"
}