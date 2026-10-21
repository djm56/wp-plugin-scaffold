<?php
/**
 * Bootstrap file for {{PLUGIN_NAME}}.
 *
 * Plugin Name: {{PLUGIN_NAME}}
 * Plugin URI: {{PLUGIN_URI}}
 * Description: {{PLUGIN_DESCRIPTION}}
 * Version: {{PLUGIN_VERSION}}
 * Author: {{VENDOR}}
 * Author URI: {{AUTHOR_URI}}
 * Text Domain: {{PLUGIN_TEXT_DOMAIN}}
 * Domain Path: /languages
 * Requires at least: {{REQUIRES_WP}}
 * Tested up to: {{TESTED_UP_TO}}
 * Requires PHP: {{REQUIRES_PHP}}
 * License: {{LICENSE}}
 * License URI: {{LICENSE_URI}}
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Current plugin version.
 */
define( '{{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_VERSION', '{{PLUGIN_VERSION}}' );

/**
 * Absolute path to the main plugin file.
 */
define( '{{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_FILE', __FILE__ );

/**
 * Absolute path to the plugin directory.
 */
define( '{{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_DIR', plugin_dir_path( __FILE__ ) );

/**
 * URL to the plugin directory.
 */
define( '{{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_URL', plugin_dir_url( __FILE__ ) );

require_once {{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_DIR . 'includes/{{PLUGIN_MODULE_FILE}}';
require_once {{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_DIR . 'includes/{{PLUGIN_SETTINGS_FILE}}';
{{#HAS_ANALYTICS}}
require_once {{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_DIR . 'includes/{{PLUGIN_ANALYTICS_FILE}}';
{{/HAS_ANALYTICS}}
{{#HAS_ADMIN_ANALYTICS}}
require_once {{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_DIR . 'includes/{{PLUGIN_ADMIN_ANALYTICS_FILE}}';
{{/HAS_ADMIN_ANALYTICS}}
require_once {{PLUGIN_CONSTANT_PREFIX}}_PLUGIN_DIR . 'includes/{{PLUGIN_CLASS_FILE}}';

register_activation_hook(
	__FILE__,
	array( '{{PLUGIN_NAMESPACE}}\\{{PLUGIN_MAIN_CLASS}}', 'activate' )
);

register_deactivation_hook(
	__FILE__,
	array( '{{PLUGIN_NAMESPACE}}\\{{PLUGIN_MAIN_CLASS}}', 'deactivate' )
);

add_action(
	'plugins_loaded',
	static function () {
		// Load translation files from the plugin languages directory.
		load_plugin_textdomain(
			'{{PLUGIN_TEXT_DOMAIN}}',
			false,
			dirname( plugin_basename( __FILE__ ) ) . '/languages'
		);

		{{PLUGIN_NAMESPACE}}\{{PLUGIN_MAIN_CLASS}}::instance();
	}
);
