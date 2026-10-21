#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="${1:-}"

if [[ -z "$PLUGIN_DIR" ]]; then
  echo "Usage: scripts/verify-version-sync.sh <plugin-dir>"
  exit 1
fi

if [[ ! -d "$PLUGIN_DIR" ]]; then
  echo "Error: plugin directory not found: $PLUGIN_DIR"
  exit 1
fi

readme_file="$PLUGIN_DIR/readme.txt"
changelog_file="$PLUGIN_DIR/CHANGELOG.md"

plugin_main="$(grep -El '^ \* Plugin Name:' "$PLUGIN_DIR"/*.php 2>/dev/null | head -n 1 || true)"

if [[ -z "$plugin_main" || ! -f "$plugin_main" ]]; then
  echo "Error: plugin main PHP file with Plugin Name header not found in $PLUGIN_DIR"
  exit 1
fi

if [[ ! -f "$readme_file" ]]; then
  echo "Error: readme.txt not found in $PLUGIN_DIR"
  exit 1
fi

if [[ ! -f "$changelog_file" ]]; then
  echo "Error: CHANGELOG.md not found in $PLUGIN_DIR"
  exit 1
fi

plugin_version="$(grep -E '^ \* Version:' "$plugin_main" | sed -E 's/^ \* Version:[[:space:]]+//')"
stable_tag="$(grep -E '^Stable tag:' "$readme_file" | sed -E 's/^Stable tag:[[:space:]]+//')"
changelog_version="$(grep -E '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' "$changelog_file" | head -n 1 | sed -E 's/^## \[([^]]+)\].*/\1/')"

if [[ -z "$plugin_version" || -z "$stable_tag" || -z "$changelog_version" ]]; then
  echo "Error: unable to parse one or more versions"
  echo "  plugin header: $plugin_version"
  echo "  readme stable tag: $stable_tag"
  echo "  changelog: $changelog_version"
  exit 1
fi

if [[ "$plugin_version" != "$stable_tag" || "$plugin_version" != "$changelog_version" ]]; then
  echo "Version mismatch detected"
  echo "  plugin header: $plugin_version"
  echo "  readme stable tag: $stable_tag"
  echo "  changelog: $changelog_version"
  exit 1
fi

echo "Version sync OK: $plugin_version"
