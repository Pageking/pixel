#!/bin/bash

source "${BREW_PREFIX}/libexec/lib/helpers/check-public-folder.sh"
check_public_folder

PROJECT_NAME=$(basename "$(dirname "$(dirname "$PWD")")")

if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo "Invalid project name. Use only lowercase letters, numbers, and hyphens (no spaces or special characters)."
  exit 1
fi

cd "wp-content/themes" || exit 1

if [ -d "pk-theme" ];
then
  echo "❌ Error: This command must be run without an existing pk-theme folder."
  echo "📁 Current directory: $(pwd)"
  exit 1
fi
if [ -d "pk-theme-child" ];
then
  echo "❌ Error: This command must be run without an existing pk-theme-child folder."
  exit 1
fi

source "${BREW_PREFIX}/libexec/lib/helpers/env/get-1pass-var.sh"

# TODO: make deploy key per user instead of master for everyone
SERVER=$(get_1pass_var "Servers" "PK1" "server")
DOMAIN=$(get_1pass_var "Servers" "PK1" "domain")
GITHUB_ORG=$(get_1pass_var "Servers" "GitHub" "org")
MAIN_REPO=$(get_1pass_var "Servers" "GitHub" "main_repo")
TEMPLATE_REPO=$(get_1pass_var "Servers" "GitHub" "template_repo")

run_step "Clone base theme '$MAIN_REPO'" git clone --recurse-submodules "https://github.com/$GITHUB_ORG/$MAIN_REPO.git"

run_step "Create project repository from '$TEMPLATE_REPO'" gh repo create "$GITHUB_ORG/$PROJECT_NAME" \
  --template "$GITHUB_ORG/$TEMPLATE_REPO" \
  --private
run_step "Save Plesk server secret" gh secret set "PLESK_SERVER" --body "$SERVER" --repo "$GITHUB_ORG/$PROJECT_NAME"
run_step "Save Plesk domain secret" gh secret set "PLESK_DOMAIN" --body "$DOMAIN" --repo "$GITHUB_ORG/$PROJECT_NAME"
run_step "Save project name variable" gh variable set "PROJECT_NAME" --body "$PROJECT_NAME" --repo "$GITHUB_ORG/$PROJECT_NAME"

# Wait for repo to be ready
announce_step "Wait for GitHub main branch"
until git ls-remote "https://github.com/$GITHUB_ORG/$PROJECT_NAME.git" 2>/dev/null | grep -q "refs/heads/main"; do
  sleep 1
done

source "${BREW_PREFIX}/libexec/lib/helpers/env/get-core-version.sh"
CORE_VERSION=$(get_core_version)
if [[ -n "$CORE_VERSION" ]]; then
  run_step "Save core version '$CORE_VERSION'" gh variable set "CORE_VERSION" --body "$CORE_VERSION" --repo "$GITHUB_ORG/$PROJECT_NAME"
fi

CLONE_DIR="pk-theme-child"
run_step "Clone project repository" git clone "https://github.com/$GITHUB_ORG/$PROJECT_NAME.git" "$CLONE_DIR"
cd "$CLONE_DIR" || exit 1

# Rename and push branches
run_step "Create development branch" git checkout -b development
run_step "Push development branch" git push -u origin development
run_step "Set test as default branch" gh api -X PATCH "repos/$GITHUB_ORG/$PROJECT_NAME" -f default_branch="test"
announce_step "Remove template main branch"
run_quietly git push origin --delete main >/dev/null 2>&1 || true

for BRANCH in test staging production; do
  run_step "Create $BRANCH branch" git checkout -b "$BRANCH"
  run_step "Push $BRANCH branch" git push -u origin "$BRANCH"
done

run_step "Return to development branch" git checkout development

cat << EOF > .npmrc
engine-strict=true
EOF

echo "✅ Project '$PROJECT_NAME' initialized with branches: development, test, staging, production"
