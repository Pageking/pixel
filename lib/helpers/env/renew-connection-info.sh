renew_connection_info() {
	read -rp "Are you sure you want to re-enter the connection info? [y/N]" renew_info
	if [[ "$renew_info" != "y" ]] && [[ "$renew_info" != "Y" ]]; then
		echo "Oké dan niet hè."
		exit 0
	fi

	select environment in 'Test' 'Production'; 
	do
		echo "You selected: $environment"
			read -rp "Paste the test connection string:" new_connection_string
			echo "💾 Saving connection string to GitHub variable..."
		if [[ $environment == 'Test' ]]; then
			source "${BREW_PREFIX}/libexec/lib/helpers/env/set-github-var.sh"
			set_github_var "WPM_TEST_CONNECTION_STRING" "$new_connection_string"
		fi
		if [[ $environment == 'Production' ]]; then
			source "${BREW_PREFIX}/libexec/lib/helpers/env/set-github-var.sh"
			set_github_var "WPM_PROD_CONNECTION_STRING" "$new_connection_string"
		fi
		echo "✅ Connection string saved to GitHub variable"
		break;
	done
}