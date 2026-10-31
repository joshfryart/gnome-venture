# CI validation, release 2.3.6 (SQLite only)

Tested commit: 23183ff2 ("Update todo and handoffs for 2.3.6 crafting area map", branch ccr-222dc533-j67nk3, includes 2.3.3 to 2.3.5). This worktree started at main (44aef90e, 2.3.2) and was fast-forwarded to 23183ff2 first. Base for comparison: 44aef90e (main, 2.3.2), exported with `git archive`.
PHP 8.3.6, pdo_sqlite, gd, mbstring. MySQL not run. Game code not modified.
Method: tests/ci_suites.sh, one suite at a time, private TMPDIR and PORT_BASE per suite.

## Result: no regressions from 2.3.3 to 2.3.6

Every failure on HEAD either fails identically on base or passed on rerun (flaky).

## Static and install checks

| Check | Result | Notes |
|---|---|---|
| php -l, all 352 .php (CI skip list) | pass | |
| tools/check_versions.sh | pass | version 2.3.6 consistent |
| conflict-marker grep | pass | |
| tests/db_errors.php | pass | |
| upgrade_check.sh from releases/GnomeVenture-2.2.0-source.zip | pass | db_migrate no errors, no upgrade step failed, schema matches fresh install (1788 objects). Only source zips present are 2.2.0 and 2.2.1; CI's `sort -V | tail -2 | head -1` picks 2.2.0 |

## Requested suites (all pass)

craft, pantry, pjobs, health, delve2, delvefloors, delveroute, delvestamp, delvemap, images, roadlife, scenes, stops100, security190: pass. puzzle_pals: see below.

## Remaining DEFAULT_SUITES

Pass: adventure animals120 animals140 beds breeding110 calling clock contest eggs110 events explore fix100 fresh_hold friends fun games140 games2 garden100 gear help jobs landmarks market100 pest148 rebuild buildplans rewards roads roads097 roadtext social tools town trade gourmand comm cook flowers gather099 mentors120 modr prog sinks097 social100 stopthemes stopkinds popart roadkinds folkoverlay trekshell updrollback villagers worms puzzles puzzles_tourney puzzles_daily jigsaw jigsaw_tourney landing.

## Failures

| Suite | HEAD | Base (2.3.2) | Verdict |
|---|---|---|---|
| puzzle_pals | FAIL | FAIL, identical | Pre-existing. Line: `FAIL hub: Puzzle Pals card + Jigsaw pip 'pals 3/12' (got '2/1', want '1/1')`. Failed on both HEAD runs. Not in the known-failure list; it was not failing in 2.2.1 per handoff, so 2.3.0 to 2.3.2 or a stale test. |
| gather150 | FAIL | FAIL, identical | Known. `scene art, same origin, versioned`; `gather form`; `adventure form action` |
| catfish | FAIL | FAIL, identical set | Known. `hub: Cat Fish link shows (got '2', want '1')`; bunting +3 jar (got 13, want 9) x2; `ppal_open ... view.kph` x2 |
| reset (tests/reset.sh, not in CI list) | FAIL | FAIL | Known "reset-install check": `INSTALL FAILED` at the install step, both trees |
| yard | FAIL once | pass | Flaky. HEAD first run: SQLite PDOExceptions (`users.password_hash NOT NULL`, syntax errors near ORDER, ",", THEN). Passed on rerun on HEAD. |
| puzzles_upload | FAIL once | pass | Flaky. `switched on: in the player library (got '0', want '1')`. Passed on rerun on HEAD. |
| folkoverlay | pass | pass | Listed as a known failure but passed on both here |
| social100 | pass | pass | Same: listed as known, passed on both |

## Notes
- The shared scratchpad `run.sh` was overwritten by another session mid-run. I killed my runner and restarted from delvemap under a private directory; the first 8 suites (craft to delvestamp) had already finished (all pass) and were not re-run.
- catfish takes about 4 minutes.
