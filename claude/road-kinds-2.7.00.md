# Road kinds 2.7.00: draft route list (veto me)

Draft by `tools/draft_road_kinds.py` from the route data (`claude/bend-prototype-v2/`). Nothing is in the game yet. Kinds and rules: `claude/plan-2.7.00.md` item 5. One route per kind per region where the land fits (`-` = no fitting route: say if you want a pick anyway). **Tier** is for tunnel (lantern) and pass (staff) only: Sturdy (2) up to region level 12, Fine (3) after (those tools stop at tier 3). A route keeps one kind. Routes that already have a tool gate or a boss are skipped.

Veto: strike a row, or write the route id you want instead.

| Region (lvl) | Route | From to | Land | Path | Kind | Rule | Tier | Why |
|---|---|---|---|---|---|---|---|---|
| NA (1) | 308 | Honeybrook to Pebblestead | coast | trail | ferry | pay 20 Petals per crossing | - | 264 water cells over 2 sections |
| NA (1) | 309 | Cloverholt to Iciclecrest | tundra | trail | tunnel | lantern gate | 2 | tundra route, 2 sections |
| NA (1) | 310 | Poppyburrow to Snowcombe | tundra | trail | pass | staff gate | 2 | tundra route, 2 sections |
| NA (1) | 228 | The Maplewold Market to Poppyburrow | grassland | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| NA (1) | 304 | Poppyburrow to Acornby | forest | trail | overgrown | +10 game min per section; axe = none | - | forest route, 2 sections |
| NA (1) | 307 | Poppyburrow to Shellhollow | coast | trail | flooded | +10 game min per section; flood boots +5 | - | 213 water cells, coast |
| CA (4) | 241 | Meadowmere to Shoreford | island | exit | ferry | pay 20 Petals per crossing | - | 251 water cells over 3 sections |
| CA (4) | 321 | Larkbrook to Stonethorpe | mountain | trail | tunnel | lantern gate | 2 | mountain route, 2 sections |
| CA (4) | 322 | Poppynook to Flintcove | mountain | trail | pass | staff gate | 2 | mountain route, 2 sections |
| CA (4) | 231 | Poppynook to Maizehollow Market | grassland | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| CA (4) | 244 | Maizehollow Market to Jadedell | rainforest | road | overgrown | +10 game min per section; axe = none | - | rainforest route, 3 sections |
| CA (4) | 324 | Jadedell to The Stepped Seed Temple | rainforest | trail | flooded | +10 game min per section; flood boots +5 | - | 16 water cells, rainforest |
| NWE (6) | 257 | Larkden to Brinewick | coast | exit | ferry | pay 20 Petals per crossing | - | 169 water cells over 3 sections |
| NWE (6) | 357 | Windbottom to Froststead | tundra | trail | tunnel | lantern gate | 2 | tundra route, 2 sections |
| NWE (6) | 358 | Windburrow to Sleetford | tundra | trail | pass | staff gate | 2 | tundra route, 2 sections |
| NWE (6) | 235 | Windburrow to Mistmoor Market | grassland | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| NWE (6) | 260 | Mistmoor Market to Hollowknoll | forest | road | overgrown | +10 game min per section; axe = none | - | forest route, 3 sections |
| NWE (6) | 355 | Larkden to Spraywell | coast | trail | flooded | +10 game min per section; flood boots +5 | - | 142 water cells, coast |
| CB (8) | 243 | Breezehollow to The Sunsprinkle Isles Market | island | road | ferry | pay 20 Petals per crossing | - | 160 water cells over 3 sections |
| CB (8) | 328 | Shoreford to Sandpipergate | coast | trail | tunnel | lantern gate | 2 | coast route, 2 sections (different land: nothing mountain here) |
| CB (8) | 329 | Breezehollow to Foamknoll | coast | trail | pass | staff gate | 2 | coast route, 2 sections (different land: nothing mountain here) |
| CB (8) | 248 | The Sunsprinkle Isles Market to Palmknoll | island | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| CB (8) | 331 | Shoreford to Lianacombe | rainforest | trail | overgrown | +10 game min per section; axe = none | - | rainforest route, 2 sections |
| CB (8) | 336 | Palmknoll to Sunken Gnome Galleon | coast | trail | flooded | +10 game min per section; flood boots +5 | - | 165 water cells, coast |
| SE (10) | 375 | Driftmead to The Labyrinth Isle | island | trail | ferry | pay 20 Petals per crossing | - | 254 water cells over 3 sections |
| SE (10) | 365 | Brinewick to Cliffbrook | mountain | trail | tunnel | lantern gate | 2 | mountain route, 2 sections |
| SE (10) | 366 | Driftmead to Screebottom | mountain | trail | pass | staff gate | 2 | mountain route, 2 sections |
| SE (10) | 259 | Driftmead to Olivewhistle Shore Market | coast | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| SE (10) | 264 | Olivewhistle Shore Market to Sprayglen | coast | road | overgrown | +10 game min per section; axe = none | - | coast route, 3 sections (different land: nothing wooded here) |
| SE (10) | 372 | Driftmead to Olive Press Piazza | coast | trail | flooded | +10 game min per section; flood boots +5 | - | 143 water cells, coast |
| SA (12) | 253 | Highcove to Palmgate | island | exit | ferry | pay 20 Petals per crossing | - | 225 water cells over 3 sections |
| SA (12) | 341 | Barleyglen to Stoneden | mountain | trail | tunnel | lantern gate | 2 | mountain route, 2 sections |
| SA (12) | 348 | Thistlebottom to The Sky City Ruins | mountain | trail | pass | staff gate | 2 | mountain route, 3 sections |
| SA (12) | 247 | Windwell to The Rainroot Reaches Market | grassland | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| SA (12) | 342 | Windwell to Figknoll | rainforest | trail | overgrown | +10 game min per section; axe = none | - | rainforest route, 2 sections |
| SA (12) | 343 | Thistlebottom to Frondstead | rainforest | trail | flooded | +10 game min per section; flood boots +5 | - | 60 water cells, rainforest |
| EE (14) | 382 | Haynook to Reedby | wetland | trail | ferry | pay 20 Petals per crossing | - | 34 water cells over 2 sections |
| EE (14) | 383 | Tussockgate to Echohollow | mountain | trail | tunnel | lantern gate | 3 | mountain route, 2 sections |
| EE (14) | 384 | Thistleburrow to Flintknoll | mountain | trail | pass | staff gate | 3 | mountain route, 2 sections |
| EE (14) | 263 | Haynook to Birchbramble Steppe Market | grassland | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| EE (14) | 378 | Thistleburrow to Hazelthorpe | forest | trail | overgrown | +10 game min per section; axe = none | - | forest route, 2 sections |
| EE (14) | 388 | Haynook to Stork Chimney Village | wetland | trail | flooded | +10 game min per section; flood boots +5 | - | 27 water cells, wetland |
| MENA (17) | 267 | Gullstead to The Dunewhisper Market | coast | road | ferry | pay 20 Petals per crossing | - | 185 water cells over 3 sections |
| MENA (17) | 392 | Brineburrow to Craghollow | mountain | trail | tunnel | lantern gate | 3 | mountain route, 2 sections |
| MENA (17) | 393 | Meadowbrook to Cragmead | mountain | trail | pass | staff gate | 3 | mountain route, 2 sections |
| MENA (17) | 272 | The Dunewhisper Market to Brineburrow | coast | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| MENA (17) | 276 | The Dunewhisper Market to Meadowbrook | grassland | road | overgrown | +10 game min per section; axe = none | - | grassland route, 3 sections (different land: nothing wooded here) |
| MENA (17) | 397 | Meadowbrook to Spice Souk | coast | trail | flooded | +10 game min per section; flood boots +5 | - | 104 water cells, coast |
| EA (20) | 446 | Bramblebrook to Pearl Diver Cove | coast | trail | ferry | pay 20 Petals per crossing | - | 234 water cells over 3 sections |
| EA (20) | 441 | Bramblebrook to Coppergate | desert | trail | tunnel | lantern gate | 3 | desert route, 2 sections (different land: nothing mountain here) |
| EA (20) | 442 | Birchford to Dunewick | desert | trail | pass | staff gate | 3 | desert route, 2 sections (different land: nothing mountain here) |
| EA (20) | 239 | Clovercove to Blossomreach Market | grassland | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| EA (20) | 290 | Poppywell to Bramblebrook | forest | road | overgrown | +10 game min per section; axe = none | - | forest route, 3 sections |
| EA (20) | 439 | Clovercove to Sprayholt | coast | trail | flooded | +10 game min per section; flood boots +5 | - | 184 water cells, coast |
| CSA (23) | 293 | Leafmead to Marshcrest | wetland | exit | ferry | pay 20 Petals per crossing | - | 29 water cells over 3 sections |
| CSA (23) | 429 | Rushdell to Cliffmead | mountain | trail | tunnel | lantern gate | 3 | mountain route, 2 sections |
| CSA (23) | 430 | Heronby to Pinecrest | mountain | trail | pass | staff gate | 3 | mountain route, 2 sections |
| CSA (23) | 271 | Rushdell to Spicepeak Market | wetland | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| CSA (23) | 292 | Spicepeak Market to Leafmead | forest | road | overgrown | +10 game min per section; axe = none | - | forest route, 3 sections |
| CSA (23) | 270 | Newtdell to Rushdell | wetland | road | flooded | +10 game min per section; flood boots +5 | - | 1 water cells, wetland |
| SEA (26) | 457 | Sandpiperglen to Volcano Spice Gardens | island | trail | ferry | pay 20 Petals per crossing | - | 200 water cells over 3 sections |
| SEA (26) | 449 | Marshcrest to Sandpiperhollow | coast | trail | tunnel | lantern gate | 3 | coast route, 2 sections (different land: nothing mountain here) |
| SEA (26) | 456 | Lilyby to Lantern Festival River | coast | trail | pass | staff gate | 3 | coast route, 3 sections (different land: nothing mountain here) |
| SEA (26) | 295 | Rushglen to The Monsoon Tangle Market | wetland | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| SEA (26) | 452 | Sandpiperglen to Canopyford | rainforest | trail | overgrown | +10 game min per section; axe = none | - | rainforest route, 2 sections |
| SEA (26) | 300 | The Monsoon Tangle Market to Shellnook | coast | road | flooded | +10 game min per section; flood boots +5 | - | 243 water cells, coast |
| WCA (29) | 409 | Cloverbottom to Driftglen | coast | trail | ferry | pay 20 Petals per crossing | - | 114 water cells over 2 sections |
| WCA (29) | 410 | Thistleholt to Pebblenook | coast | trail | tunnel | lantern gate | 3 | coast route, 2 sections (different land: nothing mountain here) |
| WCA (29) | 411 | Hayglen to Drum Circle Market | grassland | trail | pass | staff gate | 3 | grassland route, 2 sections (different land: nothing mountain here) |
| WCA (29) | 275 | Thistleholt to The Greatcanopy Market | grassland | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| WCA (29) | 406 | Cloverbottom to Vineden | rainforest | trail | overgrown | +10 game min per section; axe = none | - | rainforest route, 2 sections |
| WCA (29) | 403 | Cloverbottom to Fenmead | wetland | trail | flooded | +10 game min per section; flood boots +5 | - | 1 water cells, wetland |
| ESA (32) | 418 | Meadowbottom to Bogmead | wetland | trail | ferry | pay 20 Petals per crossing | - | 6 water cells over 2 sections |
| ESA (32) | 416 | Meadowden to Pinecombe | mountain | trail | tunnel | lantern gate | 3 | mountain route, 2 sections |
| ESA (32) | 417 | Clovergate to Echoford | mountain | trail | pass | staff gate | 3 | mountain route, 2 sections |
| ESA (32) | 283 | Clovergate to Thornacre Savanna Market | grassland | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| ESA (32) | 419 | Summitglen to Newtcombe | wetland | trail | overgrown | +10 game min per section; axe = none | - | wetland route, 2 sections (different land: nothing wooded here) |
| ESA (32) | 426 | Meadowbottom to Flamingo Shallows | wetland | trail | flooded | +10 game min per section; flood boots +5 | - | 3 water cells, wetland |
| OC (35) | 255 | Reefknoll to The Coralscatter Market | island | road | ferry | pay 20 Petals per crossing | - | 190 water cells over 3 sections |
| OC (35) | 465 | Palmgate to Miragewell | desert | trail | tunnel | lantern gate | 3 | desert route, 2 sections (different land: nothing mountain here) |
| OC (35) | 466 | Reefknoll to Oasiswick | desert | trail | pass | staff gate | 3 | desert route, 2 sections (different land: nothing mountain here) |
| OC (35) | 303 | Brineglen to The Coralscatter Market | coast | road | toll | pay 10 Petals once per route; safer, faster | - | road between markets/ports |
| OC (35) | 463 | Turtleburrow to Mossby | forest | trail | overgrown | +10 game min per section; axe = none | - | forest route, 2 sections |
| OC (35) | 302 | Turtleburrow to Brineglen | coast | road | flooded | +10 game min per section; flood boots +5 | - | 189 water cells, coast |

84 routes picked of 246.
