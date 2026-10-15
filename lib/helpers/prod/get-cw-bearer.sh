get_cw_bearer() {
	source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"

	announce_step "Authenticate with Cloudways"
	ACCESS_TOKEN="$(get_1pass_var "Servers" "Cloudways" "access_token")"

	if [ -z "$ACCESS_TOKEN" ]; then
		echo "❌ Cloudways access_token not found in 1Password (Servers > Cloudways > access_token)"
		exit 1
	fi

	export ACCESS_TOKEN
}
