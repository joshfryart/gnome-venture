# Gnome Venture: LIVE TO-DO (open items only; reviewed for stale 2026-11-26; main = 2.8.72). History: `claude/todo_history.md`

Rules: add new items here only. Tick or delete when done, and MOVE finished blocks to `claude/todo_history.md` (newest on top). STANDING RULE (Josh, 2026-11-05): after every change or release, update this file. Items marked (2.7.x) were carried from older lists and not re-verified: check before building.

## A. Owner picks / decisions waiting
- Stop art (owner marks 2026-11-26): REDO staged in art-review/stopart/out (icons, stamps, town place/route, shops-street, stoptiers polish); route cards also for popovers (`landmark_scene` fallback, landmarks.php:612). Owner 2026-11-26: keep the used Cut/Remove groups (stop-<type>, banner-*, villages, door/home/shop/resid); only unused banner-market and banner-village were deleted.
- Fair dock Enter: CUT by owner. "Visitor can smell it" reading (still-cooking dish vs last-cooked): ask.
- Rigs: 6 still old art (bramble-wolf, badger, giant-anteater, dust-sidewinder, gnat-cloud, dune-scorpion); 5 weak per reviewer (cistern-newt, ashen-ant, bellcap-beetle, ember-beetle, grub-beetle): keep or redo? `mini-<slug>.png` still old. 69 weaker pals: pick-list?
- Confirm on the live world: 8 base creature rows got region windows (boot step `creature_windows_2708`, code done); Hollow jar second-week sizing check; `sights_shared_on` is still OFF by default (Josh ticked it as reviewed; flip in Admin if wanted); `gnav_on` / `gnav_tree` / `gnav_tiles` / `home_slim` default OFF (check Admin).

## B. Code / bugs open
- W4 route-id offset bug (`roads.php` `lay_roads` + live-world renumber); gourmand nav tile double count; stale `trail_maps.json`; off-road pin clamp; `rl_trail_heading`.
- W2 residuals: hovel tabs under dock at 640x260, tour "Show me now" at 640x260, dock labels ~8px under 340px high. W3 shop / village card asks.
- DONE: crew wording now "They work every morning at 06:00." (pal_crew.php:135).
- Garden Count badge can lag under the sleep-days clock (raw growth); dock.js finds the Garden tile by label.
- `aseprite-source/v3/creature25/gen.lua` would overwrite swapped rigs: do not rerun blind.
- Tests failing on old code too: pbox_v1, puzzle_pals, gourmand (nav tile 2 vs 1), tea, guest, treks (+10.1 balance sim), pfparts48 (ci_suites only), pfv1_newfight (overlay blocks click). Also (2.7.x): market100, trail_bendy, pf_piece_text, npc25_wire. Flaky under load: sinks097, game_clock.sh, catfish, puzzle_pals, tour, roads, pfboard, pfdeck_v1. Do not add to `RETRY_SUITES` without telling Josh.
- Never run: MySQL (`upgrade_check.sh`), full CI on a phone-class check, a real phone. Not seen in a real browser: harvest dialog timing, batch picker, quick turns, run-away buttons, Walk to the way on, Sell all crops, Hovel link, dock Take/Deliver/Rest/Fight, W-badge shop, event banners in the bell, Cat Fish rod upgrades, crew 06:00 pass. Ideas: SMTP untested live, cPanel cron for reminders.
- (2.7.x) Puzzle combat: no human play session; creature card on a phone; Almanac pages for 231 creatures; player-text / tone review; phone performance of 117+ rigs unmeasured. Tests market100, trail_bendy, pf_piece_text, npc25_wire were fixed in 2.7.17 (todo_history): re-run to confirm.
- (2.7.x) Sights balance untested; decor needs a real yard check; Almanac `npc:` keys probably moot (migration removes them). Treks open: scenes Gloomtooth intro / Sorrel's door / signpost riddle, Thorny / Bramble, respec, Lanternroot crop, hats / stamp / trophy, Snail Trail 3rd puzzle game (Ch IV-VI and trailmate 8 struck).
- Garden dock badge: dock.js finds the Garden tile by label (`dock.js:774`); lag under the sleep-days clock not addressed.
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
