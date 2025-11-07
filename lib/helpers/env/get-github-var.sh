#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

get_github_var() {
	if [[ $# -ne 1 ]]; then
        echo "❌ Usage: get_github_var <variable_name>"
        exit 1
    fi

	local VAR_NAME RESULT
	VAR_NAME="$1"
	
	cd "wp-content/themes/pk-theme-child" || exit 1
	RESULT=$(gh variable get "$VAR_NAME")

	echo "$RESULT"
}