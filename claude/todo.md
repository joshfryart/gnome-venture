# Gnome Venture: LIVE TO-DO (open items only; reviewed for stale 2026-11-26; main = 2.8.77, live = 2.8.77). History: `claude/todo_history.md`

Rules: add new items here only. Tick or delete when done, and MOVE finished blocks to `claude/todo_history.md` (newest on top). STANDING RULE (Josh, 2026-11-05): after every change or release, update this file. Items marked (2.7.x) were carried from older lists and not re-verified: check before building.
## Latest: 2.8.77 on main and live (2026-11-27; Josh confirmed it works on live). Slim zip `releases/GnomeVenture-2.8.77-web-update.zip` (99 files, goes on 2.8.73 or newer). Release blocks 2.8.73 to 2.8.77 are in `claude/todo_history.md`. Open from this run: find why live had a different `first_week.php` (it called `craft_link_fix()`, fixed by 2.8.76); nothing seen on a real phone or MySQL.

## A. Owner picks / decisions waiting
- Stop art: DECIDED (Josh, 2026-11-27): route cards stay without the gnome; the lair route card keeps its glowing eyes. Still open: shops-street hotspots not checked by eye; 6 stoptiers (mill-1, workshop-1..4, spring-3) kept as before (their redraws were broken).
- DONE unreleased (after 2.8.76, in `gardens.php` `building_peek`, `tests/cook.sh` updated, cook 158 ok): a visitor smells the LAST-COOKED dish (Josh, 2026-11-27): kitchen peek reads "Something is bubbling away and it smells of <last-cooked dish>"; the pot's own dish is only the fallback when no dish was cooked yet. Note `users.last_cooked_id` is set when a dish is collected. Fair dock Enter: CUT by owner.
- Rigs: all 124 redrawn and swapped (2.8.73). DECIDED (Josh, 2026-11-27): leave the 69 weaker pals and the old `mini-<slug>.png` rigs as they are. Harness notes: cistern-newt unchanged; dung-beetle fails the rigkit pivot lint.
- Confirm on the live world: 8 base creature rows got region windows (boot step `creature_windows_2708`, code done); Hollow jar second-week sizing check.

## B. Code / bugs open
- DECIDED (Josh, 2026-11-26): keep `game/includes/data/trail_maps.json` (old 22x7 reference for tests; not live, all 246 routes overridden by `data/trail_maps/*_30x18.json`). Known: Admin "Trail maps check" reports it as live; silent 22x7 fallback if a region file fails validation.
- `aseprite-source/v3/creature25/gen.lua` would overwrite swapped rigs: do not rerun blind.
- treks: passes locally (0 FAIL) but takes about 7.5 minutes (`trek_audit_ch3b.php` is most of it) against `ci_suites.sh`'s `timeout 600`: watch for load timeouts, lower `AUDIT_N` or split if it bites. puzzle_pals dock fix greys the Pals entry as "soon" when closed or for guests (owner may prefer omitting it).
- Flaky under load: sinks097, game_clock.sh, catfish, puzzle_pals, tour, roads, pfboard, pfdeck_v1. Do not add to `RETRY_SUITES` without telling Josh.
- Never run: MySQL (`upgrade_check.sh`), full CI on a phone-class check, a real phone. Not seen in a real browser: harvest dialog timing, batch picker, quick turns, run-away buttons, Walk to the way on, Sell all crops, Hovel link, dock Take/Deliver/Rest/Fight, W-badge shop, event banners in the bell, Cat Fish rod upgrades, crew 06:00 pass. Ideas: SMTP untested live, cPanel cron for reminders.
- (2.7.x) Puzzle combat: no human play session; creature card on a phone; Almanac pages for 231 creatures; player-text / tone review; phone performance of 117+ rigs unmeasured.
- (2.7.x) Sights balance untested; decor needs a real yard check; Almanac `npc:` keys probably moot (migration removes them). Treks open: scenes Gloomtooth intro / Sorrel's door / signpost riddle, Thorny / Bramble, respec, Lanternroot crop, hats / stamp / trophy, Snail Trail 3rd puzzle game (Ch IV-VI and trailmate 8 struck).
- Ideas: preset postcards, follow a friend's trail, seed lineage, satchel split stacks by quality, crop economy (`price_base_pct` 60 to 70), cPanel cron for reminder emails, /testvault/. SMTP untested live. (SMTP and cron: see Never run)

## C. Wearables / Closet open (2.7.x)
Open: nothing browser-tested (Closet, avatar art); the 42 outfitter-staff portraits (`ph/npc-<slug>.png`) are placeholders (folk portraits plus a tape-measure sash and pin cushion): draw real ones; 1-7 worn pieces and Lined untested; human playtest needed. By design: non-slim My Gnome keeps the Wearing panel. Closet picker is an in-page dialog, demo / sims feed `worn`, 42 legendary sim (`claude/balance-legend-sim.md`).

## D. Art open
Method: `aseprite-source/v3/HANDOFF.md`, `claude/art-audit.md`, Hearth Pop / Stitched Toy. Delete `obj/lm-*.png` before re-baking.
- Trail ground for the other 11 regions is stand-in (coast / tundra / forest ground reused); landmark sprites mostly drawn. Lair sleeper taupe fix lives in the 7 sprites only: generator `claude/tile-art-v3-proposal/landmarks_endpieces.py` `RAMP["dusk"]` is still purple, so a re-bake brings it back. Remaining stop-look weak spots: none listed; check on a real phone.
- Weak items: tomato kept on purpose (Josh may swap); ginseng seed looked fine on review; stone-wall-end left as is (a redraw was not clearly better). 2.8.75 redid moth 1, butterflies 1-3, tortoise shells, stuffed-peppers-goat. Moth 1 sprite ruff / antenna barbs may still be a touch busy.
- Optional: wander-step-back, street / door animation, season variants, Cat Fish lane F, cheer pose (needs arm-up gnome cut), glint-only popover scenes r_ee_stove_ledge / r_sa_frost_potatoes, more stat icons, per-villager doors, per-village pictures (2 exist), town repaints, `map/` 16px tiles.

## 6. WATCH / SMALL
- Admin upload `uploads/items/<slug>.png` shadows `assets/img/ph/` (reason an item can show old art).
- Trek map: open-zone walls flat grey; long walks enter from phone-window edge. Travel card 'via X' truncates at 390px.
- Balance: week 1 ~8.5k earned vs ~7k sinks; days 1-3 flush; cosmetics have no level check; harvests ~73% of XP.

## 7. PARKED (Josh: not now)
Combat intent/Guard, KO cost on road fights, Inbox, test environment, growing villages, caravans, more festivals, Duck Pond animal.

## 8. WORKING NOTES
- Playwright test method: throwaway SQLite install (copy `game/`, delete `data/`, run `tests/walk.sh`, `php -S` with `tests/router.php`); unique `PORT_BASE` per suite run; session cookie `garden_sess`; touch drag via CDP `Input.dispatchTouchEvent`.
- Waves: writer subagent per region drafts into scratchpad, lint (`tools/lint_road_events.py`, `tools/lint_stop_acts.py`), merge, fix pack-count tests (`tests/roadlife.php`, `tests/roadkinds.php`).
- CSP: no inline styles. `choice_row()` escapes text: pass plain text. Anchors with `color: inherit` in felt cards: use `--gx-felt-ink`.
- Windows release builds: `build_update.sh` breaks on spaces, relative output dir, CRLF; use a space-free out dir.
- Branch hygiene: see `claude/branches.md`; do not clean old branches without asking.
- Icons: emoji are swapped for drawn icons by `ico_swap` (e.g. 🪙 shows as the petal). JS must not overwrite icon markup; change only text nodes.
- Released: 2.7.00 (2026-11-15), 2.7.01 to 2.7.04 (2026-11-16); details in CHANGELOG. Wearables + Tailor stay behind `pfight_v1`.
