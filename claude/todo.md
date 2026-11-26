# Gnome Venture: LIVE TO-DO (open items only; reviewed for stale 2026-11-26; main = 2.8.72). History: `claude/todo_history.md`

Rules: add new items here only. Tick or delete when done, and MOVE finished blocks to `claude/todo_history.md` (newest on top). STANDING RULE (Josh, 2026-11-05): after every change or release, update this file. Items marked (2.7.x) were carried from older lists and not re-verified: check before building.

## A. Owner picks / decisions waiting
- Stop art (mockup `/tmp/.../scratchpad/stopart/mockup.html`, sent): which swaps / popovers to build.
- Fair dock R Enter (ticked AND struck): ask. "Visitor can smell it" reading (still-cooking dish vs last-cooked).
- Rigs: 6 still old art (bramble-wolf, badger, giant-anteater, dust-sidewinder, gnat-cloud, dune-scorpion); 5 weak per reviewer (cistern-newt, ashen-ant, bellcap-beetle, ember-beetle, grub-beetle): keep or redo? `mini-<slug>.png` still old. 69 weaker pals: pick-list?
- (2.7.x) fight length target 4-5 vs 6-8 turns (`pfboard_tune_v1.php`); flip `sights_shared_on` + blocklist `sights_shared_block`; `tea_open` to everyone; `pfight_v1` Everyone menu entry; Treks Ch IV-VI + trailmate 8; Hollow jar proposals; 4 Sights quest lines over 50 a beat; Rope price at Twigg's is a guess; 8 base creature rows without a region window (live-world change). Josh cleared parts of this on 2026-11-25: re-ask only what is still unclear.

## B. Code / bugs open
- W4 route-id offset bug (`roads.php` `lay_roads` + live-world renumber); gourmand nav tile double count; stale `trail_maps.json`; off-road pin clamp; `rl_trail_heading`.
- W2 residuals: hovel tabs under dock at 640x260, tour "Show me now" at 640x260, dock labels ~8px under 340px high. W3 shop / village card asks.
- Tutorial wording "They start working when you sleep" (crew now also works at 06:00).
- Garden Count badge can lag under the sleep-days clock (raw growth); dock.js finds the Garden tile by label.
- `aseprite-source/v3/creature25/gen.lua` would overwrite swapped rigs: do not rerun blind.
- Tests failing on old code too: pbox_v1, puzzle_pals, gourmand (nav tile 2 vs 1), tea, guest, treks (+10.1 balance sim), pfparts48 (ci_suites only), pfv1_newfight (overlay blocks click). Also (2.7.x): market100, trail_bendy, pf_piece_text, npc25_wire. Flaky under load: sinks097, game_clock.sh, catfish, puzzle_pals, tour, roads, pfboard, pfdeck_v1. Do not add to `RETRY_SUITES` without telling Josh.
- Never run: MySQL (`upgrade_check.sh`), full CI on a phone-class check, a real phone. Not seen in a real browser: harvest dialog timing, batch picker, quick turns, run-away buttons, Walk to the way on, Sell all crops, Hovel link, dock Take/Deliver/Rest/Fight, W-badge shop, event banners in the bell, Cat Fish rod upgrades, crew 06:00 pass.
- (2.7.x) Puzzle combat: no human play session; creature card on a phone; Almanac pages for 231 creatures; player-text / tone review; phone performance of 117+ rigs unmeasured.
- (2.7.x) Almanac `npc:<slug>` unlock keys unused; Sights balance untested; decor needs a real yard check; Treks: scenes, Thorny / Bramble, respec, Lanternroot crop, hats / stamp / trophy, trailmates 8, Snail Trail 3rd puzzle game.
- Flags `gnav_on`, `gnav_tree`, `gnav_tiles` default 0 (check Admin). Slim Home (`home_slim`) default off.
- Ideas: preset postcards, follow a friend's trail, seed lineage, satchel split stacks by quality, crop economy (`price_base_pct` 60 to 70), cPanel cron for reminder emails, /testvault/. SMTP untested live.

## C. Wearables / Closet open (2.7.x)
Nothing browser-tested (Closet, avatar art). Front cloak / pack art weak; outfitter staff have no portraits; Closet picker is a page reload; Pals tab and pre-fight screen can pack a worn piece; `tools/pfdemo_v1` + `tools/sims/tailor_sims_2701.php` use `src['wears']` (need `worn`); 1-7 worn pieces and Lined untested; `oc-flax-wading-wraps` -4.6 health; human playtest needed; non-slim My Gnome still shows Wearing panel.

## D. Art open
Method: `aseprite-source/v3/HANDOFF.md`, `claude/art-audit.md`, Hearth Pop / Stitched Toy. Delete `obj/lm-*.png` before re-baking.
- Trail ground + landmarks for 11 regions are stand-ins; trail depth-order: trees overdraw wide landmarks (305, 316, 309, 236); lair sleeper bright purple; taprow syrup thin; stop-look weak spots (coast market no quay, wetland / tundra animals small, rainforest tower roof).
- Seed icons may be missing (Lantern Fruit, Tiny Thank-You: installed 2026-11-18, check); weak items ginseng, stone-wall-end, tomato, stuffed-peppers-goat; weakest creatures blight-mother, wasp legs, leeches, basalt-borer, clam head; butterfly / moth villager faces, tortoise shell.
- Optional: wander-step-back, street / door animation, season variants, Cat Fish lane F, cheer pose, 2 glint-only popover scenes, more stat icons, per-villager doors, per-village pictures, town repaints, `map/` 16px tiles.

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
