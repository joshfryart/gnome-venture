# Gnome Venture: to-do (updated 2026-10-20, after 2.0.18)

Built: **2.0.18** (Treks phone play-test fixes: spot-text pop-overs, fight feed cap, obstacle bypass fixed, compact party cards, Ch II rest-site camp pop-over, Ch II sluices closer). Check on phone: walk to Burdock (cart now blocks: dig it), back out of a fight/duel and try to walk on (refused), Ch II oldcamps + Cushion Corner open the camp pop-over with free rest, sluice turn shows water change. Ideas: no fatigue on the first cart dig; one-time text pass for the sluice lines; short CSS pulse on drained tiles; Clay Slide can skip the Shelf (left).

Built: **2.0.17** (picture-tile shops done: Curio, Dye Pot, festival stalls, haven pantry, village stalls). Check on phone: each opens a sheet, buy works, centred. Watch: CSP inline-style console error on town.php (pre-existing). The "NEXT UP picture tiles" list below is DONE.

Built: **2.0.16** (II-b Fallen Shelf stop, road roll admin settings, Tumble lines pass 6, .tkfoelv CSS gone). Check: Admin → Settings → advanced "Road:" four weights; II-b shelf at the Dim (dc 11, camp kit). The "II-b held" list below is DONE except the Tumble brief note.

Live and OK (Joshua 2026-10-20): **2.0.15** (join card Trek Lv, foe level dropped, Juniper pot at nookB, Tumble own effect), 2.0.14, 2.0.13 desktop layout. Overdue Book "gap" was not real (Sorrel takes it in II-a).
II-b held until Joshua plays it: one skill-check stop (cart) in II-b; road roll % settings (~25 lines); Tumble talk lines reword; stale `.tkfoelv` CSS.


Built: **2.0.11** (camp pop-over; check on phone: Camp button opens it, Talk cycles, Rest runs, it reopens after the story pop-over, auto-open switch works; add `chN.banter.<crew>.3/.4` text slots for more Talk lines). Before: 2.0.10 (map camera follows the token while walking, Treks + delves; check on phone: no jump at the end of a walk). Upload it instead of 2.0.9.

Built: **2.0.9** (all Treks story text as pop-over + Party-member-joined card + pop-up toggle). Before: 2.0.8 (talk pop-over + log under the map). Before: 2.0.7 (Treks text fixes + party-full note). Before: 2.0.6 (Phase 3: delve/lair maps; 2.0.5 = Phase 2: shop tiles, rewards wrapper, combat_math; 2.0.4 = Phase 1; 2.0.3 = Usage page) (slim needs 1.4.1+). Live: whatever Joshua last uploaded (1.9.1 migration verified live). Read `claude/handoff.md` first, history in `claude/changelog.md` (complete to 2.0.6). Treks: `claude/plan-treks.md`, `claude/trek-chapter1.md`, `claude/trek-chapter2.md`, `claude/trek-text-spec.md`, `claude/plan-trek-levels.md`.

**Standing orders (Joshua 2026-10-20):** Puzzles = ignore until he says. Treks stay admin-only and their text stays as it is until he has played through it.

## 2.0.12 (built 2026-10-20, branch trek-fight-touches)
- Check on phone as admin: start a fight by walking: "!" over the gnome, then one pop-over with all foes side by side; hit shake / −N numbers in Fight round, Auto 1, plan-each-turn, Auto replay. Does the 2-foe pop-over feel too long (~2.2 s)? Is the map block "Where it began" good or too tall?
- Idea parked: fight as a bottom sheet over the map (phone: map top 35%). Cost ~1 release, medium risk; needs all other dialogs converted to modal. Decide after the phone test.
- Not tested live: creature pictures in the pop-over (only emoji in tests). Last foe KO fade only in Auto replay.
- Fable text review: Ch I + II-a work. Fixed 7 of 8 issues. Left: ch2.spot.crossroads.locked is unreachable (leave).

## 2.0.13 desktop fight layout: BUILT (see claude/plan-trek-desktop-layout.md)
- Desktop map screen: log + Sneak/Camp/Leave under the map; fight screen keeps the inert map left and cross-fades the right column to the fight panel and back. Waiting for Joshua's "go" after the 2.0.12 phone test. One Sonnet task + Opus review.

## Now: Joshua
0. 2.0.15 checked OK. Next: play Ch I + II-a + II-b as admin; then say go on the held II-b items above. Ask if Tumble talk lines should be reworded.
1. Upload **2.0.9** (covers 2.0.3–2.0.8). Check on phone: log sits under the map; free Burdock/Zinnia/Bracken: story pop-ups, then the "Party member joined!" card (stats + bio); the "Story pop-ups" button under the tabs mutes them; edit the 7 gnome reply lines (Admin → Trek text, keys `*.scene.*.me`) and the trailmates' bios (npcs, used on the join card). Decide: should the milestone line come before the join card? Do pop-ups feel too many? As admin on phone check: a delve and a lair on the map (tap a lit tile, no sideways scroll, "Use the simple list" works, chest opens after the other rooms); shop, Trading Post and Market Day tiles + sheet; Town → Passport + Villagers tabs; World → Seasons fold; Admin → Usage, Road text, settings search.
2. Play Ch I + Ch II-a as admin on phone (text reworked in 2.0.4; rows you edited kept your words). Edit/approve in Admin → Trek text. Then say when to turn on "Treks: open".
3. Get players (slow going). Read Admin → Retention and Admin → Usage after a week or two: they decide the gated cuts.
4. Art in progress (Admin → Images).
- Email: Joshua says OK, drop it.

## Plan 2026-10-20: see claude/plan-consolidation.md (Phase 0 usage page 2.0.3, Phase 1 2.0.4; next: read Admin → Usage; gated cuts wait for the numbers; Phase 3 done in 2.0.6; NEXT: read Admin → Usage, decision gate on maps (roads strip/town hub only if delve maps get played), gated cuts, more picture-tile shops (Curio/Dye Pot, festival, pantry, local))

## NEXT UP (Joshua 2026-10-17)
- Picture tiles + sheet (like shop.php 1.9.8) on: Curio + Dye Pot (sinks.php), market day stalls (marketday.php), haven pantry (landmarks.php), festival stalls, local.php buys, Trading Post (market.php).


## Explore: next (from `claude/explore-review.md`; 1-5, 7, 10 done)
- Region packs for the other 11 regions. 6 traces of other players, 9 festival/goal chips, 11 calling/animal lines, 12 delve room text, 8 Tales.
- Also: road_lines admin editor (draft status like trek text); 146 villages share 9 descriptions; 4 stop personalities lack chat lines; Haven text promises shops that don't exist; tundra thin.

## Treks: next
- Scenes next: Gloomtooth intro, Sorrel's door, signpost riddle as pop-overs (need speaker-tagged text); gnome reply lines are drafts.
- II-b watch: Overdue Book unused in II-b; only 2 new crew moments;  Admin settings for road roll % not built. Road data files have no admin editor.
- Not built: zone j first-fight tutorial, Chapters III-VI, Thorny/Bramble, skill points/respec, mini-map, Lanternroot real crop, hats/stamp/trophy, friendship +1/20 fights, trailmates 4-8.

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
- Fix stale greps in tests/sinks097.sh (`class="curio"` is now `class="curio choiceform"`; `owned</span>`). Game is fine.
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
