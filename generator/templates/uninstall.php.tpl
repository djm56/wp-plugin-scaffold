<?php
/**
 * Uninstall {{PLUGIN_NAME}}.
 *
 * Removes every trace of the plugin when it is deleted from wp-admin.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}

delete_option( '{{PLUGIN_OPTION_KEY}}' );
{{#HAS_CRON}}

// Clear scheduled events so none outlives the plugin that created them.
${{HOOK_PREFIX}}_hook = '{{HOOK_PREFIX}}_cron_event';
${{HOOK_PREFIX}}_next = wp_next_scheduled( ${{HOOK_PREFIX}}_hook );

while ( ${{HOOK_PREFIX}}_next ) {
	wp_unschedule_event( ${{HOOK_PREFIX}}_next, ${{HOOK_PREFIX}}_hook );
	${{HOOK_PREFIX}}_next = wp_next_scheduled( ${{HOOK_PREFIX}}_hook );
}

unset( ${{HOOK_PREFIX}}_hook, ${{HOOK_PREFIX}}_next );
{{/HAS_CRON}}
{{#HAS_META_REGISTRATION}}

global $wpdb;

${{HOOK_PREFIX}}_pattern = $wpdb->esc_like( '{{HOOK_PREFIX}}_' ) . '%';

// Direct query: post meta is deleted in bulk by key pattern, which the meta
// API cannot express. Uncached by design — this runs once, at uninstall.
// phpcs:ignore WordPress.DB.DirectDatabaseQuery.DirectQuery, WordPress.DB.DirectDatabaseQuery.NoCaching
$wpdb->query(
	$wpdb->prepare(
		"DELETE FROM {$wpdb->postmeta} WHERE meta_key LIKE %s",
		${{HOOK_PREFIX}}_pattern
	)
);

unset( ${{HOOK_PREFIX}}_pattern );
{{/HAS_META_REGISTRATION}}

/*
 * Custom tables: add the DROP TABLE statements here in the same change that
 * creates them, never afterwards.
 */
