setup_mira() {
	local mira_repo mira_repo_branch
	CONFIG_PATH="$HOME/.config/pixel/config.json"

	mira_repo=$(jq -r '.mira.repo_url' "$CONFIG_PATH")
	mira_repo_branch=$(jq -r '.mira.repo_branch' "$CONFIG_PATH")

	cd ~/.config/pixel || exit 1
	git clone -qb "$mira_repo_branch" "$mira_repo" mira
	echo "✅ Mira succesfully setup"
}