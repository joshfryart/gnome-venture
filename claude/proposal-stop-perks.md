# PROPOSAL: Lasting marks (rest-stop perks rework)

Status: proposal only, no game code changed. 2026-11-27.
Read for this: `docs/stop-perk-ideas.md`, `includes/player_perks.php`, `stop_living.php`, `stops.php`, `stop_adopt.php`, `data/stops.txt`, `stop_tiers.txt`, `stop_act_state.txt`, the four `stop_acts*.txt` files (860 acts), `claude/proposal-story-1-base.md`, `claude/proposal-maplewold-bands-and-seals.md`, `claude/route-list.md`.

Three things found while reading, which change the plan:
- **The Maplewold list has 16 stops, not 15** (1 town, 3 road, 7 off-road, 3 road-out, 2 havens). All 16 are done below: 48 perks.
- **The town and the two havens are not stops in code today.** `stop_do`, `stop_perk_body`, `stop_adopt` all require `kind = 'village'`. The town is `market`, the havens are `haven` (and the Sugar Shack is closed until its Journey chapter). They need a small gate change (section 8) before they can have bars.
- **Acts can already be done only once a game day per stop** (2.8.64). So "repeats small" is defined per bar per day, not per act (section 2).

## 1. The rule

| | Now | Proposed |
|---|---|---|
| Full bar | Perk for 7 game days, random from a pool, max 3, bar restarts at 30 | **Lasting mark**: the bar stays full and its perk is on for good |
| Whose | Player, works everywhere | Player, per stop, per bar. Works everywhere unless the perk text names a place |
| Which perk | Seeded pick from 9 | Fixed: that stop's own perk for that bar (section 5), else its type's default (section 6) |
| Limit | 3 at once | None. Balance comes from family caps (section 4) |
| Decay | 3 a day | **None (recommended).** See below |

**Bars while filling: remove decay.** A bar is a high-water mark, like Standing in the story proposal. Reasons: the game is at leisure with no fail states; a bar now takes days of visits, so losing 3 a day at 16 stops punishes travelling; and "latched" plus "decays" is two rules where one will do. Kept as a setting (`mark_decay`, default 0) so it can be switched on for unfilled bars only. A filled bar never moves.

After a bar is full: its acts still pay their normal rewards. Each one adds 1 to a "kept up" count shown on the plaque (flavour only). The notice board's "Needs help" lists unfilled bars only.

## 2. Acts feed bars: the rules

Every act feeds one bar. Some feed a second at half. The generator script reads the act files and writes `data/stop_act_bars.txt` (`slug | stop type | bar | second`). Steps, in order, first match wins.

**Step 0. Override.** A row in `stop_act_state.txt` "moves" names the bar(s). Its numbers are ignored; points come from the formula.

**Step 1. Tags.** As `stop_act_tags`, with two fixes: match at the start of a whole word (today "pier" counts as "pie"), and tags from the name rank before tags from the blurb. Inside each, this order: `fix > craft > cook > gather > tend > trade > play > lore > rest`. Bars: fix, craft = Repairs. cook, gather, tend = Larder. trade, play, lore, rest = Cheer.

**Step 2. First bar, by act kind.**

| Kind | First bar |
|---|---|
| craft | Larder if it has a cook tag or makes food, else Repairs |
| tend | Bar of its first tag if that is fix, craft, cook, gather or tend. Else the type's lean |
| rest | Larder if the NAME has a cook tag (a table, a supper). Else Cheer |
| lore, gossip | Cheer |
| buy, snack, swap, seedswap | Larder |
| contest, pick, power, collect | Cheer, unless step 3 moves it |
| check | Bar of its first tag. No tag: the type's lean |
| thread | The type's signature bar |
| anything else (default) | The type's lean |

**Step 3. Stop type.** Signature = the bar the type is proud of. Lean = where untagged work goes. Moves apply to game kinds only. Share = how the 860 acts split per type under these rules (script run, Repairs / Larder / Cheer %).

| Type | Signature | Lean | Moves | Share R/L/C |
|---|---|---|---|---|
| market | Larder | Larder | pick > Larder, power > Repairs | 20/37/43 |
| mill | Larder | Repairs | power > Repairs | 29/44/28 |
| inn | Cheer | Larder | power > Repairs, collect > Larder | 17/37/46 |
| shrine | Cheer | Repairs | pick > Larder | 25/19/57 |
| jetty | Larder | Repairs | power > Larder, pick > Larder | 27/26/46 |
| herb | Larder | Larder | collect > Larder | 16/55/29 |
| workshop | Repairs | Repairs | power > Repairs, pick > Repairs | 50/15/35 |
| orchard | Larder | Larder | power > Larder | 15/47/38 |
| ferry | Repairs | Repairs | power > Repairs, pick > Larder | 30/21/49 |
| tower | Repairs | Larder | power > Repairs, pick > Larder | 15/20/65 |
| spring | Cheer | Repairs | pick > Larder | 18/27/55 |
| camp | Cheer | Larder | power > Repairs, pick > Larder | 18/31/51 |

The thin bar at each type is covered by the four "answer" acts at every stop (`mend_board`, `tidy_yard` Repairs; `fill_shelf` Larder; `hang_lanterns` Cheer). Change their needs from `meter<60` to "bar not full", so every unfilled bar has a feeder every day.

**Step 4. Second bar (half points).** First that applies:
1. buy, snack, swap, seedswap: Cheer.
2. Moved in step 3: the bar it was moved from (Cheer).
3. Its next tag (not `rest`) whose bar differs from the first bar.
4. contest, pick, power, collect: the type's lean, if different.
5. lore, gossip, thread: never. Otherwise none.

Result: 28% to 56% of acts per type have a second bar.

**Points.** `pts = max(1, floor(B x D x W x F)) + V`

| Part | Value |
|---|---|
| B, by energy cost | 0 energy = 6, 1 = 9, 2 = 12, 3 or more = 15 |
| D, nth act today at this stop with this first bar | 1st = 1, 2nd = 0.5, 3rd and later = 0 (so 1 point) |
| W | win or no dice = 1, lose = 0.5 |
| F | festival day x2, answer act x1.5 |
| V, variety | +2 if this act KIND has not been done at this stop today |
| Full round | The first time all three bars are fed in a day at a stop: +5 to the lowest unfilled bar |
| Second bar | floor(pts / 2), least 1. Does not count for D |
| Same act again the same day | Not possible now. If that rule is ever lifted: 1 point |

A bar is 100 points. One day at a workshop: Mend something 11 R, Plane the boards 6 R + 3 C, Strike the anvil bell 3 R + 1 C, Tales by the forge 8 C, Forge stall 8 L + 4 C, full round +5 L. Day total R 20, L 13, C 16. So **about 6 to 10 visit-days per bar**, and all three bars at one stop in about the same days if you spread your acts. First mark in the first week; all 48 in the Maplewold is roughly two months of steady play.

**Worked examples** (real acts; points = first of that bar that day, before variety).

| Type | Act | Kind, energy | Why | First bar | Second |
|---|---|---|---|---|---|
| market | Haggle at the stalls | check 0 | tag trade | Cheer 6 | |
| market | Weighing house stall | buy 0 | kind | Larder 6 | Cheer 3 |
| market | Patch the awnings | tend 1 | tag fix | Repairs 9 | Larder 4 |
| market | Sniff the jars | pick 0 | type move | Larder 6 | Cheer 3 |
| market | Heave the hay bale | power 1 | type move | Repairs 9 | Cheer 4 |
| mill | Turn the millstone | check 2 | tag cook | Larder 12 | |
| mill | Fly the sails | check 1 | override row | Repairs 9 | |
| mill | Compost swap | swap 0 | kind | Larder 6 | Cheer 3 |
| mill | Bakehouse table | rest 0 | cook in name | Larder 6 | |
| inn | Tall tales by the hearth | lore 0 | kind | Cheer 6 | |
| inn | Late supper by lamplight | buy 0 | kind | Larder 6 | Cheer 3 |
| inn | Snail cards | pick 0 | kind, lean second | Cheer 6 | Larder 3 |
| inn | Stock the root cellar | tend 1 | override row | Larder 9 | |
| shrine | Sit in silence | rest 0 | kind | Cheer 6 | |
| shrine | Rake the gravel | tend 1 | no tag, lean | Repairs 9 | |
| shrine | Tend the moss | check 1 | tag tend | Larder 9 | |
| shrine | The politest bow | contest 0 | kind, lean second | Cheer 6 | Repairs 3 |
| jetty | Twist rope | check 1 | tag fix | Repairs 9 | |
| jetty | Skim stones | power 0 | type move | Larder 6 | Cheer 3 |
| jetty | Cattail fritters | craft 1 | tag cook | Larder 9 | |
| jetty | Loon-call contest | contest 0 | kind, lean second | Cheer 6 | Repairs 3 |
| herb | Herbal tea tasting | buy 0 | kind | Larder 6 | Cheer 3 |
| herb | Leaf shapes | collect 0 | type move | Larder 6 | Cheer 3 |
| herb | Train the hop bines | tend 1 | override row | Larder 9 | |
| herb | Sit by the drying rack | rest 0 | kind | Cheer 6 | |
| workshop | Mend something | check 1 | tag fix | Repairs 9 | |
| workshop | Plane the pine boards | craft 1 | kind, tag play | Repairs 9 | Cheer 4 |
| workshop | Strike the anvil bell | power 0 | type move | Repairs 6 | Cheer 3 |
| workshop | Tales by the banked forge | lore 0 | kind | Cheer 6 | |
| orchard | Gather herbs | check 1 | tag gather | Larder 9 | |
| orchard | Rebuild the zigzag fence | tend 1 | tag fix | Repairs 9 | |
| orchard | Windfall toss | power 0 | type move | Larder 6 | Cheer 3 |
| orchard | Which hole pops? | pick 0 | kind, lean second | Cheer 6 | Larder 3 |
| ferry | Skim stones | power 0 | type move | Repairs 6 | Cheer 3 |
| ferry | Toll-house stall | buy 0 | kind | Larder 6 | Cheer 3 |
| ferry | Legends of the Lost Lantern | lore 0 | kind | Cheer 6 | |
| ferry | Stare down the gull | contest 0 | kind, tag fix | Cheer 6 | Repairs 3 |
| tower | Dress stone | check 2 | tag craft | Repairs 12 | |
| tower | Haul the beacon basket | power 1 | type move | Repairs 9 | Cheer 4 |
| tower | Spyglass stall | buy 0 | kind | Larder 6 | Cheer 3 |
| tower | Toboggan race | contest 0 | kind, lean second | Cheer 6 | Larder 3 |
| spring | Scrub the bath stones | tend 1 | no strong tag, lean | Repairs 9 | |
| spring | Boil the perfect egg | check 0 | tag cook | Larder 6 | |
| spring | Which egg is done? | pick 0 | type move | Larder 6 | Cheer 3 |
| spring | Skim stones | power 0 | kind, tag craft | Cheer 6 | Repairs 3 |
| camp | Campfire story | lore 0 | kind | Cheer 6 | |
| camp | Rebuild the zigzag fence | tend 1 | tag fix | Repairs 9 | |
| camp | Boil an egg | buy 0 | kind | Larder 6 | Cheer 3 |
| camp | Toboggan race | contest 0 | kind, lean second | Cheer 6 | Larder 3 |

Skim stones shows the stop type at work: Larder at a jetty, Repairs at a ferry, Cheer at a spring.

Known noise: word tags misfire on a few acts (in the trial run "Fry the fiddleheads" lands on Repairs because "fry" is not a cook word; "Make an offering" reads as craft). Add `fry, broth, cordial, porridge, pickle` to the cook words, and expect about 5% of rows to need a hand override. The script should print the per-type share table above so outliers show.

## 3. Perk rules

- Size: +1% or +2%, or +1 of a small unit, or one small convenience. Nothing else.
- A perk row is `family | size | scope`. Scope narrows where it counts and reuses the act "when" grammar: `dp=` day part, `we=` weather, `se=` season, plus `land=`, `region=`, `type=` (stop type), `from=` (stop), `items=` (item group).
- Marks of one family add up, then the family cap cuts the total (section 4).
- Info and looks perks (flags) are only for hand-written stops. Type defaults are always stackable families, so a second inn is never a blank.

## 4. Effect catalogue and caps

29 families. "NA" = perks in the Maplewold set (count, summed size). "Types" = default type perks feeding the family. World today: 178 stops (146 villages, 14 towns, 18 havens) = 534 marks; 162 stops outside the Maplewold, about 13 per type.

| # | Family | Effect | Hook | Per perk | **Cap** | NA | Types |
|---|---|---|---|---|---|---|---|
| F01 | sell | Shop sell price | `world.php` `sell_price_with_bonus` | +1% | **+5%** | 2 (2) | 1 |
| F02 | buy | Shop prices | `world.php:415` `shop_price` | -1% | **-5%** | 1 (1) | 2 |
| F03 | xp | Gnome XP | `gnome.php:308` `add_xp` | +1% or +2% scoped | **+5%** | 2 (3) | 3 |
| F04 | gxp | Garden XP | `gnome.php:355` `add_garden_xp` | +1% | **+5%** | 1 (1) | 1 |
| F05 | walk | Walk time | `adventure.php:192` | -1% or -2% scoped | **-6%** | 3 (4) | 1 |
| F06 | cook | Pot time | `crafting.php:465` | -1% or -2% scoped | **-6%** | 2 (4) | 1 |
| F07 | meal | Energy from dishes | `gnome.php:625` | +1% or +2% scoped | **+5%** | 1 (2) | 1 |
| F08 | buff | Boost length | `gnome.php:439` | +2% | **+8%** | 2 (4) | 2 |
| F09 | heal | Healing | `health.php:130`, `adventure.php:1280` `rest_heal` | +2% | **+8%** | 2 (4) | 2 |
| F10 | harvest | Chance of one extra | `garden_logic.php:1598` | +1% | **+4%** | 2 (2) | 1 |
| F11 | gather | Chance of one extra find | `gathering.php` `gather_on_walk`, `gather_here` | +1% | **+4%** | 1 (1) | 2 |
| F12 | water | Watering lasts | `garden_logic.php:865` `water_seconds` | +2% | **+8%** | 1 (2) | 1 |
| F13 | seed | Chance of a seed back | `garden_logic.php:1634` | +1% | **+4%** | 1 (1) | 1 |
| F14 | friend | Chance of +1 friendship | `friends.php:56` `friend_add` | +2% | **+8%** | 1 (2) | 2 |
| F15 | stopcoin | Coins from stop acts | `stops.php:670` `stop_rewards` | +2% | **+8%** | 1 (2) | 2 |
| F16 | check | Stop check chance | `stops.php:742` `stop_check` | +1% | **+4%** | 1 (1) | 1 |
| F17 | pest | Pest chance | `garden_fx.php:281` `pest_chances` | -2% | **-8%** | 1 (2) | 1 |
| F18 | travel | Fast travel cost | `world.php:282` | -1% | **-5%** | 1 (1) | 1 |
| F19 | spot | Spot hidden things | `explore.php:222` | +1% | **+4%** | 1 (1) | 1 |
| F20 | hp | Max health | `health.php:46` `hp_max` | +1 point | **+4** | 0 | 1 |
| F21 | torch | Delve torch steps | `delve_v2.php:37` `dv2_fuel` | +1 step | **+5** | 1 (1) | 1 |
| F22 | restenergy | Energy from rest acts | `stops.php` `stop_do`, rest kind | +1 | **+3** | 2 (2) | 1 |
| F23 | trailseed | Seed found on travel | `world.php:292` | +1% | **+4%** | 0 | 1 |
| A1 | dayfree | A first action of the day is free or 1 cheaper | `garden_logic.php:554` water, `:1317` weed, `adventure.php:208` walk, `world.php:283` | 1 a day | **3 a day** | 2 | 2 |
| A2 | dayback | Something lost comes back once a day | seed drop, `stops.php:748` re-roll, `adventure.php:237` staff, `crafting.php:529` | 1 a day | **3 a day** | 3 | 1 |
| A3 | daygift | One common item a day | first visit (`place_ui.php:306`), first food buy | 1 item | **3 items a day** | 3 | 1 |
| A4 | daycoin | A few flat coins | `adventure.php:447` `give_find`, `sell_to_shop` | up to 3 coins | **10 coins a day** | 1 | 1 |
| A5 | info | Shows something you could not see | UI only | flag | no power. 1 per stop at most | 6 | 0 |
| A6 | looks | Cosmetic | UI only | flag | no power. 1 per stop at most | 3 | 0 |

**The maths.**
- Maplewold alone (48 marks, 30 with numbers): no family goes over its cap. Largest sums: walk 4 of 6, cook 4 of 6, buff 4 of 8, dayback 3 of 3, daygift 3 of 3. And scoped perks rarely all apply at once.
- Whole world on type defaults: a family fed by k type perks gets about 13 x k marks. XP has k = 3: 39 marks, +39% uncapped, **capped at +5%**. Sell has k = 1: 13 marks, +13% uncapped, capped at +5%. Every percent family reaches its cap after 3 to 5 marks.
- So the most a gnome can ever hold, with all 534 marks: each row of the Cap column, once. Sell +5%, buy -5%, XP +5%, walk -6%, pots -6%, and so on.
- Compare today: three 7-day perks at once can be XP +10%, pots -20%, walk -15%. **The forever maximum is under half of today's temporary one.**
- At cap, a new mark of that family adds nothing more. The perk row then reads "as good as it gets"; the stamp, plaque and count still land (open question 2).

Caps are rows in `data/stop_perk_fx.txt`, editable in Admin.

## 5. The Maplewold: 16 stops, 48 perks

Stop types to set in Admin > Places:

| Stop | Type | Why |
|---|---|---|
| The Maplewold Market | market | The town |
| Poppyburrow | inn | The crossroads: six roads leave it |
| Honeybrook | herb | Bees and a beekeeper |
| Cloverholt | mill | Oats and lentils to grind |
| Acornby | camp | A clearing in the forest |
| Birchhollow | workshop | Birch planks |
| Mossgate | shrine | "Moss shrine" |
| Shellhollow | jetty | Coast, shells, anglers |
| Pebblestead | ferry | Coast crossing |
| Iciclecrest | tower | A crest in the tundra, a beacon |
| Snowcombe | spring | Hot pools in the snow |
| Larkbrook | inn | Border inn on the Maizehollow road |
| Windbottom | tower | Gate beacon on the Mistmoor road (Warden Hobb's wish) |
| Honeythorpe | orchard | Hop yard and fruit, toward Blossomreach |
| The Sugar Shack | orchard | A maple sugar bush |
| Aurora Camp | camp | By name |

| Stop | Bar | Perk | Effect | Size | Family |
|---|---|---|---|---|---|
| Maplewold Market | Repairs | ⚖️ Level Scales | Maplewold-native crops sell for 1% more | +1% | F01 |
| | Larder | 🥯 Baker's Thirteenth | Once a day, the first food you buy in a shop comes with one extra | 1 a day | A3 |
| | Cheer | 🧺 Known at the Stalls | Shop shelves put a small leaf on anything you have never owned | flag | A5 |
| Poppyburrow | Repairs | 🪧 The Straightened Signpost | Walks that start at Poppyburrow take 2% less time | -2% | F05 |
| | Larder | 🥞 Second Breakfast | Home-cooked dishes eaten at dawn give 2% more energy | +2% | F07 |
| | Cheer | 🛏️ A Bed With Your Name On | Rest acts at any inn give 1 more energy | +1 | F22 |
| Honeybrook | Repairs | 🐝 Tidy Skeps | Pests are 2% less likely on flowering plants | -2% | F17 |
| | Larder | 🍯 Honey in the Tea | Tea boosts last 2% longer | +2% | F08 |
| | Cheer | 🌼 The Bees Know You | A Honeybrook bee visits your garden now and then (looks only) | flag | A6 |
| Cloverholt | Repairs | ⚙️ Greased Wheel | Breads and bakes cook 2% faster | -2% | F06 |
| | Larder | 🌾 Miller's Pinch | Oat and lentil harvests: 1% chance of one extra | +1% | F10 |
| | Cheer | 🍪 Oatcake for the Road | First visit to Cloverholt each day: one oatcake | 1 a day | A3 |
| Acornby | Repairs | 🪵 Dry Woodpile | Resting on a forest trail heals 2% more | +2% | F09 |
| | Larder | 🐿️ Squirrel's Arithmetic | Gathering in forest: 1% chance of one extra | +1% | F11 |
| | Cheer | 🔥 Fireside Regular | Checks at camp stops are 1% kinder | +1% | F16 |
| Birchhollow | Repairs | 🩹 Birch-Bark Patch | Once a day, the first wear on your walking staff is skipped | 1 a day | A2 |
| | Larder | 🍂 Sawdust Mulch | Watering lasts 2% longer on hot or windy days | +2% | F12 |
| | Cheer | 📏 Measured Twice | Stop checks show your exact odds as a number | flag | A5 |
| Mossgate | Repairs | 🧹 Swept Steps | 1% better chance to spot hidden things in forest | +1% | F19 |
| | Larder | 🥣 What You Leave Comes Back | Maplewold-native crops: 1% more chance of a seed back | +1% | F13 |
| | Cheer | ✨ Glow-Moss in the Pocket | When your torch runs out in a delve, your one lit tile glows soft green (looks only) | flag | A6 |
| Shellhollow | Repairs | 🕸️ Sound Nets | Acts at jetties and ferries pay 2% more coins | +2% | F15 |
| | Larder | 🐟 Catch of the Day | Fish sell for 1% more | +1% | F01 |
| | Cheer | 🎣 An Opinion on Every Fish | The Today page shows tomorrow's weather | flag | A5 |
| Pebblestead | Repairs | 🦫 Beaver-Tight Hull | Fast travel to or from the coast costs 1% less | -1% | F18 |
| | Larder | 📦 Porter's Crate | Shops on the coast charge 1% less | -1% | F02 |
| | Cheer | 🪨 Pebble in the Boot | 1 in 20 chance a road walk turns up a coin | 1 coin | A4 |
| Iciclecrest | Repairs | 🧯 Beacon Basket, Refilled | +1 torch step in Maplewold delves | +1 step | F21 |
| | Larder | 🫖 Watcher's Flask | Walking in snow or frost takes 1% less time | -1% | F05 |
| | Cheer | 🔭 Three Roads and a Long Way | The route menu shows if something is on at the far stop today | flag | A5 |
| Snowcombe | Repairs | ♨️ Scrubbed Pools | Rest acts at any hot spring give 1 more energy | +1 | F22 |
| | Larder | 🥚 Spring-Boiled Egg | First visit to Snowcombe each day: one boiled egg | 1 a day | A3 |
| | Cheer | 🧣 Warm to the Bones | Healing is 2% stronger while it snows | +2% | F09 |
| Larkbrook | Repairs | 🏮 Border Lamp | Walking at night takes 1% less time | -1% | F05 |
| | Larder | 🥪 Packed by the Cook | Boosts from dishes you cooked yourself last 2% longer | +2% | F08 |
| | Cheer | 🐦 Up With the Lark | 1% more XP at dawn | +1% | F03 |
| Windbottom | Repairs | 🗼 Answered Beacon | The world map shows your three bars for every stop | flag | A5 |
| | Larder | 🎒 Signaller's Ration | The first fast travel each day costs 1 less energy | 1 a day | A1 |
| | Cheer | 🍃 Tailwind | 2% more XP on windy days | +2% | F03 |
| Honeythorpe | Repairs | 🪜 Propped Boughs | 1% more garden XP from fruit and tree crops | +1% | F04 |
| | Larder | 🏷️ Grafter's Label | Your satchel shows seed ages | flag | A5 |
| | Cheer | 🍻 Hop-Yard Hum | Gifts of food or drink: 2% chance of +1 friendship | +2% | F14 |
| The Sugar Shack | Repairs | 🪓 Stacked Birch | Syrups and sweets cook 2% faster | -2% | F06 |
| | Larder | 🪣 Brim-Full Bucket | Tree and sap harvests: 1% chance of one extra | +1% | F10 |
| | Cheer | 🍁 Sticky Fingers | The first seed you drop each day is returned | 1 a day | A2 |
| Aurora Camp | Repairs | ⛺ Pegged Tents | Once a day, a failed stop check is rolled again | 1 a day | A2 |
| | Larder | 💧 Meltwater Can | The first watering each day costs no energy | 1 a day | A1 |
| | Cheer | 🌌 Sky-Dazzled | On clear nights a faint aurora shows over your garden (looks only) | flag | A6 |

Item names (oatcake, boiled egg) and item groups (fish, sweets, bakes, tree crops) must be mapped to real slugs and categories at build time.

## 6. Default type perks (other regions)

Used when a stop has no perk of its own. Admin can override per stop. All stackable, all unscoped or lightly scoped.

| Type | Repairs | Larder | Cheer |
|---|---|---|---|
| market | 🪙 Honest Weights: everything sells for 1% more (F01) | 🥬 Heaped Stall: food in shops costs 1% less (F02) | 🗣️ Good Banter: trade and haggle acts pay 2% more coins (F15) |
| mill | 🛢️ Oiled Cogs: pots cook 1% faster (F06) | 🧺 Full Sacks: harvests have a 1% chance of one extra (F10) | 🥖 Flour on the Nose: baked dishes give 1% more energy (F07) |
| inn | 🪟 Fixed Shutters: rest acts at stops give 1 more energy (F22) | 🍲 Stew That Remembers You: boosts from bought meals last 2% longer (F08) | 📖 Told at the Hearth: 1% more XP from stop acts (F03) |
| shrine | 🪨 Raked Gravel: 1% better chance to spot hidden things (F19) | 🌱 Left a Little, Got a Little: 1% more chance of a seed back (F13) | 🔔 Bell-Calm: stop checks are 1% kinder (F16) |
| jetty | 🛶 Sound Planks: fast travel costs 1% less (F18) | 🦀 A Bucket at Every Post: gathering at a place has a 1% chance of one extra (F11) | 🐠 The One That Got Away: chats have a 2% chance of +1 friendship (F14) |
| herb | 🧵 Mended Drying Racks: pests are 2% less likely (F17) | 🌿 More Herbs Than Names: watering lasts 2% longer (F12) | 🐞 Bee-Loud: 1% more garden XP (F04) |
| workshop | 🔩 Spare Nail: +1 torch step in delves (F21) | 🫙 Glue Pot: once a day, a craft gives one ingredient back (A2) | 🛠️ Contraption Approved: craft acts at stops pay 2% more coins (F15) |
| orchard | 🧤 Sound Ladders: the first weeding each day is free (A1) | 🍎 Windfall: 1% more chance to find a seed on your travels (F23) | 🍐 Picker's Whistle: 1% more XP from harvesting (F03) |
| ferry | ⚓ Tight Ropes: walking takes 1% less time (F05) | 🧾 Toll Paid in Kind: tools and gear cost 1% less (F02) | 🛎️ Rung the Bell: the first sale each day pays 2 coins more (A4) |
| tower | 🧱 Sound Rungs: +1 max health (F20) | 🥠 Watcher's Biscuit Tin: first visit to this tower each day: one biscuit (A3) | 🧭 Seen It Coming: 1% more XP from walking and exploring (F03) |
| spring | 🛁 Mended Pools: healing is 2% stronger (F09) | 🧪 Egg Basket: potion boosts last 2% longer (F08) | 🧖 Steam in the Whiskers: gifts have a 2% chance of +1 friendship (F14) |
| camp | 🏕️ Ring of Stones: resting on any trail heals 2% more (F09) | 🍳 Shared Pot: gathering on a walk has a 1% chance of one extra (F11) | 🎶 Harmonica Somewhere: the first road walk each day costs 1 less energy (A1) |

All 84 names and effects in sections 5 and 6 are different from each other.

## 7. UI

**Perks page: "Lasting marks" card** (replaces "Your perks (work everywhere)").
```
🏅 Lasting marks   7 of 48 in the Maplewold · 9 in all
 🪧 The Straightened Signpost   Poppyburrow · Repairs    Walks from Poppyburrow 2% faster
 🍯 Honey in the Tea            Honeybrook · Larder      Tea boosts last 2% longer
 ...
 Adds up to:  walk -3% (most -6%) · sell +2% (most +5%) · 2 of 3 daily freebies
```
One row per mark, grouped by region, newest first. The last line is the family totals against their caps. A capped row says "as good as it gets".

**Stop page.**
- Full bar: the meter turns gold with a stamp in the stop's hue (`stops.txt` hue): `🔨 Repairs  [ MENDED ✔ ]`. Words: Mended, Stocked, Merry. The plant tile stays in bloom (stage 4).
- Unfilled bar: shows its perk greyed, so you know what you are working for: `🧺 Larder 62% · 🥞 Second Breakfast`.
- Plaque line under the stop name, one per mark, beside the adopter's plaque: *"The signpost stands straight. {gnome} saw to it. Kept up 12 times."*
- Three marks at one stop: the three medals in the banner go gold, and the passport stamp for that stop gets a gold rim.
- On filling: `🌟 Repairs is mended at Poppyburrow, for good. 🪧 The Straightened Signpost: walks from here take 2% less time.`

## 8. Build notes

**Schema**
```
stop_marks      user_id INT, location_id INT, bar VARCHAR(8), perk_key VARCHAR(40),
                filled_on DATE, kept INT DEFAULT 0
                PRIMARY KEY (user_id, location_id, bar), KEY (user_id, perk_key)
stop_mark_use   user_id INT, day DATE, family VARCHAR(16), used INT
                PRIMARY KEY (user_id, day, family)            -- daily charges, A1 to A4
locations       + perk_repairs, perk_larder, perk_cheer VARCHAR(40) NULL   -- NULL = the type's default
```
Bars stay in `stop_prog` (`meter:<name>`, 0 to 100). The per-day counts for D and V come from `stop_log` (it has act, kind, day). `perk_key` is stored at fill time: what you earned stays what you earned.

**Data files**
- `data/stop_perks.txt`: `key | owner (type:inn or stop:<slug>) | bar | icon | name | family | size | scope | text`
- `data/stop_perk_fx.txt`: `family | unit | cap | label`
- `data/stop_act_bars.txt` (generated): `slug | type | bar | second`. `stop_act_state.txt` keeps its needs column.

**Hooks** (new `includes/stop_marks.php`)
- `stop_mark_fx(int $uid, string $family, array $ctx = []): int` capped sum of the player's marks in a family whose scope fits `$ctx`. One cached query per request. Replaces every `player_perk_pct()` call site (9 today) and goes in at the hook column of section 4.
- `stop_mark_flag(int $uid, string $perkKey): bool` for A5 and A6.
- `stop_mark_charge(int $uid, string $family, string $what): bool` takes one daily charge if any is left.
- `stop_mark_latch(int $uid, array $loc, string $bar): array` called from `stop_meter_add` at 100.
- `stop_is_place(array $loc): bool` = village, or a market or haven with a stop type set. Replaces the `kind === 'village'` tests in `stops.php:813`, `stop_living.php:339, 360`, `here_view.php:372`. A haven's bars open when the haven is open to that player.

**Admin settings**

| Setting | Default |
|---|---|
| `mark_on` | 1 |
| `mark_bar_size` | 100 |
| `mark_pts_0`, `_1`, `_2`, `_3` | 6, 9, 12, 15 |
| `mark_repeat_pct` (2nd act of a bar that day) | 50 |
| `mark_lose_pct` | 50 |
| `mark_answer_pct` | 150 |
| `mark_variety` | 2 |
| `mark_round` | 5 |
| `mark_fest_mult` | 2 |
| `mark_decay` (a day, unfilled bars only) | 0 |

Plus: Admin > Stop perks (the perk rows), Admin > Stop perk effects (the caps), and three perk pickers beside Stop type in Admin > Places. Retire `perk_days`, `perk_max` and the nine `perk_*` numbers.

**Migration**
1. Bars: work out each bar's value one last time with the old decay, store it, stop decaying. **Every bar keeps what it has; a bar at 30 or more stays as it is.** No bar is raised and no mark is given for a past fill.
2. Running 7-day perks: left to run out on their own date (7 days at most). No new ones are granted. They do not turn into marks. Until the last one ends, a call site reads the old perk or the new family, whichever is larger, never both.
3. `stop_prog` rows `perk:<meter>`: deleted (already unused).
4. After 7 days: remove `player_perks.php` reads and the old settings; keep the table one release for safety.
5. Update news: say plainly that the big 7-day perks are gone and what replaces them.

## 9. Open questions for Josh

1. **16 stops, and three are not stops yet.** The list has 16 names. The town and both havens need the `stop_is_place` change and a stop type. OK to do that, or should havens fill their bars through their build plans instead?
2. **Caps make later marks of the same family add nothing.** On type defaults a family is full after 3 to 5 marks. Is "as good as it gets, but the stamp still counts" enough, or should every region get its own written set like the Maplewold (about 534 perks in all, with far more info and looks perks)?
3. **Pace.** About 6 to 10 visit-days per bar, two months for the whole Maplewold. Right, or faster?
4. **Standing.** Should marks count toward a region's Standing and Seal ("12 lasting marks in the Maplewold"), or stay a separate layer?
5. **The step down.** Players lose XP +10%, pots -20% and walk -15% and get 1% to 2% pieces back. Fine as it is, or soften it (for example one free mark of their choice at a stop where they are already a Local)?
