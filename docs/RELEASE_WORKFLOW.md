# Release Workflow

## Source of Truth

- `CHANGELOG.md` is the primary release notes source
- `readme.txt` changelog mirrors the latest release entry
- Plugin header `Version` must match `readme.txt` `Stable tag`

## Local Release Steps

1. Update plugin header version in main `.php` file
2. Update `Stable tag` in `readme.txt`
3. Add release entry to `CHANGELOG.md` (date + Added/Changed/Fixed sections)
4. Copy changelog entry into `readme.txt` changelog section
5. Run version sync check: `bash scripts/verify-version-sync.sh <plugin-dir>`
6. Run lint: `composer lint`
7. Smoke-test: activate, settings save, frontend, deactivate
8. Commit with descriptive message (e.g. "Release 1.2.0 — add bulk scheduling")
9. Tag release in git: `git tag v1.2.0`

## WordPress.org SVN — First Release

1. Checkout SVN repo: `svn co https://plugins.svn.wordpress.org/<slug>`
2. Copy release files into `trunk/` (exclude dev artifacts)
3. `svn add` new files, `svn commit -m "v1.0.0"`
4. Copy trunk to tag: `svn cp trunk tags/1.0.0`
5. `svn commit -m "Tag 1.0.0"`

## WordPress.org SVN — Subsequent Releases

1. Complete local release steps above
2. Replace `trunk/` contents with updated release files
3. `svn commit -m "v1.2.0"`
4. `svn cp trunk tags/1.2.0`
5. `svn commit -m "Tag 1.2.0"`

## Guidelines

- Keep commits meaningful — avoid rapid noisy updates
- Only update `Tested up to` when actually validated against that WP version
- Exclude dev files from SVN: `vendor/`, `node_modules/`, `.phpcs.xml.dist`, `phpunit.xml`, `tests/`
