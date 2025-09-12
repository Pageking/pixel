get_project_name() {
	export PROJECT_NAME=$(basename "$(dirname "$(dirname "$PWD")")")
}