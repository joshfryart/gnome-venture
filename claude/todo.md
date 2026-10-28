# Gnome Venture: to-do (updated 2026-10-28, after 2.0.75; everything below 2.0.68 is on main)

## ART: first pass of the 64 placeholders is DRAWN on branch `claude/art-first-pass` (not pushed; stage icons, 48 stop tiers, 11 folk; see `claude/todo-art-variety.md`). Act scenes: checklist of all 810 activities in `claude/todo-art-acts.md`. Still open below:
## ART FOR A FUTURE AI: one Aseprite scene per stop activity
Full brief in `claude/todo-art-variety.md` (section "ART TODO FOR A FUTURE AI"). Short version: draw `game/assets/img/acts/act-<slug>.png` (144x108) for every activity in `stop_acts*.txt` and every future wave; `python3 tools/missing_act_art.py` lists what is missing; no code change needed.

## VARIETY PROJECT (started 2.0.76): plan `claude/plan-variety.md`, art list `claude/todo-art-variety.md`
**2.0.76 built (build plans, pilot CA + CB; not yet released as a zip, not yet checked by Joshua).** Joshua checks: upload, then on phone take on a repair at e.g. Cenote of Echoes (needs the place in ruins: Admin > Places or wait for `ensure_ruins`; ruins are 1 in 3 by name, never in the start region NA) and walk the 4 stages: gather, clear (Work here today, 2 days), haul, gather + Petals. The five verb icons are PLACEHOLDER (red border): real art listed in `claude/todo-art-variety.md`.
**Decisions (Joshua):** building first, then stops, then road; plans hand-written per landmark; Worm Hunt / Snail Race are full games, NOT reused as step checks; 2 regions per release.
**2.0.77 built (themed adopt upgrades, 12 kinds x 4 tiers, regional materials, 48 themed acts, placeholder tier art in `assets/img/stoptiers/`).** Joshua checks: adopt a stop on the phone, read the upgrade list, hand in a regional material, see the themed rest at tier 1, Admin > Themed upgrades by kind of stop.
**2.0.78 built (stop act kinds craft/collect/tend/contest, `region` column, 14 pilot regional acts for NA + CA, kind-diversity rule, 4 placeholder cards).** Joshua checks: Do tab at a Maplewold or Maizehollow stop, open each new kind; Admin > Stop activities region field.
**Content waves DONE in 2.0.78:** 35+ plain activities for every stop kind, 35 regional for every region (810 activities in all, no repeats: `tools/dedupe_stop_acts.py`). Review pages: wave 1 approved, the other 691 on the review artifact (notes to apply next release). Joshua checks: a few rest stops in different regions; Admin > Stop activities (list is long: filter by Region/Kind).
**2.0.79 built (road card kinds fork/riddle/trade/chain/sketch, Road Journal, 48 pilot cards NA + CA, placeholder icons).** Joshua checks: walk a road in the Maplewold and Maizehollow, meet each kind; Town > Stop for the Road Journal; Admin > Road text lists the new cards. Next: road card waves for the other 12 regions (50 per wave, lint `tools/lint_road_events.py`, repeat check by eye + id/text), then toll/beat/sketch art, then the leftover build verbs.
**Old next list (after 2.0.78):** festival act kind, `cookalong`/`tune`/`teach` kinds, regional acts for the other 12 regions in the content waves (2 regions per release), then 2.0.79 road kinds. Old line: 2.0.78 stop act kinds + `region` column + kind-diversity; 2.0.79 road kinds + Road Journal; 2.0.80+ content waves of 2 regions (plans for the other 12 regions: MENA, ESA, WCA, SE, NWE, EE, CSA, EA, SEA, OC, SA, NA). Left over from 2.0.76: verbs `befriend` (landmark places have no stop folk yet: needs folk at landmarks), `carry`, `trial`, `vigil`, `wait`, `decorate`; an Admin > Build plans page (read-only list first); before/after pictures per place; plan tests for new regions are covered by the data lint in `tests/buildplans.sh`.

## NOW (2026-10-28, after 2.0.75): Joshua checks + what is next
**On main, not yet uploaded/checked by Joshua: 2.0.69 to 2.0.75** (slim zips in `releases/`, each needs 2.0.47+; upload the latest, 2.0.75 covers all). Back up first. Everything new is OFF for players until he flips a setting:
1. **Puzzles:** `puzzles_open` + `pz_barrel_open` (Rain Barrel) + `pz_beds_open` (Gnome Beds) in Admin > Game settings. Play a daily on phone light + dark: reward lands once (`pz_daily_petals` 15), hints +20s, board, sleep/oops Jeff beside status/errors. Look at the new tables on MySQL (`puzzle_runs`, `puzzle_wins`) and that `data/pzcache` is writable (Gnome Beds caches built gardens there).
2. **Front page (logged out, always on):** Jeff's tour with real screenshots, GIFsaw demo (`puzzles_front`, default on). Check on phone light + dark, desktop. Re-run `bash tests/shots.sh` after any look change to Garden/Satchel/World/Town/Games/Almanac pages (`tests/shots_stale.sh` fails after 12 releases).
3. **Guest gardens:** `guest_open` (default off). Play as a guest on phone (strip, blocked card, front-page button), register from a guest (garden kept, make-your-gnome step), Admin > Usage guest line, DB growth, idle purge (24h) on MySQL (`guest_purge` finds tables from information_schema: untested on MySQL).
4. GIFsaw: 2.0.68 checks still apply (GD for uploads, tournaments test with 2 accounts).
**Next candidates (Joshua picks):** Snail Trail (3rd puzzle game, plan `claude/plan-puzzle-games.md`: drag one trail through numbered stones, backbite generator; trio `pz_snail_*` in `includes/puzzle_games.php`, page, js, hub card flips from coming-soon automatically via `PUZZLE_GAMES`); redo Jeff `tada` (weak at 38px) and use `bye`; Jeff poses on more screens; guest-friendly treks (blocked in v1); delete uploaded GIF pictures; open Puzzles to players once checked; Seed Picross as a 4th game (needs small pixel pictures).
**Releases done this session:** 2.0.69 hub + GIFsaw move, 2.0.70 front-page puzzle demo, 2.0.71 Rain Barrel, 2.0.72 Gnome Beds, 2.0.73 Jeff tour + screenshot pipeline, 2.0.74 eight Jeff poses, 2.0.75 guest gardens. Plans/notes: `claude/plan-puzzle-games.md`, `claude/plan-guest-mode.md` (built), `claude/jeff-poses.md`.
**Working notes learned this session:** (a) test servers: kill stale `php -d session.save_path` servers before re-running suites (a leftover on a CI port gives phantom failures); (b) in bash test scripts `wait` must name PIDs (the php server is a child); (c) `ci_suites.sh walk` reports INSTALL FAILED (it installs first): run `bash tests/walk.sh` directly; (d) never `pkill -f` a pattern that appears in your own command; (e) `puzzle_games.php` needs `jobs.php` for `game_day()`; (f) PHP `.` binds tighter than `??`: parenthesise `($a ?? 'x')` inside concatenations; (g) Playwright needs `bypassCSP: true` to inject CSS and the theme toggle is hidden on phones (click via evaluate); (h) commit the Jeff/Aseprite WIP to the feature branch to satisfy the stop hook; (i) Joshua: "push main" = fast-forward `git push origin HEAD:main`, only on his word; zips go to `releases/` keep 4, archive the rest.

## 2.0.60 hardening release (Joshua to upload + test; still open)

Built from an external review. Done and on main: db_migrate index errors no longer silent; give_item rethrows non-duplicate errors (moved to includes/inventory.php); updater auto-maintenance lock + per-file rollback + hash check (tests/updrollback.sh); MIT LICENSE; SECURITY.md; version single source (tools/check_versions.sh); CI workflow; 21 stale suites repaired (all green run one at a time).

Joshua checks: upload 2.0.60 via Admin -> Update on a BACKED-UP live MySQL site (updater changes only apply to the NEXT update after this one, the old updater installs this release); open the Actions tab and fix the first CI run (MySQL job, PHP 8.1 leg, action versions never run); confirm upgrade shows no migrate errors in the error log.

Open from the review: `releases/` stays in git on purpose (Joshua's call); big files (garden.php, trek.php, bootstrap, functions) still to split incrementally (inventory.php is the first cut; next candidates: rewards, migrations); `treks` suite too slow for CI; suites share fixed /tmp files (use mktemp, then CI could parallelise); MySQL race test (12 parallel inserts) in tests/db_errors.php never run on real MySQL.

## Shipped since 2.0.60 (all on main, see CHANGELOG.md)
- **2.0.75** Guest gardens (`guest_open` default OFF; Joshua turns on after checking on phone). `includes/guest.php`, `includes/onboard.php`, `guest.php`, `customise.php`, `tests/guest.sh`. Joshua checks: back up, upload, set `guest_open` on, play as guest on phone (strip, blocked card, front-page button), register from a guest (garden kept, make-your-gnome step), watch Admin > Usage guest line and DB size. NEXT: Snail Trail, tada redo, more Jeff screens, guest-friendly treks later. 
- **2.0.74** (on main) 8 Jeff poses shipped (point, key, sleep, oops, gnomehat, water, snail, trophy) + wired (tour, closing card, Rain Barrel, Gnome Beds, tournament winner, Snail Trail card). Not shipped: tada (weak at 38px, redo), bye.
- **2.0.73** (on main) Jeff-the-Puzzler tour front page (logged out): 6 stops with real screenshots (`bash tests/shots.sh` regenerates; `tests/shots_stale.sh`; `tests/landing.sh`). Words editable: `home.jeff`, `home.tourbtn`, `home.tour.1..6`, `home.try`, `home.gate`. Old `assets/img/landing/*.png|svg` tiles now unused.
- **2.0.72** (on main) Gnome Beds (`gnomebeds.php`, `assets/gnomebeds.js`, `gb_*` in `includes/puzzle_games.php`, `data/pzcache`), shared `pz_run_*` helpers. Closed to players: `pz_beds_open`.
- **2.0.71** (on main) Rain Barrel + shared puzzle-game parts (`includes/puzzle_games.php`, `puzzle_game_api.php`, tables `puzzle_runs`/`puzzle_wins`). Closed to players: Joshua sets `pz_barrel_open` (and `puzzles_open`).
- **2.0.70** (on main) logged-out front page "Try a puzzle" GIFsaw demo (`puzzles_front`, default on; `includes/gifsaw_play.php` shared). Next: Rain Barrel becomes 2.0.71.
- **2.0.69** (on main) Puzzles hub + jigsaw moved to GIFsaw (`gifsaw.php`), 3 coming-soon cards.
- **2.0.68** (LIVE and OK, Joshua 2026-10-28) Puzzles rework: Jeff/Ffej/Old Wizard cast, `puzzle_pics` + Admin > Puzzles (Library / Upload / Tournaments), seeded scramble, tournaments (`puzzles_tournaments`, off by default). Joshua checks: upload a GIF on live (GD present?), turn it on, run a short test tournament with 2 accounts, check the cast art light/dark on phone, then decide whether to open Puzzles/tournaments to players. Open: real host `.htaccess` already serves `uploads/puzzles/*.gif|png` (images only); no delete for uploaded pictures yet; tournament times are entered in Hollow time. Cast art (16 images + dark versions, Jeff main) is polished once; tournament badges/trophy/tourney-banner have no dark version. Ideas: delete uploaded pictures, MySQL run of puzzles_tourney, more Jeff poses, redraw dark variants in Aseprite instead of tools/darken.py recolour, run new GIF uploads through the Aseprite process.
- **2.0.67** (Joshua to upload and check on phone if not yet) Gather satchel panel, mini-game removed, Do-tab and town felt cards, stage art by weather and time of day, Dye Pot shop art. Leftovers: see the 2.0.67 block in handoff.md.
- **2.0.66** GPS route card redesign (`dest_panel`, thread + pinned Set off) and trip strip on every page (`dest_strip_html`, `tests/tripstrip.sh`). **2.0.65** shared villager row (`villager_row_html`), 12 unique rest-stop scenes (`stop_art_file()`, generator `aseprite-source/scenes-pil/stops.py`), redrawn shop art (`shops.py`), felt-sign place headers, unique seed shop names (`SEED_SHOP_NAMES`), red `.newart` outline removed. Consolidation block below is essentially DONE: left = visual pass leftovers and the checks listed there.
- **2.0.64** pixel-art world + 14 region maps are the default (`map_style` only picks the fallback); fixed region layout `includes/region_layout.php` (dump: `tools/map_layout.php`); zoom controls above the map. **2.0.63** Treks Ch III open by default, Hush Bell fails open. **2.0.62** World Go right column 1600px+, header chips, 3-button switcher, main-stop Villagers = who is in town. **2.0.61** consolidation review build + puzzle stills/Motion button (`tests/puzzles.sh`, new `-still.png` per GIF via `tests/gen_puzzle_stills.py`).
- Joshua checks still open: 2.0.60 live upload (see below), then 2.0.61-2.0.64 on phone: World tabs Go/Map/Gather/Shops, Stop tab, place switcher, bottom bar "Here", region maps zoom, puzzles Motion.

## World / Town / Stops consolidation: SHIPPED (2.0.61-2.0.66); only leftovers below
Plan PDF: `docs/ui-consolidation-plan.pdf`. Files: `game/world.php`, `game/town.php`, `includes/place_ui.php`, `includes/local.php`, `includes/villagers.php`, `assets/style.css`.
**Joshua's decisions (2026-10-27):** main-stop Villagers = only who is in town now; "Here" top-level + phone bottom bar OK; Orders tab back in town (5th main-stop tab, "try it out"); stop-*/map-* art on place headers with RED OUTLINE (`.newart`, style.css ~5325) until he reviews; Mossbottom reachable from anywhere; no land purchasing at main stops (deeds village-only).
**Structure now:** World tabs Go, Map, Gather, Shops. Main stop tabs Square, Villagers, Shops, Orders, Stop. Rest stop tabs Do, Villagers, Stop. Helpers in `includes/place_ui.php`. Old `?t=`, `?view=`, `?tab=travel|seasons|here`, `?go=` URLs still land.
**Left:** (1) shared villager list: rest-stop (`stop_folk`) and main-stop (`$present`/`$homeIn`) lists still differ, errand forms post to town.php, villager panel to villagers.php: keep both working; (2) DONE 2.0.65: shared villager row and `.newart` outline removed; (3) visual pass leftovers (felt/stitch, light/dark, CSP no inline styles, desktop right column); (4) check links in index.php:126, shop.php:103, marketday.php:38 and the `$back` regex in gather.php; (5) run tests/scene_smoke, roads.sh, walk.sh, explore.sh (not run since 2.0.50) via `bash tests/ci_suites.sh <names>`; (6) release 2.0.65+, CHANGELOG, slim zip. Mockup to Joshua before big UI changes.

## Earlier: explore / road-walk layout rework (2.0.50 to 2.0.59)
Plan was reviewed by Opus; phases 1-4 are done. Joshua checks still open: tests/roads.sh, walk.sh, explore.sh not run; a road fight on his phone (fade once, stays out, comes back after); light theme; 10+ stop road; Snack picker / Auto-win rows in the tightened phone fight.
- 2.0.50: Joshua's web-update zip reconciled into git (a parallel take on the 2.0.49 mobile layout). 2.0.51: phase 1 CSS cleanup. 2.0.52: phases 2-3 (route ribbon = felt strip, Route fold, one route display, phone Journal shows newest line only). 2.0.53: phase 4 (Latest result inside the action card, World map link replaces the fold) + stale scene_smoke banner test fixed. 2.0.54: route info fades out in phone fights. 2.0.55: slimmer ribbon on phone. 2.0.56: tighter phone fight card/buttons. 2.0.57: fade plays once per fight (sessionStorage `gvRouteFaded`, class `rf-done`). 2.0.58: phone fight log = last round only. 2.0.59: compact "Show all" tag.
- Design chosen: mockup A (felt strip) with C's danger marker (thorn pin on the space where a fight waits). Mockups live in `mockups/route/` and `mockups/page/` (gitignored); Aseprite sources and Lua are in `aseprite-source/route-mockups/`; game sprites in `game/assets/img/route/`.
- Slim zip rule: build with `bash tests/build_update.sh <v> 2.0.47 /home/user/gnome-venture/releases` (absolute out dir; base manifest must exist, latest is 2.0.47). Zips go in `releases/` (keep latest 4 versions, rest to `releases/archive/`), NOT `upload-zips/` (that is for art).

### Next ideas (not started, ask Joshua)
1. The phone Journal peek repeats the Latest line (Latest now sits in the action card): drop the peek or the Latest strip on phones?
2. "After this stop..." arrival help text is still in the action card, not in the Route fold.
3. Phone fight: the ability / Fight on / Snack description lines are hidden; add a one-line version or a tap-for-info if he misses them.
4. Explore (hoop map), delve and lair pages still carry the old heading + status line; same ribbon treatment could follow (explore keeps the hoop).
5. Unused art: `assets/img/scenes/map-world*.png`, `map-*.png` regions and `stop-*.png` have no code using them; natural slot is rest-stop / destination scenes. Map art is an "ask Josh first" item.
6. Remaining CSS duplication on the adventure page: `.advgrid .encounter` max-width (3 places), `.advlatest` (3), 900-999px double layout, fight rules per breakpoint.

## Older notes (from 2026-10-21)

Built + shipped: **2.0.29** (logged-out homepage + How to play rework). Joshua: check on phone logged out; a logged-in Today page render and Firefox Android were not tested.

Built + shipped: **2.0.28** (art only: clap, party, watering-can, flatbread, boat, grain redrawn). Checked 2026-10-21 and closed: JS/CSS emoji leftovers (all mapped, only SVG pop text and `<option>` stay emoji); missing space after icon in summaries (fixed 2.0.25 with flex gap); town.php CSP console error does not reproduce (no inline styles left in source). Still weak, optional: path, dove, nav festival/friends/villagers/arranging at 24px, account on dark.

Built: **2.0.27** (docs + guide PDF only: `claude/art-style-guide.md` now exists, generated from `tests/guide_src/text.py`; no original Project doc was found, so there is nothing left to compare).

Built: **2.0.26** (ruler icon size fix + guide PDF rebuild; supersedes 2.0.25). The PDF Joshua uploaded 2026-10-21 is the 2.0.23 build and still carries the reconstructed art-rule text: the real `art-style-guide.md` is still needed to compare.

Built: **2.0.25** (Almanac real pictures, 4 new + 4 redrawn icons, summary icon spacing, stop-tint CSP fix; Joshua: upload; check on phone: Almanac tabs Plants/Flowers/Recipes/Creatures/Villages/Landmarks/Regions show pictures, heat weather chip, a rest stop page tints). Left on purpose: pest.js SVG pop text emoji (cannot hold an img), `<option>` emoji (sort labels), 🃏 on Seed Memory, colour-swatch squares, one-off emoji marked SKIP in ico_map_source.json. Still weak: party, bouquet (cones), dove, grain, boat, telescope, nav festival/friends/villagers/arranging at 24px. Trek foes (12 creatures) and cover crops (clover, rye) have no art in the Almanac yet. Art guide text vs Project doc: NOT compared (Projects doc not readable from this session; Joshua: paste `claude/art-style-guide.md` into the repo or the chat).

Built: **2.0.24** (JS/CSS emoji pass + creature art in duel/lair; Joshua: upload; check on phone: chest prize, Mushroom win, Pest chips, Spit gnome, harvest toast, duel + lair boss pictures). Remaining from the emoji list: season/weather/daypart emoji (hollow_clock.php) and yard decor tray print emoji (already swapped by the PHP pass, no art fallback), unmapped Satchel/Book emoji, composer toolbar 🔗/🖼, Pest pop text. NPC portraits for `npc_icon()`: DECIDED not worth it (portraits 400x500 per NPC, sites are species text).

Built + LIVE and OK (Joshua uploaded 2026-10-21): **2.0.23** (emoji swapped for our own icons at render, 269 `ico-*` icons, Admin → Art & style guide PDF; see handoff Art). main = f33b6b6. Next version: 2.0.24 or higher (check bootstrap.php first).

## NEXT SESSION: start here (2026-10-21)
1. **DONE in 2.0.24 except the leftovers named at the top.** Emoji second pass (old list below): `gvIco()` JS helper, 2 CSS `content:` emoji, unmapped Satchel/Book emoji, `npc_icon()` ignores the real `ph/npc-*.svg` portraits (26 call sites; shown as emoji directly) and `creature_icon()` (trek_fight.php, layout.php:432, landmarks.php:615, adventure.php:832), season/weather/daypart emoji (hollow_clock.php), yard decor tray icons: these print emoji straight, no art fallback. Fix = use the portrait/art when it exists.
2. **Weak icons to redraw when time allows** (Opus rounds 1-3; none misleading now): clap (can read as bread at 24px), path (egg-shaped mound), flatbread (looks like a cookie), pancakes (boxy), party and bouquet (both cones), watering-can (looks like a kettle), dove (cream wing relies on outline on light), grain, boat, telescope (small at 16px). Withheld on purpose: prayer, handshake (`WITHHOLD` in tests/ico_build.py). Nav icons at 24px: festival, friends, villagers, arranging are mush; account is low contrast on dark; ember-beetle eyes hard to read (large placeholders).
3. **Joshua checks still open:** Satchel/Book pages for stray emoji; `/assets/guides/` must be blocked by .htaccess (PHP built-in server ignored it in tests); Admin → Art & style guide downloads.
4. Small known bugs: pre-existing CSP "refused inline style" console error on town.php (also with swap off, not found yet); two headings lack a space after the icon ("Other times here" on town, "Seasons & weather:" on world; the space is missing in the PHP).
5. The guide PDF's art-rule text was RECONSTRUCTED from tests/hearth.py (the subagent could not read the Project doc). Compare with Project `claude/art-style-guide.md` and edit `tests/guide_src/text.py`, then `python3 tests/build_guide.py`. The Project doc itself lacks the new `ico-` section (halo 6.0u / outline 3.4u, 16-24px, plain sources in tests/ico_src, `tests/ico_build.py`): add it or point to the PDF.
6. Sizes: ph set is 265% of the old size (3.3 MB) and the PDF 3.5 MB: fine, watch only.

### Working notes learned 2026-10-21 (for the next Claude)
- Subagents may not have the Projects tool: they cannot read Project docs; give them what they need in the prompt or have them read repo files. The lead (this chat) can read Project docs.
- The stop hook "no remote branch / N unpushed" can be stale: verify with `git ls-remote --heads origin <branch>` against `git rev-parse HEAD` before assuming a push failed. Uncommitted files while agents run = WIP; commit WIP only on feature branches (never on main).
- The auto-mode classifier denied pushing a release to main until Joshua said "Ship". Ask for an explicit go before merging/pushing main; feature branches are fine.
- Start the work in the SAME turn you announce it (ending a turn after "building X" wastes hours; Joshua scolded this).
- Never `pkill -f` a pattern that matches your own shell.
- Version drift: another session shipped 2.0.21 (security) while this one worked. Always `git fetch` and read APP_VERSION before bumping.
- Icon pipeline: draw plain SVG (viewBox 64, no halo) in tests/ico_src/ico-<slug>.svg, `PYTHONHASHSEED=1 python3 tests/ico_build.py restyle` (never for a single slug in parallel runs: use the gen_ico_fix_*.py pattern), add a row in tests/ico_map_source.json, `python3 tests/ico_map_build.py`, `python3 tests/build_guide.py`. Review sheets: scratchpad sheet.py (SVGDIR PREFIX COLS). Opus reviews the 16/24px sheets before shipping.


## Emoji leftovers (2.0.23 swap is PHP-only; JS/CSS second pass is NEXT)
- Add `gvIco(slug)` helper to `site.js` (loaded on every page; other files call it if present; base path via a data attribute on body from layout.php). Only innerHTML sinks can take an img; textContent/alert/confirm/title stay emoji.
- 10 JS files: chest.js (44,45), fighton.js (7,41,84), gather-games.js (14 lines), mushroom.js 106, pest.js (662,750), puzzles.js 463, spit.js (142,153), site.js (33 lines: menu toggle, toasts, composer toolbar, pickers; biggest win), tilemap.js 143, trekfight.js (7 lines), trekscene.js (129,187). Plain symbols (arrows, check, cross) stay.
- style.css `content:` emoji: ~line 1337 `.yard.editing .tile.fixed::after` pin -> background-image ico-pushpin; ~line 2620 `.memboard .card.matched .pk::after` leaf -> ico-leaf. Check-glyph contents are text symbols: leave.
- Unmapped emoji (still emoji): in Satchel/Book 📦 🔤 🪱 🧰 and others; find with the list from `php tests/emoji_icons.php game`. Add icons via handoff Art recipe.
- `<option>` and `<title>` emoji stay (cannot hold an img).
- Full detail: scratchpad `ico/js_css_leftovers.md` (session file, may be gone).

Built: **2.0.22** (art only: all placeholder SVGs Hearthlight-restyled; new placeholders need the restyle pass last, see handoff Art line). Optional polish: ember-beetle eyes hard to read; nav festival/friends/villagers/arranging mush at 24px; nav account low contrast on dark.

Built: **2.0.30** (Ch III-b "The Knock Below", hidden like III-a; merged onto main 2.0.29). `trek_chapters_open` 3 opens ALL of Ch III (a + b) at once: there is no separate III-b switch.
- Joshua decides: (1) Holler numbers: two sim runs median 86.0 / 85.7, worst 70.7 / 74.7, best ~99; zone means 87-91, worst single parties 62-80 (real dice swing). OK? (2) Hush Bell has no failopen (fail twice = no bell); fallback is 3 Bellcap Beetle kills in the Gallery give the clapper. Keep, or make the bell failopen? (3) Play-test III-a + III-b on phone as admin (Lodge Camp Talk, Hush Bell, Mere Wheel, Holler fight card, finish screen). (4) When to set `trek_chapters_open` 3 (then add a news entry).
- Art later: npc-pip-dustwing, items warden-scute / echo-stone / bell-clapper (emoji fallback now).

Built: **2.0.20** (Knacks, whole-map fold, Ch III-a hidden, camps = full rest, friendship per fights; details in the 2.0.20 section below). Joshua: upload it.

Built: **2.0.19** (trek tap brake 400/5 min, news entry "Treks are open!"). Joshua: upload it, then Admin → Settings → "Treks: open" = on. News post goes out at upload even if you wait: set the switch right after. Watch the first days: Admin → Usage (treks row), error log.

Built: **2.0.18** (Treks phone play-test fixes: spot-text pop-overs, fight feed cap, obstacle bypass fixed, compact party cards, Ch II rest-site camp pop-over, Ch II sluices closer). Check on phone: walk to Burdock (cart now blocks: dig it), back out of a fight/duel and try to walk on (refused), Ch II oldcamps + Cushion Corner open the camp pop-over with free rest, sluice turn shows water change. DECIDED 2026-10-20: first cart dig keeps +8 fatigue (no change; free dig would make the Grit heave pointless; 8 is far under Tired 60 and Lantern Stump camp resets it); sluice text pass done in the next release (text pass 7; the freeze is lifted). Ideas: short CSS pulse on drained tiles; Clay Slide can skip the Shelf (left).

Built: **2.0.17** (picture-tile shops done: Curio, Dye Pot, festival stalls, haven pantry, village stalls). Check on phone: each opens a sheet, buy works, centred. Watch: CSP inline-style console error on town.php (pre-existing).

Built: **2.0.16** (II-b Fallen Shelf stop, road roll admin settings, Tumble lines pass 6, .tkfoelv CSS gone). Check: Admin → Settings → advanced "Road:" four weights; II-b shelf at the Dim (dc 11, camp kit). The II-b held list is DONE (Tumble brief fixed in the next release).

Live and OK (Joshua 2026-10-20): **2.0.15** (join card Trek Lv, foe level dropped, Juniper pot at nookB, Tumble own effect), 2.0.14, 2.0.13 desktop layout. Overdue Book "gap" was not real (Sorrel takes it in II-a).
II-b held items: ALL CLOSED. II-b skill-check stop, road roll settings, `.tkfoelv` CSS: done 2.0.16. Silverfin Sorrel line fixed 2.0.4. `thrum.harden` and the Tumble interlude are fine. Trailmates 4-6 are built; Wren is the 7th, in Ch III.


Built: **2.0.11** (camp pop-over; check on phone: Camp button opens it, Talk cycles, Rest runs, it reopens after the story pop-over, auto-open switch works; add `chN.banter.<crew>.3/.4` text slots for more Talk lines). Before: 2.0.10 (map camera follows the token while walking, Treks + delves; check on phone: no jump at the end of a walk). 

Built: **2.0.9** (all Treks story text as pop-over + Party-member-joined card + pop-up toggle). Before: 2.0.8 (talk pop-over + log under the map). Before: 2.0.7 (Treks text fixes + party-full note). Before: 2.0.6 (Phase 3: delve/lair maps; 2.0.5 = Phase 2: shop tiles, rewards wrapper, combat_math; 2.0.4 = Phase 1; 2.0.3 = Usage page) (slim needs 1.4.1+). Live: whatever Joshua last uploaded (1.9.1 migration verified live). Read `claude/handoff.md` first, history in `claude/changelog.md` (complete to 2.0.6). Treks: `claude/plan-treks.md`, `claude/trek-chapter1.md`, `claude/trek-chapter2.md`, `claude/trek-text-spec.md`, `claude/plan-trek-levels.md`.

**Standing orders (Joshua 2026-10-20):** ~~Puzzles = ignore until he says~~ (lifted 2026-10-28: Joshua asked for GIFsaw, the new games, Jeff and guest mode). **Treks are OPEN (`trek_open` on) since 2.0.19, and the Treks text freeze is LIFTED** (text may be changed again; rows Joshua edited keep his words).

## 2.0.12 (built 2026-10-20, branch trek-fight-touches)
- Check on phone as admin: start a fight by walking: "!" over the gnome, then one pop-over with all foes side by side; hit shake / −N numbers in Fight round, Auto 1, plan-each-turn, Auto replay. Does the 2-foe pop-over feel too long (~2.2 s)? Is the map block "Where it began" good or too tall?
- Idea parked: fight as a bottom sheet over the map (phone: map top 35%). Cost ~1 release, medium risk; needs all other dialogs converted to modal. Decide after the phone test.
- Not tested live: creature pictures in the pop-over (only emoji in tests). Last foe KO fade only in Auto replay.
- Fable text review: Ch I + II-a work. Fixed 7 of 8 issues. Left: ch2.spot.crossroads.locked is unreachable (leave).

## 2.0.13 desktop fight layout: BUILT (see claude/plan-trek-desktop-layout.md)
- Desktop map screen: log + Sneak/Camp/Leave under the map; fight screen keeps the inert map left and cross-fades the right column to the fight panel and back. Waiting for Joshua's "go" after the 2.0.12 phone test. One Sonnet task + Opus review.

## 2.0.20 (Opus review 2026-10-20)
- Shipped: Knacks (11 slots to Lv22, minor/major sidegrades, change filled slots at camp/hub), trek level cap 23, Whole map fold, friendship +1 per 20 won fights (cap `trek_friend_daily` 3/day), Ch II first-fight lesson, text pass 7, Drum Door label, feed keeps last lines. Ch III-a built but HIDDEN (`trek_chapters_open` 2; admins bypass).
- Balance watch: camps are now full rest (kits + old camps stronger). Levers: `trek_oldcamp_ambush_pct`, `trek_campkit_price`.
- Joshua checks (phone): Party tab knack selects (pick, Save, change at camp only), Whole map fold under the map, a 20th won fight shows "X likes you a little more", Ch II sluice lines.
- Joshua decides: Old Gneiss median ~90 (target 78-88; worst 72, best 98); knack numbers (sims: builds add +7 to +9 avg win on Pinch/Thrum, test limit 8); knacks at Lv22 = 11 select rows (~800px on phone: fold?); Mushroom Camp beetle shells (pack first?); Lanternroot crop; when to set `trek_chapters_open` 3.

## Now: Joshua
0. Treks are open (`trek_open` on since 2.0.19). Watch Admin → Usage (treks row), the error log, and players' first runs.
1. Upload **2.0.20** (covers 2.0.19; adds text pass 7: sluice lines name the water and clay layer, Ch II stash/shrine lines, Drum Door says "Open the door"). Rows you edited keep your words. Then play Ch III-a as admin on phone (hidden from players).
2. Get players (slow going). Read Admin → Retention and Admin → Usage after a week or two: they decide the gated cuts.
3. Art in progress (Admin → Images).
- Email: Joshua says OK, drop it.

### Joshua decides
- **Mushroom Camp beetle shells:** should Mushroom Camp take them from the pack first, then the Satchel? (~10 lines in `trek_events.php` `trek_act_mush`.)
- **Lanternroot as a real crop:** the seed exists; the crop is not built.

## Plan 2026-10-20: see claude/plan-consolidation.md (Phase 0 usage page 2.0.3, Phase 1 2.0.4; next: read Admin → Usage; gated cuts wait for the numbers; Phase 3 done in 2.0.6; NEXT: read Admin → Usage, decision gate on maps (roads strip/town hub only if delve maps get played), gated cuts, more picture-tile shops (Curio/Dye Pot, festival, pantry, local))

## Explore: next (from `claude/explore-review.md`; 1-5, 7, 10 done)
- Region packs for the other 11 regions. 6 traces of other players, 9 festival/goal chips, 11 calling/animal lines, 12 delve room text, 8 Tales.
- Also: road_lines admin editor (draft status like trek text); 146 villages share 9 descriptions; 4 stop personalities lack chat lines; Haven text promises shops that don't exist; tundra thin.

## Treks: next
- Scenes next: Gloomtooth intro, Sorrel's door, signpost riddle as pop-overs (need speaker-tagged text); gnome reply lines are drafts.
- II-b watch: only 2 new crew moments. Road data files have no admin editor (road roll % settings done 2.0.16).
- Not built: Ch III-b to VI, Thorny/Bramble, respec, Lanternroot real crop, hats/stamp/trophy, trailmates 8 (4-7 built).

## Treks: done in 2.0.1 (decided 2026-10-18)
- Party wall fixed (all 20 parties 76–95%). Watch: Silverfin Lv11 93–99% (above 92 target), Bu+Zi+Br Silverfin Lv10 74.5%.
- Riddles 2 tries; orphan slots shown; trek_items_daily setting (off); old campsites + KO checkpoint; Bracken OK.
- Still open: no rate limit on trek POSTs (low). Crossroads locked text only reachable by unusual paths.
## Next (ideas, Joshua picks)
- No-typing social: preset postcards; follow a friend's trail; seed lineage.
- How-to-play "Folk & friendship" title still says Folk (title is DB key in ensure_almanac_howto; needs guarded migration).
- Satchel split stacks by quality; then turn `orders_food_quality` back on.
- Crops lose money on bought seed (radish sells ~4, seed 8-13). Look at seed price / yield / sell %. Quick option: `price_base_pct` 60 → 70.
- Later: cPanel cron for reminder emails; test site /testvault/ (code ready, skipped).

## Small / watch
- `walk_scene` row is deleted when a delve ends, so delve completion is not recorded anywhere; the plan's gate after the maps has no data source until a count is added (Usage has no map line).
- Trek map: open-zone walls flat grey; long walks enter from phone-window edge.
- "Community garden" tab wraps on phone. Sign/skin Buy buttons small.
- Friend watering duplicates garden water logic. Nudge crops-ready approximate; SMTP untested live.
- Seasons + hammer nav icons roughest.
- Travel card "via X" truncates at 390px with long names.
- Test noise: social100 2 FAIL on pristine (mid-tour); cook.sh map checks stale; games2.sh doesn't test payouts; walk.sh "INSTALL FAILED" flake under parallel runs.
- Balance (audit 2026-10-17): week 1 ~8.5k earned vs ~7k sinks (mild). Days 1-3 flush. Cosmetics no level check. Harvests ~73% of XP.
- MySQL watch: trek_ms table (1.8.9, untested on MySQL), trek_flag_set duplicate-insert catch on InnoDB.

## Parked (Joshua said not now)
- Combat intent/Guard, KO cost on road fights. Inbox. Test environment.
- Growing villages · caravans · more festivals · Duck Pond animal.

## Art
- Placeholders game/assets/img/ph/*.svg, palette ph/palette.json, guide = "Gnome Venture Art Guide" artifact.
- Names: `{item-slug}`, `creature-{slug}`, `npc-{slug}` (400×500), `{building}-{1..3}`, `{building}-{mossy|painted|lantern}`, `{fence}-{end|straight|corner|tee|cross|gate}`, `tile-{...}`, `stage-{kind}-{1..4}`, `land-{...}`, `banner-{code}`, `hat-{calling}`, `lm-{haven|wonder|delve|lair}`, `logo`, `nav-{gnome|almanac|satchel|crafting|garden|arranging|world|town|villagers|seasons|passport|games|trading|together|tasks|friends|account|today|festival|start|feedback|treks}`.
- Trek art needed: creature-{slug} for trek creatures (Ch I + Ch II incl. Silverfin), npc for Sorrel Inkcap + innkeeper (name TBD).
