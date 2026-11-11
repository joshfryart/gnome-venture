# PLAN: Trail Sights — interact with the big set pieces while adventuring

Status: PLAN ONLY (2026-11-11). Nothing built. Model = how Trail fishing was done (2.6.38): the map already knows where the thing is, a button row under the map appears when the gnome is close, it posts an action, uses energy, pays a reward.

## 1. What a "Sight" is
Every Trail section has 1 landmark sprite (`lm-<slug>`), 41 sections have 2: **665 sections, 706 landmark placements, 219 slugs** (82 hand-drawn Maplewold + 137 shared: 94 land pieces + 43 `end-*`). Each slug becomes a **Sight**: one named thing you can DO when you stand near it. No re-bake needed: position is already in the map data (`objs` rows `[x, y, "lm-<slug>", jit]`).

Rules (same spirit as fishing):
- Button appears only when the gnome is within **3 tiles** of the landmark's feet tile (sprites sit 2-5 tiles off the road, so 1-2 would never trigger) and no fight/event is open.
- Costs 1 energy (like Fish) and 10 game minutes (sleep-days). Admin can change per row.
- Never a KO, never a fight. Worst case: a scratch (lose a little energy / a line of text). Fights stay on E / M tokens.
- Per player, per section, per Sight: **cooldown on game days** (default 5.5, same as Trail finds, setting `trail_sight_tenths` 55) and **max uses per cooldown** (default 1-3 by kind). Keeps it from being a farm.
- Works both ways on a route (reverse walks, 2.6.41): near-check reads the map as drawn.

## 2. Player-facing UI
1. **Button** in `.trailfoot` next to `🎣 Fish`: `<icon> <verb> <small>⚡1</small>` (e.g. `🪢 Cross`, `🦉 Watch`, `🧺 Pick clover`). Shows a second button if two Sights are near. Greyed with "again in N days" when on cooldown.
2. **Marker**: small `!` over the sprite when usable (same style as the workshop `!`), nothing when used up. Phase 3.
3. **Tap the sprite** on the map = open the Sight card (popover, like Rest stop): picture, caption (already written in `setpieces.json`), what it can do, tool needed, what you got last time. Phase 3.
4. Result: the normal toast + map pop-up lines (`take_toasts`, `.tmpop`), found items via the satchel reveal.
5. Almanac: new section **Sights** (per land; seen / used counts; first use pays a little XP + a milestone at 10 / 25 / 50 per land). Page text = the caption we already have.

## 3. Engine (reuse, do not invent)
- **Near check**: `trail_sights_near(array $art, int $x, int $y): array` in new `includes/trail_sights.php`, same shape as `trail_water_near()` (`trail_art.php:97`). Reads `lm-` objs of the section.
- **Acts**: reuse the stop-activity engine (`stops.php stop_acts()`, kinds `check / pick / power / lore / snack / swap / buy / gossip`, reward grammar `c= xp= en= item= crop= find= fish= seed=`, `when` conditions dp/se/we). Spike first: confirm `stop_act_run`-style code can take a Trail section as its host instead of a stop (if not, extract a small `act_resolve($a, $u, $ctx)`).
- **Gather-type Sights** reuse `gatherables.txt` + `gather_on_walk()`; add an optional 10th column `spot` = landmark slug (or `*` land): rows with a spot only drop at that Sight, tier rule unchanged (common Worn, uncommon Sturdy, rare Fine).
- **Choice-card Sights** reuse `road_events.txt` E/O cards (`where` field gets `sight:<slug>`).
- **Fishing Sights** reuse the 2.6.38 rod path; the Sight just names the spot and lifts the table (`gather_candidates` with `spot`).
- **State**: new table `trail_sight_uses (user_id, route_id, sec, slug, last_day, uses)` created by the migrator / first use (pattern of `trail_pickups`, `action_log.php:22`). Day = player game day (`gclock`), real days if clock off.
- **Energy / time**: `spend_energy()`, `gclock_spend_minutes()`; tired surcharge applies as for any action.
- **Pals**: a Puzzle Pal beside the gnome can add a small bonus (+1 find chance) — later, not in the first build.
- **Sleep-days**: day-part (`dp`) and weather (`we`) conditions on rows make dusk / rain / fog Sights special (red rock arch glows at dusk, mist pool at fog).

## 4. Data file
New `game/includes/data/trail_sights.txt`, one row per slug (219 rows), editable in Admin (new Admin > Trail sights, modelled on Stop activities; Tools check lists slugs with no row):
`slug | verb | icon | kind | tool (or -) | tier | energy | cooldown_tenths | uses | when | spec | rewards | win line | lose line`
Shared pieces are per land, so rewards use the land's loot table; the 82 Maplewold rows are hand-tuned.

## 5. Behaviours by archetype (every one of the 219 is in one)
| # | Archetype | What you do | Pieces (shared) | Notes |
|---|---|---|---|---|
| A | **Forage spot** | Pick / forage here: better, tool-gated gather table | clover patch, daisy ring, dandelion drift (blow: seeds), acorn scatter, bluebell glade, shell heap, kelp line, salt flat (bucket: salt), peat bank (spade: peat), dune grass, orchid tree, lantern fruit, coconut grove, shell-bell tree, rain-drum leaf, spring + pebbles, willow curtain (switch / withies), giant fern glade, hay-cart ruts | spot rows in `gatherables.txt` |
| B | **Skill crossing** | stat check to cross; win = small find + XP, lose = lose 1-2 energy ("you slip") | rope bridge, vine bridge, plank footbridge, boardwalk gap, fallen-log bridge, lily-pad ford, stepping roots, root-tangle crossing, goat ledge, switchback, ice-shelf steps, mossy stair, sandbar causeway | stats Agility / Balance; difficulty by region level; never blocks the road |
| C | **Watch / sneak** | quiet check; win = rare critter sighting (Almanac critter page + a small item or feather) | owl-watch bough, heron's post, parrot perch, frog choir, mud-skipper flats, dragonfly bend, eagle's rest, goat ledge, hammock palms (crab) | Sneak stance makes it easier; Hunt stance scares them |
| D | **Rest / nap** | rest a bit: energy back, short buff; uses game time | picnic knoll (needs a snack item: buff), shade awning (nap 2 h), stilt house, stone hut, hollow oak (tea: needs a cooked item), driftwood arch, snow fort, lone fir, fallen giant | reuses stop `rest` kind, caps per day so it is not a free inn |
| E | **Fish / water** | the 2.6.38 rod path with a named better table | reef shallows, lagoon edge, mist pool, mirage pool (mostly a trick: lore), tide-pool steps (crab pick), frozen stream (ice-fishing), tide cave, waterfall mist (drink: small energy + rainbow find chance) | cooldown 1 per day, shares the rod wear |
| F | **Use / craft** | uses an item you carry; small craft or swap | well and rope (bucket: water), sleepy windmill (grain -> flour), net rack (borrow / mend net), trader's tent poles (barter swap), lantern branch (light a lantern: night buff), scarecrow (leave a hat: crow gift), stranded rowboat (patch: lets you row a short hop) | kinds `swap`, `buy`, `snack` |
| G | **Lore / read** | read it, pays a tiny XP + Almanac note, sometimes a hint or a map clue | milestone, star-chart stones, bottle post (note says 'hello'; sometimes an item), waystone cluster, echo wall (echo returns a funny line), wind-combed meadow (kite: hint to weather), aurora rise (night only: wish) | kind `lore`; cheap, 0 energy allowed |
| H | **Hazard / terrain** | a small choice: push on or go round; costs / gains a little | scree slope (noisy: +encounter odds for a while, or sneak across), wind notch (wind buff / debuff by weather), bramble gap (axe cuts: wood), sand-ripple lane, dry riverbed (dig: pebble / fossil), sea-stack gap, red rock arch (glows at dusk: bonus) | uses `when` weather / day-part |
| I | **Persistent / shared** | adds to something everyone sees | cairn pass (add a stone: a shared counter on the Sight card, milestone rewards), bottle post (leave a note for a later player), milestone (distance marker) | phase 4; needs a table `trail_sight_shared (slug, route, sec, count)`, player notes moderated like Messages |
| J | **End-piece scout** | prepare for the place ahead | haven path / last turn (peek at the shop / rest price, free), wonder gates / hush (peek: lore + first-visit XP), delve mine mouth (listen: hints the first room; light a lantern: +buff for the delve), delve lantern line (same), lair approach / threshold (read footprints: shows the boss, its weakness hint, and offers Sneak) | the 43 `end-*`; ties to boss fights without adding a fight |

Maplewold's 82 hand-drawn landmarks get the same archetypes by name (pond mill = F grind, apple tree = A, ford = B, scarecrow = F, haybales = D, hedgerow = H, beehive = A honey with a sting check, taproom / sugar shack = F swap, etc.); a row-by-row list is written when phase 2 starts.

## 6. Balance
- Reward per energy about equal to one Gather here. Rare items only via tier-gated spot rows.
- Cooldown + uses cap per section, plus a **per-walk cap** of 6 Sight uses so a long route cannot snowball.
- First use of each Sight: bonus XP once (Almanac). Later uses: normal.
- Fail costs capped at 2 energy; no item loss.
- Tool wear as for gathering (one use per act).
- Check with `tests/balance_sim.php` walks: add average Sight use per route (assume 50% taken).

## 7. Build phases
- **P0 Spike (1 day):** can the stop-activity engine run with a Trail host? Prove one Sight end to end: 'Pick clover' (A) on route 230. Output: yes/no + extraction needed.
- **P1 Engine:** `includes/trail_sights.php`, table, near check, button in `adventure.php`, cooldown, data parser + lint, admin editor, tests (`tests/trail_sights.php`, `.sh`, add to CI). Archetypes A, B, G, E first (reuse paths exist).
- **P2 Data:** write rows for the 94 shared land pieces (C, D, F, H added), then 43 end pieces (J), then the 82 Maplewold ones.
- **P3 UI:** marker `!`, tap-the-sprite card, Almanac Sights section, 'used' tint (draw one `-used` variant only if it reads well; else none).
- **P4 Shared:** cairn counter + bottle-post notes.
- **P5 Polish:** pal bonus, sounds, tiny animations (windmill turning, awning flapping).
- Each phase is its own version with changelog and slim zip; no Admin > Images upload needed (no new pictures, only data and code).

## 8. Tests
- Every slug in `setpieces.json` + `maplewold` has a row; rows parse; kinds known; tool types valid; rewards parse.
- Near radius: gnome 3 tiles away sees the button, 4 does not; reverse walk the same; two-landmark section shows two.
- Cooldown on game day, uses cap, per-walk cap; clock-off fallback to real days.
- Energy and game minutes spent; fail never KOs; rewards land in satchel.
- Playwright walk at 412 px on one route per land: button shows, result toast + map pop-up show, button greys after use.
- Not covered by tests: look and feel on a real phone (ask Josh).

## 9. Risks
- Fishing buttons + Gather + Wander + Sneak/Hunt + Sights may crowd `.trailfoot` on a phone: fold Sight buttons into one `✨ Sights` button that opens the card when 2 are near.
- Cooldown state per section adds a table row per use: prune rows older than 30 game days on insert (like `player_actions`).
- 41 two-landmark sections: both may be near; fine, both listed.
- The shared pieces repeat across routes (a "plank footbridge" appears in 9): same rewards each time but cooldown is per section, so a land piece can be used once per route stretch — intended.
- Ground pictures do not show a used state; the card and the greyed button carry that.

## 10. Questions for Josh
1. Radius 3 tiles OK, or must the gnome stand next to it?
2. Button under the map only, or also tap-the-sprite (P3)?
3. Should Sights cost game time (10 min) like other 10+ min actions?
4. Shared cairn / bottle notes (P4): yes, or keep everything private?
5. End-piece scouting (J) can reveal the boss: OK that it gives hints for free?
6. Any piece you want cut or made special first (my picks: windmill, rope bridge, owl bough, waterfall, mist pool, bottle post)?
