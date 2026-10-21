# First-Activation Wizard — the pattern

> This document is the spec, so plugins implement the onboarding wizard against it rather than by reading some other plugin's class sideways. Chrome comes from `components.css` (`wpps-wizard-*`). See [design/README.md](README.md) for the UI standard this sits inside.

## Behaviour contract

1. **Option-flagged, once.** A single boolean option (`{prefix}_onboarding_complete`). `is_complete()` is the only gate. Uninstall removes it.
2. **Shown, never forced.** The wizard renders **on the plugin's own screens only** (check `get_current_screen()` against the plugin's screen ids — deferred to render time, because the screen object does not exist at `admin_init`). It never redirects away from anything, never interrupts another plugin's screen, and the whole plugin works untouched behind it.
3. **At most 3 steps**, driven by a GET parameter, normalised server-side to a known value.
4. **Skippable everywhere.** Every step carries a dismiss control that marks complete (AJAX with nonce; a plain link fallback is fine). Skipping is a first-class exit, not a failure.
5. **Saves via `admin-post`** with nonce + capability checks, merging into the plugin's *existing* options. **A wizard writes only options that already exist in Settings** — it is a friendlier door to the same rooms, never a place where unique state lives.
6. **Detection over interrogation.** Anything the plugin can detect (active multilingual plugin, SEO plugin, post types), it shows as a statement rather than asking as a question.
7. **Last step ends in the product**, pointed at the first useful action (run a scan, view Help) — not at a marketing page.

## Step template

| Step | Content |
|---|---|
| 1 | *What was detected* — environment statement, builds confidence; sets nothing |
| 2 | *The few choices that matter* — 2–5 controls mapped to existing options |
| 3 | *First action* — do the first useful thing now, or skip to the product |

## Chrome

`div.wpps-wizard` → `wpps-wizard-masthead` (product name + one-line welcome; the masthead's top border is the **only** brand-red element in the admin) → `wpps-wizard-step` (core form controls inside) → `wpps-wizard-actions` (Back link · `wpps-wizard-progress` "Step 2 of 3" · Continue as `button-primary`; Dismiss as a plain link).

## Accessibility

The step container is a `<form>` with a real submit; progress text lives in the actions row (not colour-only); every control labelled; the dismiss link has discernible text ("Skip setup"), not an ×.
