update_pixel() {
	run_step "Update Homebrew package metadata" brew update && run_step "Upgrade Pixel" brew upgrade pixel
	echo "✅ Pixel update complete."
}