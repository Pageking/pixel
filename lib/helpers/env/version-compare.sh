version_is_older() {
	local v1="$1" v2="$2"

	if [[ "$v1" == "$v2" ]]; then
		return 1
	fi

	[[ "$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | head -n1)" == "$v1" ]]
}

# extract_version_string <raw-output>
#
# Pulls the last dotted-numeric version token (e.g. "2.6.15") out of arbitrary command
# output. Local/remote `wp plugin get --field=version` calls are expected to print just the
# version, but SSH sessions can prepend extra lines (login banners, MOTD, carriage returns),
# which would otherwise corrupt a direct string/sort comparison. Extracting the version this
# way makes comparisons robust regardless of any such surrounding noise.
extract_version_string() {
	local raw="$1"
	printf '%s' "$raw" | tr -d '\r' | grep -Eo '[0-9]+(\.[0-9]+)+' | tail -n1
}
