#!/bin/bash
IFS=$'\n'
set -e

cwGenerateGitSSH () {
	GENERATE_KEY=$(curl -s POST "https://api.cloudways.com/api/v1/git/generateKey" \
	-H "Authorization: Bearer $1" \
	-d "{
		\"server_id\": $2,
		\"app_id\": $3
	}")

	export CW_GIT_SSH_KEY=$(curl -s GET "https://api.cloudways.com/api/v1/git/key" \
	-H "Authorization: Bearer $1" \
	-d "{
		\"server_id\": $2,
		\"app_id\": $3
	}")
}