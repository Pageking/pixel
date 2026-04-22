#!/bin/bash
IFS=$'\n'
set -e

source "${BREW_PREFIX}/libexec/lib/helpers/test/get-credentials.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/get-project-name.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/get-core-version.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/set-github-var.sh"

test_set_core_version() {	
	# --- Load vars safely ---
	local SERVER DOMAIN REPO PROJECT_NAME THEME_DIR LOCAL_VERSION CORE_VERSION
	SERVER=$(get_1pass_var "Servers" "PK1" "server")
	DOMAIN=$(get_1pass_var "Servers" "PK1" "domain")
	REPO=$(get_1pass_var "Servers" "GitHub" "main_repo")

	# Compare local pk-theme version with GitHub variable
	LOCAL_VERSION=$(get_core_version)
	CORE_VERSION=$(get_github_var "CORE_VERSION")

	if [[ -z "$CORE_VERSION" ]]; then
		echo "❌ CORE_VERSION GitHub variable is not set. Run 'pixel set-core-version' first."
		exit 1
	fi

	if [[ -n "$LOCAL_VERSION" && "$LOCAL_VERSION" != "$CORE_VERSION" ]]; then
		echo "⚠️  Version mismatch detected:"
		echo "   Local pk-theme : $LOCAL_VERSION"
		echo "   GitHub variable: $CORE_VERSION"
		read -rp "Update GitHub variable CORE_VERSION to '$LOCAL_VERSION' before continuing? [y/N]: " update_gh
		if [[ "$update_gh" =~ ^[Yy]$ ]]; then
			set_github_var "CORE_VERSION" "$LOCAL_VERSION"
			CORE_VERSION="$LOCAL_VERSION"
			echo "✅ CORE_VERSION updated to '$CORE_VERSION'."
		fi
	fi

	# --- Validate config ---
	for var in SERVER DOMAIN REPO CORE_VERSION; do
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

	echo "You are about to set the core version to '$CORE_VERSION' on test."
	read -p "⚠️ Are you sure? ⚠️ [y/N]: " confirm_set_core_version
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
		git checkout ${CORE_VERSION}
		git submodule update --init
	'
EOF
	echo "✅ Core version set to '$CORE_VERSION' on test environment."
}