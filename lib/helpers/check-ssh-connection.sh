#!/bin/bash
IFS=$'\n'

# check_ssh_connection <host> [password] [retries] [timeout_seconds]
#   host     — user@host or SSH alias
#   password — if set, authenticates via sshpass; otherwise uses key-based auth
#   retries  — number of attempts before aborting (default: 3)
#   timeout  — per-attempt connect timeout in seconds (default: 10)
check_ssh_connection() {
	local host="${1:?check_ssh_connection: host is required}"
	local password="${2:-}"
	local retries="${3:-3}"
	local timeout="${4:-10}"

	echo "🔌 Checking SSH connection to $host"

	local attempt=1
	while [[ $attempt -le $retries ]]; do
		if [[ -n "$password" ]]; then
			if sshpass -p "$password" ssh \
				-o ConnectTimeout="$timeout" \
				-o IgnoreUnknown=UseKeychain \
				-o StrictHostKeyChecking=accept-new \
				-o PreferredAuthentications=password \
				-o PubkeyAuthentication=no \
				-o IdentitiesOnly=yes \
				-T "$host" exit 2>/dev/null; then
				break
			fi
		else
			if ssh \
				-o ConnectTimeout="$timeout" \
				-o BatchMode=yes \
				-o IgnoreUnknown=UseKeychain \
				-o StrictHostKeyChecking=accept-new \
				"$host" exit 2>/dev/null; then
				break
			fi
		fi

		if [[ $attempt -lt $retries ]]; then
			echo "⚠️  SSH attempt $attempt/$retries failed. Retrying in 5 seconds..."
			sleep 5
		fi
		((attempt++)) || true
	done

	if [[ $attempt -gt $retries ]]; then
		echo "❌ Could not establish SSH connection to $host after $retries attempt(s)."
		echo "   Please verify:"
		echo "   - The host is reachable          : ping $host"
		echo "   - Your VPN / network is active"
		return 1
	fi

	echo "✅ SSH connection to $host verified"
}
