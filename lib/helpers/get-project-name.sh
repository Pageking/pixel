get_project_name() {
	local project_name=$(basename "$(dirname "$(dirname "$PWD")")")
	echo "$project_name"
}