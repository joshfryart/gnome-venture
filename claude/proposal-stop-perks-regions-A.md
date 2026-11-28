# PROPOSAL: Hand-written stop perks, regions A (Maizehollow, Mistmoor, the Sunsprinkle Isles, the Rainroot Reaches)

Status: proposal only, no game code changed. 2026-11-27.
Impact pass 2026-11-27 (`proposal-perk-impact.md`): 90 perk rows of this file have a wider trigger or a bigger size (`RAISES` in `tools_audit_stop_perks_fixes.py`). The perk tables are current; prose notes below may still describe a perk's first, narrower scope.
Follows `proposal-stop-perks.md` (rules, families, caps, section 5 format) and `PROPOSAL-HOLLOW-MASTER.md` section 7 and section 14 ruling 7 (a hand-written set per region). Stops are every town, village and haven of the four regions in `claude/route-list.md`. Wonders, delves and lairs are not stops.

Every stop below has its own three perks, one per bar. **49 stops, 147 perks.** The two border villages already written in the Maplewold set (Larkbrook in Maizehollow, Windbottom in Mistmoor) keep those perks and are not repeated.

## 1. World budget: this file's share per family

Share = (cap minus what the Maplewold set uses) / 13 other regions, rounded down. The Maplewold column is the "NA world" figure of `proposal-stop-perks.md` section 4 and 4.1 (18 stops, 54 perks, with Cattailmere and Granitegate).

| Family | Effect | Cap | Maplewold uses | Left | Share per region (left / 13, rounded down) | So in this file |
|---|---|---|---|---|---|---|
| F01 | sell | 5 | 3 | 2 | **0** | place-scoped only |
| F02 | buy | 5 | 1 | 4 | **0** | place-scoped only |
| F03 | XP | 5 | 3 | 2 | **0** | place-scoped only |
| F04 | garden XP | 5 | 1 | 4 | **0** | place-scoped only |
| F05 | walk time | 6 | 3 | 3 | **0** | place-scoped only |
| F06 | pot time | 6 | 4 | 2 | **0** | place-scoped only |
| F07 | dish energy | 5 | 2 | 3 | **0** | place-scoped only |
| F08 | boost length | 8 | 4 | 4 | **0** | place-scoped only |
| F09 | healing | 8 | 4 | 4 | **0** | place-scoped only |
| F10 | harvest extra | 4 | 4 | 0 | **0** | place-scoped only |
| F11 | gather extra | 4 | 2 | 2 | **0** | place-scoped only |
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
- Size: 1% or 2%, +1 energy, +1 torch step, +1 max health. Nothing above 2%. Impact pass 2026-11-27: every % family may be 2% a perk, and the narrow place perks on the veto list of `proposal-perk-impact.md` are at 3%.
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
| Maizehollow Market | market | Repairs | Relaid Cobbles | 🧱 | Fast travel that starts in Maizehollow's grassland and rainforest zones costs 2% less | -2% | P `region=CA` | F18 |
|  |  | Larder | Thirteen Ears to the Dozen | 🌽 | Stalls in Maizehollow's grassland and rainforest zones pay 2% more for what you sell | +2% | P `region=CA` | F01 |
|  |  | Cheer | Brass on the Bandstand | 🎺 | The Today page names any Maizehollow stop that has a festival on | flag | F | A5 |
| Poppynook | mill | Repairs | Dressed Grindstone | 🪨 | Dishes with maize or black bean in them cook 2% faster | -2% | P `items=local:` corn, black-bean | F06 |
|  |  | Larder | First Off the Griddle | 🫓 | First visit to Poppynook each day: one piece of cornbread (`cornbread`) | 1 a day | D here | A3 |
|  |  | Cheer | Poppies on the Sill | 🌺 | A pot of red poppies sits by your garden gate (looks only) | flag | F | A6 |
| Meadowmere | inn | Repairs | Restrung Hammocks | 🪢 | Rest acts at Meadowmere give 1 more energy in spring and summer | +1 | P `from=` `se=spring,summer` | F22 |
|  |  | Larder | Beans in the Pot Since Tuesday | 🫘 | Dishes with black bean or maize give 2% more energy | +2% | P `items=local:` black-bean, corn | F07 |
|  |  | Cheer | Five Roads' Worth of Gossip | 🧭 | In Meadowmere the route menu shows the weather at the far end of each road | flag | F | A5 |
| Jadedell | shrine | Repairs | Reset Temple Steps | 🪜 | Walks in Maizehollow's grassland and rainforest zones take 2% less time | -2% | P `region=CA` | F05 |
|  |  | Larder | Seed Left on the Altar | 🌱 | Tomatillo, maize and black bean harvests: 2% more chance of a seed back | +2% | P `items=local:` tomatillo, corn, black-bean | F13 |
|  |  | Cheer | Jade in the Ink | 🟢 | Your Maizehollow passport stamps print in jade green (looks only) | flag | F | A6 |
| Frondthorpe | orchard | Repairs | Shored-Up Terraces | 🪵 | Watering lasts 2% longer on avocado, papaya, maize, black bean and amaranth | +2% | P `items=local:` avocado, papaya, corn, black-bean, amaranth | F12 |
|  |  | Larder | Two From One Stone | 🥑 | Once a day, your first avocado or papaya harvest gives one extra of that crop | 1 a day | D | A3 |
|  |  | Cheer | Paw Prints in the Mud | 🐆 | After rain, jaguar paw prints cross your rainforest route maps (looks only) | flag | F | A6 |
| Orchiddell | herb | Repairs | Retied Orchid Stakes | 🧵 | Pests are 2% less likely on chayote, amaranth, maize, black bean and chili pepper | -2% | P `items=local:` chayote, amaranth, corn, black-bean, chili-pepper | F17 |
|  |  | Larder | Chayote Up the Trellis | 🫛 | Chayote, maize, tomatillo, amaranth, vanilla and cardamom harvests: 3% chance of one extra | +3% | P `items=local:` chayote, corn, tomatillo, amaranth, vanilla, cardamom | F10 |
|  |  | Cheer | Hummingbird at the Window | 🦋 | A hummingbird hovers over your garden while something is in flower (looks only) | flag | F | A6 |
| Saffroncrest | tower | Repairs | Polished Signal Mirror | 🪞 | On sunny days, walks that start at Saffroncrest take 3% less time | -3% | P `from=` `we=sun` | F05 |
|  |  | Larder | Nopal Off the Parapet | 🌵 | First visit to Saffroncrest each day: one nopal pad (`nopal`) | 1 a day | D here | A3 |
|  |  | Cheer | Counts the Shadows | 🌅 | The route menu shows the day part you will arrive in | flag | F | A5 |
| Scorchburrow | camp | Repairs | Mended Water Jars | 🏺 | Watering lasts 2% longer on chili pepper, tomatillo, chayote, prickly pear cactus and mamey sapote | +2% | P `items=local:` chili-pepper, tomatillo, chayote, nopal, mamey | F12 |
|  |  | Larder | Supper After Sundown | 🌮 | Dishes eaten in Maizehollow's grassland and desert zones give 2% more energy | +2% | P `region=CA` | F07 |
|  |  | Cheer | A Wish per Shooting Star | 🌠 | First rest act at Scorchburrow each day: 2 coins turn up in the sand | 2 coins, 1 a day | D here | A4 |
| Stonethorpe | spring | Repairs | Relined Ash Pools | ♨️ | Rest acts and trail rests in Maizehollow's grassland and mountain zones heal 2% more | +2% | P `region=CA` | F09 |
|  |  | Larder | Ash for the Beds | 🌋 | Black bean, maize and chili pepper give 2% more garden XP | +2% | P `items=local:` black-bean, corn, chili-pepper | F04 |
|  |  | Cheer | Steam on Cold Mornings | 🌫️ | A wisp of steam curls from your cooking pot while it is busy (looks only) | flag | F | A6 |
| Flintcove | workshop | Repairs | Knapped a Fresh Edge | 🔪 | Once a day, the first wear on your rock pick anywhere in Maizehollow is skipped | 1 a day | D here | A2 |
|  |  | Larder | Comal Hammered Flat | 🍳 | Dishes with tomatillo or chili pepper in them cook 2% faster | -2% | P `items=local:` tomatillo, chili-pepper | F06 |
|  |  | Cheer | Sees Itself in Obsidian | 🖤 | Stop pages show how many points each act will add to a bar before you do it | flag | F | A5 |
| Market of a Thousand Chilies | market | Repairs | Repainted Stall Numbers | 🪧 | Stalls in Maizehollow's grassland and rainforest zones charge 2% less | -2% | P `region=CA` | F02 |
|  |  | Larder | The Thousand-and-First | 🌶️ | Chili pepper, black bean, prickly pear cactus, mamey sapote and cacao harvests: 3% chance of one extra | +3% | P `items=local:` chili-pepper, black-bean, nopal, mamey, cacao | F10 |
|  |  | Cheer | Tried the Hot One | 🥵 | Dishes with chili pepper or maize give boosts that last 2% longer | +2% | P `items=local:` chili-pepper, corn | F08 |

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
| Mistmoor Market | market | Repairs | Patched Awnings | ☂️ | Stalls in Mistmoor's grassland and coast zones pay 2% more for what you sell | +2% | P `region=NWE` | F01 |
|  |  | Larder | Leek by the Yard | 🧅 | Stalls in Mistmoor's grassland and forest zones charge 2% less | -2% | P `region=NWE` | F02 |
|  |  | Cheer | Town Crier's Second Wind | 📯 | The Today page lists the Mistmoor stops you have not visited this game day | flag | F | A5 |
| Windburrow | mill | Repairs | Reset Sails | 🌬️ | Dishes with rye or barley in them cook 2% faster | -2% | P `items=local:` rye, barley | F06 |
|  |  | Larder | Baker's Peel | 🍞 | Once a day, the first bread or bake you cook with rye comes out with one extra | 1 a day | D | A3 |
|  |  | Cheer | Kite Day | 🪁 | A small kite flies over your garden on windy days (looks only) | flag | F | A6 |
| Larkden | inn | Repairs | Trimmed Wicks | 🕯️ | Rest acts and trail rests in Mistmoor's forest and coast zones heal 2% more | +2% | P `region=NWE` | F09 |
|  |  | Larder | Sprouts Done Properly | 🥬 | Dishes with brussels sprouts or rye give 2% more energy | +2% | P `items=local:` brussels-sprouts, rye | F07 |
|  |  | Cheer | Fiddle in the Corner | 🎻 | Acts at stops in Mistmoor's forest and coast zones give 2% more XP | +2% | P `region=NWE` | F03 |
| Hollowknoll | shrine | Repairs | Righted Waymarker | 🪦 | Walks in Mistmoor's grassland and coast zones take 2% less time | -2% | P `region=NWE` | F05 |
|  |  | Larder | One for the Stones | 🍄 | Gathering in Mistmoor's grassland and forest zones: 2% chance of one extra | +2% | P `region=NWE` | F11 |
|  |  | Cheer | The Stones Hum Back | 🎶 | At dusk a faint ring of standing stones shows on the horizon of your Today page (looks only) | flag | F | A6 |
| Fernden | camp | Repairs | Dry Kindling Under Cover | 🪓 | Once a day, the first check act you do at Fernden costs 1 less energy | 1 a day | D here | A1 |
|  |  | Larder | Hedgerow Pudding | 🫐 | Lingonberry, rye, leek, blackcurrant and kohlrabi harvests: 2% chance of one extra | +2% | P `items=local:` lingonberry, rye, leek, blackcurrant, kohlrabi | F10 |
|  |  | Cheer | Ring of Toadstools | 🧚 | After rain, a ring of small mushrooms shows in a corner of your garden (looks only) | flag | F | A6 |
| Hazelmere | orchard | Repairs | Stile Over the Hedge | 🚪 | Once a day, the first walk that ends at Hazelmere costs 1 less energy | 1 a day | D here | A1 |
|  |  | Larder | Jam Pan Scoured | 🫙 | Dishes with rhubarb, blackcurrant or leek in them cook 2% faster | -2% | P `items=local:` rhubarb, blackcurrant, leek | F06 |
|  |  | Cheer | Conker Champion | 🌰 | Acts at stops in Mistmoor's grassland and forest zones pay 2% more coins | +2% | P `region=NWE` | F15 |
| Spraywell | jetty | Repairs | Storm Lantern Rehung | 🏮 | +1 torch step in the Sea-cave Smugglers' Run | +1 step | P `region=NWE` (that delve) | F21 |
|  |  | Larder | Smoked Over Alder | 🐟 | Fish sell for 3% more at Spraywell's stall | +3% | P `from=` | F01 |
|  |  | Cheer | Reads the Tide Table | 🌊 | The Today page shows the hour of the next low tide | flag | F | A5 |
| Brinehollow | ferry | Repairs | Greased Winch | ⛓️ | Fast travel that starts in Mistmoor's forest and coast zones costs 2% less | -2% | P `region=NWE` | F18 |
|  |  | Larder | Pickle Crock Under the Bench | 🥒 | Dishes with kohlrabi, rye or barley give boosts that last 2% longer | +2% | P `items=local:` kohlrabi, rye, barley | F08 |
|  |  | Cheer | Seal Off the Slipway | 🦭 | A seal's head bobs at the edge of your Today page when you wake on a coast (looks only) | flag | F | A6 |
| Froststead | workshop | Repairs | Waxed Runners | 🛷 | Walks that start at Froststead take 3% less time in snow or frost | -3% | P `from=` `we=snow,frost` | F05 |
|  |  | Larder | Sweeter After Frost | ❄️ | Brussels sprouts, barley, rhubarb, asparagus, cloudberry and gooseberry harvests: 2% chance of one extra | +2% | P `items=local:` brussels-sprouts, barley, rhubarb, asparagus, cloudberry, gooseberry | F10 |
|  |  | Cheer | Knitted While You Waited | 🧤 | Your gnome wears mittens in its portrait while it snows (looks only) | flag | F | A6 |
| Sleetford | tower | Repairs | Windbreak Rebuilt | 🛡️ | +1 max health in fights on Mistmoor's tundra roads | +1 | P `region=NWE` `land=tundra` | F20 |
|  |  | Larder | Berries Under the Snow | 🍒 | Gathering at Sleetford itself: 3% chance of one extra | +3% | P `from=` (gather here) | F11 |
|  |  | Cheer | Cartographer's Corrections | 🗺️ | The world map draws the Mistmoor roads you have walked in a darker line | flag | F | A5 |
| Thatchtop Tearoom | herb | Repairs | Reglazed Cold Frame | 🪴 | Watering lasts 2% longer on rhubarb, asparagus, rye, barley and leek | +2% | P `items=local:` rhubarb, asparagus, rye, barley, leek | F12 |
|  |  | Larder | Second Cup, Same Pot | 🫖 | First visit to the Thatchtop Tearoom each day: one cup of mint tea (`mint-tea`) | 1 a day | D here | A3 |
|  |  | Cheer | Reads the Leaves | 🫖 | Stop pages mark the act that would add most to your lowest unfilled bar | flag | F | A5 |
| Northern Lights Sauna | spring | Repairs | Split Birch for the Stove | 🪵 | Rest acts at the Northern Lights Sauna give 1 more energy outside summer | +1 | P `from=` `se=autumn,winter,spring` | F22 |
|  |  | Larder | Rye Porridge After the Plunge | 🥣 | Dishes eaten in Mistmoor's forest and tundra zones give 2% more energy | +2% | P `region=NWE` | F07 |
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
| The Sunsprinkle Isles Market | market | Repairs | Restitched Sailcloth Shade | ⛱️ | Stalls in the Sunsprinkle Isles' island and coast zones pay 2% more for what you sell | +2% | P `region=CB` | F01 |
|  |  | Larder | Lime With Everything | 🍋 | Dishes with lime or sweet potato give 2% more energy | +2% | P `items=local:` lime, sweet-potato | F07 |
|  |  | Cheer | Steel Pans on the Quay | 🥁 | Stalls on the Isles show whether a price is above or below the item's usual price | flag | F | A5 |
| Shoreford | ferry | Repairs | Caulked Dugout | 🛶 | Fast travel that starts in the Sunsprinkle Isles' island and coast zones costs 2% less | -2% | P `region=CB` | F18 |
|  |  | Larder | Fried Plantain at the Landing | 🍌 | First visit to Shoreford each day: one plantain (`plantain`) | 1 a day | D here | A3 |
|  |  | Cheer | Post by Canoe | 📮 | A tiny canoe with a mailbag crosses the foot of your Today page each morning (looks only) | flag | F | A6 |
| Breezehollow | orchard | Repairs | Windbreak Replanted | 🎋 | Pests are 2% less likely on lime, guava, plantain, soursop and grapefruit | -2% | P `items=local:` lime, guava, plantain, soursop, grapefruit | F17 |
|  |  | Larder | Guava Jelly Cooling | 🍈 | Guava, sweet potato, plantain, breadfruit and grapefruit harvests: 2% chance of one extra | +2% | P `items=local:` guava, sweet-potato, plantain, breadfruit, grapefruit | F10 |
|  |  | Cheer | Hammock Between Two Limes | 🏝️ | A hammock hangs in a corner of your garden (looks only) | flag | F | A6 |
| Palmknoll | inn | Repairs | Rethatched Palm Roof | 🌴 | Rest acts and trail rests in the Sunsprinkle Isles' island and coast zones heal 2% more | +2% | P `region=CB` | F09 |
|  |  | Larder | Peas and No Hurry | 🍲 | Dishes with pigeon pea or plantain in them cook 2% faster | -2% | P `items=local:` pigeon-pea, plantain | F06 |
|  |  | Cheer | Conch Telegraph | 🐚 | The Today page shows the sea on the Isles as calm, choppy or rough, from the game day's wind | flag | F | A5 |
| Sandpipergate | tower | Repairs | Lighthouse Lamp Relit | 💡 | Walks in the Sunsprinkle Isles' island and coast zones take 2% less time | -2% | P `region=CB` | F05 |
|  |  | Larder | Rock Pools at First Light | 🦀 | Gathering in the Sunsprinkle Isles' island and coast zones: 2% chance of one extra | +2% | P `region=CB` | F11 |
|  |  | Cheer | Sandpipers in the Margins | 🐦 | Sandpiper footprints trail across your passport pages (looks only) | flag | F | A6 |
| Foamknoll | jetty | Repairs | Replanked to the End | 🎣 | Once a day, the first wear on your fishing rod is skipped | 1 a day | D | A2 |
|  |  | Larder | Reef Fish on the Coals | 🐠 | Stalls in the Sunsprinkle Isles' island and coast zones charge 2% less | -2% | P `region=CB` | F02 |
|  |  | Cheer | Sundowner on the Planks | 🍹 | Chats and gifts with folk in the Sunsprinkle Isles' island and coast zones: 2% chance of +1 friendship | +2% | P `region=CB` | F14 |
| Saltgate | market | Repairs | Scoured Salt Scales | 🧂 | Saltgate's stall pays 3% more for sea salt and shells (`sea-salt`, `spiral-shell`) | +3% | P `from=` | F01 |
|  |  | Larder | Baked in a Salt Crust | 🍠 | Sweet potato, pigeon pea and plantain harvests: 2% more chance of a seed back | +2% | P `items=local:` sweet-potato, pigeon-pea, plantain | F13 |
|  |  | Cheer | Dominoes Under the Sea Grape | 🎲 | A set of dominoes sits on a table in your garden, laid out in your last winning line (looks only) | flag | F | A6 |
| Lianacombe | spring | Repairs | Retied Liana Bridge | 🌉 | Walks that start at Lianacombe take 3% less time in rain | -3% | P `from=` `we=rain` | F05 |
|  |  | Larder | Soursop Leaf Tea | 🍵 | Dishes with soursop, sweet potato or pigeon pea give boosts that last 2% longer | +2% | P `items=local:` soursop, sweet-potato, pigeon-pea | F08 |
|  |  | Cheer | Tree Frogs at Bath Time | 🐸 | Rest acts at Lianacombe give 1 more energy under cloud, in rain, storm or fog | +1 | P `from=` `we=cloud,rain,storm,fog` | F22 |
| Canopybottom | shrine | Repairs | Unblocked Spring Runnel | 🪷 | Watering lasts 2% longer on plantain, breadfruit, sweet potato and pigeon pea | +2% | P `items=local:` plantain, breadfruit, sweet-potato, pigeon-pea | F12 |
|  |  | Larder | First Fruits on the Ledge | 🍃 | Breadfruit, sweet potato, pigeon pea and plantain give 2% more garden XP | +2% | P `items=local:` breadfruit, sweet-potato, pigeon-pea, plantain | F04 |
|  |  | Cheer | The Waterfall Carries a Tune | 🎐 | The route menu shows whether a wonder on the Isles has something new for you this game day | flag | F | A5 |
| Heronholt | mill | Repairs | Trued Cane Rollers | ⚙️ | Dishes with pineapple, grapefruit or sweet potato in them cook 2% faster | -2% | P `items=local:` pineapple, grapefruit, sweet-potato | F06 |
|  |  | Larder | Cane Juice by the Cup | 🧃 | First visit to Heronholt each day: one jar of cane syrup (`cane-syrup`) | 1 a day | D here | A3 |
|  |  | Cheer | Heron on One Leg | 🦩 | On rainy days a heron stands beside your garden (looks only) | flag | F | A6 |
| Mireburrow | herb | Repairs | Root-Lantern Rehung | 🔦 | +1 torch step in the Mangrove Root Maze | +1 step | P `region=CB` (that delve) | F21 |
|  |  | Larder | Beds Above the Tide | 🌿 | Pests are 2% less likely on sweet potato, pigeon pea, breadfruit, pineapple, ackee and nutmeg | -2% | P `items=local:` sweet-potato, pigeon-pea, breadfruit, pineapple, ackee, nutmeg | F17 |
|  |  | Cheer | Smudge Pot | 🦟 | The Today page warns you when pests are likelier than usual this game day | flag | F | A5 |
| Driftwood Tavern | inn | Repairs | Bar Top Planed Smooth | 🪑 | Stop checks in the Sunsprinkle Isles' island and coast zones are 2% kinder | +2% | P `region=CB` | F16 |
|  |  | Larder | Lime and Something | 🥤 | First rest act at the Driftwood Tavern each day: one lime cordial (`lime-cordial`) | 1 a day | D here | A3 |
|  |  | Cheer | Knows the Chorus | 🎵 | A line of music notes drifts over your Today page on festival days (looks only) | flag | F | A6 |
| Turtle Nesting Beach | camp | Repairs | Driftwood Fence Mended | 🚧 | Once a day, the first tend or mend act you do at Turtle Nesting Beach costs 1 less energy | 1 a day | D here | A1 |
|  |  | Larder | Pineapple in the Cool Sand | 🍍 | Pineapple, pigeon pea, lime, soursop, ackee and nutmeg harvests: 2% chance of one extra | +2% | P `items=local:` pineapple, pigeon-pea, lime, soursop, ackee, nutmeg | F10 |
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
| The Rainroot Reaches Market | market | Repairs | Rehung Weavers' Rails | 🧶 | Fast travel that starts in the Rainroot Reaches' mountain and rainforest zones costs 2% less | -2% | P `region=SA` | F18 |
|  |  | Larder | Peanuts in a Paper Cone | 🥜 | First visit to the Rainroot Reaches Market each day: one handful of peanuts (`peanut`) | 1 a day | D here | A3 |
|  |  | Cheer | Reads the Weave | 🧵 | Your satchel shows which region each crop is native to | flag | F | A5 |
| Barleyglen | inn | Repairs | Glazed Against the Pampas Wind | 🪟 | Rest acts and trail rests in the Rainroot Reaches' grassland and rainforest zones heal 2% more | +2% | P `region=SA` | F09 |
|  |  | Larder | Flatbread for the Pocket | 🫓 | First walk that starts at Barleyglen each day: one mesquite flatbread (`mesquite-flatbread`) in your satchel | 1 a day | D here | A3 |
|  |  | Cheer | Passed the Gourd | 🧉 | Gifts of yerba mate, quinoa, cassava, peanut, passion fruit, cherimoya, feijoa, naranjilla, tree tomato, brazil nut or cashew: 3% chance of +1 friendship | +3% | P `items=local:` yerba-mate, quinoa, cassava, peanut, passion-fruit, cherimoya, feijoa, naranjilla, tamarillo, brazil-nut, cashew | F14 |
| Windwell | mill | Repairs | Wind Pump Regreased | 🛢️ | Watering lasts 3% longer on quinoa and peanut | +3% | P `items=local:` quinoa, peanut | F12 |
|  |  | Larder | Rinsed Twice | 🌾 | Dishes with quinoa cook 2% faster | -2% | P `items=local:` quinoa | F06 |
|  |  | Cheer | Tin Windmill on the Fence | 🎏 | A small tin windmill spins on your garden fence, faster on windy days (looks only) | flag | F | A6 |
| Thistlebottom | shrine | Repairs | Refitted Stone Stair | 🧗 | Walks in the Rainroot Reaches' mountain and rainforest zones: 2% better chance to spot hidden things | +2% | P `region=SA` | F19 |
|  |  | Larder | Terrace Offering | 🪴 | Quinoa and cassava harvests: 3% more chance of a seed back | +3% | P `items=local:` quinoa, cassava | F13 |
|  |  | Cheer | Head in the Clouds | ☁️ | Once a day, a failed Lore check at the Sky City Ruins or at any other wonder or delve of the Rainroot Reaches is rolled again | 1 a day | D here | A2 |
| Flintburrow | tower | Repairs | Re-roped Crag Path | 🪢 | +1 max health in fights on the road to Condor's Crag | +1 | P `from=` (that road) | F20 |
|  |  | Larder | Watcher's Trail Mix | 🎒 | Once a day, the first walk that starts at Flintburrow or runs along the road to Condor's Crag costs 1 less energy | 1 a day | D here | A1 |
|  |  | Cheer | Sized Up the Condor | 🦅 | The route menu shows a lair boss's level before you set out | flag | F | A5 |
| Highcove | spring | Repairs | Recut Stone Tubs | 🛁 | Rest acts at Highcove give 1 more energy before dusk | +1 | P `from=` `dp=dawn,day` | F22 |
|  |  | Larder | Cooling in the Stream | 🍊 | Naranjilla, tree tomato, quinoa and cassava harvests: 2% chance of one extra | +2% | P `items=local:` naranjilla, tamarillo, quinoa, cassava | F10 |
|  |  | Cheer | The Dolphins Said So | 🐬 | Fast travel that starts in the Rainroot Reaches' grassland and rainforest zones: 2% more chance to turn up a seed | +2% | P `region=SA` | F23 |
| Stoneden | camp | Repairs | Windbreak of Stacked Slate | 🧱 | Resting on mountain walks that start at Stoneden heals 3% more at night | +3% | P `from=` `dp=night` | F09 |
|  |  | Larder | Cassava in the Embers | 🥘 | Dishes with cassava give 2% more energy | +2% | P `items=local:` cassava | F07 |
|  |  | Cheer | Condor Country | 🪶 | A condor's shadow glides across your Today page on sunny days (looks only) | flag | F | A6 |
| Figknoll | orchard | Repairs | Lashed Bamboo Ladders | 🎍 | Pests are 2% less likely on passion fruit, cherimoya, quinoa and cassava | -2% | P `items=local:` passion-fruit, cherimoya, quinoa, cassava | F17 |
|  |  | Larder | One for the Picker | 🧺 | First visit to Figknoll each day: one passion fruit (`passion-fruit`) | 1 a day | D here | A3 |
|  |  | Cheer | Parrot on the Ladder | 🦜 | A green parrot perches on your garden gate while any fruit is ripe (looks only) | flag | F | A6 |
| Frondstead | herb | Repairs | Drying Loft Reroofed | 🏚️ | Watering lasts 2% longer on feijoa, yerba mate, cassava, passion fruit, cherimoya, naranjilla, tree tomato, brazil nut and cashew | +2% | P `items=local:` feijoa, yerba-mate, cassava, passion-fruit, cherimoya, naranjilla, tamarillo, brazil-nut, cashew | F12 |
|  |  | Larder | Topped Up, Never Stirred | 🍶 | Dishes with yerba mate or quinoa give boosts that last 2% longer | +2% | P `items=local:` yerba-mate, quinoa | F08 |
|  |  | Cheer | Nothing to Do but Talk | 🐒 | Chats and gifts with folk in the Rainroot Reaches' grassland and rainforest zones: 2% chance of +1 friendship | +2% | P `region=SA` | F14 |
| Canopyglen | jetty | Repairs | Patched Dugouts | 🚣 | Resting on walks that end at Canopyglen heals 3% more in rain or storm | +3% | P `to=` `we=rain,storm` | F09 |
|  |  | Larder | Wrapped in Leaves | 🐡 | Gathering in the Rainroot Reaches' grassland and rainforest zones: 2% chance of one extra | +2% | P `region=SA` | F11 |
|  |  | Cheer | Otters Ride Along | 🦦 | A river otter pops up beside the route map on rainforest walks in the Reaches (looks only) | flag | F | A6 |
| Scorchby | workshop | Repairs | Reblown Lamp Glass | 🪔 | +1 torch step in the Anaconda Hollows | +1 step | P `region=SA` (that delve) | F21 |
|  |  | Larder | Grown Under Glass | 🔆 | Peanut, quinoa and cassava give 2% more garden XP | +2% | P `items=local:` peanut, quinoa, cassava | F04 |
|  |  | Cheer | Seen Through Clear Glass | 🔍 | Stop pages put a small dot on acts you have never done | flag | F | A5 |
| Duneford | market | Repairs | Salt Blocks Squared | 📦 | Stalls in the Rainroot Reaches' grassland, mountain and desert zones pay 2% more for what you sell | +2% | P `region=SA` | F01 |
|  |  | Larder | Caravan Sacks | 🛍️ | Stalls in the Rainroot Reaches' grassland, mountain and desert zones charge 2% less | -2% | P `region=SA` | F02 |
|  |  | Cheer | Sky Underfoot | 🪩 | After rain, the sky is mirrored along the foot of your Today page (looks only) | flag | F | A6 |
| Gaucho Gnome Ranch | camp | Repairs | Saddle on the Rail | 🐴 | Once a day, the first walk on a grassland or desert road of the Rainroot Reaches costs 1 less energy (saddled at the Gaucho Gnome Ranch) | 1 a day | D here | A1 |
|  |  | Larder | Saved for Sowing | 🪹 | Peanut, passion fruit, cherimoya, feijoa, naranjilla, yerba mate, tree tomato, brazil nut and cashew harvests: 2% more chance of a seed back | +2% | P `items=local:` peanut, passion-fruit, cherimoya, feijoa, naranjilla, yerba-mate, tamarillo, brazil-nut, cashew | F13 |
|  |  | Cheer | Guitar on the Porch | 🎸 | Stop checks in the Rainroot Reaches' grassland and rainforest zones are 2% kinder | +2% | P `region=SA` | F16 |

## 6. Counts

| Region | Stops | Perks | W | P | D | F | World-family units used |
|---|---|---|---|---|---|---|---|
| Maizehollow | 11 | 33 | 0 | 19 | 5 | 9 | 0 |
| Mistmoor | 12 | 36 | 0 | 22 | 5 | 9 | 0 |
| The Sunsprinkle Isles | 13 | 39 | 0 | 23 | 5 | 11 | 0 |
| The Rainroot Reaches | 13 | 39 | 0 | 25 | 6 | 8 | 0 |
| **All four** | **49** | **147** | **0** | **89** | **21** | **37** | **0** |

With Larkbrook and Windbottom (written in the Maplewold set: 6 perks, 4 of them world perks already counted in the Maplewold column) Maizehollow has 12 stops and Mistmoor 13.

Perks per family (all four regions, after the audit of 2026-11-27): A1 6, A2 3, A3 11, A4 1, A5 15, A6 22, F01 6, F02 4, F03 1, F04 3, F05 6, F06 7, F07 6, F08 4, F09 6, F10 7, F11 4, F12 6, F13 4, F14 3, F15 1, F16 2, F17 4, F18 4, F19 1, F20 2, F21 3, F22 4, F23 1.

Stop types used: camp 5, ferry 2, herb 4, inn 5, jetty 3, market 7, mill 4, orchard 4, shrine 4, spring 4, tower 4, workshop 3.

## 7. Checks

Script check (Python, run on this file's data and on `proposal-stop-perks.md`): the 54 hand-written and 36 template names and effects were read from sections 5 and 6 (90 found). All 147 names and all 147 effects here are different from each other and from those 90 (compared in lower case, punctuation ignored). The effects were also compared with the stop name taken out, so none is a type template with a stop filled in and no two differ only by the stop's name. Also checked: 3 perks per stop, one per bar; no family twice at a stop; no crop twice in a family within a region; every P size is 1 or 2; at most one A5 and one A6 per stop; every share in section 1 is 0 and no perk is W.

Not unique by design: some place perks share a shape with a template and differ by a condition (a rest act at one stop at night, at another at dawn). Each is still its own effect text and its own stop.

**Cross-file audit, 2026-11-27** (`python3 claude/tools_audit_stop_perks.py`, all 540 perks of the four files): 0 errors after fixes. Changed here: fast travel can only land at a region town, so Brinehollow, Shoreford and Highcove now count from the stop (or to the town); Saltgate's lost-game-pays-as-won (a power spike) became a flag; the Gaucho Ranch ridden walk now saves 1 energy, not the whole walk; Saltgate's fish and Frondthorpe's unfound places clashed with other files and were rewritten; Flintcove's tool wear names the rock pick (Foamknoll owns rod wear); every gift names a real item slug.

## 8. Problems hit (5)

1. **Every world share is 0**, so the world budget left cannot be shared out over 13 regions at all. If Josh wants a few world perks per region, the caps must go up or the budget must be given to chosen regions by hand, not divided.
2. **"Local crops" are per region, not per stop** (`stop_local_crops()` reads `plant_regions`). A crop-scoped place perk therefore works wherever that crop grows, which is close to a small world perk. I named one or two crops per perk and kept one perk per family per crop; the build needs a named-crop form of `items=local:`.
3. **Stop types and landscapes.** `stops.txt` lists which landscapes suit a type (no workshop on a coast, no tower on an island). Every type here suits its landscape or is an "any" type (market, inn, camp). The cost: 7 markets in 49 stops, no workshop on the Isles, and two inns on the Isles.
4. **Item names and UI facts are unchecked.** Gifts such as tortilla, scone, empanada, cane juice, lime cooler and nopal pad must be mapped to real item slugs (or swapped for a local staple crop). Each info flag must be checked against what the page already shows. The tide, moon, festival and bar-points data exist in code, but most flags and several daily triggers (rod wear, lost game pays, Lore re-roll at a wonder, ridden walk) need a NEW hook.
5. **`proposal-stop-perks.md` changed while this was written** (48 perks became 54, 84 names became 90, seed on fast travel went from 0 to 1 used); this file was re-run against the new text. The other region files were being written at the same time: names and effects were compared once with `regions-B` and `regions-C` as they stood (no clash), and the final cross-file check of all region files was run on 2026-11-27 (see the audit note above). Also Larkbrook and Windbottom keep world perks while every other stop of their regions has none.
