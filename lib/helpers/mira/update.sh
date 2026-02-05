update_mira() {
	if ! [[ -d "$HOME/.config/pixel/mira" ]]; then
		echo "❓ Missing mira folder in ~/.config/pixel/"
		exit 1
	fi

	cd "$HOME/.config/pixel/mira" || exit 1
	git pull origin
}