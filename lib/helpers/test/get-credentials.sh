get_plesk_credentials() {
	source "${BREW_PREFIX}/libexec/lib/helpers/get-project-name.sh"
	source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"

	local project_name domain vault item_name item_json
	# PLESK_USER/PLESK_PASS are intentionally NOT local: callers rely on these being
	# exported into their shell after this function returns.

	project_name=$(get_project_name)
	domain=$(get_1pass_var "Servers" "PK1" "domain")
	vault="Credentials"

	item_name="Plesk: ${project_name}.${domain}"

	item_json=$(op item get "$item_name" --vault "$vault" --format json) || {
	echo "❌ Could not find 1Password item '$item_name' in vault '$vault'"
	return 1
	}

	PLESK_USER=$(echo "$item_json" | jq -r '.fields[] | select(.id == "username") | .value')
	PLESK_PASS=$(echo "$item_json" | jq -r '.fields[] | select(.id == "password") | .value')
	export PLESK_USER
	export PLESK_PASS

	echo "🔑 Retrieved credentials for $item_name"
}
