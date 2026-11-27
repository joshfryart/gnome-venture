# PROPOSAL: Stop perks, regions B (SE, EE, MENA, WCA)

Status: proposal only, no game code changed. 2026-11-27.
Follows `proposal-stop-perks.md` (rules, families, caps, section 5 as the format) and `PROPOSAL-HOLLOW-MASTER.md` section 7 and section 14, answer 7 (a hand-written set per region). Stops are from `claude/route-list.md`: every town, village and haven. Regions: Olivewhistle Shore (SE), Birchbramble Steppe (EE), The Dunewhisper (MENA), The Greatcanopy (WCA).

**51 stops, 153 perks.** Every stop has its own three perks, one per bar, hand-written. No type template is used.

## 1. World budget share per region (the balance rule)

Share = (cap - what the Maplewold set uses) / 13 regions, rounded down. "NA use" is the world perks among the 54 Maplewold perks of section 5 (18 stops, with Cattailmere and Granitegate), as listed in section 4.1 of that file.

| Family | Cap | NA use | Left | Share per region (left / 13, rounded down) |
|---|---|---|---|---|
| F01 sell | 5% | 2 | 3 | **0** |
| F02 buy | 5% | 1 | 4 | **0** |
| F03 xp | 5% | 3 | 2 | **0** |
| F04 garden xp | 5% | 1 | 4 | **0** |
| F05 walk | 6% | 2 | 4 | **0** |
| F06 cook | 6% | 4 | 2 | **0** |
| F07 meal | 5% | 2 | 3 | **0** |
| F08 buff | 8% | 4 | 4 | **0** |
| F09 heal | 8% | 4 | 4 | **0** |
| F10 harvest | 4% | 2 | 2 | **0** |
| F11 gather | 4% | 1 | 3 | **0** |
| F12 water | 8% | 2 | 6 | **0** |
| F13 seed | 4% | 1 | 3 | **0** |
| F14 friend | 8% | 2 | 6 | **0** |
| F15 stop coins | 8% | 2 | 6 | **0** |
| F16 check | 4% | 1 | 3 | **0** |
| F17 pest | 8% | 2 | 6 | **0** |
| F18 travel | 5% | 1 | 4 | **0** |
| F19 spot | 4% | 1 | 3 | **0** |
| F20 max health | 3 points | 0 | 3 | **0** |
| F21 torch | 3 steps | 0 | 3 | **0** |
| F22 rest energy | 2 energy | 2 | 0 | **0** |
| F23 trail seed | 4% | 1 | 3 | **0** |
| A4 day coins | 10 coins | 1 | 9 | **0** |

**Every share is 0.** The most any family has left is 6 (watering, friendship, stop coins, pests), and 6 / 13 rounds down to 0. So in these four regions:
- **No world (W) perk at all.** Every perk with a number is a place perk (P): it works only at its stop, on walks that start or end there, on fast travel to it, in the one delve or on the one lair road it names, or on that stop's local crops. World-family units used: **0 in every region**.
- A4 (day coins) has 9 of 10 coins left, share 0: the two A4 perks here pay only at their own stop and stay under the 10-coins-a-day ceiling.
- Daily charges (D) share no cap; each has its own trigger, and every one here is tied to its own stop (section 6).
- Flags (F) have no power. No stop here has two flags.
- **Local crops.** `stop_local_crops()` returns the region's crops, the same list for every stop in a region. So each region gets **at most one local-crop perk per family** here (script-checked), and each is narrowed further (a weather, a season or a crop group). Two marks can never add up on the same crop.
- Nothing is above 2%, +1 of a small unit, or one charge a game day (game day = a sleep, `gclock_my_date()`, not midnight).

Scope letters: W world, P place, D daily charge, F flag. Families are those of `proposal-stop-perks.md` section 4.

## 2. Olivewhistle Shore (SE): 13 stops, 39 perks

1 town, 10 villages, 2 havens. Brinewick is the border village at the end of the Mistmoor road and belongs to this region. Gullwell, at the end of the road out, belongs to the Dunewhisper (section 4). Landscapes: coast (Olive Terrace Shore), mountain (Goatbell Hills, Cinderpeak), island (the Scattered Isles). Two mills, on purpose: Cliffbrook grinds grain, the Piazza presses oil.

Stop types to set in Admin > Places:

| Stop | Type | Why |
|---|---|---|
| Olivewhistle Shore Market | market | The town, on the coast |
| Brinewick | inn | Border inn on the Mistmoor road; five roads leave it |
| Driftmead | ferry | Boats leave for Turtlenook and the Labyrinth Isle |
| Sprayglen | jetty | Coast village; the boats for the Grottoes tie up here |
| Cliffbrook | mill | A hill brook in the Goatbell Hills to turn a wheel |
| Screebottom | workshop | Stone cutters at the foot of the scree |
| Screemere | shrine | A still mountain mere, the quiet sort of place |
| Atollmead | orchard | Fig and lemon trees on an island |
| Turtlenook | camp | A driftwood fire on a turtle beach |
| Cragholt | spring | Hot pools on the side of Cinderpeak |
| Echonook | tower | A lookout high on Cinderpeak |
| Olive Press Piazza (haven) | mill | An oil mill: the press stones |
| Lemon Grove Monastery (haven) | herb | "Quiet monks tend herbs" |

| Stop | Type | Bar | Perk | Icon | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|---|
| Olivewhistle Shore Market | market | Repairs | Swept Colonnade | 🏛️ | Seeds bought in Olivewhistle Shore Market cost 2% less | -2% | P | F02 buy |
|  |  | Larder | Oil-Jar Shelf | 🏺 | The stalls of Olivewhistle Shore Market pay 2% more for Shore-native crops | +2% | P | F01 sell |
|  |  | Cheer | Stallholder's Wink | 🧿 | Shop shelves in every town put a small olive on goods native to the region you are standing in | flag | F | A5 info |
| Brinewick | inn | Repairs | Singed-Boot Rack | 🥾 | +1 max health on the road from Brinewick to the Forge of the Cinder Wyrm | +1 point | P | F20 hp |
|  |  | Larder | Salt-Crust Supper | 🐟 | Dishes eaten at Brinewick at dusk or night give 2% more energy | +2% | P | F07 meal |
|  |  | Cheer | Lamp in the Window | 🕯️ | Once a day, the first walk that ends at Brinewick at night costs 1 less energy | 1 a day | D | A1 dayfree |
| Driftmead | ferry | Repairs | Tarred Seams | ⛵ | Walks from Driftmead to Turtlenook or to the Labyrinth Isle take 2% less time | -2% | P | F05 walk |
|  |  | Larder | Crates on the Quay | 📦 | Once a day, the first seed you buy at Driftmead's stall comes with one extra | 1 a day | D | A3 daygift |
|  |  | Cheer | Harbour-Master's Log | 📒 | The route menu shows, for each road, the game day you last walked it | flag | F | A5 info |
| Sprayglen | jetty | Repairs | Grotto Lantern Hook | 🔦 | +1 torch step in the Pirate-gull Grottoes | +1 step | P | F21 torch |
|  |  | Larder | Squid-Ink Bucket | 🦑 | Gathering at Sprayglen has a 1% chance of one extra | +1% | P | F11 gather |
|  |  | Cheer | Gull-Proof Hat | 🪶 | Gulls on your route map circle your gnome but never land (looks only) | flag | F | A6 looks |
| Cliffbrook | mill | Repairs | Goat-Proof Sluice | 🐐 | Acts at Cliffbrook that cost 2 or more energy pay 2% more coins | +2% | P | F15 stopcoin |
|  |  | Larder | Miller's Flatbread | 🫓 | First visit to Cliffbrook each day: one herb flatbread | 1 a day | D | A3 daygift |
|  |  | Cheer | Counted Goatbells | 🔔 | The route menu shows how many trail sights you have not yet found on each road | flag | F | A5 info |
| Screebottom | workshop | Repairs | Terrace Walls | 🧱 | Watering lasts 2% longer on Screebottom's local crops on hot days | +2% | P | F12 water |
|  |  | Larder | Cheese-Cave Shelf | 🧀 | First visit to Screebottom each day: one wedge of goat cheese | 1 a day | D | A3 daygift |
|  |  | Cheer | Mason's Eye | 📐 | Craft and mend checks at Screebottom are 2% kinder | +2% | P | F16 check |
| Screemere | shrine | Repairs | Reset Stepping Stones | 🪜 | Walks that end at Screemere have a 2% better chance to spot hidden things | +2% | P | F19 spot |
|  |  | Larder | Chestnut in the Bowl | 🌰 | Screemere's local crops have 1% more chance of a seed back in autumn | +1% | P | F13 seed |
|  |  | Cheer | Still Mere | 🪞 | On days with no wind, the stop page of every mountain stop shows the peaks mirrored in water (looks only) | flag | F | A6 looks |
| Atollmead | orchard | Repairs | Driftwood Props | 🪵 | 2% more garden XP from the fruit trees among Atollmead's local crops | +2% | P | F04 gxp |
|  |  | Larder | Sun-Dried on the Roof | 🍋 | Boosts from dishes eaten at Atollmead last 2% longer | +2% | P | F08 buff |
|  |  | Cheer | Sundial on the Quay | ☀️ | Your garden shows how long each bed's watering will last, in hours | flag | F | A5 info |
| Turtlenook | camp | Repairs | Roped-Off Nests | 🚩 | Rest acts at Turtlenook heal 2% more at night | +2% | P | F09 heal |
|  |  | Larder | Beachcomber's Pot | 🐚 | Once a day, the first time you gather at Turtlenook you also find a shell | 1 a day | D | A3 daygift |
|  |  | Cheer | Borrowed Shell | 🦀 | Now and then a hermit crab wanders across your satchel page (looks only) | flag | F | A6 looks |
| Cragholt | spring | Repairs | Relaid Basalt Steps | 🌋 | Fast travel to Cragholt costs 1% less | -1% | P | F18 travel |
|  |  | Larder | Ash-Baked Eggs | 🥚 | Once a day, the first dish you eat at Cragholt also heals 1 health | 1 a day | D | A3 daygift |
|  |  | Cheer | Steam Up to the Chin | ♨️ | Rest acts at Cragholt give 1 more energy in cold or rainy weather | +1 | P | F22 restenergy |
| Echonook | tower | Repairs | Restrung Echo Horn | 📯 | The route menu shows the level of the creature waiting at a lair before you set out | flag | F | A5 info |
|  |  | Larder | Lookout's Fava Pouch | 🫛 | Fast travel to Echonook has a 1% chance to turn up a seed on the way | +1% | P | F23 trailseed |
|  |  | Cheer | Says It Back Twice | 🗣️ | Once a day, a lost contest at Echonook is tried again | 1 a day | D | A2 dayback |
| Olive Press Piazza (haven) | mill | Repairs | Press Stones Rolled Home | 🫒 | Bread and oil at the Olive Press Piazza's stall cost 2% less | -2% | P | F02 buy |
|  |  | Larder | Heel of Bread, Dipped | 🍞 | First visit to the Olive Press Piazza each day: one heel of bread dipped in new oil | 1 a day | D | A3 daygift |
|  |  | Cheer | Piazza Lamps | 🏮 | At night, the stop page of every stop where all three of your bars are full is strung with small lamps (looks only) | flag | F | A6 looks |
| Lemon Grove Monastery (haven) | herb | Repairs | Cloister Roof, No Crates | 🏚️ | Pests are 2% less likely on the Lemon Grove Monastery's local crops while it rains | -2% | P | F17 pest |
|  |  | Larder | Lemon-Verbena Tisane | 🍵 | Lore boosts gained at the Lemon Grove Monastery last 2% longer | +2% | P | F08 buff |
|  |  | Cheer | A Vow Against Repeating Yourself | 🤫 | Chat lines you have already heard are shown in grey | flag | F | A5 info |

## 3. Birchbramble Steppe (EE): 12 stops, 36 perks

1 town, 10 villages, 1 haven. Thistleburrow is the border village at the end of the Mistmoor road. Newtdell, on the road out, belongs to Spicepeak (not in this file). Landscapes: grassland (Sunflower Steppe), forest (Birchbramble Wood), wetland (the Reedmarsh), mountain (Wolfback Ridges). Twelve stops, twelve stop types, one each.

Stop types to set in Admin > Places:

| Stop | Type | Why |
|---|---|---|
| Birchbramble Steppe Market | market | The town, on the Sunflower Steppe |
| Thistleburrow | inn | Border inn on the Mistmoor road; the Salt Mine road starts here |
| Haynook | mill | A windmill on the steppe; buckwheat to grind |
| Tussockgate | tower | A gate watch; the wolf road and the Spicepeak road start here |
| Hazelthorpe | orchard | Plum, cherry and hazel at the wood's edge |
| Mossknoll | shrine | A moss shrine on a knoll in Birchbramble Wood |
| Fernford | herb | Ferns, sorrel and elder by a forest ford |
| Miregate | ferry | The punt across the Reedmarsh |
| Reedby | jetty | Marsh anglers, and storks overhead |
| Echohollow | spring | Warm tubs in a hollow of the Wolfback Ridges |
| Flintknoll | camp | Flint for the fire, on a knoll in wolf country |
| Painted Egg House (haven) | workshop | A folk-art cottage: the egg painters' benches |

| Stop | Type | Bar | Perk | Icon | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|---|
| Birchbramble Steppe Market | market | Repairs | Sunflower-Husk Sweep | 🌻 | The stalls of Birchbramble Steppe Market pay 2% more for pickles and preserves | +2% | P | F01 sell |
|  |  | Larder | Dumpling for the Queue | 🥟 | First visit to Birchbramble Steppe Market each day: one dumpling | 1 a day | D | A3 daygift |
|  |  | Cheer | Cross-Stitch Awning | 🧵 | Your Perks page gets a red and black cross-stitch border (looks only) | flag | F | A6 looks |
| Thistleburrow | inn | Repairs | Salt-Miner's Lamp Shelf | ⛏️ | +1 torch step in the Salt Mine Galleries | +1 step | P | F21 torch |
|  |  | Larder | Beet Soup, Sour Cream | 🍲 | Soups and stews eaten at Thistleburrow give 2% more energy | +2% | P | F07 meal |
|  |  | Cheer | Samovar Never Cold | 🫖 | Once a day, the first act at Thistleburrow that costs energy costs 1 less | 1 a day | D | A1 dayfree |
| Haynook | mill | Repairs | Patched Sails | 🌬️ | Walks that start at Haynook take 2% less time on windy days | -2% | P | F05 walk |
|  |  | Larder | Buckwheat Bin | 🌾 | Grain harvests among Haynook's local crops: 1% chance of one extra | +1% | P | F10 harvest |
|  |  | Cheer | Pancake Morning | 🥞 | First visit to Haynook each day: one buckwheat pancake | 1 a day | D | A3 daygift |
| Tussockgate | tower | Repairs | Wolf-Watch Rail | 🐺 | +1 max health on the road from Tussockgate to the Lair of the Grey Wolf King | +1 point | P | F20 hp |
|  |  | Larder | Watcher's Onion String | 🧅 | Gathering on walks that start at Tussockgate has a 1% chance of one extra | +1% | P | F11 gather |
|  |  | Cheer | Steppe Beacon Chain | 🔥 | The world map shows today's weather in every region where you hold a mark | flag | F | A5 info |
| Hazelthorpe | orchard | Repairs | Wasp Jars on the Boughs | 🪤 | Pests are 2% less likely on the fruit crops among Hazelthorpe's local crops | -2% | P | F17 pest |
|  |  | Larder | Plum-Butter Crock | 🫙 | First visit to Hazelthorpe each day: one plum | 1 a day | D | A3 daygift |
|  |  | Cheer | Cherry-Stone Champion | 🍒 | Contests at Hazelthorpe are 2% kinder | +2% | P | F16 check |
| Mossknoll | shrine | Repairs | Birch-Bark Shingles | 🛖 | Fast travel to Mossknoll costs 1% less | -1% | P | F18 travel |
|  |  | Larder | Bowl Under the Bridge | 🥛 | Once a day, the first gift of a common local crop to one of Mossknoll's folk is not used up | 1 a day | D | A2 dayback |
|  |  | Cheer | Amber Bead on a String | 🟠 | Your walking staff gets an amber bead that glows at dusk (looks only) | flag | F | A6 looks |
| Fernford | herb | Repairs | Ford Stones Set Straight | 🪨 | Walks that end at Fernford take 2% less time in rain | -2% | P | F05 walk |
|  |  | Larder | Sorrel by the Step | 🌿 | Watering lasts 2% longer on the leafy crops among Fernford's local crops | +2% | P | F12 water |
|  |  | Cheer | Elderflower Cordial | 🍶 | Boosts from teas and cordials bought at Fernford's stall last 2% longer | +2% | P | F08 buff |
| Miregate | ferry | Repairs | Reed-Rope Hawser | 🪢 | Mend and haul acts at Miregate pay 2% more coins | +2% | P | F15 stopcoin |
|  |  | Larder | Toll Paid in Gherkins | 🥒 | The first act each day at Miregate pays 1 coin more | 1 coin | D | A4 daycoin |
|  |  | Cheer | Poled Every Channel | 🛶 | The route menu marks roads you have never walked with a small reed | flag | F | A5 info |
| Reedby | jetty | Repairs | Stork Wheel, Back on the Pole | 🪹 | A stork nests on your chimney at home in spring and summer (looks only) | flag | F | A6 looks |
|  |  | Larder | Smoke-Rack of Marsh Fish | 🎣 | Reedby's stall pays 2% more for fish | +2% | P | F01 sell |
|  |  | Cheer | Frogs Have the Last Word | 🐸 | Chats with Reedby's folk at dusk have a 2% chance of +1 friendship | +2% | P | F14 friend |
| Echohollow | spring | Repairs | Re-Caulked Wooden Tubs | 🛁 | Rest acts at Echohollow heal 2% more in snow or frost | +2% | P | F09 heal |
|  |  | Larder | Kefir Jug in the Cold Stream | 🏺 | Once a day, the first rest act at Echohollow gives 1 more energy | 1 a day | D | A3 daygift |
|  |  | Cheer | The Hollow Tells You Twice | 👂 | Stop pages show which bar each act feeds before you do it | flag | F | A5 info |
| Flintknoll | camp | Repairs | Flint and Dry Tinder | 🪓 | Pots cooked at Flintknoll's fire in wind, snow or frost cook 2% faster | -2% | P | F06 cook |
|  |  | Larder | Potatoes in the Embers | 🥔 | First visit to Flintknoll each day: one ember-baked potato | 1 a day | D | A3 daygift |
|  |  | Cheer | Ridge-Top Stories | 🌠 | 2% more XP from lore acts at Flintknoll | +2% | P | F03 xp |
| Painted Egg House (haven) | workshop | Repairs | One Very Small Brush | 🖌️ | Craft and paint checks at the Painted Egg House are 2% kinder | +2% | P | F16 check |
|  |  | Larder | Pickled-Egg Shelf | 🥚 | Egg dishes eaten at the Painted Egg House give 2% more energy | +2% | P | F07 meal |
|  |  | Cheer | Egg on the Windowsill | 🪺 | A painted egg sits on your windowsill at home; its pattern changes each season (looks only) | flag | F | A6 looks |

## 4. The Dunewhisper (MENA): 13 stops, 39 perks

1 town, 11 villages, 1 haven. Gullwell is the border village at the end of the Olivewhistle road. Cloverbottom (the Greatcanopy, section 5) and Heronby (Spicepeak, not in this file) are at the ends of the roads out. Landscapes: coast (Lemonwhite Harbour), grassland (Crescent Fields), mountain (Cedarcrown Heights), desert (the Endless Dunes). Two markets: the town and the Spice Souk.

Stop types to set in Admin > Places:

| Stop | Type | Why |
|---|---|---|
| The Dunewhisper Market | market | The town, in Lemonwhite Harbour |
| Gullwell | inn | Border inn on the Olivewhistle road, built round a well |
| Gullstead | jetty | Harbour anglers on the coast road |
| Brineburrow | ferry | The coast crossing toward the Greatcanopy |
| Meadowbrook | mill | A brook in the Crescent Fields; chickpea and sesame to grind |
| Windford | orchard | Date palms and pomegranates in the Crescent Fields |
| Prairieden | herb | Cumin, mint and sage beds |
| Craghollow | shrine | A hush under the cedars of Cedarcrown Heights |
| Cragmead | workshop | Cedar carpenters and brass smiths in the hills |
| Ambercrest | tower | A watch on a crest over the Endless Dunes |
| Amberholt | spring | A tiled warm pool in the desert |
| Sandbottom | camp | A caravan camp at the foot of the dunes |
| Spice Souk (haven) | market | "A covered market" |

| Stop | Type | Bar | Perk | Icon | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|---|
| The Dunewhisper Market | market | Repairs | Whitewashed Arcade | 🏘️ | The stalls of the Dunewhisper Market pay 2% more for spices and dried fruit | +2% | P | F01 sell |
|  |  | Larder | Last Basket of the Day | 🌇 | Food in the Dunewhisper Market costs 2% less at dusk, when the stalls pack up | -2% | P | F02 buy |
|  |  | Cheer | The Amber Hour | 🌆 | At dusk your Today page turns a warm amber (looks only) | flag | F | A6 looks |
| Gullwell | inn | Repairs | Scarab Charm Over the Door | 🪲 | +1 max health on the road from Gullwell to the Tomb of the Sand Scarab | +1 point | P | F20 hp |
|  |  | Larder | Drink First, Question Second | 💧 | First visit to Gullwell each day: 1 energy from the well | 1 a day | D | A3 daygift |
|  |  | Cheer | Rooftop Bed Under the Stars | 🛏️ | Rest acts at Gullwell at night give 1 more energy | +1 | P | F22 restenergy |
| Gullstead | jetty | Repairs | Net Floats Re-Corked | 🪝 | Walks that start at Gullstead at dawn take 2% less time | -2% | P | F05 walk |
|  |  | Larder | Octopus on the Line | 🐙 | Gathering with a rod at Gullstead has a 1% chance of one extra | +1% | P | F11 gather |
|  |  | Cheer | Blue Door, Fresh Paint | 🚪 | Your home gets a blue-painted door (looks only) | flag | F | A6 looks |
| Brineburrow | ferry | Repairs | Ballast of Salt Blocks | ⚓ | Fast travel to Brineburrow costs 1% less | -1% | P | F18 travel |
|  |  | Larder | Preserved-Lemon Jar | 🧂 | Sea salt and jars at Brineburrow's stall cost 2% less | -2% | P | F02 buy |
|  |  | Cheer | Oasis Rumour | 🏝️ | The route menu tells you which village the Oasis That Moves is at today | flag | F | A5 info |
| Meadowbrook | mill | Repairs | Canyon-Guide's Lamp | 🪔 | +1 torch step in the Rose-red Canyon City | +1 step | P | F21 torch |
|  |  | Larder | Sesame Round | 🥯 | First visit to Meadowbrook each day: one sesame flatbread | 1 a day | D | A3 daygift |
|  |  | Cheer | Fritters While You Wait | 🧆 | 2% more XP from craft and cook acts at Meadowbrook | +2% | P | F03 xp |
| Windford | orchard | Repairs | Palm-Climber's Belt | 🌴 | Tree harvests among Windford's local crops: 1% chance of one extra | +1% | P | F10 harvest |
|  |  | Larder | Pomegranate Press | 🧃 | Boosts from juices and sherbets bought at Windford last 2% longer | +2% | P | F08 buff |
|  |  | Cheer | Windchimes Re-Hung | 🎐 | Gifts of fruit to Windford's folk have a 2% chance of +1 friendship | +2% | P | F14 friend |
| Prairieden | herb | Repairs | Sage-Drying Roof | 🧺 | Pests are 2% less likely on the herbs and spices among Prairieden's local crops | -2% | P | F17 pest |
|  |  | Larder | Cumin Row | 🌱 | 2% more garden XP from Prairieden's local crops in dry weather | +2% | P | F04 gxp |
|  |  | Cheer | Old Herbalist's Almanac | 📜 | Seed packets show how the region you are standing in changes their growing time | flag | F | A5 info |
| Craghollow | shrine | Repairs | Cedar Beams, Oiled | 🌲 | Sense and lore checks at Craghollow are 2% kinder | +2% | P | F16 check |
|  |  | Larder | Almond in the Niche | 🥜 | The nut and tree crops among Craghollow's local crops have 1% more chance of a seed back | +1% | P | F13 seed |
|  |  | Cheer | Hush Under the Cedars | 🕊️ | Your Today page shows a cedar sprig beside your gnome's name (looks only) | flag | F | A6 looks |
| Cragmead | workshop | Repairs | Cedar-Shaving Broom | 🪚 | Once a day, a craft act at Cragmead that fails gives its ingredients back | 1 a day | D | A2 dayback |
|  |  | Larder | Brass Pot on the Bench | 🥘 | Dishes eaten at Cragmead by day give 2% more energy | +2% | P | F07 meal |
|  |  | Cheer | Inlaid Game Board | 🎲 | Pick and contest acts at Cragmead pay 2% more coins | +2% | P | F15 stopcoin |
| Ambercrest | tower | Repairs | Sand-Swept Stair | 🧗 | Walks that start at Ambercrest at dusk or night take 2% less time | -2% | P | F05 walk |
|  |  | Larder | Shade Jar of Chickpeas | 🫘 | First visit to Ambercrest each day: one handful of roasted chickpeas | 1 a day | D | A3 daygift |
|  |  | Cheer | Star-Counter's Chart | 🌟 | The world map shows how many game days it is since you last visited each stop | flag | F | A5 info |
| Amberholt | spring | Repairs | Tiled Pool, Regrouted | 🚿 | Rest acts at Amberholt heal 2% more in heat | +2% | P | F09 heal |
|  |  | Larder | Mint in the Steam | 🌿 | Boosts from teas drunk at Amberholt last 2% longer | +2% | P | F08 buff |
|  |  | Cheer | Star-Tile Floor | 🔷 | Stop pages of hot springs show a blue star-tile floor under the water (looks only) | flag | F | A6 looks |
| Sandbottom | camp | Repairs | Tent Ropes Against the Wind | ⛺ | Once a day, the first walk that ends at Sandbottom in heat costs 1 less energy | 1 a day | D | A1 dayfree |
|  |  | Larder | Supper Buried in Hot Sand | 🍢 | Pots cooked at Sandbottom's fire at night cook 2% faster | -2% | P | F06 cook |
|  |  | Cheer | What the Dunes Said | 👣 | On desert walks your gnome leaves footprints on the route map that fade behind you (looks only) | flag | F | A6 looks |
| Spice Souk (haven) | market | Repairs | Roof Cloth, Stretched Tight | 🧶 | Haggle checks at the Spice Souk are 2% kinder | +2% | P | F16 check |
|  |  | Larder | Pinch From Every Basket | 🌶️ | First visit to the Spice Souk each day: one pinch of cumin | 1 a day | D | A3 daygift |
|  |  | Cheer | No Bargain Without Tea | 🫖 | Shop pages show what you paid the last time you bought each thing | flag | F | A5 info |

## 5. The Greatcanopy (WCA): 13 stops, 39 perks

1 town, 11 villages, 1 haven. Cloverbottom is the border village at the end of the Dunewhisper road. Meadowden, on the road out, belongs to Thornacre Savanna (not in this file). Landscapes: grassland (Shea Sahel), wetland (Riverdelta Weave), rainforest (the Greatcanopy Deep), coast (Goldsand Coast). Two camps: Driftglen's beach fire and the Drum Circle.

Stop types to set in Admin > Places:

| Stop | Type | Why |
|---|---|---|
| The Greatcanopy Market | market | The town, in the Shea Sahel |
| Cloverbottom | inn | Border inn on the Dunewhisper road; six roads leave it |
| Thistleholt | mill | Millet and fonio to pound and grind |
| Hayglen | orchard | Shea and kola trees in open parkland; the Canopy Bridges road starts here |
| Fenmead | ferry | The dugout crossing in the Riverdelta Weave |
| Fenwell | jetty | Stilt houses and crayfish pots |
| Heronwick | herb | Hibiscus and marsh herbs |
| Vineden | shrine | A quiet shrine under the vines of the Deep |
| Lianawick | workshop | Rope and bridge makers |
| Mistcrest | spring | Warm pools on a misty crest |
| Driftglen | camp | A beach fire on the Goldsand Coast |
| Pebblenook | tower | A lookout over the Goldsand Coast |
| Drum Circle Market (haven) | camp | "Music, stew and rest": a ring of drums round the fire |

| Stop | Type | Bar | Perk | Icon | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|---|
| The Greatcanopy Market | market | Repairs | Laterite Kerb Stones | 🧱 | The stalls of the Greatcanopy Market pay 2% more for roots and tubers | +2% | P | F01 sell |
|  |  | Larder | Groundnut Twist | 🥜 | First visit to the Greatcanopy Market each day: one paper twist of roasted groundnuts | 1 a day | D | A3 daygift |
|  |  | Cheer | Wax-Print Awnings | 👘 | Your satchel gets a wax-print cloth lining; the pattern changes with each new mark in the Greatcanopy (looks only) | flag | F | A6 looks |
| Cloverbottom | inn | Repairs | Web-Brushed Rafters | 🕸️ | +1 max health on the road from Cloverbottom to the Hollow of the Silverback Spider | +1 point | P | F20 hp |
|  |  | Larder | Groundnut Stew, Second Ladle | 🍲 | Boosts from meals bought at Cloverbottom in rain last 2% longer | +2% | P | F08 buff |
|  |  | Cheer | A Story From the Spider | 🕷️ | Stop pages put a small web on lore acts you have not heard yet | flag | F | A5 info |
| Thistleholt | mill | Repairs | Mortar and Tall Pestle | 🪵 | Power acts at Thistleholt pay 2% more coins | +2% | P | F15 stopcoin |
|  |  | Larder | Fonio Sieve | 🌾 | 2% more garden XP from the grains among Thistleholt's local crops | +2% | P | F04 gxp |
|  |  | Cheer | Porridge at First Light | 🥣 | First visit to Thistleholt each day: one bowl of millet porridge | 1 a day | D | A3 daygift |
| Hayglen | orchard | Repairs | Bridge-Walker's Lamp | 🌉 | +1 torch step in the Canopy Bridges | +1 step | P | F21 torch |
|  |  | Larder | Shea Butter Pot | 🧈 | Nut harvests among Hayglen's local crops: 1% chance of one extra | +1% | P | F10 harvest |
|  |  | Cheer | Kola Nut, Split and Shared | 🌰 | Chats with Hayglen's folk at dawn have a 2% chance of +1 friendship | +2% | P | F14 friend |
| Fenmead | ferry | Repairs | Dugout, Freshly Pitched | 🛶 | Walks that end at Fenmead by day take 2% less time | -2% | P | F05 walk |
|  |  | Larder | Smoked Catfish Basket | 🐟 | Fenmead's stall pays 2% more for smoked and dried goods | +2% | P | F01 sell |
|  |  | Cheer | Paddle-Beat Song | 🎶 | Once a day, the first power act at Fenmead costs 1 less energy | 1 a day | D | A1 dayfree |
| Fenwell | jetty | Repairs | Stilt Legs, Re-Footed | 🏗️ | Walks that start at Fenwell in rain have a 2% better chance to spot hidden places | +2% | P | F19 spot |
|  |  | Larder | Crayfish Pots | 🦐 | The pod crops among Fenwell's local crops have 1% more chance of a seed back | +1% | P | F13 seed |
|  |  | Cheer | Heron on Every Post | 🦢 | A heron stands by your garden's water butt on rainy days (looks only) | flag | F | A6 looks |
| Heronwick | herb | Repairs | Rain-Gutter Reeds | 🌧️ | Once a day, the first tend act at Heronwick costs 1 less energy | 1 a day | D | A1 dayfree |
|  |  | Larder | Hibiscus Steep | 🌺 | Watering lasts 2% longer on Heronwick's local crops on windy days | +2% | P | F12 water |
|  |  | Cheer | Night-Scented Bed | 🦗 | Your garden marks the beds that will need weeding by the next game day | flag | F | A5 info |
| Vineden | shrine | Repairs | Roots Off the Path | 🌳 | Resting on walks that start at Vineden heals 2% more in rain | +2% | P | F09 heal |
|  |  | Larder | Leaf-Plate Offering | 🍃 | Gathering at Vineden at dawn has a 1% chance of one extra | +1% | P | F11 gather |
|  |  | Cheer | Polite as a Gorilla | 🦍 | Charm checks at Vineden are 2% kinder | +2% | P | F16 check |
| Lianawick | workshop | Repairs | Liana Rope, Triple-Plaited | 🧗 | 2% more XP from craft and mend acts at Lianawick | +2% | P | F03 xp |
|  |  | Larder | Yam Chips in a Leaf Cone | 🍠 | First visit to Lianawick each day: one cone of yam chips | 1 a day | D | A3 daygift |
|  |  | Cheer | Tin-Roof Drumming | 🥁 | When it rains, your Today page shows rain running off a tin roof (looks only) | flag | F | A6 looks |
| Mistcrest | spring | Repairs | Mossy Pool Lip, Scrubbed | 🧽 | Rest acts at Mistcrest give 1 more energy at dawn, while the mist is in | +1 | P | F22 restenergy |
|  |  | Larder | Pepper Soup in a Leaf Cup | 🥬 | Dishes eaten at Mistcrest in rain give 2% more energy | +2% | P | F07 meal |
|  |  | Cheer | Steam-Room Recipes | 📖 | Your satchel shows how many recipes you know use each ingredient | flag | F | A5 info |
| Driftglen | camp | Repairs | Palm-Thatch Windbreak | 🛖 | Pots cooked at Driftglen's fire with fish in them cook 2% faster | -2% | P | F06 cook |
|  |  | Larder | Grilled-Fish Night | 🐠 | The first fish you sell each day at Driftglen's stall pays 2 coins more | 2 coins | D | A4 daycoin |
|  |  | Cheer | Goldsand in the Turn-Ups | ✨ | Passport stamps from coast stops get a gold-sand shimmer (looks only) | flag | F | A6 looks |
| Pebblenook | tower | Repairs | Palm-Oil Beacon | 🪔 | Fast travel to Pebblenook costs 1% less | -1% | P | F18 travel |
|  |  | Larder | Cowpea Fritter Tin | 🧆 | First visit to Pebblenook each day: one cowpea fritter | 1 a day | D | A3 daygift |
|  |  | Cheer | Canoes Counted Home | 🌊 | The route menu shows what kind of land each stretch of a road crosses | flag | F | A5 info |
| Drum Circle Market (haven) | camp | Repairs | Drum Skins Pulled Tight | 🪘 | Acts at the Drum Circle Market pay 2% more coins on festival days | +2% | P | F15 stopcoin |
|  |  | Larder | Stew for Whoever Comes | 🍛 | Rest acts at the Drum Circle Market give 1 more energy at dusk, when the stew is ladled | +1 | P | F22 restenergy |
|  |  | Cheer | Rhythm in the Feet | 🎵 | On festival days a small drum beats beside the date on your Today page (looks only) | flag | F | A6 looks |

## 6. Counts

| Region | Stops | Perks | W | P | D | F | World-family units used |
|---|---|---|---|---|---|---|---|
| Olivewhistle Shore (SE) | 13 | 39 | 0 | 21 | 8 | 10 | 0 (every share is 0) |
| Birchbramble Steppe (EE) | 12 | 36 | 0 | 21 | 8 | 7 | 0 (every share is 0) |
| The Dunewhisper (MENA) | 13 | 39 | 0 | 24 | 6 | 9 | 0 (every share is 0) |
| The Greatcanopy (WCA) | 13 | 39 | 0 | 23 | 7 | 9 | 0 (every share is 0) |
| **All four** | **51** | **153** | **0** | **89** | **29** | **35** | **0** |

Perks per family, all four regions (every numbered one is a place perk): F01 sell 6, F02 buy 4, F03 xp 3, F04 gxp 3, F05 walk 6, F06 cook 3, F07 meal 5, F08 buff 6, F09 heal 4, F10 harvest 3, F11 gather 4, F12 water 3, F13 seed 3, F14 friend 3, F15 stopcoin 5, F16 check 6, F17 pest 3, F18 travel 4, F19 spot 2, F20 hp 4, F21 torch 4, F22 restenergy 4, F23 trailseed 1, A1 dayfree 5, A2 dayback 3, A3 daygift 19, A4 daycoin 2, A5 info 17, A6 looks 18.

Daily charges: 29 perks, each with its own trigger, and every one is tied to its own stop (first visit, first act of a kind there, first sale or buy at its stall, a walk that ends there). So none can share a trigger with a world daily perk, in the Maplewold or in another region. (A first draft had "the first weed you pull in rain" at Heronwick; the Maplewold's Cleared Channels at Cattailmere now owns the weeding trigger, so it was replaced.)

Build notes (as section 5 of `proposal-stop-perks.md`): item names (herb flatbread, goat cheese, shell, dumpling, plum, buckwheat pancake, ember-baked potato, sesame flatbread, roasted chickpeas, cumin, groundnuts, millet porridge, yam chips, cowpea fritter, bread) and item groups (fish, pickles and preserves, spices and dried fruit, roots and tubers, smoked and dried goods, soups and stews, egg dishes, grains, nuts, pods, fruit trees, leafy crops) must be mapped to real slugs and categories at build time; where an item does not exist, use the nearest common local one. New scope needs: `to=<landmark>` for the four torch perks (one delve each) and the four max-health perks (one lair road each); `to=<stop>` on fast travel (F18, F23); three daily gifts that give 1 energy or 1 health in place of an item (Gullwell, Echohollow, Cragholt). Every flag is UI only.

## 7. Checks (script)

Run on the rows of this file by a scratch Python script (`genB.py`, not in the repo; it holds the hand-written rows and wrote the tables):
- **Names and effects: all 153 are unique** within this file, and none equals any of the 90 existing ones (54 Maplewold perks of section 5 + 36 type templates of section 6, read from `proposal-stop-perks.md` as it stands now; the brief said 84, the file has grown by the 6 perks of Cattailmere and Granitegate). Compared in lower case with punctuation removed.
- Against the other two region files: checked against `proposal-stop-perks-regions-C.md` as it stood when this file was finished: no perk name or effect of this file appears as a table cell there. Three flags that read too close to a C perk (moon phase, a kite on windy days, a turtle crossing a page) were rewritten by hand. `proposal-stop-perks-regions-A.md` did not exist yet; rerun the check when it lands.
- Each stop has exactly three perks, one per bar, in three different families; no stop has two flags.
- No number above 2%; every +1 is energy, a torch step or a health point; every daily perk is one charge.
- At most one local-crop perk per family per region.
- Scope and family agree (flags are A5 or A6, daily charges A1 to A4, everything else P); no W perk exists.

## 8. Problems hit (max 5)

1. **Every world share is 0**, so this file has no world perks. If Josh wants a few true world perks outside the Maplewold, the caps must go up or the Maplewold set must give some budget back; 13 regions cannot share 1 to 6 points.
2. **"Local crops" are per region in code, not per stop** (`stop_local_crops()` reads `plant_regions` by region). The templates of section 6 assume per stop; with them, ten herb or mill stops in one region would pile onto the same crops up to the cap. Here it is held to one local-crop perk per family per region, each narrowed further.
3. **Stop types.** 13 stops and 12 types force one repeat in SE (two mills), MENA (two markets) and WCA (two camps). One type sits outside the "landscapes it suits" list of `stops.txt`: Lianawick, a workshop in rainforest (rope and bridge makers). Lemon Grove Monastery is herb, not shrine, because its landmark line says the monks tend herbs. Havens and towns have no stop type in code yet (`stop_is_place()`).
4. **Templates already cover the plain place effects** ("walks that start at {stop} take 2% less time"). To stay hand-written and different, most numbered perks here carry a condition (day part, weather, season, act kind, item group). That makes them a little weaker than a template at the same stop, and needs the act-kind and item-group scopes to exist.
5. **Unknowns in the game data**: some flags assume data the UI may not show yet (the game day a road was last walked, last price paid, days since last visit, weeding forecast, lair creature level), and some gift items may not exist as slugs. Each is marked for mapping at build time; none changes balance.
