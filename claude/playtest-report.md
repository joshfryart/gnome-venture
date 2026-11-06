# Playtest report: commit fbb08c38 (2.3.94 playtest fixes)

Run 2026-11-01. Haiku ran fresh SQLite install (`tests/walk.sh`) + curl playthrough. Sonnet wrote this report. Repo untouched by the run.

| # | Fix | Result | Evidence |
|---|---|---|---|
| 1 | Crafting qty 0 / -1 / abc | PASS | Flash "Pick how many to make: 1 or more."; stock, energy, coins unchanged. qty=1 reaches craft(). Successful craft NOT tested (no kitchen). |
| 2 | Garden name rejects `<` `>` | PASS | `<b>Evil</b>`, `Bad>name` refused; "Sunny Patch" saved. |
| 3 | Flash dedupe + cap | PASS | 3 identical errors give 1 session flash, 1 log line. |
| 4 | Double-submit guard | PASS | Shop buy x1: POST2 within 2s gets 303, coins/qty unchanged; POST after 2.5s works. |
| 5 | Adventure energy refresh | PASS (DB only) | GET persists energy 10 (control pre-fix stays 0). Walk screen shows no energy, visible symptom not seen. |
| 6 | Job deadline text | PASS | Daily, weekly, monthly all show "ends at Hollow ... Progress does not carry over." |
| 7 | XP per harvest shown | PASS | Plant dropdown "+8 XP"; shop seed tag "+8 XP / harvest". |
| 8 | Batch plant falls through picky seed | PASS | Apple (min soil 40) skipped on fertility 35, Radish planted on 3 squares, Apple untouched. No pre-fix control. |
| 9 | Expedition double start | PASS, weak | One active walk, energy charged once. PHP session lock serialises requests, so the race guard itself may not have run. |

Suites: garden100 ok, market100 ok, walk ok (with `SELF_INSTALLING=walk`). PHP logs: no Warning/Notice/Fatal.

## Not tested
Harvest "bare ground" hint, world.php walk redirect, hire race guard, adventure display, batch plant non-soil errors and "too tired" stop path.

## Findings (none fixed)
1. `includes/functions.php` csrf_check double-submit 303: without Referer, falls back to `SCRIPT_NAME`, losing the query string (POST `shop.php?id=15` goes to `/shop.php`). Raw Referer is also reflected into `Location`. Low severity. Suggest: use `REQUEST_URI`, and only same-origin Referer.
2. `tests/ci_suites.sh`: `walk` missing from default `SELF_INSTALLING`, so running it prints a false "INSTALL FAILED". Add `walk`.
3. Identical second POST within 2s is dropped silently, no message. Suggest a flash like "Already done."
4. Batch plant fallback only exercised on "needs richer soil".
