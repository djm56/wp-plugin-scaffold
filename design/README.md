# Design system

A plugin built from this scaffold should look like WordPress, not like a
widget dropped into WordPress.

## The standard

Screens are built from **core admin markup** — `.wrap`, `.form-table`,
`.notice`, `.button` / `submit_button()`, `.nav-tab-wrapper`,
`.widefat.striped`. Core already styles all of it, it stays accessible, and
it keeps working when WordPress changes its admin theme.

Custom CSS exists **only** for the handful of components core has no
equivalent for. That set is deliberately small and closed:

| Component | Why core has no equivalent |
|---|---|
| `card` | `.postbox` drags in metabox drag/toggle affordances |
| `tile` / `tiles` | no core stat-tile |
| `nav-bar` | a plain sub-nav strip, not tabs |
| `count` / `pill` | core badges are comment-count specific |
| `score` | no core numeric readout |
| `why` | no core inline explanation callout |
| `help-section` | no core collapsible help block |
| `wizard-*` | see [WIZARD_PATTERN.md](WIZARD_PATTERN.md) |

If a screen needs something not on that list, the answer is a core class —
not a new component, and not a new token.

## What the generator emits

A generated plugin is **self-contained**. `assets/css/admin.css` ships the
tokens it needs plus the one `card` component the scaffolded screens use, all
prefixed with your config's `brand.css_prefix`. Nothing is imported from this
folder at runtime.

## What this folder is

The **reference library** — the full component set, for when a plugin grows
past the generated starting point.

- `tokens.css` — the complete token vocabulary
- `components.css` — the full component set
- `WIZARD_PATTERN.md` — the onboarding wizard spec

These use a neutral `wpps-` prefix. To adopt them, copy both files into your
plugin and re-prefix to match your `css_prefix`:

```bash
sed -i '' 's/wpps-/acme-/g' assets/css/tokens.css assets/css/components.css
```

Colours are WordPress core's own admin values, named for what they **mean**,
so no rule hard-codes a hex and a family of plugins cannot drift apart one
shade at a time.

Set `--wpps-brand` to your own brand colour, taken from your actual logo.
Check its contrast — aim for at least 4.5:1 on white (WCAG AA). Brand colour
belongs on the wizard masthead and document accents only, never on
interactive controls, where a red reads as *danger* rather than as brand.

### Vendoring rule

If several plugins share these files, each ships a **byte-identical copy**.
Edit here, then re-copy — never edit a vendored copy. Assert the checksum in
your build script so the family cannot drift.
