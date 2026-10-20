# Gnome Venture: to-do (updated 2026-10-20, after 2.0.1)

Built + sent: **2.0.1** (slim needs 1.4.1+). Live: whatever Joshua last uploaded (1.9.1 migration verified live). Read `claude/handoff.md` first, history in `claude/changelog.md` (complete to 2.0.1). Treks: `claude/plan-treks.md`, `claude/trek-chapter1.md`, `claude/trek-chapter2.md`, `claude/trek-text-spec.md`, `claude/plan-trek-levels.md`.

## Now: Joshua
1. 1.9.2 uploaded; all 1.8.x checks pass (Joshua 2026-10-17). Play Chapter II-a as admin on phone; time it.
2. Trek text this week: Ch I (89) + Ch II-a (88) drafts. Edit/approve in Admin → Trek text. Then turn on "Treks: open".
3. Get players (slow going). Check Admin → Retention.
4. Art in progress (Admin → Images).
- Email: Joshua says OK, drop it.

1b. Upload **2.0.1** (on top of 2.0.0.1). As admin check: a Ch II boss with a non-Burdock party, a riddle (2 tries), an old campsite ⛺ rest + KO wake-up there, road in-sight timer ticking.

## NEXT UP (Joshua 2026-10-17)
- Picture tiles + sheet (like shop.php 1.9.8) on: Curio + Dye Pot (sinks.php), market day stalls (marketday.php), haven pantry (landmarks.php), festival stalls, local.php buys, Trading Post (market.php).


## Explore: next (from `claude/explore-review.md`; 1-5, 7, 10 done)
- Region packs for the other 11 regions. 6 traces of other players, 9 festival/goal chips, 11 calling/animal lines, 12 delve room text, 8 Tales.
- Also: road_lines admin editor (draft status like trek text); 146 villages share 9 descriptions; 4 stop personalities lack chat lines; Haven text promises shops that don't exist; tundra thin.

## Treks: next
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
