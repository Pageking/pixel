get_1pass_var() {
	local vault_name item_name field_name result

	vault_name="$1"

	# Validate arguments
    if [ -z "$vault_name" ]; then
        echo "Invalid vault name"
        exit 1
    fi

	item_name="$2"

	# Validate arguments
    if [ -z "$item_name" ]; then
        echo "Invalid item name"
        exit 1
    fi

	if [[ ! "$item_name" == *"- Pixel credentials"* ]]; then
		item_name="$item_name - Pixel credentials"
	fi

	field_name="$3"

	if [ -z "$field_name" ]; then
        echo "Invalid field name"
        exit 1
    fi

	result=$(op read "op://$vault_name/$item_name/$field_name")

	echo "$result"
}