list_mira_post() {
	echo ""
    echo "Available Mira Post Layouts:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

	find "$MIRA_POST_LAYOUTS" -maxdepth 1 -name "mira_*" -exec basename {} \; | sort | sed 's/^/  - /'
}
