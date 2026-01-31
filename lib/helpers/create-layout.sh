create_layout() {
	local layout_category

	if ! [[ -n "$1" ]]; then
		echo "🤦 No layout slug given."
		exit 1
	fi

	if ! [[ "$1" =~ ^[a-z0-9_]+$ ]]; then
		echo "❌ Invalid slug. Use only lowercase letters, numbers, and underscores."
		exit 1
	fi

	if ! [[ -n "$2" ]]; then
		echo "🤦 No layout label given."
		exit 1
	fi

	if ! [[ -n "$3" ]]; then
		layout_category='Content'
	fi

	cd wp-content/themes/pk-theme-child/flex/content/layouts/ || { echo "No layouts folder found"; exit 1; }

	if [[ -d "$1" ]]; then
		read -rp "🔄 $1 already exists, overwrite? [y/N]" overwrite_layout
		if [[ "$overwrite_layout" != "y" ]] && [[ "$overwrite_layout" != "Y" ]]; then
			echo "❌ Cancelling creation of $1."
			exit 0
		fi
	else
		read -rp "➕ Create $1 layout? [Y/n]" create_layout
		if [[ "$create_layout" =~ ^[Nn]$ ]]; then
			echo "❌ Cancelling creation of $1."
			exit 0
		fi
	fi

	mkdir "$1"

	cd "$1" || { echo "Could not find folder $1."; exit 1; }

	cat > fields.php <<- EOF
<?php
\$heading = \$this->getComponent('heading', 'heading');

\$builder->addFields(\$heading);

\$this->addLayout('$1', '$2', \$builder, '$layout_category');
EOF

	cat > frontend.php <<- EOF
<?php
use PKFlex\Classes\Render;

\$title = Render::component('heading', 'heading');
?>

<div class="flex-layout $1-layout">
	<div class="pk-row">
		<div class="pk-row-content pk-grid-container">
			<div class="content span-12 md-span-8 sm-span-5">
                <?= \$title ?>
			</div>
		</div>
	</div>
</div>
EOF

	cat > script.js <<- EOF
document.addEventListener("DOMContentLoaded", function () {

});
EOF
	cat > style.css <<- EOF
.$1-layout {

}
EOF
}