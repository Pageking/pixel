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
	local GIT_REPO SERVER_USER APP_FOLDER
	GIT_REPO="git@github.com:$(get_1pass_var "Servers" "GitHub" "org")/pk-theme.git"

	SERVER_IP=$(get_github_var "CLOUDWAYS_SERVER_IP")
	SERVER_USER=$(get_github_var "CLOUDWAYS_SERVER_USER")
	APP_FOLDER=$(get_github_var "CLOUDWAYS_APP_FOLDER")

	ssh -o IgnoreUnknown=UseKeychain $SERVER_USER@$SERVER_IP bash <<EOF
	set -e
	cd applications/$APP_FOLDER/public_html/wp-content/themes/
	git clone $GIT_REPO
EOF

	echo "✅ Main theme clone successful"
}