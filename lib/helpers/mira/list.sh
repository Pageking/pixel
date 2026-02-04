list_mira() {
	echo ""
    echo "Available Mira Blocks:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

	ls -1 "$MIRA_LAYOUTS" | grep "mira_" | sed 's/^/  - /'
}