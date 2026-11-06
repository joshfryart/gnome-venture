# CI validation, release 2.3.7 (SQLite only, not committed)

Tested HEAD 2d7ad687 via `git archive` copy (game code not modified). PHP 8.3.6. Method: tests/ci_suites.sh, one suite at a time, private TMPDIR and PORT_BASE. MySQL not run.

## Result: no new failures

| Check | Result | Notes |
|---|---|---|
| php -l, 357 .php (skip combat_math_golden) | pass | |
| conflict markers | pass | |
| tools/check_versions.sh | pass | 2.3.7 |
| tests/db_errors.php | pass | |
| upgrade_check.sh, releases/GnomeVenture-2.2.1-source.zip (newest) | pass | schema matches fresh (1788 objects) |
| upgrade_check.sh, 2.2.0 zip (what CI picks) | pass | same |
| craft (includes alchemy.php and craft_tags.php) | pass | |
| pantry gourmand calling pjobs health puzzle_pals jigsaw events garden100 delve2 delvefloors delveroute delvestamp delvemap images roadlife scenes stops100 security190 | pass | puzzle_pals now passes |
| paljobs | FAIL once, pass on rerun | flaky: `an equipped pal is not sent without agreeing` got "Sap Drip needs to rest first." (pal hp < 1 in pj_can_send); test paljobs.php ~line 238 |
| Rest of DEFAULT_SUITES (57 suites incl. help, yard, puzzles_upload, folkoverlay, social100) | pass | |
| gather150 | FAIL | known: scene art versioned, gather form, adventure form action |
| catfish | FAIL | known: hub link (2 vs 1), bunting jar 13 vs 9 x2, ppal_open view.kph x3 |
