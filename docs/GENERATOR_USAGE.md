# Generator Usage

## Command

```bash
php generator/generate.php --config config/<family>.json --type <free|pro> --output <directory>
```

## Examples

```bash
# Free + Pro pair
php generator/generate.php --config config/examples/free-and-pro.json --type free --output ./_generated
php generator/generate.php --config config/examples/free-and-pro.json --type pro --output ./_generated

# Free-only plugin (config has no "pro" key)
php generator/generate.php --config config/examples/free-only.json --type free --output ./_generated

# Pro-only plugin (config has no "free" key)
php generator/generate.php --config config/examples/pro-only.json --type pro --output ./_generated
```

## Generated Output

One plugin directory per `--type` invocation:

```
_generated/
└── {slug}/
    ├── {slug}.php                   Entry file (plugin headers + bootstrap)
    ├── uninstall.php                 Cleanup on deletion
    ├── composer.json                 PHP deps + lint/i18n scripts
    ├── package.json                  NPM wrapper scripts
    ├── phpcs.xml.dist                WordPress coding standards config
    ├── README.md                     Developer documentation
    ├── readme.txt                    WordPress.org format
    ├── CHANGELOG.md                  Release notes
    ├── includes/
    │   ├── class-{slug}.php                  Main class (singleton, options)
    │   ├── class-{slug}-module.php           Frontend/business logic
    │   ├── class-{slug}-settings.php         Admin settings UI
    │   ├── class-{slug}-analytics.php                (if analytics=true)
    │   └── class-{slug}-admin-analytics.php          (if admin_analytics=true)
    ├── languages/
    │   └── {text-domain}.pot         Starter translation template
    └── assets/
        ├── css/admin.css             (if has_css=true)
        └── js/admin.js               (if has_js=true)
```

## Feature Flags

All booleans, all default `false` except `has_css`. Set them under `features` in the variant section of the config.

| Flag | Effect when `true` |
|------|--------------------|
| `analytics` | Emits the analytics class and wires it up |
| `admin_analytics` | Emits the analytics admin page |
| `cron` | Emits scheduled-event cleanup in `uninstall.php` |
| `meta_registration` | Emits post-meta cleanup in `uninstall.php` |
| `bulk_actions` | Reserved |
| `shortcode` | Registers a shortcode and emits its callback |
| `ajax` | Registers a **privileged-only** AJAX endpoint with a capability check and nonce |
| `has_css` / `has_js` | Emits and enqueues the asset |
| `frontend` | **Default `false` — admin-only.** When `true`, assets enqueue on `wp_enqueue_scripts` and a `the_content` filter is emitted. Leave it `false` for admin tools: a plugin that never renders on the front end should not hook `the_content` on every post. |

### Conditional blocks

Templates use `{{#FLAG}}…{{/FLAG}}` (and `{{^FLAG}}…{{/FLAG}}` for the inverse) so disabled features are **never emitted at all**.

This matters. The generator previously emitted upsell scaffolding into every plugin and disabled it with `if ( false && false )`, which is how an "Upgrade to Pro" screen ended up inside a premium-only product with no pro tier. Prefer a conditional block over generating unreachable code: dead scaffolding that ships to customers is a liability, and it silently becomes live the moment someone "tidies up" the condition.

Available flags: `IS_FREE`, `IS_PRO`, `SHOW_UPSELL` (free **and** `allow_free_upsell`), and `HAS_*` for each feature above. Blocks of the same flag must not nest. Any `{{PLACEHOLDER}}` left unresolved after rendering aborts generation rather than shipping literal braces into a plugin file.

### Hook naming

Hook and action names come from `{{HOOK_PREFIX}}` (the lowercased `constant_prefix`, e.g. `acmesl`), **not** `{{PLUGIN_SLUG}}`. Slugs contain hyphens, which violate `WordPress.NamingConventions.ValidHookName`.

## Validation

The generator validates before generating:

- A `brand` block is present with all five fields (`vendor`, `vendor_slug`,
  `author_uri`, `css_prefix`, `menu_parent_label`), `vendor_slug` is a valid
  Composer vendor name, `css_prefix` is a valid CSS identifier stem, and
  `author_uri` is an http(s) URL. **None of these have defaults** — see the
  Configuration section of the top-level README for why.
- The requested `--type` has a matching section in the config
- All required config fields and variant fields present
- `slug` equals `text_domain` in each variant
- Feature flags are booleans
- For `--type free`: WP.org fields required (`license_uri`, `contributor_usernames`, `plugin_tags` ≤ 5)
- No unresolved `{{PLACEHOLDER}}` remains in any rendered file

Generation stops with a clear error if validation fails.

## Lint Baseline

A freshly generated plugin is **PHPCS-clean on WordPress-Core/Docs/Extra — zero errors, zero warnings**. Verify with `composer install && composer lint` in the generated directory, and keep it that way.

> ⚠️ Always run `composer lint` / `composer lint-fix` **from the plugin root**. PHPCS discovers `phpcs.xml.dist` from the current working directory, not from any path argument — running `phpcs /some/abs/path` from elsewhere silently falls back to the default PEAR standard, reformats everything to non-WordPress style, and rewrites `vendor/` because the exclude patterns never loaded.

## Translation Workflow

Generated plugins include i18n tooling:

```bash
composer i18n:pot    # Extract strings → languages/<text-domain>.pot
npm run i18n:pot     # Same via NPM wrapper
```

Requires WP-CLI to be installed.

## Version Sync Check

After generating, verify version consistency across all files:

```bash
bash scripts/verify-version-sync.sh ./_generated/acme-seo-links
```

Checks that plugin header `Version`, `readme.txt` `Stable tag`, and top `CHANGELOG.md` version all match.
