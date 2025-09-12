get_plesk_credentials() {
  local project_name="$1"
  local domain="$2"
  local vault="${3:-"Credentials"}"

  local item_name="Plesk: ${project_name}.${domain}"
  local item_json

  item_json=$(op item get "$item_name" --vault "$vault" --format json) || {
    echo "❌ Could not find 1Password item '$item_name' in vault '$vault'"
    return 1
  }

  export PLESK_USER=$(echo "$item_json" | jq -r '.fields[] | select(.id == "username") | .value')
  export PLESK_PASS=$(echo "$item_json" | jq -r '.fields[] | select(.id == "password") | .value')

  echo "🔑 Retrieved credentials for $item_name"
}
