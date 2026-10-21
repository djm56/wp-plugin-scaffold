# Plugin Scaffold Specification

## Architecture

All generated plugins follow the same four-class structure:

| File | Class | Purpose |
|------|-------|---------|
| `{slug}.php` | — | Entry file: constants, requires, hooks, text domain |
| `class-{slug}.php` | `Plugin` | Singleton bootstrap, option management, feature checks |
| `class-{slug}-module.php` | `Module` | Frontend/business logic hooks (content filters, shortcodes, AJAX) |
| `class-{slug}-settings.php` | `Settings` | Admin settings page UI, save handling, upsell menu |

Optional classes (feature-flag driven):

| File | Class | Condition |
|------|-------|-----------|
| `class-{slug}-analytics.php` | `Plugin_Analytics` | `features.analytics = true` |
| `class-{slug}-admin-analytics.php` | `Plugin_Admin_Analytics` | `features.admin_analytics = true` |

## Naming Rules

- **Constant prefix**: Unique per variant (free vs pro), uppercase initials (e.g. `ACMESL_`)
- **Option key**: Unique per variant, lowercase (e.g. `acmesl_options`)
- **Text domain**: Must equal plugin slug (e.g. `acme-seo-links`)
- **Hook names**: Derived from `constant_prefix`, underscored (e.g. `acmesl_analytics_event`)
- **Namespace**: `{Vendor}_{Family_Name}` (e.g. `Acme_Seo_Links`)

## Tooling

All generated plugins include:

| Command | Purpose |
|---------|---------|
| `composer lint` | Run PHPCS against WordPress-Core, WordPress-Docs, WordPress-Extra |
| `composer lint-fix` | Auto-fix PHPCS violations |
| `composer i18n:pot` | Generate/update translation POT file via WP-CLI |
| `npm run lint` / `npm run lint-fix` / `npm run i18n:pot` | NPM wrappers for above |

## PHPDoc Rules

- Classes and methods include summary docblocks
- Required tags: `@since`, `@param`, `@return` (where applicable)
- Entry file and `uninstall.php` include purpose docblocks
- Bootstrap constants are documented inline

## i18n Rules

- `Text Domain` header must match plugin slug
- `languages/` directory included in scaffold
- Starter POT file generated as `languages/<text-domain>.pot`
- Update POT via `composer i18n:pot` (requires WP-CLI)
