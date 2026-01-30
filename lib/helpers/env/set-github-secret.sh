#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"

set_github_secret() {
	if [[ $# -ne 2 ]]; then
        echo "❌ Usage: set_github_var <variable_name> <value>"
        exit 1
    fi

	local SECRET_NAME SECRET_VALUE RESULT CONFIG_PATH GITHUB_ORG PROJECT_NAME
	CONFIG_PATH="$HOME/.config/pixel/config.json"
	GITHUB_ORG=$(jq -r '.github.org' "$CONFIG_PATH")
	PROJECT_NAME=$(get_github_var "PROJECT_NAME")
	SECRET_NAME="$1"
	SECRET_VALUE="$2"
	
	RESULT=$(gh secret set "$SECRET_NAME" --body "$SECRET_VALUE" --repo "$GITHUB_ORG/$PROJECT_NAME")

	echo "$RESULT"
}