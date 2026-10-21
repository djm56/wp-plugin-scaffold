<?php
/**
 * Admin settings class for {{PLUGIN_NAME}}.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

namespace {{PLUGIN_NAMESPACE}};

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Registers the settings screen and persists its form.
 */
class {{PLUGIN_SETTINGS_CLASS}} {

	/**
	 * Admin page slug.
	 */
	const PAGE_SLUG = '{{PLUGIN_SLUG}}';

	/**
	 * Action name for the settings form's admin-post handler.
	 */
	const SAVE_ACTION = '{{HOOK_PREFIX}}_save_settings';

	/**
	 * Capability required to view or save settings.
	 */
	const CAPABILITY = 'manage_options';

	/**
	 * Main plugin instance.
	 *
	 * @var {{PLUGIN_MAIN_CLASS}}
	 */
	private $plugin;

	/**
	 * Constructor.
	 *
	 * @param {{PLUGIN_MAIN_CLASS}} $plugin Plugin instance.
	 */
	public function __construct( $plugin ) {
		$this->plugin = $plugin;

		add_action( 'admin_menu', array( $this, 'register_menu' ) );
		add_action( 'admin_post_' . self::SAVE_ACTION, array( $this, 'handle_save' ) );
	}

	/**
	 * Register admin page.
	 *
	 * @return void
	 */
	public function register_menu() {
		/*
		 * A top-level menu, deliberately not a submenu of a shared parent.
		 *
		 * Registering against a shared parent page only works if some other
		 * plugin in the same family has already created it. On a site running
		 * this plugin on its own, add_submenu_page() against a missing parent
		 * registers the page but renders no link anywhere — the plugin is
		 * installed, active, and completely invisible, with no error to
		 * explain why. That has shipped before; it should not ship again.
		 */
		add_menu_page(
			'{{PLUGIN_NAME}}',
			'{{PLUGIN_NAME}}',
			self::CAPABILITY,
			self::PAGE_SLUG,
			array( $this, 'render_page' ),
			'dashicons-admin-generic',
			81
		);

		// Renames the entry WordPress auto-creates for the parent, which
		// would otherwise repeat the menu title.
		add_submenu_page(
			self::PAGE_SLUG,
			'{{PLUGIN_NAME}}',
			esc_html__( 'Dashboard', '{{PLUGIN_TEXT_DOMAIN}}' ),
			self::CAPABILITY,
			self::PAGE_SLUG,
			array( $this, 'render_page' )
		);
{{#SHOW_UPSELL}}

		$this->maybe_register_upgrade_submenu();
{{/SHOW_UPSELL}}
	}
{{#SHOW_UPSELL}}

	/**
	 * Register one contextual upgrade submenu for the free plugin only.
	 *
	 * @return void
	 */
	private function maybe_register_upgrade_submenu() {
		// Under this plugin's own menu, for the same reason the main page is
		// top-level: a shared parent that may not exist orphans the entry.
		add_submenu_page(
			self::PAGE_SLUG,
			esc_html__( 'Upgrade to Pro', '{{PLUGIN_TEXT_DOMAIN}}' ),
			esc_html__( 'Upgrade to Pro', '{{PLUGIN_TEXT_DOMAIN}}' ),
			self::CAPABILITY,
			self::PAGE_SLUG . '-upgrade',
			array( $this, 'render_upgrade_page' )
		);
	}
{{/SHOW_UPSELL}}

	/**
	 * Handle settings save.
	 *
	 * @return void
	 */
	public function handle_save() {
		if ( ! current_user_can( self::CAPABILITY ) ) {
			wp_die( esc_html__( 'You do not have permission to access this page.', '{{PLUGIN_TEXT_DOMAIN}}' ) );
		}

		check_admin_referer( self::SAVE_ACTION );

		$module_enabled = isset( $_POST['module_enabled'] ) ? 1 : 0;
		$this->plugin->update_options( array( 'module_enabled' => $module_enabled ) );

		wp_safe_redirect(
			add_query_arg(
				array(
					'page'    => self::PAGE_SLUG,
					'updated' => '1',
				),
				admin_url( 'admin.php' )
			)
		);
		exit;
	}

	/**
	 * Render settings page.
	 *
	 * @return void
	 */
	public function render_page() {
		if ( ! current_user_can( self::CAPABILITY ) ) {
			return;
		}

		// Display-only flag set by our own post-save redirect. Reading it
		// changes no state, so no nonce is required here.
		// phpcs:ignore WordPress.Security.NonceVerification.Recommended
		$just_saved = isset( $_GET['updated'] );

		$module_enabled = (int) $this->plugin->get_option( 'module_enabled', 1 );
		?>
		<div class="wrap">
			<h1><?php echo esc_html( '{{PLUGIN_NAME}}' ); ?></h1>
			<?php if ( $just_saved ) : ?>
				<div class="notice notice-success is-dismissible">
					<p><?php echo esc_html__( 'Settings updated.', '{{PLUGIN_TEXT_DOMAIN}}' ); ?></p>
				</div>
			<?php endif; ?>
			<div class="{{CSS_PREFIX}}-card">
				<form method="post" action="<?php echo esc_url( admin_url( 'admin-post.php' ) ); ?>">
					<input type="hidden" name="action" value="<?php echo esc_attr( self::SAVE_ACTION ); ?>" />
					<?php wp_nonce_field( self::SAVE_ACTION ); ?>

					<table class="form-table" role="presentation">
						<tr>
							<th scope="row"><?php echo esc_html__( 'Module', '{{PLUGIN_TEXT_DOMAIN}}' ); ?></th>
							<td>
								<label for="module_enabled">
									<input id="module_enabled" type="checkbox" name="module_enabled" value="1" <?php checked( 1, $module_enabled ); ?> />
									<?php echo esc_html__( 'Enable module', '{{PLUGIN_TEXT_DOMAIN}}' ); ?>
								</label>
							</td>
						</tr>
					</table>

					<?php submit_button( __( 'Save Settings', '{{PLUGIN_TEXT_DOMAIN}}' ) ); ?>
				</form>
			</div>
		</div>
		<?php
	}
{{#SHOW_UPSELL}}

	/**
	 * Render contextual upgrade page for the free variant.
	 *
	 * @return void
	 */
	public function render_upgrade_page() {
		if ( ! current_user_can( self::CAPABILITY ) ) {
			return;
		}
		?>
		<div class="wrap">
			<h1><?php echo esc_html__( 'Upgrade to Pro', '{{PLUGIN_TEXT_DOMAIN}}' ); ?></h1>
			<div class="{{CSS_PREFIX}}-card">
				<p><?php echo esc_html__( 'Unlock advanced features with the Pro version.', '{{PLUGIN_TEXT_DOMAIN}}' ); ?></p>
				<p>
					<a class="button button-primary" href="{{PLUGIN_URI}}" target="_blank" rel="noopener noreferrer">
						<?php echo esc_html__( 'Learn More', '{{PLUGIN_TEXT_DOMAIN}}' ); ?>
					</a>
				</p>
			</div>
		</div>
		<?php
	}
{{/SHOW_UPSELL}}
}
