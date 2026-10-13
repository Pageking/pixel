source "${BREW_PREFIX}/libexec/lib/helpers/env/get-github-var.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/run-migratedb-sync.sh"
source "${BREW_PREFIX}/libexec/lib/helpers/env/print-sync-summary.sh"

sync_dev_to_prod() {
	local MDB_CONN_STRING MDB_URL MDB_SECRET_KEY MDB_CONN_EXTRA skip_plugins skip_database skip_media
	local -a mdb_command

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

	print_sync_summary "Development" "Production" "${skip_database:-false}" "${skip_plugins:-false}" "${skip_media:-false}"
	read -rp "Are you sure you want to sync to the production server? [y/N]" sync_to_prod
	if [[ "$sync_to_prod" =~ ^[Yy]$ ]]; then
		read -rp "⚠️ Are you REALLY sure you want to sync to the production server? [y/N]" sync_to_prod_check
		if [[ "$sync_to_prod_check" != "Y" ]] && [[ "$sync_to_prod_check" != "y" ]]; then
			echo "❌ Cancelled sync from development to production."
			exit 0
		fi
	fi

	MDB_CONN_STRING=$(get_github_var "WPM_PROD_CONNECTION_STRING")

	if [[ -z "$MDB_CONN_STRING" ]]; then
		read -rp "WPM_PROD_CONNECTION_STRING is empty, paste the prod connection string:" migrate_connection_string
		if [[ -z "$migrate_connection_string" ]]; then
			echo "⚠️ No connection string provided. Skipping GitHub secret update."
		else
			source "${BREW_PREFIX}/libexec/lib/helpers/env/set-github-var.sh"
			set_github_var "WPM_PROD_CONNECTION_STRING" "$migrate_connection_string"
			echo "✅ Connection string saved to GitHub secret"
			MDB_CONN_STRING=$(get_github_var "WPM_PROD_CONNECTION_STRING")
		fi
	fi

	MDB_URL=""
	MDB_SECRET_KEY=""
	MDB_CONN_EXTRA=""
	IFS=$' \t\n' read -r MDB_URL MDB_SECRET_KEY MDB_CONN_EXTRA <<< "$MDB_CONN_STRING"
	if [[ -z "$MDB_URL" || -z "$MDB_SECRET_KEY" || -n "$MDB_CONN_EXTRA" ]]; then
		echo "❌ WPM_PROD_CONNECTION_STRING must contain a URL and secret key separated by whitespace." >&2
		return 1
	fi

	# Build the migratedb command with conditional flags
	mdb_command=(wp migratedb push "$MDB_URL" "$MDB_SECRET_KEY")
    
	if [[ "$skip_database" == true ]]; then
		mdb_command+=(--exclude-database)
    fi

    if [[ "$skip_plugins" != true ]]; then
		mdb_command+=(--plugin-files=all)
    fi
    
    if [[ "$skip_media" != true ]]; then
		mdb_command+=(--media=all)
    fi
	run_migratedb_sync "prod" "${mdb_command[@]}"
}