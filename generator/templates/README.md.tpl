# {{PLUGIN_NAME}}

{{PLUGIN_DESCRIPTION}}

## Installation

1. Upload the plugin folder to `/wp-content/plugins/`.
2. Activate the plugin through the WordPress plugins screen.
3. Configure settings under {{ADMIN_MENU_PATH}} in the WordPress admin.

## Development

- `composer lint`
- `composer lint-fix`
- `composer i18n:pot`
- `npm run lint`
- `npm run lint-fix`
- `npm run i18n:pot`

## Translations

- Translation files live in `languages/`.
- A starter POT file is scaffolded as `languages/{{PLUGIN_TEXT_DOMAIN}}.pot`.
- Regenerate the POT file after string changes with `composer i18n:pot`.
