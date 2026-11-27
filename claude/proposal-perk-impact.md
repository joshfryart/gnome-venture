# PROPOSAL: Perk impact model and estimates (all 540 stop perks)

Status: proposal only, no game code changed. 2026-11-27. Unsimulated: every baseline number is a source or a stated assumption.
Josh: "List the estimated change or boost from the perk. If below a meaningful amount, up it."

Files: this page (model, summary, every raised perk before and after, veto list); `proposal-perk-impact.csv` (one line for each of the 540 perks, as they are now); `proposal-perk-impact-before.csv` (the same table before the raises). Made by `python3 claude/tools_perk_impact.py --md` (model and numbers at the top of that file); the raises are rows in `tools_audit_stop_perks_fixes.py` (`RAISES`, written by `tools_perk_impact_raise.py`), applied by `python3 claude/tools_audit_stop_perks.py --fix` (0 errors) and taken out again by `--unraise`.

## Result in short

- Before: **312 of 540 perks were LOW** (below a meaningful amount). Typical case: 2% on one stop's walks, stall or acts in one weather = 0.02 to 0.05% of the day.
- **312 perks raised**: 216 wider trigger only, 60 wider trigger and bigger size, 36 3% (veto list).
- After: 511 ok, **29 still LOW**. All 29 are narrow place perks at 3%, the limit; they are the second perk of their family in their region, and rule P3 allows one region-wide perk per family per region (section 7).
- **36 perks are at 3%, for Josh's veto** (section 7). Caps: no family over its world cap, place-stack ceiling P2 unchanged (+4% at one event), A4 still 10 coins a game day, unit perks still +1, daily charges still one a game day, flags still flags.

## 1. Baseline: one game day of a typical gnome

A game day = one sleep (960 awake minutes). A touring day in the region the perk belongs to: 3 to 4 stops, 5 acts each, the garden and kitchen at home. A perk is rated in the band of its region: Maplewold 1-15; Maizehollow, Mistmoor and the four second-ring regions 15-35; the seven far regions 35-55.

| Per game day | 1-15 | 15-35 | 35-55 | Source or assumption |
|---|---|---|---|---|
| Awake minutes | 960 | 960 | 960 | master 1.1: 06:00 to 22:00 |
| Stops visited | 3.5 | 3.5 | 3.5 | master 3 A1: 3 to 4 stops on a touring day |
| Stop acts done | 17.5 | 17.5 | 17.5 | master 3 A1: 5 acts a stop x 3.5 stops |
| Walks (routes) | 5 | 5 | 5 | assumption: one walk per stop, the first leg and one side path |
| Walk minutes | 150 | 180 | 220 | master 3 A1: about 30 min between neighbours x 5 walks; roads get longer (assumption) |
| Harvests | 3 | 5 | 6 | master 3 A3: 6 beds (10, 12 later: assumption), a crop every 2 sleeps on average |
| Watering actions | 6 | 10 | 12 | master 3 A3: every bed watered every game day |
| Seeds planted | 3 | 5 | 6 | one per harvest (annuals) |
| Garden XP | 54 | 90 | 108 | harvests x 18 (`catalog.php:247` xp_per_harvest = tier x tier x 2, tier 3) |
| Pest visits | 1 | 1 | 1 | assumption |
| Pot cook minutes | 30 | 45 | 60 | `recipes.txt`: meal 15 min, snack 3, feast 45; 2 to 3 dishes a day (assumption) |
| Dishes eaten | 2 | 3 | 3 | assumption |
| Energy from dishes | 18 | 27 | 30 | `recipes.txt`: a meal gives 9 energy on average |
| Boost minutes running | 450 | 670 | 700 | `recipes.txt`: a meal boost lasts 224 min on average |
| Petals earned | 300 | 800 | 1450 | act coins + shop sales below |
| Petals from stop acts | 225 | 560 | 950 | `stop_acts.txt`: 7 paying acts x (14 + 4 x stop level) x 0.7 won, stop level = 8, 25, 45 |
| Petals from shop sales | 80 | 250 | 500 | assumption (no sim; master 3 A4) |
| Petals spent in shops | 100 | 300 | 600 | assumption; master 4: 3,600 Petals of stop fees in 20 to 35 game days |
| XP gained | 2100 | 27000 | 142000 | master 2.1 band totals / master 3 game days: 75.7k in 36, 2.4M in 90, 13.5M in 95 |
| XP from stop acts | 630 | 8100 | 42600 | assumption: 30% of the XP of the day |
| Friendship events (chats, gifts) | 6 | 8 | 8 | assumption: 3 to 4 folk, one chat and one gift each |
| Friendship points | 20 | 25 | 25 | master 3 A5: a Friend (100 points) in 6 to 12 game days, 2 to 3 folk at a time |
| Gifts given | 3 | 4 | 4 | half of the friendship events |
| Fast travels | 0.1 | 0.3 | 0.5 | assumption; 150 Petals and 2 energy each (`functions.php:407`) |
| Delve floors | 0.33 | 0.67 | 0.67 | assumption: a delve every 3 game days, 1 to 2 floors |
| Delve torch steps | 15 | 30 | 30 | floors x 45 (`delve_floors.php:16` DV_TORCH standard) |
| Fights | 2 | 3 | 3 | assumption (`trail_enc_pct` 3% a tile) |
| Max health | 44 | 95 | 155 | 20 + 3 x level (proposal-stop-perks.md section 4) |
| Health healed | 44 | 95 | 155 | assumption: one full bar a game day |
| Rest acts | 2 | 2 | 2 | assumption: 2 of the 17.5 acts; 3 or 5 energy each (`stop_acts.txt`) |
| Stop checks and contests | 6 | 6 | 6 | assumption: a third of the acts roll |
| Craft acts | 1 | 1 | 1 | assumption |
| Gathered finds | 6 | 8 | 10 | assumption: 1.2 to 2 finds a walk |
| Hidden-thing rolls | 2 | 2 | 2 | assumption |
| Energy spent | 60 | 160 | 260 | max energy 10 + 5 a level (`gnome.php:272`) + food and rest |

## 2. Exchange rates: 1 value point (VP) = 1 Petal

| Thing | VP | From |
|---|---|---|
| 1 energy | 3.0 | inn bed: 14 Petals for 5 energy (2.8); late supper: 9 Petals for 2 energy (4.5) (`stop_acts.txt`) |
| 1 game minute | 0.31 / 0.83 / 1.51 by band | Petals earned in the day / 960 awake minutes |
| 1 XP | 0.143 / 0.030 / 0.0102 by band | a day of XP is worth a day of Petals |
| 1 common item (crop, snack) | 8.0 | common gatherables average 9 Petals (`gatherables.txt`) |
| 1 gathered find | 12.0 | common 9, uncommon 21 (`gatherables.txt`) |
| 1 seed | 6.0 | assumption |
| 1 friendship point | 4.0 | assumption: an 8-Petal gift gives about 2 points |
| 1 health point | 0.5 | assumption |
| 1 boost minute | 0.1 | assumption: a 224-minute meal boost = about 20 Petals |
| 1 garden XP | 1.0 | assumption |
| 1 pest avoided | 5.0 | assumption: 1 energy to pick it off + lost growth |
| 1 hidden thing spotted | 30.0 | assumption |
| 1 torch step | 1.0 | assumption |
| 1 fast travel | 150 | `functions.php:407` travel_cost |

VP is only for comparing families. LOW or ok is decided in the perk's own domain (section 5), not in VP: fast travel, pests and friendship are small in VP by nature.

## 3. Trigger frequency: how much of the day a scope reaches

Expected benefit per game day = **baseline x share x size**. Share = the part of the day's domain the perk's text reaches, on a game day spent in the perk's region:

| Scope in the text | Share | Why |
|---|---|---|
| World, no condition | 1.00 |  |
| Region-wide, landscapes named | 0.50 to 0.75 | villages in zones of those landscapes / all villages of the region (`zones.txt`) |
| A given stop is visited | 0.28 of days | 3.5 stops a day of about 12.5 in a region |
| Acts at one stop; its stall; dishes eaten there | 0.08 | a visit day x 5 of 17.5 acts (or 1 of 3.5 stalls) |
| Walks from (or to) one stop | 0.056 | a visit day x 1 of 5 walks |
| One named road, both ways | 0.037 | one neighbour of about three |
| Rest acts at one stop | 0.14 | a visit day x 1 of 2 rest acts |
| Fast travel from one stop | 0.08 | the gnome stands at 1 of 12.5 stops |
| Named crops | 0.70 staples, 0.25 uncommon, 0.05 rare finds | share of the beds while in the region, split evenly inside a tier (`region_crops.txt`); a dish holds 2.5 ingredients |
| Day part | dawn 0.125, day 0.625, dusk 0.125, night 0.125 | of the 16 awake hours |
| Weather | rain 0.15, storm 0.05, wind 0.10, fog 0.07, snow 0.07, frost 0.06, heat 0.10, sun 0.22, cloud 0.18 | assumption |
| Season | 0.25 each |  |
| Festival day | 0.10 | assumption |
| One act kind (contest, lore, craft...) | 0.15 to 0.5 | assumption, table `KIND` in the script |
| One kind of goods at a stall | 0.1 to 0.5 | assumption, table `GOODS` in the script |

Conditions multiply. Example: "Walks that start at Froststead take 2% less time in snow or frost" = 180 walk minutes x (0.056 x 0.13) x 2% = 0.03 minutes a game day.

## 4. Formula per family

| Family | Baseline of the day | Benefit per game day | Unit | To VP |
|---|---|---|---|---|
| F01 sell | Petals from shop sales | sales x share x size | Petals | x 1 |
| F02 buy | Petals spent in shops | spend x share x size | Petals saved | x 1 |
| F03 XP | XP gained (place perks: XP from stop acts) | XP x share x size | XP | x Petals of the day / XP of the day |
| F04 garden XP | Garden XP | garden XP x share x size | garden XP | x 1 |
| F05 walk time | Walk minutes | minutes x share x size | minutes saved | x Petals of the day / 960 |
| F06 pot time | Pot cook minutes | minutes x share x size | minutes saved | x Petals of the day / 960 |
| F07 dish energy | Energy from dishes | energy x share x size | energy | x 3 |
| F08 boost length | Boost minutes running | minutes x share x size | boost minutes | x 0.1 |
| F09 healing | Health healed | health x share x size | health | x 0.5 |
| F10 harvest extra | Harvests | harvests x share x chance | crops | x 8 |
| F11 gather extra | Gathered finds | finds x share x chance | finds | x 12 |
| F12 watering lasts | Watering actions | waterings x share x size (2% longer = 2% fewer) | waterings saved (1 energy each) | x 3 |
| F13 seed back | Harvests | harvests x share x chance | seeds | x 6 |
| F14 friendship | Friendship events (chats, gifts) | events x share x chance | friendship points | x 4 |
| F15 stop coins | Petals from stop acts | coins x share x size | Petals | x 1 |
| F16 stop check | Stop checks and contests | checks x share x size | extra wins | x one act reward (14 + 4 x level) |
| F17 pest | Pest visits | visits x share x size | pests fewer | x 5 |
| F18 fast travel cost | Fast travels x 150 Petals | travels x 150 x share x size | Petals saved | x 1 |
| F19 spot hidden | Hidden-thing rolls | rolls x share x chance | extra finds | x 30 |
| F20 max health | Fights | fights x share (each fought with +1 of the bar) | fights with +1 health | x 0.5 |
| F21 torch steps | Delve floors | floors x share (+1 step of 45 each) | torch steps | x 1 |
| F22 rest energy | Rest acts | rest acts x share (+1 energy on 3 to 5) | energy | x 3 |
| F23 seed on fast travel | Fast travels | travels x share x chance | seeds | x 6 |
| A1 first action cheaper | days the trigger happens | chance the charge is used that day x 1 energy | energy | x 3 |
| A2 something comes back | days the trigger happens | chance x the thing kept (a seed, a tool wear, an ingredient, a second try) | item or try | seed 6, wear 2, item 8, try = 65% of an act reward |
| A3 daily gift | days the trigger happens | chance x 1 item | items | x 8 |
| A4 day coins | days the trigger happens | chance x coins | Petals | x 1 |
| A5 info flag | - | no number: it saves a look-up, a wrong guess or a tap | - | 0 |
| A6 looks flag | - | no number: looks only | - | 0 |

Daily charges: chance the charge is used on a game day = a visit day (0.28) x the act being done (0.9 for a rest, an act, a sale; less for a loss, a failure, one named road), or the day-wide chance for region-wide and world triggers (table `DAILY_RULES`).

## 5. What counts as meaningful

- **Number perks:** share x size is at least about **1% of the day's activity in the perk's own domain** (0.95% or more). So a 2% perk must reach about half of the domain, a 1% perk all of it. Max health, torch steps and rest energy also pass on the felt rule below (the +1 is seen every time).
- **Daily charges:** a clearly felt event **at least once in 4 game days** in the region (0.25 a day). The brief said "say once in 2 game days"; a stop is only visited on 28% of days, so once in 4 = about every visit, which is the most a perk tied to one stop can do. `THRESH_FELT` in the script changes it.
- **Flags:** an info flag (A5) is meaningful when it saves a look-up, a wrong guess or a tap: all 60 do. A looks flag (A6) has no boost by design; it is listed, not rated.
- Everything below is **LOW**.

## 6. Results

### Now (after the raises)

| Family | Perks | ok | LOW | Median boost (% of the day's domain, or felt events a day) | Median VP/day |
|---|---|---|---|---|---|
| F01 sell | 21 | 14 | 7 | 1.0% | 2.5 |
| F02 buy | 13 | 11 | 2 | 1.1% | 4.4 |
| F03 xp | 9 | 9 | 0 | 1.1% | 4.7 |
| F04 garden xp | 12 | 12 | 0 | 1.2% | 1.3 |
| F05 walk time | 23 | 15 | 8 | 1.0% | 1.5 |
| F06 pot time | 19 | 19 | 0 | 1.2% | 0.49 |
| F07 dish energy | 19 | 18 | 1 | 1.2% | 0.98 |
| F08 boost length | 16 | 15 | 1 | 1.2% | 0.84 |
| F09 healing | 18 | 15 | 3 | 1.0% | 0.57 |
| F10 harvest extra | 21 | 21 | 0 | 1.0% | 0.46 |
| F11 gather extra | 14 | 12 | 2 | 1.1% | 1.2 |
| F12 watering lasts | 15 | 15 | 0 | 1.1% | 0.38 |
| F13 seed back | 13 | 13 | 0 | 1.1% | 0.40 |
| F14 friendship chance | 11 | 10 | 1 | 1.1% | 0.35 |
| F15 stop coins | 10 | 8 | 2 | 1.0% | 6.7 |
| F16 stop check | 12 | 10 | 2 | 1.1% | 8.2 |
| F17 pest | 14 | 14 | 0 | 1.2% | 0.059 |
| F18 fast travel cost | 12 | 12 | 0 | 1.1% | 0.54 |
| F19 spot hidden | 7 | 7 | 0 | 1.1% | 0.65 |
| F20 max health | 7 | 7 | 0 | 0.30 a day | 0.15 |
| F21 torch steps | 9 | 9 | 0 | 0.67 a day | 0.67 |
| F22 rest energy | 13 | 13 | 0 | 0.16 a day | 0.48 |
| F23 seed on fast travel | 3 | 3 | 0 | 1.0% | 0.018 |
| A1 first action cheaper | 17 | 17 | 0 | 0.28 a day | 0.84 |
| A2 something comes back | 16 | 16 | 0 | 0.60 a day | 4.0 |
| A3 daily gift | 52 | 52 | 0 | 0.28 a day | 2.2 |
| A4 day coins | 6 | 6 | 0 | 0.25 a day | 0.50 |
| A5 info flag | 60 | 60 | 0 | - | - |
| A6 looks flag | 78 | 78 | 0 | - | - |
| **All** | **540** | **511** | **29** | | |

Number perks (311), boost as % of the day's activity in the perk's own domain:

```
    0 to 0.1   % | #######                                                      28
  0.1 to 0.25  % | ##                                                           7
 0.25 to 0.5   % |                                                              0
  0.5 to 0.95  % |                                                              1
 0.95 to 1.5   % | ############################################################## 247
  1.5 to 3     % | ######                                                       26
    3 to more  % |                                                              2
```

Daily charges (91), how often the charge is used:

```
less than once in 10 days    |                                          0
once in 4 to 10 days         |                                          0
once in 2 to 4 days          | ##################################       68
every other day or more      | #########                                18
every day                    | ##                                       5
```

### Before the raises

LOW per family before: A1 8, A2 9, A3 8, A4 4, F01 21, F02 13, F03 9, F04 11, F05 23, F06 16, F07 16, F08 15, F09 18, F10 21, F11 14, F12 15, F13 13, F14 10, F15 10, F16 12, F17 14, F18 12, F19 7, F20 1, F22 10, F23 2. Total 312.

```
    0 to 0.1   % | ######################################                       151
  0.1 to 0.25  % | ###############                                              60
 0.25 to 0.5   % | ###########                                                  45
  0.5 to 0.95  % | ########                                                     33
 0.95 to 1.5   % | ###                                                          11
  1.5 to 3     % | ##                                                           10
    3 to more  % |                                                              1
```

### World budget after the raises

World use per family (cap): sell 3 (5), buy 1 (5), xp 3 (5), garden xp 1 (5), walk time 3 (6), pot time 4 (6), dish energy 2 (5), boost length 4 (8), healing 4 (8), harvest extra 4 (4), gather extra 2 (4), watering lasts 2 (8), seed back 1 (4), friendship chance 2 (8), stop coins 2 (8), stop check 1 (4), pest 2 (8), fast travel cost 1 (5), spot hidden 1 (4), rest energy 2 (2), seed on fast travel 1 (4). Changed by the pass: sell 2 to 3, walk 2 to 3, harvest extra 2 to 4 (now full), gather extra 1 to 2. No cap was raised. Five families that were 1% a perk may now be 2%: harvest extra, gather extra, seed back, fast travel cost, seed on fast travel (rule P5 in `proposal-stop-perks.md` 4.1).

## 7. Veto list: 36 place perks at 3%

Each is a narrow place perk that was still LOW at 2%. Strike any line to put it back to 2% (delete its row from `RAISES` and its key from `VETO3`, then `--fix`).

| Perk | Name | Family | Effect now | Boost per game day now | Status |
|---|---|---|---|---|---|
| CA:Orchiddell:Larder | Chayote Up the Trellis | F10 | Chayote, maize, tomatillo, amaranth, vanilla and cardamom harvests: 3% chance of one extra | +3% chance on 47% of the harvests = +0.070 crops/day (once in 14 game days) | ok |
| CA:Saffroncrest:Repairs | Polished Signal Mirror | F05 | On sunny days, walks that start at Saffroncrest take 3% less time | walk -3% on 1% of the walking = 0.067 min/day saved | LOW |
| CA:Market of a Thousand Chilies:Larder | The Thousand-and-First | F10 | Chili pepper, black bean, prickly pear cactus, mamey sapote and cacao harvests: 3% chance of one extra | +3% chance on 45% of the harvests = +0.067 crops/day (once in 15 game days) | ok |
| NWE:Spraywell:Larder | Smoked Over Alder | F01 | Fish sell for 3% more at Spraywell's stall | sales +3% on 2% of them = +0.12 Petals/day | LOW |
| NWE:Froststead:Repairs | Waxed Runners | F05 | Walks that start at Froststead take 3% less time in snow or frost | walk -3% on 1% of the walking = 0.039 min/day saved | LOW |
| NWE:Sleetford:Larder | Berries Under the Snow | F11 | Gathering at Sleetford itself: 3% chance of one extra | +3% chance on 6% of the finds = +0.013 finds/day (once in 74 game days) | LOW |
| CB:Saltgate:Repairs | Scoured Salt Scales | F01 | Saltgate's stall pays 3% more for sea salt and shells (`sea-salt`, `spiral-shell`) | sales +3% on 1% of them = +0.060 Petals/day | LOW |
| CB:Lianacombe:Repairs | Retied Liana Bridge | F05 | Walks that start at Lianacombe take 3% less time in rain | walk -3% on 1% of the walking = 0.045 min/day saved | LOW |
| SA:Barleyglen:Cheer | Passed the Gourd | F14 | Gifts of yerba mate, quinoa, cassava, peanut, passion fruit, cherimoya, feijoa, naranjilla, tree tomato, brazil nut or cashew: 3% chance of +1 friendship | 3% chance on 47% of the chats and gifts = +0.11 friendship/day (once in 9 game days) | ok |
| SA:Windwell:Repairs | Wind Pump Regreased | F12 | Watering lasts 3% longer on quinoa and peanut | watering +3% longer on 47% of the beds = 0.14 waterings/day saved | ok |
| SA:Thistlebottom:Larder | Terrace Offering | F13 | Quinoa and cassava harvests: 3% more chance of a seed back | +3% seed chance on 47% of the harvests = +0.070 seeds/day (once in 14 game days) | ok |
| SA:Stoneden:Repairs | Windbreak of Stacked Slate | F09 | Resting on mountain walks that start at Stoneden heals 3% more at night | healing +3% on 1% of it = +0.020 health/day | LOW |
| SA:Canopyglen:Repairs | Patched Dugouts | F09 | Resting on walks that end at Canopyglen heals 3% more in rain or storm | healing +3% on 1% of it = +0.032 health/day | LOW |
| SE:Olive Press Piazza:Repairs | Press Stones Rolled Home | F02 | Bread and oil at the Olive Press Piazza's stall cost 3% less | shop prices -3% on 1% of the spend = 0.11 Petals/day saved | LOW |
| EE:Fernford:Repairs | Ford Stones Set Straight | F05 | Walks that end at Fernford take 3% less time in rain | walk -3% on 1% of the walking = 0.045 min/day saved | LOW |
| EE:Reedby:Larder | Smoke-Rack of Marsh Fish | F01 | Reedby's stall pays 3% more for perch and minnows (`perch`, `minnow`) | sales +3% on 1% of them = +0.060 Petals/day | LOW |
| EE:Painted Egg House:Repairs | One Very Small Brush | F16 | Craft and paint checks at the Painted Egg House are 3% kinder | checks +3% on 3% of them = +0.005 wins/day (once in 198 game days) | LOW |
| EE:Painted Egg House:Larder | Pickled-Egg Shelf | F07 | Egg dishes eaten at the Painted Egg House give 3% more energy | dish energy +3% on 2% of the dishes = +0.019 energy/day | LOW |
| MENA:Brineburrow:Larder | Preserved-Lemon Jar | F02 | Sea salt and jars at Brineburrow's stall cost 3% less | shop prices -3% on 1% of the spend = 0.14 Petals/day saved | LOW |
| MENA:Ambercrest:Repairs | Sand-Swept Stair | F05 | Walks that start at Ambercrest at dusk or night take 3% less time | walk -3% on 1% of the walking = 0.092 min/day saved | LOW |
| MENA:Amberholt:Larder | Mint in the Steam | F08 | Boosts from teas drunk at Amberholt last 3% longer | boosts +3% on 2% of them = +0.50 boost min/day | LOW |
| MENA:Spice Souk:Repairs | Roof Cloth, Stretched Tight | F16 | Haggle checks at the Spice Souk are 3% kinder | checks +3% on 1% of them = +0.002 wins/day (once in 463 game days) | LOW |
| WCA:Fenmead:Larder | Smoked Catfish Basket | F01 | Fenmead's stall pays 3% more for smoked and dried goods | sales +3% on 1% of them = +0.18 Petals/day | LOW |
| WCA:Drum Circle Market:Repairs | Drum Skins Pulled Tight | F15 | Acts at the Drum Circle Market pay 3% more coins on festival days | act coins +3% on 1% of the acts = +0.23 Petals/day | LOW |
| ESA:Bogmead:Larder | Tilapia on a Reed | F01 | Bogmead's stall pays 3% more for golden carp and trout (`golden-carp`, `trout`) | sales +3% on 1% of them = +0.12 Petals/day | LOW |
| CSA:Cloverburrow:Larder | Gleaner's Corner | F10 | Wheat, fenugreek, turmeric, mango and tulsi harvests: 3% chance of one extra | +3% chance on 46% of the harvests = +0.082 crops/day (once in 12 game days) | ok |
| CSA:Poppythorpe:Cheer | Dice on a Saddle Blanket | F14 | Chats with Poppythorpe's folk at night have a 3% chance of +1 friendship | 3% chance on 0% of the chats and gifts = +0.001 friendship/day (once in 833 game days) | LOW |
| CSA:Pinecrest:Larder | Apricot Kernels in the Apron | F10 | Apricot, mung bean, ginger, melon, cinnamon, tea and black pepper harvests: 3% chance of one extra | +3% chance on 47% of the harvests = +0.085 crops/day (once in 12 game days) | ok |
| CSA:Floating Flower Market:Repairs | Bailed-Out Flower Boat | F01 | The Floating Flower Market pays 3% more for flowers you sell | sales +3% on 1% of them = +0.12 Petals/day | LOW |
| EA:Tidecombe:Repairs | Tarred Flat-Bottom | F05 | Walks between Tidecombe and Poppywell take 3% less time, both ways | walk -3% on 4% of the walking = 0.25 min/day saved | LOW |
| SEA:Sandpiperglen:Larder | Shrimp-Paste Jar | F11 | Gathering on coast walks that end at Sandpiperglen: 3% chance of one extra | +3% chance on 6% of the finds = +0.017 finds/day (once in 60 game days) | LOW |
| SEA:Shellnook:Repairs | Outrigger Lashed Tight | F05 | Walks between Shellnook and Turtleburrow take 3% less time in wind or storm, both ways | walk -3% on 1% of the walking = 0.037 min/day saved | LOW |
| SEA:Floating Market:Repairs | Bailed and Balanced | F01 | The Floating Market's boats pay 3% more for dishes you sell | sales +3% on 2% of them = +0.36 Petals/day | LOW |
| OC:Turtleburrow:Cheer | Quiet as Low Tide | F09 | Rest acts at Turtleburrow heal 3% more at dawn | healing +3% on 2% of it = +0.081 health/day | LOW |
| OC:Brineglen:Repairs | Salt-Proof Shutters | F05 | Walks that start at Brineglen take 3% less time in fog | walk -3% on 0% of the walking = 0.026 min/day saved | LOW |
| OC:Salthollow:Repairs | Pandanus-Rope Rails | F15 | Fishing and gathering acts at Salthollow pay 3% more coins | act coins +3% on 2% of the acts = +0.57 Petals/day | LOW |

**29 of them are still LOW at 3%.** Each is the second perk of its family in its region: the first one took the region-wide slot (rule P3: one `region=` perk per family per region), and a perk tied to one stop reaches 2 to 11% of the day, so even 3% stays under 0.35%. For Josh, three ways out, none applied:
1. Let the second perk take the region's other landscapes (the first names half of the region; the two never meet on one event, so nothing stacks). Needs P3 to read "one per family per landscape of a region".
2. Give these stops a perk of a family their region does not have yet.
3. Leave them as small local colour at 3%.

## 8. Every raised perk, before and after (312)

Boost = the benefit per game day in the perk's own unit. % = share of the day's domain (number perks) or how often the charge is used (daily charges).

| Perk | Name | Fam | Before | Boost before | After | Boost after | VP/day | Status |
|---|---|---|---|---|---|---|---|---|
| NA:Maplewold Market:Repairs | Level Scales | F01 | +1%: Maplewold-native crops sell for 1% more | 0.45%; +0.36 Petals/day | +1%: Everything you sell in a shop sells for 1% more | 1.00%; +0.80 Petals/day | 0.80 | ok |
| NA:Poppyburrow:Repairs | The Straightened Signpost | F05 | -2%: Walks between Poppyburrow and any of its seven neighbours (six today, + Granitegate) take 2% less time, both ways | 0.22%; 0.34 min/day saved | -2%: Walks on the Maplewold's forest, grassland and wetland roads take 2% less time | 1.17%; 1.8 min/day saved | 0.55 | ok |
| NA:Poppyburrow:Larder | Second Breakfast | F07 | +2%: Home-cooked dishes eaten at dawn give 2% more energy | 0.25%; +0.045 energy/day | +2%: Home-cooked dishes eaten at dawn or by day give 2% more energy | 1.50%; +0.27 energy/day | 0.81 | ok |
| NA:Honeybrook:Repairs | Tidy Skeps | F17 | -2%: Pests are 2% less likely on flowering plants | 0.60%; 0.006 pests/day fewer (once in 167 game days) | -2%: Pests are 2% less likely on flowers, herbs and fruit crops | 1.20%; 0.012 pests/day fewer (once in 83 game days) | 0.06 | ok |
| NA:Honeybrook:Larder | Honey in the Tea | F08 | +2%: Tea boosts last 2% longer | 0.60%; +2.7 boost min/day | +2%: Boosts from teas, other drinks and sweets last 2% longer | 1.00%; +4.5 boost min/day | 0.45 | ok |
| NA:Cloverholt:Repairs | Greased Wheel | F06 | -2%: Breads and bakes cook 2% faster | 0.60%; 0.18 min/day saved | -2%: Breads, bakes, porridges and anything else with grain in it cook 2% faster | 1.00%; 0.30 min/day saved | 0.09 | ok |
| NA:Cloverholt:Larder | Miller's Pinch | F10 | +1%: Oat and lentil harvests: 1% chance of one extra | 0.35%; +0.010 crops/day (once in 95 game days) | +2%: Oat, lentil, soybean and kidney bean harvests: 2% chance of one extra | 1.40%; +0.042 crops/day (once in 24 game days) | 0.34 | ok |
| NA:Acornby:Repairs | Dry Woodpile | F09 | +2%: Resting on a forest trail heals 2% more | 0.25%; +0.11 health/day | +2%: Resting on any trail heals 2% more | 1.00%; +0.44 health/day | 0.22 | ok |
| NA:Acornby:Larder | Squirrel's Arithmetic | F11 | +1%: Gathering in forest: 1% chance of one extra | 0.25%; +0.015 finds/day (once in 67 game days) | +2%: Gathering in forest and grassland: 2% chance of one extra | 1.00%; +0.060 finds/day (once in 17 game days) | 0.72 | ok |
| NA:Acornby:Cheer | Fireside Regular | F16 | +1%: Checks at camp stops are 1% kinder | 0.12%; +0.007 wins/day (once in 139 game days) | +1%: Stop checks are 1% kinder | 1.00%; +0.060 wins/day (once in 17 game days) | 2.76 | ok |
| NA:Birchhollow:Larder | Sawdust Mulch | F12 | +2%: Watering lasts 2% longer on hot or windy days | 0.40%; 0.024 waterings/day saved | +2%: Watering lasts 2% longer in dry weather (sun, cloud, heat or wind) | 1.20%; 0.072 waterings/day saved | 0.22 | ok |
| NA:Mossgate:Repairs | Swept Steps | F19 | +1%: 1% better chance to spot hidden things in forest | 0.25%; +0.005 finds/day (once in 200 game days) | +1%: 1% better chance to spot hidden things | 1.00%; +0.020 finds/day (once in 50 game days) | 0.60 | ok |
| NA:Mossgate:Larder | What You Leave Comes Back | F13 | +1%: Maplewold-native crops: 1% more chance of a seed back | 0.90%; +0.027 seeds/day (once in 37 game days) | +1%: Every crop: 1% more chance of a seed back | 1.00%; +0.030 seeds/day (once in 33 game days) | 0.18 | ok |
| NA:Shellhollow:Repairs | Sound Nets | F15 | +2%: Acts at jetties and ferries pay 2% more coins | 0.34%; +0.77 Petals/day | +2%: Stop acts that cost energy pay 2% more coins | 1.00%; +2.2 Petals/day | 2.25 | ok |
| NA:Shellhollow:Larder | Catch of the Day | F01 | +1%: Fish sell for 1% more | 0.15%; +0.12 Petals/day | +2%: Fish, gathered finds and dishes sell for 2% more | 1.00%; +0.80 Petals/day | 0.80 | ok |
| NA:Pebblestead:Repairs | Beaver-Tight Hull | F18 | -1%: Fast travel that starts at a coast stop costs 1% less | 0.17%; 0.026 Petals/day saved | -1%: Fast travel costs 1% less | 1.00%; 0.15 Petals/day saved | 0.15 | ok |
| NA:Pebblestead:Larder | Porter's Crate | F02 | -1%: Shops on the coast charge 1% less | 0.17%; 0.17 Petals/day saved | -1%: Shops charge 1% less | 1.00%; 1.0 Petals/day saved | 1.00 | ok |
| NA:Iciclecrest:Larder | Watcher's Flask | F05 | -1%: Walking in snow or frost takes 1% less time | 0.13%; 0.20 min/day saved | -2%: Walking in rain, storm, snow, frost, fog or wind takes 2% less time | 1.00%; 1.5 min/day saved | 0.47 | ok |
| NA:Snowcombe:Cheer | Warm to the Bones | F09 | +2%: Healing is 2% stronger while it snows | 0.14%; +0.062 health/day | +2%: Healing is 2% stronger in rain, storm, snow, frost, fog or wind | 1.00%; +0.44 health/day | 0.22 | ok |
| NA:Granitegate:Repairs | This Year's Stone | F20 | +1 point: +1 max health on the Maplewold's mountain trails (Cairnback Ridge and the Climb) | 0.19%; 0.17 fights/day with it | +1 point: +1 max health on the Maplewold's mountain and tundra trails | 0.57%; 0.50 fights/day with it | 0.25 | ok |
| NA:Granitegate:Larder | Goat-Track Pickings | F11 | +1%: Gathering on the Maplewold's mountain trails: 1% chance of one extra | 0.08%; +0.005 finds/day (once in 200 game days) | +2%: Gathering on the Maplewold's mountain, tundra, coast and wetland trails: 2% chance of one extra | 1.00%; +0.060 finds/day (once in 17 game days) | 0.72 | ok |
| CA:Larkbrook:Repairs | Border Lamp | F05 | -1%: Walking at night takes 1% less time | 0.12%; 0.23 min/day saved | -1%: Walking takes 1% less time | 1.00%; 1.8 min/day saved | 1.50 | ok |
| CA:Larkbrook:Cheer | Up With the Lark | F03 | +1%: 1% more XP at dawn | 0.12%; +34 XP/day | +1%: 1% more XP | 1.00%; +270 XP/day | 8.00 | ok |
| NWE:Windbottom:Cheer | Tailwind | F03 | +2%: 2% more XP on windy days | 0.20%; +54 XP/day | +2%: 2% more XP in wind, storm, rain, snow, frost or fog | 1.00%; +270 XP/day | 8.00 | ok |
| EA:Honeythorpe:Repairs | Propped Boughs | F04 | +1%: 1% more garden XP from fruit and tree crops | 0.30%; +0.32 garden XP/day | +1%: 1% more garden XP | 1.00%; +1.1 garden XP/day | 1.08 | ok |
| NA:Sugar Shack:Repairs | Stacked Birch | F06 | -2%: Syrups and sweets cook 2% faster | 0.30%; 0.090 min/day saved | -2%: Syrups, sweets, preserves and drinks cook 2% faster | 1.00%; 0.30 min/day saved | 0.09 | ok |
| NA:Sugar Shack:Larder | Brim-Full Bucket | F10 | +1%: Tree and sap harvests: 1% chance of one extra | 0.20%; +0.006 crops/day (once in 167 game days) | +2%: Harvests from trees, bushes and vines (anything that regrows): 2% chance of one extra | 1.00%; +0.030 crops/day (once in 33 game days) | 0.24 | ok |
| CA:Maizehollow Market:Repairs | Relaid Cobbles | F18 | -1%: Fast travel that ends at Maizehollow Market costs 1% less | 0.30%; 0.14 Petals/day saved | -2%: Fast travel that starts in Maizehollow's grassland and rainforest zones costs 2% less | 1.20%; 0.54 Petals/day saved | 0.54 | ok |
| CA:Maizehollow Market:Larder | Thirteen Ears to the Dozen | F01 | +2%: Corn sells for 2% more at Maizehollow Market's stalls | 0.02%; +0.040 Petals/day | +2%: Stalls in Maizehollow's grassland and rainforest zones pay 2% more for what you sell | 1.20%; +3.0 Petals/day | 3.00 | ok |
| CA:Poppynook:Repairs | Dressed Grindstone | F06 | -2%: Dishes with corn in them cook 2% faster | 0.76%; 0.34 min/day saved | -2%: Dishes with maize or black bean in them cook 2% faster | 1.32%; 0.59 min/day saved | 0.49 | ok |
| CA:Meadowmere:Repairs | Restrung Hammocks | F22 | +1: Rest acts at Meadowmere from dusk on give 1 more energy | 0.88%; +0.070 energy/day (once in 14 game days) | +1: Rest acts at Meadowmere give 1 more energy in spring and summer | 1.75%; +0.14 energy/day (once in 7 game days) | 0.42 | ok |
| CA:Meadowmere:Larder | Beans in the Pot Since Tuesday | F07 | +2%: Dishes with black beans give 2% more energy | 0.76%; +0.21 energy/day | +2%: Dishes with black bean or maize give 2% more energy | 1.32%; +0.36 energy/day | 1.07 | ok |
| CA:Jadedell:Repairs | Reset Temple Steps | F05 | -2%: Walks from Jadedell to the Stepped Seed Temple take 2% less time | 0.04%; 0.067 min/day saved | -2%: Walks in Maizehollow's grassland and rainforest zones take 2% less time | 1.20%; 2.2 min/day saved | 1.80 | ok |
| CA:Jadedell:Larder | Seed Left on the Altar | F13 | +1%: Tomatillo harvests: 1% more chance of a seed back | 0.17%; +0.009 seeds/day (once in 114 game days) | +2%: Tomatillo, maize and black bean harvests: 2% more chance of a seed back | 1.05%; +0.052 seeds/day (once in 19 game days) | 0.31 | ok |
| CA:Frondthorpe:Repairs | Shored-Up Terraces | F12 | +2%: Watering lasts 2% longer on avocado and papaya | 0.17%; 0.017 waterings/day saved | +2%: Watering lasts 2% longer on avocado, papaya, maize, black bean and amaranth | 0.95%; 0.095 waterings/day saved | 0.29 | ok |
| CA:Frondthorpe:Larder | Two From One Stone | A3 | 1 a day: Once a day, your first avocado harvest gives one extra avocado | once in 5 game days; 1.5 VP/day | 1 a day: Once a day, your first avocado or papaya harvest gives one extra of that crop | once in 3 game days; 2.8 VP/day | 2.82 | ok |
| CA:Orchiddell:Repairs | Retied Orchid Stakes | F17 | -2%: Pests are 2% less likely on chayote and amaranth | 0.17%; 0.002 pests/day fewer (once in 600 game days) | -2%: Pests are 2% less likely on chayote, amaranth, maize, black bean and chili pepper | 1.22%; 0.012 pests/day fewer (once in 82 game days) | 0.06 | ok |
| CA:Orchiddell:Larder | Chayote Up the Trellis | F10 | +1%: Chayote harvests: 1% chance of one extra | 0.04%; +0.002 crops/day (once in 480 game days) | +3%: Chayote, maize, tomatillo, amaranth, vanilla and cardamom harvests: 3% chance of one extra | 1.40%; +0.070 crops/day (once in 14 game days) | 0.56 | ok |
| CA:Saffroncrest:Repairs | Polished Signal Mirror | F05 | -2%: On sunny days, walks that start at Saffroncrest take 2% less time | 0.02%; 0.044 min/day saved | -3%: On sunny days, walks that start at Saffroncrest take 3% less time | 0.04%; 0.067 min/day saved | 0.06 | LOW |
| CA:Scorchburrow:Repairs | Mended Water Jars | F12 | +2%: Watering lasts 2% longer on chili peppers and tomatillos in heat | 0.07%; 0.007 waterings/day saved | +2%: Watering lasts 2% longer on chili pepper, tomatillo, chayote, prickly pear cactus and mamey sapote | 0.95%; 0.095 waterings/day saved | 0.29 | ok |
| CA:Scorchburrow:Larder | Supper After Sundown | F07 | +2%: Dishes eaten at Scorchburrow at night give 2% more energy | 0.02%; +0.005 energy/day | +2%: Dishes eaten in Maizehollow's grassland and desert zones give 2% more energy | 1.00%; +0.27 energy/day | 0.81 | ok |
| CA:Scorchburrow:Cheer | A Wish per Shooting Star | A4 | 2 coins, 1 a day: First rest act at Scorchburrow each night: 2 coins turn up in the sand | once in 31 game days; 0.063 VP/day | 2 coins, 1 a day: First rest act at Scorchburrow each day: 2 coins turn up in the sand | once in 4 game days; 0.50 VP/day | 0.50 | ok |
| CA:Stonethorpe:Repairs | Relined Ash Pools | F09 | +2%: Healing from rest acts at Stonethorpe is 2% stronger at dawn and dusk | 0.07%; +0.067 health/day | +2%: Rest acts and trail rests in Maizehollow's grassland and mountain zones heal 2% more | 1.00%; +0.95 health/day | 0.48 | ok |
| CA:Stonethorpe:Larder | Ash for the Beds | F04 | +2%: 2% more garden XP from black beans | 0.35%; +0.31 garden XP/day | +2%: Black bean, maize and chili pepper give 2% more garden XP | 1.05%; +0.94 garden XP/day | 0.94 | ok |
| CA:Flintcove:Repairs | Knapped a Fresh Edge | A2 | 1 a day: Once a day, the first wear on your rock pick on a walk that starts at Flintcove is skipped | once in 7 game days; 0.28 VP/day | 1 a day: Once a day, the first wear on your rock pick anywhere in Maizehollow is skipped | once in 2 game days; 1.2 VP/day | 1.20 | ok |
| CA:Flintcove:Larder | Comal Hammered Flat | F06 | -2%: Dishes with tomatillo in them cook 2% faster | 0.76%; 0.34 min/day saved | -2%: Dishes with tomatillo or chili pepper in them cook 2% faster | 1.32%; 0.59 min/day saved | 0.49 | ok |
| CA:Market of a Thousand Chilies:Repairs | Repainted Stall Numbers | F02 | -2%: Spices and chilies cost 2% less at the Thousand Chilies stalls | 0.03%; 0.096 Petals/day saved | -2%: Stalls in Maizehollow's grassland and rainforest zones charge 2% less | 1.20%; 3.6 Petals/day saved | 3.60 | ok |
| CA:Market of a Thousand Chilies:Larder | The Thousand-and-First | F10 | +1%: Chili pepper harvests: 1% chance of one extra | 0.17%; +0.009 crops/day (once in 114 game days) | +3%: Chili pepper, black bean, prickly pear cactus, mamey sapote and cacao harvests: 3% chance of one extra | 1.35%; +0.067 crops/day (once in 15 game days) | 0.54 | ok |
| CA:Market of a Thousand Chilies:Cheer | Tried the Hot One | F08 | +2%: Boosts from dishes with chili pepper last 2% longer | 0.76%; +5.1 boost min/day | +2%: Dishes with chili pepper or maize give boosts that last 2% longer | 1.32%; +8.8 boost min/day | 0.88 | ok |
| NWE:Mistmoor Market:Repairs | Patched Awnings | F01 | +2%: On rainy days, Mistmoor Market's stalls pay 2% more for what you sell | 0.02%; +0.060 Petals/day | +2%: Stalls in Mistmoor's grassland and coast zones pay 2% more for what you sell | 1.00%; +2.5 Petals/day | 2.50 | ok |
| NWE:Mistmoor Market:Larder | Leek by the Yard | F02 | -2%: Leeks cost 2% less at Mistmoor Market's stalls | 0.02%; 0.048 Petals/day saved | -2%: Stalls in Mistmoor's grassland and forest zones charge 2% less | 1.20%; 3.6 Petals/day saved | 3.60 | ok |
| NWE:Windburrow:Repairs | Reset Sails | F06 | -2%: On windy days, dishes with rye or barley cook 2% faster | 0.13%; 0.059 min/day saved | -2%: Dishes with rye or barley in them cook 2% faster | 1.32%; 0.59 min/day saved | 0.49 | ok |
| NWE:Larkden:Repairs | Trimmed Wicks | F09 | +2%: Healing from rest acts at Larkden is 2% stronger when it rains | 0.04%; +0.040 health/day | +2%: Rest acts and trail rests in Mistmoor's forest and coast zones heal 2% more | 1.00%; +0.95 health/day | 0.48 | ok |
| NWE:Larkden:Larder | Sprouts Done Properly | F07 | +2%: Dishes with brussels sprouts give 2% more energy | 0.76%; +0.21 energy/day | +2%: Dishes with brussels sprouts or rye give 2% more energy | 1.32%; +0.36 energy/day | 1.07 | ok |
| NWE:Larkden:Cheer | Fiddle in the Corner | F03 | +2%: 2% more XP from acts at Larkden from dusk on | 0.04%; +3.2 XP/day | +2%: Acts at stops in Mistmoor's forest and coast zones give 2% more XP | 1.00%; +81 XP/day | 2.40 | ok |
| NWE:Hollowknoll:Repairs | Righted Waymarker | F05 | -2%: Walks that end at Hollowknoll in fog or rain take 2% less time | 0.02%; 0.044 min/day saved | -2%: Walks in Mistmoor's grassland and coast zones take 2% less time | 1.00%; 1.8 min/day saved | 1.50 | ok |
| NWE:Hollowknoll:Larder | One for the Stones | F11 | +1%: In fog or after rain, gathering on walks out of Hollowknoll has a 1% chance of one extra | 0.01%; +0.001 finds/day (once in 1015 game days) | +2%: Gathering in Mistmoor's grassland and forest zones: 2% chance of one extra | 1.20%; +0.096 finds/day (once in 10 game days) | 1.15 | ok |
| NWE:Fernden:Repairs | Dry Kindling Under Cover | A1 | 1 a day: Once a day, the first act you do at Fernden in the rain costs 1 less energy | once in 26 game days; 0.11 VP/day | 1 a day: Once a day, the first check act you do at Fernden costs 1 less energy | once in 4 game days; 0.76 VP/day | 0.76 | ok |
| NWE:Fernden:Larder | Hedgerow Pudding | F10 | +1%: Lingonberry harvests: 1% chance of one extra | 0.05%; +0.003 crops/day (once in 400 game days) | +2%: Lingonberry, rye, leek, blackcurrant and kohlrabi harvests: 2% chance of one extra | 1.00%; +0.050 crops/day (once in 20 game days) | 0.40 | ok |
| NWE:Hazelmere:Larder | Jam Pan Scoured | F06 | -2%: Dishes with rhubarb or blackcurrant cook 2% faster | 0.46%; 0.21 min/day saved | -2%: Dishes with rhubarb, blackcurrant or leek in them cook 2% faster | 1.10%; 0.50 min/day saved | 0.41 | ok |
| NWE:Hazelmere:Cheer | Conker Champion | F15 | +2%: Contests at Hazelmere pay 2% more coins | 0.03%; +0.18 Petals/day | +2%: Acts at stops in Mistmoor's grassland and forest zones pay 2% more coins | 1.20%; +6.7 Petals/day | 6.72 | ok |
| NWE:Spraywell:Larder | Smoked Over Alder | F01 | +2%: Fish sell for 2% more at Spraywell's stall | 0.03%; +0.080 Petals/day | +3%: Fish sell for 3% more at Spraywell's stall | 0.05%; +0.12 Petals/day | 0.12 | LOW |
| NWE:Brinehollow:Repairs | Greased Winch | F18 | -1%: Fast travel that starts at Brinehollow in fog or rain costs 1% less | 0.02%; 0.008 Petals/day saved | -2%: Fast travel that starts in Mistmoor's forest and coast zones costs 2% less | 1.00%; 0.45 Petals/day saved | 0.45 | ok |
| NWE:Brinehollow:Larder | Pickle Crock Under the Bench | F08 | +2%: Boosts from dishes with kohlrabi last 2% longer | 0.24%; +1.6 boost min/day | +2%: Dishes with kohlrabi, rye or barley give boosts that last 2% longer | 1.44%; +9.7 boost min/day | 0.97 | ok |
| NWE:Froststead:Repairs | Waxed Runners | F05 | -2%: Walks that start at Froststead take 2% less time in snow or frost | 0.01%; 0.026 min/day saved | -3%: Walks that start at Froststead take 3% less time in snow or frost | 0.02%; 0.039 min/day saved | 0.03 | LOW |
| NWE:Froststead:Larder | Sweeter After Frost | F10 | +1%: Brussels sprouts harvested in frost: 1% chance of one extra | 0.01%; +0.001 crops/day (once in 1905 game days) | +2%: Brussels sprouts, barley, rhubarb, asparagus, cloudberry and gooseberry harvests: 2% chance of one extra | 0.97%; +0.048 crops/day (once in 21 game days) | 0.39 | ok |
| NWE:Sleetford:Larder | Berries Under the Snow | F11 | +1%: Gathering at Sleetford itself: 1% chance of one extra | 0.06%; +0.004 finds/day (once in 223 game days) | +3%: Gathering at Sleetford itself: 3% chance of one extra | 0.17%; +0.013 finds/day (once in 74 game days) | 0.16 | LOW |
| NWE:Thatchtop Tearoom:Repairs | Reglazed Cold Frame | F12 | +2%: Watering lasts 2% longer on rhubarb and asparagus | 0.20%; 0.020 waterings/day saved | +2%: Watering lasts 2% longer on rhubarb, asparagus, rye, barley and leek | 1.25%; 0.12 waterings/day saved | 0.38 | ok |
| NWE:Northern Lights Sauna:Repairs | Split Birch for the Stove | F22 | +1: Rest acts at the Northern Lights Sauna give 1 more energy at night | 0.44%; +0.035 energy/day (once in 29 game days) | +1: Rest acts at the Northern Lights Sauna give 1 more energy outside summer | 2.63%; +0.21 energy/day (once in 5 game days) | 0.63 | ok |
| NWE:Northern Lights Sauna:Larder | Rye Porridge After the Plunge | F07 | +2%: Dishes eaten at the Northern Lights Sauna while it snows give 2% more energy | 0.01%; +0.003 energy/day | +2%: Dishes eaten in Mistmoor's forest and tundra zones give 2% more energy | 1.00%; +0.27 energy/day | 0.81 | ok |
| CB:Sunsprinkle Isles Market:Repairs | Restitched Sailcloth Shade | F01 | +2%: In the day part "day", fruit sells for 2% more at the Isles Market's stalls | 0.03%; +0.062 Petals/day | +2%: Stalls in the Sunsprinkle Isles' island and coast zones pay 2% more for what you sell | 1.20%; +3.0 Petals/day | 3.00 | ok |
| CB:Sunsprinkle Isles Market:Larder | Lime With Everything | F07 | +2%: Dishes with lime give 2% more energy | 0.76%; +0.21 energy/day | +2%: Dishes with lime or sweet potato give 2% more energy | 1.32%; +0.36 energy/day | 1.07 | ok |
| CB:Shoreford:Repairs | Caulked Dugout | F18 | -1%: Fast travel from Shoreford to Maizehollow (its town) costs 1% less | 0.02%; 0.011 Petals/day saved | -2%: Fast travel that starts in the Sunsprinkle Isles' island and coast zones costs 2% less | 1.20%; 0.54 Petals/day saved | 0.54 | ok |
| CB:Breezehollow:Repairs | Windbreak Replanted | F17 | -2%: Pests are 2% less likely on lime and guava | 0.45%; 0.004 pests/day fewer (once in 222 game days) | -2%: Pests are 2% less likely on lime, guava, plantain, soursop and grapefruit | 1.00%; 0.010 pests/day fewer (once in 100 game days) | 0.05 | ok |
| CB:Breezehollow:Larder | Guava Jelly Cooling | F10 | +1%: Guava harvests: 1% chance of one extra | 0.05%; +0.003 crops/day (once in 400 game days) | +2%: Guava, sweet potato, plantain, breadfruit and grapefruit harvests: 2% chance of one extra | 1.00%; +0.050 crops/day (once in 20 game days) | 0.40 | ok |
| CB:Palmknoll:Repairs | Rethatched Palm Roof | F09 | +2%: Healing from rest acts at Palmknoll is 2% stronger in heat (siesta) | 0.03%; +0.027 health/day | +2%: Rest acts and trail rests in the Sunsprinkle Isles' island and coast zones heal 2% more | 1.20%; +1.1 health/day | 0.57 | ok |
| CB:Palmknoll:Larder | Peas and No Hurry | F06 | -2%: Dishes with pigeon peas cook 2% faster | 0.76%; 0.34 min/day saved | -2%: Dishes with pigeon pea or plantain in them cook 2% faster | 1.32%; 0.59 min/day saved | 0.49 | ok |
| CB:Sandpipergate:Repairs | Lighthouse Lamp Relit | F05 | -2%: Walks that end at Sandpipergate at night take 2% less time | 0.01%; 0.025 min/day saved | -2%: Walks in the Sunsprinkle Isles' island and coast zones take 2% less time | 1.20%; 2.2 min/day saved | 1.80 | ok |
| CB:Sandpipergate:Larder | Rock Pools at First Light | F11 | +1%: Gathering on walks from Sandpipergate at dawn: 1% chance of one extra | 0.01%; +0.001 finds/day (once in 1786 game days) | +2%: Gathering in the Sunsprinkle Isles' island and coast zones: 2% chance of one extra | 1.20%; +0.096 finds/day (once in 10 game days) | 1.15 | ok |
| CB:Foamknoll:Larder | Reef Fish on the Coals | F02 | -2%: Fish cost 2% less at Foamknoll's stall | 0.03%; 0.096 Petals/day saved | -2%: Stalls in the Sunsprinkle Isles' island and coast zones charge 2% less | 1.20%; 3.6 Petals/day saved | 3.60 | ok |
| CB:Foamknoll:Cheer | Sundowner on the Planks | F14 | +2%: Chats with Foamknoll's folk at dusk: 2% chance of +1 friendship | 0.01%; +0.001 friendship/day (once in 1250 game days) | +2%: Chats and gifts with folk in the Sunsprinkle Isles' island and coast zones: 2% chance of +1 friendship | 1.20%; +0.096 friendship/day (once in 10 game days) | 0.38 | ok |
| CB:Saltgate:Repairs | Scoured Salt Scales | F01 | +2%: Saltgate's stall pays 2% more for sea salt and shells (`sea-salt`, `spiral-shell`) | 0.02%; +0.040 Petals/day | +3%: Saltgate's stall pays 3% more for sea salt and shells (`sea-salt`, `spiral-shell`) | 0.02%; +0.060 Petals/day | 0.06 | LOW |
| CB:Saltgate:Larder | Baked in a Salt Crust | F13 | +1%: Sweet potato harvests: 1% more chance of a seed back | 0.17%; +0.009 seeds/day (once in 114 game days) | +2%: Sweet potato, pigeon pea and plantain harvests: 2% more chance of a seed back | 1.05%; +0.052 seeds/day (once in 19 game days) | 0.31 | ok |
| CB:Lianacombe:Repairs | Retied Liana Bridge | F05 | -2%: Walks that start at Lianacombe take 2% less time in rain | 0.02%; 0.030 min/day saved | -3%: Walks that start at Lianacombe take 3% less time in rain | 0.03%; 0.045 min/day saved | 0.04 | LOW |
| CB:Lianacombe:Larder | Soursop Leaf Tea | F08 | +2%: Boosts from dishes with soursop last 2% longer | 0.24%; +1.6 boost min/day | +2%: Dishes with soursop, sweet potato or pigeon pea give boosts that last 2% longer | 1.44%; +9.7 boost min/day | 0.97 | ok |
| CB:Lianacombe:Cheer | Tree Frogs at Bath Time | F22 | +1: Rest acts at Lianacombe give 1 more energy while it rains | 0.53%; +0.042 energy/day (once in 24 game days) | +1: Rest acts at Lianacombe give 1 more energy under cloud, in rain, storm or fog | 1.58%; +0.13 energy/day (once in 8 game days) | 0.38 | ok |
| CB:Canopybottom:Repairs | Unblocked Spring Runnel | F12 | +2%: Watering lasts 2% longer on plantain and breadfruit | 0.45%; 0.045 waterings/day saved | +2%: Watering lasts 2% longer on plantain, breadfruit, sweet potato and pigeon pea | 1.15%; 0.11 waterings/day saved | 0.34 | ok |
| CB:Canopybottom:Larder | First Fruits on the Ledge | F04 | +2%: 2% more garden XP from breadfruit | 0.10%; +0.090 garden XP/day | +2%: Breadfruit, sweet potato, pigeon pea and plantain give 2% more garden XP | 1.15%; +1.0 garden XP/day | 1.03 | ok |
| CB:Heronholt:Repairs | Trued Cane Rollers | F06 | -2%: Dishes with pineapple or grapefruit cook 2% faster | 0.46%; 0.21 min/day saved | -2%: Dishes with pineapple, grapefruit or sweet potato in them cook 2% faster | 1.10%; 0.50 min/day saved | 0.41 | ok |
| CB:Mireburrow:Larder | Beds Above the Tide | F17 | -2%: Pests are 2% less likely on sweet potato and pigeon peas | 0.70%; 0.007 pests/day fewer (once in 143 game days) | -2%: Pests are 2% less likely on sweet potato, pigeon pea, breadfruit, pineapple, ackee and nutmeg | 0.97%; 0.010 pests/day fewer (once in 103 game days) | 0.05 | ok |
| CB:Driftwood Tavern:Repairs | Bar Top Planed Smooth | F16 | +2%: Checks at the Driftwood Tavern are 2% kinder from dusk on, while the band plays | 0.04%; +0.002 wins/day (once in 417 game days) | +2%: Stop checks in the Sunsprinkle Isles' island and coast zones are 2% kinder | 1.20%; +0.072 wins/day (once in 14 game days) | 8.21 | ok |
| CB:Turtle Nesting Beach:Repairs | Driftwood Fence Mended | A1 | 1 a day: Once a day, the first act you do at Turtle Nesting Beach at night costs 1 less energy | once in 31 game days; 0.095 VP/day | 1 a day: Once a day, the first tend or mend act you do at Turtle Nesting Beach costs 1 less energy | once in 4 game days; 0.84 VP/day | 0.84 | ok |
| CB:Turtle Nesting Beach:Larder | Pineapple in the Cool Sand | F10 | +1%: Pineapple harvests: 1% chance of one extra | 0.05%; +0.003 crops/day (once in 400 game days) | +2%: Pineapple, pigeon pea, lime, soursop, ackee and nutmeg harvests: 2% chance of one extra | 0.97%; +0.048 crops/day (once in 21 game days) | 0.39 | ok |
| SA:Rainroot Reaches Market:Repairs | Rehung Weavers' Rails | F18 | -1%: Fast travel that starts at the Rainroot Reaches Market costs 1% less | 0.08%; 0.036 Petals/day saved | -2%: Fast travel that starts in the Rainroot Reaches' mountain and rainforest zones costs 2% less | 1.09%; 0.49 Petals/day saved | 0.49 | ok |
| SA:Barleyglen:Repairs | Glazed Against the Pampas Wind | F09 | +2%: Healing from rest acts at Barleyglen is 2% stronger on windy days | 0.03%; +0.027 health/day | +2%: Rest acts and trail rests in the Rainroot Reaches' grassland and rainforest zones heal 2% more | 1.09%; +1.0 health/day | 0.52 | ok |
| SA:Barleyglen:Cheer | Passed the Gourd | F14 | +2%: Gifts of yerba mate: 2% chance of +1 friendship | 0.04%; +0.003 friendship/day (once in 350 game days) | +3%: Gifts of yerba mate, quinoa, cassava, peanut, passion fruit, cherimoya, feijoa, naranjilla, tree tomato, brazil nut or cashew: 3% chance of +1 friendship | 1.42%; +0.11 friendship/day (once in 9 game days) | 0.45 | ok |
| SA:Windwell:Repairs | Wind Pump Regreased | F12 | +2%: Watering lasts 2% longer on quinoa and peanut on windy days | 0.09%; 0.009 waterings/day saved | +3%: Watering lasts 3% longer on quinoa and peanut | 1.40%; 0.14 waterings/day saved | 0.42 | ok |
| SA:Thistlebottom:Repairs | Refitted Stone Stair | F19 | +2%: 2% better chance to spot hidden places on walks that end at Thistlebottom | 0.11%; +0.002 finds/day (once in 446 game days) | +2%: Walks in the Rainroot Reaches' mountain and rainforest zones: 2% better chance to spot hidden things | 1.09%; +0.022 finds/day (once in 46 game days) | 0.65 | ok |
| SA:Thistlebottom:Larder | Terrace Offering | F13 | +1%: Quinoa harvests: 1% more chance of a seed back | 0.23%; +0.012 seeds/day (once in 86 game days) | +3%: Quinoa and cassava harvests: 3% more chance of a seed back | 1.40%; +0.070 seeds/day (once in 14 game days) | 0.42 | ok |
| SA:Thistlebottom:Cheer | Head in the Clouds | A2 | 1 a day: Once a day, a failed Lore check at the Sky City Ruins is rolled again | once in 10 game days; 7.4 VP/day | 1 a day: Once a day, a failed Lore check at the Sky City Ruins or at any other wonder or delve of the Rainroot Reaches is rolled again | once in 3 game days; 26 VP/day | 25.94 | ok |
| SA:Flintburrow:Larder | Watcher's Trail Mix | A1 | 1 a day: Once a day, the first walk of 4 sections or more that starts at Flintburrow costs 1 less energy | once in 9 game days; 0.34 VP/day | 1 a day: Once a day, the first walk that starts at Flintburrow or runs along the road to Condor's Crag costs 1 less energy | once in 4 game days; 0.84 VP/day | 0.84 | ok |
| SA:Highcove:Repairs | Recut Stone Tubs | F22 | +1: Rest acts at Highcove give 1 more energy at dawn | 0.44%; +0.035 energy/day (once in 29 game days) | +1: Rest acts at Highcove give 1 more energy before dusk | 2.63%; +0.21 energy/day (once in 5 game days) | 0.63 | ok |
| SA:Highcove:Larder | Cooling in the Stream | F10 | +1%: Naranjilla and tamarillo harvests: 1% chance of one extra | 0.07%; +0.004 crops/day (once in 280 game days) | +2%: Naranjilla, tree tomato, quinoa and cassava harvests: 2% chance of one extra | 1.08%; +0.054 crops/day (once in 19 game days) | 0.43 | ok |
| SA:Highcove:Cheer | The Dolphins Said So | F23 | +1%: Fast travel that starts at Highcove: 1% more chance to turn up a seed | 0.08%; +0.000 seeds/day (once in 4167 game days) | +2%: Fast travel that starts in the Rainroot Reaches' grassland and rainforest zones: 2% more chance to turn up a seed | 1.09%; +0.003 seeds/day (once in 306 game days) | 0.02 | ok |
| SA:Stoneden:Repairs | Windbreak of Stacked Slate | F09 | +2%: Resting on mountain walks that start at Stoneden heals 2% more at night | 0.01%; +0.013 health/day | +3%: Resting on mountain walks that start at Stoneden heals 3% more at night | 0.02%; +0.020 health/day | 0.01 | LOW |
| SA:Figknoll:Repairs | Lashed Bamboo Ladders | F17 | -2%: Pests are 2% less likely on passion fruit and cherimoya | 0.14%; 0.001 pests/day fewer (once in 700 game days) | -2%: Pests are 2% less likely on passion fruit, cherimoya, quinoa and cassava | 1.08%; 0.011 pests/day fewer (once in 93 game days) | 0.05 | ok |
| SA:Frondstead:Repairs | Drying Loft Reroofed | F12 | +2%: Watering lasts 2% longer on yerba mate and feijoa | 0.14%; 0.014 waterings/day saved | +2%: Watering lasts 2% longer on feijoa, yerba mate, cassava, passion fruit, cherimoya, naranjilla, tree tomato, brazil nut and cashew | 0.96%; 0.096 waterings/day saved | 0.29 | ok |
| SA:Frondstead:Larder | Topped Up, Never Stirred | F08 | +2%: Boosts from dishes or drinks with yerba mate last 2% longer | 0.17%; +1.2 boost min/day | +2%: Dishes with yerba mate or quinoa give boosts that last 2% longer | 1.09%; +7.3 boost min/day | 0.73 | ok |
| SA:Frondstead:Cheer | Nothing to Do but Talk | F14 | +2%: Chats with Frondstead's folk while it rains: 2% chance of +1 friendship | 0.01%; +0.001 friendship/day (once in 1042 game days) | +2%: Chats and gifts with folk in the Rainroot Reaches' grassland and rainforest zones: 2% chance of +1 friendship | 1.09%; +0.087 friendship/day (once in 11 game days) | 0.35 | ok |
| SA:Canopyglen:Repairs | Patched Dugouts | F09 | +2%: Resting on walks that end at Canopyglen heals 2% more in rain or storm | 0.02%; +0.021 health/day | +3%: Resting on walks that end at Canopyglen heals 3% more in rain or storm | 0.03%; +0.032 health/day | 0.02 | LOW |
| SA:Canopyglen:Larder | Wrapped in Leaves | F11 | +1%: Gathering with a rod on walks from Canopyglen: 1% chance of one extra | 0.02%; +0.001 finds/day (once in 744 game days) | +2%: Gathering in the Rainroot Reaches' grassland and rainforest zones: 2% chance of one extra | 1.09%; +0.087 finds/day (once in 11 game days) | 1.05 | ok |
| SA:Scorchby:Larder | Grown Under Glass | F04 | +2%: 2% more garden XP from peanut | 0.47%; +0.42 garden XP/day | +2%: Peanut, quinoa and cassava give 2% more garden XP | 1.40%; +1.3 garden XP/day | 1.26 | ok |
| SA:Duneford:Repairs | Salt Blocks Squared | F01 | +2%: Duneford's stall pays 2% more at dawn, when the caravans load | 0.02%; +0.050 Petals/day | +2%: Stalls in the Rainroot Reaches' grassland, mountain and desert zones pay 2% more for what you sell | 1.45%; +3.6 Petals/day | 3.64 | ok |
| SA:Duneford:Larder | Caravan Sacks | F02 | -2%: Peanuts and quinoa cost 2% less at Duneford's stall | 0.02%; 0.048 Petals/day saved | -2%: Stalls in the Rainroot Reaches' grassland, mountain and desert zones charge 2% less | 1.45%; 4.4 Petals/day saved | 4.36 | ok |
| SA:Gaucho Gnome Ranch:Repairs | Saddle on the Rail | A1 | 1 a day: Once a day, the first walk from the Gaucho Gnome Ranch to Windwell costs 1 less energy | once in 11 game days; 0.28 VP/day | 1 a day: Once a day, the first walk on a grassland or desert road of the Rainroot Reaches costs 1 less energy (saddled at the Gaucho Gnome Ranch) | once in 1 game days; 2.9 VP/day | 2.86 | ok |
| SA:Gaucho Gnome Ranch:Larder | Saved for Sowing | F13 | +1%: Peanut harvests: 1% more chance of a seed back | 0.23%; +0.012 seeds/day (once in 86 game days) | +2%: Peanut, passion fruit, cherimoya, feijoa, naranjilla, yerba mate, tree tomato, brazil nut and cashew harvests: 2% more chance of a seed back | 0.96%; +0.048 seeds/day (once in 21 game days) | 0.29 | ok |
| SA:Gaucho Gnome Ranch:Cheer | Guitar on the Porch | F16 | +2%: Contests at the Gaucho Gnome Ranch are 2% kinder | 0.03%; +0.002 wins/day (once in 521 game days) | +2%: Stop checks in the Rainroot Reaches' grassland and rainforest zones are 2% kinder | 1.09%; +0.065 wins/day (once in 15 game days) | 7.46 | ok |
| SE:Olivewhistle Shore Market:Repairs | Swept Colonnade | F02 | -2%: Seeds bought in Olivewhistle Shore Market cost 2% less | 0.06%; 0.19 Petals/day saved | -2%: Stalls in Olivewhistle Shore's mountain and coast zones charge 2% less | 1.60%; 4.8 Petals/day saved | 4.80 | ok |
| SE:Olivewhistle Shore Market:Larder | Oil-Jar Shelf | F01 | +2%: The stalls of Olivewhistle Shore Market pay 2% more for Shore-native crops | 0.08%; +0.20 Petals/day | +2%: Stalls in Olivewhistle Shore's mountain and coast zones pay 2% more for what you sell | 1.60%; +4.0 Petals/day | 4.00 | ok |
| SE:Brinewick:Larder | Salt-Crust Supper | F07 | +2%: Dishes eaten at Brinewick at dusk or night give 2% more energy | 0.04%; +0.011 energy/day | +2%: Dishes eaten in Olivewhistle Shore's mountain zones give 2% more energy | 1.00%; +0.27 energy/day | 0.81 | ok |
| SE:Brinewick:Cheer | Lamp in the Window | A1 | 1 a day: Once a day, the first walk that ends at Brinewick at night costs 1 less energy | once in 29 game days; 0.11 VP/day | 1 a day: Once a day, the first walk that starts or ends at Brinewick costs 1 less energy | once in 4 game days; 0.84 VP/day | 0.84 | ok |
| SE:Driftmead:Repairs | Tarred Seams | F05 | -2%: Walks from Driftmead to Turtlenook or to the Labyrinth Isle take 2% less time | 0.07%; 0.13 min/day saved | -2%: Walks in Olivewhistle Shore's mountain and coast zones take 2% less time | 1.60%; 2.9 min/day saved | 2.40 | ok |
| SE:Driftmead:Larder | Crates on the Quay | A3 | 1 a day: Once a day, the first seed you buy at Driftmead's stall comes with one extra | once in 9 game days; 0.90 VP/day | 1 a day: Once a day, the first seed you buy at any stall in Olivewhistle Shore comes with one extra (Driftmead's crates) | once in 2 game days; 4.8 VP/day | 4.80 | ok |
| SE:Sprayglen:Larder | Squid-Ink Bucket | F11 | +1%: Gathering at Sprayglen with a tide bucket has a 1% chance of one extra | 0.02%; +0.001 finds/day (once in 744 game days) | +2%: Gathering in Olivewhistle Shore's mountain and coast zones: 2% chance of one extra | 1.60%; +0.13 finds/day (once in 8 game days) | 1.54 | ok |
| SE:Cliffbrook:Repairs | Goat-Proof Sluice | F15 | +2%: Acts at Cliffbrook that cost 2 or more energy pay 2% more coins | 0.05%; +0.27 Petals/day | +2%: Acts at stops in Olivewhistle Shore's mountain zones pay 2% more coins | 1.00%; +5.6 Petals/day | 5.60 | ok |
| SE:Screebottom:Repairs | Terrace Walls | F12 | +2%: Watering lasts 2% longer on Screebottom's local crops on hot days | 0.20%; 0.020 waterings/day saved | +2%: Watering lasts 2% longer on fava bean, oregano and artichoke | 1.40%; 0.14 waterings/day saved | 0.42 | ok |
| SE:Screebottom:Cheer | Mason's Eye | F16 | +2%: Craft and mend checks at Screebottom are 2% kinder | 0.06%; +0.003 wins/day (once in 298 game days) | +2%: Stop checks in Olivewhistle Shore's mountain zones are 2% kinder | 1.00%; +0.060 wins/day (once in 17 game days) | 6.84 | ok |
| SE:Screemere:Repairs | Reset Stepping Stones | F19 | +2%: Walks that end at Screemere have a 2% better chance to spot hidden things | 0.11%; +0.002 finds/day (once in 446 game days) | +2%: Walks in Olivewhistle Shore's mountain zones: 2% better chance to spot hidden things | 1.00%; +0.020 finds/day (once in 50 game days) | 0.60 | ok |
| SE:Screemere:Larder | Chestnut in the Bowl | F13 | +1%: Screemere's local crops have 1% more chance of a seed back in autumn | 0.25%; +0.012 seeds/day (once in 80 game days) | +2%: Fava bean, oregano and artichoke harvests: 2% more chance of a seed back | 1.40%; +0.070 seeds/day (once in 14 game days) | 0.42 | ok |
| SE:Atollmead:Repairs | Driftwood Props | F04 | +2%: 2% more garden XP from the fruit trees among Atollmead's local crops | 0.39%; +0.35 garden XP/day | +2%: Olive, fig, lemon, orange, mandarin, carob, fava bean and oregano give 2% more garden XP | 1.32%; +1.2 garden XP/day | 1.19 | ok |
| SE:Atollmead:Larder | Sun-Dried on the Roof | F08 | +2%: Boosts from dishes eaten at Atollmead last 2% longer | 0.16%; +1.1 boost min/day | +2%: Boosts from anything eaten or drunk in Olivewhistle Shore's mountain and island zones last 2% longer | 1.40%; +9.4 boost min/day | 0.94 | ok |
| SE:Turtlenook:Repairs | Roped-Off Nests | F09 | +2%: Rest acts at Turtlenook heal 2% more at night | 0.04%; +0.033 health/day | +2%: Rest acts and trail rests in Olivewhistle Shore's mountain and island zones heal 2% more | 1.40%; +1.3 health/day | 0.66 | ok |
| SE:Turtlenook:Larder | Beachcomber's Pot | A3 | 1 a day: Once a day, the first time you gather at Turtlenook you also find a spiral shell (`spiral-shell`) | once in 6 game days; 1.3 VP/day | 1 a day: First visit to Turtlenook each day: one spiral shell (`spiral-shell`) from the tideline | once in 4 game days; 2.2 VP/day | 2.24 | ok |
| SE:Cragholt:Repairs | Relaid Basalt Steps | F18 | -1%: Fast travel that starts at Cragholt at dusk or night costs 1% less | 0.02%; 0.009 Petals/day saved | -2%: Fast travel that starts in Olivewhistle Shore's mountain zones costs 2% less | 1.00%; 0.45 Petals/day saved | 0.45 | ok |
| SE:Cragholt:Larder | Ash-Baked Eggs | A3 | 1 a day: Once a day, the first dish you eat at Cragholt also heals 1 health | once in 7 game days; 0.070 VP/day | 1 a day: Once a day, the first dish you eat anywhere in Olivewhistle Shore also heals 2 health (an egg from Cragholt's ashes) | 1.0 a game day; 1.0 VP/day | 1.00 | ok |
| SE:Echonook:Larder | Lookout's Fava Pouch | F23 | +1%: Fast travel that starts at Echonook at night has a 1% better chance to turn up a seed | 0.01%; +0.000 seeds/day (once in 33333 game days) | +2%: Fast travel that starts in Olivewhistle Shore's mountain zones: 2% more chance to turn up a seed | 1.00%; +0.003 seeds/day (once in 333 game days) | 0.02 | ok |
| SE:Echonook:Cheer | Says It Back Twice | A2 | 1 a day: Once a day, a lost contest at Echonook is tried again | once in 17 game days; 4.4 VP/day | 1 a day: Once a day, a lost contest at Echonook or anywhere else in Olivewhistle Shore is tried again | once in 1 game days; 58 VP/day | 57.69 | ok |
| SE:Olive Press Piazza:Repairs | Press Stones Rolled Home | F02 | -2%: Bread and oil at the Olive Press Piazza's stall cost 2% less | 0.02%; 0.072 Petals/day saved | -3%: Bread and oil at the Olive Press Piazza's stall cost 3% less | 0.04%; 0.11 Petals/day saved | 0.11 | LOW |
| SE:Lemon Grove Monastery:Repairs | Cloister Roof, No Crates | F17 | -2%: Pests are 2% less likely on the Lemon Grove Monastery's local crops while it rains | 0.30%; 0.003 pests/day fewer (once in 333 game days) | -2%: Pests are 2% less likely on fava bean, oregano and artichoke | 1.40%; 0.014 pests/day fewer (once in 71 game days) | 0.07 | ok |
| SE:Lemon Grove Monastery:Larder | Lemon-Verbena Tisane | F08 | +2%: Boosts from dishes and teas with lemon verbena last 2% longer | 0.05%; +0.32 boost min/day | +2%: Dishes with lemon verbena, fava bean or oregano give boosts that last 2% longer | 1.65%; +11 boost min/day | 1.11 | ok |
| EE:Birchbramble Steppe Market:Repairs | Sunflower-Husk Sweep | F01 | +2%: The stalls of Birchbramble Steppe Market pay 2% more for pickles and preserves | 0.02%; +0.060 Petals/day | +2%: Stalls in Birchbramble Steppe's grassland and wetland zones pay 2% more for what you sell | 1.00%; +2.5 Petals/day | 2.50 | ok |
| EE:Thistleburrow:Larder | Beet Soup, Sour Cream | F07 | +2%: Soups and stews eaten at Thistleburrow give 2% more energy | 0.05%; +0.013 energy/day | +2%: Dishes eaten in Birchbramble Steppe's grassland and forest zones give 2% more energy | 1.20%; +0.32 energy/day | 0.97 | ok |
| EE:Haynook:Repairs | Patched Sails | F05 | -2%: Walks that start at Haynook take 2% less time on windy days | 0.01%; 0.020 min/day saved | -2%: Walks in Birchbramble Steppe's grassland and forest zones take 2% less time | 1.20%; 2.2 min/day saved | 1.80 | ok |
| EE:Haynook:Larder | Buckwheat Bin | F10 | +1%: Grain harvests among Haynook's local crops: 1% chance of one extra | 0.23%; +0.012 crops/day (once in 86 game days) | +2%: Buckwheat, bell pepper and plum harvests: 2% chance of one extra | 1.40%; +0.070 crops/day (once in 14 game days) | 0.56 | ok |
| EE:Tussockgate:Larder | Watcher's Onion String | F11 | +1%: Gathering on walks that start at Tussockgate has a 1% chance of one extra | 0.06%; +0.004 finds/day (once in 223 game days) | +2%: Gathering in Birchbramble Steppe's forest and mountain zones: 2% chance of one extra | 1.00%; +0.080 finds/day (once in 12 game days) | 0.96 | ok |
| EE:Hazelthorpe:Repairs | Wasp Jars on the Boughs | F17 | -2%: Pests are 2% less likely on the fruit crops among Hazelthorpe's local crops | 0.91%; 0.009 pests/day fewer (once in 110 game days) | -2%: Pests are 2% less likely on plum, cherry, pear, elderberry, quince, sea buckthorn and buckwheat | 1.38%; 0.014 pests/day fewer (once in 73 game days) | 0.07 | ok |
| EE:Hazelthorpe:Cheer | Cherry-Stone Champion | F16 | +2%: Contests at Hazelthorpe are 2% kinder in summer | 0.01%; +0.000 wins/day (once in 2083 game days) | +2%: Stop checks in Birchbramble Steppe's grassland and forest zones are 2% kinder | 1.20%; +0.072 wins/day (once in 14 game days) | 8.21 | ok |
| EE:Mossknoll:Repairs | Birch-Bark Shingles | F18 | -1%: Fast travel that starts at Mossknoll in autumn costs 1% less | 0.02%; 0.009 Petals/day saved | -2%: Fast travel that starts in Birchbramble Steppe's grassland and forest zones costs 2% less | 1.20%; 0.54 Petals/day saved | 0.54 | ok |
| EE:Mossknoll:Larder | Bowl Under the Bridge | A2 | 1 a day: Once a day, the first gift of a common local crop to one of Mossknoll's folk is not used up | once in 7 game days; 1.1 VP/day | 1 a day: Once a day, the first gift of a common local crop to anyone in Birchbramble Steppe is not used up (Mossknoll's bowl) | once in 1 game days; 7.2 VP/day | 7.20 | ok |
| EE:Fernford:Repairs | Ford Stones Set Straight | F05 | -2%: Walks that end at Fernford take 2% less time in rain | 0.02%; 0.030 min/day saved | -3%: Walks that end at Fernford take 3% less time in rain | 0.03%; 0.045 min/day saved | 0.04 | LOW |
| EE:Fernford:Larder | Sorrel by the Step | F12 | +2%: Watering lasts 2% longer on the leafy crops among Fernford's local crops | 0.59%; 0.059 waterings/day saved | +2%: Watering lasts 2% longer on bell pepper, sorrel and buckwheat | 1.06%; 0.11 waterings/day saved | 0.32 | ok |
| EE:Fernford:Cheer | Elderflower Cordial | F08 | +2%: Boosts from teas and cordials bought at Fernford's stall last 2% longer | 0.05%; +0.32 boost min/day | +2%: Boosts from anything eaten or drunk in Birchbramble Steppe's forest and mountain zones last 2% longer | 1.00%; +6.7 boost min/day | 0.67 | ok |
| EE:Miregate:Repairs | Reed-Rope Hawser | F15 | +2%: Mend and haul acts at Miregate pay 2% more coins | 0.05%; +0.27 Petals/day | +2%: Acts at stops in Birchbramble Steppe's forest and wetland zones pay 2% more coins | 1.00%; +5.6 Petals/day | 5.60 | ok |
| EE:Reedby:Larder | Smoke-Rack of Marsh Fish | F01 | +2%: Reedby's stall pays 2% more for perch and minnows (`perch`, `minnow`) | 0.02%; +0.040 Petals/day | +3%: Reedby's stall pays 3% more for perch and minnows (`perch`, `minnow`) | 0.02%; +0.060 Petals/day | 0.06 | LOW |
| EE:Reedby:Cheer | Frogs Have the Last Word | F14 | +2%: Chats with Reedby's folk in fog have a 2% chance of +1 friendship | 0.01%; +0.000 friendship/day (once in 2232 game days) | +2%: Chats and gifts with folk in Birchbramble Steppe's forest and wetland zones: 2% chance of +1 friendship | 1.00%; +0.080 friendship/day (once in 12 game days) | 0.32 | ok |
| EE:Echohollow:Repairs | Re-Caulked Wooden Tubs | F09 | +2%: Rest acts at Echohollow heal 2% more in snow or frost | 0.04%; +0.035 health/day | +2%: Rest acts and trail rests in Birchbramble Steppe's forest and mountain zones heal 2% more | 1.00%; +0.95 health/day | 0.48 | ok |
| EE:Flintknoll:Repairs | Flint and Dry Tinder | F06 | -2%: Pots cooked at Flintknoll's fire in wind, snow or frost cook 2% faster | 0.02%; 0.010 min/day saved | -2%: Pots you cook while in Birchbramble Steppe's forest and mountain zones cook 2% faster | 1.00%; 0.45 min/day saved | 0.38 | ok |
| EE:Flintknoll:Cheer | Ridge-Top Stories | F03 | +2%: 2% more XP from lore acts at Flintknoll | 0.03%; +2.6 XP/day | +2%: Acts at stops in Birchbramble Steppe's forest and mountain zones give 2% more XP | 1.00%; +81 XP/day | 2.40 | ok |
| EE:Painted Egg House:Repairs | One Very Small Brush | F16 | +2%: Craft and paint checks at the Painted Egg House are 2% kinder | 0.06%; +0.003 wins/day (once in 298 game days) | +3%: Craft and paint checks at the Painted Egg House are 3% kinder | 0.08%; +0.005 wins/day (once in 198 game days) | 0.57 | LOW |
| EE:Painted Egg House:Larder | Pickled-Egg Shelf | F07 | +2%: Egg dishes eaten at the Painted Egg House give 2% more energy | 0.05%; +0.013 energy/day | +3%: Egg dishes eaten at the Painted Egg House give 3% more energy | 0.07%; +0.019 energy/day | 0.06 | LOW |
| MENA:Dunewhisper Market:Repairs | Whitewashed Arcade | F01 | +2%: The stalls of the Dunewhisper Market pay 2% more for spices and dried fruit | 0.04%; +0.20 Petals/day | +2%: Stalls in the Dunewhisper's coast and desert zones pay 2% more for what you sell | 1.09%; +5.5 Petals/day | 5.45 | ok |
| MENA:Dunewhisper Market:Larder | Last Basket of the Day | F02 | -2%: Food in the Dunewhisper Market costs 2% less at dusk, when the stalls pack up | 0.01%; 0.048 Petals/day saved | -2%: Stalls in the Dunewhisper's coast and desert zones charge 2% less | 1.09%; 6.5 Petals/day saved | 6.55 | ok |
| MENA:Gullwell:Cheer | Rooftop Bed Under the Stars | F22 | +1: Rest acts at Gullwell give 1 more energy on windy days | 0.35%; +0.028 energy/day (once in 36 game days) | +1: Rest acts at Gullwell give 1 more energy on windy, hot or clear days | 1.47%; +0.12 energy/day (once in 9 game days) | 0.35 | ok |
| MENA:Gullstead:Repairs | Net Floats Re-Corked | F05 | -2%: Walks that start at Gullstead at dawn take 2% less time | 0.01%; 0.031 min/day saved | -2%: Walks in the Dunewhisper's coast and desert zones take 2% less time | 1.09%; 2.4 min/day saved | 3.62 | ok |
| MENA:Gullstead:Larder | Octopus on the Line | F11 | +1%: Gathering with a rod at Gullstead has a 1% chance of one extra | 0.02%; +0.002 finds/day (once in 595 game days) | +2%: Gathering in the Dunewhisper's coast and desert zones: 2% chance of one extra | 1.09%; +0.11 finds/day (once in 9 game days) | 1.31 | ok |
| MENA:Brineburrow:Repairs | Ballast of Salt Blocks | F18 | -1%: Fast travel from Brineburrow to the Greatcanopy (its town) costs 1% less at dawn, when the salt boats sail | 0.00%; 0.002 Petals/day saved | -2%: Fast travel that starts in the Dunewhisper's coast and desert zones costs 2% less | 1.09%; 0.82 Petals/day saved | 0.82 | ok |
| MENA:Brineburrow:Larder | Preserved-Lemon Jar | F02 | -2%: Sea salt and jars at Brineburrow's stall cost 2% less | 0.02%; 0.096 Petals/day saved | -3%: Sea salt and jars at Brineburrow's stall cost 3% less | 0.02%; 0.14 Petals/day saved | 0.14 | LOW |
| MENA:Meadowbrook:Cheer | Fritters While You Wait | F03 | +2%: 2% more XP from craft and cook acts at Meadowbrook | 0.06%; +24 XP/day | +2%: Acts at stops in the Dunewhisper's coast and desert zones give 2% more XP | 1.09%; +465 XP/day | 4.75 | ok |
| MENA:Windford:Repairs | Palm-Climber's Belt | F10 | +1%: Tree harvests among Windford's local crops: 1% chance of one extra | 0.12%; +0.007 crops/day (once in 133 game days) | +2%: Date palm, pomegranate, chickpea and eggplant harvests: 2% chance of one extra | 1.18%; +0.071 crops/day (once in 14 game days) | 0.57 | ok |
| MENA:Windford:Larder | Pomegranate Press | F08 | +2%: Boosts from juices and sherbets bought at Windford last 2% longer | 0.05%; +0.34 boost min/day | +2%: Boosts from anything eaten or drunk in the Dunewhisper's coast and grassland zones last 2% longer | 1.09%; +7.6 boost min/day | 0.76 | ok |
| MENA:Windford:Cheer | Windchimes Re-Hung | F14 | +2%: Gifts of fruit to Windford's folk have a 2% chance of +1 friendship | 0.04%; +0.003 friendship/day (once in 312 game days) | +2%: Chats and gifts with folk in the Dunewhisper's coast and grassland zones: 2% chance of +1 friendship | 1.09%; +0.087 friendship/day (once in 11 game days) | 0.35 | ok |
| MENA:Prairieden:Repairs | Sage-Drying Roof | F17 | -2%: Pests are 2% less likely on the herbs and spices among Prairieden's local crops | 0.50%; 0.005 pests/day fewer (once in 200 game days) | -2%: Pests are 2% less likely on cumin, saffron crocus and chickpea | 0.97%; 0.010 pests/day fewer (once in 103 game days) | 0.05 | ok |
| MENA:Craghollow:Repairs | Cedar Beams, Oiled | F16 | +2%: Sense and lore checks at Craghollow are 2% kinder | 0.08%; +0.005 wins/day (once in 208 game days) | +2%: Stop checks in the Dunewhisper's coast, desert and mountain zones are 2% kinder | 1.45%; +0.087 wins/day (once in 11 game days) | 16.93 | ok |
| MENA:Craghollow:Larder | Almond in the Niche | F13 | +1%: The nut and tree crops among Craghollow's local crops have 1% more chance of a seed back | 0.16%; +0.009 seeds/day (once in 105 game days) | +2%: Date palm, pomegranate, pistachio, almond, chickpea and eggplant harvests: 2% more chance of a seed back | 1.25%; +0.075 seeds/day (once in 13 game days) | 0.45 | ok |
| MENA:Cragmead:Repairs | Cedar-Shaving Broom | A2 | 1 a day: Once a day, a craft act at Cragmead that fails gives its ingredients back | once in 17 game days; 0.47 VP/day | 1 a day: Once a day, a craft act at Cragmead or anywhere else in the Dunewhisper that fails gives its ingredients back | once in 3 game days; 2.8 VP/day | 2.80 | ok |
| MENA:Cragmead:Larder | Brass Pot on the Bench | F07 | +2%: Dishes eaten at Cragmead by day give 2% more energy | 0.10%; +0.030 energy/day | +2%: Dishes eaten in the Dunewhisper's coast, desert and mountain zones give 2% more energy | 1.45%; +0.44 energy/day | 1.31 | ok |
| MENA:Cragmead:Cheer | Inlaid Game Board | F15 | +2%: Pick and contest acts at Cragmead pay 2% more coins | 0.06%; +0.53 Petals/day | +2%: Acts at stops in the Dunewhisper's coast, desert and mountain zones pay 2% more coins | 1.45%; +14 Petals/day | 13.82 | ok |
| MENA:Ambercrest:Repairs | Sand-Swept Stair | F05 | -2%: Walks that start at Ambercrest at dusk or night take 2% less time | 0.03%; 0.062 min/day saved | -3%: Walks that start at Ambercrest at dusk or night take 3% less time | 0.04%; 0.092 min/day saved | 0.14 | LOW |
| MENA:Amberholt:Repairs | Tiled Pool, Regrouted | F09 | +2%: Rest acts at Amberholt heal 2% more in heat | 0.03%; +0.043 health/day | +2%: Rest acts and trail rests in the Dunewhisper's coast and desert zones heal 2% more | 1.09%; +1.7 health/day | 0.85 | ok |
| MENA:Amberholt:Larder | Mint in the Steam | F08 | +2%: Boosts from teas drunk at Amberholt last 2% longer | 0.05%; +0.34 boost min/day | +3%: Boosts from teas drunk at Amberholt last 3% longer | 0.07%; +0.50 boost min/day | 0.05 | LOW |
| MENA:Sandbottom:Repairs | Tent Ropes Against the Wind | A1 | 1 a day: Once a day, the first walk that ends at Sandbottom in heat costs 1 less energy | once in 36 game days; 0.084 VP/day | 1 a day: Once a day, the first walk on a desert road of the Dunewhisper costs 1 less energy (Sandbottom's ropes hold) | once in 1 game days; 2.4 VP/day | 2.39 | ok |
| MENA:Sandbottom:Larder | Supper Buried in Hot Sand | F06 | -2%: Pots cooked at Sandbottom's fire at night cook 2% faster | 0.01%; 0.007 min/day saved | -2%: Pots you cook while in the Dunewhisper's coast and desert zones cook 2% faster | 1.09%; 0.65 min/day saved | 0.99 | ok |
| MENA:Spice Souk:Repairs | Roof Cloth, Stretched Tight | F16 | +2%: Haggle checks at the Spice Souk are 2% kinder | 0.02%; +0.001 wins/day (once in 694 game days) | +3%: Haggle checks at the Spice Souk are 3% kinder | 0.04%; +0.002 wins/day (once in 463 game days) | 0.42 | LOW |
| WCA:Greatcanopy Market:Repairs | Laterite Kerb Stones | F01 | +2%: The stalls of the Greatcanopy Market pay 2% more for roots and tubers | 0.03%; +0.16 Petals/day | +2%: Stalls in the Greatcanopy's grassland, wetland and rainforest zones pay 2% more for what you sell | 1.64%; +8.2 Petals/day | 8.18 | ok |
| WCA:Cloverbottom:Larder | Groundnut Stew, Second Ladle | F08 | +2%: Boosts from meals bought at Cloverbottom in rain last 2% longer | 0.01%; +0.050 boost min/day | +2%: Boosts from anything eaten or drunk in the Greatcanopy's grassland and rainforest zones last 2% longer | 1.09%; +7.6 boost min/day | 0.76 | ok |
| WCA:Thistleholt:Repairs | Mortar and Tall Pestle | F15 | +2%: Power acts at Thistleholt pay 2% more coins | 0.02%; +0.23 Petals/day | +2%: Acts at stops in the Greatcanopy's grassland and rainforest zones pay 2% more coins | 1.09%; +10 Petals/day | 10.36 | ok |
| WCA:Thistleholt:Larder | Fonio Sieve | F04 | +2%: 2% more garden XP from the grains among Thistleholt's local crops | 0.47%; +0.51 garden XP/day | +2%: Millet, fonio, yam and cowpea give 2% more garden XP | 1.17%; +1.3 garden XP/day | 1.27 | ok |
| WCA:Hayglen:Larder | Shea Butter Pot | F10 | +1%: Nut harvests among Hayglen's local crops: 1% chance of one extra | 0.03%; +0.002 crops/day (once in 500 game days) | +2%: Kola nut, shea, yam, cowpea and millet harvests: 2% chance of one extra | 1.12%; +0.067 crops/day (once in 15 game days) | 0.54 | ok |
| WCA:Hayglen:Cheer | Kola Nut, Split and Shared | F14 | +2%: Chats with Hayglen's folk at dawn have a 2% chance of +1 friendship | 0.01%; +0.001 friendship/day (once in 1250 game days) | +2%: Chats and gifts with folk in the Greatcanopy's grassland and wetland zones: 2% chance of +1 friendship | 1.09%; +0.087 friendship/day (once in 11 game days) | 0.35 | ok |
| WCA:Fenmead:Repairs | Dugout, Freshly Pitched | F05 | -2%: Walks that end at Fenmead by day take 2% less time | 0.07%; 0.15 min/day saved | -2%: Walks in the Greatcanopy's grassland and wetland zones take 2% less time | 1.09%; 2.4 min/day saved | 3.62 | ok |
| WCA:Fenmead:Larder | Smoked Catfish Basket | F01 | +2%: Fenmead's stall pays 2% more for smoked and dried goods | 0.02%; +0.12 Petals/day | +3%: Fenmead's stall pays 3% more for smoked and dried goods | 0.04%; +0.18 Petals/day | 0.18 | LOW |
| WCA:Fenwell:Repairs | Stilt Legs, Re-Footed | F19 | +2%: Walks that start at Fenwell in rain have a 2% better chance to spot hidden places | 0.02%; +0.000 finds/day (once in 2976 game days) | +2%: Walks in the Greatcanopy's grassland and wetland zones: 2% better chance to spot hidden things | 1.09%; +0.022 finds/day (once in 46 game days) | 0.65 | ok |
| WCA:Fenwell:Larder | Crayfish Pots | F13 | +1%: The pod crops among Fenwell's local crops have 1% more chance of a seed back | 0.24%; +0.014 seeds/day (once in 70 game days) | +2%: Cowpea, bambara groundnut, yam and millet harvests: 2% more chance of a seed back | 1.17%; +0.070 seeds/day (once in 14 game days) | 0.42 | ok |
| WCA:Heronwick:Larder | Hibiscus Steep | F12 | +2%: Watering lasts 2% longer on Heronwick's local crops on windy days | 0.20%; 0.024 waterings/day saved | +2%: Watering lasts 2% longer on yam, cowpea and millet | 1.05%; 0.13 waterings/day saved | 0.38 | ok |
| WCA:Vineden:Repairs | Roots Off the Path | F09 | +2%: Resting on walks that start at Vineden heals 2% more in rain | 0.02%; +0.026 health/day | +2%: Rest acts and trail rests in the Greatcanopy's wetland and rainforest zones heal 2% more | 1.09%; +1.7 health/day | 0.85 | ok |
| WCA:Vineden:Larder | Leaf-Plate Offering | F11 | +1%: Gathering at Vineden at dawn has a 1% chance of one extra | 0.01%; +0.001 finds/day (once in 1429 game days) | +2%: Gathering in the Greatcanopy's wetland and rainforest zones: 2% chance of one extra | 1.09%; +0.11 finds/day (once in 9 game days) | 1.31 | ok |
| WCA:Vineden:Cheer | Polite as a Gorilla | F16 | +2%: Charm checks at Vineden are 2% kinder | 0.05%; +0.003 wins/day (once in 316 game days) | +2%: Stop checks in the Greatcanopy's wetland and rainforest zones are 2% kinder | 1.09%; +0.065 wins/day (once in 15 game days) | 12.70 | ok |
| WCA:Lianawick:Repairs | Liana Rope, Triple-Plaited | F03 | +2%: 2% more XP from craft and mend acts at Lianawick | 0.06%; +24 XP/day | +2%: Acts at stops in the Greatcanopy's grassland and rainforest zones give 2% more XP | 1.09%; +465 XP/day | 4.75 | ok |
| WCA:Mistcrest:Repairs | Mossy Pool Lip, Scrubbed | F22 | +1: Rest acts at Mistcrest give 1 more energy at dawn, while the mist is in | 0.44%; +0.035 energy/day (once in 29 game days) | +1: Rest acts at Mistcrest give 1 more energy in autumn and winter, while the mist is in | 1.75%; +0.14 energy/day (once in 7 game days) | 0.42 | ok |
| WCA:Mistcrest:Larder | Pepper Soup in a Leaf Cup | F07 | +2%: Dishes eaten at Mistcrest in rain give 2% more energy | 0.02%; +0.007 energy/day | +2%: Dishes eaten in the Greatcanopy's grassland and rainforest zones give 2% more energy | 1.09%; +0.33 energy/day | 0.98 | ok |
| WCA:Driftglen:Repairs | Palm-Thatch Windbreak | F06 | -2%: Pots cooked at Driftglen's fire with fish in them cook 2% faster | 0.03%; 0.018 min/day saved | -2%: Pots you cook while in the Greatcanopy's grassland, rainforest and coast zones cook 2% faster | 1.45%; 0.87 min/day saved | 1.32 | ok |
| WCA:Driftglen:Larder | Grilled-Fish Night | A4 | 2 coins: The first fish you sell each day at Driftglen's stall pays 2 coins more | once in 14 game days; 0.14 VP/day | 2 coins: The first thing you sell each day at Driftglen's stall pays 2 coins more | once in 4 game days; 0.50 VP/day | 0.50 | ok |
| WCA:Pebblenook:Repairs | Palm-Oil Beacon | F18 | -1%: Fast travel that starts at Pebblenook on windy days costs 1% less | 0.01%; 0.006 Petals/day saved | -2%: Fast travel that starts in the Greatcanopy's grassland, rainforest and coast zones costs 2% less | 1.45%; 1.1 Petals/day saved | 1.09 | ok |
| WCA:Drum Circle Market:Repairs | Drum Skins Pulled Tight | F15 | +2%: Acts at the Drum Circle Market pay 2% more coins on festival days | 0.02%; +0.15 Petals/day | +3%: Acts at the Drum Circle Market pay 3% more coins on festival days | 0.02%; +0.23 Petals/day | 0.23 | LOW |
| WCA:Drum Circle Market:Larder | Stew for Whoever Comes | F22 | +1: Rest acts at the Drum Circle Market give 1 more energy at dusk, when the stew is ladled | 0.44%; +0.035 energy/day (once in 29 game days) | +1: Rest acts at the Drum Circle Market give 1 more energy by day and at dusk, while the stew is on | 2.63%; +0.21 energy/day (once in 5 game days) | 0.63 | ok |
| ESA:Thornacre Savanna Market:Repairs | Red-Ochre Stall Posts | F01 | +2%: The Thornacre market stall pays 2% more for Savanna crops you sell there | 0.08%; +0.40 Petals/day | +2%: Stalls in Thornacre Savanna's grassland and desert zones pay 2% more for what you sell | 1.00%; +5.0 Petals/day | 5.00 | ok |
| ESA:Meadowden:Repairs | Mended Rooibos Racks | F17 | -2%: Pests are 2% less likely on rooibos and collard | 0.47%; 0.005 pests/day fewer (once in 211 game days) | -2%: Pests are 2% less likely on collard greens, rooibos, teff and banana | 1.17%; 0.012 pests/day fewer (once in 85 game days) | 0.06 | ok |
| ESA:Meadowden:Larder | Red Bush Brew | F08 | +2%: Tea boosts drunk anywhere in the Savanna last 2% longer | 0.60%; +4.2 boost min/day | +2%: Boosts from anything eaten or drunk in Thornacre Savanna's grassland and mountain zones last 2% longer | 1.20%; +8.4 boost min/day | 0.84 | ok |
| ESA:Clovergate:Larder | Sweepings of the Threshing Floor | F10 | +1%: Teff and sorghum harvests: 1% chance of one extra | 0.35%; +0.021 crops/day (once in 48 game days) | +2%: Teff, sorghum and collard greens harvests: 2% chance of one extra | 1.05%; +0.063 crops/day (once in 16 game days) | 0.50 | ok |
| ESA:Meadowbottom:Repairs | Banana-Leaf Thatch | A1 | 1 a day: The first walk each day that ends at Meadowbottom in rain costs 1 less energy | once in 24 game days; 0.13 VP/day | 1 a day: The first walk each day on a grassland road of the Savanna costs 1 less energy (shade from Meadowbottom) | once in 1 game days; 2.5 VP/day | 2.50 | ok |
| ESA:Meadowbottom:Larder | A Whole Hand of Bananas | F04 | +2%: Banana and tamarind harvests give 2% more garden XP | 0.47%; +0.51 garden XP/day | +2%: Banana, tamarind, teff and collard greens give 2% more garden XP | 1.17%; +1.3 garden XP/day | 1.27 | ok |
| ESA:Summitglen:Larder | Lookout's Tamarind Twist | F05 | -1%: Walking in the mountains of the Savanna takes 1% less time | 0.30%; 0.66 min/day saved | -2%: Walks in Thornacre Savanna's grassland and desert zones take 2% less time | 1.00%; 2.2 min/day saved | 3.32 | ok |
| ESA:Pinecombe:Repairs | Relined Rift Pool | F22 | +1: Rest acts at Pinecombe give 1 more energy at dusk and at night | 0.88%; +0.070 energy/day (once in 14 game days) | +1: Rest acts at Pinecombe give 1 more energy after dawn | 3.06%; +0.25 energy/day (once in 4 game days) | 0.74 | ok |
| ESA:Pinecombe:Larder | Steam-Bed Ensete | F13 | +1%: Ensete harvests: 1% more chance of a seed back | 0.06%; +0.004 seeds/day (once in 267 game days) | +2%: Enset, teff, collard greens and banana harvests: 2% more chance of a seed back | 1.17%; +0.070 seeds/day (once in 14 game days) | 0.42 | ok |
| ESA:Pinecombe:Cheer | The Baboon Has Your Towel | A2 | 1 a day: Once a day, a lost contest at Pinecombe can be played again | once in 17 game days; 7.4 VP/day | 1 a day: Once a day, a lost contest at Pinecombe or anywhere else in the Savanna can be played again | once in 1 game days; 98 VP/day | 98.18 | ok |
| ESA:Echoford:Cheer | It Says It Back | F03 | +2%: Lore acts at Echoford give 2% more XP | 0.03%; +14 XP/day | +2%: Acts at stops in Thornacre Savanna's grassland and mountain zones give 2% more XP | 1.20%; +511 XP/day | 5.22 | ok |
| ESA:Bogmead:Repairs | Papyrus Raft, Rebound | F11 | +1%: Gathering on wetland walks in the Savanna: 1% chance of one extra | 0.20%; +0.020 finds/day (once in 50 game days) | +2%: Gathering in Thornacre Savanna's grassland and wetland zones: 2% chance of one extra | 1.00%; +0.10 finds/day (once in 10 game days) | 1.20 | ok |
| ESA:Bogmead:Larder | Tilapia on a Reed | F01 | +2%: Bogmead's stall pays 2% more for golden carp and trout (`golden-carp`, `trout`) | 0.02%; +0.080 Petals/day | +3%: Bogmead's stall pays 3% more for golden carp and trout (`golden-carp`, `trout`) | 0.02%; +0.12 Petals/day | 0.12 | LOW |
| ESA:Newtcombe:Repairs | Net Mended by the Ferryman | A2 | 1 a day: Once a day, the first wear on your bug net on a walk from Newtcombe is skipped | once in 7 game days; 0.28 VP/day | 1 a day: Once a day, the first wear on your bug net anywhere in the Savanna is skipped | once in 2 game days; 1.2 VP/day | 1.20 | ok |
| ESA:Newtcombe:Larder | Collards on the Punt | F12 | +2%: Watering lasts 2% longer on collard and watermelon | 0.47%; 0.057 waterings/day saved | +2%: Watering lasts 2% longer on collard greens, watermelon, teff and banana | 1.17%; 0.14 waterings/day saved | 0.42 | ok |
| ESA:Emberhollow:Repairs | Flint in the Tinderbox | F15 | +2%: Mend acts at Emberhollow pay 2% more coins on hot days | 0.00%; +0.030 Petals/day | +2%: Acts at stops in Thornacre Savanna's grassland and desert zones pay 2% more coins | 1.00%; +9.5 Petals/day | 9.50 | ok |
| ESA:Amberburrow:Repairs | Thorn-Fence Boma | F09 | +2%: Resting on desert trails in the Savanna heals 2% more | 0.40%; +0.62 health/day | +2%: Rest acts and trail rests in Thornacre Savanna's grassland and desert zones heal 2% more | 1.00%; +1.6 health/day | 0.78 | ok |
| ESA:Baobab Inn:Repairs | Lantern in the Hollow Trunk | F18 | -1%: Fast travel that starts at the Baobab Inn by day costs 1% less | 0.05%; 0.037 Petals/day saved | -2%: Fast travel that starts in Thornacre Savanna's grassland and mountain zones costs 2% less | 1.20%; 0.90 Petals/day saved | 0.90 | ok |
| CSA:Spicepeak Market:Repairs | Restrung Awnings | F01 | +2%: The Spicepeak market stall pays 2% more for spices and herbs | 0.03%; +0.16 Petals/day | +2%: Stalls in Spicepeak's grassland and mountain zones pay 2% more for what you sell | 1.09%; +5.5 Petals/day | 5.45 | ok |
| CSA:Newtdell:Repairs | Caulked Delta Boat | A1 | 1 a day: The first walk each day between Newtdell and Rushdell costs 1 less energy, either way | once in 11 game days; 0.28 VP/day | 1 a day: The first walk each day on a wetland road of Spicepeak costs 1 less energy (poled from Newtdell) | once in 1 game days; 2.4 VP/day | 2.39 | ok |
| CSA:Newtdell:Larder | Boatman's Mung Dal | F07 | +2%: Dishes made with mung bean give 2% more energy | 0.76%; +0.23 energy/day | +2%: Dishes with mung bean or fenugreek give 2% more energy | 1.32%; +0.40 energy/day | 1.19 | ok |
| CSA:Rushdell:Repairs | Rebound Reed Jetty | F19 | +2%: Walks from Rushdell to Cliffmead or Prayer-flag Pass: 2% better chance to spot hidden things | 0.07%; +0.001 finds/day (once in 670 game days) | +2%: Walks in Spicepeak's grassland and mountain zones: 2% better chance to spot hidden things | 1.09%; +0.022 finds/day (once in 46 game days) | 0.65 | ok |
| CSA:Rushdell:Larder | Fish in Mustard | F06 | -2%: Fish dishes you cook while in Spicepeak cook 2% faster | 0.60%; 0.36 min/day saved | -2%: Pots you cook while in Spicepeak's grassland and mountain zones cook 2% faster | 1.09%; 0.65 min/day saved | 0.99 | ok |
| CSA:Cloverburrow:Repairs | Chakki Stones, Re-cut | F06 | -2%: Dishes made with wheat cook 2% faster | 0.76%; 0.46 min/day saved | -2%: Dishes with wheat or mung bean in them cook 2% faster | 1.32%; 0.79 min/day saved | 1.20 | ok |
| CSA:Cloverburrow:Larder | Gleaner's Corner | F10 | +1%: Wheat and fenugreek harvests: 1% chance of one extra | 0.35%; +0.021 crops/day (once in 48 game days) | +3%: Wheat, fenugreek, turmeric, mango and tulsi harvests: 3% chance of one extra | 1.37%; +0.082 crops/day (once in 12 game days) | 0.66 | ok |
| CSA:Windstead:Larder | Mango on the Sill | F12 | +2%: Watering lasts 2% longer on mango and melon | 0.14%; 0.017 waterings/day saved | +2%: Watering lasts 2% longer on mango, melon, wheat, mung bean and fenugreek | 1.19%; 0.14 waterings/day saved | 0.43 | ok |
| CSA:Windstead:Cheer | Leaning Into It | F05 | -2%: Walks that end at Windstead take 2% less time on windy days | 0.01%; 0.025 min/day saved | -2%: Walks in Spicepeak's grassland and mountain zones take 2% less time | 1.09%; 2.4 min/day saved | 3.62 | ok |
| CSA:Poppythorpe:Repairs | Picketed Caravan Line | F02 | -2%: Seeds cost 2% less at Poppythorpe's stall and at the Silk Road Caravanserai | 0.06%; 0.38 Petals/day saved | -2%: Stalls in Spicepeak's grassland and mountain zones charge 2% less | 1.09%; 6.5 Petals/day saved | 6.55 | ok |
| CSA:Poppythorpe:Cheer | Dice on a Saddle Blanket | F14 | +2%: Chats with Poppythorpe's folk at night have a 2% chance of +1 friendship | 0.01%; +0.001 friendship/day (once in 1250 game days) | +3%: Chats with Poppythorpe's folk at night have a 3% chance of +1 friendship | 0.01%; +0.001 friendship/day (once in 833 game days) | 0.00 | LOW |
| CSA:Leafmead:Repairs | Re-staked Tulsi Beds | F17 | -2%: Pests are 2% less likely on tulsi and turmeric | 0.14%; 0.001 pests/day fewer (once in 700 game days) | -2%: Pests are 2% less likely on turmeric, tulsi, wheat, mung bean and fenugreek | 1.19%; 0.012 pests/day fewer (once in 84 game days) | 0.06 | ok |
| CSA:Leafmead:Larder | Two Leaves and a Bud | F04 | +2%: Tulsi, turmeric and ginger give 2% more garden XP | 0.49%; +0.53 garden XP/day | +2%: Ginger, turmeric, tulsi, wheat and mung bean give 2% more garden XP | 1.19%; +1.3 garden XP/day | 1.29 | ok |
| CSA:Hollowby:Repairs | Bamboo Picking Poles | F13 | +1%: Mango, jackfruit and mulberry harvests: 1% more chance of a seed back | 0.11%; +0.006 seeds/day (once in 156 game days) | +2%: Mango, jackfruit, mulberry, wheat, mung bean and fenugreek harvests: 2% more chance of a seed back | 1.26%; +0.076 seeds/day (once in 13 game days) | 0.46 | ok |
| CSA:Hollowby:Larder | Purple to the Elbows | A3 | 1 a day: The first mulberry harvest each day gives one extra mulberry | once in 5 game days; 1.6 VP/day | 1 a day: The first mulberry or jackfruit harvest each day gives one extra of that crop | once in 3 game days; 2.9 VP/day | 2.87 | ok |
| CSA:Cliffmead:Larder | Butter-Tea Offering | F07 | +2%: Dishes eaten in the mountains of Spicepeak give 2% more energy | 0.55%; +0.16 energy/day | +2%: Dishes eaten in Spicepeak's grassland and mountain zones give 2% more energy | 1.09%; +0.33 energy/day | 0.98 | ok |
| CSA:Cliffmead:Cheer | A Wish on the Wind | F16 | +2%: Stop checks at Cliffmead are 2% kinder on windy days | 0.02%; +0.001 wins/day (once in 1042 game days) | +2%: Stop checks in Spicepeak's grassland and mountain zones are 2% kinder | 1.09%; +0.065 wins/day (once in 15 game days) | 12.70 | ok |
| CSA:Pinecrest:Larder | Apricot Kernels in the Apron | F10 | +1%: Apricot harvests: 1% chance of one extra | 0.04%; +0.002 crops/day (once in 467 game days) | +3%: Apricot, mung bean, ginger, melon, cinnamon, tea and black pepper harvests: 3% chance of one extra | 1.41%; +0.085 crops/day (once in 12 game days) | 0.68 | ok |
| CSA:Screeden:Repairs | Slate-Lined Pool | F09 | +2%: Resting on mountain trails in Spicepeak heals 2% more | 0.55%; +0.85 health/day | +2%: Rest acts and trail rests in Spicepeak's wetland and mountain zones heal 2% more | 1.09%; +1.7 health/day | 0.85 | ok |
| CSA:Screeden:Larder | Eggs in Turmeric Water | F07 | +2%: Dishes with turmeric give 2% more energy | 0.17%; +0.052 energy/day | +2%: Dishes with turmeric, wheat or ginger give 2% more energy | 1.41%; +0.42 energy/day | 1.27 | ok |
| CSA:Screeden:Cheer | Shared Steam, Shared Umbrella | F14 | +2%: Chats with villagers anywhere in Spicepeak while it rains: 2% chance of +1 friendship | 0.15%; +0.012 friendship/day (once in 83 game days) | +2%: Chats and gifts with folk in Spicepeak's grassland and mountain zones: 2% chance of +1 friendship | 1.09%; +0.087 friendship/day (once in 11 game days) | 0.35 | ok |
| CSA:Floating Flower Market:Repairs | Bailed-Out Flower Boat | F01 | +2%: The Floating Flower Market pays 2% more for flowers you sell | 0.02%; +0.080 Petals/day | +3%: The Floating Flower Market pays 3% more for flowers you sell | 0.02%; +0.12 Petals/day | 0.12 | LOW |
| EA:Blossomreach Market:Larder | Napa by the Cartload | F01 | +2%: Dishes made with napa cabbage or daikon sell for 2% more at any Blossomreach stall | 0.60%; +3.0 Petals/day | +2%: Stalls in Blossomreach's grassland and forest zones pay 2% more for what you sell | 1.20%; +6.0 Petals/day | 6.00 | ok |
| EA:Blossomreach Market:Cheer | Red Envelope | A4 | 2 coins: The first festival act you do each day in Blossomreach pays 2 coins more | once in 10 game days; 0.20 VP/day | 2 coins: The first act you do each day in Blossomreach pays 2 coins more | 1.0 a game day; 2.0 VP/day | 2.00 | ok |
| EA:Clovercove:Repairs | Cleared Terrace Sluice | F12 | +2%: Watering lasts 2% longer on napa cabbage and bok choy | 0.70%; 0.084 waterings/day saved | +2%: Watering lasts 2% longer on napa cabbage, bok choy and daikon | 1.05%; 0.13 waterings/day saved | 0.38 | ok |
| EA:Clovercove:Larder | Polished Adzuki | F06 | -2%: Dishes made with adzuki cook 2% faster | 0.76%; 0.46 min/day saved | -2%: Dishes with adzuki bean or napa cabbage in them cook 2% faster | 1.32%; 0.79 min/day saved | 1.20 | ok |
| EA:Poppywell:Larder | Shoots from the Panda's Share | F10 | +1%: Bamboo-shoot harvests: 1% chance of one extra | 0.03%; +0.002 crops/day (once in 533 game days) | +2%: Bamboo shoot, napa cabbage, adzuki bean, peach, lotus root and lychee harvests: 2% chance of one extra | 0.95%; +0.057 crops/day (once in 18 game days) | 0.46 | ok |
| EA:Bramblebrook:Repairs | Perilla Under Netting | F17 | -2%: Pests are 2% less likely on perilla and star anise | 0.12%; 0.001 pests/day fewer (once in 800 game days) | -2%: Pests are 2% less likely on perilla, star anise, napa cabbage, daikon and adzuki bean | 1.17%; 0.012 pests/day fewer (once in 85 game days) | 0.06 | ok |
| EA:Bramblebrook:Larder | Seed Saved in the Pickling Crock | F13 | +1%: Perilla and daikon harvests: 1% more chance of a seed back | 0.21%; +0.012 seeds/day (once in 81 game days) | +2%: Daikon, perilla, napa cabbage and adzuki bean harvests: 2% more chance of a seed back | 1.11%; +0.067 seeds/day (once in 15 game days) | 0.40 | ok |
| EA:Birchford:Cheer | Fan-Maker's Breeze | F05 | -1%: Walking on hot days in Blossomreach takes 1% less time | 0.10%; 0.22 min/day saved | -2%: Walks in Blossomreach's forest and desert zones take 2% less time | 1.00%; 2.2 min/day saved | 3.32 | ok |
| EA:Brambleburrow:Repairs | Fresh Vermilion | F19 | +2%: Walks that end at Brambleburrow in fog or rain have a 2% better chance to spot hidden things | 0.02%; +0.000 finds/day (once in 2029 game days) | +2%: Walks in Blossomreach's grassland and forest zones: 2% better chance to spot hidden things | 1.20%; +0.024 finds/day (once in 42 game days) | 0.72 | ok |
| EA:Brambleburrow:Larder | Peach Left for the Fox | F04 | +2%: Peach and persimmon harvests give 2% more garden XP | 0.12%; +0.14 garden XP/day | +2%: Peach, persimmon, napa cabbage, daikon and adzuki bean give 2% more garden XP | 1.17%; +1.3 garden XP/day | 1.27 | ok |
| EA:Sprayholt:Repairs | Spliced Mooring Lines | F11 | +1%: Gathering on coast walks in Blossomreach: 1% chance of one extra | 0.20%; +0.020 finds/day (once in 50 game days) | +2%: Gathering in Blossomreach's forest and coast zones: 2% chance of one extra | 1.00%; +0.10 finds/day (once in 10 game days) | 1.20 | ok |
| EA:Sprayholt:Larder | Mussel Rack at Low Tide | A3 | 1 a day: First visit to Sprayholt at dawn or dusk each day: one handful of mussels (`blue-mussels`) | once in 14 game days; 0.56 VP/day | 1 a day: First visit to Sprayholt each day: one handful of mussels (`blue-mussels`) | once in 4 game days; 2.2 VP/day | 2.24 | ok |
| EA:Tidecombe:Repairs | Tarred Flat-Bottom | F05 | -2%: Walks between Tidecombe and Poppywell take 2% less time, both ways | 0.07%; 0.16 min/day saved | -3%: Walks between Tidecombe and Poppywell take 3% less time, both ways | 0.11%; 0.25 min/day saved | 0.37 | LOW |
| EA:Tidecombe:Larder | Sea-Salt Pans | F02 | -2%: Tidecombe's stall charges 2% less for sea salt (`sea-salt`) | 0.02%; 0.096 Petals/day saved | -2%: Stalls in Blossomreach's forest and coast zones charge 2% less | 1.00%; 6.0 Petals/day saved | 6.00 | ok |
| EA:Coppergate:Repairs | Polished Gate Gong | F16 | +2%: Stop checks at Coppergate are 2% kinder at dawn | 0.02%; +0.001 wins/day (once in 833 game days) | +2%: Stop checks in Blossomreach's forest and desert zones are 2% kinder | 1.00%; +0.060 wins/day (once in 17 game days) | 11.64 | ok |
| EA:Dunewick:Repairs | Tamarisk Windbreak | F09 | +2%: Healing of any kind at Dunewick is 2% stronger on hot days | 0.03%; +0.043 health/day | +2%: Rest acts and trail rests in Blossomreach's forest and desert zones heal 2% more | 1.00%; +1.6 health/day | 0.78 | ok |
| EA:Dunewick:Larder | Jujube Tea in the Shade | F10 | +1%: Jujube harvests: 1% chance of one extra | 0.03%; +0.002 crops/day (once in 533 game days) | +2%: Jujube, daikon, bok choy, perilla, persimmon and star anise harvests: 2% chance of one extra | 0.95%; +0.057 crops/day (once in 18 game days) | 0.46 | ok |
| EA:Cherry Blossom Teahouse:Larder | Second Pour | F08 | +2%: Boosts from teas drunk at the Cherry Blossom Teahouse in spring last 2% longer | 0.01%; +0.084 boost min/day | +2%: Boosts from anything eaten or drunk in Blossomreach's grassland and forest zones last 2% longer | 1.20%; +8.4 boost min/day | 0.84 | ok |
| SEA:Monsoon Tangle Market:Repairs | Patched Tarpaulins | F02 | -2%: Shops in the Monsoon Tangle charge 2% less while it rains | 0.30%; 1.8 Petals/day saved | -2%: Stalls in the Monsoon Tangle's coast and rainforest zones charge 2% less | 1.09%; 6.5 Petals/day saved | 6.55 | ok |
| SEA:Monsoon Tangle Market:Larder | Noodles Sold from the Wok | A4 | 2 coins: The first dish you sell each day at the Monsoon Tangle market pays 2 coins more | once in 14 game days; 0.14 VP/day | 2 coins: The first dish you sell each day at any stall in the Monsoon Tangle pays 2 coins more | once in 2 game days; 1.0 VP/day | 1.00 | ok |
| SEA:Marshcrest:Repairs | Buffalo-Turned Stone | F06 | -2%: Dishes made with rice cook 2% faster | 0.76%; 0.46 min/day saved | -2%: Dishes with rice or water spinach in them cook 2% faster | 1.32%; 0.79 min/day saved | 1.20 | ok |
| SEA:Marshcrest:Larder | Second Threshing | F10 | +1%: Rice harvests: 1% chance of one extra | 0.17%; +0.010 crops/day (once in 95 game days) | +2%: Rice, lemongrass, dragon fruit, moringa, durian and mangosteen harvests: 2% chance of one extra | 0.97%; +0.058 crops/day (once in 17 game days) | 0.46 | ok |
| SEA:Rushglen:Repairs | Re-woven Drying Trays | F12 | +2%: Watering lasts 2% longer on lemongrass and kangkong | 0.70%; 0.084 waterings/day saved | +2%: Watering lasts 2% longer on water spinach, lemongrass and rice | 1.05%; 0.13 waterings/day saved | 0.38 | ok |
| SEA:Rushglen:Larder | Bruised Lemongrass | F08 | +2%: Tea boosts last 2% longer on rainy days in the Monsoon Tangle | 0.09%; +0.63 boost min/day | +2%: Boosts from anything eaten or drunk in the Monsoon Tangle's wetland and coast zones last 2% longer | 1.09%; +7.6 boost min/day | 0.76 | ok |
| SEA:Lilyby:Repairs | Dry Bedding in the Wet | F22 | +1: Rest acts at Lilyby give 1 more energy in a storm | 0.18%; +0.014 energy/day (once in 71 game days) | +1: Rest acts at Lilyby give 1 more energy in any weather but clear sun | 2.73%; +0.22 energy/day (once in 5 game days) | 0.66 | ok |
| SEA:Lilyby:Larder | Sticky Rice in a Leaf | A3 | 1 a day: First visit to Lilyby after dusk each day: one parcel of rice (`rice`) | once in 14 game days; 0.56 VP/day | 1 a day: First visit to Lilyby each day: one parcel of rice (`rice`) | once in 4 game days; 2.2 VP/day | 2.24 | ok |
| SEA:Sandpiperglen:Repairs | Longtail Prop, Straightened | F18 | -1%: Fast travel that starts at Sandpiperglen at dawn costs 1% less | 0.01%; 0.008 Petals/day saved | -2%: Fast travel that starts in the Monsoon Tangle's coast and rainforest zones costs 2% less | 1.09%; 0.82 Petals/day saved | 0.82 | ok |
| SEA:Sandpiperglen:Larder | Shrimp-Paste Jar | F11 | +1%: Gathering on coast walks that end at Sandpiperglen: 1% chance of one extra | 0.06%; +0.006 finds/day (once in 179 game days) | +3%: Gathering on coast walks that end at Sandpiperglen: 3% chance of one extra | 0.17%; +0.017 finds/day (once in 60 game days) | 0.20 | LOW |
| SEA:Shellnook:Repairs | Outrigger Lashed Tight | F05 | -2%: Walks between Shellnook and Turtleburrow take 2% less time in wind or storm, both ways | 0.01%; 0.025 min/day saved | -3%: Walks between Shellnook and Turtleburrow take 3% less time in wind or storm, both ways | 0.02%; 0.037 min/day saved | 0.06 | LOW |
| SEA:Shellnook:Larder | Crated Starfruit | F01 | +2%: Shellnook's stall pays 2% more for fruit | 0.04%; +0.20 Petals/day | +2%: Stalls in the Monsoon Tangle's coast, rainforest and island zones pay 2% more for what you sell | 1.45%; +7.3 Petals/day | 7.27 | ok |
| SEA:Sandpiperhollow:Repairs | Storm Lamp, Trimmed | F05 | -1%: Walking in rain in the Monsoon Tangle takes 1% less time | 0.15%; 0.33 min/day saved | -2%: Walks in the Monsoon Tangle's coast and rainforest zones take 2% less time | 1.09%; 2.4 min/day saved | 3.62 | ok |
| SEA:Sandpiperhollow:Larder | Keeper's Bitter-Melon Fry | F07 | +2%: Dishes made with bitter melon give 2% more energy | 0.76%; +0.23 energy/day | +2%: Dishes with bitter melon or rice give 2% more energy | 1.32%; +0.40 energy/day | 1.19 | ok |
| SEA:Spindriftbottom:Repairs | Re-dug Volcano Pool | F09 | +2%: Healing is 2% stronger anywhere on the islands of the Monsoon Tangle | 0.36%; +0.56 health/day | +2%: Rest acts and trail rests in the Monsoon Tangle's coast, rainforest and island zones heal 2% more | 1.45%; +2.3 health/day | 1.13 | ok |
| SEA:Reefden:Repairs | Notched Palm Ladder | F11 | +1%: Gathering on island walks in the Monsoon Tangle: 1% chance of one extra | 0.18%; +0.018 finds/day (once in 55 game days) | +2%: Gathering in the Monsoon Tangle's coast, rainforest and island zones: 2% chance of one extra | 1.45%; +0.15 finds/day (once in 7 game days) | 1.75 | ok |
| SEA:Reefden:Larder | Rambutan by the Armful | F10 | +1%: Rambutan, longan and starfruit harvests: 1% chance of one extra | 0.15%; +0.009 crops/day (once in 111 game days) | +2%: Rambutan, longan, starfruit, water spinach and bitter melon harvests: 2% chance of one extra | 1.00%; +0.060 crops/day (once in 17 game days) | 0.48 | ok |
| SEA:Reefden:Cheer | Fruit for the Neighbours | F14 | +2%: Gifts of fruit to anyone in the Monsoon Tangle: 2% chance of +1 friendship | 0.50%; +0.040 friendship/day (once in 25 game days) | +2%: Chats and gifts with folk in the Monsoon Tangle's coast, rainforest and island zones: 2% chance of +1 friendship | 1.45%; +0.12 friendship/day (once in 9 game days) | 0.47 | ok |
| SEA:Canopyford:Repairs | Re-roped Bridge | F19 | +1%: Rainforest walks in the Monsoon Tangle: 1% better chance to spot hidden things | 0.27%; +0.005 finds/day (once in 183 game days) | +2%: Walks in the Monsoon Tangle's coast and rainforest zones: 2% better chance to spot hidden things | 1.09%; +0.022 finds/day (once in 46 game days) | 0.65 | ok |
| SEA:Canopyford:Larder | Supper on a Banana Leaf | A2 | 1 a day: Once a day, a dish cooked at Canopyford's fire gives one ingredient back | once in 7 game days; 1.1 VP/day | 1 a day: Once a day, a dish cooked at Canopyford's fire or at any other stop fire in the Monsoon Tangle gives one ingredient back | once in 3 game days; 2.4 VP/day | 2.40 | ok |
| SEA:Monsoonburrow:Repairs | Swept Before the Rains | F17 | -2%: Pests are 2% less likely on kangkong and bitter melon | 0.70%; 0.007 pests/day fewer (once in 143 game days) | -2%: Pests are 2% less likely on water spinach, bitter melon, starfruit, moringa, durian and mangosteen | 0.97%; 0.010 pests/day fewer (once in 103 game days) | 0.05 | ok |
| SEA:Monsoonburrow:Larder | First Bowl to the Spirits | F13 | +1%: Rice harvests: 1% more chance of a seed back | 0.17%; +0.010 seeds/day (once in 95 game days) | +2%: Rice, water spinach and lemongrass harvests: 2% more chance of a seed back | 1.05%; +0.063 seeds/day (once in 16 game days) | 0.38 | ok |
| SEA:Monsoonburrow:Cheer | After the Downpour | F03 | +2%: 2% more XP from acts at Monsoonburrow while it rains | 0.02%; +10 XP/day | +2%: Acts at stops in the Monsoon Tangle's coast and rainforest zones give 2% more XP | 1.09%; +465 XP/day | 4.75 | ok |
| SEA:Parrotden:Repairs | Parrot-Proof Netting | F17 | -2%: Pests are 2% less likely on dragon fruit, rambutan and longan | 0.30%; 0.003 pests/day fewer (once in 333 game days) | -2%: Pests are 2% less likely on dragon fruit, rambutan, longan, rice and lemongrass | 1.00%; 0.010 pests/day fewer (once in 100 game days) | 0.05 | ok |
| SEA:Parrotden:Larder | What the Parrots Missed | F04 | +2%: Moringa and dragon fruit give 2% more garden XP | 0.20%; +0.22 garden XP/day | +2%: Dragon fruit, moringa, rice, water spinach and lemongrass give 2% more garden XP | 1.25%; +1.4 garden XP/day | 1.35 | ok |
| SEA:Floating Market:Repairs | Bailed and Balanced | F01 | +2%: The Floating Market's boats pay 2% more for dishes you sell | 0.05%; +0.24 Petals/day | +3%: The Floating Market's boats pay 3% more for dishes you sell | 0.07%; +0.36 Petals/day | 0.36 | LOW |
| SEA:Floating Market:Cheer | Haggled from the Prow | F16 | +2%: Checks in trade and haggle acts at the Floating Market are 2% kinder | 0.03%; +0.002 wins/day (once in 521 game days) | +2%: Stop checks in the Monsoon Tangle's wetland and coast zones are 2% kinder | 1.09%; +0.065 wins/day (once in 15 game days) | 12.70 | ok |
| OC:Palmgate:Repairs | Re-lashed Outrigger | F18 | -1%: Fast travel from Palmgate to the Rainroot Reaches (its town) costs 1% less at night | 0.00%; 0.002 Petals/day saved | -2%: Fast travel that starts in the Coralscatter's island and desert zones costs 2% less | 1.09%; 0.82 Petals/day saved | 0.82 | ok |
| OC:Reefknoll:Repairs | Notches Up the Palm | F10 | +1%: Coconut and pandanus harvests: 1% chance of one extra | 0.47%; +0.028 crops/day (once in 36 game days) | +2%: Coconut, pandanus and kava harvests: 2% chance of one extra | 0.97%; +0.058 crops/day (once in 17 game days) | 0.46 | ok |
| OC:Reefknoll:Larder | Pandanus Keys | F04 | +2%: Pandanus and noni give 2% more garden XP | 0.59%; +0.64 garden XP/day | +2%: Pandanus, noni and taro give 2% more garden XP | 1.06%; +1.1 garden XP/day | 1.14 | ok |
| OC:Reefknoll:Cheer | Coconut Crab Referee | F15 | +2%: Contest acts at Reefknoll pay 2% more coins | 0.03%; +0.30 Petals/day | +2%: Acts at stops in the Coralscatter's coast and desert zones pay 2% more coins | 1.09%; +10 Petals/day | 10.36 | ok |
| OC:Turtleburrow:Larder | Greens Above the Tideline | F13 | +1%: Warrigal greens and taro harvests: 1% more chance of a seed back | 0.30%; +0.018 seeds/day (once in 56 game days) | +2%: Taro, warrigal greens and coconut harvests: 2% more chance of a seed back | 1.06%; +0.063 seeds/day (once in 16 game days) | 0.38 | ok |
| OC:Turtleburrow:Cheer | Quiet as Low Tide | F09 | +2%: Rest acts at Turtleburrow heal 2% more at dawn | 0.04%; +0.054 health/day | +3%: Rest acts at Turtleburrow heal 3% more at dawn | 0.05%; +0.081 health/day | 0.04 | LOW |
| OC:Brineglen:Repairs | Salt-Proof Shutters | F05 | -2%: Walks that start at Brineglen take 2% less time in fog | 0.01%; 0.017 min/day saved | -3%: Walks that start at Brineglen take 3% less time in fog | 0.01%; 0.026 min/day saved | 0.04 | LOW |
| OC:Shellknoll:Repairs | Whitewashed Light | F05 | -1%: Coast walks in the Coralscatter take 1% less time at night | 0.03%; 0.075 min/day saved | -2%: Walks in the Coralscatter's island, coast and desert zones take 2% less time | 1.64%; 3.6 min/day saved | 5.44 | ok |
| OC:Shellknoll:Larder | Billy on the Boil | F07 | +2%: Dishes eaten on the Coralscatter coast at night give 2% more energy | 0.07%; +0.020 energy/day | +2%: Dishes eaten in the Coralscatter's coast and desert zones give 2% more energy | 1.09%; +0.33 energy/day | 0.98 | ok |
| OC:Salthollow:Repairs | Pandanus-Rope Rails | F15 | +2%: Fishing and gathering acts at Salthollow pay 2% more coins | 0.04%; +0.38 Petals/day | +3%: Fishing and gathering acts at Salthollow pay 3% more coins | 0.06%; +0.57 Petals/day | 0.57 | LOW |
| OC:Salthollow:Larder | Salt-Crusted Catch | A3 | 1 a day: Once a day, the first fish you find on a walk from Salthollow comes with one pinch of sea salt (`sea-salt`) | once in 12 game days; 0.67 VP/day | 1 a day: Once a day, the first thing you find on a walk from Salthollow comes with one pinch of sea salt (`sea-salt`) | once in 4 game days; 2.0 VP/day | 2.02 | ok |
| OC:Mossby:Repairs | Fern-Cleared Race | F06 | -2%: Dishes made with sago cook 2% faster | 0.30%; 0.18 min/day saved | -2%: Dishes with sago palm or taro in them cook 2% faster | 1.17%; 0.70 min/day saved | 1.06 | ok |
| OC:Mossby:Larder | Sago Pearls, Sieved | F10 | +1%: Sago and taro harvests: 1% chance of one extra | 0.30%; +0.018 crops/day (once in 56 game days) | +2%: Taro, sago palm, noni, kiwifruit and warrigal greens harvests: 2% chance of one extra | 0.97%; +0.058 crops/day (once in 17 game days) | 0.46 | ok |
| OC:Toadstoolbrook:Repairs | Re-thatched Fern House | F17 | -2%: Pests are 2% less likely on kiwi and warrigal greens | 0.25%; 0.003 pests/day fewer (once in 400 game days) | -2%: Pests are 2% less likely on kiwifruit, warrigal greens, taro and coconut | 1.18%; 0.012 pests/day fewer (once in 85 game days) | 0.06 | ok |
| OC:Toadstoolbrook:Larder | Fuzzy Fruit, Shady Vine | F12 | +2%: Watering lasts 2% longer on kiwi and noni | 0.25%; 0.030 waterings/day saved | +2%: Watering lasts 2% longer on noni, kiwifruit, taro and coconut | 1.18%; 0.14 waterings/day saved | 0.43 | ok |
| OC:Miragewell:Repairs | Capped Bore, No Leaks | F22 | +1: Rest acts at Miragewell give 1 more energy on hot days | 0.35%; +0.028 energy/day (once in 36 game days) | +1: Rest acts at Miragewell give 1 more energy on hot, sunny or cloudy days | 1.75%; +0.14 energy/day (once in 7 game days) | 0.42 | ok |
| OC:Oasiswick:Repairs | Trued Boomerang | A2 | 1 a day: Once a day, when a walk from Oasiswick finds nothing, your gnome looks once more | once in 7 game days; 0.84 VP/day | 1 a day: Once a day, when a walk in the Coralscatter finds nothing, your gnome looks once more (Oasiswick's boomerang comes back) | once in 1 game days; 4.8 VP/day | 4.80 | ok |
| OC:Oasiswick:Larder | Seed Tin with a Tight Lid | F02 | -2%: Seeds cost 2% less at Oasiswick's stall in heat | 0.01%; 0.038 Petals/day saved | -2%: Stalls in the Coralscatter's island and desert zones charge 2% less | 1.09%; 6.5 Petals/day saved | 6.55 | ok |
| OC:Oasiswick:Cheer | Clapsticks | F03 | +2%: Craft acts at Oasiswick give 2% more XP | 0.03%; +14 XP/day | +2%: Acts at stops in the Coralscatter's island and desert zones give 2% more XP | 1.09%; +465 XP/day | 4.75 | ok |
| OC:Ambercove:Repairs | Swag Rolled Tight | F09 | +2%: Resting on desert trails in the Coralscatter at night heals 2% more | 0.07%; +0.11 health/day | +2%: Rest acts and trail rests in the Coralscatter's island and desert zones heal 2% more | 1.09%; +1.7 health/day | 0.85 | ok |
| OC:Kava Circle:Repairs | Re-carved Kava Bowl | F08 | +2%: Boosts from drinks shared at the Kava Circle last 2% longer | 0.05%; +0.34 boost min/day | +2%: Boosts from anything eaten or drunk in the Coralscatter's island and coast zones last 2% longer | 1.09%; +7.6 boost min/day | 0.76 | ok |
| OC:Kava Circle:Cheer | Clap Once, Drink, Clap Thrice | F14 | +2%: Gifts to anyone in the Coralscatter at dusk: 2% chance of +1 friendship | 0.12%; +0.010 friendship/day (once in 100 game days) | +2%: Chats and gifts with folk in the Coralscatter's island and desert zones: 2% chance of +1 friendship | 1.09%; +0.087 friendship/day (once in 11 game days) | 0.35 | ok |

## 9. How the raises were chosen

1. **Wider trigger first.** Crop perks now name enough of their region's crops (staples first) to cover about half of the beds or dishes; no crop has two perks of one family (rule P3). One place perk per family per region became region-wide, in the landscapes that hold half of the region or more, the stop's own landscape first. Daily charges lost a narrow condition (one weather, one day part, one named road) or became region-wide. Rest energy stayed at its stop with a wider condition (+1 is already 25% of a rest act).
2. **Then size, to 2% at most**: harvest extra, gather extra, seed back and the fast-travel families from 1% to 2% where the wider trigger was not enough. Unit perks stayed +1 and day coins stayed at 2 or less (their caps).
3. **Then 3%**, only for narrow place perks still LOW at 2%: section 7.
4. **World perks** (24 of the 29 were LOW): the condition was dropped or widened; five went from 1% to 2% inside their family cap (Miller's Pinch, Squirrel's Arithmetic, Catch of the Day, Watcher's Flask, Brim-Full Bucket).

Weak spots of the model: Petals per game day are not simulated (master section 3, A4); the shares of weather, act kinds and goods are guesses; a gnome is assumed to be touring the perk's region. A looser threshold (0.5%) would pass crop perks on two staples; a stricter one (once in 2 days for daily charges) would fail every first-visit gift.

