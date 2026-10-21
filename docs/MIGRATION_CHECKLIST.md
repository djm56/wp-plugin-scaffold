# Migration Checklist

Use when applying boilerplate output to an existing plugin codebase.

## Pre-migration

- [ ] Confirm target variant: `free`, `pro`, or both
- [ ] Confirm constant prefix is unique (not used by another plugin)
- [ ] Confirm option key is unique
- [ ] Confirm text domain matches plugin slug

## Generate & Merge

- [ ] Generate scaffold using config JSON
- [ ] Diff generated files against existing plugin code
- [ ] Merge feature-specific logic into generated module/settings files
- [ ] Preserve any custom classes or hooks not in boilerplate

## Validate

- [ ] Run `composer lint` — fix all violations
- [ ] Test activation and deactivation
- [ ] Test settings page save flow (nonce, capability, option storage)
- [ ] Test frontend behaviour (content filters, shortcodes, assets)
- [ ] For pro variants: test free/pro coexistence (free defers to pro)
- [ ] Verify `uninstall.php` cleans up options, cron events, and post meta
- [ ] Run version sync check: `bash scripts/verify-version-sync.sh <plugin-dir>`
