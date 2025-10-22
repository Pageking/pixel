#!/bin/bash
IFS=$'\n'
set -e

cwCloneMainRepo() {
	local CONFIG_PATH="$HOME/.config/pixel/config.json"
	local GIT_REPO="git@github.com:$(jq -r '.github.org' "$CONFIG_PATH")/pk-theme.git"
	sshpass -p $3 ssh -o IgnoreUnknown=UseKeychain $2@$1 bash <<EOF
	set -e
	cd applications/$4/public_html/wp-content/themes/
	git clone $GIT_REPO
EOF

	echo "✅ Main theme clone succesful"
}