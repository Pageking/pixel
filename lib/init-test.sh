IFS=$'\n'

source "$(dirname "${BASH_SOURCE[0]}")/helpers/check-public-folder.sh"
source "$(dirname "${BASH_SOURCE[0]}")/helpers/env/get-github-var.sh"
check_public_folder

# === CONFIGURATION ===
CONFIG_PATH="$HOME/.config/pixel/config.json"
SERVER=$(jq -r '.servers.server_1.server' "$CONFIG_PATH")
DOMAIN=$(jq -r '.servers.server_1.domain' "$CONFIG_PATH")
IP=$(jq -r '.servers.server_1.ip' "$CONFIG_PATH")
DB_PREFIX=$(jq -r '.wp.db_prefix' "$CONFIG_PATH")
WP_ADMIN=$(jq -r '.wp.admin_username' "$CONFIG_PATH")
WP_ADMIN_PASS=$(jq -r '.wp.admin_password' "$CONFIG_PATH")
WP_ADMIN_EMAIL=$(jq -r '.wp.admin_email' "$CONFIG_PATH")

WWW_ROOT=$(jq -r '.servers.server_1.www_root' "$CONFIG_PATH")

PROJECT_NAME=$(get_github_var "PROJECT_NAME")
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo "Invalid project name. Use only lowercase letters, numbers, and hyphens (no spaces or special characters)."
  exit 1
fi

DB_NAME="${PROJECT_NAME}"
DB_USER="${DB_NAME}_user"
DB_PASS="$(openssl rand -base64 12)"

GIT_REPO="git@github.com-info:$(jq -r '.github.org' "$CONFIG_PATH")/pk-theme.git"
TARGET_DIR="/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/${WWW_ROOT}/wp-content/themes"

SUFFIX=$(openssl rand -hex 5)
PLESK_USER="${DOMAIN}_${SUFFIX}"
PLESK_PASS=$(openssl rand -base64 16)

# === Save credentials in 1Password ===
OP_VAULT="Credentials"  # <-- Change to your actual vault name or ID
OP_ITEM_NAME="Plesk: ${PROJECT_NAME}.${DOMAIN}"

# Check if item already exists
EXISTING_ITEM=$(op item list --vault "$OP_VAULT" --categories=Login --format=json | jq -r --arg name "$OP_ITEM_NAME" '.[] | select(.title == $name) | .id')

if [[ -n "$EXISTING_ITEM" ]]; then
  echo "⚠️ 1Password item already exists for $OP_ITEM_NAME. Skipping creation."
else
  echo "💾 Saving credentials to 1Password..."

  op item create \
    --vault "$OP_VAULT" \
    --category Login \
    "username=$PLESK_USER" \
    "password=$PLESK_PASS" \
    "url=https://${PROJECT_NAME}.${DOMAIN}" \
    "notes=Auto-generated on $(date)" \
    title="$OP_ITEM_NAME"

  echo "✅ Credentials saved to 1Password vault '$OP_VAULT' as '$OP_ITEM_NAME'"
fi

echo "👷 Creating domain on Plesk with project name '$PROJECT_NAME'"
ssh -o IgnoreUnknown=UseKeychain "$SERVER" bash <<'EOF'
# Exit on first failure
set -e 

# Creating Domain
plesk bin domain --create ${PROJECT_NAME}.${DOMAIN} -ip $IP -hosting true -www-root $WWW_ROOT -login $PLESK_USER -passwd $PLESK_PASS

# Enable SSH access
plesk bin subscription -u ${PROJECT_NAME}.${DOMAIN} -shell /bin/sh

# Create database
plesk bin database --create $DB_NAME -domain ${PROJECT_NAME}.${DOMAIN} -type mysql

# Create database user
plesk bin database --create-dbuser $DB_USER -passwd $DB_PASS -domain ${PROJECT_NAME}.${DOMAIN} -server localhost:3306 -database $DB_NAME

# Install WP
plesk ext wp-toolkit --install \
    -domain-name ${PROJECT_NAME}.${DOMAIN} \
    -installation-path /$WWW_ROOT \
    -admin-email $WP_ADMIN_EMAIL \
    -admin-user $WP_ADMIN \
    -admin-password $WP_ADMIN_PASS \
    -db-name $DB_NAME \
    -db-user $DB_USER \
    -db-password $DB_PASS

# Clone main theme into created 
git clone $GIT_REPO $TARGET_DIR/pk-theme

git clone -b test git@github.com-info:$(jq -r '.github.org' "$CONFIG_PATH")/${PROJECT_NAME}.git /var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/wp-content/themes/$(jq -r '.github.template_repo' "$CONFIG_PATH")
EOF
echo "✅ Domain created"

if [[ -f "wp-cli.yml" ]]; then
	echo "🔄 Syncing wp-cli.yml to server..."
	scp wp-cli.yml ${SERVER}:/var/www/vhosts/${PROJECT_NAME}.${DOMAIN}/httpdocs/
else 
	echo "⚠️ No wp-cli.yml file found in the current folder. Skipping wp-cli.yml upload."
fi

read -rp "Do you also want to sync the plugins and/or the database? [y/N]: " sync_plugins
if [[ "$sync_plugins" =~ ^[Yy]$ ]]; then
	source "$(dirname "${BASH_SOURCE[0]}")/helpers/test/sync-dev-to-test.sh"
	sync_dev_to_test "$PROJECT_NAME"
fi