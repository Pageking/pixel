get_cw_bearer() {
	CONFIG_PATH="$HOME/.config/pixel/config.json"
	CLOUDWAYS_EMAIL=$(jq -r '.cw.email' "$CONFIG_PATH")
	CLOUDWAYS_API_KEY=$(jq -r '.cw.api_key' "$CONFIG_PATH")

	AUTH_RESPONSE=$(curl -s POST "https://api.cloudways.com/api/v1/oauth/access_token" \
	-H "Content-Type: application/json" \
	-d "{\"email\":\"$CLOUDWAYS_EMAIL\", \"api_key\":\"$CLOUDWAYS_API_KEY\"}")

	export ACCESS_TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.access_token')
}