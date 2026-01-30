source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"

sync_dev_to_test() {
	read -rp "Are you sure you want to sync to the test server? [y/N]" sync_to_test
	if [[ "$sync_to_test" != ^[Yy]$ ]]; then
		echo "Oké dan niet hè."
		exit 0
	fi

	local MDB_CONN_STRING skip_plugins skip_database skip_media mdb_command

	# Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
			--no-database)
                skip_database=true
                shift
                ;;
            --no-plugins)
                skip_plugins=true
                shift
                ;;
			--no-media)
				skip_media=true
				shift
				;;
            --help)
                echo "Usage: pixel sync-dev-to-test [OPTIONS]"
                echo "  --no-database     Skip database synchronization"
                echo "  --no-plugins      Skip plugin synchronization"
                echo "  --no-media     Skip uploads synchronization"
                exit 0
                ;;
            *)
                echo "❌ Unknown flag: $1"
                exit 1
                ;;
        esac
    done

	MDB_CONN_STRING=$(get_github_var "WPM_TEST_CONNECTION_STRING")

	if [[ -z "$MDB_CONN_STRING" ]]; then
		read -rp "WPM_TEST_CONNECTION_STRING is empty, paste the test connection string:" migrate_connection_string
		if [[ -z "$migrate_connection_string" ]]; then
			echo "⚠️ No connection string provided. Skipping GitHub secret update."
		else
			source "${BREW_PREFIX}/libexec/lib/helpers/env/set-github-var.sh"
			echo "💾 Saving connection string to GitHub secret..."
			set_github_var "WPM_TEST_CONNECTION_STRING" "$migrate_connection_string"
			echo "✅ Connection string saved to GitHub secret"
			MDB_CONN_STRING=$(get_github_var "WPM_TEST_CONNECTION_STRING")
		fi
	fi

	echo "🔃 Syncing uploads/media/database to test"
	
	# Build the migratedb command with conditional flags
    mdb_command="wp migratedb push $MDB_CONN_STRING"
    
	if [[ "$skip_database" == true ]]; then
        mdb_command="$mdb_command --exclude-database"
    fi

    if [[ "$skip_plugins" != true ]]; then
        mdb_command="$mdb_command --plugin-files=all"
    fi
    
    if [[ "$skip_media" != true ]]; then
        mdb_command="$mdb_command --media=all"
    fi
    
    eval "$mdb_command"
}