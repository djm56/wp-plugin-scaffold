/**
 * {{PLUGIN_NAME}} — admin styles.
 *
 * The screens this plugin renders are built from core WordPress admin markup
 * (.wrap, .form-table, .notice, .button, submit_button()). Core already
 * styles all of that, and it keeps the plugin looking native when WordPress
 * changes its admin theme.
 *
 * What follows is the small amount core has no equivalent for, plus the
 * tokens those rules use. Everything is prefixed `{{CSS_PREFIX}}-` so two
 * plugins on the same screen cannot collide.
 *
 * Colours are core's own admin values, named for what they MEAN — so no rule
 * below hard-codes a hex, and a family of plugins cannot drift apart one
 * shade at a time. If a screen needs a value that is not here, reach for a
 * core class before adding a token.
 */

:root {
	/* Neutrals — core's, named for their role. */
	--{{CSS_PREFIX}}-text: #1d2327;
	--{{CSS_PREFIX}}-text-secondary: #50575e;
	--{{CSS_PREFIX}}-border: #c3c4c7;
	--{{CSS_PREFIX}}-surface: #ffffff;

	/* Spacing — core admin rhythm. */
	--{{CSS_PREFIX}}-space-4: 16px;
	--{{CSS_PREFIX}}-space-5: 20px;

	/* Radius — match core (.postbox, .button). Nothing rounder. */
	--{{CSS_PREFIX}}-radius: 2px;
}

/**
 * Card — a titled content surface.
 *
 * Core's nearest equivalent is .postbox, which drags in the metabox
 * toggle/drag affordances this does not want.
 */
.{{CSS_PREFIX}}-card {
	max-width: 100%;
	margin-top: var(--{{CSS_PREFIX}}-space-4);
	padding: var(--{{CSS_PREFIX}}-space-5);
	color: var(--{{CSS_PREFIX}}-text);
	background: var(--{{CSS_PREFIX}}-surface);
	border: 1px solid var(--{{CSS_PREFIX}}-border);
	border-radius: var(--{{CSS_PREFIX}}-radius);
}

/* A card's own form table should not add core's leading padding twice. */
.{{CSS_PREFIX}}-card .form-table th {
	padding-left: 0;
}
