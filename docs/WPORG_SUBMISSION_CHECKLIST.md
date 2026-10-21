# WordPress.org Submission Checklist

Use before submitting any free plugin to the WordPress.org directory.

## Metadata

- [ ] Plugin header includes: `Plugin Name`, `Description`, `Version`, `Text Domain`, `License`, `License URI`, `Requires at least`, `Requires PHP`
- [ ] `readme.txt` includes: `Contributors`, `Tags` (max 5), `Requires at least`, `Tested up to`, `Stable tag`, `License URI`
- [ ] Plugin header `Version` equals `readme.txt` `Stable tag`
- [ ] `Text Domain` matches plugin slug exactly

## Policy Compliance

- [ ] No trialware or time-limited features in free plugin
- [ ] No tracking/telemetry without explicit user opt-in
- [ ] No remote executable code loading
- [ ] Upsell is contextual only — one submenu page, no admin nags or popups
- [ ] Public-site credits/links are opt-in only
- [ ] No "powered by" output without user consent

## Security

- [ ] All input sanitised (`sanitize_text_field`, `absint`, `wp_kses`, etc.)
- [ ] All output escaped (`esc_html`, `esc_attr`, `esc_url`, etc.)
- [ ] All forms use nonce verification (`wp_verify_nonce`)
- [ ] All admin actions check capabilities (`current_user_can`)
- [ ] All database queries use `$wpdb->prepare()`
- [ ] No `eval()`, `extract()`, or `unserialize()` on untrusted data

## Package

- [ ] ZIP excludes dev artifacts: `vendor/`, `node_modules/`, `tests/`, `.phpcs.xml.dist`, `phpunit.xml`
- [ ] Code is human-readable (not obfuscated or minified PHP)
- [ ] Uses WordPress-bundled libraries where available (jQuery, React, etc.)
- [ ] `CHANGELOG.md` updated for the release
- [ ] `readme.txt` changelog section matches `CHANGELOG.md`
- [ ] Version sync script passes

## Submission

- [ ] ZIP contains complete, installable plugin
- [ ] Slug and naming respect WordPress trademark rules
- [ ] Submit via https://wordpress.org/plugins/developers/add/
- [ ] Save review feedback and apply fixes before re-submission
