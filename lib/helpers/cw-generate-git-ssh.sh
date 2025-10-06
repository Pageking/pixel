#!/bin/bash
IFS=$'\n'
set -e

cwGenerateGitSSH() {
	echo "Token: $1"
	echo "Server id: $2"
	echo "App id: $3"
	local GENERATE_KEY=$(curl -s -X POST "https://api.cloudways.com/api/v1/git/generateKey" \
		-H "Authorization: Bearer $1" \
		-H "Content-Type: application/json" \
		-d "{
			\"server_id\": \"$2\",
			\"app_id\": \"$3\"
	}")

	echo $GENERATE_KEY

	local CW_GIT_SSH_KEY=$(curl -s -X GET "https://api.cloudways.com/api/v1/git/key" \
		-H "Authorization: Bearer $1" \
		-H "Content-Type: application/json" \
		-d "{
			\"server_id\": \"$2\",
			\"app_id\": \"$3\"
	}" | jq -r ".key")

	export $CW_GIT_SSH_KEY
}