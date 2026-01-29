source "$(dirname "${BASH_SOURCE[0]}")/../../helpers/env/get-github-var.sh"

sync_dev_to_test() {
	local MDB_CONN_STRING
	MDB_CONN_STRING=$(get_github_var "WPM_TEST_CONNECTION_STRING")

	if [[ -z "$MDB_CONN_STRING" ]]; then
		read -rp "WPM_TEST_CONNECTION_STRING is empty, paste the test connection string:" migrate_connection_string
		if [[ -z "$migrate_connection_string" ]]; then
			echo "⚠️ No connection string provided. Skipping GitHub secret update."
		else
			source "$(dirname "${BASH_SOURCE[0]}")/../../helpers/env/set-github-var.sh"
			echo "💾 Saving connection string to GitHub secret..."
			set_github_var "WPM_TEST_CONNECTION_STRING" "$migrate_connection_string"
			echo "✅ Connection string saved to GitHub secret"
			MDB_CONN_STRING=$(get_github_var "WPM_TEST_CONNECTION_STRING")
		fi
	fi

	echo "🔃 Syncing uploads/media/database to test"
	eval "wp migratedb pull $MDB_CONN_STRING --plugin-files=all --media=all"
}