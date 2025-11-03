#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/helpers/check-public-folder.sh"
source "$(dirname "${BASH_SOURCE[0]}")/helpers/get-project-name.sh"
check_public_folder

removeTest() {
	read -p "⚠️ Are you sure you want to remove the test enviroment? ⚠️ [y/N]: " confirm_remove_test
	if [[ ! "$confirm_remove_test" =~ ^[Yy]$ ]]; then
		echo "❌ Aborting removal of test environment."
		exit 1
	fi

	local CONFIG_PATH="$HOME/.config/pixel/config.json"

	# --- Load config safely ---
	local SERVER DOMAIN IP REPO VAULT ITEM_NAME
	SERVER=$(jq -r '.servers.server_1.server' "$CONFIG_PATH")
	DOMAIN=$(jq -r '.servers.server_1.domain' "$CONFIG_PATH")
	IP=$(jq -r '.servers.server_1.ip' "$CONFIG_PATH")
	VAULT="Credentials"
	ITEM_NAME="Plesk: ${PROJECT_NAME}.${DOMAIN}"

	# --- Validate config ---
	for var in SERVER DOMAIN IP REPO; do
		if [[ -z "${!var}" || "${!var}" == "null" ]]; then
			echo "❌ Config error: $var is empty"
			exit 1
		fi
	done

	# --- Project name ---
	local PROJECT_NAME
	PROJECT_NAME=$(get_project_name)
	if [[ -z "$PROJECT_NAME" ]]; then
		echo "❌ Could not determine project name"
		exit 1
	fi

	ssh -o IgnoreUnknown=UseKeychain "$SERVER" bash <<EOF
	# Exit on first failure
	set -e 

	plesk bin subscription --remove "${PROJECT_NAME}.${DOMAIN}"
EOF
	echo "🗑️ Test environment for project '$PROJECT_NAME' removed from Plesk."

	op item delete "$ITEM_NAME" --vault "$VAULT" || {
		echo "❌ Could not delete 1Password item '$ITEM_NAME' from vault '$VAULT'"
		return 1
	}
	echo "🗑️ Deleted 1Password item '$ITEM_NAME' from vault '$VAULT'."
}