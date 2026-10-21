<?php
/**
 * Module class for {{PLUGIN_NAME}}.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

namespace {{PLUGIN_NAMESPACE}};

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Behaviour orchestrator for the plugin.
 */
class {{PLUGIN_MODULE_CLASS}} {
{{#HAS_AJAX}}

	/**
	 * AJAX action name.
	 */
	const AJAX_ACTION = '{{HOOK_PREFIX}}_event';

	/**
	 * Nonce action guarding the AJAX endpoint.
	 */
	const AJAX_NONCE = '{{HOOK_PREFIX}}_ajax';

	/**
	 * Capability required by the AJAX endpoint.
	 */
	const CAPABILITY = 'manage_options';
{{/HAS_AJAX}}

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
{{#HAS_FRONTEND}}

		add_action( 'wp_enqueue_scripts', array( $this, 'enqueue_assets' ) );
		add_filter( 'the_content', array( $this, 'filter_content' ), 20 );
{{/HAS_FRONTEND}}
{{^HAS_FRONTEND}}

		add_action( 'admin_enqueue_scripts', array( $this, 'enqueue_assets' ) );
{{/HAS_FRONTEND}}
{{#HAS_SHORTCODE}}

		add_shortcode( '{{HOOK_PREFIX}}_shortcode', array( $this, 'render_shortcode' ) );
{{/HAS_SHORTCODE}}
{{#HAS_AJAX}}

		/*
		 * Privileged only. Add a wp_ajax_nopriv_ registration ONLY if the
		 * endpoint is genuinely meant for logged-out visitors, and give it
		 * its own nonce and rate limiting if you do.
		 */
		add_action( 'wp_ajax_' . self::AJAX_ACTION, array( $this, 'handle_ajax' ) );
{{/HAS_AJAX}}
	}

{{#HAS_FRONTEND}}
	/**
	 * Enqueue front-end assets.
	 *
	 * @return void
	 */
	public function enqueue_assets() {
		if ( ! $this->is_enabled() ) {
			return;
		}
{{/HAS_FRONTEND}}
{{^HAS_FRONTEND}}
	/**
	 * Enqueue admin assets on this plugin's screens only.
	 *
	 * @param string $hook_suffix Current admin page hook suffix.
	 * @return void
	 */
	public function enqueue_assets( $hook_suffix ) {
		if ( ! $this->is_enabled() ) {
			return;
		}

		if ( false === strpos( (string) $hook_suffix, {{PLUGIN_SETTINGS_CLASS}}::PAGE_SLUG ) ) {
			return;
		}
{{/HAS_FRONTEND}}
{{#HAS_CSS}}

		wp_enqueue_style(
			'{{PLUGIN_SLUG}}-styles',
			{{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_URL . 'assets/css/admin.css',
			array(),
			{{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_VERSION
		);
{{/HAS_CSS}}
{{#HAS_JS}}

		wp_enqueue_script(
			'{{PLUGIN_SLUG}}-scripts',
			{{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_URL . 'assets/js/admin.js',
			array(),
			{{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_VERSION,
			true
		);
{{/HAS_JS}}
{{#HAS_AJAX}}
{{#HAS_JS}}

		wp_localize_script(
			'{{PLUGIN_SLUG}}-scripts',
			'{{HOOK_PREFIX}}Data',
			array(
				'ajaxUrl' => admin_url( 'admin-ajax.php' ),
				'action'  => self::AJAX_ACTION,
				'nonce'   => wp_create_nonce( self::AJAX_NONCE ),
			)
		);
{{/HAS_JS}}
{{/HAS_AJAX}}
	}
{{#HAS_FRONTEND}}

	/**
	 * Content filter placeholder.
	 *
	 * @param string $content Post content.
	 * @return string
	 */
	public function filter_content( $content ) {
		if ( ! $this->is_enabled() ) {
			return $content;
		}

		return $content;
	}
{{/HAS_FRONTEND}}

	/**
	 * Whether the module is enabled.
	 *
	 * @return bool
	 */
	private function is_enabled() {
		return (bool) $this->plugin->get_option( 'module_enabled', 1 );
	}
{{#HAS_SHORTCODE}}

	/**
	 * Shortcode placeholder.
	 *
	 * @param array<string,mixed> $atts    Shortcode attributes.
	 * @param string|null         $content Enclosed content.
	 * @param string              $tag     Shortcode tag.
	 * @return string
	 */
	public function render_shortcode( $atts = array(), $content = null, $tag = '' ) {
		unset( $atts, $content, $tag );

		return '';
	}
{{/HAS_SHORTCODE}}
{{#HAS_AJAX}}

	/**
	 * AJAX placeholder.
	 *
	 * The capability and nonce checks are here from the start so real
	 * endpoints inherit them rather than bolting them on later.
	 *
	 * @return void
	 */
	public function handle_ajax() {
		if ( ! current_user_can( self::CAPABILITY ) ) {
			wp_send_json_error(
				array( 'message' => __( 'You do not have permission to do that.', '{{PLUGIN_TEXT_DOMAIN}}' ) ),
				403
			);
		}

		check_ajax_referer( self::AJAX_NONCE, 'nonce' );

		wp_send_json_success( array( 'ok' => true ) );
	}
{{/HAS_AJAX}}
}
