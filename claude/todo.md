# Gnome Venture: LIVE TO-DO (open items only; reviewed for stale 2026-11-26; main = 2.8.73). History: `claude/todo_history.md`

Rules: add new items here only. Tick or delete when done, and MOVE finished blocks to `claude/todo_history.md` (newest on top). STANDING RULE (Josh, 2026-11-05): after every change or release, update this file. Items marked (2.7.x) were carried from older lists and not re-verified: check before building.

## 2.8.73 SHIPPED 2026-11-26 (PR 84 merged to main; slim zip `releases/GnomeVenture-2.8.73-web-update.zip` built against 2.8.70, goes on 2.8.70 or newer, includes 2.8.71 + 2.8.72)
- Open from it: shops-street hotspots unchecked by eye; route cards lost the gnome (ask if wanted back) and the lair card keeps its eyes; stoptiers mill-1, workshop-1..4, spring-3 kept as before (redraws were broken); `mini-<slug>.png` rigs old; zip not test-installed over a real 2.8.70.

## A. Owner picks / decisions waiting
- Stop art: DONE and swapped in 2.8.73 (flagged: shops-street hotspots not checked by eye; 6 stoptiers kept as before; route cards no longer show the gnome: ask if wanted back; lair route card still has glowing eyes).
- Fair dock Enter: CUT by owner. "Visitor can smell it" reading (still-cooking dish vs last-cooked): ask.
- Rigs: all 124 redrawn and swapped (2.8.73); `mini-<slug>.png` still old; cistern-newt unchanged; dung-beetle fails rigkit pivot lint (harness). 69 weaker pals: pick-list?
- Confirm on the live world: 8 base creature rows got region windows (boot step `creature_windows_2708`, code done); Hollow jar second-week sizing check; `sights_shared_on` is still OFF by default (Josh ticked it as reviewed; flip in Admin if wanted); `gnav_on` / `gnav_tree` / `gnav_tiles` / `home_slim` default OFF (check Admin).

## B. Code / bugs open
- DECIDED (Josh, 2026-11-26): keep `game/includes/data/trail_maps.json` (old 22x7 reference for tests; not live, all 246 routes overridden by `data/trail_maps/*_30x18.json`). Known: Admin "Trail maps check" reports it as live; silent 22x7 fallback if a region file fails validation.
- Owner: dock labels render ~8px under 340px high (`dock.js scaleFor` k=0.75, a 2.8.50 trade-off, not a bug). Options: accept; or a `dk-small` class with 13px labels (eye check "Out & about" / "Together"); or drop the 75% scale (26 px less page at 640x260). Recommended: labels only. W3 shop / village card asks. (Hovel tabs and tour ask card at 640x260: FIXED in `dock.css`, unreleased.)
- Live world (2.8.73): if `SELECT COUNT(*), MAX(id), SUM(id=239) FROM routes` gives `245 | 472 | 1` it has the route-id bug; fix with `php tools/renumber_routes_239.php GAME_DIR` (dry run), then `--apply` (SQLite: copies game.sqlite; MySQL: needs `--i-have-a-db-backup`). `245 | 473 | 0` is already right. Not run on live. Tested on SQLite only (bad world, rollback, repeat); MySQL path untested.
- DONE: crew wording now "They work every morning at 06:00." (pal_crew.php:135).
- `aseprite-source/v3/creature25/gen.lua` would overwrite swapped rigs: do not rerun blind.
- treks: passes locally (0 FAIL) but takes about 7.5 minutes (`trek_audit_ch3b.php` is most of it) against `ci_suites.sh`'s `timeout 600`: watch for load timeouts, lower `AUDIT_N` or split if it bites. puzzle_pals dock fix greys the Pals entry as "soon" when closed or for guests (owner may prefer omitting it).
- Flaky under load: sinks097, game_clock.sh, catfish, puzzle_pals, tour, roads, pfboard, pfdeck_v1. Do not add to `RETRY_SUITES` without telling Josh.
- Never run: MySQL (`upgrade_check.sh`), full CI on a phone-class check, a real phone. Not seen in a real browser: harvest dialog timing, batch picker, quick turns, run-away buttons, Walk to the way on, Sell all crops, Hovel link, dock Take/Deliver/Rest/Fight, W-badge shop, event banners in the bell, Cat Fish rod upgrades, crew 06:00 pass. Ideas: SMTP untested live, cPanel cron for reminders.
- (2.7.x) Puzzle combat: no human play session; creature card on a phone; Almanac pages for 231 creatures; player-text / tone review; phone performance of 117+ rigs unmeasured.
- (2.7.x) Sights balance untested; decor needs a real yard check; Almanac `npc:` keys probably moot (migration removes them). Treks open: scenes Gloomtooth intro / Sorrel's door / signpost riddle, Thorny / Bramble, respec, Lanternroot crop, hats / stamp / trophy, Snail Trail 3rd puzzle game (Ch IV-VI and trailmate 8 struck).
- Ideas: preset postcards, follow a friend's trail, seed lineage, satchel split stacks by quality, crop economy (`price_base_pct` 60 to 70), cPanel cron for reminder emails, /testvault/. SMTP untested live. (SMTP and cron: see Never run)

## C. Wearables / Closet open (2.7.x)
Open: nothing browser-tested (Closet, avatar art); front cloak / pack art weak; outfitter staff have no portraits; Pals tab and pre-fight screen may still pack a worn piece (untraced); 1-7 worn pieces and Lined untested; `oc-flax-wading-wraps` -4.6 health; human playtest needed. By design: non-slim My Gnome keeps the Wearing panel. Done: Closet picker is an in-page dialog, demo / sims feed `worn`, 42 legendary sim (`claude/balance-legend-sim.md`).

## D. Art open
Method: `aseprite-source/v3/HANDOFF.md`, `claude/art-audit.md`, Hearth Pop / Stitched Toy. Delete `obj/lm-*.png` before re-baking.
- Trail ground for the other 11 regions is stand-in (coast / tundra / forest ground reused); landmark sprites mostly drawn. Lair sleeper bright purple; taprow syrup thin; stop-look weak spots (coast market no quay, wetland / tundra animals small, rainforest tower roof). Depth-order overdraw is FIXED.
- Weak items: tomato kept on purpose (Josh may swap); ginseng seed keeps old picture; check wasp legs / clam head in the new 2.8.72 rigs; butterfly / moth villager faces and tortoise villager shell still open.
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
