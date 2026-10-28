# Plan: variety across 14 regions (road, stops, claiming/rebuilding)

Status: PLAN ONLY. Nothing built. Written 2026-10-28 after 2.0.75.

## Why it feels the same (found in code/data)
Road walks (`road_life.php`, `data/road_events.txt`, `road_lines.txt`, `road_meet.txt`)
- Every space rolls one of 4 kinds (creature 40 / problem 22 / choice 14 / find 24). Choice card = pick option, roll a stat. Always same shape.
- ~100 scenes; 26 are region `any`. Most regions have 3-6 own scenes, 0-2 sights. Road lines are by landscape + time + weather, not by region.
- Every road is 3 stops x 3 spaces (`ROAD_STEPS`). No forks, no chains, no collecting.

Stops (`stops.php`, `data/stops.txt`, `stop_acts.txt`)
- 12 stop types, same 12 in all 14 regions. 60 acts, picked by TYPE only (no region column). ~35 of 60 are `kind=check` (pick a stat, roll). Kinds pick/power/lore/swap/buy/rest exist but are rare.
- Main-stop town, rest stop, landmark pages each have their own template but the same verbs: roll, chat, shop.

Landmarks / claiming (`rebuild.php`, `stop_adopt.php`, `landmarks.php`)
- `REBUILD_STAGES` is ONE constant: stone+coins, timber+rope, 4 meals, fine finds+coins. Same 4 steps for all ~67 ruinable havens/wonders/delves, all 14 regions. Pure "hand in items".
- Adopt-a-stop: same 4 tiers (bench, stall, well, hall) for all 12 types. Same needs.
- Wonders: pick one of a few stat approaches. Delve: 5 rooms. Lair: one fight. Text differs, mechanics do not.

## Goal
Three layers. Each is data-driven so content can be added in batches without engine changes.
1. NEW VERBS (how it plays): more than "pick stat, roll".
2. REGION KITS (what it is): every region has its own scenes, acts, materials, build plans.
3. ANTI-REPEAT (what you see): pools are picked so the same shape does not show twice in a row.

## Layer 1: new verbs

### A. Road encounter kinds (new `kind` column on `E` rows, default `choice` = today)
Keep the 4 roll bands. Under `choice` and `find`, add card shapes:
| kind | plays like | reuses |
|---|---|---|
| choice | today | road_events |
| fork | two ways on: short + risky / long + safe / hidden (needs a stat or item) | choice engine, new option effects |
| chain | 2-3 linked cards over the next spaces (lost goat: tracks, then pen, then reward). State in `$exp['chain']` | road state |
| riddle | pick the right answer of 3 (lore flavour, no dice, wrong = small cost) | stop `pick`/`lore` code |
| trade | traveller offers X for Y, take or leave, local goods by region | stop `swap` |
| toll | a gate wants an item/Petals/a tune (charm) or a detour | choice |
| beat | tiny timing/pick mini-task: stack, balance, catch (3 taps), reuse hoop.js / race.js / spit.js patterns | existing games |
| sketch | collect a "sight": fills the region's Road Journal page (see C) | passport |
| weather | only in a weather/season cond, changes the space (puddle hop, snow-drift dig, heat shimmer rest) | cond system |
Rule: no new scene kind may be added without at least 3 scenes for it per 5 regions it fits.

### B. Stop acts: new kinds (extend `stop_do`)
Today: check pick power lore rest buy swap snack seedswap gossip. Add:
| kind | plays like |
|---|---|
| craft | use the stop's station with what you carry: spin, dye, brew, press, smoke. Input item(s) -> local item. No dice. |
| cookalong | cook with a villager: pick 2 of 4 local ingredients, outcome by combo (small table) |
| contest | one-shot mini-game vs a villager, reuse Worm Hunt / Seed Spit / Snail Race / Memory scores as the roll |
| tune | rhythm of 4 pick-a-note (music stops: minstrel, bell, drum) |
| tend | small local chore with a visible state that persists for the day (water the row, feed the ferry goat) and pays when finished over 2+ visits |
| collect | spot N of M local things (birds, shells, stones, kites); keeps a per-region checklist |
| teach | villager teaches a small knack; pay time/energy once; a cosmetic or tiny buff |
| festival | rare, cond-gated (season/weather/day): replaces one slot with a bigger, themed act |
Also: `stop_pool` diversity rule: 3 slots must have 3 different `kind`s if possible.

### C. Region Road Journal (collecting)
Each region gets 6 sights + 4 meets + 1 rare. Seeing one stamps a page; a full page pays a small reward and a title. Fits the existing passport (`stop_pass.php`). Gives a reason to walk the same road again.

### D. Claim / rebuild: step verbs (replaces fixed REBUILD_STAGES)
Stage = a verb + params. Library of ~14 verbs, each has one check function and one UI line:
| verb | player does |
|---|---|
| haul | hand in items (today's stone/timber/rope; now varied by plan) |
| craft_on_site | make a part at the site's own station, then fit it |
| gather_local | bring 2-3 regional gatherables (reed, clay, coral, lotus, cedar...) |
| feed_crew | hand in specific regional dish(es) (a recipe from `recipes.txt`) |
| carry | take an item from town A to here by road; arrives over the walk (uses routes) |
| befriend | reach friendship N with the local stop folk (`stop_friend_points`) |
| clear | spend energy on 3 different days (a visible progress bar, no items) |
| trial | win a mini-game score or a wonder approach here |
| fetch_lore | answer the keeper's riddle (Almanac knowledge: needs a plant/creature seen) |
| vigil | be here at dusk/night/dawn/in a weather (cond) and do one thing |
| tune_up | plant/place something from your own garden (a flower, an animal product) |
| light | hand in a made item (lantern, candle, bell) |
| wait | a curing/setting timer, hours, others can see it |
| decorate | pick 3 of 6 local touches; changes the plaque/art text only |
A **build plan** = 4 stages chosen for a landmark. Never the same 4 verbs as another plan in the same region.
- Plans picked deterministically (`crc32(slug)`) from a pool per landmark kind (haven / wonder / delve) and per region material set, OR written by hand in `data/build_plans.txt` (one row per landmark, optional override).
- Adopt-a-stop tiers: per stop TYPE, 4 themed tiers (mill: wheel, sluice, sack-hoist, flour hall; jetty: pier, nets, lantern boats, fish hall...) with their own verbs/needs. Region material swap (stone -> coral block / bamboo pole / adobe brick).
- Safe change: stage count stays 4, `landmark_repairs.stage` stays an int. Old rows resolve to the old default plan. No schema change for the first cut (plan = function of landmark id).

## Layer 2: region kits (content)
One file set per region. Minimum quota per region (x14):
- Road: 14 scenes (6 choice, 2 fork, 2 chain, 2 weather, 2 riddle/trade/toll/beat) + 6 sights + 6 road lines per landscape it has + 4 meets.
- Stops: 8 regional acts (spread over the types that region uses: add `region` column to `stop_acts`; likelier in that region, or only there) + 1 regional festival + type skin lines (market in Maizehollow smells like masa; in Dunewhisper has camels).
- Stop folk: regional species/names/bios pool (today global `STOP_*`).
- Building: 1 regional material set (3 items) + 6 regional gatherables used by plans + 2 regional dishes for feed_crew.
- Landmarks: each of its 5-6 landmarks gets a build plan, a distinct wonder approach set (3 stats -> region-flavoured verbs), 3 delve room lines, 1 keeper character line set.
Totals: roughly 14 x (14 + 6 + 8 + 1 + 6 + 6 + ~30 landmark lines) = ~1,000 content rows. Written in batches of 2-3 regions per release by Claude, edited by Joshua in the existing admin editors (Admin > Road text, Stop activities, Stop types).

## Layer 3: anti-repeat
- Road: ring memory already exists (`ROAD_RING_*`); extend to remember `kind` and region-vs-any, so two cards of the same shape never show back to back and a regional scene is guaranteed about 1 in 3 cards.
- Stops: slot kind-diversity rule (see above). Stop acts get `weight` and "seen today" memory per gnome.
- Repairs: UI shows the verb icon per stage so the 4 steps are visibly different on the card.

## Build order (each is one release, Joshua checks between)
1. **2.0.76 Build plans engine.** Stage verbs `haul`, `gather_local`, `feed_crew`, `clear`, `befriend`, `light`. Plan resolver. Default plan = today (no change for old). 1 region (Maplewold) fully planned as the pilot. Tests: `tests/rebuild*.sh`, new `tests/buildplans.php`. Admin: read-only plan view first.
2. **2.0.77 Adopt tiers per stop type** (12 themed tier sets) + regional material swap.
3. **2.0.78 Stop act kinds**: `craft`, `collect`, `tend`, `contest`; `region` column; kind-diversity pool rule. Pilot: Maplewold + Maizehollow acts.
4. **2.0.79 Road kinds**: `fork`, `chain`, `riddle`, `trade`, `weather`; Road Journal (sights page). Pilot: same two regions.
5. **2.0.80 to 2.0.86 Region content waves**: two regions each (wave order: pilot 2, then NWE/SE, EA/SEA, MENA/WCA, ESA/CSA, SA/CB, NA/EE/OC leftovers). Each wave = scenes + acts + plans + materials + tests + CHANGELOG.
6. Later verbs once engine is proven: `carry`, `trial`, `vigil`, `wait`, `decorate`, `beat`, `teach`, `tune`, `cookalong`, `festival`, `toll`.

## Risks
- Saved walks point at scene numbers (first 14 fixed): new kinds appended only.
- Balance: Petal/XP caps (`ROAD_ITEM_CAP`, `repair_rewards`) must apply to every new verb; no new uncapped Petal source (owner rule).
- `landmark_repairs` is per gnome and may be mid-way: keep stage ints, keep old plan for anyone with stage > 0.
- Admin editors must read/write the new columns; importers "add missing rows only" so new data needs a version bump + upgrade hook.
- Treks (separate system) untouched.
- MySQL: any new table uses `*_schema()` pattern; no new table needed for the first two releases.
- Content volume: ~1,000 rows needs a style pass so it stays in Gnome Venture voice (use `road_text.php` rules, `’` curly, no `|`).

## Build notes (2.0.76)
- Pilot regions are CA + CB, not NA: the Maplewold is the start region and never has ruins. NA plans come with the last wave (they only matter if the start region changes).
- `befriend` is deferred: landmark places have no stop folk. Verbs built: haul, gather, feed, light, clear. A `clear` stage is days-only and finishes itself.
- Art: placeholders in `game/assets/img/steps/` (not `build/`, which is gitignored). List: `claude/todo-art-variety.md`.

## Decisions (Joshua, 2026-10-28)
1. Order: building/claiming first (2.0.76), then stops, then road.
2. Build plans hand-written per landmark (`data/build_plans.txt`, one row per landmark, 4 stages each). No generator. Content cost: ~67 plans, 5 per region wave.
3. Worm Hunt, Snail Race etc. are full games in the Games section, not mini-games. Do NOT reuse them as step checks. `contest` / `beat` / `trial` become small in-place checks (pick/timing/stat), built new and light. Games stay separate.
4. Region waves: 2 regions per release.
