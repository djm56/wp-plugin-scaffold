# Pro Plugin Template

Extends the free template with advanced capabilities.

## Additions Over Free

| Component | Condition |
|-----------|-----------|
| Analytics class (`Plugin_Analytics`) | `features.analytics = true` |
| Admin analytics class (`Plugin_Admin_Analytics`) | `features.admin_analytics = true` |
| Cron event scheduling | `features.cron = true` |
| AJAX handler endpoints | `features.ajax = true` |
| Shortcode registration | `features.shortcode = true` |
| Post meta registration | `features.meta_registration = true` |
| Bulk admin actions | `features.bulk_actions = true` |
| JavaScript admin assets | `features.has_js = true` |

## Required Behaviour

- Free and pro responsibilities are explicit and separate
- All feature code is opt-in through config JSON flags
- Pro uses its own constant prefix and option key (different from free)
- Pro integrates into free's settings page via hooks — no separate admin menu
- `uninstall.php` cleans up pro-specific options, cron events, and post meta
