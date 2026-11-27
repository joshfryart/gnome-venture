# PROPOSAL: Story pass 2, main quest line and side quests

Status: PROPOSAL ONLY (2026-11-27). No code. Pass 2 of the story.
Superseded in part by `PROPOSAL-HOLLOW-MASTER.md`: section 6 (M4, M6, M7 steps; `puzzle` step kind; no `unlock=pal` extras), section 2.2 (CB-WCA and SA-ESA doors), section 12 (rulings 4, 6, 11, 14, 15, 21).
Builds on: `claude/proposal-story-1-base.md` (the Round, cast, stops as story, Standing, signature crops), `claude/proposal-maplewold-bands-and-seals.md` (bands, routes, Seals), `includes/journey.php`, `data/stop_threads.txt`, `data/stop_happenings.txt`, `data/calling_quests.txt`, `data/creatures.txt`.
Fixed: no Trek story, no Tansy, Wren's Almanac is the main quest, stops are the spine, gardening in every area, no timers, no fail states.
Creatures: bands 1-3 use `data/creatures.txt`; bands 4-5 use `claude/proposal-creatures-38-55.txt` (proposal list, slugs as written there).

Pass 4 review: corrected in place (stop feasibility, the Crossing, counts trimmed). See `claude/proposal-story-4-review.md`.

Totals (after the pass 4 trim): 28 main chapters, 80 area side quests, 20 new cast threads (section 3.5), so 100 side quests in all; 14 happening acts (ex-`H` quests); 13 secret places, 12 stop themes.

## 1. Quest grammar

### 1.1 Three containers
| Container | What | Where it lives | Shape |
|---|---|---|---|
| **Chapter** (main line) | One per zone (tiers 1-2) or per area (tiers 3-5). Wren's Almanac | `quest_chapters` + `quest_tasks`, seeded from a new `data/journey_chapters.txt` | 5-7 ordered steps, last one is a Leaf or Seal step |
| **Errand** (side quest) | Folk asking for help. Noticeboard, stop card, NPC clockwork spot | new `data/journey_errands.txt` | 1-4 steps, one-off or repeatable for Regulars |
| **Thread** (side quest, multi-day) | Existing stop threads: one beat a day, Regular or better | `data/stop_threads.txt` (existing format, 2 added fields) | 4-6 beats, last beat pays |

A stop **happening** is not a container: it is a trigger (`hp=bake_day`) that makes an errand available that day.

### 1.2 Step kinds
`Lv` on a step is a recommended level and the level an errand creature is scaled to. It is never a lock.

| Kind | Status | spec | qty | Done when | Reads from |
|---|---|---|---|---|---|
| `visit` | exists | - | 1 | area reached | `user_quests` row |
| `grow` | exists | `staple` / `any` | N | N different crops of the area harvested | harvest log |
| `friend` | exists | - | level | friendship level with any townsfolk of the area | friends.php |
| `find` | exists | - or place slug list | N | N hidden places found (or the named ones) | explore |
| `stage` | exists | `item:slug:3,coins:100,meal:2,fine:1` | 1 | handed in, in order (the Repair) | hand-in |
| `adopt` | NEW | `zone:N` and/or `type:mill` | N | you have adopted N matching stops, now or ever (founder counts) | `stop_adopt` |
| `raise` | NEW | `tier:T` + optional `zone:N`, `type:x`, `hearth`; or `lit:60%` | N | N matching stops are tier T or better and you are a Regular there, whoever raised them. `hearth` = a stop you adopted or paid upkeep into. `lit:P%` = P% of the area's road stops at tier 1+ | `stops`, Regular count |
| `plant` | NEW | `crop:slug:N` (harvest N of it in this area) / `flower:slug:N` (grown to bloom) / `bed:K` (Seed Bed hand-in number K of 3 done) | 1 | as spec | harvest log, Seed Bed |
| `deliver` | NEW | `item:slug:N,from:place,to:place` (`to:stop*3` = any 3 lit stops) | 1 | item handed over at the target. The item is given at `from` or is something you grew/cooked | inventory, arrive |
| `escort` | NEW | `who:npc,from:place,to:stop` | 1 | found at `from`, then you arrive at `to` with them. They wait for ever where found; walking anywhere else just pauses it | explore + arrive |
| `defeat` | NEW | `creature:slug` or `lair:slug` | N | beaten **or charmed** (befriend counts). In the main line every `defeat` step also has an `alt` | fights |
| `help` | NEW | `area` / `zone:N` / `errand:id` | N | N errands done there (or the named one) | errand log |
| `regular` | NEW | `zone:N` / `type:x` | N | you are a Regular (3 things done) at N matching villages, road or off-road | Regular count |
| `seal` | NEW | `leaf` (all earlier steps done) / `standing:80` / `seals:CA,NWE` / `seals:14` | 1 | as spec. Triggers Wren's letter, `journey_finish` | Standing |

Two modifiers on any step: `opt=1` (shown, pays a small bonus, never blocks the chapter) and `alt=kind:spec:qty` (a second way to finish it). Rule: **no main-line step can only be finished by fighting.** Charm happens on the fight board, so "fight or charm" is one way; the `alt` is the peaceful one.

Pass 4 rules that make every main step doable:
- **Steps latch.** A step is done the first time its condition holds and never undoes (a tier-4 Hearth that loses a tier to upkeep keeps its step).
- **Only road villages can be adopted** (`on_road`), so `adopt` and `raise` steps name road stops only. Zones with no road village use `regular zone:N` instead.
- **Every `adopt` step has `alt=regular` at a tier 1+ road stop of the same zone or area**, for a busy world where every road stop is held by someone else or already a Hall (a tier 4 stop cannot be adopted).
- A stop type in a step (mill, inn, jetty...) is flavour: any road stop of the zone counts. Havens and wonders (Baobab Inn, Kava Circle, Thatchtop Tearoom, Cherry Blossom Teahouse, Market of a Thousand Chilies, Olive Press Piazza, Floating Market...) are landmarks, not stops: "<haven> stop" means the road stop its side path leaves from.
- The Seed Bed hand-in needs the bed's stop lit if it is a road stop, or you a Regular there if it is an off-road village.

### 1.3 Reward vocabulary (reuse first)
| Token | Status | Meaning |
|---|---|---|
| `c=40:8` `xp=15:3` `item=slug:N@chance` `fp=N` | exists (stop reward spec, `stops.php`) | Petals (base:spread), XP, item, friendship with the giver |
| chapter coins / xp / item / title / benefit | exists (`journey_seed`) | benefits stay the four: `native_plus:N`, `sell_bonus:N`, `free_travel`, `weekly_crate` |
| `seed=slug:N` | NEW (sugar for `item=`) | seed packet. "treasure seed" below = 1 seed of one of the area's treasure crops |
| `page=slug` | NEW | an Almanac page (counts for the Standing "pages" row) |
| `title=Text` | NEW for errands (exists for chapters) | a title |
| `unlock=recipe:slug` / `tea:slug` | NEW | recipe known without harvesting all ingredients |
| `unlock=place:slug` | NEW | a secret place appears on the area map (a hidden haven or wonder, counts as a find) |
| `unlock=theme:slug` | NEW | a cosmetic variant of one tier of one stop type, pickable by any adopter who has it (a row in `stop_tier_themes.txt`) |
| `unlock=shop:slug` | NEW | one more line of goods at tier 2 stalls of the area (for everybody once anyone has done it at that stop, like the glow) |
| `unlock=pal:key` | DROPPED (Josh 2026-11-27) | Puzzle Pals are released only by finishing a jigsaw on Advanced or Expert (`ppal_on_solve`), never by a quest reward |

"Extra" on a side quest is paid on first completion only. A repeatable quest pays its small `c/xp/fp` each time after.

### 1.4 Reward scale by band (unsimulated, same caveat as the XP budget)
| Band | One-off errand | Repeatable (each time) | Thread (last beat) | Seed Bed hand-ins (3) |
|---|---|---|---|---|
| 1 | c=60-90, xp=40-80 | c=25:5, xp=12:2, fp=1 | c=45:8, xp=16:3 (as now) | 3 / 5 / 8 |
| 2 | c=140-220, xp=180-300 | c=35:6, xp=20:3, fp=1 | c=90:12, xp=120:10 | 5 / 8 / 12 |
| 3 | c=350, xp=600 | c=50:8, xp=35:4, fp=1 | c=180:20, xp=300:20 | 8 / 12 / 16 |
| 4 | c=600, xp=1,200 | c=70:10, xp=60:6, fp=1 | c=300:30, xp=600:40 | 10 / 15 / 20 |
| 5 | c=900, xp=2,000 | c=90:12, xp=90:8, fp=1 | c=450:40, xp=1,000:60 | 12 / 18 / 24 |

Chapter XP rule: the chapters of an area pay about 35% of that band's XP between them, split by level span. Chapter Petals: band 1 150 to 600 rising by zone, band 2 600 to 1,300, band 3 2,600, band 4 5,000, band 5 7,500, final 10,000. The area benefit and region guide are paid once, at the Seal.

Titles by Seal count (order-free, reuses the existing four): 1 Seal **Lamplighter** (new), 3 **Field Hand**, 5 **Pathfinder**, 7 **Hollow Ranger**, 9 **Wren's Companion**, 12 **Keeper** (new), final chapter **Roundwalker**.

## 2. Main line: Wren's Almanac (28 chapters)

Every chapter has: (a) an adopt/raise step, (b) a gardening step, (c) a folk step, (d) a Leaf or Seal step. Zone chapters end in a **Leaf** (Wren binds that zone's leaf into the section, all earlier steps done). The area's last chapter ends in the **Seal** (Standing 80%). Chapters of an area can be started in any order once the zone is reached; steps inside a chapter are ordered only where one needs the other (the bed follows the lamp). "Optional" items never block.

Slot note (pass 4, checked against `stop_adopt.php`): `raise` counts stops raised by anybody, and the Hearth counts a stop you founded, so "light it, hand it back, walk on" works with one slot. The Maplewold main line adopts 3 times (the 3 prairie road stops), Maizehollow and Mistmoor 2 times each. No main step needs two adoptions at once or a tier 4 before band 4.

### 2.1 The Maplewold, band 1 (7 chapters)

**M1. The First Lamp.** Bramblesweep Prairie, Lv 1-4. Giver: Clover Puddlejump. Repair: Sugar Shack (existing).
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Reach the Maplewold, read Wren's cover note | `visit` | 1 |
| 2 | **Finish the Maplewold jigsaw on Advanced or Expert.** Its Puzzle Pals are released and start waiting at Maplewold places on your map (Expert also earns the trophy) | `puzzle pic:jig-maplewold,tier:advanced+` (hooks `ppal_on_solve`) | 1 |
| 3 | Sow Wren's seed packet: harvest 2 staples (oats, lentil) | `grow staple 2` | 1-2 |
| 4 | Do three things at the dark market hamlet, then adopt it (first adoption free) | `adopt zone:1` | 1-2 |
| 5 | Build its Bench & lantern post | `raise tier:1,zone:1` | 2-3 |
| 6 | A lost lamb: find it off the road and walk it back to the hamlet | `escort who:lamb,to:stop` | 2-3 |
| 7 | Rebuild the Sugar Shack (3 Flint + 50; 2 Timber Planks; 1 Rope + 100) | `stage` x3 | 3-4 |
| 8 | Prairie leaf | `seal leaf` | 4 |
Leaf note: "The old book said the prairie lamps were lit 'by whoever is passing'. I have crossed that out and written your name."

**M2. Hand It Back.** Old Maplewood, Lv 4-7. Giver: Bodkin and Thrum. Repair: the mill sluice.
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Find the Thousand Rings Stump, and become a Regular at the old mill village in the wood (off-road) | `find` 1, `regular zone:2` | 4-5 |
| 2 | Release your first stop (it stays lit) and adopt the second prairie road stop, the one the Maplewood path leaves from | `adopt` (road stop), alt `regular` at a lit road stop | 4-5 |
| 3 | Light it: two lamps now, one glowing road between them | `raise tier:1` x2 | 5-6 |
| 4 | Something is in the mill sacks: a Barn Rat (scaled to 6). Fight, charm, or leave 2 meals by the door as a decoy | `defeat creature:barn-rat`, alt `deliver meal:2` | 5-6 |
| 5 | Mend the sluice with the tinkers (2 Timber Planks, 1 Rope; then 100 Petals) | `stage` x2 | 6-7 |
| 6 | Grow apples or hops and bring 3 to the mill's bake day | `plant crop:apple:3` or `crop:hops:3` | 6-7 |
| 7 | Maplewood leaf | `seal leaf` | 7 |
Leaf note: "The old book says the mill 'never stops'. It had stopped. It says so now, and that you started it."

**M3. The Lost Lantern.** Foghorn Shallows, Lv 7-10. Giver: Fenna Reedwhistle. Repair: Lighthouse of the Lost Lantern.
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Find the Lighthouse of the Lost Lantern | `find` 1 | 7 |
| 2 | Become a Regular at a Shallows village (jetty or ferry landing; off-road, no tiers) | `regular zone:3` | 7-8 |
| 3 | A stranded fisher on the sandbar: walk him back to the jetty | `escort who:fisher,to:stop` | 8 |
| 4 | Open a Little stall at the road stop you hold (tier 2) | `raise tier:2` | 8-9 |
| 5 | Carry lamp oil from the stall to the lighthouse (2 Beeswax) | `deliver item:beeswax:2,to:lighthouse` | 9 |
| 6 | Relight the big lamp (3 Dressed Stone + 150; 2 Rope, 2 Timber Planks) | `stage` x2 | 9-10 |
| 7 | Grow goldenrod to bloom for the keeper's bees, walk the Tide Track to the Ferry Landing (Hobb's first "not yet"), Shallows leaf | `plant flower:goldenrod:1`, `seal leaf` | 10 |
Leaf note: "The old book calls it the Lost Lantern. I have left the name. It suits it better now that it is found."

**M4. The Dam Debt.** Beaverdam Fens, Lv 8-11. Giver: Marsh-reeve Tully Sedgewick of Heron Stilt Village (new local). Repair: the causeway sluice.
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Find Heron Stilt Village and the Dam Debt | `find` 2 | 8-9 |
| 2 | Settle the Dam Debt: hear both sides, bring the council what it is owed (errand `na-dam-debt`: talk x2, deliver 3 Birch Log) | `help errand:na-dam-debt` | 8-10 |
| 3 | Build the agreed sluice gate (4 Timber Planks, 2 Rope, 200 Petals) | `stage` | 9-10 |
| 4 | Adopt and light the third prairie road stop (the last dark lamp on the home road), and become a Regular at the causeway croft that owns the paddy | `adopt`, `raise tier:1`, `regular zone:4` | 9-10 |
| 5 | Grow wild rice and make the first Seed Bed hand-in (3) | `plant bed:1` | 10-11 |
| 6 | Optional: raise any Maplewold stop to its Wishing well (tier 3): it hums four notes | `raise tier:3`, `opt=1` | 10-11 |
| 7 | Fens leaf | `seal leaf` | 11 |
Optional: Beaverdam Tunnels delve; thread "The singing well".
Leaf note: "The old book says the beavers 'trespassed upon the road'. Crossed out. They kept the water when no one kept the sluice."

**M5. Three Chairs Short.** The Frostbitten North, Lv 11-13. Giver: Ottilie Kettlewick. Repair: Aurora Camp lamps.
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Find Aurora Camp | `find` 1 | 11 |
| 2 | Become a Regular at a North village (hot spring or moss shrine) | `regular zone:5` | 11-12 |
| 3 | Hang the camp lamps (4 Beeswax, 3 Rope; then 250 Petals) | `stage` x2 | 11-12 |
| 4 | The cook's wolf (Bramble Wolf scaled to 12): shoo, charm, or leave 2 meals at the tree line | `defeat creature:bramble-wolf`, alt `deliver meal:2` | 12 |
| 5 | Second Seed Bed hand-in (5 wild rice) | `plant bed:2` | 12-13 |
| 6 | Cook for Ottilie's first supper (3 home-cooked meals, one with raspberry or wild rice) | `stage meal:3` | 13 |
| 7 | North leaf | `seal leaf` | 13 |
Optional: thread "The stranger with no name" (tea paid with a button).
Leaf note: "The old book lists nine at the camp table. Ottilie counted six. I have written six, and left room."

**M6. One Stone a Year.** Cairnback Ridge, Lv 12-15. Giver: Warden Hobb Stiles. Repair: the cairns.
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Find Cairnback Pass and the Cairn Keeper's Hut | `find` 2 | 12-13 |
| 2 | Become a Regular at the watchtower village (the door stop) | `regular zone:6` | 12-13 |
| 3 | Walk old keeper Garrow Stonecount (new local) from the Hut up to the Pass with this year's stone | `escort who:garrow,from:hut,to:pass` | 13 |
| 4 | Rebuild the cairns (6 Dressed Stone; 4 Flint + 300; one stone of your own: 1 uncommon find) | `stage` x3 | 13-14 |
| 5 | Third Seed Bed hand-in (8 wild rice): the bed is full | `plant bed:3` | 14 |
| 6 | Your Hearth stop has a Little stall (tier 2; a stop you founded counts). A Long-table hall is optional | `raise tier:2,hearth`; `raise tier:4,hearth` `opt=1` | 14-15 |
| 7 | Ridge leaf: from the tower at night, the road you lit | `seal leaf` | 15 |
Optional: Hollow Peak delve.
Leaf note: "The old book says 'a stone for every walker, every year'. The newest stone is older than I am. There is a new one on top."

**M7. The Lighting** (capstone). Whole Maplewold, Lv 15. Giver: Wren.
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | The road glows end to end: 60% of Maplewold road stops lit (2 of 3) | `raise lit:60%` | 13-15 |
| 2 | Make a Friend among the Maplewold's townsfolk | `friend` 2 | any |
| 3 | The Great White Owl: beat, charm, or answer it three evenings from Aurora Camp (`r_na_owl_hoot`). Same terms each way: the Aurora Road stays lampless and the Owl guards it | `defeat lair:great-white-owl`, alt stop act x3 | 15 |
| 4 | Bring a wild-rice dish and an apple dish to your Hearth stop for the supper | `deliver meal:2,to:hearth` | 15 |
| 5 | Maplewold Seal: Standing 80%. Hobb fires the Cairnback beacon, Wren arrives on foot and binds the section | `seal standing:80` | 15 |
Reward: Maplewold Seal, region guide, `native_plus:10`, title Lamplighter, Wren's desk at the Hearth stop. Opens: Cairnback Climb high road, Northern Rim Pass.
Seal letter: "The old book said the Maplewold's lamps 'are lit each dusk'. I have crossed it out and written: lit, by a friend, who came back. Also, friend: the last page of the old book has been cut out. I had never noticed."

### 2.2 Maizehollow, band 2 (4 chapters)
Signature crop amaranth, flower marigold, bed at the granary-side mill.

**C1. The Granary.** Cornrow Flats, Lv 15-17. Giver: Hazel Dewberry. Repair: Granary (existing).
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Reach Maizehollow, cover note | `visit` | 15 |
| 2 | Harvest 2 staples (corn, black bean) | `grow staple 2` | 15 |
| 3 | Adopt and light a Flats road stop (the granary-side one) | `adopt zone:1`, `raise tier:1,zone:1` | 15-16 |
| 4 | Mice in the grain: Barn Rats (scaled to 16) x3. Fight, charm, or bring the mill cat 2 meals | `defeat creature:barn-rat` 3, alt `deliver meal:2` | 16 |
| 5 | Buy amaranth seed at the Market of a Thousand Chilies and harvest 3 | `plant crop:amaranth:3` | 16-17 |
| 6 | Rebuild the Granary (existing 3 stages) | `stage` x3 | 16-17 |
| 7 | Flats leaf | `seal leaf` | 17 |
Leaf note: "The old book says the Granary 'feeds the Flats'. It fed the mice. I have written what it holds today, by the sack."

**C2. The Lost Trader.** The Quetzal Tangle, Lv 18-20. Giver: Pell Quickthistle (he has a letter for her).
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Find the Stepped Seed Temple | `find` 1 | 18 |
| 2 | Release the Flats stop and adopt and light the next Maizehollow road stop (the one toward the Tangle) | `adopt`, `raise tier:1` (road stop) | 18 |
| 3 | Find trader Marlo Pepperpack (new local) in the Tangle and walk her to your lit stop | `escort who:marlo,to:stop` | 18-19 |
| 4 | Her ledger was taken by a Mischief Monkey (scaled to 19): fight, charm, or swap it 3 papaya | `defeat creature:mischief-monkey`, alt `deliver item:papaya:3` | 19 |
| 5 | Open a stall at that stop so she can trade (tier 2) | `raise tier:2` | 19-20 |
| 6 | First Seed Bed hand-in (5 amaranth) | `plant bed:1` | 19-20 |
| 7 | Tangle leaf | `seal leaf` | 20 |
Optional: Jaguar Root Caves delve.
Leaf note: "The old book has 'a stall at every bend of the Tangle'. There is one. It is a good one."

**C3. Cisterns.** Cactusbristle Barrens, Lv 21-23. Giver: Professor Puff Morelby.
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Find the Cenote of Echoes | `find` 1 | 21 |
| 2 | Rebuild the cenote steps and the cistern (6 Dressed Stone + 400; 4 Rope, 4 Timber Planks) | `stage` x2 | 21-22 |
| 3 | Become a Regular at a thirsty Barrens village (off-road) | `regular zone:3` | 21-22 |
| 4 | Carry a cistern jar from the cenote to two Barrens villages | `deliver item:cistern-jar:2,from:cenote,to:village*2` | 22 |
| 5 | A Gila Dragon basks on the cistern lid: fight, charm, or tempt it off with 2 nopal | `defeat creature:desert-gila-dragon`, alt `deliver item:nopal:2` | 22-23 |
| 6 | Marigold in bloom by the cistern, second Seed Bed hand-in (8 amaranth) | `plant flower:marigold:1`, `plant bed:2` | 22-23 |
| 7 | Barrens leaf | `seal leaf` | 23 |
Optional: Cenote Underway delve.
Leaf note: "The old book says water 'is found here'. It is carried here. I have named who carries it."

**C4. The Beacon.** Smokecap Volcanoes, Lv 24-25. Giver: Warden Hobb Stiles.
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Walk the Ash Road and find the Cloudcorn Terraces | `find` 1 | 24 |
| 2 | Become a Regular at the Smokecap watchtower village | `regular zone:4` | 24 |
| 3 | A muleteer stuck in the ashfall: walk him down to the tower | `escort who:muleteer,to:stop` | 24 |
| 4 | Third Seed Bed hand-in (12 amaranth): tier 2 stalls now sell it | `plant bed:3` | 24-25 |
| 5 | Stalls open along the road: 2 Maizehollow road stops at tier 2 (C2's counts as one) and your Hearth among them | `raise tier:2` x2, one `hearth` | 24-25 |
| 6 | Build the beacon brazier (6 Flint, 4 Dressed Stone, 500 Petals) | `stage` | 25 |
| 7 | Maizehollow Seal: Standing 80% | `seal standing:80` | 25 |
Optional: Smokecap Caldera lair (the fire salamander), beat or charm.
Reward: Seal, guide, `sell_bonus:10`.
Seal letter: "The old book said Maizehollow 'wants for nothing'. I have written what it wanted, and that it has it. Pell showed me letters marked 'The Walker, wherever met'. Nobody has collected one in his lifetime."

### 2.3 Mistmoor, band 2 (4 chapters)
Signature crop barley, flower heather, bed at the old mill by the Footbridge.

**N1. The Footbridge.** Hedgerow Downs, Lv 15-17. Giver: Willow Rootstock. Repair: Footbridge (existing).
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Reach Mistmoor, cover note | `visit` | 15 |
| 2 | Harvest 2 staples (rye, leek) | `grow staple 2` | 15 |
| 3 | Adopt and light a Downs road stop (the one by the mill stream) | `adopt zone:1`, `raise tier:1,zone:1` | 15-16 |
| 4 | A carter lost in the hedgerow lanes in the fog: walk him to the mill lamp | `escort who:carter,to:stop` | 16 |
| 5 | Barley seed from the seed swap: harvest 3 | `plant crop:barley:3` | 16-17 |
| 6 | Build the Footbridge (existing 3 stages) | `stage` x3 | 16-17 |
| 7 | Downs leaf | `seal leaf` | 17 |
Leaf note: "The old book says 'cross at the bridge'. Willow has waded for years. It is true again, slowly, and she insists on slowly."

**N2. The Ley Walk.** Fernhollow Wood, Lv 18-20. Giver: Professor Puff Morelby.
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Find the Standing Stones and the Fairy-ring Clearing | `find` 2 | 18 |
| 2 | Release the Downs stop and adopt and light the next Mistmoor road stop (toward Fernhollow) | `adopt`, `raise tier:1` (road stop) | 18 |
| 3 | Set three fallen ley stones upright (5 Dressed Stone + 300; 3 Rope; 1 uncommon find) | `stage` x3 | 18-19 |
| 4 | A Will-o'-Wisp (scaled to 19) leads folk off the path: fight, charm (it becomes the stone's lamp), or plant heather at the stone | `defeat creature:will-o-wisp`, alt `plant flower:heather:1` | 19 |
| 5 | Open a stall at that stop (tier 2): your Mistmoor Hearth | `raise tier:2,hearth` | 19-20 |
| 6 | First Seed Bed hand-in (5 barley) | `plant bed:1` | 19-20 |
| 7 | Wood leaf: lit stones now link as fast-travel nodes | `seal leaf` | 20 |
Leaf note: "The old book says the stones 'show the way'. They show it when a lamp is near. Morelby says this proves his theory. It does not, quite."

**N3. A Smuggler Wants Out.** Fjordfang Coast, Lv 21-23. Giver: Fenna Reedwhistle.
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Find the mouth of the sea caves (Smugglers' Tide) | `find` 1 | 21 |
| 2 | Become a Regular at the Fjordfang jetty village (off-road) | `regular zone:3` | 21 |
| 3 | Walk Dab Tarrow (new local) out of the caves to the jetty | `escort who:dab,from:sea-caves,to:stop` | 21-22 |
| 4 | Give him an honest stall: any Mistmoor road stop at tier 2 (N2's counts) | `raise tier:2` | 22 |
| 5 | Return his last crate to its owner at the Downs market | `deliver item:marked-crate:1,from:jetty,to:downs-market` | 22-23 |
| 6 | Heather in bloom, second Seed Bed hand-in (8 barley) | `plant flower:heather:1`, `plant bed:2` | 22-23 |
| 7 | Coast leaf | `seal leaf` | 23 |
Optional: Sea-cave Smugglers' Run delve.
Leaf note: "The old book has no smugglers in it at all. I have added one, under 'stallholders'."

**N4. Lamps in the Fog.** The Long Night Fells, Lv 24-25. Giver: fell-herder Bracken Tuppence (new local).
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Find the Northern Lights Sauna | `find` 1 | 24 |
| 2 | Become a Regular at a Fells village | `regular zone:4` | 24 |
| 3 | Bracken's goats went into the fog: find the three and bring them to the lamp (errand `nwe-goats`) | `help errand:nwe-goats` | 24 |
| 4 | Third Seed Bed hand-in (12 barley): the stalls have barley bread | `plant bed:3` | 24-25 |
| 5 | A lamp in sight of the next: 60% of Mistmoor road stops lit | `raise lit:60%` | 24-25 |
| 6 | Build the twin beacon (6 Flint, 4 Timber Planks, 500 Petals) | `stage` | 25 |
| 7 | Mistmoor Seal: Standing 80% | `seal standing:80` | 25 |
Optional: Barrow of the Frost Toad lair, beat or charm.
Reward: Seal, guide, `free_travel`.
Seal letter: "The old book said the moor 'cannot be crossed in fog'. I have written: it can, lamp to lamp, and here is where they are. Somebody has been leaving one lamp lit on the Fells for years. Nobody here will own to it."

### 2.4 The Crossing (joint finale of band 2)
Whole of bands 1-2, Lv 25. Giver: Wren, with Fenna. (Its ceremony is the base story's "Two lamps".) **Pass 4: the five tier 3 doors open at step 1, the moment both Seals are held** (the Seal is the only hard block). Steps 2-6 are the optional celebration, at leisure; they pay the recipe and the letter.
| # | Step | Kind | Lv |
|---|---|---|---|
| 1 | Hold the Maizehollow and Mistmoor Seals | `seal seals:CA,NWE` | 25 |
| 2 | Carry a lit lantern from your Maizehollow Hearth stop to your Mistmoor Hearth stop, through the Maplewold, past the first stop you lit | `deliver item:keepers-lantern:1,from:hearth@CA,to:hearth@NWE` | 25 |
| 3 | Bake the Two-lamp loaf (amaranth and barley; recipe given here) | `plant crop:amaranth:2`, `crop:barley:2`; `stage meal:1` | 25 |
| 4 | Become a Regular at the Ferry Landing on the Tide Track (an off-road place, it has no tiers) | `regular` (Ferry Landing) | 25 |
| 5 | Walk Wren down the Tide Track to the Ferry Landing | `escort who:wren,to:ferry-landing` | 25 |
| 6 | Hobb's beacon is answered. Board Fenna's first ferry out | `visit` | 25 |
Reward: step 1 opens all five tier 3 doors (Isthmus Track, Ferry Cove, Fell Pass, Smugglers' Tide, Tide Track). Steps 2-6 (optional): recipe Two-lamp loaf. Title Field Hand comes with the third Seal (section 1.4), not from this chapter.
Letter: "The old book said the two beacons 'speak nightly'. Hobb's has never once been answered. Last night it was. He gave it as one hundred percent."

### 2.5 Tiers 3-5: one chapter per area (11 chapters)
Seven step slots, the same in every area. Flagship Repair, its giver and its three stages are the existing chapter's (`journey_seed`, `journey_seed2`).

| Slot | Kind | Band 3 Lv | Band 4 Lv | Band 5 Lv | What |
|---|---|---|---|---|---|
| S1 Arrive | `visit`, `grow staple 2`, `adopt` + `raise tier:1` | 25-26 | 35-36 | 45-46 | Cover note, first lamp at the landing stop |
| S2 Garden | `plant crop:sig:N`, `plant bed:1..3`, `plant flower:x:1` | 26-33 | 36-43 | 46-53 | Seed Bed, three hand-ins, spread along the chapter |
| S3 Folk | `escort` or `defeat` (with `alt`) | 28-30 | 38-40 | 48-50 | see table |
| S4 Repair | `stage` x3 | 29-32 | 39-42 | 49-52 | flagship |
| S5 Reach | `find` 2 + `raise lit:P%` | 31-33 | 41-43 | 51-53 | the band's network problem |
| S6 Hearth | `raise tier:T,hearth` | 33-35 | 43-45 | 53-55 | band 3 = tier 3 (well or pool), bands 4-5 = tier 4 (hall) |
| S7 Seal | `seal standing:80` | 35 | 45 | 55 | ceremony per base story |
Optional in every area: its delve and its lair (beat or charm).

**Band 3, "Across the water"** (S5: `lit:50%` of the area's road stops; the ferry, jetty and tower flavour is not a type requirement).
| Area, chapter, giver | S2 crop / flower / bed | S3 Folk | S5 finds | Seal letter (one line) |
|---|---|---|---|---|
| **Sunsprinkle: The Lighthouse**, Nettle Thornwhistle | breadfruit / frangipani / ferry-side orchard camp | `escort`: a supply-boat pilot stranded on Coralteeth Reef, to the Driftwood Tavern | Singing Waterfall, Turtle Nesting Beach | "The old book said the Isles 'lie beyond the road'. Crossed out. The road is wet here, that is all. A lamp was already lit on the far cay. Nobody keeps that cay." |
| **Rainroot: The Canoe Jetty**, Rowan Burrowman | yerba mate / passionflower / jetty-side herb croft | `defeat`: a Giant Anteater asleep on the jetty timber; alt: paddle the timber round (`deliver timber-plank:4`) | Pink River Dolphin Pools, Sky City Ruins | "The old book said the river 'cannot be kept'. I have written: it is kept at every jetty where someone pours mate." |
| **Olivewhistle: The Hill Windmill**, Dew Dewberry | olive / lavender / orchard camp below the mill | `escort`: the goatherd's bellwether, from Goatbell Hills to the windmill stop | Goat Path Vineyards, Lemon Grove Monastery | "The old book said the mill light 'guides the boats'. It was a lantern someone left. Now it is a mill, with a light, on purpose." |
| **Birchbramble: The Drying Barn**, Ginger Thornwhistle | buckwheat (plum counts for hand-in 2) / chamomile / the barn's mill stop | `defeat`: a Beaver Foreman damming the Reedmarsh causeway; charm = a council, as in the Fens; alt `deliver item:birch-log:4` | Amber Woods, Stork Chimney Village | "The old book said the steppe 'has one road'. It has one road and a great many people who now use it. Morelby says the Waythread does cross water. It is simply deep." |

**Band 4, "The long table"** (S5: no dark stop between the gate and the hall: `lit:60%`, counted along one unbroken road).
| Area, chapter, giver | S2 crop / flower / bed | S3 Folk | S5 finds | Seal letter (one line) |
|---|---|---|---|---|
| **Dunewhisper: The Oasis Waterwheel**, Holly Barkley | date / damask rose / the oasis stop | `escort`: a caravan straggler from the Endless Dunes to the oasis hall | The Oasis That Moves, Cedar Sanctuary | "The old book said 'no one stops in the Dunes'. Everyone stops. There is a table. I sat at it." |
| **Spicepeak: The Tea Terraces**, Sage Dewberry | turmeric (ginger counts for hand-in 2) / sacred lotus / croft below the terraces | `defeat`: a Dhole Pack (Lv 43, scaled to 39) on the terrace wall; alt: leave 3 meals at the far wall | Prayer-flag Pass, Silk Road Caravanserai | "The old book said the pass 'is for pilgrims'. I have written: and for whoever is hungry at the top of it." |
| **Greatcanopy: The Storyteller's Platform**, Lark Fernsway | fonio / wild gardenia / the platform's hall stop | `escort`: the old storyteller from the Shea Sahel to the Platform | Mud Mosque Library, Gorilla Glade | "The old book said the stories 'are told nightly'. They had stopped. The first new one was about you. The Grey Cloaks were here. They are households, friend, not ghosts." |
| **Thornacre: The Waterhole Pump**, Poppy Puddlejump | teff / king protea / the road stop the Baobab Inn's path leaves from | `defeat`: a Meerkat Mob (Lv 38) that has dug in round the pump; alt: fill the far trough (`deliver item:water-skin:3`) | Coffee Ceremony Hut, Flamingo Shallows | "The old book said the plain 'belongs to the herds'. It does. The bench under the baobab belongs to everyone else. A stranger sat with us and left before pudding. There is a page sewn in that coat." |

**Band 5, "The far end is the near end"** (S5: `lit:60%`; S6 adds one stop act, "light the oldest lamp", which works once the Hearth is a hall).
| Area, chapter, giver | S2 crop / flower / bed | S3 Folk | S5 finds | Seal letter (one line) |
|---|---|---|---|---|
| **Blossomreach: The Red Bridge**, Fennick Barkley | persimmon / cherry blossom (`sakura`) / orchard by the bridge | `escort`: a tea-pilgrim through the Thousand Gates to the Cherry Blossom Teahouse | The Thousand Gates, Pearl Diver Cove | "The old book said the Clovercove road 'is the short way home'. It is closed, and I have written closed, in pencil." |
| **Monsoon Tangle: The Stilt Boathouse**, Moss Petalwing | rice / sampaguita / paddies under the boathouse | `defeat`: a Proboscis Monkey (Lv 48) sunning on the slipway; alt `deliver item:rice:5` to the far bank | Lantern Festival River, Root-wrapped Temple | "The old book said the paddies 'feed the Tangle'. They feed three areas. I counted the canoes." |
| **Coralscatter: The Reef Garden**, the reef keeper (existing chapter NPC, Tansy text removed) | taro / tiare / the Reef Garden's beds | `escort`: a navigator who lost the Starpath, to the Kava Circle | Starpath Canoe, Stone Head Watchers | "The old book said 'the reef sings'. It hums. Four notes. You know them. The Stranger has stopped leaving, Keeper. They are waiting at a gate." |

### 2.6 Final chapter: The Last Page
Needs all 14 Seals. Lv 55 (no fight). Giver: Wren.
| # | Step | Kind |
|---|---|---|
| 1 | Hold all 14 Seals | `seal seals:14` |
| 2 | Walk the Clovercove road from the Blossomreach side | `visit` (the gate) |
| 3 | Sow one signature seed, any of the 14, in the empty bed at the Clovercove Gatehouse | `plant crop:any-signature:1` |
| 4 | The Stranger asks if there is tea: bring any tea | `deliver item:tea:1,to:gatehouse` |
| 5 | Walk the Stranger from the Gatehouse to your first Hearth stop | `escort who:stranger,to:hearth@NA` |
| 6 | Trim the lamp at the first stop you ever lit | stop act (`raise tier:1`, already true) |
| 7 | Sign the Roll at Wren's desk | `seal leaf` |
Reward: title Roundwalker, Keeper's Lantern (yard decor), the Whole Map page, the Roll of Keepers page.
Letter: "Dear Keeper, the old book said the Round 'is walked each year'. I have not crossed that out. I am going to go and see if it is true."

## 3. Side quests (80 after the pass 4 trim)

Kinds: **L** lost folk, **C** creature trouble (fight or charm, each has a peaceful `alt`), **D** delivery, **G** garden favour, **T** stop thread (multi-day, Regular or better), **H** stop happening (available on that happening's day). `R` = repeatable at leisure for Regulars (can be done again any later day it is on offer; nothing expires).
A few at a time: at most 3 errands on offer per area, picked from those whose trigger is met.

**Pass 4 trim (target 80-100 side quests, was 94 + 36 = 130).** Applied: (1) the cast-thread cut in 3.5 (36 to 21) plus Fusby's band 1 thread (to 20); (2) the 14 happening errands (`na-s11`, `ca-s06`, `nwe-s04` and every tier 3-5 `s06`) stop being quests: each stays as a one-off **happening act** (a `stop_acts` row with its `hp=` condition) that keeps its first-time extra. Their rows stay below, marked *act*. Result: 80 area side quests + 20 cast threads = 100. Reward tables in section 4 are unchanged.

### 3.1 The Maplewold (12)
| id | Kind | Giver, stop type | Trigger | Steps | Reward | Extra (first time) |
|---|---|---|---|---|---|---|
| `na-s01` Within Sight of the Road | L | Sorrel Inkpot, camp or tower | first prairie stop at tier 1 | find Sorrel at a prairie hidden place; escort her to the lit stop; walk one glowing segment with her | c=60, xp=40 | `page=sorrel-map-na` + one unfound hidden place marked "?" on the area map |
| `na-s02` First Sack (R) | D | Pell Quickthistle, inn | any Maplewold stop at tier 2 | first time: 3 old letters to 3 lit stops, any order. After: 1 letter between two lit stops | first c=90, xp=60, item=beeswax:2; after c=25:5, xp=12:2, fp=1 | `title=Second Post` |
| `na-s03` Something in the Oats | C | Weigher, market hamlet | Regular at a prairie stop | Tunnel Mole (scaled to 3): fight, charm; alt: plant 2 lentil at the bed edge (garlic is no Maplewold crop) | c=50, xp=40 | treasure seed (blueberry) x1 |
| `na-s04` Hops for the Bake Day (R) | G, H | miller, mill | mill at tier 1, `hp=bake_day` or `bread_day` | hand in 3 apples or 3 hops | c=30:5, xp=12:2, fp=1 | `unlock=recipe:mill-day-apple-loaf` |
| `na-s05` The Jam Jar | T (4 beats) | Professor Puff Morelby, herb or mill | Thousand Rings Stump found, Regular at a Maplewood stop | count the rings (`r_na_stump_rings`); jar by a bare bed; jar by a planted bed; the thin rings | thread pay | `page=waythread-first-guess` |
| `na-s06` Oil for the Lost Lantern (R) | D | lighthouse keeper, tower | chapter M3 done | bring 2 Beeswax, trim the wick (`r_na_trim_wick`) | c=25:5, xp=12:2, fp=1 | `unlock=theme:lantern-glass-post` (tier 1, jetty and ferry) |
| `na-s07` Gulls on the Catch | C | Fisher, jetty | a jetty at tier 2 | Herring Gull x2 (or a Sea Otter Bandit): fight, charm; alt: build a scare-gnome (2 Rope, 2 Straw Mulch) | c=80, xp=70 | `unlock=shop:smokehouse-rack` (smoked fish at Shallows stalls) |
| `na-s08` The Heron Who Kept the Toll | T (4 beats) | stilt-villager, any Fens stop | Heron Stilt Village found, Regular at a Fens stop | a Grey Heron stands on the causeway; what it wants; a fish a day; it steps aside for good | thread pay | `unlock=pal:mw-toll-heron` |
| `na-s09` Goldenrod by the Paddy | G | herb croft | Seed Bed first hand-in | grow 3 goldenrod to bloom, hand them in at the paddy | c=70, xp=60 | `unlock=place:drowned-paddy-boardwalk` + treasure seed (cranberry) x1 |
| `na-s10` The Bather in the Snow | L | attendant, hot spring | a North stop at tier 1 | find a gnome who took the wrong path from the spring (Aurora Road); escort back | c=90, xp=80 | `unlock=recipe:snowshoe-stew` |
| `na-s11` Snow Gnome Day *act* | H | anyone, any North stop | `hp=snow_day` or `snow_gnome` | build the snow gnome (act), carry 1 meal to the next stop | c=20:5, xp=10:2, fp=1 | `title=Snow Neighbour` |
| `na-s12` The Cairn Count | T (5 beats) | Garrow Stonecount, Cairn Keeper's Hut | chapter M6 done | read the oldest stone; count down the years; the gap; the newest old stone; its mark is a button | thread pay + item=building-stone:2 | `page=cairn-count` + `unlock=place:walkers-bivouac` |

Also `na-dam-debt` (used by chapter M4, not counted above): talk to the beaver council, talk to the stilt-villagers, deliver 3 Birch Log. c=80, xp=70.

### 3.2 Maizehollow (8)
| id | Kind | Giver, stop type | Trigger | Steps | Reward | Extra (first time) |
|---|---|---|---|---|---|---|
| `ca-s01` Sorrel and the Mirage | L | Sorrel Inkpot | first Maizehollow stop at tier 1 | find her in the Barrens, mapping a lake that is not there; escort to the nearest lit stop | c=150, xp=200 | `page=sorrel-map-ca` + one hidden place marked |
| `ca-s02` Chilies to the Dark Stalls (R) | D | Stallholder, Market of a Thousand Chilies | 2 Maizehollow stops at tier 2 | carry 3 chili pepper from the market to any tier 2 stall | c=35:6, xp=20:3, fp=1 | `unlock=shop:chili-strings` |
| `ca-s03` The Leafcutter Road | C | herb croft | Seed Bed first hand-in | Leafcutter Column (scaled to 18) stripping the amaranth: fight, charm; alt: plant 3 marigold as a decoy row | c=140, xp=180 | treasure seed (vanilla) x1 |
| `ca-s04` The Well That Answers | T (4 beats) | cistern-keeper, spring or market | chapter C3 done | shout down the cenote; it answers a different word; ask at the next stop; it is the next stop answering | thread pay | `unlock=place:the-second-echo` (in the Cenote Underway) |
| `ca-s05` Three Sisters | G | miller, granary-side mill | chapter C1 done | grow corn, black bean and chayote; hand in 2 of each | c=160, xp=220 | `unlock=recipe:three-sisters-stew` |
| `ca-s06` Lanterns Out *act* | H | anyone, any stop | `hp=market_dusk` or `lantern_walk` | carry a lantern along one lit segment to the next stop | c=35:6, xp=20:3, fp=1 | `unlock=theme:papel-picado-awning` (tier 1, market) |
| `ca-s07` The Vulture on the Waymark | C | Warden, tower | Ash Road found | Griffon Vulture on the Ash Road waymarker scaring the mule trains: fight, charm; alt: carry 2 meals to a ledge further off | c=220, xp=300 | `unlock=place:cinder-lee` (Ash Road shelter) + `title=Ash-Walker` |
| `ca-s08` The Temple Tally | D | seed-counter, Stepped Seed Temple | temple found | bring one seed each of 4 Maizehollow crops to the temple shelves | c=180, xp=240 | `page=seed-temple-tally`; the area's seed swaps stock tomatillo and chayote |

### 3.3 Mistmoor (8)
| id | Kind | Giver, stop type | Trigger | Steps | Reward | Extra (first time) |
|---|---|---|---|---|---|---|
| `nwe-s01` Sorrel and the Ring | L | Sorrel Inkpot | first Mistmoor stop at tier 1 | find her walking circles at the Fairy-ring Clearing; escort to the nearest lit stop | c=150, xp=200 | `page=sorrel-map-nwe` + one hidden place marked |
| `nwe-s02` The Tearoom's Missing Cup | T (4 beats) | tearoom host, inn | Thatchtop Tearoom found, Regular at a Downs stop | one cup short; who had it last; it is on the bridge rail; Willow was using it to bail | thread pay | `unlock=tea:moor-mist-blend` |
| `nwe-s03` Heather for the Hives (R) | G | beekeeper, herb or orchard | a herb or orchard stop at tier 1 | hand in 2 heather in bloom | c=35:6, xp=20:3, item=beeswax:1 | `unlock=shop:heather-honey` |
| `nwe-s04` Fog-blind *act* | L, H | Warden, tower or camp | `hp=fog_morning` | a traveller is somewhere between two stops: find, escort to the nearer lamp | c=40:6, xp=25:3, fp=1 | `title=Fog Lamp` |
| `nwe-s05` The Boar in the Barley | C | miller, mill | Seed Bed first hand-in | Wild Boar rooting up the bed: fight, charm; alt: fence it (3 Timber Planks, 2 Rope) | c=180, xp=240 | treasure seed (hazelnut) x1 |
| `nwe-s06` Honest Crates | D | Dab Tarrow, jetty | chapter N3 done | 3 crates from the jetty to 3 different stalls | c=200, xp=220 | `unlock=shop:smugglers-shelf` (one import from another area at the jetty stall) |
| `nwe-s07` The Ring Grows | T (5 beats) | Morelby's note on the noticeboard, any Fernhollow stop | Fairy-ring Clearing found | one more mushroom each visit; a gap; plant nothing, just tread the path; the ring closes; step inside | thread pay | `unlock=place:the-inner-ring` + `page=fairy-ring` |
| `nwe-s08` The Goat That Stayed | L | Bracken Tuppence, camp | chapter N4 done | a fourth goat nobody counted, at the Barrow's edge; escort to the Fells camp | c=220, xp=300 | `unlock=pal:mm-fell-kid` |

### 3.4 Tiers 3-5 (11 areas x 5 = 55 quests, + 11 happening acts)
Each area has one of each kind; the `H` row (`s06`) is a happening act after the pass 4 trim. Rewards follow the band scale (1.4); only the extra is listed.
`s01` in every area is **Sorrel is lost** (her recurring errand): trigger = first stop in the area at tier 1; find her at the place named; escort to the nearest lit stop; extra = `page=sorrel-map-<area>` + one unfound hidden place marked. Fourteen sheets make the Whole Map of the last page.

| id | Kind | Giver, stop | Trigger | Steps | Extra |
|---|---|---|---|---|---|
| **Sunsprinkle** `cb-s01` | L | Sorrel | (rule) | at the Sunken Gnome Galleon, tide came in | map sheet |
| `cb-s02` The Hoarder's Lens | C | keeper, tower | lighthouse stage 1 | Hermit Crab Hoarder has a lens shard: fight, charm; alt: offer a better shell (2 Spiral Shell) | `unlock=theme:shell-lamp-post` |
| `cb-s03` Breadfruit Boat (R) | D | ferryman, ferry | Seed Bed full | 3 breadfruit to another island's stall | `unlock=recipe:breadfruit-chips` |
| `cb-s04` Garlands for the Jetty | G | jetty | a jetty at tier 1 | 3 frangipani in bloom | treasure seed x1 |
| `cb-s05` Turtle Watch | T (5) | camp by Turtle Nesting Beach | beach found | sit up five nights; the last hatchling goes the wrong way | `unlock=pal:cb-hatchling` |
| `cb-s06` The Late Ferry (R) | H | ferry | `hp=ferry_late` | keep the lamp (act), bring the ferryman a meal | `title=Lampwatch` |
| **Rainroot** `sa-s01` | L | Sorrel | (rule) | half-way up the Sky City Ruins stairs, counting | map sheet |
| `sa-s02` Python on the Planks | C | jetty | chapter stage 2 | Emerald Python asleep across the new jetty; alt: wait it out with 2 meals | `unlock=theme:carved-prow-jetty` |
| `sa-s03` Salt for Every Table | D | market | Mirror Salt Flat found | a salt block from the flat to 3 stalls | `unlock=recipe:salt-flat-flatbread` |
| `sa-s04` Mate for the Jetty (R) | G | any jetty | jetty at tier 1 | 3 yerba mate | `unlock=tea:jetty-mate` |
| `sa-s05` The Dolphin Post | T (5) | ferry | Dolphin Pools found | a pink dolphin keeps bringing the same bottle back | `unlock=place:the-upper-pool` |
| `sa-s06` Ranch Market (R) | H | market | `hp=market_day` | carry a stall's load from the Gaucho Gnome Ranch | `unlock=shop:saddle-blanket` |
| **Olivewhistle** `se-s01` | L | Sorrel | (rule) | in the Labyrinth Isle, naturally | map sheet |
| `se-s02` Pelicans in Session | C | ferry | ferry at tier 1 | Pelican Parliament on the landing: fight, charm (get a ruling); alt: 5 Sardine | `title=Speaker to Pelicans` |
| `se-s03` First Pressing | D | Olive Press Piazza | Seed Bed first hand-in | oil jars to the Lemon Grove Monastery and 2 stalls | `unlock=recipe:lemon-olive-bread` |
| `se-s04` Lavender for the Sacks (R) | G | mill | windmill built | 2 lavender | `unlock=shop:lavender-sachet` |
| `se-s05` The Vine on the Goat Path | T (5) | orchard | Vineyards found | tie in one more yard of vine each visit | `unlock=place:the-top-terrace` |
| `se-s06` Kite Wind (R) | H | tower | `hp=kite_wind` | fly the signal kite to the next isle's tower | `unlock=theme:kite-mast-tower` |
| **Birchbramble** `ee-s01` | L | Sorrel | (rule) | in the Amber Woods, every tree the same | map sheet |
| `ee-s02` Bear at the Racks | C | mill (barn) | barn built | Black Bear eating the drying plums; alt: 2 Wild Honeycomb at the wood's edge | treasure seed x1 |
| `ee-s03` Painted Eggs | D | Painted Egg House | house found | 3 painted eggs to 3 stops | `unlock=theme:painted-shutters` |
| `ee-s04` For the Barn (R) | G | mill | Seed Bed first hand-in | 3 buckwheat or 3 plum | `unlock=recipe:buckwheat-plum-cakes` |
| `ee-s05` The Stork That Came Back | T (5) | any stop near Stork Chimney Village | village found | mend one chimney nest; a stork returns to it | `page=stork-chimneys` + `title=Stork-Neighbour` |
| `ee-s06` First Frost (R) | H | any | `hp=first_frost` | cover the stop's bed (act) with 2 Straw Mulch | `unlock=shop:straw-bed-cover` |
| **Dunewhisper** `mena-s01` | L | Sorrel | (rule) | at the Oasis That Moves, which moved | map sheet |
| `mena-s02` The Baboon in the Shade | C | spring | oasis stop at tier 1 | Hamadryas Baboon (Lv 40) will not leave the well-shade; alt: 3 dates further off | `title=Shade-Sharer` |
| `mena-s03` Water to the Far Stop (R) | D | oasis stop | waterwheel built | 2 water-skins to a dune stop | `unlock=theme:shade-sail-bench` |
| `mena-s04` Roses in the Ruins | G | herb | Hanging Garden Ruins found | 3 damask rose in bloom | `unlock=recipe:rosewater-date-sweets` |
| `mena-s05` The Caravan That Is Always Arriving | T (6) | inn | a hall in the area | dust on the horizon, six days running | `unlock=place:the-ninth-well` |
| `mena-s06` A Still Night (R) | H | shrine or camp | `hp=night_watch` | read the stars with the Grey Cloaks (act) | `page=star-roads` |
| **Spicepeak** `csa-s01` | L | Sorrel | (rule) | at Prayer-flag Pass, in cloud | map sheet |
| `csa-s02` The Rhino on the Road | C | tower | Lotus Delta stop at tier 1 | One-horned Rhino (Lv 44) asleep across the causeway; alt: 2 Sea Salt | `unlock=shop:yak-wool-blanket` |
| `csa-s03` Tea Down the Terraces (R) | D | Tea Garden Slopes | terraces built | a tea brick to the Caravanserai hall | `unlock=tea:caravan-brick-tea` |
| `csa-s04` Lotus for the Market | G | Floating Flower Market | Seed Bed first hand-in | 3 sacred lotus in bloom, 3 turmeric | `unlock=theme:lotus-garlands` |
| `csa-s05` One Flag a Day | T (5) | shrine | 3 stops lit | hang a flag for each lit stop | `unlock=place:the-wind-hermitage` |
| `csa-s06` Shrine Day (R) | H | shrine | `hp=shrine_day` | leave a small gift, as the Grey Cloaks do | `title=Button-Payer` |
| **Greatcanopy** `wca-s01` | L | Sorrel | (rule) | among the shelves of the Mud Mosque Library | map sheet |
| `wca-s02` The Drumstick Thieves | C | market | Drum Circle Market found | Grey Parrot Gossip (Lv 39) carrying off the drumsticks and the news; alt: 4 fruit | `unlock=shop:talking-drum` |
| `wca-s03` Overdue | D | Mud Mosque Library | library found | fetch 3 books back from 3 stops | `page=library-road-ledger` (a Roll clue) |
| `wca-s04` Fonio for the Pot (R) | G | hall stop | a hall in the area | 3 fonio | `unlock=recipe:fonio-feast-bowl` |
| `wca-s05` The Story With No Ending | T (6) | Storyteller's Platform stop | platform built | one more line each night; you are asked for the last | `unlock=place:the-listening-hollow` + `title=Tale-Ender` |
| `wca-s06` The Fiddler and the Drums (R) | H | camp | `hp=fiddler` | join the chorus (act) | `unlock=theme:drum-ring-fire` |
| **Thornacre** `esa-s01` | L | Sorrel | (rule) | in the middle of the Great Migration, going the other way | map sheet |
| `esa-s02` Larder Guest | C | Baobab Inn | the road stop below the Baobab Inn at tier 1 | Secretary Bird (Lv 40) stamping about in the larder; alt: 3 Wild Honeycomb outside | `title=Larder-Keeper` |
| `esa-s03` Three Cups | D | Coffee Ceremony Hut | hut found | roasted beans (given) to 3 halls or stalls | `unlock=tea:three-cup-ceremony` |
| `esa-s04` After the Fire | G | herb | Fynbos Fire Trails found | 3 king protea in bloom at the trailhead | treasure seed (coffee) x1 |
| `esa-s05` The Ostrich Is Rude | T (5) | tower (lookout) | pump built | it takes your seat five days running | `unlock=pal:ta-rude-ostrich` |
| `esa-s06` Sleepy Noon (R) | H | any | `hp=sleepy_noon` | 2 teff to the shade bench | `unlock=recipe:teff-flatbread` |
| **Blossomreach** `ea-s01` | L | Sorrel | (rule) | at the Thousand Gates, lost count at 600 | map sheet |
| `ea-s02` The Sleeper on the Path | C | shrine | bridge stage 1 | Giant Salamander (Lv 53, scaled to 47) asleep on the bridge approach; charm = it moves into the koi pond; alt: 3 fish left at the pond edge | `unlock=theme:moss-lantern-path` |
| `ea-s03` Pearls for the Lamp Glass | D | Pearl Diver Cove | cove found | 2 Seed Pearl to the area's oldest lamp | `page=oldest-lamp-ea` |
| `ea-s04` Persimmons on the Line (R) | G | orchard | Seed Bed first hand-in | 3 persimmon to dry | `unlock=recipe:dried-persimmon` |
| `ea-s05` The Gate With No Road | T (6) | Clovercove-side camp | Seal held | clear a little of the closed road each visit; it stays closed until all 14 | `unlock=place:clovercove-overlook` |
| `ea-s06` Lantern Walk (R) | H | any | `hp=lantern_walk` | walk one lit segment under the blossom | `title=Blossom-Walker` |
| **Monsoon Tangle** `sea-s01` | L | Sorrel | (rule) | inside the Root-wrapped Temple | map sheet |
| `sea-s02` King of the Slip | C | jetty | boathouse stage 1 | Peacock Mantis Shrimp (Lv 52, scaled to 48) holding the slip; alt: 4 fish at the far bank | `unlock=shop:crab-pot` |
| `sea-s03` Floating Market Run (R) | D | Floating Market | market found | 3 goods by canoe, stall to stall | `unlock=theme:boat-stall` |
| `sea-s04` Sampaguita Border | G | herb | Seed Bed first hand-in | 3 sampaguita in bloom, 5 rice | `unlock=recipe:festival-sticky-rice` |
| `sea-s05` Lanterns on the River | T (6) | ferry | Lantern Festival River found | float one lantern for each lit stop | `unlock=place:the-quiet-reach` |
| `sea-s06` Monsoon Day In (R) | H | inn | `hp=cosy_weather` | cook and share (act), 1 meal | `title=Rain-Guest` |
| **Coralscatter** `oc-s01` | L | Sorrel | (rule) | at the Stone Head Watchers: her last blank bit | map sheet (the fourteenth) |
| `oc-s02` Right of Way | C | camp | Fernmist Gullies reached | Tasmanian Devil (Lv 50) on the gully path; alt: 4 fruit, and patience | `title=Gave Way Politely` |
| `oc-s03` The Star Path | D | Starpath Canoe | canoe found | a shell-chart to 3 atoll jetties | `unlock=place:the-fourth-atoll` + `page=star-path` |
| `oc-s04` Taro for the Reef Garden (R) | G | Reef Garden stop | Seed Bed first hand-in | 3 taro | `unlock=recipe:taro-leaf-parcels` |
| `oc-s05` The Glowworm Count | T (6) | any stop near the Glowworm Grotto | grotto found | count them; one more each night; they are spelling the road | `unlock=theme:glow-lamp-post` |
| `oc-s06` Kava Night (R) | H | road stop by the Kava Circle | `hp=night_watch` | sit, tell one tale (act) | `unlock=shop:kava-bowl` |

### 3.5 Cast threads (the base story's "one thread per cast member per band")
Not part of the 80. Region-scoped rows in `stop_threads.txt`, Regular or better, at the cast member's favoured stop type. Titles only here; beats are a writing pass. Sorrel has no thread: her line is the fourteen `s01` errands.

| Cast | Band 1 | Band 2 | Band 3 | Band 4 | Band 5 |
|---|---|---|---|---|---|
| Pell | (`na-s02`) | To the Walker, wherever met | Post over water | A letter for a place that moved | The last letter in the sack |
| Bodkin and Thrum | `bridge` (exists) | The cistern lid | (cut) | (cut) | (cut) |
| Ottilie | `cheese` (exists) | Soup for two towns | (cut) | (cut) | (cut) |
| Fenna | `hat` (exists) | `boat` (exists) | (cut) | (cut) | (cut) |
| Hobb | `kite` (exists) | An answered beacon | (cut) | (cut) | (cut) |
| Fusby | (cut: chat line "Form 1: lamp, lit") | The weighing of the amaranth | (cut) | (cut) | (cut) |
| Morelby | (`na-s05`) | It follows the water | It cannot cross the sea | The oasis that moves | One living thing |
| Linnet | `well` (exists) | The same four notes | Both sides of the water | A chorus for an empty hall | The whole tune |
| The Stranger | `stranger` (exists) | A button for tea | Lamps on empty islands | Before pudding | The far side of the gate |

45 cells: 7 reuse existing threads, 2 are in the Maplewold set, 36 new before the trim. Extras: one Almanac page per cast member per band at most (Morelby's four theory pages, Linnet's four phrases, the Stranger's four Roll clues); the rest pay the plain thread reward. **Cut applied in pass 4**: bands 3-5 only for Pell, Linnet, Morelby and the Stranger (minus 15), and Fusby's band 1 "Form 1: lamp, lit" becomes a chat line (minus 1). **20 new threads.** Cut cells: Bodkin and Thrum, Ottilie, Fenna, Hobb and Fusby in bands 3-5; Fusby band 1. Ottilie's "Every seat" lives on as the band 4 ceremony.

## 4. Rewards and unlock map

### 4.1 Main line
| When | Unlocks |
|---|---|
| Any Repair built | the place reopens with its daily action (`JOURNEY_SPOTS`, as now) |
| Zone Leaf | Wren's leaf note, chapter Petals/XP/item; nothing gated |
| Seed Bed full | signature seed in that stop's seed swap, signature crop at the area's tier 2 stalls, garden happenings at the bed's stop, "Restored by" on the crop's page |
| Area Seal | region guide, the area benefit, Wren's desk at the Hearth stop, the next door(s) |
| Maplewold Seal | Cairnback Climb high road, Northern Rim Pass |
| Both tier 2 Seals held | the five tier 3 doors (The Crossing step 1); the rest of The Crossing pays recipe Two-lamp loaf |
| Tier 3-4 Seal | the door(s) out of that area that exist in `ROAD_PAIRS`: SE to MENA, EE to CSA, CSA to EA and SEA. CB has no onward door; SA's door to OC needs a tier 4 Seal (bands doc section 4) |
| All 14 Seals | the Clovercove road and the final chapter |

### 4.2 Side quest extras (first completion only)
| Kind of extra | Count | Sources |
|---|---|---|
| Secret places (hidden haven or wonder; each counts as a find) | 13 | `na-s09`, `na-s12`, `ca-s04`, `ca-s07`, `nwe-s07`, `sa-s05`, `se-s05`, `mena-s05`, `csa-s05`, `wca-s05`, `ea-s05`, `sea-s05`, `oc-s03` |
| Stop themes (cosmetic tier variants) | 12 | `na-s06`, `ca-s06`, `cb-s02`, `sa-s02`, `se-s06`, `ee-s03`, `mena-s03`, `csa-s04`, `wca-s06`, `ea-s02`, `sea-s03`, `oc-s05` |
| Recipes | 14 | `na-s04`, `na-s10`, `ca-s05`, `cb-s03`, `sa-s03`, `se-s03`, `ee-s04`, `mena-s04`, `wca-s04`, `esa-s06`, `ea-s04`, `sea-s04`, `oc-s04`, + Two-lamp loaf (The Crossing) |
| Teas | 4 | `nwe-s02`, `sa-s04`, `csa-s03`, `esa-s03` |
| Stall lines (shop items) | 11 | `na-s07`, `ca-s02`, `nwe-s03`, `nwe-s06`, `sa-s06`, `se-s04`, `ee-s06`, `csa-s02`, `wca-s02`, `sea-s02`, `oc-s06`, + amaranth/barley etc. from the beds |
| Titles | 14 | `na-s02`, `na-s11`, `ca-s07`, `nwe-s04`, `cb-s06`, `se-s02`, `ee-s05`, `mena-s02`, `csa-s06`, `wca-s05`, `esa-s02`, `ea-s06`, `sea-s06`, `oc-s02` (+7 main-line titles) |
| Companions (Puzzle Pals) | 4 | `na-s08`, `nwe-s08`, `cb-s05`, `esa-s05` |
| Treasure seeds | 7 | `na-s03`, `na-s09`, `ca-s03`, `nwe-s05`, `cb-s04`, `ee-s02`, `esa-s04` |
| Almanac pages | 14 map sheets + 9 others | every `s01`; `na-s05`, `na-s12`, `ca-s08`, `nwe-s07`, `ee-s05`, `mena-s06`, `wca-s03`, `ea-s03`, `oc-s03`, + cast pages |

Kept modest on purpose: nothing here gates a Seal or a door. Secret places add to the "places found" Standing row (they raise the count and the total together, so the 80% line does not move for a gnome who skips them). Treasure seeds are the only extras with a lasting stat effect: 7 in the whole world.

### 4.3 Repeatables for Regulars (15, + 14 happening acts)
`na-s02`, `na-s04`, `na-s06`, `ca-s02`, `nwe-s03`, and in every tier 3-5 area but Thornacre one of `D`/`G` (the rows marked R). The 14 happening acts (ex-`H`) repeat as acts. Each pays the band's repeatable reward and 1 friendship; each counts as one of the "things done at a stop" toward Regular, Local and Pillar.

## 5. Content counts and data files

### 5.1 Counts
| Content | Count |
|---|---|
| Main chapters | 28 (Maplewold 7, Maizehollow 4, Mistmoor 4, The Crossing 1, tier 3 x4, tier 4 x4, tier 5 x3, The Last Page 1) |
| Main-line steps | about 190 |
| Wren letters | 14 cover notes, 14 first-lamp notes, 14 Seal letters, 14 leaf notes, 2 joint letters = 58 |
| Area side quests | 80 (Maplewold 11, Maizehollow 7, Mistmoor 7, 11 areas x 5). Repeatable 15. Plus 14 happening acts (ex-`H`, not quests) |
| Main-line helper errands | 2 (`na-dam-debt`, `nwe-goats`) |
| Cast threads | 20 new after the cut (+7 existing reused) |
| New local NPCs | 5 (Tully Sedgewick, Garrow Stonecount, Marlo Pepperpack, Dab Tarrow, Bracken Tuppence) |
| Seed Beds | 14 (+1 empty bed at the Clovercove Gatehouse) |
| Secret places / stop themes / recipes / teas / pals | 13 / 12 / 14 / 4 / 4 |
| Quest items (carried, not sold) | about 12 (cistern-jar, marked-crate, keepers-lantern, old-letter, salt-block, painted-egg, water-skin, tea-brick, shell-chart, oil-jar, library-book, lantern) |

### 5.2 Data files (formats follow `calling_quests.txt`: pipe rows, `\n` for new lines, no pipe inside a field)
| File | New or changed | Rows |
|---|---|---|
| `data/journey_chapters.txt` | NEW. Replaces `journey_seed()` and `journey_seed2()` | `C|slug|area|zone (0 = whole area)|sort|title|giver npc slug|lv min-max|needs (chapter slugs or seals:..)|coins|xp|item|qty|title|benefit|benefit text|project name|icon|intro|letter` and `T|chapter|kind|spec|qty|lv|opt (0/1)|alt (kind:spec:qty or -)|label` |
| `data/journey_errands.txt` | NEW | `Q|id|area|zone|kind (lost/creature/deliver/garden/happening)|giver (npc slug or stop type)|trigger|repeat (once/regular)|lv|reward (stop reward spec)|extra (first time)|title|intro|outro` and `S|id|kind|spec|qty|alt|label` |
| `data/journey_letters.txt` | NEW | `L|area|kind (cover/firstlamp/leaf/seal/joint)|chapter slug or -|text` (Seal letters hold the four fixed parts; `{hearth}`, `{plaque}`, `{friend}` are filled in) |
| `data/seed_beds.txt` | NEW | `area|stop slug or type|signature crop|flower|hand-in 1|hand-in 2|hand-in 3|acts and happenings switched on when full` |
| `data/stop_threads.txt` | CHANGED: 20 cast + 17 area threads. Two optional fields added at the end | `...|beats|trigger (same grammar as errands)|extra (first time)` |
| `data/stop_tier_themes.txt` | CHANGED: 12 variant rows | existing columns + `variant slug` (blank = the default row) |
| `data/landmarks.txt` | CHANGED: 13 secret places (plus the new places of the routes proposal) | existing format, type haven or wonder, flagged hidden-until-unlocked |
| `data/recipes.txt`, `data/teas.txt` | CHANGED: 14 + 4 rows | existing formats |
| `data/puzzle_pals.txt` | CHANGED: 4 rows | existing format |
| `data/creatures.txt` | no change here | band 4-5 steps need the 38-55 list imported first |

Trigger grammar (errands and threads), all read live: `tier>=N@zone:Z` / `@type:mill` / `@area`, `regular@type:x`, `chapter=slug`, `found=place-slug`, `bed>=K`, `seal=CODE`, `hp=happening_id`, joined with commas (all must hold).

### 5.3 Points to settle (pass 2 only)
1. **Name clash**: resolved in pass 4. Band 2 joint chapter = "The Crossing"; band 2 ceremony = "Two lamps"; band 3 ceremony renamed "Lamps on the water" (not "First boat out", which is Fenna's band 3 thread).
2. **Tier 4 in M6** and **tier 2 x4 in C4**: fixed in pass 4 (M6 asks tier 2, Hall optional; C4 asks 2 stalls). Zones with no road village now use `regular` steps.
3. **Peaceful alts** finish the step. They do not score the delve row; the lair row counts a lair's own peaceful act (the Owl's three evenings). A non-fighter's ceiling is 90-95, so 80 has slack (pass 4 table).
4. **Companions** are mapped to Puzzle Pals because that is the only companion system in the data. Drop the 4 if that is wrong.
5. **Creatures 38-55**: 7 side quests and 3 main steps name creatures from the 38-55 proposal list (dhole-pack, meerkat-mob, hamadryas-baboon, one-horned-rhino, grey-parrot-gossip, secretary-bird, proboscis-monkey, giant-salamander, mantis-shrimp, tasmanian-devil); do not trim those. The seven lairs are existing lairs whose guardians are generated (`ensure_lair_bosses`); the list now gives them as level/drop overrides at band top (45 / 55), not as new creatures.
6. All Petal, XP and hand-in numbers are unsimulated.

## Pass 5 changes (Josh, 2026-11-27)
- Signature crops: no new crops. All 14 already exist in `crops.txt` (checked: wild-rice, amaranth, barley, breadfruit, yerba-mate, olive, buckwheat, date, turmeric, fonio, teff, persimmon, rice, taro).
- Puzzle Pals stay released by jigsaw (Advanced or Expert). M1 step 2 makes the Maplewold jigsaw part of the Lv 1 quest line. The 4 companion side-quest extras (`na-s08`, `nwe-s08`, `cb-s05`, `esa-s05`) no longer grant a pal; give each a different extra (rare seed or stop theme).
- Pals now spawn only in regions the gnome has access to (code done: `accessible_regions()`, `ppal_spawn_nodes()`, `ppal_spawn_prune()`).
