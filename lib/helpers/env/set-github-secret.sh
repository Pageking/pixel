#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"

set_github_secret() {
	if [[ $# -ne 2 ]]; then
        echo "❌ Usage: set_github_var <variable_name> <value>"
        exit 1
    fi

	local SECRET_NAME SECRET_VALUE RESULT GITHUB_ORG PROJECT_NAME
	GITHUB_ORG=$(get_1pass_var "Servers" "GitHub" "org")
	PROJECT_NAME=$(get_github_var "PROJECT_NAME")
	SECRET_NAME="$1"
	SECRET_VALUE="$2"
	
	RESULT=$(gh secret set "$SECRET_NAME" --body "$SECRET_VALUE" --repo "$GITHUB_ORG/$PROJECT_NAME")

	echo "$RESULT"
}