# CI validation, release 2.3.8 (SQLite only, not committed from a clean archive)

Tested the working tree of branch ccr-f7f10010-mkvd2b before the zip build. PHP 8.3.6. Method: `tests/ci_suites.sh`, one suite at a time, own PORT_BASE. MySQL not run.

| Check | Result |
|---|---|
| php -l, every tracked game/*.php | pass |
| tools/check_versions.sh | pass (2.3.8) |
| tests/db_errors.php | pass |
| town, stops100, roadkinds, roadlife, roadtext, villagers | pass |
| images, scenes, security190, updrollback | pass |
| Browser render (SQLite install, seeded player) at 390 / 768 / 1024 / 1366, dark and light | no horizontal scroll, no JS errors, no PHP warnings |

Not run: MySQL, `upgrade_check.sh` (needs a source zip install), phone, screen reader, 200% zoom.
Zip: `releases/GnomeVenture-2.3.8-web-update.zip`, 59 files, UPDATE-BASE 2.3.6.
