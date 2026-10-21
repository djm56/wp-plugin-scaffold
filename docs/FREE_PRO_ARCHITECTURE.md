# Free/Pro Architecture

## Distribution Model

| Variant | Distribution | Licence |
|---------|-------------|---------|
| Free | WordPress.org plugin directory | GPL-2.0-or-later |
| Pro | Sold directly (your own site) | GPL-2.0-or-later |

## Plugin Types

| Type | Free variant | Pro variant | Use case |
|------|-------------|-------------|----------|
| `free+pro` | Yes (WP.org) | Yes (direct) | Standard model — free base + paid extension |
| `free-only` | Yes (WP.org) | No | Full-featured free plugin, no paid tier |
| `pro-only` | No | Yes (direct) | Premium-only, not on WP.org |

## Coexistence Rules (free+pro)

1. Free and pro must use **different constant prefixes** (e.g. `ACMESL_` vs `ACMESLP_`)
2. Free and pro must use **different option keys** (e.g. `acmesl_options` vs `acmeslp_options`)
3. Free detects pro activation via a **dedicated filter** and defers to pro's module
4. Free must **not duplicate processing** when pro is active
5. Pro extends free's settings page via hooks — no separate admin menu

## Upsell Policy (WP.org-safe)

1. One contextual upgrade submenu/page only — registered once, checked for duplicates
2. No global admin nag notices or modal popups
3. No gating of included free features behind time limits or degradation

## Versioning

1. `CHANGELOG.md` is the source of truth for release notes
2. Plugin header `Version` and `readme.txt` `Stable tag` must match
3. Free and pro versions are independent (e.g. free 1.3.0, pro 1.0.0)
4. Use descriptive release commits; avoid rapid noisy updates

## Ownership of Differences

- Product-specific behaviour lives in **module classes**
- Compliance and structural behaviour lives in **boilerplate templates**
- Feature toggles are driven by **config JSON feature flags**
