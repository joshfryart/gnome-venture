# Gnome Venture: to-do (updated 2026-10-21, after 2.0.23)

Built + LIVE and OK (Joshua uploaded 2026-10-21): **2.0.23** (emoji swapped for our own icons at render, 269 `ico-*` icons, Admin → Art & style guide PDF; see handoff Art). main = f33b6b6. Next version: 2.0.24 or higher (check bootstrap.php first).

## NEXT SESSION: start here (2026-10-21)
1. **Emoji second pass** (list below): `gvIco()` JS helper, 2 CSS `content:` emoji, unmapped Satchel/Book emoji, `npc_icon()` ignores the real `ph/npc-*.svg` portraits (26 call sites; shown as emoji directly) and `creature_icon()` (trek_fight.php, layout.php:432, landmarks.php:615, adventure.php:832), season/weather/daypart emoji (hollow_clock.php), yard decor tray icons: these print emoji straight, no art fallback. Fix = use the portrait/art when it exists.
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

Built: **2.0.20** (Knacks, whole-map fold, Ch III-a hidden, camps = full rest, friendship per fights; details in the 2.0.20 section below). Joshua: upload it.

Built: **2.0.19** (trek tap brake 400/5 min, news entry "Treks are open!"). Joshua: upload it, then Admin → Settings → "Treks: open" = on. News post goes out at upload even if you wait: set the switch right after. Watch the first days: Admin → Usage (treks row), error log.

Built: **2.0.18** (Treks phone play-test fixes: spot-text pop-overs, fight feed cap, obstacle bypass fixed, compact party cards, Ch II rest-site camp pop-over, Ch II sluices closer). Check on phone: walk to Burdock (cart now blocks: dig it), back out of a fight/duel and try to walk on (refused), Ch II oldcamps + Cushion Corner open the camp pop-over with free rest, sluice turn shows water change. DECIDED 2026-10-20: first cart dig keeps +8 fatigue (no change; free dig would make the Grit heave pointless; 8 is far under Tired 60 and Lantern Stump camp resets it); sluice text pass done in the next release (text pass 7; the freeze is lifted). Ideas: short CSS pulse on drained tiles; Clay Slide can skip the Shelf (left).

Built: **2.0.17** (picture-tile shops done: Curio, Dye Pot, festival stalls, haven pantry, village stalls). Check on phone: each opens a sheet, buy works, centred. Watch: CSP inline-style console error on town.php (pre-existing).

Built: **2.0.16** (II-b Fallen Shelf stop, road roll admin settings, Tumble lines pass 6, .tkfoelv CSS gone). Check: Admin → Settings → advanced "Road:" four weights; II-b shelf at the Dim (dc 11, camp kit). The II-b held list is DONE (Tumble brief fixed in the next release).

Live and OK (Joshua 2026-10-20): **2.0.15** (join card Trek Lv, foe level dropped, Juniper pot at nookB, Tumble own effect), 2.0.14, 2.0.13 desktop layout. Overdue Book "gap" was not real (Sorrel takes it in II-a).
II-b held items: ALL CLOSED. II-b skill-check stop, road roll settings, `.tkfoelv` CSS: done 2.0.16. Silverfin Sorrel line fixed 2.0.4. `thrum.harden` and the Tumble interlude are fine. Trailmates 4-6 are built; Wren is the 7th, in Ch III.


Built: **2.0.11** (camp pop-over; check on phone: Camp button opens it, Talk cycles, Rest runs, it reopens after the story pop-over, auto-open switch works; add `chN.banter.<crew>.3/.4` text slots for more Talk lines). Before: 2.0.10 (map camera follows the token while walking, Treks + delves; check on phone: no jump at the end of a walk). 

Built: **2.0.9** (all Treks story text as pop-over + Party-member-joined card + pop-up toggle). Before: 2.0.8 (talk pop-over + log under the map). Before: 2.0.7 (Treks text fixes + party-full note). Before: 2.0.6 (Phase 3: delve/lair maps; 2.0.5 = Phase 2: shop tiles, rewards wrapper, combat_math; 2.0.4 = Phase 1; 2.0.3 = Usage page) (slim needs 1.4.1+). Live: whatever Joshua last uploaded (1.9.1 migration verified live). Read `claude/handoff.md` first, history in `claude/changelog.md` (complete to 2.0.6). Treks: `claude/plan-treks.md`, `claude/trek-chapter1.md`, `claude/trek-chapter2.md`, `claude/trek-text-spec.md`, `claude/plan-trek-levels.md`.

**Standing orders (Joshua 2026-10-20):** Puzzles = ignore until he says. **Treks are OPEN (`trek_open` on) since 2.0.19, and the Treks text freeze is LIFTED** (text may be changed again; rows Joshua edited keep his words).

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
