# PROPOSAL: Stop perks, regions C (Thornacre Savanna, Spicepeak, Blossomreach, The Monsoon Tangle, The Coralscatter)

Status: proposal only, no game code changed. 2026-11-27.
Impact pass 2026-11-27 (`proposal-perk-impact.md`): 107 perk rows of this file have a wider trigger or a bigger size (`RAISES` in `tools_audit_stop_perks_fixes.py`). The perk tables are current; prose notes below may still describe a perk's first, narrower scope.
Follows `proposal-stop-perks.md` (rules, families, caps, section 5 format) and `PROPOSAL-HOLLOW-MASTER.md` section 7 and 14 (ruling 7: a hand-written set per region). Stops are from `claude/route-list.md`; zones and havens from `zones.txt` and `landmarks.txt`; stop types from `stops.txt`; crops from `region_crops.txt`.

62 stops, 186 perks: every stop has its own three (Repairs, Larder, Cheer). Honeythorpe (Blossomreach) already has its three in the Maplewold set and is not rewritten.

## 1. World budget share per region

Share = (cap - what the Maplewold set uses) / 13 regions, rounded down. "Maplewold use" is the "NA world" column of `proposal-stop-perks.md` section 4 (18 stops, 54 perks, as updated 2026-11-27 with Cattailmere and Granitegate); "Left" matches the line "World budget left for the other 13 regions" in its section 4.1.

| Family | Effect | Cap | Maplewold use | Left | Share per region | In this file |
|---|---|---|---|---|---|---|
| F01 | sell | +5% | 3 | 2 | **0** | 7 place |
| F02 | buy | -5% | 1 | 4 | **0** | 4 place |
| F03 | XP | +5% | 3 | 2 | **0** | 3 place |
| F04 | garden XP | +5% | 1 | 4 | **0** | 5 place |
| F05 | walk time | -6% | 3 | 3 | **0** | 8 place |
| F06 | pot time | -6% | 4 | 2 | **0** | 7 place |
| F07 | dish energy | +5% | 2 | 3 | **0** | 7 place |
| F08 | boost length | +8% | 4 | 4 | **0** | 4 place |
| F09 | healing | +8% | 4 | 4 | **0** | 6 place |
| F10 | harvest extra | +4% | 4 | 0 | **0** | 9 place |
| F11 | gather extra | +4% | 2 | 2 | **0** | 4 place |
| F12 | watering lasts | +8% | 2 | 6 | **0** | 5 place |
| F13 | seed back | +4% | 1 | 3 | **0** | 5 place |
| F14 | friendship chance | +8% | 2 | 6 | **0** | 4 place |
| F15 | stop coins | +8% | 2 | 6 | **0** | 3 place |
| F16 | stop check | +4% | 1 | 3 | **0** | 3 place |
| F17 | pest | -8% | 2 | 6 | **0** | 6 place |
| F18 | fast travel cost | -5% | 1 | 4 | **0** | 3 place |
| F19 | spot hidden | +4% | 1 | 3 | **0** | 3 place |
| F20 | max health | +3 | 0 | 3 | **0** | 0 place |
| F21 | torch steps | +3 | 0 | 3 | **0** | 1 place |
| F22 | rest energy | +2 | 2 | 0 | **0** | 3 place |
| F23 | seed on fast travel | +4% | 1 | 3 | **0** | 0 place |
| A4 | daycoin | 10 coins a game day | 1 | 9 | **0** | 2 place (daily) |

**Every share is 0.** The largest amount left in any family is 6 (watering, friendship, stop coins, pest), and 6 / 13 rounds down to 0. A4 is not a budget but a ceiling of 10 coins a game day (1 used), so its row is treated the same way. So this file has **no world perks**: every numeric perk is a place perk (P), and the rest are daily charges (D) or flags (F). World-family units used by these five regions: 0.

Rules kept in every row:
- **P** = place perk. Scope is one of `from=` (at this stop, or a walk that starts here), `to=` (a walk, fast travel or delve that ends here), `region=` (only inside this region), `items=local` (named crops of this region). Never added to a world cap.
- `region=` perks: at most one per family per region, so region-wide place perks never stack inside a region. `items=local` perks: no crop gets the same family twice in a region (family cap per crop, 4.1 rule 2).
- **D** = daily charge, one per perk per game day (comes back on sleep, never at midnight, never banked). Every D here is tied to its stop, its region or a regional crop, and no two share a trigger. The two A4 perks pay 2 coins each and sit under the 10-coins-a-game-day ceiling.
- **F** = flag (A5 information, A6 looks). No power. At most one A5 and one A6 per stop.
- Sizes: 1% or 2%, +1 energy, +1 torch step, one item, 2 coins. Nothing above 2%. One perk per family per stop. Impact pass 2026-11-27: every % family may be 2% a perk, and the narrow place perks on the veto list of `proposal-perk-impact.md` are at 3%.
- Stop types are explicit and each suits its landscape in `stops.txt`; set them in Admin > Places. The town and the havens need `stop_is_place()` first (ruling 6).

## 2. Thornacre Savanna (ESA): 12 stops, 36 perks

Zones: Thornacre Plains (grassland), Coffeecloud Highlands (mountain), Rift Lakes (wetland), Bonedry Karoo (desert). 12 stops: the town, 10 villages, 1 haven. Each of the 12 stop types is used once. Meadowden is the border village on the road from the Greatcanopy.

| Stop | Kind | Land | Type | Why |
|---|---|---|---|---|
| Thornacre Savanna Market | town | grassland | market | The town |
| Meadowden | village | grassland | herb | Rooibos beds by the Greatcanopy road |
| Clovergate | village | grassland | mill | Teff and sorghum to grind |
| Meadowbottom | village | grassland | orchard | Banana and tamarind groves; four roads leave it |
| Summitglen | village | mountain | tower | Lookout over the plains, at the head of the Spicepeak road |
| Pinecombe | village | mountain | spring | A warm rift pool in a high valley |
| Echoford | village | mountain | shrine | A bell and an echo in the highlands |
| Bogmead | village | wetland | jetty | Lake fishing on the Rift Lakes |
| Newtcombe | village | wetland | ferry | A punt across the lake arm |
| Emberhollow | village | desert | workshop | A flint-knappers' forge |
| Amberburrow | village | desert | camp | A thorn-fenced fire in the Karoo |
| Baobab Inn | haven | grassland | inn | A guesthouse inside a giant baobab |

| Stop | Type | Bar | Perk | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|
| Thornacre Savanna Market | market | Repairs | 🧱 Red-Ochre Stall Posts | Stalls in Thornacre Savanna's grassland and desert zones pay 2% more for what you sell | +2% | P region=ESA | F01 |
|  |  | Larder | 🫓 Injera Off the Griddle | First visit to the Thornacre market each day: one sack of teff (`teff`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🧺 Woven Basket Lid | A woven Savanna basket sits on your hovel shelf, filled with whatever you last harvested (looks only) | flag | F | A6 |
| Meadowden | herb | Repairs | 🌿 Mended Rooibos Racks | Pests are 2% less likely on collard greens, rooibos, teff and banana | -2% | P items=local | F17 |
|  |  | Larder | 🍵 Red Bush Brew | Boosts from anything eaten or drunk in Thornacre Savanna's grassland and mountain zones last 2% longer | +2% | P region=ESA | F08 |
|  |  | Cheer | 🦒 Tall Neighbours | At dusk a giraffe looks over your garden fence (looks only) | flag | F | A6 |
| Clovergate | mill | Repairs | ⚙️ Dressed Teff Stones | Dishes made with teff or sorghum cook 2% faster | -2% | P items=local | F06 |
|  |  | Larder | 🌾 Sweepings of the Threshing Floor | Teff, sorghum and collard greens harvests: 2% chance of one extra | +2% | P items=local | F10 |
|  |  | Cheer | 🐓 Guinea-Fowl Alarm | The garden page marks every plot that had a pest in the last game day | flag | F | A5 |
| Meadowbottom | orchard | Repairs | 🪜 Banana-Leaf Thatch | The first walk each day on a grassland road of the Savanna costs 1 less energy (shade from Meadowbottom) | 1 a day | D to= | A1 |
|  |  | Larder | 🍌 A Whole Hand of Bananas | Banana, tamarind, teff and collard greens give 2% more garden XP | +2% | P items=local | F04 |
|  |  | Cheer | 🦩 Pink on the Horizon | Your gnome wears a flamingo feather in the hat on the profile page (looks only) | flag | F | A6 |
| Summitglen | tower | Repairs | 🧯 Fire-Watch Basket | Once a day, the first torch step in the Fynbos Fire Trails is not used up | 1 a day | D to= | A2 |
|  |  | Larder | 🥜 Lookout's Tamarind Twist | Walks in Thornacre Savanna's grassland and desert zones take 2% less time | -2% | P region=ESA | F05 |
|  |  | Cheer | 🦓 Counting the Herds | Zebra stripes run along the border of your grassland route maps in the Savanna (looks only) | flag | F | A6 |
| Pinecombe | spring | Repairs | ♨️ Relined Rift Pool | Rest acts at Pinecombe give 1 more energy after dawn | +1 | P from= | F22 |
|  |  | Larder | 🌱 Steam-Bed Ensete | Enset, teff, collard greens and banana harvests: 2% more chance of a seed back | +2% | P items=local | F13 |
|  |  | Cheer | 🐒 The Baboon Has Your Towel | Once a day, a lost contest at Pinecombe or anywhere else in the Savanna can be played again | 1 a day | D from= | A2 |
| Echoford | shrine | Repairs | 🔔 Rehung Echo Bell | Stop checks name the stat they will test before you choose | flag | F | A5 |
|  |  | Larder | 🥣 Pilgrim's Sorghum Bowl | First visit to Echoford each day: one bowl of sorghum (`sorghum`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🗣️ It Says It Back | Acts at stops in Thornacre Savanna's grassland and mountain zones give 2% more XP | +2% | P region=ESA | F03 |
| Bogmead | jetty | Repairs | 🛶 Papyrus Raft, Rebound | Gathering in Thornacre Savanna's grassland and wetland zones: 2% chance of one extra | +2% | P region=ESA | F11 |
|  |  | Larder | 🐟 Tilapia on a Reed | Bogmead's stall pays 3% more for golden carp and trout (`golden-carp`, `trout`) | +3% | P from= | F01 |
|  |  | Cheer | 🦛 Yawn Across the Water | At dusk a hippo's ears and eyes drift along the foot of the Today page (looks only) | flag | F | A6 |
| Newtcombe | ferry | Repairs | 🥅 Net Mended by the Ferryman | Once a day, the first wear on your bug net anywhere in the Savanna is skipped | 1 a day | D from= | A2 |
|  |  | Larder | 🥬 Collards on the Punt | Watering lasts 2% longer on collard greens, watermelon, teff and banana | +2% | P items=local | F12 |
|  |  | Cheer | 🧾 Return Ticket | The route menu shows the energy cost of the walk back beside the walk out | flag | F | A5 |
| Emberhollow | workshop | Repairs | 🔥 Flint in the Tinderbox | Acts at stops in Thornacre Savanna's grassland and desert zones pay 2% more coins | +2% | P region=ESA | F15 |
|  |  | Larder | 🍉 Melon in the Quench Trough | First craft act at Emberhollow each day: one cool watermelon (`watermelon`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🎨 Ochre Thumbprint | Your gnome wears two stripes of red ochre on the profile page (looks only) | flag | F | A6 |
| Amberburrow | camp | Repairs | 🌵 Thorn-Fence Boma | Rest acts and trail rests in Thornacre Savanna's grassland and desert zones heal 2% more | +2% | P region=ESA | F09 |
|  |  | Larder | 🌿 Sage on the Coals | First rest act at Amberburrow each day: one sprig of desert sage (`desert-sage`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🌠 Karoo Sky | On clear nights the Milky Way arches over your garden (looks only) | flag | F | A6 |
| Baobab Inn | inn | Repairs | 🌳 Lantern in the Hollow Trunk | Fast travel that starts in Thornacre Savanna's grassland and mountain zones costs 2% less | -2% | P region=ESA | F18 |
|  |  | Larder | 🥤 Baobab-Shade Lunch | Dishes eaten in the Savanna at midday give 2% more energy | +2% | P region=ESA | F07 |
|  |  | Cheer | 📖 Guest Book in the Bark | Your passport shows the game date of your first visit to each stop | flag | F | A5 |

## 3. Spicepeak (CSA): 13 stops, 39 perks

Zones: Lotus Delta (wetland), Silkroad Steppe (grassland), Tigerstripe Jungle (forest), The Roof of the World (mountain). 13 stops: the town, 11 villages, 1 haven. Border villages: Newtdell (from the Birchbramble Steppe), Heronby (from the Dunewhisper), Windstead (from the Savanna).

| Stop | Kind | Land | Type | Why |
|---|---|---|---|---|
| Spicepeak Market | town | grassland | market | The town |
| Newtdell | village | wetland | ferry | A delta crossing on the Steppe road |
| Rushdell | village | wetland | jetty | Reed jetty on the delta |
| Heronby | village | wetland | inn | Caravan inn on the Dunewhisper road |
| Cloverburrow | village | grassland | mill | Wheat country |
| Windstead | village | grassland | tower | A windy rise on the Savanna road |
| Poppythorpe | village | grassland | camp | Caravan camp on the way to the Caravanserai |
| Leafmead | village | forest | herb | Tulsi and tea, below the Tea Garden Slopes |
| Hollowby | village | forest | orchard | Mango and mulberry trees in the jungle |
| Cliffmead | village | mountain | shrine | Prayer flags on a cliff path |
| Pinecrest | village | mountain | workshop | Pine resin and slate |
| Screeden | village | mountain | spring | Slate pools under the scree |
| Floating Flower Market | haven | wetland | market | Boats of flowers |

| Stop | Type | Bar | Perk | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|
| Spicepeak Market | market | Repairs | 🧵 Restrung Awnings | Stalls in Spicepeak's grassland and mountain zones pay 2% more for what you sell | +2% | P region=CSA | F01 |
|  |  | Larder | 🫚 Thumb of Ginger | First sale each day at the Spicepeak market: the stallholder adds one piece of ginger (`ginger`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🌶️ Nose for Masala | Recipes mark every dish you can cook right now from your satchel with a small ladle | flag | F | A5 |
| Newtdell | ferry | Repairs | 🛶 Caulked Delta Boat | The first walk each day on a wetland road of Spicepeak costs 1 less energy (poled from Newtdell) | 1 a day | D from= | A1 |
|  |  | Larder | 🥣 Boatman's Mung Dal | Dishes with mung bean or fenugreek give 2% more energy | +2% | P items=local | F07 |
|  |  | Cheer | 🐸 Frog on the Tiller | A small frog rides on the corner of your wetland route maps (looks only) | flag | F | A6 |
| Rushdell | jetty | Repairs | 🎋 Rebound Reed Jetty | Walks in Spicepeak's grassland and mountain zones: 2% better chance to spot hidden things | +2% | P region=CSA | F19 |
|  |  | Larder | 🐠 Fish in Mustard | Pots you cook while in Spicepeak's grassland and mountain zones cook 2% faster | -2% | P region=CSA | F06 |
|  |  | Cheer | 🪤 Reed Fish-Trap | A reed fish-trap leans against your hovel wall (looks only) | flag | F | A6 |
| Heronby | inn | Repairs | 🏮 Lamp at the Caravan Gate | Once a day, the first torch step on the Snowleopard Ledges is not used up | 1 a day | D to= | A2 |
|  |  | Larder | 🍛 Dal for the Dusty | First rest act at Heronby each day: one handful of mung beans (`mung-bean`) | 1 a day | D from= | A3 |
|  |  | Cheer | 📜 News from Three Roads | Heronby's notice board shows today's weather in the Dunewhisper and on the Steppe | flag | F | A5 |
| Cloverburrow | mill | Repairs | 🪨 Chakki Stones, Re-cut | Dishes with wheat or mung bean in them cook 2% faster | -2% | P items=local | F06 |
|  |  | Larder | 🌾 Gleaner's Corner | Wheat, fenugreek, turmeric, mango and tulsi harvests: 3% chance of one extra | +3% | P items=local | F10 |
|  |  | Cheer | 🫓 Roti Puffed on the Coals | First visit to Cloverburrow each day: one sack of flour (`flour`) | 1 a day | D from= | A3 |
| Windstead | tower | Repairs | 🚩 Mended Wind Vane | A weathercock on your hovel roof turns with the wind (looks only) | flag | F | A6 |
|  |  | Larder | 🥭 Mango on the Sill | Watering lasts 2% longer on mango, melon, wheat, mung bean and fenugreek | +2% | P items=local | F12 |
|  |  | Cheer | 🌬️ Leaning Into It | Walks in Spicepeak's grassland and mountain zones take 2% less time | -2% | P region=CSA | F05 |
| Poppythorpe | camp | Repairs | 🐫 Picketed Caravan Line | Stalls in Spicepeak's grassland and mountain zones charge 2% less | -2% | P region=CSA | F02 |
|  |  | Larder | 🫖 Caravan Kettle | Once a day, the first tea you brew in Spicepeak gives one ingredient back | 1 a day | D region=CSA | A2 |
|  |  | Cheer | 🎲 Dice on a Saddle Blanket | Chats with Poppythorpe's folk at night have a 3% chance of +1 friendship | +3% | P from= | F14 |
| Leafmead | herb | Repairs | 🪴 Re-staked Tulsi Beds | Pests are 2% less likely on turmeric, tulsi, wheat, mung bean and fenugreek | -2% | P items=local | F17 |
|  |  | Larder | 🍃 Two Leaves and a Bud | Ginger, turmeric, tulsi, wheat and mung bean give 2% more garden XP | +2% | P items=local | F04 |
|  |  | Cheer | ⏲️ First Flush | The tea menu shows the minutes left on your running boost beside each tea | flag | F | A5 |
| Hollowby | orchard | Repairs | 🎍 Bamboo Picking Poles | Mango, jackfruit, mulberry, wheat, mung bean and fenugreek harvests: 2% more chance of a seed back | +2% | P items=local | F13 |
|  |  | Larder | 🫐 Purple to the Elbows | The first mulberry or jackfruit harvest each day gives one extra of that crop | 1 a day | D items=local | A3 |
|  |  | Cheer | 🐅 Stripes in the Shade | Now and then a striped tail slips out of sight at the edge of your garden (looks only) | flag | F | A6 |
| Cliffmead | shrine | Repairs | 🎏 Restrung Prayer Flags | On windy days prayer flags flutter over your garden gate (looks only) | flag | F | A6 |
|  |  | Larder | 🧈 Butter-Tea Offering | Dishes eaten in Spicepeak's grassland and mountain zones give 2% more energy | +2% | P region=CSA | F07 |
|  |  | Cheer | 🙏 A Wish on the Wind | Stop checks in Spicepeak's grassland and mountain zones are 2% kinder | +2% | P region=CSA | F16 |
| Pinecrest | workshop | Repairs | 🔧 Tinker's Squint | Your satchel puts a small spanner on any tool that is close to wearing out | flag | F | A5 |
|  |  | Larder | 🍑 Apricot Kernels in the Apron | Apricot, mung bean, ginger, melon, cinnamon, tea and black pepper harvests: 3% chance of one extra | +3% | P items=local | F10 |
|  |  | Cheer | 🐆 Whittled Snow Leopard | A small carved snow leopard sits on your hovel windowsill (looks only) | flag | F | A6 |
| Screeden | spring | Repairs | 🧱 Slate-Lined Pool | Rest acts and trail rests in Spicepeak's wetland and mountain zones heal 2% more | +2% | P region=CSA | F09 |
|  |  | Larder | 🥚 Eggs in Turmeric Water | Dishes with turmeric, wheat or ginger give 2% more energy | +2% | P items=local | F07 |
|  |  | Cheer | ☔ Shared Steam, Shared Umbrella | Chats and gifts with folk in Spicepeak's grassland and mountain zones: 2% chance of +1 friendship | +2% | P region=CSA | F14 |
| Floating Flower Market | market | Repairs | 🚤 Bailed-Out Flower Boat | The Floating Flower Market pays 3% more for flowers you sell | +3% | P from= | F01 |
|  |  | Larder | 🌼 Marigold for the Teapot | First visit to the Floating Flower Market each day: one marigold (`marigold`) | 1 a day | D from= | A3 |
|  |  | Cheer | 💐 Garland Round the Plaque | Every plaque you hold in Spicepeak wears a marigold garland (looks only) | flag | F | A6 |

## 4. Blossomreach (EA): 11 stops, 33 perks

Zones: Ricestep Terraces (grassland), Bamboo Whisperwood (forest), Pearlwave Shore (coast), The Gobi Wastes (desert). 12 stops: the town, 10 villages, 1 haven. **Honeythorpe is already written** (orchard; Propped Boughs, Grafter's Label, Hop-Yard Hum in `proposal-stop-perks.md` section 5), so 11 stops and 33 perks are new here. With Honeythorpe, each of the 12 stop types is used once. Poppywell is the border village on the road from Spicepeak.

| Stop | Kind | Land | Type | Why |
|---|---|---|---|---|
| Blossomreach Market | town | grassland | market | The town |
| Clovercove | village | grassland | mill | A water mill on the terraces |
| Poppywell | village | grassland | camp | Travellers' fire by the well on the Spicepeak road |
| Bramblebrook | village | forest | herb | Perilla beds under the bamboo |
| Birchford | village | forest | workshop | Paper, fans and lamps; the Long Wall starts here |
| Brambleburrow | village | forest | shrine | Red gates under old trees |
| Sprayholt | village | coast | jetty | A jetty on the Pearlwave Shore |
| Tidecombe | village | coast | ferry | A flat boat across the bay |
| Coppergate | village | desert | tower | A gate tower at the edge of the wastes |
| Dunewick | village | desert | spring | A warm pool at the last oasis |
| Cherry Blossom Teahouse | haven | grassland | inn | Tea, rest and the best view in the Hollow |
| Honeythorpe | village | grassland | orchard | Already written (Maplewold set) |

| Stop | Type | Bar | Perk | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|
| Blossomreach Market | market | Repairs | 🏮 Re-papered Lanterns | A paper lantern glows on your hovel door at night (looks only) | flag | F | A6 |
|  |  | Larder | 🥬 Napa by the Cartload | Stalls in Blossomreach's grassland and forest zones pay 2% more for what you sell | +2% | P region=EA | F01 |
|  |  | Cheer | 🧧 Red Envelope | The first act you do each day in Blossomreach pays 2 coins more | 2 coins | D region=EA | A4 |
| Clovercove | mill | Repairs | 💧 Cleared Terrace Sluice | Watering lasts 2% longer on napa cabbage, bok choy and daikon | +2% | P items=local | F12 |
|  |  | Larder | 🫘 Polished Adzuki | Dishes with adzuki bean or napa cabbage in them cook 2% faster | -2% | P items=local | F06 |
|  |  | Cheer | 🎏 Carp in the Millpond | A carp's shadow circles in your garden's water butt (looks only) | flag | F | A6 |
| Poppywell | camp | Repairs | 🪣 New Rope on the Well | Once a day, the first cook or craft act at Poppywell costs 1 less energy | 1 a day | D from= | A1 |
|  |  | Larder | 🎍 Shoots from the Panda's Share | Bamboo shoot, napa cabbage, adzuki bean, peach, lotus root and lychee harvests: 2% chance of one extra | +2% | P items=local | F10 |
|  |  | Cheer | 🐼 Black-and-White Visitor | On rainy days a panda naps in a corner of your garden (looks only) | flag | F | A6 |
| Bramblebrook | herb | Repairs | 🌿 Perilla Under Netting | Pests are 2% less likely on perilla, star anise, napa cabbage, daikon and adzuki bean | -2% | P items=local | F17 |
|  |  | Larder | 🫙 Seed Saved in the Pickling Crock | Daikon, perilla, napa cabbage and adzuki bean harvests: 2% more chance of a seed back | +2% | P items=local | F13 |
|  |  | Cheer | 🦋 Swallowtail Hour | At midday a swallowtail rests on your tallest plant (looks only) | flag | F | A6 |
| Birchford | workshop | Repairs | 🕯️ Wall-Walker's Lamp | +1 torch step on the Long Wall Walk | +1 step | P to= | F21 |
|  |  | Larder | 🏷️ Rice-Paper Labels | Your recipe book marks the dishes you have never cooked | flag | F | A5 |
|  |  | Cheer | 🪭 Fan-Maker's Breeze | Walks in Blossomreach's forest and desert zones take 2% less time | -2% | P region=EA | F05 |
| Brambleburrow | shrine | Repairs | ⛩️ Fresh Vermilion | Walks in Blossomreach's grassland and forest zones: 2% better chance to spot hidden things | +2% | P region=EA | F19 |
|  |  | Larder | 🍑 Peach Left for the Fox | Peach, persimmon, napa cabbage, daikon and adzuki bean give 2% more garden XP | +2% | P items=local | F04 |
|  |  | Cheer | 🦊 The Fox Comes Back | At dusk a fox sits by your garden path (looks only) | flag | F | A6 |
| Sprayholt | jetty | Repairs | 🪢 Spliced Mooring Lines | Gathering in Blossomreach's forest and coast zones: 2% chance of one extra | +2% | P region=EA | F11 |
|  |  | Larder | 🦪 Mussel Rack at Low Tide | First visit to Sprayholt each day: one handful of mussels (`blue-mussels`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🌙 Wave-Watcher's Almanac | The Today page shows the phase of the moon | flag | F | A5 |
| Tidecombe | ferry | Repairs | ⛴️ Tarred Flat-Bottom | Walks between Tidecombe and Poppywell take 3% less time, both ways | -3% | P from= | F05 |
|  |  | Larder | 🧂 Sea-Salt Pans | Stalls in Blossomreach's forest and coast zones charge 2% less | -2% | P region=EA | F02 |
|  |  | Cheer | 🐚 Pearl-Diver's String | A string of pearl-white shells hangs in your hovel window (looks only) | flag | F | A6 |
| Coppergate | tower | Repairs | 🛎️ Polished Gate Gong | Stop checks in Blossomreach's forest and desert zones are 2% kinder | +2% | P region=EA | F16 |
|  |  | Larder | 🥮 Sentry's Red-Bean Bun | First visit to Coppergate each day: one red-bean bun (`red-bean-buns`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🧭 A Long Way in Both Directions | The route menu shows the level needed for the place at the far end | flag | F | A5 |
| Dunewick | spring | Repairs | 🏜️ Tamarisk Windbreak | Rest acts and trail rests in Blossomreach's forest and desert zones heal 2% more | +2% | P region=EA | F09 |
|  |  | Larder | 🍵 Jujube Tea in the Shade | Jujube, daikon, bok choy, perilla, persimmon and star anise harvests: 2% chance of one extra | +2% | P items=local | F10 |
|  |  | Cheer | 🪰 Jade Wings Over the Water | A jade dragonfly hovers over the last plot you watered (looks only) | flag | F | A6 |
| Cherry Blossom Teahouse | inn | Repairs | 🌸 Screens Re-papered | In spring, cherry petals drift across your garden (looks only) | flag | F | A6 |
|  |  | Larder | 🍶 Second Pour | Boosts from anything eaten or drunk in Blossomreach's grassland and forest zones last 2% longer | +2% | P region=EA | F08 |
|  |  | Cheer | 🖌️ The Best View in the Hollow | Your Tea Journal shows how many named teas you have still to find | flag | F | A5 |

## 5. The Monsoon Tangle (SEA): 13 stops, 39 perks

Zones: Paddy Patchwork (wetland), Longtail Lagoons (coast), Spice Scatter (island), The Hornbill Deep (rainforest). 13 stops: the town, 11 villages, 1 haven. Border villages: Marshcrest (from Spicepeak), Lilyby (from Blossomreach). No workshop: the type does not suit wetland, coast, island or rainforest.

| Stop | Kind | Land | Type | Why |
|---|---|---|---|---|
| The Monsoon Tangle Market | town | wetland | market | The town |
| Marshcrest | village | wetland | mill | A rice mill on the Spicepeak road |
| Rushglen | village | wetland | herb | Lemongrass and kangkong beds |
| Lilyby | village | wetland | inn | Stilt inn on the Blossomreach road |
| Sandpiperglen | village | coast | jetty | Longtail boats on the lagoon |
| Shellnook | village | coast | ferry | The sea crossing to the Coralscatter |
| Sandpiperhollow | village | coast | tower | A storm light on the shore |
| Spindriftbottom | village | island | spring | Volcano-warmed pools |
| Reefden | village | island | orchard | Fruit groves on a spice island |
| Canopyford | village | rainforest | camp | A camp by the rope bridge |
| Monsoonburrow | village | rainforest | shrine | A rain shrine in the Hornbill Deep |
| Parrotden | village | rainforest | orchard | Fruit trees full of parrots |
| Floating Market | haven | wetland | market | Boat stalls and noodles |

| Stop | Type | Bar | Perk | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|
| The Monsoon Tangle Market | market | Repairs | ⛱️ Patched Tarpaulins | Stalls in the Monsoon Tangle's coast and rainforest zones charge 2% less | -2% | P region=SEA | F02 |
|  |  | Larder | 🍜 Noodles Sold from the Wok | The first dish you sell each day at any stall in the Monsoon Tangle pays 2 coins more | 2 coins | D from= | A4 |
|  |  | Cheer | 🛺 Knows Every Alley | Stalls show how many of each thing you already carry | flag | F | A5 |
| Marshcrest | mill | Repairs | 🐃 Buffalo-Turned Stone | Dishes with rice or water spinach in them cook 2% faster | -2% | P items=local | F06 |
|  |  | Larder | 🍚 Second Threshing | Rice, lemongrass, dragon fruit, moringa, durian and mangosteen harvests: 2% chance of one extra | +2% | P items=local | F10 |
|  |  | Cheer | 🪶 Egret on the Buffalo | After rain an egret stands in your wettest plot (looks only) | flag | F | A6 |
| Rushglen | herb | Repairs | 🧺 Re-woven Drying Trays | Watering lasts 2% longer on water spinach, lemongrass and rice | +2% | P items=local | F12 |
|  |  | Larder | 🍋 Bruised Lemongrass | Boosts from anything eaten or drunk in the Monsoon Tangle's wetland and coast zones last 2% longer | +2% | P region=SEA | F08 |
|  |  | Cheer | ✨ Followed Home by Fireflies | In the Firefly Caves a few fireflies trail behind your gnome (looks only) | flag | F | A6 |
| Lilyby | inn | Repairs | 🛏️ Dry Bedding in the Wet | Rest acts at Lilyby give 1 more energy in any weather but clear sun | +1 | P from= | F22 |
|  |  | Larder | 🍙 Sticky Rice in a Leaf | First visit to Lilyby each day: one parcel of rice (`rice`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🪔 Lantern Set on the River | The Today page counts the game days left in this season | flag | F | A5 |
| Sandpiperglen | jetty | Repairs | 🚤 Longtail Prop, Straightened | Fast travel that starts in the Monsoon Tangle's coast and rainforest zones costs 2% less | -2% | P region=SEA | F18 |
|  |  | Larder | 🦐 Shrimp-Paste Jar | Gathering on coast walks that end at Sandpiperglen: 3% chance of one extra | +3% | P to= | F11 |
|  |  | Cheer | 🛥️ Longtail Wake | A longtail boat's wake trails behind your gnome on coast route maps (looks only) | flag | F | A6 |
| Shellnook | ferry | Repairs | ⛵ Outrigger Lashed Tight | Walks between Shellnook and Turtleburrow take 3% less time in wind or storm, both ways | -3% | P from= | F05 |
|  |  | Larder | 📦 Crated Starfruit | Stalls in the Monsoon Tangle's coast, rainforest and island zones pay 2% more for what you sell | +2% | P region=SEA | F01 |
|  |  | Cheer | 🦎 Lizard on the Bollard | The fast-travel list shows the energy you will have left on arrival | flag | F | A5 |
| Sandpiperhollow | tower | Repairs | 🗼 Storm Lamp, Trimmed | Walks in the Monsoon Tangle's coast and rainforest zones take 2% less time | -2% | P region=SEA | F05 |
|  |  | Larder | 🥘 Keeper's Bitter-Melon Fry | Dishes with bitter melon or rice give 2% more energy | +2% | P items=local | F07 |
|  |  | Cheer | 🌧️ Smells Rain Coming | The Today page shows how many hours are left until the weather changes | flag | F | A5 |
| Spindriftbottom | spring | Repairs | 🌋 Re-dug Volcano Pool | Rest acts and trail rests in the Monsoon Tangle's coast, rainforest and island zones heal 2% more | +2% | P region=SEA | F09 |
|  |  | Larder | 🥚 Eggs Boiled Black | First rest act at Spindriftbottom each day: one salted egg (`salted-eggs`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🐵 Monkey Has the Soap | Now and then a monkey runs off with a bar of soap across your Today page (looks only) | flag | F | A6 |
| Reefden | orchard | Repairs | 🌴 Notched Palm Ladder | Gathering in the Monsoon Tangle's coast, rainforest and island zones: 2% chance of one extra | +2% | P region=SEA | F11 |
|  |  | Larder | 🍒 Rambutan by the Armful | Rambutan, longan, starfruit, water spinach and bitter melon harvests: 2% chance of one extra | +2% | P items=local | F10 |
|  |  | Cheer | 🎁 Fruit for the Neighbours | Chats and gifts with folk in the Monsoon Tangle's coast, rainforest and island zones: 2% chance of +1 friendship | +2% | P region=SEA | F14 |
| Canopyford | camp | Repairs | 🌉 Re-roped Bridge | Walks in the Monsoon Tangle's coast and rainforest zones: 2% better chance to spot hidden things | +2% | P region=SEA | F19 |
|  |  | Larder | 🍃 Supper on a Banana Leaf | Once a day, a dish cooked at Canopyford's fire or at any other stop fire in the Monsoon Tangle gives one ingredient back | 1 a day | D from= | A2 |
|  |  | Cheer | 🐦 Hornbill Overhead | A hornbill flies across the top of your rainforest route maps (looks only) | flag | F | A6 |
| Monsoonburrow | shrine | Repairs | 🧹 Swept Before the Rains | Pests are 2% less likely on water spinach, bitter melon, starfruit, moringa, durian and mangosteen | -2% | P items=local | F17 |
|  |  | Larder | 🥄 First Bowl to the Spirits | Rice, water spinach and lemongrass harvests: 2% more chance of a seed back | +2% | P items=local | F13 |
|  |  | Cheer | 🌈 After the Downpour | Acts at stops in the Monsoon Tangle's coast and rainforest zones give 2% more XP | +2% | P region=SEA | F03 |
| Parrotden | orchard | Repairs | 🦜 Parrot-Proof Netting | Pests are 2% less likely on dragon fruit, rambutan, longan, rice and lemongrass | -2% | P items=local | F17 |
|  |  | Larder | 🐉 What the Parrots Missed | Dragon fruit, moringa, rice, water spinach and lemongrass give 2% more garden XP | +2% | P items=local | F04 |
|  |  | Cheer | 💬 The Parrot Repeats It | Stop pages show which of the stop's folk you have not chatted with this game day | flag | F | A5 |
| Floating Market | market | Repairs | 🚣 Bailed and Balanced | The Floating Market's boats pay 3% more for dishes you sell | +3% | P from= | F01 |
|  |  | Larder | 🥢 Lemongrass From the Boat | First visit to the Floating Market each day: one bundle of lemongrass (`lemongrass`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🛶 Haggled from the Prow | Stop checks in the Monsoon Tangle's wetland and coast zones are 2% kinder | +2% | P region=SEA | F16 |

## 6. The Coralscatter (OC): 13 stops, 39 perks

Zones: Lagoon Ring Atolls (island), Kelpwhisker Coast (coast), Fernmist Gullies (forest), The Red Heart (desert). 13 stops: the town, 11 villages, 1 haven. Border villages: Palmgate (from the Rainroot Reaches), Turtleburrow (from the Monsoon Tangle).

| Stop | Kind | Land | Type | Why |
|---|---|---|---|---|
| The Coralscatter Market | town | island | market | The town |
| Palmgate | village | island | ferry | Canoe landing on the Rainroot road |
| Reefknoll | village | island | orchard | Coconut and pandanus palms |
| Turtleburrow | village | island | shrine | A turtle shrine above the hatchling beach |
| Brineglen | village | coast | inn | The last roof before the Kava Circle |
| Shellknoll | village | coast | tower | A whitewashed light on a knoll |
| Salthollow | village | coast | jetty | Salt pans and a fishing jetty |
| Mossby | village | forest | mill | A sago mill in a fern gully |
| Toadstoolbrook | village | forest | herb | A fern-house croft |
| Miragewell | village | desert | spring | A warm bore in the Red Heart |
| Oasiswick | village | desert | workshop | Carvers and tool-makers |
| Ambercove | village | desert | camp | A swag camp under red rock |
| Kava Circle | haven | island | camp | Share kava and rest |

| Stop | Type | Bar | Perk | Effect | Size | Scope | Family |
|---|---|---|---|---|---|---|---|
| The Coralscatter Market | market | Repairs | ⚖️ Shell-Weight Scales | Your satchel shows what each thing would sell for at the shop you are in | flag | F | A5 |
|  |  | Larder | 🥥 Husked While You Wait | First visit to the Coralscatter market each day: one coconut (`coconut`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🌺 Flower Behind the Ear | Your gnome wears a frangipani behind one ear on the profile page (looks only) | flag | F | A6 |
| Palmgate | ferry | Repairs | 🛶 Re-lashed Outrigger | Fast travel that starts in the Coralscatter's island and desert zones costs 2% less | -2% | P region=OC | F18 |
|  |  | Larder | 🐟 Reef Fish in Coconut | Dishes made with coconut cook 2% faster | -2% | P items=local | F06 |
|  |  | Cheer | ⭐ Steering by Stars | On clear nights the Southern Cross hangs over your garden (looks only) | flag | F | A6 |
| Reefknoll | orchard | Repairs | 🌴 Notches Up the Palm | Coconut, pandanus and kava harvests: 2% chance of one extra | +2% | P items=local | F10 |
|  |  | Larder | 🍍 Pandanus Keys | Pandanus, noni and taro give 2% more garden XP | +2% | P items=local | F04 |
|  |  | Cheer | 🦀 Coconut Crab Referee | Acts at stops in the Coralscatter's coast and desert zones pay 2% more coins | +2% | P region=OC | F15 |
| Turtleburrow | shrine | Repairs | 🐢 Raked Hatchling Run | A small stone shrine stands at the head of your garden path (looks only) | flag | F | A6 |
|  |  | Larder | 🥗 Greens Above the Tideline | Taro, warrigal greens and coconut harvests: 2% more chance of a seed back | +2% | P items=local | F13 |
|  |  | Cheer | 🌅 Quiet as Low Tide | Rest acts at Turtleburrow heal 3% more at dawn | +3% | P from= | F09 |
| Brineglen | inn | Repairs | 🪟 Salt-Proof Shutters | Walks that start at Brineglen take 3% less time in fog | -3% | P from= | F05 |
|  |  | Larder | 🍇 Sea Grapes by the Door | First rest act at Brineglen each day: one handful of sea grapes (`sea-grapes`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🗿 One Question Each | Friends pages show the game day you last spoke to each villager | flag | F | A5 |
| Shellknoll | tower | Repairs | 🗼 Whitewashed Light | Walks in the Coralscatter's island, coast and desert zones take 2% less time | -2% | P region=OC | F05 |
|  |  | Larder | 🫖 Billy on the Boil | Dishes eaten in the Coralscatter's coast and desert zones give 2% more energy | +2% | P region=OC | F07 |
|  |  | Cheer | 🐋 Thar She Blows | The world map shows which way the wind blows today | flag | F | A5 |
| Salthollow | jetty | Repairs | 🪢 Pandanus-Rope Rails | Fishing and gathering acts at Salthollow pay 3% more coins | +3% | P from= | F15 |
|  |  | Larder | 🧂 Salt-Crusted Catch | Once a day, the first thing you find on a walk from Salthollow comes with one pinch of sea salt (`sea-salt`) | 1 a day | D from= | A3 |
|  |  | Cheer | ✨ Salt on the Rim | Salt crystals sparkle along the rim of your coast route maps (looks only) | flag | F | A6 |
| Mossby | mill | Repairs | ⚙️ Fern-Cleared Race | Dishes with sago palm or taro in them cook 2% faster | -2% | P items=local | F06 |
|  |  | Larder | 🥣 Sago Pearls, Sieved | Taro, sago palm, noni, kiwifruit and warrigal greens harvests: 2% chance of one extra | +2% | P items=local | F10 |
|  |  | Cheer | ⏳ Mill-Clock Regular | Your recipe book shows how long each dish takes in the pot before you start | flag | F | A5 |
| Toadstoolbrook | herb | Repairs | 🍄 Re-thatched Fern House | Pests are 2% less likely on kiwifruit, warrigal greens, taro and coconut | -2% | P items=local | F17 |
|  |  | Larder | 🥝 Fuzzy Fruit, Shady Vine | Watering lasts 2% longer on noni, kiwifruit, taro and coconut | +2% | P items=local | F12 |
|  |  | Cheer | 🐛 Glow in the Gully | In Coralscatter delves your torch burns blue-green (looks only) | flag | F | A6 |
| Miragewell | spring | Repairs | 🚰 Capped Bore, No Leaks | Rest acts at Miragewell give 1 more energy on hot, sunny or cloudy days | +1 | P from= | F22 |
|  |  | Larder | 🍞 Bush Jam on Damper | First visit to Miragewell each day: one pot of wild berry jam (`wild-berry-jam`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🦎 Drinks Through Its Feet | Your passport shows how many stamps are left to fill each region's page | flag | F | A5 |
| Oasiswick | workshop | Repairs | 🪃 Trued Boomerang | Once a day, when a walk in the Coralscatter finds nothing, your gnome looks once more (Oasiswick's boomerang comes back) | 1 a day | D from= | A2 |
|  |  | Larder | 🌰 Seed Tin with a Tight Lid | Stalls in the Coralscatter's island and desert zones charge 2% less | -2% | P region=OC | F02 |
|  |  | Cheer | 🎵 Clapsticks | Acts at stops in the Coralscatter's island and desert zones give 2% more XP | +2% | P region=OC | F03 |
| Ambercove | camp | Repairs | 🏕️ Swag Rolled Tight | Rest acts and trail rests in the Coralscatter's island and desert zones heal 2% more | +2% | P region=OC | F09 |
|  |  | Larder | 🍠 Coals Under the Sand | First lore act at Ambercove each day: one taro for the coals (`taro`) | 1 a day | D from= | A3 |
|  |  | Cheer | 🎶 Songline Hummed Back | On the Red Rock Songlines, forks you have already walked are marked with dots | flag | F | A5 |
| Kava Circle | camp | Repairs | 🥣 Re-carved Kava Bowl | Boosts from anything eaten or drunk in the Coralscatter's island and coast zones last 2% longer | +2% | P region=OC | F08 |
|  |  | Larder | ♨️ Earth Oven Opened | Dishes made with taro give 2% more energy | +2% | P items=local | F07 |
|  |  | Cheer | 🤝 Clap Once, Drink, Clap Thrice | Chats and gifts with folk in the Coralscatter's island and desert zones: 2% chance of +1 friendship | +2% | P region=OC | F14 |

## 7. Counts

| Region | Stops | Perks | W | P | D | F | World-family units used |
|---|---|---|---|---|---|---|---|
| Thornacre Savanna | 12 | 36 | 0 | 17 | 8 | 11 | 0 |
| Spicepeak | 13 | 39 | 0 | 20 | 8 | 11 | 0 |
| Blossomreach | 11 | 33 | 0 | 17 | 4 | 12 | 0 |
| The Monsoon Tangle | 13 | 39 | 0 | 24 | 5 | 10 | 0 |
| The Coralscatter | 13 | 39 | 0 | 22 | 6 | 11 | 0 |
| **All five** | **62** | **186** | **0** | **100** | **31** | **55** | **0** |

Flags: 23 information (A5), 32 looks (A6). Blossomreach is 11 new stops; with Honeythorpe it has 12 stops and 36 perks, and Honeythorpe's two world perks (garden XP 1, friendship 2) are already inside the Maplewold use above.

Perks per family (after the audit of 2026-11-27): A1 3, A2 7, A3 19, A4 2, A5 23, A6 32, F01 7, F02 4, F03 3, F04 5, F05 8, F06 7, F07 7, F08 4, F09 6, F10 9, F11 4, F12 5, F13 5, F14 4, F15 3, F16 3, F17 6, F18 3, F19 3, F21 1, F22 3.

## 8. Checks (script)

A Python script built this file from one data table and checked it. Result: 0 errors.
- All 186 perk names and all 186 effect texts are different from each other and from the 90 existing ones (54 hand-written, 36 templates) in `proposal-stop-perks.md`, compared in lower case with punctuation removed.
- Every stop has exactly one perk per bar, three different families, at most one A5 and one A6.
- No world perk; every P size is 1% or 2%, +1 or +1 step; every `region=` family is used once per region at most; every named crop is in that region's rows of `region_crops.txt` and gets a family once at most.
- Every stop type suits the stop's landscape in `stops.txt`.
- Sibling files: `proposal-stop-perks-regions-A.md` and `-B.md` did not exist yet when this was written. **Rerun 2026-11-27** across all four files (`python3 claude/tools_audit_stop_perks.py`): 0 errors after fixes. This file is the latest, so most clashes were fixed here: 9 exact duplicates (Windstead, Poppythorpe, Brambleburrow, Lilyby, Meadowbottom, Screeden, Shellnook, Emberhollow's region torch, Bogmead's fish stall) and 14 flags that repeated a theme of A or B (weather at the far end, which bar an act feeds, seal, kite, turtle, sandpiper tracks, usual price, gossip heard, roads never walked, roads walked in ink, crop regions, hours of water, steam from the pot, rain on a roof); 3 wonder flags read data the game does not keep (Great Migration, panda shoots); Palmgate, Sandpiperglen and the Baobab Inn had fast travel inside a region or to a village at -2% (now from the stop, -1%); Hollowby's apricot charge broke the one-perk-per-crop rule; Bogmead's and Tidecombe's fish stalls, the Teahouse's teas, Brineglen's dawn walks, Oasiswick's seeds and Ambercove's desert rest had the same target and condition as an earlier perk and now differ; every gift names a real item slug.

## 9. Problems hit (5)

1. **No region gets a world perk.** With 13 regions sharing what the Maplewold left, every share rounds down to 0 (the best case is 6 / 13). All 186 perks are P, D or F. If Josh wants a few world perks outside the Maplewold, they must be handed out by hand (for example 3 sell points to 3 chosen regions), not by equal share.
2. **`items=local:<stop>` cannot tell two stops apart.** `stop_local_crops()` (`stops.php:628`) returns the whole region's edible crops, the same list for every stop in the region. So crop perks here name their crops ("teff and sorghum") and are written as `items=local` narrowed to those crops; the build needs a crop-list scope that still counts as a place perk. The script made sure no crop gets the same family twice in a region.
3. **The source changed while this was written.** `proposal-stop-perks.md` went from 16 stops / 48 perks to 18 / 54 (Cattailmere, Granitegate). Budget and the uniqueness check were redone against the new text: 90 existing perks, F23 now 1 of 4 used. Honeythorpe is already written there, so Blossomreach has 11 new stops here, not 12.
4. **Landscapes are read from the route list and zone counts, not from the database.** Two are a judgement: Poppywell (grassland or forest) and Turtleburrow (island or coast). Poppywell is a camp, which suits any land; Turtleburrow is a shrine, which suits island but not coast, so check it in Admin > Places. The Monsoon Tangle has no workshop because that type suits none of its four landscapes.
5. **Some perks need things the code may not have.** New hooks: replay a lost contest, look once more on an empty walk, fishing-rod wear on a walk, tea ingredient back, an act-kind or weather test inside a scope (`we=hot`, `we=rain`, festival act). Item names (flatbread, roti, damper, hand pie, sea salt, marigold head) must be mapped to real slugs or added as common items. Information flags must be checked against what the pages already show (moon phase, usual price, hours until thirsty), and the wonder flags (Great Migration, Panda Bamboo Grove) need a daily state to read. The A and B files were not there to compare against (done since: see the checks).
