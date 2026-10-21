# Free Plugin Template

Minimum requirements for all free plugin variants.

## Required Files

| File | Purpose |
|------|---------|
| `{slug}.php` | Entry file with plugin headers + bootstrap |
| `includes/class-{slug}.php` | Main class (singleton, options, feature checks) |
| `includes/class-{slug}-module.php` | Frontend/business logic |
| `includes/class-{slug}-settings.php` | Admin settings UI + save handling |
| `uninstall.php` | Cleanup on plugin deletion |
| `composer.json` | PHP dependencies + lint/i18n scripts |
| `package.json` | NPM wrapper scripts |
| `phpcs.xml.dist` | WordPress coding standards config |
| `README.md` | Developer documentation |
| `readme.txt` | WordPress.org format |
| `CHANGELOG.md` | Release history |
| `languages/<text-domain>.pot` | Translation template |

## Required Behaviour

- `defined('ABSPATH') || exit;` guard in every PHP file
- Singleton main class with `instance()`, `activate()`, `deactivate()`
- Standard default options array and `get_option()`/`update_options()` helpers
- Admin settings page registered as its own top-level menu (never as a
  submenu of a shared parent that may not exist — see the rationale comment
  in `generator/templates/class-settings.php.tpl`)
- Text domain loaded via `plugins_loaded` hook
- Skip free module when pro is active (checked via `{slug}_pro_active` filter)
