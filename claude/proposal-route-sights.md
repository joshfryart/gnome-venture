# PROPOSAL: Route-map Sights, one picture-UI and one quest game per map family

Status: PROPOSAL ONLY (2026-11-15). No code. Josh to veto/pick.
Builds on: `claude/plan-trail-sights.md`, `claude/sights/GRAMMAR.md`, `trail_sights.php`, `trail_sight_extras.php`, `npc_life.php`.

## 0. Reading of "each one"
Trail route maps have 219 Sights in 14 families (counts from data files):
Maplewold hand-drawn (82) | 9 lands: forest 13, coast 11, desert 11, grassland 10, mountain 10, rainforest 10, wetland 10, island 8, tundra 6 | 4 end kinds: haven 8, wonder 16, delve 9, lair 10.
One UI skin + one game per family = 14. (If Josh meant per Sight (219) or per road kind (6): see section 5.)

## 1. What is here now (reuse, do not rebuild)
- Sight = gold `!` on landmark, tap -> card -> verb button. Cost: energy + 10 game min. Cooldown on game ticks.
- Checks: stat:dc, `pick:N` (choose a label, one is right), `choose=`, `tool`, `take=`, `tally=`, `first:`.
- Conditions: `dp se we hp st gd=M:R`.
- Quests: 25 lines, `seq|any|anylast`, beat kinds Sight / `@boss` / `@meal` / `@friend`, `needs take=`.
- Folk at Sights: `trail_sight_folk_*.txt`, roll once per gnome+Sight+villager+game day, role hours, away days, hidden NPCs.
- Travellers (merchant, minstrel, naturalist): 12h per region, offset circuit, window 3 behind / 4 ahead. Gourmand: festival camp days.
- Shop NPCs: shift -> wander 3h -> rest. Stop calendar: weekly:sat, monthly:first:sun, dates, ranges.
- Gaps already listed by Josh/quests-todo: no time-limit beats, no villager-beside-you at a beat, no errand beats, no mini-game pieces.

## 2. NPC timing = the core trick (one shared engine add, "Clockwork")
Every family game is a **timed appointment**: the Sight only does its big thing when a named NPC is there. Player learns the NPC rhythm from the map, then plans the walk.
- **Timing bar** on the Sight card: 24h strip, coloured blocks = when each villager can be here (from `when`, role hours, circuit window). Gold notch = now. Tap a block = "remind me" (a note on the Trail page, no push).
- **Travel-time aware**: a section costs game minutes. Card shows "arrive 16:40, Lyra here until 18:00".
- **Next-up chip** on the route ribbon: "Lyra at the Gate, dusk" = nearest open appointment on this route.
- **Engine adds (small)**: `trail_sight_forecast(slug, uid, days)` returns hours each villager row would fire (deterministic: `hollow_unit` already keyed by day, so it is predictable not random); beat condition `needs=npc:Name` (NPC present at use); beat `window=` (finish within N game days).
- Free fairness: chance rolls are fixed per day, so forecast is TRUE. Show "likely" only for chance < 100.

## 3. The 14 proposals
Format: **UI** (picture layer over the tile map) | **Game** (one repeatable mini-loop, 1 energy) | **Quest line** (new, 5 beats, ends on an NPC appointment).

### Maplewold (82, the first map everyone sees)
- UI: **Sugar-shack ledger**: a felt-board strip above the map, one stitched patch per Sight done (82 patches = collect-all quilt). Patch lights when its Sight is ready.
- Game: **Pantry Round**: each day 3 Maplewold villagers want one thing (flour, syrup, honey). Gather via Sights, deliver where they stand NOW. Matches shop-NPC shift -> wander -> rest: at shift they are at shop, wander they are on a route.
- Quest "The Opening Day Parade": 5 beats, each Sight lights one lantern in order dawn -> dusk (`dp=` per beat). Clover (Market) opens the line, Bramble ends it at dusk, picnic-list line must be done first (gate).

### Forest (13)
- UI: **Glow-moss dusk filter**: map dims at dusk, Sights show lantern halos, fireflies mark where a villager is.
- Game: **Lantern Relay**: light 3 lantern-branch Sights in under 90 game min before the lamplighter NPC passes (his round is timed).
- Quest "Who Lit the Wood?": catch the lamplighter (forecast bar!) at 3 different Sights at night; he is only at one per hour.

### Coast (11)
- UI: **Tide strip** (top right): high/low tide arc drawn on map edge; tide-pool Sights only open at low.
- Game: **Tide Table**: true tide (already planned in `end-p2-todo`): plan visits to shell heap / kelp line at low tide, bonus when the fisher NPC joins.
- Quest "The Message in the Bottle": bottle moves one Sight per game day with tide; follow it down the coast, hand to the lighthouse keeper on his dawn shift.

### Desert (11)
- UI: **Heat shimmer + shade pips**: map wobbles at midday; shaded tiles glow cool. Walking in sun drains a small "water" gauge.
- Game: **Caravan Stop**: Tobias (merchant) camps at a tent-pole Sight only when he is in this region (circuit); trade a well-water for a rare seed.
- Quest "The Trader Who Went Home" (extend existing): add 3 dusk-only beats; Tobias appears at 7th-day (`gd=7:0`), finale ends when he is in his own region.

### Grassland (10)
- UI: **Kite sky strip**: wind arrow + speed over the map; Sights hint "good kite day".
- Game: **Kite & Wind**: fly a kite at wind Sights, wind from true weather. Pick wind right for a bonus; Mabel (Dreamy) joins on `we=wind`.
- Quest "Mabel's Sky Letters": 5 letters, each needs a different weather (sun, cloud, wind, rain, fog) so it takes a full week.

### Mountain (10)
- UI: **Altitude tint**: climbing sections add cold/mist; echo-wall shows sound rings.
- Game: **Echo Chain**: shout at echo wall, reply comes from a second Sight at the delay of its distance. Match the rhythm (pick:N).
- Quest "The Goat Ledge Census": count the same goat at 3 ledges; the goat herder villager is at one ledge per dp, tell him at dawn.

### Rainforest (10)
- UI: **Canopy layers**: toggle floor/canopy view; some Sights only visible in canopy.
- Game: **Mist Pool Tally**: `tally=` key per pool, fill all pools in a day for a title.
- Quest "The Orchid That Opens at Night": all beats `dp=night`, needs a lantern tier; Pomeroy (Gourmand) camps there on festival days only.

### Wetland (10)
- UI: **Reed-line ripples**: tiles ripple where a creature moves; stilt-walk planks overlay.
- Game: **Stepping Stones**: nimble chain, 3 checks, fail = wet boots (flooded rule: Flood Boots halve slow).
- Quest "The Dragonfly Bend Count": species count by season (`se=`); Pip Oakenpot (Fussy) rates the list at dusk only.

### Island (8)
- UI: **Boat dot**: a boat icon links Sights across water; ferry kind routes show timetable.
- Game: **Ferry Timetable**: ferry/harbour NPC runs on a fixed 12h rhythm (like travellers); catch the right crossing to reach hammock palms.
- Quest "Pinchwell's Postcards": 4 islands, one postcard each, delivered in order, last on a Sunday (`gd=7:0`).

### Tundra (6)
- UI: **Aurora overlay** at night in winter; frost on cold tiles.
- Game: **Warm Hut Relay**: each hut Sight gives warmth buff minutes; chain 3 huts without freezing.
- Quest "Ferrin's Long Night": snow-only beats, last one needs aurora (`se=winter/dp=night/we=sun,cloud`).

### Haven end pieces (8): rest places at the road end
- UI: **Guest book**: a book page per haven, villagers sign it when seen.
- Game: **Bedtime Rounds**: tuck in 3 villagers in the right order by their schedule (rest hours differ).
- Quest "Rest Here, Repainted" (extend): repaint the sign over 3 visits, Tobias returns on his circuit to inspect it.

### Wonder end pieces (16): the big sights
- UI: **Postcard frame**: tap a wonder, get a framed picture card with a sticker slot.
- Game: **Look Closer**: a hidden-detail game, find 3 things at the wonder; Wren (naturalist) tells one true clue when in the region.
- Quest "Wren's Gate Rubbings": rubbing per wonder, 16 pieces make a poster; Wren seen only on her circuit windows.

### Delve end pieces (9): doorways down
- UI: **Torch bar**: map goes dark ring-shaped, torch reach shrinks over steps.
- Game: **Lamplighter's Round** (existing quest, add live timer): Burdock lights each mouth in turn; reach each lit mouth within the window.
- Quest "The Book of Hushes": silence beats (no chat, no fight) at each delve mouth, Sorrel Inkcap reads the book at night.

### Lair end pieces (10): boss mouths
- UI: **Footprint tracker**: tracks on the map age (fresh/old) from game time; creature hints become true hints.
- Game: **Sideways Tracks**: read tracks (pick:N), guess the lair creature level +/-2; right = free hint on fight.
- Quest "The Scout's Field Notes": Captain Spurwing at his 7th-day patrol (`gd=7:0`) pays for each page; complete = a title.

## 4. Build order (cheapest first)
1. Clockwork core (timing bar, forecast, `needs=npc:`, `window=`): needed by all 14. ~1 file + a card section.
2. UI skins as CSS + overlay layers only (no new art needed): tide strip, wind strip, altitude tint, aurora, torch ring.
3. Per family: data rows + 1 quest line each (use existing grammar; lint `tests/trail_sights_lint.sh`).
4. Art last, with emoji fallback like all Trail art.

## 5. Questions for Josh
1. "Each one" = 14 map families, per Sight (219), or per road kind (6)? Per Sight would need reusing 6-8 game templates, not 219 unique games.
2. Forecast bar: show chance < 100 villagers as "maybe", or hide?
3. Should missing an appointment cost anything? Proposed: no, retry next game day.
4. Which 3 families first? Suggest Maplewold, Coast (tide), Forest (lanterns).
