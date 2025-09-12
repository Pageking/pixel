source "$(dirname "${BASH_SOURCE[0]}")/get-project-name.sh"
get_plesk_credentials() {
  CONFIG_PATH="$HOME/.config/pixel/config.json"
  local project_name=$(get_project_name)
  local domain=$(jq -r '.servers.server_1.domain' "$CONFIG_PATH")
  local vault="Credentials"

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
