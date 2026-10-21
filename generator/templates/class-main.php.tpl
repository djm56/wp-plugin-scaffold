<?php
/**
 * Main bootstrap class for {{PLUGIN_NAME}}.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

namespace {{PLUGIN_NAMESPACE}};

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Plugin container: owns the singleton, the options store, and the wiring of
 * every collaborating object.
 */
class {{PLUGIN_MAIN_CLASS}} {

	/**
	 * Option storage key.
	 */
	const OPTION_KEY = '{{PLUGIN_OPTION_KEY}}';

	/**
	 * Singleton instance.
	 *
	 * @var {{PLUGIN_MAIN_CLASS}}|null
	 */
	private static $instance = null;

	/**
	 * Module instance.
	 *
	 * @var {{PLUGIN_MODULE_CLASS}}|null
	 */
	private $module = null;

	/**
	 * Settings instance.
	 *
	 * @var {{PLUGIN_SETTINGS_CLASS}}
	 */
	private $settings;
{{#HAS_ANALYTICS}}

	/**
	 * Analytics instance.
	 *
	 * @var object|null
	 */
	private $analytics = null;
{{/HAS_ANALYTICS}}
{{#HAS_ADMIN_ANALYTICS}}

	/**
	 * Admin analytics instance.
	 *
	 * @var object|null
	 */
	private $admin_analytics = null;
{{/HAS_ADMIN_ANALYTICS}}

	/**
	 * Get singleton instance.
	 *
	 * @return {{PLUGIN_MAIN_CLASS}}
	 */
	public static function instance() {
		if ( null === self::$instance ) {
			self::$instance = new self();
		}
		return self::$instance;
	}

	/**
	 * Activate plugin.
	 *
	 * @return void
	 */
	public static function activate() {
		$options = get_option( self::OPTION_KEY );
		if ( ! is_array( $options ) ) {
			update_option( self::OPTION_KEY, self::default_options() );
		}
	}

	/**
	 * Deactivate plugin.
	 *
	 * @return void
	 */
	public static function deactivate() {
		// Reserved for deactivation cleanup hooks.
	}

	/**
	 * Constructor.
	 */
	private function __construct() {
		$this->settings = new {{PLUGIN_SETTINGS_CLASS}}( $this );
{{#HAS_ANALYTICS}}

		$this->analytics = class_exists( __NAMESPACE__ . '\\{{PLUGIN_ANALYTICS_CLASS}}' ) ? new {{PLUGIN_ANALYTICS_CLASS}}() : null;
{{/HAS_ANALYTICS}}
{{#HAS_ADMIN_ANALYTICS}}

		$this->admin_analytics = class_exists( __NAMESPACE__ . '\\{{PLUGIN_ADMIN_ANALYTICS_CLASS}}' ) ? new {{PLUGIN_ADMIN_ANALYTICS_CLASS}}() : null;
		if ( is_object( $this->admin_analytics ) && method_exists( $this->admin_analytics, 'hooks' ) ) {
			$this->admin_analytics->hooks();
		}
{{/HAS_ADMIN_ANALYTICS}}
{{#IS_FREE}}

		// The pro plugin takes over the module when it is active.
		if ( ! $this->is_pro_active() ) {
			$this->module = new {{PLUGIN_MODULE_CLASS}}( $this );
		}
{{/IS_FREE}}
{{#IS_PRO}}

		$this->module = new {{PLUGIN_MODULE_CLASS}}( $this );
{{/IS_PRO}}
	}

	/**
	 * Default options.
	 *
	 * @return array<string,mixed>
	 */
	public static function default_options() {
		return array(
			'module_enabled' => 1,
			'post_types'     => array( 'post', 'page' ),
		);
	}

	/**
	 * Option getter.
	 *
	 * @param string $key            Key.
	 * @param mixed  $fallback_value Value returned when the key is absent.
	 * @return mixed
	 */
	public function get_option( $key, $fallback_value = null ) {
		$options = wp_parse_args( get_option( self::OPTION_KEY, array() ), self::default_options() );
		return array_key_exists( $key, $options ) ? $options[ $key ] : $fallback_value;
	}

	/**
	 * Save merged options.
	 *
	 * @param array<string,mixed> $new_options New values.
	 * @return bool
	 */
	public function update_options( $new_options ) {
		$current = wp_parse_args( get_option( self::OPTION_KEY, array() ), self::default_options() );
		$merged  = array_merge( $current, $new_options );
		return (bool) update_option( self::OPTION_KEY, $merged );
	}
{{#IS_FREE}}

	/**
	 * Whether the paid companion plugin is active.
	 *
	 * @return bool
	 */
	public function is_pro_active() {
		return (bool) apply_filters( '{{HOOK_PREFIX}}_pro_active', false );
	}
{{/IS_FREE}}

	/**
	 * Whether a build-time capability is compiled into this plugin.
	 *
	 * This is a static capability map generated from the boilerplate config —
	 * it is not a licensing or tier check, and must never gate functionality
	 * behind a purchase state.
	 *
	 * @param string $feature Feature key.
	 * @return bool
	 */
	public function has_feature( $feature ) {
		$map = array(
			'analytics'         => {{FEATURE_ANALYTICS}},
			'admin_analytics'   => {{FEATURE_ADMIN_ANALYTICS}},
			'cron'              => {{FEATURE_CRON}},
			'meta_registration' => {{FEATURE_META_REGISTRATION}},
			'bulk_actions'      => {{FEATURE_BULK_ACTIONS}},
			'shortcode'         => {{FEATURE_SHORTCODE}},
			'ajax'              => {{FEATURE_AJAX}},
			'frontend'          => {{FEATURE_FRONTEND}},
		);

		return ! empty( $map[ $feature ] );
	}
}
