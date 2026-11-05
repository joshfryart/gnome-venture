# Gnome Venture: MASTER TO-DO (one file; updated 2026-11-05, main = 2.5.70)

Rules: add new items here only. Tick or delete when done. History lives in `CHANGELOG.md` and `claude/todo-archive.md` (the old todo.md log up to 2.5.62 is at the bottom of the archive). Detail lists for art stay in their own files, linked below, but their OPEN items are copied here.

## 1. STATE
- Main = 2.5.70. Slim zips are in `releases/` (2.5.70 needs 2.5.68+; 2.5.69 needs 2.5.67+; 2.5.68 needs 2.5.66+; 2.5.67 needs 2.5.65+). Art zips in `upload-zips/` (none for 2.5.67). Josh uploads.
- 2.5.66: route landmarks (82 large hand-drawn sprites on all 16 Maplewold trail maps, path layer, contact shadows), GPS stops at every stop, no tap dots on trail maps.
- 2.5.68: build plans for all 94 havens/wonders/delves (58 new, text not yet reviewed by Josh); status-strip energy bar updates live.
- 2.5.67: Do here and Stall results show in the popover; header energy and Petals pills update live (icon kept, number only).
- 2.5.63 to 2.5.65 (art): 133 weak items redrawn, all 387 seeds are packets, 4 kind cards, scene fixes (camp flames, ferry dock, wild-trail trees, Snowcrown, turtle scutes, kava circle, banner-desert, trek-me, vig-pick), world + region maps richer, desert/adobe stop looks, hero-scale village/haven/delve/lair, Beaver Pond front, hedgehogs redrawn, gnome eye rim.
- 2.5.60 to 2.5.62: 81 wonders, 29 banners, gather small art, 14 journal emblems, 7 landing, 14 region maps, 46 trek tiles installed.
- Flags `gnav_on`, `gnav_tree`, `gnav_tiles` default 0 (check Admin before assuming).
- Release recipe: bump `APP_VERSION` in `game/includes/bootstrap.php`, CHANGELOG top entry = same, `tools/check_versions.sh`, `bash tests/build_update.sh <v> <two-back> releases`, art zip `upload-zips/gnome-venture-images-v3-<v>.zip`. Never rebuild a zip under the same version. Push main only on Josh's word.

## 2. JOSH: phone checks
- Josh said "everything live seems fine" (2026-11-05). Not itemised, so the list below stays until he ticks specifics; treat 2.5.66 and 2.5.67 as passed.
- Trail landmarks 2.5.66 (all 16 routes), GPS auto-stop, hidden dots; Do here popover results + live header pills 2.5.67.
- Trail walk camera; select bar; Rest stop card (tabs, stamp, adopt non-maxed stop, hand-in, upkeep, buy deed); new doors/streets/workshop pictures.
- 2.5.60 to 2.5.62 art: wonders, banners, gather art, journal, landing, region maps, trek tiles.
- Yard: corner pieces, paths vs beds, wet beds in rain, visitor thirst, crop sizes, ripe pictures, designer Shape/Size.
- Here pages (stall/pantry popovers, icon row), Pal Jobs Select all, garden select bar in LIGHT theme.
- Maplewold trail tiles; Do here names; folk line; Villagers highlight.

## 3. JOSH: decisions needed
- Review the 58 new build plans (2.5.68) on the live site or in `build_plans.txt`.
- DECIDED 2026-11-05: upkeep: anyone can pay it, no one owes it; stop just degrades if not paid (see section 4). Tile walks: keep ~40% extra fights, add Sneak and Hunt buttons (section 4). Region maps: Josh sends real route maps (section 3 line below). Pet shops and Puzzles: already open, so lane E is unblocked.
- Stage art APPROVED 2026-11-05 (contact sheet). `derived-<land>/` files are byte-identical to `game/assets/img/scenes/`, so already installed; nothing to copy.
- P7 art order; craftmap 14 scenes skip?; redraw all 1,667 acts or only used; 480x270 canvas final?
- Josh to send real route maps for the other 11 regions (`claude/prompt-route-maps.md`, `claude/route-list.md`); stand-ins (`ART_LAND`) stay until then.
- Admin upload `uploads/items/<slug>.png` shadows `assets/img/ph/` (reason an item can show old art).

## 4. CODE: open
**Trail / Here**
- Tile walks Sneak/Hunt buttons released 2.5.70: stance on the trail footer, Sneak = 40% fight chance, Hunt = 250% and up to 3 fights a section; tap again to go back to normal. Josh to confirm numbers; `balance_sim.php` Walks not updated for stances.
- Upkeep: stamp requirement removed (any gnome can chip in; `stop_upkeep_give`, `stop_slim_upkeep`); UNRELEASED (branch only), no test covers upkeep, not tried live.
- Workshop picture: round icons hidden (hotspots now `ghost` = invisible tap areas, `style.css` `.hs.ghost`); released 2.5.69, not phone-checked. Same icons may show on other picture pages (Here, treehouse, pal yard): ask Josh.
- Trail ground and landmarks for the other 11 regions (loader exists; art is stand-ins).
- Shops/Homes popover on non-town stop types; step-off/step-back strip; Lost Letters + landmark panel on World page; gnome walk-frame animation (8 frames, idle only); nav chrome on other picture pages; `balance_sim` for `gnav_enter_energy`.
- `walk_scene` row deleted when a delve ends, so no delve-completion record.
**Yard / garden**
- Designer: corner pick only for corner-shaped pieces; cover squares not recomputed live when a bed moves; planted soil for no-till beds; satchel `satchel_skin` column (canvas/patchwork).
**Content**
 - Build plans: all 94 havens/wonders/delves have plans (2.5.68, Josh not yet reviewed the text). Leftover build verbs (`befriend`, `carry`, `trial`, `vigil`, `wait`, `decorate`); Admin > Build plans page.
- Stop acts: `cookalong`/`tune`/`teach`/festival kinds; apply review notes for 691 acts.
- Road: toll/beat/weather kinds; picture per sketch page; collection pages. Region packs for other 11 regions; road_lines admin editor; 146 villages share 9 descriptions; 4 stop personalities lack chat lines; Haven text promises shops that don't exist; tundra thin.
- Treks: scenes (Gloomtooth intro, Sorrel's door, signpost riddle); Ch IV to VI, Thorny/Bramble, respec, Lanternroot crop, hats/stamp/trophy, trailmates 8 (4-7 built).
- Delve redo: `delve_v2` built OFF (`claude/plan-delves.md`, `claude/checklist-delves.md`).
- Popover animation polish: 11 glint-only scenes (`bulk.py --report`); animate flags/water/foliage/sun; more icons than 7 stats.
- Snail Trail 3rd puzzle game; Jeff `tada` redo; guest-friendly treks.
- Ideas: preset postcards, follow a friend's trail, seed lineage, satchel split stacks by quality (then re-enable `orders_food_quality`), crop economy (radish sells ~4, seed 8-13; maybe `price_base_pct` 60 to 70), cPanel cron for reminder emails, /testvault/.
- How-to-play "Folk & friendship" title needs a guarded migration.
**Never run on this line:** MySQL `upgrade_check.sh`, full CI list, a real phone. Untested on MySQL: `trek_ms` table, `trek_flag_set` duplicate-insert catch.

## 5. ART: open
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
