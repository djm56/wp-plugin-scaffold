# WP Plugin Scaffold

A config-driven generator for WordPress plugin scaffolds. One JSON file in,
a lint-clean, WordPress.org-ready plugin out — free variant, pro variant, or
both.

Every value that identifies *who* is shipping the plugin lives in the config's
`brand` block. The generator has no house brand of its own, so the same
scaffold serves different companies, product families, and naming schemes
without a find-and-replace pass afterwards.

## Requirements

- PHP 7.4+ (CLI) — tested on 8.3
- Composer and WP-CLI, for the lint and i18n scripts inside generated plugins

## Quick start

```bash
# 1. Start from an example
cp config/examples/free-and-pro.json config/my-plugin.json

# 2. Edit it — at minimum the brand block, slugs, prefixes and descriptions
#    (see "Configuration" below)

# 3. Generate
php generator/generate.php --config config/my-plugin.json --type free --output ./_generated
php generator/generate.php --config config/my-plugin.json --type pro  --output ./_generated

# 4. Verify version consistency
bash scripts/verify-version-sync.sh ./_generated/my-plugin
```

Three worked examples ship in [`config/examples/`](config/examples/):

| Example | Demonstrates |
|---|---|
| `free-and-pro.json` | the standard free base + paid extension pair |
| `free-only.json` | a full-featured free plugin with no paid tier |
| `pro-only.json` | a premium plugin never listed on WordPress.org |

> `config/*.json` is gitignored so your own product configs stay private —
> a config file names an unreleased product, its tier split and its tags.
> Only `config/examples/` is tracked. Remove that line from `.gitignore` if
> your roadmap is public.

## Configuration

### The `brand` block — required

```json
"brand": {
  "vendor": "Acme Web Co",
  "vendor_slug": "acme-web",
  "author_uri": "https://example.com",
  "css_prefix": "acme",
  "menu_parent_label": "Acme Tools"
}
```

| Field | Becomes |
|---|---|
| `vendor` | plugin header `Author`, `readme.txt` author |
| `vendor_slug` | Composer package vendor (`acme-web/acme-seo-links`) |
| `author_uri` | plugin header `Author URI` |
| `css_prefix` | every generated CSS class and custom property |
| `menu_parent_label` | the admin menu path shown in docs and readme prose |

All five are **mandatory and validated**. There are deliberately no defaults:
a generator that quietly substitutes its own author's name into someone
else's plugin is a bug whose failure is silent and ships to users.

`vendor_slug` must be a valid Composer vendor name. `css_prefix` must be a
usable CSS identifier — lowercase, letter-first, single hyphens, no trailing
hyphen.

### Plugin types

| Type | Config shape | Generates |
|---|---|---|
| free + pro | both `free` and `pro` keys | two plugin directories |
| free-only | only `free` | one free directory |
| pro-only | only `pro` | one pro directory |

Requesting a variant the config does not define fails with a clear message
rather than generating something half-formed.

### Feature flags

Per-variant booleans under `features`. All default `false` except `has_css`.
Disabled features are **never emitted at all** — the templates use
conditional blocks rather than generating unreachable `if ( false )` code.
See [docs/GENERATOR_USAGE.md](docs/GENERATOR_USAGE.md) for the full table.

## What you get

```
my-plugin/
├── my-plugin.php              entry file, plugin headers, bootstrap
├── uninstall.php              option / cron / post-meta cleanup
├── composer.json              PHP deps + lint and i18n scripts
├── package.json               npm wrappers
├── phpcs.xml.dist             WordPress coding standards
├── README.md / readme.txt     developer + WordPress.org docs
├── CHANGELOG.md               release history
├── includes/                  main, module, settings (+ analytics if enabled)
├── languages/                 starter .pot
└── assets/                    admin.css / admin.js if enabled
```

Generated admin screens are built from **core WordPress admin markup** —
`.wrap`, `.form-table`, `.notice`, `submit_button()` — so they look native
and stay accessible. The only custom CSS is one `card` component and the
tokens it uses, prefixed with your `css_prefix` and shipped inside the
plugin. See [design/README.md](design/README.md).

## Structure

```
wp-plugin-scaffold/
├── generator/         generate.php + 16 .tpl templates
├── config/examples/   worked example configs
├── design/            design system reference + wizard spec
├── docs/              architecture, release, submission guides
├── scripts/           version sync verification
├── free-template/     contract: minimum free plugin requirements
└── pro-template/      contract: pro extension requirements
```

## Documentation

| Doc | Purpose |
|---|---|
| [GENERATOR_USAGE.md](docs/GENERATOR_USAGE.md) | commands, feature flags, validation, i18n |
| [FREE_PRO_ARCHITECTURE.md](docs/FREE_PRO_ARCHITECTURE.md) | free/pro coexistence and upsell policy |
| [PLUGIN_SCAFFOLD_SPEC.md](docs/PLUGIN_SCAFFOLD_SPEC.md) | naming, tooling, PHPDoc, i18n rules |
| [MIGRATION_CHECKLIST.md](docs/MIGRATION_CHECKLIST.md) | applying the scaffold to an existing plugin |
| [RELEASE_WORKFLOW.md](docs/RELEASE_WORKFLOW.md) | version bumps, SVN, release steps |
| [WPORG_SUBMISSION_CHECKLIST.md](docs/WPORG_SUBMISSION_CHECKLIST.md) | pre-submission compliance |
| [design/README.md](design/README.md) | the UI standard and component set |

## Status

Used in production to build and ship WordPress plugins. Issues and pull
requests are welcome, but this is a tool maintained for its own use first —
there is no support commitment and no release cadence.

## Licence

GPL-2.0-or-later. See [LICENSE](LICENSE).

Plugins you generate are yours; the scaffold does not assert any claim over
its output. Generated plugins declare GPL-2.0-or-later by default because
that is what WordPress.org requires — change `license` and `license_uri` in
your config if you are distributing under different terms.
