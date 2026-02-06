#!/bin/bash

source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"
check_public_folder

removeTest() {
	read -p "⚠️ Are you sure you want to remove the test enviroment? ⚠️ [y/N]: " confirm_remove_test
	if [[ ! "$confirm_remove_test" =~ ^[Yy]$ ]]; then
		echo "❌ Aborting removal of test environment."
		exit 1
	fi

	# --- Load config safely ---
	local SERVER DOMAIN VAULT
	SERVER=$(get_1pass_var "Servers" "PK1" "server")
	DOMAIN=$(get_1pass_var "Servers" "PK1" "domain")
	VAULT="Credentials"
	

	# --- Validate config ---
	for var in SERVER DOMAIN VAULT; do
		if [[ -z "${!var}" || "${!var}" == "null" ]]; then
			echo "❌ Config error: $var is empty"
			exit 1
		fi
	done

	# --- Project name ---
	local PROJECT_NAME
	PROJECT_NAME=$(get_github_var "PROJECT_NAME")
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

	# --- Delete 1Password item ---
	ITEM_NAME="Plesk: ${PROJECT_NAME}.${DOMAIN}"
	op item delete "$ITEM_NAME" --vault "$VAULT" || {
		echo "❌ Could not delete 1Password item '$ITEM_NAME' from vault '$VAULT'"
		return 1
	}
	echo "🗑️ Deleted 1Password item '$ITEM_NAME' from vault '$VAULT'."
}