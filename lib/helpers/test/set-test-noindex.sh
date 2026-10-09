set_test_noindex() {
	local plesk_user="${1:?set_test_noindex: Plesk user is required}"
	local plesk_pass="${2:?set_test_noindex: Plesk password is required}"
	local ip="${3:?set_test_noindex: server IP is required}"

	sshpass -p "$plesk_pass" ssh -T -o IgnoreUnknown=UseKeychain -o PreferredAuthentications=password -o PubkeyAuthentication=no -o IdentitiesOnly=yes "${plesk_user}@${ip}" <<'EOF'
	set -e
	bash -lc '
		cd httpdocs
		wp option update blog_public 0
	'
EOF
}
