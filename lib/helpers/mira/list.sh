list_mira() {
	echo ""
    echo "Available Mira Blocks:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo "Content layouts:"
	find "$MIRA_LAYOUTS" -maxdepth 1 -name "mira_*" -exec basename {} \; | sort | sed 's/^/  - /'
	echo ""
	echo "Sidebar layouts:"
	find "$MIRA_SIDEBAR_LAYOUTS" -maxdepth 1 -name "mira_sidebar_*" -exec basename {} \; | sort | sed 's/^/  - /'
}
