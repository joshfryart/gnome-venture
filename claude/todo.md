# Gnome Venture: MASTER TO-DO (one file; updated 2026-11-06, main = 2.5.96)

Rules: add new items here only. Tick or delete when done. History lives in `CHANGELOG.md` and `claude/todo-archive.md` (the old todo.md log up to 2.5.62 is at the bottom of the archive). Detail lists for art stay in their own files, linked below, but their OPEN items are copied here.

## 1. STATE
- Main = 2.5.96. Slim zips are in `releases/` (each needs the one before; 2.5.96 needs 2.5.95+). Trail ground art: `upload-zips/gnome-venture-trail-ground-partNof9.zip` through Admin > Images. Build: `bash tests/build_update.sh <v> <previous> $PWD/releases slim`.
- 2.5.90 to 2.5.96: authored maps for all 230 other routes (generated, stand-in art), Admin > Tools Trail maps check, ground pictures upload via Images, on-the-road bar removed, pals beside the gnome on maps and in fights, Trail fight menu = Fight / Item / Flee command column (Design C). Details in `claude/handoff.md`.
- 2.5.66: route landmarks (82 large hand-drawn sprites on all 16 Maplewold trail maps, path layer, contact shadows), GPS stops at every stop, no tap dots on trail maps.
- 2.5.68: build plans for all 94 havens/wonders/delves (58 new, text not yet reviewed by Josh); status-strip energy bar updates live.
- 2.5.67: Do here and Stall results show in the popover; header energy and Petals pills update live (icon kept, number only).
- 2.5.63 to 2.5.65 (art): 133 weak items redrawn, all 387 seeds are packets, 4 kind cards, scene fixes (camp flames, ferry dock, wild-trail trees, Snowcrown, turtle scutes, kava circle, banner-desert, trek-me, vig-pick), world + region maps richer, desert/adobe stop looks, hero-scale village/haven/delve/lair, Beaver Pond front, hedgehogs redrawn, gnome eye rim.
- 2.5.60 to 2.5.62: 81 wonders, 29 banners, gather small art, 14 journal emblems, 7 landing, 14 region maps, 46 trek tiles installed.
- Flags `gnav_on`, `gnav_tree`, `gnav_tiles` default 0 (check Admin before assuming).
- Release recipe: bump `APP_VERSION` in `game/includes/bootstrap.php`, CHANGELOG top entry = same, `tools/check_versions.sh`, `bash tests/build_update.sh <v> <two-back> releases`, art zip `upload-zips/gnome-venture-images-v3-<v>.zip`. Never rebuild a zip under the same version. Push main only on Josh's word.

## 2. JOSH: phone checks
- DONE 2026-11-06: Josh said "Phone checks done good". Treat everything previously listed here as PASSED: 2.5.90 to 2.5.96 (ground zips, new-region routes, pals, Fight / Item / Flee menu, no bar under banner), 2.5.81 to 2.5.89 fight scene, 2.5.72 (Do tab meters, perks, notice board, happenings, stories, Sneak/Hunt, workshop), 2.5.60 to 2.5.71 items, yard, Here pages, Maplewold tiles. Not itemised, so per-item "not phone-checked" notes in section 4 are now stale.
- DECIDED 2026-11-06: `fight_scene` ON by default (default flipped in `here_schema.php`, NOT yet released: needs a version bump + slim zip; a site with the setting already saved as 0 stays off). 3% fight rate confirmed OK.

## 3. JOSH: decisions needed
- DECIDED 2026-11-06: art uploads go through Admin > Images (never Update); the on-the-road bar and the fight bar are gone from other pages; the Trail fight menu is Design C and closes after every action; Puzzle Pals stand beside the gnome on maps and in fights.
- Open: trail fight menu list can cover the foe while open (accepted for now); stand-in set pieces and borrowed ground art (section 5) wait for art.
- Review the 58 new build plans (2.5.68) on the live site or in `build_plans.txt`.
- DECIDED 2026-11-05: upkeep: anyone can pay it, no one owes it; stop just degrades if not paid (see section 4). Tile walks: keep ~40% extra fights, add Sneak and Hunt buttons (section 4). Region maps: Josh sends real route maps (section 3 line below). Pet shops and Puzzles: already open, so lane E is unblocked.
- Stage art APPROVED 2026-11-05 (contact sheet). `derived-<land>/` files are byte-identical to `game/assets/img/scenes/`, so already installed; nothing to copy.
- DECIDED: craftmap 14 scenes: DRAW (not started). Acts: do not redraw all 1,667, keep stills, draw ~15 state props + 4 kind cards (see living-stops plan). Still open: P7 art order; 480x270 canvas final?
- Route maps for all 230 other routes are now GENERATED (tools/gen_trail_maps.py, claude/*-trail-maps/, baked into trail_maps.json, 22 wide, ART_LAND stand-ins, no landmark sprites). They are placeholder-quality layouts: Josh can replace any region with hand-made maps from claude/prompt-route-maps.md and re-bake with --route=N; every section now has a landmark slot with a STAND-IN sprite (claude/trail-landmarks/, claude/tile-art-v3-proposal/landmarks_setpieces.py); real art needed for 137 shared set pieces, see claude/trail-setpiece-art-notes.md.
- Admin upload `uploads/items/<slug>.png` shadows `assets/img/ph/` (reason an item can show old art).

## 4. CODE: open
**Trail / Here**
- Trail fight menu (2.5.96): `fight_dock_html()` + `fightscene.js` tap logic. TODO: dock for delve / wander maps; Flee confirm is "tap again"; if the list covers the foe, consider opening it upward only when there is room.
- Fight scene (2.5.81 to 2.5.89, setting `fight_scene`, default 0, Trail map only): engine `game/assets/fightengine.js/.css`, adapter `fightscene.js`, PHP `includes/fight_scene.php`, recorder `fight_ev*` in `includes/adventure.php`. Fights play over the real map where the gnome stands, dock under the map, health pills under feet, hat flag/pickup, end scene (XP/loot float over the gnome's head while he jumps, then sink in; map locked until done). Tests: suites `fight_events fight_scene fight_scene_trail trail_back` (run ONE AT A TIME, they clash on ports), `node tools/fight/smoke.js` (slow, ~3 min, alone). Plan `claude/fight-wiring-proposal.md`. NOT phone-checked.
  - TODO step 5: dock for delve / wander / list maps and other encounter types, then delete the popover code and `fighton.js`. Step 6: DONE (phone pass passed, default flipped to 1, unreleased).
  - TODO: KO and flee have no end scene (KO falls back to the old "Knocked out!" panel); reduced motion shows no loot drop (log line only); items with no art show 🎁; Milestone box and Almanac toast can cover the end scene; map camera not clamped at edges (empty green near column 0); more creature rigs.
- Trail random fights (2.5.88): flat chance per tile, setting `trail_enc_pct` (default 3%, rough ground x2.5, Sneak x0.4, Hunt x2.5, no cap per section, first/last 3 tiles safe). Josh confirmed 3% OK (2026-11-06). `balance_sim.php` Walks not updated.
- Trail walk back (2.5.87): "Back to section N" on the entry tile of section 2+; TODO: no Continue offered on the exit tile after going back (must step off and on); no way back from the final confirm 🚪; Trail only, not delve/wander.
- Known: `here` suite red on main (PHP warning `stops.php:327` Undefined array key "slug", from 2.5.80; seen from CLI calls, not tied to a page).
- Upkeep: stamp requirement removed (any gnome can chip in; `stop_upkeep_give`, `stop_slim_upkeep`); released 2.5.71, no test covers upkeep, not tried live.
- Workshop picture: round icons hidden (hotspots now `ghost` = invisible tap areas, `style.css` `.hs.ghost`); released 2.5.69, not phone-checked. Same icons may show on other picture pages (Here, treehouse, pal yard): ask Josh.
- Trail: yellow square round the walker's tile removed (`.tm-trail .tmt.here`), released 2.5.72, not phone-checked; delve/lair maps keep theirs.
- Trail ground and landmarks for the other 11 regions (loader exists; art is stand-ins).
- Shops/Homes popover on non-town stop types; step-off/step-back strip; Lost Letters + landmark panel on World page; gnome walk-frame animation (8 frames, idle only); nav chrome on other picture pages; `balance_sim` for `gnav_enter_energy`.
- Delve/lair run records: BUILT, released 2.5.71. New table `landmark_runs` (one row per run: cleared / ko / left, level, depth, stages, route seed, picked nodes, start and end), written by `landmark_run_record()` in `save_exp` before the map row is dropped; in `fresh_start` wipe list; test in `tests/delve2.sh`. No page shows it yet (admin or journal view?). `tests/landmarks.sh` fails here with a DB-open error unrelated to this change.
**Yard / garden**
- Designer: (corner pick already only for corner-shaped pieces: `isCorner()` guards every `cornerFor()` call in `site.js`, read in code, not tried on a phone); cover squares not recomputed live when a bed moves; planted soil for no-till beds; satchel `satchel_skin` column (canvas/patchwork).
**Content**
 - Build plans: all 94 havens/wonders/delves have plans (2.5.68, Josh not yet reviewed the text). Leftover build verbs (`befriend`, `carry`, `trial`, `vigil`, `wait`, `decorate`); Admin > Build plans page.
- Perk button (released 2.5.74): a round Perks button (medal) next to World in the row under the Here picture (`stop_perk_nav()`, card `hubpop-perks`, `stop_perk_body()`), shown once a meter has moved or a perk runs; the plain stop page (town.php) has a circle by the 🌍 in its trail (`stop_perk_chip()`). Not phone-checked.
- Stop acts: `claude/plan-living-stops.md`. CODE DONE, released 2.5.72, fixes 2.5.73 (UTC perk date, daily rotation of answer acts, perks stack): steps 2-4 and 6 (happenings, per-player meters + perk, needs/moves, calendar, 3 stories, notice board, Admin > Living stops read-only preview). Josh: finish code before art. Left: step 5 prop overlays + kind cards (ART, later); phone check; more happenings/stories/calendar rows (data files only); Admin editor is read-only (edit `data/stop_*.txt`).
- Road: toll/beat/weather kinds; picture per sketch page; collection pages. Region packs for other 11 regions; road_lines admin editor; village descriptions: FIXED, released 2.5.71 (each village = a blurb + a new quirk line from `village_quirks.txt`, fixed clash-free order; `tests/village_desc.php` checks 146 distinct; shows only where `village_blurb()` is used, i.e. the World page; stored text unchanged); stop chat: 22 lines added for the thin personalities (Generous, Grumpy, Shy, Proud, Curious, Chatty, Cheerful, Sleepy), released 2.5.71; Haven text (10 havens reworded in `landmarks.txt` + upgrade step `haven_text_2571` for existing sites; released 2.5.71, not tested on a real upgrade); tundra thin.
- Treks: scenes (Gloomtooth intro, Sorrel's door, signpost riddle); Ch IV to VI, Thorny/Bramble, respec, Lanternroot crop, hats/stamp/trophy, trailmates 8 (4-7 built).
- Delve redo: `delve_v2` built OFF (`claude/plan-delves.md`, `claude/checklist-delves.md`).
- Popover animation polish: 11 glint-only scenes (`bulk.py --report`); animate flags/water/foliage/sun; more icons than 7 stats.
- Snail Trail 3rd puzzle game; Jeff `tada` redo; guest-friendly treks.
- Ideas: preset postcards, follow a friend's trail, seed lineage, satchel split stacks by quality (then re-enable `orders_food_quality`), crop economy (radish sells ~4, seed 8-13; maybe `price_base_pct` 60 to 70), cPanel cron for reminder emails, /testvault/.
- How-to-play "Folk & friendship" title needs a guarded migration.
**Never run on this line:** MySQL `upgrade_check.sh`, full CI list, a real phone. Untested on MySQL: `trek_ms` table, `trek_flag_set` duplicate-insert catch.

## 5. ART: open
**New-region Trail routes (2.5.90)**
- Draw the 137 shared set pieces listed in `claude/trail-setpiece-art-notes.md` (stand-ins in `claude/tile-art-v3-proposal/landmarks_setpieces.py`; replace one by adding a `landmarks_<name>.py` with the same slug and deleting it from the stand-in file, then re-bake `--route=N`).
- Own ground art for desert, island, mountain, rainforest and wetland (borrowing coast / forest / tundra via `ART_LAND`).
**Trail landmarks (2.5.66 nits)**
- Wall trees overdraw sprite edges; tall 304/313 sprites hide a step of the walk; small details hard to read; 315 den feathers faint; 312 larder squirrel belly reads as shield; 311 syrup muddy.
- Rule: delete `obj/lm-*.png` before re-baking after editing sprites.
**Weak spots (re-check on the phone first; 2.5.63 to 2.5.65 redrew many)**
- Items still pink-bordered in `aseprite-source/v3/rollout/weak.txt` (46 of 179 left); `map-world` props; check gather flourishes on satchel backdrop; rainforest monstera/orchids, grassland windmill base, island palm crowns/coconuts, desert/island sand blotchy.
- Towns: coralscatter dome + tea house; monsoontangle deck/boats; thornacre arch; blossomreach parasol.
- Gnome rig eye contrast is fixed (2.5.64); seasons + hammer nav icons still roughest.
**Not drawn yet**
- P7: homes (6), tiers, village pictures, craftmap 14, 1,667 acts, landing `shot-*` (824x1120), `map/` 16px tiles.
- Animation layers `<art>-anim-*.png`, `wander-step-back.png`, workshop/street/door animation, season variants.
- Here scenes (~45 templates), residential street styles + houses, 6 door arts + per-villager doors, up to 151 villager 2.5D sprites (RULE: no human villagers), treehouse cutaway + dressing, pal sprites + Pal Yard, trail event icons 32x32. Plan: `claude/plan-graphical-nav.md`, `claude/todo-art-v3.md`.
- Stop looks for 11 more types (only market done and desert/adobe looks).
- Animal homes pre-v3; hand-polish procedural yard pieces (`tools/bake_*_art.py`); AI-1 paused: P1 weak items (46 left), P2 flower heads 19, P3 odd-size UI 41 (`claude/handoff-ai1-art.md`).
- Variety: before/after pictures for 9 pilot places; progress picture; stop header picture per adopt tier (`claude/todo-art-variety.md`).
- Cat Fish lane E (pet shops open, unblocked): 55 `cf-pet-<key>.png`, 11 banners `banner-<code>-pets`, 11 shopkeeper busts, `pet_slots` in `room-layout.json`, event props. Lane F: moving side-cat nap/bored, eye pixels on catch/nap frames (`claude/todo-art-catfish.md`).
- Method for AI art: `aseprite-source/v3/HANDOFF.md`, `ROLLOUT-STATE.md`; single Opus-medium pass per scene (see `claude/todo-art-v3.md` METHOD).

## 6. WATCH / SMALL
- Trek map: open-zone walls flat grey; long walks enter from phone-window edge. (Community garden / My stall tabs wrap to two lines on a phone: looks fine.) Travel card "via X" truncates at 390px.
- Friend watering duplicates garden water logic; nudge crops-ready approximate; SMTP untested live.
- Test noise: (`beds`, `stops100`, `social100` pass as of 2.5.68); `cook.sh` map checks stale; `games2.sh` no payout test; `walk.sh` "INSTALL FAILED" flake under parallel runs.
- Balance: week 1 ~8.5k earned vs ~7k sinks; days 1-3 flush; cosmetics have no level check; harvests ~73% of XP.

## 7. PARKED (Josh: not now)
Combat intent/Guard, KO cost on road fights, Inbox, test environment, growing villages, caravans, more festivals, Duck Pond animal.

## 8. WORKING NOTES
- STANDING RULE (Josh, 2026-11-05): after every change or release, update this todo.md, and handoff.md if needed, before ending the turn.
- Playwright test method: throwaway SQLite install (copy `game/`, delete `data/`, run `tests/walk.sh`, `php -S` with `tests/router.php`); unique `PORT_BASE` per suite run; session cookie `garden_sess`; touch drag via CDP `Input.dispatchTouchEvent`.
- Waves: writer subagent per region drafts into scratchpad, lint (`tools/lint_road_events.py`, `tools/lint_stop_acts.py`), merge, fix pack-count tests (`tests/roadlife.php`, `tests/roadkinds.php`).
- CSP: no inline styles. `choice_row()` escapes text: pass plain text. Anchors with `color: inherit` in felt cards: use `--gx-felt-ink`.
- Windows release builds: `build_update.sh` breaks on spaces, relative output dir, CRLF; use a space-free out dir.
- Branch hygiene: see `claude/branches.md`; do not clean old branches without asking.
- Icons: emoji are swapped for drawn icons by `ico_swap` (e.g. 🪙 shows as the petal). JS must not overwrite icon markup; change only text nodes.
