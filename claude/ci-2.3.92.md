# CI baseline before polish work, 2.3.92 (SQLite only)

Run 2026-10-31 on branch ccr-6b3ba1b1-2c15cp (no code changed). PHP 8.3.6. Method: `tests/ci_suites.sh` with the `DEFAULT_SUITES` list from `.github/workflows/ci.yml`, PORT_BASE 8800.

| Check | Result |
|---|---|
| php -l, every game/*.php, includes, admin | pass |
| tools/check_versions.sh | pass (2.3.92) |
| ci_suites.sh, 73 suites | 71 pass, 2 fail |

Failures (both exist before any polish change):
- `gather150`: scene art `src` check, "gather form" and "adventure form action" fail (known base failure since 2.2.x, see todo.md; looks like a stale check, the page moved from `gather.php`, which now redirects to `world.php`).
- `landing`: "shots are from 2.0.73, build is 2.3.92". Fix by re-running `bash tests/shots.sh` and committing the images, not a code bug.

Previously noted failures that now pass: `catfish`, `folkoverlay`, `social100`.

Not run: MySQL, `upgrade_check.sh`, phone, screen reader, 200% zoom.
