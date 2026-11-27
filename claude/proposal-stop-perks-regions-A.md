# PROPOSAL: Hand-written stop perks, regions A (Maizehollow, Mistmoor, the Sunsprinkle Isles, the Rainroot Reaches)

Status: proposal only, no game code changed. 2026-11-27.
Follows `proposal-stop-perks.md` (rules, families, caps, section 5 format) and `PROPOSAL-HOLLOW-MASTER.md` section 7 and section 14 ruling 7 (a hand-written set per region). Stops are every town, village and haven of the four regions in `claude/route-list.md`. Wonders, delves and lairs are not stops.

Every stop below has its own three perks, one per bar. **49 stops, 147 perks.** The two border villages already written in the Maplewold set (Larkbrook in Maizehollow, Windbottom in Mistmoor) keep those perks and are not repeated.

## 1. World budget: this file's share per family

Share = (cap minus what the Maplewold set uses) / 13 other regions, rounded down. The Maplewold column is the "NA world" figure of `proposal-stop-perks.md` section 4 and 4.1 (18 stops, 54 perks, with Cattailmere and Granitegate).

| Family | Effect | Cap | Maplewold uses | Left | Share per region (left / 13, rounded down) | So in this file |
|---|---|---|---|---|---|---|
| F01 | sell | 5 | 2 | 3 | **0** | place-scoped only |
| F02 | buy | 5 | 1 | 4 | **0** | place-scoped only |
| F03 | XP | 5 | 3 | 2 | **0** | place-scoped only |
| F04 | garden XP | 5 | 1 | 4 | **0** | place-scoped only |
| F05 | walk time | 6 | 2 | 4 | **0** | place-scoped only |
| F06 | pot time | 6 | 4 | 2 | **0** | place-scoped only |
| F07 | dish energy | 5 | 2 | 3 | **0** | place-scoped only |
| F08 | boost length | 8 | 4 | 4 | **0** | place-scoped only |
| F09 | healing | 8 | 4 | 4 | **0** | place-scoped only |
| F10 | harvest extra | 4 | 2 | 2 | **0** | place-scoped only |
| F11 | gather extra | 4 | 1 | 3 | **0** | place-scoped only |
| F12 | watering lasts | 8 | 2 | 6 | **0** | place-scoped only |
| F13 | seed back | 4 | 1 | 3 | **0** | place-scoped only |
| F14 | friendship chance | 8 | 2 | 6 | **0** | place-scoped only |
| F15 | stop coins | 8 | 2 | 6 | **0** | place-scoped only |
| F16 | stop check | 4 | 1 | 3 | **0** | place-scoped only |
| F17 | pest | 8 | 2 | 6 | **0** | place-scoped only |
| F18 | fast travel cost | 5 | 1 | 4 | **0** | place-scoped only |
| F19 | spot hidden | 4 | 1 | 3 | **0** | place-scoped only |
| F20 | max health | 3 | 0 | 3 | **0** | place-scoped only |
| F21 | torch steps | 3 | 0 | 3 | **0** | place-scoped only |
| F22 | rest energy | 2 | 2 | 0 | **0** | place-scoped only |
| F23 | seed on fast travel | 4 | 1 | 3 | **0** | place-scoped only |
| A4 | daycoin (coins a game day) | 10 | 1 | 9 | **0** | place-scoped only |
| A1, A2, A3 | daily charges | one charge per perk | 8 world charges | no shared cap | own trigger each | allowed; most are tied to the stop |
| A5, A6 | flags | no power | 11 | no cap | 1 of each per stop at most | allowed |

**Every share is 0.** The largest amount left in any family is 9 coins (A4) or 6 points (watering, friendship, stop coins, pest), and both divided by 13 round down to 0. So this file has **no world perk at all**: every perk with a number is a place perk (P), and the rest are daily charges (D) or flags (F). World-family units used by these four regions: 0.

Rules used for the place perks (stricter than section 4.1 where that was open):
- Scope is always one of: `from=` / `to=` this stop (its acts, its stall, its walks, fast travel to or from it); `items=local:` narrowed to one or two **named** crops native to the region; or `region=` for one delve or one kind of road.
- One perk per family per stop. One perk per family per crop in a region (script-checked), so a crop never gets the same bonus twice from this file. `stop_local_crops()` returns the whole region's crops, so the type templates' "local crops" overlap with these; the per-crop family cap of 4.1 still applies.
- No `region=` perk in XP, walk time or pot time, so the worst case at one place stays as in 4.1 (walk -10%, pots -10%, XP +7%).
- Size: 1% or 2%, +1 energy, +1 torch step, +1 max health. Nothing above 2%.
- Daily charges: one per perk per game day (back after sleep, not at midnight, never banked). "D here" = the trigger only happens at that stop or on its walks. "D" = works anywhere, with a trigger no other perk uses.
- A4 coins: one perk (Scorchburrow), 2 coins, at the stop only; it stays under the ceiling of 10 coins a game day.
- Flags: at most one info (A5) and one looks (A6) per stop.

Scope column: W world, P place, D daily charge, F flag. Day parts and weather read the gnome's own clock (`dp=`, `we=`; weather words as in the act files: rain, wind, storm, snow, frost, fog, heat, sun, cloud).

## 2. Maizehollow (CA): 11 stops, 33 perks

Dry spells and volcanic ash; corn, beans, chilies, tomatillos. Larkbrook (border inn) already has its three perks in `proposal-stop-perks.md` section 5 and is not rewritten here.

Stop types to set in Admin > Places:

| Stop | Type | Why |
|---|---|---|
| Maizehollow Market | market | The town: the corn exchange |
| Poppynook | mill | Grassland road village: the corn is ground here |
| Meadowmere | inn | Crossroads: roads to the town, the Isles, the desert, the haven and the lair |
| Jadedell | shrine | Rainforest; the road to the Stepped Seed Temple starts here |
| Frondthorpe | orchard | Rainforest: avocado, papaya and mamey trees |
| Orchiddell | herb | Rainforest; orchids on every doorpost (vanilla is an orchid) |
| Saffroncrest | tower | A crest in the desert |
| Scorchburrow | camp | Desert: cool burrows and a fire after dark |
| Stonethorpe | spring | Mountain, under the Smokecap Volcanoes: ash-lined warm pools |
| Flintcove | workshop | Mountain: obsidian knappers |
| Market of a Thousand Chilies | market | Haven: spice stalls and a cocoa house |

| Stop | Type | Bar | Perk | Icon | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|---|
| Maizehollow Market | market | Repairs | Relaid Cobbles | 🧱 | Fast travel that ends at Maizehollow Market costs 1% less | -1% | P `to=` | F18 |
|  |  | Larder | Thirteen Ears to the Dozen | 🌽 | Corn sells for 2% more at Maizehollow Market's stalls | +2% | P `from=` | F01 |
|  |  | Cheer | Brass on the Bandstand | 🎺 | The Today page names any Maizehollow stop that has a festival on | flag | F | A5 |
| Poppynook | mill | Repairs | Dressed Grindstone | 🪨 | Dishes with corn in them cook 2% faster | -2% | P `items=local:` corn | F06 |
|  |  | Larder | First Off the Griddle | 🫓 | First visit to Poppynook each day: one warm tortilla | 1 a day | D here | A3 |
|  |  | Cheer | Poppies on the Sill | 🌺 | A pot of red poppies sits by your garden gate (looks only) | flag | F | A6 |
| Meadowmere | inn | Repairs | Restrung Hammocks | 🪢 | Rest acts at Meadowmere from dusk on give 1 more energy | +1 | P `from=` `dp=dusk,night` | F22 |
|  |  | Larder | Beans in the Pot Since Tuesday | 🫘 | Dishes with black beans give 2% more energy | +2% | P `items=local:` black-bean | F07 |
|  |  | Cheer | Five Roads' Worth of Gossip | 🧭 | In Meadowmere the route menu shows the weather at the far end of each road | flag | F | A5 |
| Jadedell | shrine | Repairs | Reset Temple Steps | 🪜 | Walks from Jadedell to the Stepped Seed Temple take 2% less time | -2% | P `from=` | F05 |
|  |  | Larder | Seed Left on the Altar | 🌱 | Tomatillo harvests: 1% more chance of a seed back | +1% | P `items=local:` tomatillo | F13 |
|  |  | Cheer | Jade in the Ink | 🟢 | Your Maizehollow passport stamps print in jade green (looks only) | flag | F | A6 |
| Frondthorpe | orchard | Repairs | Shored-Up Terraces | 🪵 | Watering lasts 2% longer on avocado and papaya | +2% | P `items=local:` avocado, papaya | F12 |
|  |  | Larder | Two From One Stone | 🥑 | Once a day, your first avocado harvest gives one extra avocado | 1 a day | D | A3 |
|  |  | Cheer | Paw Prints in the Mud | 🐆 | The route menu shows how many hidden places on a road out of Frondthorpe you have not found yet | flag | F | A5 |
| Orchiddell | herb | Repairs | Retied Orchid Stakes | 🧵 | Pests are 2% less likely on chayote and amaranth | -2% | P `items=local:` chayote, amaranth | F17 |
|  |  | Larder | Chayote Up the Trellis | 🫛 | Chayote harvests: 1% chance of one extra | +1% | P `items=local:` chayote | F10 |
|  |  | Cheer | Hummingbird at the Window | 🦋 | A hummingbird hovers over your garden while something is in flower (looks only) | flag | F | A6 |
| Saffroncrest | tower | Repairs | Polished Signal Mirror | 🪞 | On sunny days, walks that start at Saffroncrest take 2% less time | -2% | P `from=` `we=sun` | F05 |
|  |  | Larder | Nopal Off the Parapet | 🌵 | First visit to Saffroncrest each day: one nopal pad | 1 a day | D here | A3 |
|  |  | Cheer | Counts the Shadows | 🌅 | The route menu shows the day part you will arrive in | flag | F | A5 |
| Scorchburrow | camp | Repairs | Mended Water Jars | 🏺 | Watering lasts 2% longer on chili peppers and tomatillos in heat | +2% | P `items=local:` chili-pepper, tomatillo `we=heat` | F12 |
|  |  | Larder | Supper After Sundown | 🌮 | Dishes eaten at Scorchburrow at night give 2% more energy | +2% | P `from=` `dp=night` | F07 |
|  |  | Cheer | A Wish per Shooting Star | 🌠 | First rest act at Scorchburrow each night: 2 coins turn up in the sand | 2 coins, 1 a day | D here | A4 |
| Stonethorpe | spring | Repairs | Relined Ash Pools | ♨️ | Healing from rest acts at Stonethorpe is 2% stronger at dawn and dusk | +2% | P `from=` `dp=dawn,dusk` | F09 |
|  |  | Larder | Ash for the Beds | 🌋 | 2% more garden XP from black beans | +2% | P `items=local:` black-bean | F04 |
|  |  | Cheer | Steam on Cold Mornings | 🌫️ | A wisp of steam curls from your cooking pot while it is busy (looks only) | flag | F | A6 |
| Flintcove | workshop | Repairs | Knapped a Fresh Edge | 🔪 | Once a day, the first tool wear on a walk that starts at Flintcove is skipped | 1 a day | D here | A2 |
|  |  | Larder | Comal Hammered Flat | 🍳 | Dishes with tomatillo in them cook 2% faster | -2% | P `items=local:` tomatillo | F06 |
|  |  | Cheer | Sees Itself in Obsidian | 🖤 | Stop pages show how many points each act will add to a bar before you do it | flag | F | A5 |
| Market of a Thousand Chilies | market | Repairs | Repainted Stall Numbers | 🪧 | Spices and chilies cost 2% less at the Thousand Chilies stalls | -2% | P `from=` | F02 |
|  |  | Larder | The Thousand-and-First | 🌶️ | Chili pepper harvests: 1% chance of one extra | +1% | P `items=local:` chili-pepper | F10 |
|  |  | Cheer | Tried the Hot One | 🥵 | Boosts from dishes with chili pepper last 2% longer | +2% | P `items=local:` chili-pepper | F08 |

## 3. Mistmoor (NWE): 12 stops, 36 perks

Soft rain and peaty loam; rye, barley, leeks, sprouts. Windbottom (gate beacon) already has its three perks in `proposal-stop-perks.md` section 5 and is not rewritten here.

Stop types to set in Admin > Places:

| Stop | Type | Why |
|---|---|---|
| Mistmoor Market | market | The town |
| Windburrow | mill | Grassland road village: a windmill for rye and barley |
| Larkden | inn | Crossroads: roads to the town, the coast, the Tearoom, the lair and Olivewhistle Shore |
| Hollowknoll | shrine | Forest; the road to the Standing Stones starts here |
| Fernden | camp | A clearing in Fernhollow Wood |
| Hazelmere | orchard | Forest by a mere: hazels, currants and rhubarb |
| Spraywell | jetty | Fjordfang Coast: anglers on the planks |
| Brinehollow | ferry | Fjord crossing |
| Froststead | workshop | Tundra: sledge-makers |
| Sleetford | tower | A fell beacon on the Long Night Fells |
| Thatchtop Tearoom | herb | Haven: a tea garden behind the thatch |
| Northern Lights Sauna | spring | Haven: steam and a cold plunge |

| Stop | Type | Bar | Perk | Icon | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|---|
| Mistmoor Market | market | Repairs | Patched Awnings | ☂️ | On rainy days, Mistmoor Market's stalls pay 2% more for what you sell | +2% | P `from=` `we=rain` | F01 |
|  |  | Larder | Leek by the Yard | 🧅 | Leeks cost 2% less at Mistmoor Market's stalls | -2% | P `from=` | F02 |
|  |  | Cheer | Town Crier's Second Wind | 📯 | The Today page lists the Mistmoor stops you have not visited this game day | flag | F | A5 |
| Windburrow | mill | Repairs | Reset Sails | 🌬️ | On windy days, dishes with rye or barley cook 2% faster | -2% | P `items=local:` rye, barley `we=wind` | F06 |
|  |  | Larder | Baker's Peel | 🍞 | Once a day, the first bread or bake you cook with rye comes out with one extra | 1 a day | D | A3 |
|  |  | Cheer | Kite Day | 🪁 | A small kite flies over your garden on windy days (looks only) | flag | F | A6 |
| Larkden | inn | Repairs | Trimmed Wicks | 🕯️ | Healing from rest acts at Larkden is 2% stronger when it rains | +2% | P `from=` `we=rain` | F09 |
|  |  | Larder | Sprouts Done Properly | 🥬 | Dishes with brussels sprouts give 2% more energy | +2% | P `items=local:` brussels-sprouts | F07 |
|  |  | Cheer | Fiddle in the Corner | 🎻 | 2% more XP from acts at Larkden from dusk on | +2% | P `from=` `dp=dusk,night` | F03 |
| Hollowknoll | shrine | Repairs | Righted Waymarker | 🪦 | Walks that end at Hollowknoll in fog or rain take 2% less time | -2% | P `to=` `we=fog,rain` | F05 |
|  |  | Larder | One for the Stones | 🍄 | In fog or after rain, gathering on walks out of Hollowknoll has a 1% chance of one extra | +1% | P `from=` `we=fog,rain` | F11 |
|  |  | Cheer | The Stones Hum Back | 🎶 | At dusk a faint ring of standing stones shows on the horizon of your Today page (looks only) | flag | F | A6 |
| Fernden | camp | Repairs | Dry Kindling Under Cover | 🪓 | Once a day, the first act you do at Fernden in the rain costs 1 less energy | 1 a day | D here | A1 |
|  |  | Larder | Hedgerow Pudding | 🫐 | Lingonberry harvests: 1% chance of one extra | +1% | P `items=local:` lingonberry | F10 |
|  |  | Cheer | Ring of Toadstools | 🧚 | After rain, a ring of small mushrooms shows in a corner of your garden (looks only) | flag | F | A6 |
| Hazelmere | orchard | Repairs | Stile Over the Hedge | 🚪 | Once a day, the first walk that ends at Hazelmere costs 1 less energy | 1 a day | D here | A1 |
|  |  | Larder | Jam Pan Scoured | 🫙 | Dishes with rhubarb or blackcurrant cook 2% faster | -2% | P `items=local:` rhubarb, blackcurrant | F06 |
|  |  | Cheer | Conker Champion | 🌰 | Contests at Hazelmere pay 2% more coins | +2% | P `from=` kind contest | F15 |
| Spraywell | jetty | Repairs | Storm Lantern Rehung | 🏮 | +1 torch step in the Sea-cave Smugglers' Run | +1 step | P `region=NWE` (that delve) | F21 |
|  |  | Larder | Smoked Over Alder | 🐟 | Fish sell for 2% more at Spraywell's stall | +2% | P `from=` | F01 |
|  |  | Cheer | Reads the Tide Table | 🌊 | The Today page shows the hour of the next low tide | flag | F | A5 |
| Brinehollow | ferry | Repairs | Greased Winch | ⛓️ | Fast travel that starts or ends at Brinehollow costs 1% less | -1% | P `from=` / `to=` | F18 |
|  |  | Larder | Pickle Crock Under the Bench | 🥒 | Boosts from dishes with kohlrabi last 2% longer | +2% | P `items=local:` kohlrabi | F08 |
|  |  | Cheer | Seal Off the Slipway | 🦭 | A seal's head bobs at the edge of your Today page when you wake on a coast (looks only) | flag | F | A6 |
| Froststead | workshop | Repairs | Waxed Runners | 🛷 | Walks that start at Froststead take 2% less time in snow or frost | -2% | P `from=` `we=snow,frost` | F05 |
|  |  | Larder | Sweeter After Frost | ❄️ | Brussels sprouts harvested in frost: 1% chance of one extra | +1% | P `items=local:` brussels-sprouts `we=frost` | F10 |
|  |  | Cheer | Knitted While You Waited | 🧤 | Your gnome wears mittens in its portrait while it snows (looks only) | flag | F | A6 |
| Sleetford | tower | Repairs | Windbreak Rebuilt | 🛡️ | +1 max health in fights on Mistmoor's tundra roads | +1 | P `region=NWE` `land=tundra` | F20 |
|  |  | Larder | Berries Under the Snow | 🍒 | Gathering at Sleetford itself: 1% chance of one extra | +1% | P `from=` (gather here) | F11 |
|  |  | Cheer | Cartographer's Corrections | 🗺️ | The world map draws the Mistmoor roads you have walked in a darker line | flag | F | A5 |
| Thatchtop Tearoom | herb | Repairs | Reglazed Cold Frame | 🪴 | Watering lasts 2% longer on rhubarb and asparagus | +2% | P `items=local:` rhubarb, asparagus | F12 |
|  |  | Larder | The Good Scone | 🧁 | First visit to the Thatchtop Tearoom each day: one scone | 1 a day | D here | A3 |
|  |  | Cheer | Reads the Leaves | 🫖 | Stop pages mark the act that would add most to your lowest unfilled bar | flag | F | A5 |
| Northern Lights Sauna | spring | Repairs | Split Birch for the Stove | 🪵 | Rest acts at the Northern Lights Sauna give 1 more energy at night | +1 | P `from=` `dp=night` | F22 |
|  |  | Larder | Rye Porridge After the Plunge | 🥣 | Dishes eaten at the Northern Lights Sauna while it snows give 2% more energy | +2% | P `from=` `we=snow` | F07 |
|  |  | Cheer | The Cold Plunge | 🧊 | Once a day, after a rest act at the Northern Lights Sauna your next walk costs 1 less energy | 1 a day | D here | A1 |

## 4. The Sunsprinkle Isles (CB): 13 stops, 39 perks

Sea breeze and coral sand; sweet potato, pigeon peas, plantain, lime.

Stop types to set in Admin > Places:

| Stop | Type | Why |
|---|---|---|
| The Sunsprinkle Isles Market | market | The town |
| Shoreford | ferry | Island landing: the road from Maizehollow arrives here |
| Breezehollow | orchard | Island: lime and guava groves in the breeze |
| Palmknoll | inn | Crossroads: roads to the town, the coast, the wetland, the Galleon, the Maze and the Rainroot Reaches |
| Sandpipergate | tower | Coast: the lighthouse that is mostly decoration |
| Foamknoll | jetty | Coralteeth Reef: lines out along the planks |
| Saltgate | market | Coast: a salt-pan market |
| Lianacombe | spring | Rainforest: warm pools under the Greenmist Peaks |
| Canopybottom | shrine | Rainforest; under the Singing Waterfall |
| Heronholt | mill | Wetland: an old cane mill |
| Mireburrow | herb | Mangrove Murk: a herb croft on boardwalks |
| Driftwood Tavern | inn | Haven: coconut water, music and rest |
| Turtle Nesting Beach | camp | Haven: a night watch with no fire, so the hatchlings find the sea |

| Stop | Type | Bar | Perk | Icon | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|---|
| The Sunsprinkle Isles Market | market | Repairs | Restitched Sailcloth Shade | ⛱️ | In the day part "day", fruit sells for 2% more at the Isles Market's stalls | +2% | P `from=` `dp=day` | F01 |
|  |  | Larder | Lime With Everything | 🍋 | Dishes with lime give 2% more energy | +2% | P `items=local:` lime | F07 |
|  |  | Cheer | Steel Pans on the Quay | 🥁 | Stalls on the Isles show whether a price is above or below the item's usual price | flag | F | A5 |
| Shoreford | ferry | Repairs | Caulked Dugout | 🛶 | Fast travel between Shoreford and any stop in Maizehollow costs 1% less, both ways | -1% | P `from=` / `to=` | F18 |
|  |  | Larder | Fried Plantain at the Landing | 🍌 | First visit to Shoreford each day: one plantain | 1 a day | D here | A3 |
|  |  | Cheer | Post by Canoe | 📮 | A tiny canoe with a mailbag crosses the foot of your Today page each morning (looks only) | flag | F | A6 |
| Breezehollow | orchard | Repairs | Windbreak Replanted | 🎋 | Pests are 2% less likely on lime and guava | -2% | P `items=local:` lime, guava | F17 |
|  |  | Larder | Guava Jelly Cooling | 🍈 | Guava harvests: 1% chance of one extra | +1% | P `items=local:` guava | F10 |
|  |  | Cheer | Hammock Between Two Limes | 🏝️ | A hammock hangs in a corner of your garden (looks only) | flag | F | A6 |
| Palmknoll | inn | Repairs | Rethatched Palm Roof | 🌴 | Healing from rest acts at Palmknoll is 2% stronger in heat (siesta) | +2% | P `from=` `we=heat` | F09 |
|  |  | Larder | Peas and No Hurry | 🍲 | Dishes with pigeon peas cook 2% faster | -2% | P `items=local:` pigeon-pea | F06 |
|  |  | Cheer | Conch Telegraph | 🐚 | The world map puts a shell on any Isles stop where one of your bars is at 80 or more | flag | F | A5 |
| Sandpipergate | tower | Repairs | Lighthouse Lamp Relit | 💡 | Walks that end at Sandpipergate at night take 2% less time | -2% | P `to=` `dp=night` | F05 |
|  |  | Larder | Rock Pools at First Light | 🦀 | Gathering on walks from Sandpipergate at dawn: 1% chance of one extra | +1% | P `from=` `dp=dawn` | F11 |
|  |  | Cheer | Sandpipers in the Margins | 🐦 | Sandpiper footprints trail across your passport pages (looks only) | flag | F | A6 |
| Foamknoll | jetty | Repairs | Replanked to the End | 🎣 | Once a day, the first wear on your fishing rod is skipped | 1 a day | D | A2 |
|  |  | Larder | Reef Fish on the Coals | 🐠 | Fish cost 2% less at Foamknoll's stall | -2% | P `from=` | F02 |
|  |  | Cheer | Sundowner on the Planks | 🍹 | Chats with Foamknoll's folk at dusk: 2% chance of +1 friendship | +2% | P `from=` `dp=dusk` | F14 |
| Saltgate | market | Repairs | Scoured Salt Scales | 🧂 | Saltgate's stall pays 2% more for fish | +2% | P `from=` | F01 |
|  |  | Larder | Baked in a Salt Crust | 🍠 | Sweet potato harvests: 1% more chance of a seed back | +1% | P `items=local:` sweet-potato | F13 |
|  |  | Cheer | Dominoes Under the Sea Grape | 🎲 | Once a day, a lost game at Saltgate pays its coins as if you had won | 1 a day | D here | A2 |
| Lianacombe | spring | Repairs | Retied Liana Bridge | 🌉 | Walks that start at Lianacombe take 2% less time in rain | -2% | P `from=` `we=rain` | F05 |
|  |  | Larder | Soursop Leaf Tea | 🍵 | Boosts from dishes with soursop last 2% longer | +2% | P `items=local:` soursop | F08 |
|  |  | Cheer | Tree Frogs at Bath Time | 🐸 | Rest acts at Lianacombe give 1 more energy while it rains | +1 | P `from=` `we=rain` | F22 |
| Canopybottom | shrine | Repairs | Unblocked Spring Runnel | 🪷 | Watering lasts 2% longer on plantain and breadfruit | +2% | P `items=local:` plantain, breadfruit | F12 |
|  |  | Larder | First Fruits on the Ledge | 🍃 | 2% more garden XP from breadfruit | +2% | P `items=local:` breadfruit | F04 |
|  |  | Cheer | The Waterfall Carries a Tune | 🎐 | The route menu shows whether a wonder on the Isles has something new for you this game day | flag | F | A5 |
| Heronholt | mill | Repairs | Trued Cane Rollers | ⚙️ | Dishes with pineapple or grapefruit cook 2% faster | -2% | P `items=local:` pineapple, grapefruit | F06 |
|  |  | Larder | Cane Juice by the Cup | 🧃 | First visit to Heronholt each day: one cup of cane juice | 1 a day | D here | A3 |
|  |  | Cheer | Heron on One Leg | 🦩 | On rainy days a heron stands beside your garden (looks only) | flag | F | A6 |
| Mireburrow | herb | Repairs | Root-Lantern Rehung | 🔦 | +1 torch step in the Mangrove Root Maze | +1 step | P `region=CB` (that delve) | F21 |
|  |  | Larder | Beds Above the Tide | 🌿 | Pests are 2% less likely on sweet potato and pigeon peas | -2% | P `items=local:` sweet-potato, pigeon-pea | F17 |
|  |  | Cheer | Smudge Pot | 🦟 | The Today page warns you when pests are likelier than usual this game day | flag | F | A5 |
| Driftwood Tavern | inn | Repairs | Bar Top Planed Smooth | 🪑 | Checks at the Driftwood Tavern are 2% kinder from dusk on, while the band plays | +2% | P `from=` `dp=dusk,night` | F16 |
|  |  | Larder | Lime and Something | 🥤 | First rest act at the Driftwood Tavern each day: one lime cooler | 1 a day | D here | A3 |
|  |  | Cheer | Knows the Chorus | 🎵 | A line of music notes drifts over your Today page on festival days (looks only) | flag | F | A6 |
| Turtle Nesting Beach | camp | Repairs | Driftwood Fence Mended | 🚧 | Once a day, the first act you do at Turtle Nesting Beach at night costs 1 less energy | 1 a day | D here | A1 |
|  |  | Larder | Pineapple in the Cool Sand | 🍍 | Pineapple harvests: 1% chance of one extra | +1% | P `items=local:` pineapple | F10 |
|  |  | Cheer | Walked One to the Sea | 🐢 | A baby turtle crosses your garden path now and then (looks only) | flag | F | A6 |

## 5. The Rainroot Reaches (SA): 13 stops, 39 perks

Two worlds, highland and rainforest; quinoa, cassava, peanut.

Stop types to set in Admin > Places:

| Stop | Type | Why |
|---|---|---|
| The Rainroot Reaches Market | market | The town |
| Barleyglen | inn | Border inn: the road from Maizehollow arrives here |
| Windwell | mill | Pampas Breeze: a wind pump and a mill |
| Thistlebottom | shrine | Mountain; the road to the Sky City Ruins starts here, and the road from the Isles arrives |
| Flintburrow | tower | Mountain: the watch on Condor's Crag |
| Highcove | spring | Mountain: stone tubs above the river |
| Stoneden | camp | Mountain: a drovers' camp |
| Figknoll | orchard | Rainforest: passion fruit, cherimoya and lucuma |
| Frondstead | herb | Rainforest: yerba mate drying lofts |
| Canopyglen | jetty | Rainforest river: dugouts and lines |
| Scorchby | workshop | Saltglass Flats: glass-blowers |
| Duneford | market | Desert: where the salt caravans load |
| Gaucho Gnome Ranch | camp | Haven: rest, ride and a fire |

| Stop | Type | Bar | Perk | Icon | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|---|
| The Rainroot Reaches Market | market | Repairs | Rehung Weavers' Rails | 🧶 | Fast travel that starts at the Rainroot Reaches Market costs 1% less | -1% | P `from=` | F18 |
|  |  | Larder | Peanuts in a Paper Cone | 🥜 | First visit to the Rainroot Reaches Market each day: one cone of peanuts | 1 a day | D here | A3 |
|  |  | Cheer | Reads the Weave | 🧵 | Your satchel shows which region each crop is native to | flag | F | A5 |
| Barleyglen | inn | Repairs | Glazed Against the Pampas Wind | 🪟 | Healing from rest acts at Barleyglen is 2% stronger on windy days | +2% | P `from=` `we=wind` | F09 |
|  |  | Larder | Empanada for the Pocket | 🥟 | First walk that starts at Barleyglen each day: one empanada in your satchel | 1 a day | D here | A3 |
|  |  | Cheer | Passed the Gourd | 🧉 | Gifts of yerba mate: 2% chance of +1 friendship | +2% | P `items=local:` yerba-mate | F14 |
| Windwell | mill | Repairs | Wind Pump Regreased | 🛢️ | Watering lasts 2% longer on quinoa and peanut on windy days | +2% | P `items=local:` quinoa, peanut `we=wind` | F12 |
|  |  | Larder | Rinsed Twice | 🌾 | Dishes with quinoa cook 2% faster | -2% | P `items=local:` quinoa | F06 |
|  |  | Cheer | Tin Windmill on the Fence | 🎏 | A small tin windmill spins on your garden fence, faster on windy days (looks only) | flag | F | A6 |
| Thistlebottom | shrine | Repairs | Refitted Stone Stair | 🧗 | 2% better chance to spot hidden places on walks that end at Thistlebottom | +2% | P `to=` | F19 |
|  |  | Larder | Terrace Offering | 🪴 | Quinoa harvests: 1% more chance of a seed back | +1% | P `items=local:` quinoa | F13 |
|  |  | Cheer | Head in the Clouds | ☁️ | Once a day, a failed Lore check at the Sky City Ruins is rolled again | 1 a day | D here | A2 |
| Flintburrow | tower | Repairs | Re-roped Crag Path | 🪢 | +1 max health in fights on the road to Condor's Crag | +1 | P `from=` (that road) | F20 |
|  |  | Larder | Watcher's Trail Mix | 🎒 | Once a day, the first walk of 4 sections or more that starts at Flintburrow costs 1 less energy | 1 a day | D here | A1 |
|  |  | Cheer | Sized Up the Condor | 🦅 | The route menu shows a lair boss's level before you set out | flag | F | A5 |
| Highcove | spring | Repairs | Recut Stone Tubs | 🛁 | Rest acts at Highcove give 1 more energy at dawn | +1 | P `from=` `dp=dawn` | F22 |
|  |  | Larder | Cooling in the Stream | 🍊 | Naranjilla and tamarillo harvests: 1% chance of one extra | +1% | P `items=local:` naranjilla, tamarillo | F10 |
|  |  | Cheer | The Dolphins Said So | 🐬 | Fast travel that ends at Highcove: 1% chance of finding a seed | +1% | P `to=` | F23 |
| Stoneden | camp | Repairs | Windbreak of Stacked Slate | 🧱 | Resting on mountain walks that start at Stoneden heals 2% more at night | +2% | P `from=` `dp=night` | F09 |
|  |  | Larder | Cassava in the Embers | 🥘 | Dishes with cassava give 2% more energy | +2% | P `items=local:` cassava | F07 |
|  |  | Cheer | Condor Country | 🪶 | A condor's shadow glides across your Today page on sunny days (looks only) | flag | F | A6 |
| Figknoll | orchard | Repairs | Lashed Bamboo Ladders | 🎍 | Pests are 2% less likely on passion fruit and cherimoya | -2% | P `items=local:` passion-fruit, cherimoya | F17 |
|  |  | Larder | One for the Picker | 🧺 | First visit to Figknoll each day: one passion fruit | 1 a day | D here | A3 |
|  |  | Cheer | Parrot on the Ladder | 🦜 | A green parrot perches on your garden gate while any fruit is ripe (looks only) | flag | F | A6 |
| Frondstead | herb | Repairs | Drying Loft Reroofed | 🏚️ | Watering lasts 2% longer on yerba mate and feijoa | +2% | P `items=local:` yerba-mate, feijoa | F12 |
|  |  | Larder | Topped Up, Never Stirred | 🍶 | Boosts from dishes or drinks with yerba mate last 2% longer | +2% | P `items=local:` yerba-mate | F08 |
|  |  | Cheer | Nothing to Do but Talk | 🐒 | Chats with Frondstead's folk while it rains: 2% chance of +1 friendship | +2% | P `from=` `we=rain` | F14 |
| Canopyglen | jetty | Repairs | Patched Dugouts | 🚣 | Resting on walks that end at Canopyglen heals 2% more in rain or storm | +2% | P `to=` `we=rain,storm` | F09 |
|  |  | Larder | Wrapped in Leaves | 🐡 | Gathering with a rod on walks from Canopyglen: 1% chance of one extra | +1% | P `from=` tool rod | F11 |
|  |  | Cheer | Otters Ride Along | 🦦 | A river otter pops up beside the route map on rainforest walks in the Reaches (looks only) | flag | F | A6 |
| Scorchby | workshop | Repairs | Reblown Lamp Glass | 🪔 | +1 torch step in the Anaconda Hollows | +1 step | P `region=SA` (that delve) | F21 |
|  |  | Larder | Grown Under Glass | 🔆 | 2% more garden XP from peanut | +2% | P `items=local:` peanut | F04 |
|  |  | Cheer | Seen Through Clear Glass | 🔍 | Stop pages put a small dot on acts you have never done | flag | F | A5 |
| Duneford | market | Repairs | Salt Blocks Squared | 📦 | Duneford's stall pays 2% more at dawn, when the caravans load | +2% | P `from=` `dp=dawn` | F01 |
|  |  | Larder | Caravan Sacks | 🛍️ | Peanuts and quinoa cost 2% less at Duneford's stall | -2% | P `from=` | F02 |
|  |  | Cheer | Sky Underfoot | 🪩 | After rain, the sky is mirrored along the foot of your Today page (looks only) | flag | F | A6 |
| Gaucho Gnome Ranch | camp | Repairs | Saddle on the Rail | 🐴 | Once a day, a walk from the Gaucho Gnome Ranch to Windwell is ridden and costs no energy | 1 a day | D here | A1 |
|  |  | Larder | Saved for Sowing | 🪹 | Peanut harvests: 1% more chance of a seed back | +1% | P `items=local:` peanut | F13 |
|  |  | Cheer | Guitar on the Porch | 🎸 | Contests at the Gaucho Gnome Ranch are 2% kinder | +2% | P `from=` kind contest | F16 |

## 6. Counts

| Region | Stops | Perks | W | P | D | F | World-family units used |
|---|---|---|---|---|---|---|---|
| Maizehollow | 11 | 33 | 0 | 19 | 5 | 9 | 0 |
| Mistmoor | 12 | 36 | 0 | 22 | 5 | 9 | 0 |
| The Sunsprinkle Isles | 13 | 39 | 0 | 23 | 6 | 10 | 0 |
| The Rainroot Reaches | 13 | 39 | 0 | 25 | 6 | 8 | 0 |
| **All four** | **49** | **147** | **0** | **89** | **22** | **36** | **0** |

With Larkbrook and Windbottom (written in the Maplewold set: 6 perks, 4 of them world perks already counted in the Maplewold column) Maizehollow has 12 stops and Mistmoor 13.

Perks per family (all four regions): A1 6, A2 4, A3 11, A4 1, A5 16, A6 20, F01 6, F02 4, F03 1, F04 3, F05 6, F06 7, F07 6, F08 4, F09 6, F10 7, F11 4, F12 6, F13 4, F14 3, F15 1, F16 2, F17 4, F18 4, F19 1, F20 2, F21 3, F22 4, F23 1.

Stop types used: camp 5, ferry 2, herb 4, inn 5, jetty 3, market 7, mill 4, orchard 4, shrine 4, spring 4, tower 4, workshop 3.

## 7. Checks

Script check (Python, run on this file's data and on `proposal-stop-perks.md`): the 54 hand-written and 36 template names and effects were read from sections 5 and 6 (90 found). All 147 names and all 147 effects here are different from each other and from those 90 (compared in lower case, punctuation ignored). The effects were also compared with the stop name taken out, so none is a type template with a stop filled in and no two differ only by the stop's name. Also checked: 3 perks per stop, one per bar; no family twice at a stop; no crop twice in a family within a region; every P size is 1 or 2; at most one A5 and one A6 per stop; every share in section 1 is 0 and no perk is W.

Not unique by design: some place perks share a shape with a template and differ by a condition (a rest act at one stop at night, at another at dawn). Each is still its own effect text and its own stop.

## 8. Problems hit (5)

1. **Every world share is 0**, so the world budget left cannot be shared out over 13 regions at all. If Josh wants a few world perks per region, the caps must go up or the budget must be given to chosen regions by hand, not divided.
2. **"Local crops" are per region, not per stop** (`stop_local_crops()` reads `plant_regions`). A crop-scoped place perk therefore works wherever that crop grows, which is close to a small world perk. I named one or two crops per perk and kept one perk per family per crop; the build needs a named-crop form of `items=local:`.
3. **Stop types and landscapes.** `stops.txt` lists which landscapes suit a type (no workshop on a coast, no tower on an island). Every type here suits its landscape or is an "any" type (market, inn, camp). The cost: 7 markets in 49 stops, no workshop on the Isles, and two inns on the Isles.
4. **Item names and UI facts are unchecked.** Gifts such as tortilla, scone, empanada, cane juice, lime cooler and nopal pad must be mapped to real item slugs (or swapped for a local staple crop). Each info flag must be checked against what the page already shows. The tide, moon, festival and bar-points data exist in code, but most flags and several daily triggers (rod wear, lost game pays, Lore re-roll at a wonder, ridden walk) need a NEW hook.
5. **`proposal-stop-perks.md` changed while this was written** (48 perks became 54, 84 names became 90, seed on fast travel went from 0 to 1 used); this file was re-run against the new text. It was not checked against the other region files being written at the same time, so a name may clash across files. Also Larkbrook and Windbottom keep world perks while every other stop of their regions has none.
