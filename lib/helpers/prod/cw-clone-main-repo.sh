IFS=$'\n'

source "$(dirname "${BASH_SOURCE[0]}")/../env/get-github-var.sh"

cwCloneMainRepo() {
	if [[ $# -ne 1 ]]; then
        echo "❌ Usage: cwCloneMainRepo <server_user>"
        exit 1
    fi
	local CONFIG_PATH GIT_REPO SERVER_ID SERVER_USER APP_FOLDER
	CONFIG_PATH="$HOME/.config/pixel/config.json"
	GIT_REPO="git@github.com:$(jq -r '.github.org' "$CONFIG_PATH")/pk-theme.git"

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