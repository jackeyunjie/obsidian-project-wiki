# Changelog

## 2.1.0 - 2026-06-24

- `install.sh` now supports `--with-dashboard` to copy the optional Dashboard plugin directly into the vault.
- `install.sh` now supports `--copy-examples` to copy `examples/sample-vault/` into the target project.
- Install output now prints the absolute target path, next commands, and Dashboard/example locations.
- README and SKILL docs updated to show direct install commands instead of manual copy steps.

## 2.0.0 - 2026-06-24

- Added `ingest.sh` for `raw/inbox/` classification and intake flow.
- Added `fetch-rss.sh` and `fetch-github.sh` for optional external source capture.
- Upgraded `check.sh` with JSON health report output for machine-readable dashboards.
- Added `plugins/agent-dashboard/` as an Obsidian dashboard MVP.
- Updated templates, prompts, README, and SKILL docs around inbox, health, and source coverage.

## 1.2.0

- Added automation workflow, health check script, and sample vault.

## 1.1.0

- Added scripts, FAQ, and Obsidian configuration guidance.

## 1.0.0

- Initial release.
