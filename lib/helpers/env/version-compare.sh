version_is_older() {
	local v1="$1" v2="$2"

	if [[ "$v1" == "$v2" ]]; then
		return 1
	fi

	[[ "$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | head -n1)" == "$v1" ]]
}
