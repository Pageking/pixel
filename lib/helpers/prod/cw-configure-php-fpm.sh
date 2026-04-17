cw_configure_php_fpm() {
	if [[ $# -ne 3 ]]; then
		echo "❌ Usage: cw_configure_php_fpm <access_token> <server_id> <app_id>"
		exit 1
	fi

	local ACCESS_TOKEN="$1"
	local SERVER_ID="$2"
	local APP_ID="$3"

	local FPM_SETTING=$(base64 -w 0 <<'EOF'
;php_admin_flag[log_errors] = on
;php_admin_value[memory_limit] = 32M
;php_admin_value[max_execution_time] = 120
;php_admin_value[date.timezone] = Europe/Berlin
;php_admin_value[max_input_time] = 300
;php_admin_value[post_max_size] = 25M
;php_admin_value[upload_max_filesize] = 20M
;php_admin_value[max_input_vars] = 3000
;php_admin_value[max_file_uploads] = 20
;php_admin_value[display_errors] = off
php_admin_value[disable_functions] = getmyuid,passthru,leak,listen,diskfreespace,link,dl,system,highlight_file,source,show_source,fpassthru,virtual,posix_ctermid,posix_getcwd,posix_getegid,posix_geteuid,posix_getgid,posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid,posix,_getppid,posix_getpwuid,posix_getrlimit,posix_getsid,posix_getuid,posix_isatty,posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid,posix_setpgid,posix_setsid,posix_setuid,posix_times,posix_ttyname,posix_uname,proc_open,proc_close,proc_nice,proc_terminate,escapeshellcmd,ini_alter,popen,pcntl_exec,socket_accept,socket_bind,socket_clear_error,socket_close,socket_connect,symlink,posix_geteuid,ini_alter,socket_listen,socket_create_listen,socket_read,socket_create_pair,stream_socket_server,shell_exec,exec,putenv
EOF
	)

	echo "🔧 Configuring PHP-FPM settings..."

	local FPM_RESPONSE
	FPM_RESPONSE=$(curl -s -X POST "https://api.cloudways.com/api/v2/app/manage/fpm_setting" \
		-H "Authorization: Bearer $ACCESS_TOKEN" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		--data-urlencode "server_id=$SERVER_ID" \
		--data-urlencode "app_id=$APP_ID" \
		--data-urlencode "fpm_setting=$FPM_SETTING")

	if [[ "$(echo "$FPM_RESPONSE" | jq -r '.status')" != "true" ]]; then
		echo "❌ Failed to configure PHP-FPM settings"
		echo "$FPM_RESPONSE" | jq '.'
		exit 1
	fi

	echo "✅ PHP-FPM settings configured (tmpfile enabled for WP Migrate DB Pro)"
}
