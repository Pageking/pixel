print_sync_summary() {
	local source_environment="${1:?print_sync_summary: source is required}"
	local destination_environment="${2:?print_sync_summary: destination is required}"
	local database_included="${3:-false}"
	local plugins_included="${4:-false}"
	local media_included="${5:-false}"
	local database_status="✅"
	local plugins_status="✅"
	local media_status="✅"

	[[ "$database_included" == true ]] && database_status="❌"
	[[ "$plugins_included" == true ]] && plugins_status="❌"
	[[ "$media_included" == true ]] && media_status="❌"

	printf '%s\n' '+--------------------------------+----------+----------+----------+'
	printf '| %-30s | %-8s | %-8s | %-8s |\n' "Direction" "Database" "Plugins" "Media"
	printf '%s\n' '+--------------------------------+----------+----------+----------+'
	printf '| %-30s | %s       | %s       | %s       |\n' \
		"$source_environment -> $destination_environment" \
		"$database_status" "$plugins_status" "$media_status"
	printf '%s\n' '+--------------------------------+----------+----------+----------+'
}