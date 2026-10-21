<?php
/**
 * Analytics service placeholder for {{PLUGIN_NAME}}.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

namespace {{PLUGIN_NAMESPACE}};

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Internal event recorder.
 *
 * Scaffold state: fans events out to an action hook and stores nothing. This
 * is first-party instrumentation only — it must never phone home.
 */
class {{PLUGIN_ANALYTICS_CLASS}} {

	/**
	 * Record analytics event placeholder.
	 *
	 * @param string              $event   Event name.
	 * @param array<string,mixed> $payload Event payload.
	 * @return void
	 */
	public function record_event( $event, $payload = array() ) {
		/**
		 * Fires when the plugin records an internal event.
		 *
		 * @param string              $event   Event name.
		 * @param array<string,mixed> $payload Event payload.
		 */
		do_action( '{{HOOK_PREFIX}}_analytics_event', $event, $payload );
	}
}
