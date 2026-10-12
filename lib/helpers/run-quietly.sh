run_quietly() {
	local output_file exit_code

	output_file=$(mktemp "${TMPDIR:-/tmp}/pixel.XXXXXX") || return 1
	if "$@" >"$output_file" 2>&1; then
		rm -f "$output_file"
		return 0
	else
		exit_code=$?
		cat "$output_file" >&2
		rm -f "$output_file"
		return "$exit_code"
	fi
}

announce_step() {
	printf '⏳ %s...\n' "$1" >&2
}

run_step() {
	local description="$1"
	shift

	announce_step "$description"
	run_quietly "$@"
}