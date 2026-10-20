source "${BREW_PREFIX}/libexec/lib/helpers/env/sync-wpmigrate-plugin.sh"

run_migratedb_sync() {
	local environment="${1:?run_migratedb_sync: environment (test|prod) is required}"
	shift
	local output_file="" exit_code=0

	if [[ "$environment" != "test" && "$environment" != "prod" ]]; then
		echo "❌ Usage: run_migratedb_sync <test|prod> <command> [args...]" >&2
		return 1
	fi

	output_file=$(mktemp "${TMPDIR:-/tmp}/pixel.XXXXXX") || return 1
	# `script` allocates a PTY so wp keeps its progress bars; piping to tee would disable them.
	if script -q "$output_file" "$@"; then
		exit_code=0
	else
		exit_code=$?
	fi

	if [[ "$exit_code" -eq 0 ]]; then
		rm -f "$output_file"
		return 0
	fi

	if ! grep -Fq "Error: Version Mismatch" "$output_file"; then
		rm -f "$output_file"
		return "$exit_code"
	fi

	rm -f "$output_file"
	if ! sync_wpmigrate_plugin "$environment"; then
		echo "❌ Aborting sync: wp-migrate-db-pro version mismatch unresolved."
		return 1
	fi

	"$@"
}