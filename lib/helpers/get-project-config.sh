#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/check-public-folder.sh"
source "$(dirname "${BASH_SOURCE[0]}")/check-project-config.sh"
check_public_folder
check_project_config

get_project_config() {
	if [[ $# -ne 1 ]]; then
        echo "❌ Usage: get_project_config <json_path>"
        exit 1
    fi

	local PROJECT_CONFIG PARAMETER RESULT
	PROJECT_CONFIG="$(pwd)/wp-content/themes/pk-theme-child/pixel.json"
	PARAMETER="$1"

	RESULT=$(jq -r "$PARAMETER" "$PROJECT_CONFIG")
	if [[ "$RESULT" == "null" ]]; then
		echo "❌ Parameter '$PARAMETER' not found in project config"
		exit 1
	fi
	echo "$RESULT"
}