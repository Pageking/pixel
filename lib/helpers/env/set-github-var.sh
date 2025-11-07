#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/get-github-var.sh"

set_github_var() {
	if [[ $# -ne 2 ]]; then
        echo "❌ Usage: set_github_var <variable_name> <value>"
        exit 1
    fi

	local VAR_NAME VAR_VALUE RESULT CONFIG_PATH GITHUB_ORG PROJECT_NAME
	CONFIG_PATH="$HOME/.config/pixel/config.json"
	GITHUB_ORG=$(jq -r '.github.org' "$CONFIG_PATH")
	PROJECT_NAME=$(get_github_var "PROJECT_NAME")
	VAR_NAME="$1"
	VAR_VALUE="$2"
	
	RESULT=$(gh variable set "$VAR_NAME" --body "$VAR_VALUE" --repo "$GITHUB_ORG/$PROJECT_NAME")

	echo "$RESULT"
}