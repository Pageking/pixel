#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

sync_dev_to_prod() {
	rsync -avzh --progress --delete-after --update "wp-content/plugins" $2@$1:/home/master/applications/$3/public_html/wp-content/
}