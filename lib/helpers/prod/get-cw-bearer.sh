get_cw_bearer() {
	source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"
	local cw_email cw_api_key
	cw_email=$(get_1pass_var "Servers" "Cloudways" "email")
	cw_api_key=$(get_1pass_var "Servers" "Cloudways" "api_key")

	AUTH_RESPONSE=$(curl -s POST "https://api.cloudways.com/api/v1/oauth/access_token" \
	-H "Content-Type: application/json" \
	-d "{\"email\":\"$cw_email\", \"api_key\":\"$cw_api_key\"}")

	ACCESS_TOKEN="$(echo "$AUTH_RESPONSE" | jq -r '.access_token')"
	export ACCESS_TOKEN
}