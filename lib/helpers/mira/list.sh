list_mira() {
	echo ""
    echo "Available Mira Blocks:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

	find "$MIRA_LAYOUTS" -maxdepth 1 -name "mira_*" -exec basename {} \; | sort | sed 's/^/  - /'
}