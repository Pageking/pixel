#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "${BASH_SOURCE[0]}")/../check-public-folder.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../check-project-config.sh"
check_public_folder
check_project_config

fill_project_config() {
	if [[ $# -ne 2 ]]; then
        echo "❌ Usage: fill_project_config <json_path> <value>"
        exit 1
    fi
	local PROJECT_CONFIG PARAMETER VALUE
	PROJECT_CONFIG="$(pwd)/wp-content/themes/pk-theme-child/pixel.json"
	PARAMETER="$1"
	VALUE="$2"

	# Update the JSON file using jq
    if ! jq --arg value "$VALUE" "$PARAMETER = \$value" "$PROJECT_CONFIG" > "$PROJECT_CONFIG.tmp"; then
        echo "❌ Failed to update project config"
        rm -f "$PROJECT_CONFIG.tmp"
        exit 1
    fi

	mv "$PROJECT_CONFIG.tmp" "$PROJECT_CONFIG"
    echo "✅ Updated $PARAMETER to '$VALUE' in project config"
}