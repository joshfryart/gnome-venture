# Trail gates and extra mini-bosses outside the Maplewold: review (2026-11-14)

REVIEW ONLY: no data changed. Josh decided (2026-11-14): review all 230 generated routes, list counts per region, Josh adjusts.

Source: `game/includes/data/trail_maps/<region>_30x18.json` (the 14 region files other than `maplewold_30x18.json`; `na` = the 3 NA routes outside the hand-tuned 16). Made by `tools/add_trail_extras.py` on 2026-11-10 (2.6.40). Rules there: gate tier = region rank + 1 capped at 3 (NA 2 Sturdy, every later region 3 Fine; tools have no tier 4); a **lock** = a wall across the last section of every delve (mini-boss) / lair (boss) route, before the E tile, with a 3-tile gap on the road that needs the tool; a **short cut** = the same wall plus a second opening far along it (the long way round is 6+ steps longer), one plain route per region; an **extra mini-boss** = one large creature of the route's land on the road of one section of about every 4th plain route, level nearest 12 + 0.7 x region level, never in a gate section.

## Per region

| Region | Region Lv | Routes | Lair (boss) routes | Delve (mini-boss) routes | Locks | Short cuts | Gate tool + tier | Extra mini-bosses (creature Lv) | Routes with any extra |
|---|---|---|---|---|---|---|---|---|---|
| NA | 1 | 3 | 0 | 0 | 0 | 1 | staff 2 x1 | 1: Grass Snake 14 | 2 |
| CA | 4 | 17 | 1 | 1 | 1 | 1 | lantern 3 x1, staff 3 x1 | 4: Grass Snake 14, Mischief Monkey 15, Red Fox 16, Grass Snake 14 | 6 |
| NWE | 6 | 18 | 1 | 1 | 2 | 1 | axe 3 x1, pick 3 x2 | 4: Red Fox 16, Raccoon 16, Red Fox 16, Raccoon 16 | 7 |
| CB | 8 | 17 | 1 | 1 | 2 | 1 | axe 3 x1, staff 3 x2 | 4: Tide Crab Knight 19, Tide Crab Knight 19, Mire Toad 18, Moss Golem 20 | 7 |
| SE | 10 | 17 | 1 | 1 | 2 | 1 | lantern 3 x1, pick 3 x1, staff 3 x1 | 4: Tide Crab Knight 19, Moss Golem 20, Moss Golem 20, Tide Crab Knight 19 | 7 |
| SA | 12 | 18 | 1 | 1 | 2 | 1 | axe 3 x1, lantern 3 x1, pick 3 x1 | 4: Moss Golem 20, Moss Golem 20, Gila Dragon 20, Moss Golem 20 | 7 |
| EE | 14 | 16 | 1 | 1 | 2 | 1 | axe 3 x2, lantern 3 x1 | 3: Wild Boar 21, Beaver Foreman 22, Cliff Ram 21 | 6 |
| MENA | 17 | 19 | 1 | 1 | 2 | 1 | lantern 3 x1, pick 3 x1, staff 3 x1 | 4: Clam Lurker 23, Giant Bumblebee 23, Desert Tortoise 24, Giant Bumblebee 23 | 7 |
| EA | 20 | 17 | 1 | 1 | 1 | 1 | axe 3 x2 | 4: Jungle Tiger 26, Jungle Tiger 26, Dunegrass Camel 27, Salt Sea Lion 25 | 6 |
| CSA | 23 | 19 | 1 | 1 | 2 | 1 | axe 3 x1, lantern 3 x1, pick 3 x1 | 4: Prairie Bison 26, Prairie Bison 26, Cloud Leopard 28, Prairie Bison 26 | 7 |
| SEA | 26 | 18 | 1 | 1 | 2 | 1 | pick 3 x2, staff 3 x1 | 4: Mangrove Crab King 30, Mangrove Crab King 30, Jungle Tiger 26, Mangrove Crab King 30 | 7 |
| WCA | 29 | 17 | 1 | 1 | 2 | 1 | axe 3 x2, pick 3 x1 | 4: Honey Badger Brute 32, Mangrove Crab King 30, Reef Eel Lord 34, Fern Cassowary 36 | 7 |
| ESA | 32 | 17 | 1 | 1 | 2 | 1 | axe 3 x1, lantern 3 x1, pick 3 x1 | 4: Honey Badger Brute 32, Thunder Yak 33, Honey Badger Brute 32, Mangrove Crab King 30 | 7 |
| OC | 35 | 17 | 1 | 1 | 2 | 1 | axe 3 x1, lantern 3 x1, staff 3 x1 | 4: Deep Octopus 37, Fern Cassowary 36, Honey Badger Brute 32, Fern Cassowary 36 | 7 |
| **All 14** | | **230** | **13** | **13** | **24** | **14** | | **52** | **90** |

## The two lair / delve routes with no lock

- **327 CA** (mountain, 5 sections): Meadowmere -> Smokecap Caldera (lair). `add_trail_extras.py` found no wall line in the last section that keeps the road open without crossing a landmark, find or E tile, so it left the route without a gate.
- **448 EA** (desert, 5 sections): Honeythorpe -> Lair of the Jade Dragon-fly (lair). `add_trail_extras.py` found no wall line in the last section that keeps the road open without crossing a landmark, find or E tile, so it left the route without a gate.

## Every gate and extra mini-boss (route by route)

| Region | Route | From -> To | Kind | Section | Gate / creature | Tool + tier |
|---|---|---|---|---|---|---|
| NA | 229 | Poppyburrow -> Larkbrook | shortcut (plain) | 1 of 3 | steep short cut: a staff for the short way, the long way round is open | Hiking Staff (staff 2) |
| NA | 237 | Cloverholt -> Honeythorpe | extra mini-boss | 2 of 3 | the bramble gap: Grass Snake (`grass-snake`) | Lv 14 |
| CA | 230 | Larkbrook -> Poppynook | shortcut (plain) | 2 of 3 | steep short cut: a staff for the short way, the long way round is open | Wayfarer’s Staff (staff 3) |
| CA | 240 | Maizehollow Market -> Meadowmere | extra mini-boss | 2 of 3 | the lonely scarecrow: Grass Snake (`grass-snake`) | Lv 14 |
| CA | 317 | Larkbrook -> Frondthorpe | extra mini-boss | 2 of 2 | the parrot perch: Mischief Monkey (`mischief-monkey`) | Lv 15 |
| CA | 321 | Larkbrook -> Stonethorpe | extra mini-boss | 2 of 2 | the stone hut: Red Fox (`red-fox`) | Lv 16 |
| CA | 325 | Larkbrook -> Jaguar Root Caves | lock (delve) | 3 of 3 | dark passage: needs a lantern to find the way | Glowcap Lantern (lantern 3) |
| CA | 326 | Poppynook -> Cenote of Echoes | extra mini-boss | 2 of 3 | the trader's tent poles: Grass Snake (`grass-snake`) | Lv 14 |
| NWE | 234 | Windbottom -> Windburrow | shortcut (plain) | 2 of 3 | rocky short cut: a pick for the short way, the long way round is open | Fine Rock Hammer (pick 3) |
| NWE | 256 | Mistmoor Market -> Larkden | extra mini-boss | 3 of 3 | the bramble gap: Red Fox (`red-fox`) | Lv 16 |
| NWE | 353 | Windbottom -> Fernden | extra mini-boss | 2 of 2 | the mushroom ring: Raccoon (`raccoon`) | Lv 16 |
| NWE | 357 | Windbottom -> Froststead | extra mini-boss | 2 of 2 | the lone fir: Red Fox (`red-fox`) | Lv 16 |
| NWE | 361 | Windbottom -> Fairy-ring Clearing | extra mini-boss | 3 of 3 | the hush before Fairy-ring Clearing: Raccoon (`raccoon`) | Lv 16 |
| NWE | 362 | Windburrow -> Sea-cave Smugglers' Run | lock (delve) | 3 of 3 | rockfall: needs a pick to clear the rocks | Fine Rock Hammer (pick 3) |
| NWE | 363 | Larkden -> Barrow of the Frost Toad | lock (lair) | 5 of 5 | fallen trunk: needs an axe to chop through | Fine Felling Axe (axe 3) |
| CB | 242 | Shoreford -> Breezehollow | shortcut (plain) | 3 of 3 | steep short cut: a staff for the short way, the long way round is open | Wayfarer’s Staff (staff 3) |
| CB | 248 | The Sunsprinkle Isles Market -> Palmknoll | extra mini-boss | 2 of 3 | the lagoon edge: Tide Crab Knight (`tide-crab-knight`) | Lv 19 |
| CB | 330 | Palmknoll -> Saltgate | extra mini-boss | 2 of 2 | the sandbar causeway: Tide Crab Knight (`tide-crab-knight`) | Lv 19 |
| CB | 334 | Shoreford -> Mireburrow | extra mini-boss | 2 of 2 | the willow curtain: Mire Toad (`mire-toad`) | Lv 18 |
| CB | 338 | Breezehollow -> The Singing Waterfall | extra mini-boss | 2 of 3 | the lantern fruit: Moss Golem (`moss-golem`) | Lv 20 |
| CB | 339 | Palmknoll -> Mangrove Root Maze | lock (delve) | 4 of 4 | fallen trunk: needs an axe to chop through | Fine Felling Axe (axe 3) |
| CB | 340 | Shoreford -> Lair of the Hurricane Crab | lock (lair) | 5 of 5 | steep steps: needs a staff to climb | Wayfarer’s Staff (staff 3) |
| SE | 258 | Brinewick -> Driftmead | shortcut (plain) | 1 of 3 | rocky short cut: a pick for the short way, the long way round is open | Fine Rock Hammer (pick 3) |
| SE | 264 | Olivewhistle Shore Market -> Sprayglen | extra mini-boss | 2 of 3 | the lighthouse shadow: Tide Crab Knight (`tide-crab-knight`) | Lv 19 |
| SE | 367 | Sprayglen -> Screemere | extra mini-boss | 2 of 2 | the eagle's rest: Moss Golem (`moss-golem`) | Lv 20 |
| SE | 371 | Brinewick -> Echonook | extra mini-boss | 2 of 2 | the stone hut: Moss Golem (`moss-golem`) | Lv 20 |
| SE | 375 | Driftmead -> The Labyrinth Isle | extra mini-boss | 2 of 3 | the reef shallows: Tide Crab Knight (`tide-crab-knight`) | Lv 19 |
| SE | 376 | Sprayglen -> Pirate-gull Grottoes | lock (delve) | 3 of 3 | steep steps: needs a staff to climb | Wayfarer’s Staff (staff 3) |
| SE | 377 | Brinewick -> Forge of the Cinder Wyrm | lock (lair) | 5 of 5 | dark passage: needs a lantern to find the way | Glowcap Lantern (lantern 3) |
| SA | 246 | Barleyglen -> Windwell | shortcut (plain) | 2 of 3 | rocky short cut: a pick for the short way, the long way round is open | Fine Rock Hammer (pick 3) |
| SA | 250 | Thistlebottom -> Flintburrow | extra mini-boss | 3 of 3 | the goat ledge: Moss Golem (`moss-golem`) | Lv 20 |
| SA | 341 | Barleyglen -> Stoneden | extra mini-boss | 2 of 2 | the rope bridge: Moss Golem (`moss-golem`) | Lv 20 |
| SA | 345 | Highcove -> Scorchby | extra mini-boss | 2 of 2 | the sun-bleached bones: Gila Dragon (`desert-gila-dragon`) | Lv 20 |
| SA | 349 | Flintburrow -> Condor's Crag | lock (lair) | 4 of 4 | dark passage: needs a lantern to find the way | Glowcap Lantern (lantern 3) |
| SA | 350 | Highcove -> Pink River Dolphin Pools | extra mini-boss | 3 of 4 | the rain-drum leaf: Moss Golem (`moss-golem`) | Lv 20 |
| SA | 351 | Barleyglen -> Anaconda Hollows | lock (delve) | 4 of 4 | fallen trunk: needs an axe to chop through | Fine Felling Axe (axe 3) |
| EE | 262 | Thistleburrow -> Haynook | shortcut (plain) | 1 of 3 | overgrown short cut: an axe for the short way, the long way round is open | Fine Felling Axe (axe 3) |
| EE | 268 | Birchbramble Steppe Market -> Tussockgate | extra mini-boss | 3 of 3 | the sleepy windmill: Wild Boar (`wild-boar`) | Lv 21 |
| EE | 380 | Tussockgate -> Fernford | extra mini-boss | 2 of 2 | the owl-watch bough: Beaver Foreman (`beaver-foreman`) | Lv 22 |
| EE | 384 | Thistleburrow -> Flintknoll | extra mini-boss | 2 of 2 | the goat ledge: Cliff Ram (`cliff-ram`) | Lv 21 |
| EE | 387 | Thistleburrow -> Salt Mine Galleries | lock (delve) | 3 of 3 | fallen trunk: needs an axe to chop through | Fine Felling Axe (axe 3) |
| EE | 389 | Tussockgate -> Lair of the Grey Wolf King | lock (lair) | 5 of 5 | dark passage: needs a lantern to find the way | Glowcap Lantern (lantern 3) |
| MENA | 266 | Gullwell -> Gullstead | shortcut (plain) | 2 of 3 | steep short cut: a staff for the short way, the long way round is open | Wayfarer’s Staff (staff 3) |
| MENA | 272 | The Dunewhisper Market -> Brineburrow | extra mini-boss | 2 of 3 | the shell-heap: Clam Lurker (`clam-lurker`) | Lv 23 |
| MENA | 390 | Gullwell -> Windford | extra mini-boss | 2 of 2 | the lonely scarecrow: Giant Bumblebee (`giant-bumblebee`) | Lv 23 |
| MENA | 394 | Gullwell -> Ambercrest | extra mini-boss | 2 of 2 | the salt flat: Desert Tortoise (`desert-tortoise`) | Lv 24 |
| MENA | 398 | Gullwell -> The Hanging Garden Ruins | extra mini-boss | 2 of 3 | the old milestone: Giant Bumblebee (`giant-bumblebee`) | Lv 23 |
| MENA | 401 | Meadowbrook -> Rose-red Canyon City | lock (delve) | 4 of 4 | dark passage: needs a lantern to find the way | Glowcap Lantern (lantern 3) |
| MENA | 402 | Gullwell -> Tomb of the Sand Scarab | lock (lair) | 5 of 5 | rockfall: needs a pick to clear the rocks | Fine Rock Hammer (pick 3) |
| EA | 238 | Honeythorpe -> Clovercove | shortcut (plain) | 2 of 3 | overgrown short cut: an axe for the short way, the long way round is open | Fine Felling Axe (axe 3) |
| EA | 290 | Poppywell -> Bramblebrook | extra mini-boss | 2 of 3 | the owl-watch bough: Jungle Tiger (`jungle-tiger`) | Lv 26 |
| EA | 438 | Honeythorpe -> Brambleburrow | extra mini-boss | 2 of 2 | the fern tunnel: Jungle Tiger (`jungle-tiger`) | Lv 26 |
| EA | 442 | Birchford -> Dunewick | extra mini-boss | 2 of 2 | the shade awning: Dunegrass Camel (`desert-camel`) | Lv 27 |
| EA | 446 | Bramblebrook -> Pearl Diver Cove | extra mini-boss | 2 of 3 | the bottle post: Salt Sea Lion (`salt-sea-lion`) | Lv 25 |
| EA | 447 | Birchford -> The Long Wall Walk | lock (delve) | 4 of 4 | fallen trunk: needs an axe to chop through | Fine Felling Axe (axe 3) |
| CSA | 270 | Newtdell -> Rushdell | shortcut (plain) | 1 of 3 | rocky short cut: a pick for the short way, the long way round is open | Fine Rock Hammer (pick 3) |
| CSA | 278 | Heronby -> Cloverburrow | extra mini-boss | 2 of 3 | the clover patch: Prairie Bison (`prairie-bison`) | Lv 26 |
| CSA | 289 | Poppythorpe -> Poppywell | extra mini-boss | 3 of 3 | the shepherd's wall: Prairie Bison (`prairie-bison`) | Lv 26 |
| CSA | 429 | Rushdell -> Cliffmead | extra mini-boss | 2 of 2 | the waterfall mist: Cloud Leopard (`cloud-leopard`) | Lv 28 |
| CSA | 433 | Poppythorpe -> The Silk Road Caravanserai | extra mini-boss | 3 of 3 | the hush before The Silk Road Caravanserai: Prairie Bison (`prairie-bison`) | Lv 26 |
| CSA | 435 | Newtdell -> Temple of the Tiger Moth | lock (lair) | 4 of 4 | fallen trunk: needs an axe to chop through | Fine Felling Axe (axe 3) |
| CSA | 437 | Heronby -> Snowleopard Ledges | lock (delve) | 4 of 4 | dark passage: needs a lantern to find the way | Glowcap Lantern (lantern 3) |
| SEA | 294 | Marshcrest -> Rushglen | shortcut (plain) | 1 of 3 | rocky short cut: a pick for the short way, the long way round is open | Fine Rock Hammer (pick 3) |
| SEA | 298 | Lilyby -> Sandpiperglen | extra mini-boss | 3 of 3 | the driftwood arch: Mangrove Crab King (`mangrove-crab-king`) | Lv 30 |
| SEA | 449 | Marshcrest -> Sandpiperhollow | extra mini-boss | 2 of 2 | the kelp-line: Mangrove Crab King (`mangrove-crab-king`) | Lv 30 |
| SEA | 453 | Shellnook -> Monsoonburrow | extra mini-boss | 2 of 2 | the parrot perch: Jungle Tiger (`jungle-tiger`) | Lv 26 |
| SEA | 457 | Sandpiperglen -> Volcano Spice Gardens | extra mini-boss | 3 of 3 | the hush before Volcano Spice Gardens: Mangrove Crab King (`mangrove-crab-king`) | Lv 30 |
| SEA | 458 | Shellnook -> Dragonlizard Den | lock (lair) | 4 of 4 | rockfall: needs a pick to clear the rocks | Fine Rock Hammer (pick 3) |
| SEA | 460 | Rushglen -> Firefly Caves | lock (delve) | 4 of 4 | steep steps: needs a staff to climb | Wayfarer’s Staff (staff 3) |
| WCA | 274 | Cloverbottom -> Thistleholt | shortcut (plain) | 2 of 3 | overgrown short cut: an axe for the short way, the long way round is open | Fine Felling Axe (axe 3) |
| WCA | 280 | The Greatcanopy Market -> Hayglen | extra mini-boss | 3 of 3 | the daisy ring: Honey Badger Brute (`honey-badger-brute`) | Lv 32 |
| WCA | 405 | Hayglen -> Heronwick | extra mini-boss | 2 of 2 | the willow curtain: Mangrove Crab King (`mangrove-crab-king`) | Lv 30 |
| WCA | 409 | Cloverbottom -> Driftglen | extra mini-boss | 2 of 2 | the shell-heap: Reef Eel Lord (`reef-eel-lord`) | Lv 34 |
| WCA | 413 | Thistleholt -> Gorilla Glade | extra mini-boss | 4 of 4 | the hush before Gorilla Glade: Fern Cassowary (`fern-cassowary`) | Lv 36 |
| WCA | 414 | Hayglen -> The Canopy Bridges | lock (delve) | 4 of 4 | rockfall: needs a pick to clear the rocks | Fine Rock Hammer (pick 3) |
| WCA | 415 | Cloverbottom -> Hollow of the Silverback Spider | lock (lair) | 5 of 5 | fallen trunk: needs an axe to chop through | Fine Felling Axe (axe 3) |
| ESA | 282 | Meadowden -> Clovergate | shortcut (plain) | 1 of 3 | rocky short cut: a pick for the short way, the long way round is open | Fine Rock Hammer (pick 3) |
| ESA | 284 | Thornacre Savanna Market -> Meadowbottom | extra mini-boss | 2 of 3 | the picnic knoll: Honey Badger Brute (`honey-badger-brute`) | Lv 32 |
| ESA | 417 | Clovergate -> Echoford | extra mini-boss | 2 of 2 | the rope bridge: Thunder Yak (`thunder-yak`) | Lv 33 |
| ESA | 421 | Clovergate -> Amberburrow | extra mini-boss | 2 of 2 | the sun-bleached bones: Honey Badger Brute (`honey-badger-brute`) | Lv 32 |
| ESA | 425 | Clovergate -> Snowcrown Peak | lock (lair) | 4 of 4 | dark passage: needs a lantern to find the way | Glowcap Lantern (lantern 3) |
| ESA | 426 | Meadowbottom -> Flamingo Shallows | extra mini-boss | 2 of 3 | the stilt-house: Mangrove Crab King (`mangrove-crab-king`) | Lv 30 |
| ESA | 427 | Summitglen -> Fynbos Fire Trails | lock (delve) | 4 of 4 | fallen trunk: needs an axe to chop through | Fine Felling Axe (axe 3) |
| OC | 254 | Palmgate -> Reefknoll | shortcut (plain) | 2 of 3 | steep short cut: a staff for the short way, the long way round is open | Wayfarer’s Staff (staff 3) |
| OC | 302 | Turtleburrow -> Brineglen | extra mini-boss | 2 of 3 | the bottle post: Deep Octopus (`deep-octopus`) | Lv 37 |
| OC | 463 | Turtleburrow -> Mossby | extra mini-boss | 2 of 2 | the lantern branch: Fern Cassowary (`fern-cassowary`) | Lv 36 |
| OC | 467 | Turtleburrow -> Ambercove | extra mini-boss | 2 of 2 | the well and its rope: Honey Badger Brute (`honey-badger-brute`) | Lv 32 |
| OC | 471 | Turtleburrow -> Reef of the Box Jelly Queen | lock (lair) | 4 of 4 | fallen trunk: needs an axe to chop through | Fine Felling Axe (axe 3) |
| OC | 472 | Brineglen -> Stone Head Watchers | extra mini-boss | 3 of 3 | the hush before Stone Head Watchers: Fern Cassowary (`fern-cassowary`) | Lv 36 |
| OC | 473 | Palmgate -> The Red Rock Songlines | lock (delve) | 4 of 4 | dark passage: needs a lantern to find the way | Glowcap Lantern (lantern 3) |

## Notes for Josh (what to look at when adjusting)

- Every region from CA on has the same shape: 1 lock on its lair route, 1 lock on its delve route, 1 short cut, 3-4 extra mini-bosses. NA (3 routes) has only 1 short cut (Sturdy staff) and 1 extra mini-boss.
- Every gate outside NA asks for a **Fine** (tier 3) tool, from CA (region Lv 4) to OC (Lv 35): the tier cap of 3 flattens the curve. A CA gnome meets a Fine-tool lock on its first lair road. Options: tier 2 for the early regions (CA, NWE, CB), tier 3 from SE on.
- Locks block the lair / delve itself: without the tool the gnome cannot reach the boss / mini-boss at all (the short cuts never block). The 2 routes without a lock (327 CA, 448 EA) are therefore the only lair roads open to everyone.
- Extra mini-boss levels follow 12 + 0.7 x region level, so CA's are 14-16 (region Lv 4) and even NA's one (route 229 area, region Lv 1) is a Lv 14 Grass Snake, while OC's are 32-37 (Lv 35): early regions get fights well above their road level.
- Gone-open gates show no mark (known, todo.md section 4); nothing here was walked in a browser.
