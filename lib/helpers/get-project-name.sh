source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"

get_project_name() {
	local project_name
	project_name=$(get_github_var "PROJECT_NAME")
	echo "$project_name"
}