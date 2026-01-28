# lib/helpers/env/secrets.sh

IFS=$'\n\t'

# Cache for the session
declare -A SECRET_CACHE

# Read entire 1Password item at once and cache it
load_1password_item() {
    local item_path="$1"
    local cache_key="$2"
    
    if [[ -z "${SECRET_CACHE[$cache_key]}" ]]; then
        SECRET_CACHE[$cache_key]=$(op item get "$item_path" --format json 2>/dev/null) || {
            echo "❌ Error: Could not read 1Password item: $item_path" >&2
            exit 1
        }
    fi
    
    echo "${SECRET_CACHE[$cache_key]}"
}

# Get field from cached item
get_field_from_item() {
    local cache_key="$1"
    local field_id="$2"
    
    echo "${SECRET_CACHE[$cache_key]}" | jq -r ".fields[] | select(.id == \"$field_id\") | .value"
}
