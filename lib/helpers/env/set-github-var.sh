#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"

set_github_var() {
	if [[ $# -ne 2 ]]; then
        echo "❌ Usage: set_github_var <variable_name> <value>"
        exit 1
    fi

	local VAR_NAME VAR_VALUE GITHUB_ORG PROJECT_NAME
	GITHUB_ORG=$(get_1pass_var "Servers" "GitHub" "org")
	PROJECT_NAME=$(get_github_var "PROJECT_NAME")
	VAR_NAME="$1"
	VAR_VALUE="$2"
	
	run_step "Save GitHub variable '$VAR_NAME'" gh variable set "$VAR_NAME" --body "$VAR_VALUE" --repo "$GITHUB_ORG/$PROJECT_NAME"
}