<?php
/**
 * Admin analytics page placeholder for {{PLUGIN_NAME}}.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

namespace {{PLUGIN_NAMESPACE}};

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Registers and renders the analytics submenu.
 */
class {{PLUGIN_ADMIN_ANALYTICS_CLASS}} {

	/**
	 * Admin page slug.
	 */
	const PAGE_SLUG = '{{PLUGIN_SLUG}}-analytics';

	/**
	 * Capability required to view the analytics screen.
	 */
	const CAPABILITY = 'manage_options';

	/**
	 * Register hooks.
	 *
	 * @return void
	 */
	public function hooks() {
		add_action( 'admin_menu', array( $this, 'register_page' ) );
	}

	/**
	 * Register analytics submenu.
	 *
	 * @return void
	 */
	public function register_page() {
		// Nested under this plugin's own top-level menu — see the note in
		// the settings class about the missing shared parent.
		add_submenu_page(
			{{PLUGIN_SETTINGS_CLASS}}::PAGE_SLUG,
			'{{PLUGIN_NAME}} Analytics',
			esc_html__( 'Analytics', '{{PLUGIN_TEXT_DOMAIN}}' ),
			self::CAPABILITY,
			self::PAGE_SLUG,
			array( $this, 'render_page' )
		);
	}

	/**
	 * Render analytics page placeholder.
	 *
	 * @return void
	 */
	public function render_page() {
		if ( ! current_user_can( self::CAPABILITY ) ) {
			return;
		}
		?>
		<div class="wrap">
			<div class="{{CSS_PREFIX}}-card">
				<h1><?php echo esc_html( '{{PLUGIN_NAME}} Analytics' ); ?></h1>
				<p><?php echo esc_html__( 'Analytics dashboard placeholder.', '{{PLUGIN_TEXT_DOMAIN}}' ); ?></p>
			</div>
		</div>
		<?php
	}
}
