#!/bin/bash
IFS=$'\n'
set -e

source "${BREW_PREFIX}/libexec/lib/helpers/test/get-credentials.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/get-project-name.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"

test_set_core_version() {	
	# --- Load vars safely ---
	local SERVER DOMAIN REPO PROJECT_NAME THEME_DIR CORE_VERSION NEW_VERSION
	SERVER=$(get_1pass_var "Servers" "PK1" "server")
	DOMAIN=$(get_1pass_var "Servers" "PK1" "domain")
	REPO=$(get_1pass_var "Servers" "GitHub" "main_repo")
	CORE_VERSION=$(get_github_var "CORE_VERSION")
	NEW_VERSION="$1"

	# --- Validate config ---
	for var in SERVER DOMAIN REPO CORE_VERSION NEW_VERSION; do
		if [[ -z "${!var}" || "${!var}" == "null" ]]; then
			echo "❌ Config error: $var is empty"
			exit 1
		fi
	done

	# --- Project name ---
	PROJECT_NAME=$(get_project_name)
	if [[ -z "$PROJECT_NAME" ]]; then
		echo "❌ Could not determine project name"
		exit 1
	fi

	echo "You are currently on core version '$CORE_VERSION'. You want to switch to '$NEW_VERSION' on test."
	read -p "⚠️ Are you sure you want to set the core version to '$NEW_VERSION' on test? ⚠️ [y/N]: " confirm_set_core_version
	if [[ ! "$confirm_set_core_version" =~ ^[Yy]$ ]]; then
		echo "❌ Aborting setting core version."
		exit 1
	fi

	THEME_DIR="/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/wp-content/themes/${REPO}"

	# --- Credentials ---
	get_plesk_credentials "$PROJECT_NAME" "$DOMAIN" || { echo "Failed to get Plesk credentials"; return 1; }

	ssh -T -o IgnoreUnknown=UseKeychain "${SERVER}" <<EOF
	set -e
	bash -lc '
		cd /
		cd ${THEME_DIR}

		git config --global --add safe.directory ${THEME_DIR}
		git fetch --all
		git checkout ${NEW_VERSION}
	'
EOF
	echo "✅ Core version set to '$NEW_VERSION' on test environment."
}