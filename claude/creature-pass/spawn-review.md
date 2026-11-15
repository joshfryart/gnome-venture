# Creature spawn review (2.7.00, branch ccr-0df52ad6-jm533i)

Read-only review. Method: read the spawn code; installed the working tree into a scratch SQLite copy and dumped locations / routes / creatures; joined them to `data/trail_maps/*.json`, `trail_camps.json`, `road_kinds.txt`. Route ids below are the ids the map data uses (see bug B1: a fresh install numbers 234 routes one lower). Pool = what `pick_creature()` can return. `+g` = the walk level is max(gnome level, the number shown). Sizes S/M/L/B. `slug14` = creature at level 14.

## 0. Headlines

1. One picker serves roads, Trail tiles, camp Wait, explore, delves: `pick_creature(land, level)`. Its only inputs are the **destination's landscape**, the **walk level**, the cond tag (x3 weight, never excludes) and a no-repeat ring. Region, route id, stretch, tile, set piece, road kind and camp are not inputs. Treks use their own zone pools.
2. A creature is eligible when `level - 6 <= creature level <= level + 2`. So each creature is on-level for a 9-level window.
3. Land is taken from the place you walk **to**. 172 of 245 routes have a different land on the way back (side paths: forest/tundra/desert out, grassland back). The map art land (`trail_maps` `land`) always equals the outbound land.
4. No small creature exists above L5. Medium stops at L11 (forest), L12 (grassland, island), L13 (coast), L15 (desert), L16-18 (wetland, rainforest, mountain, tundra) until three L27-35 mediums. Pools at L19-28 are all large.
5. Late game is empty: from L30 most lands have 1-3 candidates, from L36 1-2; forest L33, wetland L37+, tundra L35+, mountain L40 have none on-level (a weaker one is scaled up). The four top regions (SEA 26, WCA 29, ESA 32, OC 35) always walk at gnome level, so this is where their walks sit.
6. Tundra exists only in NA (L1) and NWE (L6) (and one explore step in EE). 7 tundra-capable creatures L11-28 have no tundra host level; glacier-bear, lichen-reindeer and snow-owl-monarch have no region fit at all. NA tundra side paths have 2 candidates (aphids, ants).
7. Wonder and delve side paths have absolute levels (1-5, 8-12, 18-22, 10-14, 20-24) unrelated to the region: -34 (OC Starpath Canoe L1-5 in a L35 region) to +12 (CB Mangrove Root Maze L20-24 in a L8 region).
8. 56 fixed extra mini-bosses sit on route tiles; 27 are 8+ levels over the route (max +28), 5 block the only path.
9. The "boss" spot on 9 of 14 lair routes cannot find a boss and gives an ordinary creature (NA: Grumpy Lemming class).
10. Fresh installs: route ids from 239 up are one lower than the map / camp / road-kind data; 13 lair routes get a section count that differs from their authored map.

## 1. How spawn selection works

### 1.1 The picker

| step | rule | code |
|---|---|---|
| source rows | `creatures` table, `active = 1` (88 wild, 35 trek with landscape `trek`, 14 lair bosses `boss-*` inactive) | `includes/road_life.php:171` `road_rows()`; import `includes/adventure_data.php:339` |
| land fit | `landscapes == 'any'` or land in the comma list | `includes/adventure.php:352` |
| easy road | cap > 0: no boss, level = min(level, cap), nothing above cap | `adventure.php:350`, `exp_easy_cap()` `adventure.php:307` |
| boss | only if `allowBoss`: 6% roll, boss of that land with level <= walk level + 8; scaled up if below | `adventure.php:356-360` |
| ordinary band | non-boss, fits land, `level-6 <= Lv <= level+2` (`hi = cap` on easy roads) | `adventure.php:361-363` |
| band empty | strongest ones `<= level+2` (within 4 levels of the best) grown to `level - rand(0..2)` at 60% growth / 75% HP (100% in wild country) | `adventure.php:369-373`, `combat_math.php:67` `scale_creature()` |
| nothing `<= level+2` | weakest creature of the land, unscaled (unreachable today: the three `any` creatures are L1, L2, L5) | `adventure.php:364-368` |
| weighting | `road_pick()`: cond matches now = x3; cond not matching = x1 (a leading `!` makes it a must: 0); last 3 picked creatures excluded, the 5 before them x0.3 | `road_life.php:99` `road_cond_weight()`, `road_life.php:116` `road_pick_k()`, consts `road_life.php:20-23` |
| "now" | daypart, season, weather of the **destination's region** (`dp` dawn/day/dusk/night, `se`, `we` sun/cloud/rain/storm/frost/heat/wind/fog/snow) | `road_life.php:79` `road_now()`, `stops.php:403` `stop_now()`, `stops.php:425` |

### 1.2 Land and level per activity

| activity | land | level | boss? | fight chance | code |
|---|---|---|---|---|---|
| road / side path, timer walk (`gnav_tiles` off, the default) | landscape of the place walked to; if empty (markets) the start place; else grassland | see 1.3 | only on fixed routes (`!scaled`) | 40% of spaces (`road_roll_creature`) | `adventure.php:316` `exp_scene()`, `adventure.php:442` `next_step()` (pick at :460) |
| Trail tiles: random fight `R` | same | same | never | per tile walked: 3% (`trail_enc_pct`), rough `,` tile x2.5, Sneak x0.4, Hunt x2.5, paid toll x0.5; never within 3 tiles (Manhattan) of the entry or exit | `trail_art.php:284` `trail_encounter_index()`, `trail_tiles.php:346`, `trail_tiles.php:274` `trail_token_event()` |
| Trail tiles: between stretches | same | same | fixed routes only | 60% an event; of those 40% a creature (= 24% per door); not on a stretch already walked | `trail_tiles.php:298` `trail_roll_event()` -> `next_step()` |
| Trail tiles: `E` spot (last stretch of a delve / lair route) | same | same | lair: boss of the land `<= L+8`, uniform random; delve: any large of the land `<= L+4`, uniform, grown to L; none found: ordinary pick | - | fixed | `trail_tiles.php:239` `trail_pick_fixed()` |
| Trail tiles: `M` extra mini-boss | ignores land | the creature's own level from the map data (grown if higher) | - | fixed tile; easy road: a find instead | `trail_tiles.php:262` `trail_extra_mini_creature()` |
| Camp spot: Wait | same as the route, as walked | same | never | wait > 30 min 25%, <= 30 min 5%; paid toll halves; Sleep and Nap never | `trail_camps.php:47,60,87` |
| Explore (off the path) | step 1 the stop's land; step 2 a neighbour land (`stop_near_land`); steps 3-4 zone 2, 5-6 zone 3, 7+ zone 4 | stop base + 0,0,1,2,3,5,7,9...; from step 9 at least gnome+1 (+1 a step, max gnome+10) | from step 7, full strength | 27% of steps | `explore.php:37-65`, `:68`, `:96`, `:116`, pick at `:233` |
| Delve (list) | the delve's landscape | landmark level + room - 1; chest guardian +2 | never | room: 45% creature; last room always | `landmarks.php:345` |
| Delve v2 (map) | same | landmark level + stage (+2 guardian); wandering: between stage-2 and stage+3, pulled toward the gnome | never | F / B tiles and wandering | `delve_v2.php:110,264,282` |
| Lair | - | the lair's own boss (`boss-<slug>`, inactive in the pool) | - | fixed | `landmarks.php:403,557` |
| Trek | zone letter of the chapter map | creature file level (+ tune rows); chapter I grown to at most trek base - 1 | scripted | `trek_enc_percent` 9% x zone mult per step | `trek_data.php:474`, `trek.php:710,716`, `trek_fight.php:69,86` |
| Rest stops, road events, sights | no fights | - | - | - | no `pick_creature` call in `stops.php`, `road_events.txt`, `trail_sights*.php` |

### 1.3 Walk level (`route_danger()`, `adventure.php:163`; stored on the walk at `adventure.php:263`)

| route | level | scaled flag |
|---|---|---|
| not `fixed`, one end is near home (market, hub, haven, a village with your garden, your home village) | max(gnome Lv, floor); easy roads on: capped at gnome Lv - 3, no bosses | yes |
| other road, or side path not `fixed` | floor if floor < 25 (`road_fixed_below`), else max(gnome Lv, floor) | yes |
| `fixed` side path (wonder, delve, lair) | random in `min_level..max_level`, absolute, max 40 | no (bosses allowed, full strength) |

`floor` = the higher `location_min_level()` of the two ends (`progression.php:36`): region level (`REGION_LEVELS`, `progression.php:10`: NA 1, CA 4, NWE 6, CB 8, SE 10, SA 12, EE 14, MENA 17, EA 20, CSA 23, SEA 26, WCA 29, ESA 32, OC 35), with the first village over a border halfway between the two.

Result: gnome level only matters near home and in SEA / WCA / ESA / OC. Everywhere else a road is at the region's level whatever the gnome is.

## 2. Regions, landscapes, candidates

### 2.1 Creature ladder per landscape (88 creatures: 10 S, 27 M, 42 L, 9 B)

"Thin levels" = walk levels where the on-level pool has fewer than 3 (or is empty and gets scaled).

| land | n (S/M/L/B) | ladder (level: creatures) | thin levels (n<3; scaled = none on-level) |
|---|---|---|---|
| grassland | 23 (6/9/7/1) | aphid-swarm1, garden-snail1, ant-scouts2, dusk-moth3, dung-beetle3, earwig4, orb-spider5, paper-wasp6, barn-rat8, sun-lizard8, tunnel-mole9, carrion-crow9, thistle-beast12, grass-snake14, red-fox16, badger18, wild-boar21, giant-bumblebee23, prairie-bison26, great-hawk28B, savanna-hyena29, honey-badger-brute32, outback-dingo35 | 36(n=2) 37(n=2) 38(n=2) 39(n=1) 40(n=1) |
| forest | 26 (6/6/13/1) | aphid-swarm1, garden-snail1, ant-scouts2, leopard-slug2, dusk-moth3, earwig4, orb-spider5, paper-wasp6, barn-rat8, tunnel-mole9, carrion-crow9, giant-centipede11, red-fox16, raccoon16, tawny-owl17, badger18, moss-golem20, wild-boar21, bramble-wolf22, beaver-foreman22, giant-bumblebee23, tufted-lynx23, black-bear25, jungle-tiger26, old-bramblehorn30B, fern-cassowary36 | 30(n=2) 31(n=2) 32(n=1) 33(scaled) 34(n=1) 35(n=1) 36(n=1) 37(n=1) 38(n=1) 39(n=1) 40(n=1) |
| wetland | 21 (6/5/9/1) | aphid-swarm1, garden-snail1, ant-scouts2, gnat-cloud2, leopard-slug2, earwig4, orb-spider5, bog-leech6, bullfrog7, will-o-wisp13, grass-snake14, grey-heron15, raccoon16, poison-dart-frog16, mire-toad18, bog-pike20, beaver-foreman22, delta-gharial24, emerald-python25, ancient-snapper28B, mangrove-crab-king30 | 31(n=2) 32(n=1) 33(n=1) 34(n=1) 35(n=1) 36(n=1) 37(scaled) 38(scaled) 39(scaled) 40(scaled) |
| coast | 20 (4/7/8/1) | aphid-swarm1, garden-snail1, ant-scouts2, sand-fleas3, orb-spider5, shore-crab7, barn-rat8, herring-gull10, hermit-crab-hoarder12, sea-otter-bandit13, grey-heron15, tide-crab-knight19, pelican-parliament21, clam-lurker23, salt-sea-lion25, spice-monitor27, reef-leviathan29B, mangrove-crab-king30, reef-eel-lord34, deep-octopus37 | 34(n=2) 37(n=2) 38(n=2) 39(n=2) 40(n=2) |
| island | 16 (3/5/7/1) | aphid-swarm1, ant-scouts2, sand-fleas3, orb-spider5, shore-crab7, herring-gull10, hermit-crab-hoarder12, reef-turtle16, tide-crab-knight19, pelican-parliament21, coconut-crab-titan26B, spice-monitor27, mangrove-crab-king30, reef-eel-lord34, fern-cassowary36, deep-octopus37 | 23(n=2) 24(n=2) 26(n=2) 27(n=2) 28(n=2) 29(n=2) 30(n=2) 31(n=2) |
| desert | 19 (4/7/7/1) | aphid-swarm1, ant-scouts2, sand-fleas3, dung-beetle3, orb-spider5, paper-wasp6, sun-lizard8, dune-scorpion10, ember-beetle12, grass-snake14, dust-sidewinder15, desert-gila-dragon20, desert-tortoise24, griffon-vulture24, desert-camel27, dune-wyrm30B, sand-viper-matriarch31, honey-badger-brute32, outback-dingo35 | 21(n=2) 38(n=2) 39(n=1) 40(n=1) |
| mountain | 21 (4/6/10/1) | aphid-swarm1, ant-scouts2, dusk-moth3, cave-glowworm5, orb-spider5, carrion-crow9, frost-hare11, thistle-beast12, ember-beetle12, red-fox16, tawny-owl17, ptarmigan-flock18, moss-golem20, cliff-ram21, wolverine21, tufted-lynx23, griffon-vulture24, black-bear25, cloud-leopard28, storm-eagle32B, thunder-yak33 | 32(n=2) 33(n=2) 34(n=2) 35(n=1) 36(n=1) 37(n=1) 38(n=1) 39(n=1) 40(scaled) |
| tundra | 12 (2/4/5/1) | aphid-swarm1, ant-scouts2, orb-spider5, grumpy-lemming6, frost-hare11, red-fox16, arctic-fox17, ptarmigan-flock18, wolverine21, glacier-bear26, lichen-reindeer28, snow-owl-monarch30B | 1(n=2) 2(n=2) 12(n=2) 13(n=1) 14(n=2) 25(n=2) 28(n=2) 29(n=2) 30(n=2) 31(n=2) 32(n=2) 33(n=1) 34(n=1) 35(scaled) 36(scaled) 37(scaled) 38(scaled) 39(scaled) 40(scaled) |
| rainforest | 20 (5/7/7/1) | aphid-swarm1, ant-scouts2, gnat-cloud2, leopard-slug2, cave-glowworm5, orb-spider5, bullfrog7, sun-lizard8, giant-centipede11, grass-snake14, mischief-monkey15, poison-dart-frog16, leafcutter-column17, moss-golem20, giant-anteater22, emerald-python25, jungle-tiger26, spice-monitor27, jade-jaguar32B, fern-cassowary36 | 32(n=2) 33(n=1) 34(n=1) 35(n=1) 36(n=1) 37(n=1) 38(n=1) 39(n=1) 40(n=1) |

Same-type clusters:

| cluster | members | where they stack |
|---|---|---|
| starter bugs | aphid-swarm1, garden-snail1, ant-scouts2, dusk-moth3, dung-beetle3, earwig4, orb-spider5 (3 are `any`) | every land L1-8; grassland / forest L6-8 pools are 9-12 with 6-7 of these |
| crabs | shore-crab7, hermit-crab-hoarder12, tide-crab-knight19, coconut-crab-titan26B, mangrove-crab-king30 | 5 of 16 island creatures, 4 of 20 coast |
| snakes | grass-snake14, dust-sidewinder15, emerald-python25, sand-viper-matriarch31 | desert L12-17: 2 of 4-5 |
| canids | red-fox16, arctic-fox17, bramble-wolf22, savanna-hyena29, outback-dingo35 | grassland L29-37: hyena + dingo are 2 of 3 |
| forest large mammals | red-fox16, raccoon16, badger18, wild-boar21, bramble-wolf22, beaver-foreman22, tufted-lynx23, black-bear25, jungle-tiger26 (+ tawny-owl17, moss-golem20, giant-bumblebee23) | forest L19-26: 8-10 candidates, all large (EA L20, CSA L23-24) |
| desert reptiles | sun-lizard8, dust-sidewinder15, desert-gila-dragon20, desert-tortoise24, sand-viper-matriarch31 | desert L18-26: 2-3 of 3-4 |
| bears | black-bear25, glacier-bear26 | - |
| frogs / toads | bullfrog7, poison-dart-frog16, mire-toad18 | wetland L12-20 |

### 2.2 Where each landscape is actually walked at a region-set level

| land | plain road/side levels (regions) | pool n at those levels | extra levels via landmark routes / explore d1-8 | creature levels with no host level within band |
|---|---|---|---|---|
| grassland | 1(NA) 1+g(NA) 2(CA,NA) 3(NA,NWE) 4(CA) 4+g(CA) 6(CA,NWE) 6+g(NWE) 8(NWE,SA) 10(EA,EE,NA,SA) 12(SA) 12+g(SA) 14(EE) 14+g(EE) 17(MENA) 17+g(MENA) 18(EE) 20(EA,MENA) 20+g(EA) 21(CSA,EA) 23(CSA,WCA) 23+g(CSA) 27+g(CSA) 29+g(WCA) 30+g(ESA,WCA) 32+g(ESA) | 1:5 2:6 3:7 4:8 6:10 8:10 10:8 12:7 14:7 17:4 18:4 20:4 21:4 23:3 27:4 29:3 30:3 32:3 | 1-38 (34 levels) | outback-dingo35 |
| forest | 1(NA) 6(NWE) 6+g(NWE) 10(NWE) 14(EE) 20(EA) 20+g(EA) 23(CSA,EA) 23+g(CSA) 24(CSA) 35+g(OC) | 1:5 6:9 10:7 14:6 20:8 23:9 24:9 35:1 | 1-40 (30 levels) |  |
| wetland | 8(CB) 14(EE) 18(CSA) 20(CSA) 23(CSA,SEA) 23+g(CSA) 24(SEA) 26+g(SEA) 29+g(WCA) 32+g(ESA) | 8:7 14:5 18:7 20:7 23:5 24:5 26:4 29:3 32:1 | 1-37 (29 levels) | garden-snail1 |
| coast | 1(NA) 6(NWE) 8(CB,SE) 8+g(CB) 10(SE) 10+g(SE) 13(MENA,SE) 17(MENA) 17+g(MENA) 20(EA) 23(MENA) 26+g(SEA) 29+g(WCA) 30+g(SEA) 35+g(OC) | 1:4 6:7 8:6 10:5 13:6 17:4 20:3 23:4 26:4 29:4 30:3 35:3 | 1-39 (34 levels) |  |
| island | 6(CB) 8(CB) 8+g(CB) 10(CB,SE) 23(OC) 26+g(SEA) 30+g(OC) 35+g(OC) | 6:5 8:5 10:4 23:2 26:2 30:2 35:4 | 1-39 (32 levels) | reef-turtle16 |
| desert | 4(CA) 12(SA) 17(MENA) 20(EA) 32+g(ESA) 35+g(OC) | 4:6 12:5 17:3 20:3 32:3 35:3 | 4-44 (31 levels) | desert-tortoise24, griffon-vulture24 |
| mountain | 4(CA) 10(SE) 12(SA) 12+g(SA) 14(EE) 17(MENA) 23(CSA,SA) 27+g(ESA) 32+g(ESA) | 4:5 10:6 12:4 14:5 17:6 23:8 27:6 32:2 | 1-38 (38 levels) |  |
| tundra | 1(NA) 1+g(NA) 6(NWE) 6+g(NWE) | 1:2 6:4 | 6-15 (8 levels) | frost-hare11, red-fox16, arctic-fox17, ptarmigan-flock18, wolverine21, glacier-bear26, lichen-reindeer28 |
| rainforest | 4(CA) 4+g(CA) 8(CA,CB) 12(SA) 26+g(SEA) 29+g(WCA) | 4:6 8:7 12:4 26:5 29:3 | 2-35 (32 levels) | mischief-monkey15, poison-dart-frog16, leafcutter-column17, fern-cassowary36 |

### 2.3 Region -> landscapes -> candidates (plain roads and side paths; landmark routes are in 3.2)

Flags: thin = fewer than 3; crowded = 9 or more; GAP = none on-level.

**NA The Maplewold** · region L1 · zones 1-4: grassland, forest, coast, tundra · explore-only: mountain, wetland

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| coast | 1 | 307> 308> | 4 | 4/0/0 | aphid-swarm1, garden-snail1, ant-scouts2, sand-fleas3 | all small |
| forest | 1 | 304> 305> 306> | 5 | 5/0/0 | aphid-swarm1, garden-snail1, ant-scouts2, leopard-slug2, dusk-moth3 | all small |
| grassland | 1 (+g near home) | 228> 228< 232> 232< 236> 236< 304< 305< 306< 307< 308< 309< 310< 311> 311< 316< | 5 | 5/0/0 | aphid-swarm1, garden-snail1, ant-scouts2, dusk-moth3, dung-beetle3 | all small |
| grassland | 2 | 229< | 6 | 6/0/0 | aphid-swarm1, garden-snail1, ant-scouts2, dusk-moth3, dung-beetle3, earwig4 | all small |
| grassland | 3 | 233< | 7 | 6/1/0 | aphid-swarm1, garden-snail1, ant-scouts2, dusk-moth3, dung-beetle3, earwig4, orb-spider5 |  |
| grassland | 10 | 237< | 8 | 1/7/0 | earwig4, orb-spider5, paper-wasp6, barn-rat8, sun-lizard8, tunnel-mole9, carrion-crow9, thistle-beast12 |  |
| tundra | 1 (+g near home) | 309> 310> 316> | 2 | 2/0/0 | aphid-swarm1, ant-scouts2 | thin |

**CA Maizehollow** · region L4 · zones 1-4: grassland, rainforest, desert, mountain

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| desert | 4 | 319> 320> | 6 | 4/2/0 | aphid-swarm1, ant-scouts2, sand-fleas3, dung-beetle3, orb-spider5, paper-wasp6 |  |
| grassland | 2 | 229> | 6 | 6/0/0 | aphid-swarm1, garden-snail1, ant-scouts2, dusk-moth3, dung-beetle3, earwig4 | all small |
| grassland | 4 (+g near home) | 230> 230< 231> 231< 240> 240< 317< 318< 319< 321< 322< 323> 323< | 8 | 6/2/0 | aphid-swarm1, garden-snail1, ant-scouts2, dusk-moth3, dung-beetle3, earwig4, orb-spider5, paper-wasp6 |  |
| grassland | 6 | 241< | 10 | 6/4/0 | aphid-swarm1, garden-snail1, ant-scouts2, dusk-moth3, dung-beetle3, earwig4, orb-spider5, paper-wasp6, barn-rat8, sun-lizard8 | crowded |
| mountain | 4 | 321> 322> | 5 | 4/1/0 | aphid-swarm1, ant-scouts2, dusk-moth3, cave-glowworm5, orb-spider5 |  |
| rainforest | 4 (+g near home) | 244> 244< 317> 318> 320< | 6 | 5/1/0 | aphid-swarm1, ant-scouts2, gnat-cloud2, leopard-slug2, cave-glowworm5, orb-spider5 |  |
| rainforest | 8 | 245< | 7 | 4/3/0 | ant-scouts2, gnat-cloud2, leopard-slug2, cave-glowworm5, orb-spider5, bullfrog7, sun-lizard8 |  |

**NWE Mistmoor** · region L6 · zones 1-4: grassland, forest, coast, tundra · explore-only: mountain, wetland

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| coast | 6 | 355> 356> | 7 | 4/3/0 | aphid-swarm1, garden-snail1, ant-scouts2, sand-fleas3, orb-spider5, shore-crab7, barn-rat8 |  |
| forest | 6 (+g near home) | 260> 260< 353> 354> 356< 364< | 9 | 6/3/0 | aphid-swarm1, garden-snail1, ant-scouts2, leopard-slug2, dusk-moth3, earwig4, orb-spider5, paper-wasp6, barn-rat8 | crowded |
| forest | 10 | 261< | 7 | 1/6/0 | earwig4, orb-spider5, paper-wasp6, barn-rat8, tunnel-mole9, carrion-crow9, giant-centipede11 |  |
| grassland | 3 | 233> | 7 | 6/1/0 | aphid-swarm1, garden-snail1, ant-scouts2, dusk-moth3, dung-beetle3, earwig4, orb-spider5 |  |
| grassland | 6 (+g near home) | 234> 234< 235> 235< 256> 256< 353< 354< 355< 357< 358< 359> 359< | 10 | 6/4/0 | aphid-swarm1, garden-snail1, ant-scouts2, dusk-moth3, dung-beetle3, earwig4, orb-spider5, paper-wasp6, barn-rat8, sun-lizard8 | crowded |
| grassland | 8 | 257< | 10 | 4/6/0 | ant-scouts2, dusk-moth3, dung-beetle3, earwig4, orb-spider5, paper-wasp6, barn-rat8, sun-lizard8, tunnel-mole9, carrion-crow9 | crowded |
| tundra | 6 (+g near home) | 357> 358> 364> | 4 | 2/2/0 | aphid-swarm1, ant-scouts2, orb-spider5, grumpy-lemming6 |  |

**CB Sunsprinkle Isles** · region L8 · zones 1-4: island, coast, rainforest, wetland · explore-only: forest

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| coast | 8 (+g near home) | 328> 329> 330> 337> | 6 | 2/4/0 | ant-scouts2, sand-fleas3, orb-spider5, shore-crab7, barn-rat8, herring-gull10 |  |
| island | 6 | 241> | 5 | 3/2/0 | aphid-swarm1, ant-scouts2, sand-fleas3, orb-spider5, shore-crab7 |  |
| island | 8 (+g near home) | 242> 242< 243> 243< 248> 248< 328< 329< 330< 331< 332< 333< 334< 335> 335< 337< | 5 | 2/3/0 | ant-scouts2, sand-fleas3, orb-spider5, shore-crab7, herring-gull10 |  |
| island | 10 | 249< | 4 | 0/4/0 | orb-spider5, shore-crab7, herring-gull10, hermit-crab-hoarder12 | all medium |
| rainforest | 8 | 331> 332> | 7 | 4/3/0 | ant-scouts2, gnat-cloud2, leopard-slug2, cave-glowworm5, orb-spider5, bullfrog7, sun-lizard8 |  |
| wetland | 8 | 333> 334> | 7 | 4/3/0 | ant-scouts2, gnat-cloud2, leopard-slug2, earwig4, orb-spider5, bog-leech6, bullfrog7 |  |

**SE Olivewhistle Shore** · region L10 · zones 1-4: coast, mountain, island, mountain · explore-only: forest

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| coast | 8 | 257> | 6 | 2/4/0 | ant-scouts2, sand-fleas3, orb-spider5, shore-crab7, barn-rat8, herring-gull10 |  |
| coast | 10 (+g near home) | 258> 258< 259> 259< 264> 264< 365< 366< 367< 368< 369< 370< 371< 372> 372< 373> 373< | 5 | 0/5/0 | orb-spider5, shore-crab7, barn-rat8, herring-gull10, hermit-crab-hoarder12 | all medium |
| coast | 13 | 265< | 6 | 0/5/1 | shore-crab7, barn-rat8, herring-gull10, hermit-crab-hoarder12, sea-otter-bandit13, grey-heron15 |  |
| island | 10 | 368> 369> | 4 | 0/4/0 | orb-spider5, shore-crab7, herring-gull10, hermit-crab-hoarder12 | all medium |
| mountain | 10 | 365> 366> 367> 370> 371> | 6 | 1/5/0 | cave-glowworm5, orb-spider5, carrion-crow9, frost-hare11, thistle-beast12, ember-beetle12 |  |

**SA Rainroot Reaches** · region L12 · zones 1-4: grassland, mountain, rainforest, desert

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| desert | 12 | 345> 346> | 5 | 0/4/1 | paper-wasp6, sun-lizard8, dune-scorpion10, ember-beetle12, grass-snake14 |  |
| grassland | 8 | 245> | 10 | 4/6/0 | ant-scouts2, dusk-moth3, dung-beetle3, earwig4, orb-spider5, paper-wasp6, barn-rat8, sun-lizard8, tunnel-mole9, carrion-crow9 | crowded |
| grassland | 10 | 249> | 8 | 1/7/0 | earwig4, orb-spider5, paper-wasp6, barn-rat8, sun-lizard8, tunnel-mole9, carrion-crow9, thistle-beast12 |  |
| grassland | 12 (+g near home) | 246> 246< 247> 247< 250< 341< 342< 343< 346< 347> 347< | 7 | 0/6/1 | paper-wasp6, barn-rat8, sun-lizard8, tunnel-mole9, carrion-crow9, thistle-beast12, grass-snake14 |  |
| mountain | 12 (+g near home) | 250> 251> 251< 252> 252< 341> 344< 345< | 4 | 0/4/0 | carrion-crow9, frost-hare11, thistle-beast12, ember-beetle12 | all medium |
| mountain | 23 | 253< | 8 | 0/1/7 | tawny-owl17, ptarmigan-flock18, moss-golem20, cliff-ram21, wolverine21, tufted-lynx23, griffon-vulture24, black-bear25 |  |
| rainforest | 12 | 342> 343> 344> | 4 | 0/3/1 | bullfrog7, sun-lizard8, giant-centipede11, grass-snake14 |  |

**EE Birchbramble Steppe** · region L14 · zones 1-4: grassland, forest, wetland, mountain · explore-only: tundra

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| forest | 14 | 378> 379> 380> | 6 | 0/4/2 | barn-rat8, tunnel-mole9, carrion-crow9, giant-centipede11, red-fox16, raccoon16 |  |
| grassland | 10 | 261> | 8 | 1/7/0 | earwig4, orb-spider5, paper-wasp6, barn-rat8, sun-lizard8, tunnel-mole9, carrion-crow9, thistle-beast12 |  |
| grassland | 14 (+g near home) | 262> 262< 263> 263< 268> 268< 378< 379< 380< 381< 382< 383< 384< 385> 385< | 7 | 0/5/2 | barn-rat8, sun-lizard8, tunnel-mole9, carrion-crow9, thistle-beast12, grass-snake14, red-fox16 |  |
| grassland | 18 | 269< | 4 | 0/1/3 | thistle-beast12, grass-snake14, red-fox16, badger18 |  |
| mountain | 14 | 383> 384> | 5 | 0/4/1 | carrion-crow9, frost-hare11, thistle-beast12, ember-beetle12, red-fox16 |  |
| wetland | 14 | 381> 382> | 5 | 0/2/3 | will-o-wisp13, grass-snake14, grey-heron15, raccoon16, poison-dart-frog16 |  |

**MENA The Dunewhisper** · region L17 · zones 1-4: coast, grassland, mountain, desert

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| coast | 13 | 265> | 6 | 0/5/1 | shore-crab7, barn-rat8, herring-gull10, hermit-crab-hoarder12, sea-otter-bandit13, grey-heron15 |  |
| coast | 17 (+g near home) | 266> 266< 267> 267< 272> 272< 390< 391< 392< 394< 395< 396< 397> | 4 | 0/2/2 | hermit-crab-hoarder12, sea-otter-bandit13, grey-heron15, tide-crab-knight19 |  |
| coast | 23 | 273< | 4 | 0/0/4 | tide-crab-knight19, pelican-parliament21, clam-lurker23, salt-sea-lion25 | all large |
| desert | 17 | 394> 395> 396> | 3 | 0/2/1 | ember-beetle12, grass-snake14, dust-sidewinder15 |  |
| grassland | 17 (+g near home) | 276> 276< 390> 391> 393< 397< | 4 | 0/1/3 | thistle-beast12, grass-snake14, red-fox16, badger18 |  |
| grassland | 20 | 277< | 4 | 0/0/4 | grass-snake14, red-fox16, badger18, wild-boar21 | all large |
| mountain | 17 | 392> 393> | 6 | 0/4/2 | frost-hare11, thistle-beast12, ember-beetle12, red-fox16, tawny-owl17, ptarmigan-flock18 |  |

**EA Blossomreach** · region L20 · zones 1-4: grassland, forest, coast, desert · explore-only: mountain, wetland

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| coast | 20 | 439> 440> | 3 | 0/0/3 | grey-heron15, tide-crab-knight19, pelican-parliament21 | all large |
| desert | 20 | 441> 442> | 3 | 0/1/2 | grass-snake14, dust-sidewinder15, desert-gila-dragon20 |  |
| forest | 20 (+g near home) | 290> 291> 291< 296> 296< 438> 441< 442< | 8 | 0/0/8 | red-fox16, raccoon16, tawny-owl17, badger18, moss-golem20, wild-boar21, bramble-wolf22, beaver-foreman22 | all large |
| forest | 23 | 297< | 9 | 0/0/9 | tawny-owl17, badger18, moss-golem20, wild-boar21, bramble-wolf22, beaver-foreman22, giant-bumblebee23, tufted-lynx23, black-bear25 | crowded, all large |
| grassland | 10 | 237> | 8 | 1/7/0 | earwig4, orb-spider5, paper-wasp6, barn-rat8, sun-lizard8, tunnel-mole9, carrion-crow9, thistle-beast12 |  |
| grassland | 20 (+g near home) | 238> 238< 290< 438< 439< 440< 443> 443< | 4 | 0/0/4 | grass-snake14, red-fox16, badger18, wild-boar21 | all large |
| grassland | 21 | 289> | 4 | 0/0/4 | red-fox16, badger18, wild-boar21, giant-bumblebee23 | all large |

**CSA Spicepeak** · region L23 · zones 1-4: wetland, grassland, forest, mountain

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| forest | 23 (+g near home) | 292> 292< 428> | 9 | 0/0/9 | tawny-owl17, badger18, moss-golem20, wild-boar21, bramble-wolf22, beaver-foreman22, giant-bumblebee23, tufted-lynx23, black-bear25 | crowded, all large |
| forest | 24 | 293< | 9 | 0/0/9 | badger18, moss-golem20, wild-boar21, bramble-wolf22, beaver-foreman22, giant-bumblebee23, tufted-lynx23, black-bear25, jungle-tiger26 | crowded, all large |
| grassland | 21 | 289< | 4 | 0/0/4 | red-fox16, badger18, wild-boar21, giant-bumblebee23 | all large |
| grassland | 23 (+g near home) | 278> 279> 279< 287> 287< 288> 288< 431< 432< | 3 | 0/0/3 | badger18, wild-boar21, giant-bumblebee23 | all large |
| grassland | 27+g | 286> | 4 | 0/1/3 | wild-boar21, giant-bumblebee23, prairie-bison26, savanna-hyena29 |  |
| mountain | 23 | 429> 430> 431> | 8 | 0/1/7 | tawny-owl17, ptarmigan-flock18, moss-golem20, cliff-ram21, wolverine21, tufted-lynx23, griffon-vulture24, black-bear25 |  |
| wetland | 18 | 269> | 7 | 0/2/5 | will-o-wisp13, grass-snake14, grey-heron15, raccoon16, poison-dart-frog16, mire-toad18, bog-pike20 |  |
| wetland | 20 | 277> | 7 | 0/1/6 | grass-snake14, grey-heron15, raccoon16, poison-dart-frog16, mire-toad18, bog-pike20, beaver-foreman22 |  |
| wetland | 23 (+g near home) | 270> 270< 271> 271< 278< 428< 429< 430< 432> | 5 | 0/0/5 | mire-toad18, bog-pike20, beaver-foreman22, delta-gharial24, emerald-python25 | all large |

**SEA Monsoon Tangle** · region L26 (every walk = max(gnome Lv, floor)) · zones 1-4: wetland, coast, island, rainforest

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| coast | 26+g | 298> 299> 299< 300> 300< 449> 452< 453< | 4 | 0/1/3 | pelican-parliament21, clam-lurker23, salt-sea-lion25, spice-monitor27 |  |
| coast | 30+g | 301< | 3 | 0/1/2 | salt-sea-lion25, spice-monitor27, mangrove-crab-king30 |  |
| island | 26+g | 450> 451> | 2 | 0/1/1 | pelican-parliament21, spice-monitor27 | thin |
| rainforest | 26+g | 452> 453> 454> | 5 | 0/1/4 | moss-golem20, giant-anteater22, emerald-python25, jungle-tiger26, spice-monitor27 |  |
| wetland | 23 | 297> | 5 | 0/0/5 | mire-toad18, bog-pike20, beaver-foreman22, delta-gharial24, emerald-python25 | all large |
| wetland | 24 | 293> | 5 | 0/0/5 | mire-toad18, bog-pike20, beaver-foreman22, delta-gharial24, emerald-python25 | all large |
| wetland | 26+g | 294> 294< 295> 295< 298< 449< 450< 451< 454< 455> 455< | 4 | 0/0/4 | bog-pike20, beaver-foreman22, delta-gharial24, emerald-python25 | all large |

**WCA The Greatcanopy** · region L29 (every walk = max(gnome Lv, floor)) · zones 1-4: grassland, wetland, rainforest, coast · explore-only: forest

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| coast | 29+g | 409> 410> | 4 | 0/1/3 | clam-lurker23, salt-sea-lion25, spice-monitor27, mangrove-crab-king30 |  |
| grassland | 23 | 273> | 3 | 0/0/3 | badger18, wild-boar21, giant-bumblebee23 | all large |
| grassland | 29+g | 274> 274< 275> 275< 280> 280< 403< 404< 405< 406< 407< 408< 409< 410< 411> 411< | 3 | 0/1/2 | giant-bumblebee23, prairie-bison26, savanna-hyena29 |  |
| grassland | 30+g | 281< | 3 | 0/1/2 | prairie-bison26, savanna-hyena29, honey-badger-brute32 |  |
| rainforest | 29+g | 406> 407> 408> | 3 | 0/1/2 | emerald-python25, jungle-tiger26, spice-monitor27 |  |
| wetland | 29+g | 403> 404> 405> | 3 | 0/0/3 | delta-gharial24, emerald-python25, mangrove-crab-king30 | all large |

**ESA Thornacre Savanna** · region L32 (every walk = max(gnome Lv, floor)) · zones 1-4: grassland, mountain, wetland, desert

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| desert | 32+g | 420> 421> | 3 | 0/0/3 | desert-camel27, sand-viper-matriarch31, honey-badger-brute32 | all large |
| grassland | 30+g | 281> | 3 | 0/1/2 | prairie-bison26, savanna-hyena29, honey-badger-brute32 |  |
| grassland | 32+g | 282> 282< 283> 283< 284> 284< 285< 416< 417< 418< 420< 421< 422> 422< | 3 | 0/1/2 | prairie-bison26, savanna-hyena29, honey-badger-brute32 |  |
| mountain | 27+g | 286< | 6 | 0/0/6 | cliff-ram21, wolverine21, tufted-lynx23, griffon-vulture24, black-bear25, cloud-leopard28 | all large |
| mountain | 32+g | 285> 416> 417> 419< | 2 | 0/0/2 | cloud-leopard28, thunder-yak33 | thin |
| wetland | 32+g | 418> 419> | 1 | 0/0/1 | mangrove-crab-king30 | thin |

**OC The Coralscatter** · region L35 (every walk = max(gnome Lv, floor)) · zones 1-4: island, coast, forest, desert · explore-only: mountain, rainforest

| land | Lv | routes (N> = walking a>b, N< = b>a) | n | S/M/L | pool | flags |
|---|---|---|---|---|---|---|
| coast | 35+g | 302> 303> 303< 461> 462> 464< 468< | 3 | 0/0/3 | mangrove-crab-king30, reef-eel-lord34, deep-octopus37 | all large |
| desert | 35+g | 465> 466> 467> | 3 | 0/1/2 | sand-viper-matriarch31, honey-badger-brute32, outback-dingo35 |  |
| forest | 35+g | 463> 464> | 1 | 0/0/1 | fern-cassowary36 | thin |
| island | 23 | 253> | 2 | 0/0/2 | tide-crab-knight19, pelican-parliament21 | thin |
| island | 30+g | 301> | 2 | 0/1/1 | spice-monitor27, mangrove-crab-king30 | thin |
| island | 35+g | 254> 254< 255> 255< 302< 461< 462< 463< 465< 466< 467< 468> | 4 | 0/0/4 | mangrove-crab-king30, reef-eel-lord34, fern-cassowary36, deep-octopus37 | all large |

Routes / areas with too few: NA tundra L1 (309, 310, 316: 2), OC island L23 (253: 2), SEA island L26 (450, 451: 2), OC island L30 (301: 2), ESA mountain L32 (285, 416, 417: 2), ESA wetland L32 (418, 419: 1), OC forest L35 (463, 464: 1). Too many: grassland L6-8 (CA 241<, NWE 234 / 235 / 256 / 257<, SA 245>: 10), NWE forest L6 (9), EA / CSA forest L23-24 (9, all large).

### 2.4 Every creature: where it can be met on-level

Columns 6-7 list regions where the creature is inside the band at a level the region sets (not the gnome). Empty both = only met when a gnome out-levels the place (near home, top-4 regions, deep wilds).

| creature | sz | Lv | landscapes | cond | plain roads + side paths at region level | + landmark routes / delves / explore d1-8 | flag |
|---|---|---|---|---|---|---|---|
| aphid-swarm | S | 1 | any |  | NA CA NWE CB | ESA OC |  |
| garden-snail | S | 1 | forest,grassland,wetland,coast | we=rain,fog | NA CA NWE | CB ESA |  |
| ant-scouts | S | 2 | any |  | NA CA NWE CB SE SA | EE MENA EA CSA SEA WCA ESA OC |  |
| gnat-cloud | S | 2 | wetland,rainforest | dp=dawn,dusk | CA CB | NA NWE EE SEA WCA ESA |  |
| leopard-slug | S | 2 | forest,wetland,rainforest | we=rain,fog | NA CA NWE CB | SE EE EA CSA SEA WCA ESA OC |  |
| sand-fleas | S | 3 | coast,island,desert |  | NA CA NWE CB SE | SA MENA EA SEA OC |  |
| dusk-moth | S | 3 | forest,grassland,mountain | dp=dusk,night | NA CA NWE SA | CB SE EE MENA EA CSA WCA ESA OC |  |
| dung-beetle | S | 3 | grassland,desert |  | NA CA NWE SA | EE MENA EA CSA WCA ESA |  |
| earwig | S | 4 | forest,grassland,wetland |  | NA CA NWE CB SA EE EA | SE MENA CSA SEA WCA ESA OC |  |
| cave-glowworm | S | 5 | mountain,rainforest | dp=night | CA CB SE | NWE SA MENA EA ESA |  |
| orb-spider | M | 5 | any |  | NA CA NWE CB SE SA EE EA | MENA CSA SEA WCA ESA OC |  |
| paper-wasp | M | 6 | grassland,forest,desert | we=sun,heat | NA CA NWE SA EE EA | CB SE MENA CSA WCA ESA OC |  |
| bog-leech | M | 6 | wetland | we=rain | CB | NWE EE SEA WCA ESA | 1 region |
| grumpy-lemming | M | 6 | tundra |  | NWE | NA EE | 1 region |
| bullfrog | M | 7 | wetland,rainforest | we=rain,storm | CA CB SA | NWE EE SEA WCA ESA |  |
| shore-crab | M | 7 | coast,island |  | NWE CB SE MENA | NA EA SEA OC |  |
| barn-rat | M | 8 | grassland,forest,coast | dp=night | NA CA NWE CB SE SA EE MENA EA | CSA SEA WCA ESA OC |  |
| sun-lizard | M | 8 | desert,grassland,rainforest | we=sun,heat | NA CA NWE CB SA EE EA | MENA CSA WCA ESA |  |
| tunnel-mole | M | 9 | grassland,forest |  | NA NWE SA EE EA | CA SE MENA CSA WCA ESA OC |  |
| carrion-crow | M | 9 | grassland,forest,mountain |  | NA NWE SE SA EE EA | CA MENA CSA WCA ESA OC |  |
| herring-gull | M | 10 | coast,island |  | CB SE MENA | NA NWE EA SEA OC |  |
| dune-scorpion | M | 10 | desert | dp=dusk,night | SA | CA | 1 region |
| frost-hare | M | 11 | tundra,mountain | we=snow,frost | SE SA EE MENA | NA CA NWE EA ESA |  |
| giant-centipede | M | 11 | rainforest,forest |  | NWE SA EE | NA CA CB SE EA CSA OC |  |
| thistle-beast | M | 12 | grassland,mountain |  | NA SE SA EE MENA EA | CA NWE CSA WCA ESA |  |
| ember-beetle | M | 12 | desert,mountain |  | SE SA EE MENA | CA EA CSA ESA OC |  |
| will-o-wisp | M | 13 | wetland | dp=night | EE CSA | CB SEA WCA ESA |  |
| grass-snake | L | 14 | grassland,wetland,rainforest,desert |  | SA EE MENA EA CSA | NA CA NWE CB SEA WCA ESA OC |  |
| grey-heron | L | 15 | wetland,coast |  | SE EE MENA EA CSA | NWE CB SEA |  |
| mischief-monkey | L | 15 | rainforest |  |  | CA CB SA SEA WCA | no plain road |
| red-fox | L | 16 | forest,grassland,mountain,tundra | dp=dawn,dusk | EE MENA EA CSA | NA CA NWE SE SA WCA ESA |  |
| raccoon | L | 16 | forest,wetland | dp=night,dusk | EE EA CSA | NA CB SEA |  |
| tawny-owl | L | 17 | forest,mountain | dp=night,dusk | SA MENA EA CSA | NA SE EE WCA ESA OC |  |
| arctic-fox | L | 17 | tundra | se=winter |  | NWE | no plain road |
| badger | L | 18 | forest,grassland |  | EE MENA EA CSA WCA | NA SA |  |
| mire-toad | L | 18 | wetland | we=rain,fog | CSA SEA | CB EE EA WCA |  |
| tide-crab-knight | L | 19 | coast,island |  | MENA EA OC | CB SEA |  |
| moss-golem | L | 20 | forest,rainforest,mountain |  | SA EA CSA SEA | SE EE MENA WCA ESA OC |  |
| bramble-wolf | L | 22 | forest |  | EA CSA | WCA OC |  |
| coconut-crab-titan | B | 26 | island |  |  | CB SEA OC | no plain road |
| great-hawk | B | 28 | grassland |  |  | SA EE MENA EA WCA ESA | no plain road |
| ancient-snapper | B | 28 | wetland |  |  | CB CSA SEA | no plain road |
| reef-leviathan | B | 29 | coast |  |  | MENA SEA WCA OC | no plain road |
| old-bramblehorn | B | 30 | forest |  |  | EA CSA | no plain road |
| dune-wyrm | B | 30 | desert |  |  | MENA EA ESA OC | no plain road |
| snow-owl-monarch | B | 30 | tundra |  |  |  | NO REGION FIT (gnome-level only) |
| storm-eagle | B | 32 | mountain |  |  | CSA ESA | no plain road |
| jade-jaguar | B | 32 | rainforest |  |  | SA SEA WCA | no plain road |
| delta-gharial | L | 24 | wetland |  | CSA SEA WCA | CB ESA |  |
| emerald-python | L | 25 | rainforest,wetland |  | CSA SEA WCA | CB SA ESA |  |
| jungle-tiger | L | 26 | forest,rainforest |  | CSA SEA WCA | SA EA OC |  |
| spice-monitor | M | 27 | rainforest,island,coast |  | SEA WCA OC | SA EA |  |
| cloud-leopard | L | 28 | mountain |  | ESA | CSA | 1 region |
| savanna-hyena | M | 29 | grassland |  | CSA WCA ESA |  |  |
| mangrove-crab-king | L | 30 | coast,island,wetland |  | SEA WCA ESA OC | CSA |  |
| sand-viper-matriarch | L | 31 | desert |  | ESA OC | EA |  |
| honey-badger-brute | L | 32 | grassland,desert |  | WCA ESA OC |  |  |
| thunder-yak | L | 33 | mountain |  | ESA | CSA | 1 region |
| reef-eel-lord | L | 34 | coast,island |  | OC | SEA WCA | 1 region |
| outback-dingo | M | 35 | desert,grassland |  | OC | ESA | 1 region |
| fern-cassowary | L | 36 | forest,rainforest,island |  | OC | SEA WCA | 1 region |
| deep-octopus | L | 37 | island,coast |  | OC | WCA | 1 region |
| hermit-crab-hoarder | M | 12 | island,coast |  | CB SE MENA | NA NWE EA SEA OC |  |
| sea-otter-bandit | M | 13 | coast |  | SE MENA | NA NWE CB EA SEA OC |  |
| dust-sidewinder | M | 15 | desert | we=heat,sun | MENA EA | SA ESA OC |  |
| poison-dart-frog | M | 16 | rainforest,wetland | we=rain | EE CSA | CA CB SA EA SEA WCA |  |
| reef-turtle | L | 16 | island |  |  | CB SE OC | no plain road |
| leafcutter-column | M | 17 | rainforest |  |  | CA SA SEA WCA | no plain road |
| ptarmigan-flock | M | 18 | tundra,mountain | se=winter | SA MENA CSA | SE EE EA ESA OC |  |
| bog-pike | L | 20 | wetland |  | CSA SEA | CB EE EA WCA |  |
| desert-gila-dragon | L | 20 | desert |  | EA | SA MENA ESA OC | 1 region |
| cliff-ram | L | 21 | mountain |  | SA CSA ESA | SE EE MENA EA OC |  |
| wolverine | L | 21 | tundra,mountain |  | SA CSA ESA | SE EE MENA EA OC |  |
| wild-boar | L | 21 | forest,grassland |  | MENA EA CSA WCA | SA EE OC |  |
| pelican-parliament | L | 21 | coast,island |  | MENA EA SEA OC | CB |  |
| beaver-foreman | L | 22 | wetland,forest |  | EA CSA SEA | CB WCA OC |  |
| giant-anteater | L | 22 | rainforest |  | SEA | SA WCA | 1 region |
| giant-bumblebee | L | 23 | grassland,forest | we=sun,heat | EA CSA WCA | SA MENA OC |  |
| tufted-lynx | L | 23 | forest,mountain |  | SA EA CSA ESA | EE MENA WCA OC |  |
| clam-lurker | L | 23 | coast |  | MENA SEA WCA | EA OC |  |
| desert-tortoise | L | 24 | desert |  |  | MENA EA ESA OC | no plain road |
| griffon-vulture | L | 24 | mountain,desert |  | SA CSA ESA | EE MENA EA OC |  |
| black-bear | L | 25 | forest,mountain |  | SA EA CSA ESA | EE WCA OC |  |
| salt-sea-lion | L | 25 | coast |  | MENA SEA WCA | EA OC |  |
| glacier-bear | L | 26 | tundra |  |  |  | NO REGION FIT (gnome-level only) |
| prairie-bison | L | 26 | grassland |  | CSA WCA ESA | SA MENA EA |  |
| desert-camel | L | 27 | desert |  | ESA | MENA EA OC | 1 region |
| lichen-reindeer | L | 28 | tundra |  |  |  | NO REGION FIT (gnome-level only) |

Summary: NEVER spawn: none. No region fit (gnome-level only): glacier-bear, lichen-reindeer, snow-owl-monarch. No plain road at region level: arctic-fox, mischief-monkey, reef-turtle, leafcutter-column, desert-tortoise and all 9 bosses (by design: bosses need a fixed route, explore step 7+, or a lair-route E spot). One region only: 13 creatures (flag column). 16 creatures are on-level on plain roads in no region; 12 in one.

## 3. Per route map

### 3.1 What on a map hosts a fight

| spot | tiles | creature |
|---|---|---|
| random fight `R` | any walkable `.` or `,` tile on the path taken, 3+ tiles from entry and exit. `,` (rough ground: 13-42% of a route's fight tiles, mean 27%) is 2.5x | pool of (destination land, walk level); no boss |
| door between stretches | not a tile: rolled on Continue | same pool; boss 6% on fixed routes |
| `E` | one tile on the last stretch of the 14 delve and 14 lair routes (1 of 28 blocks the only path) | 3.2 last column |
| `M` | 56 tiles (`extra_minibosses`), on the road line | the named creature at its own level (3.3) |
| camp tile | 246 camps (one per route; stretch 1: 110, stretch 2: 127, stretch 3: 9). Wait only | same pool as `R` |
| `F` | 1350 find tiles | never a fight |

The set piece / feature name, water, gates and decor of a stretch do not change the creature. Every stretch of a route shares one pool per direction. Expected random fights on the shortest line, normal stance: mean 2.8 per route (1.1 on 305 to 6.2 on 363), plus 0.24 per door.

Road kinds change the fight roll only on a paid toll road (half chance, also half at the camp). Ferry, tunnel, pass, overgrown, flooded change cost / time / tool only; no creature differs. 13 ferries cross with the ordinary land pool (no water creature); 13 tunnels likewise (no cave creature).

### 3.2 Landmark side paths (fixed level)

Δ = route minimum minus region level. Bosses column = bosses that can appear at 6% on door events and timer walks (out; back).

| id | landmark (kind) | reg (L) | route Lv | Δ | land out / back | pool out n (S/M/L) | pool back n | bosses 6% on door events/timer walk (out; back) | E spot on last stretch gives |
|---|---|---|---|---|---|---|---|---|---|
| 312 | Thousand Rings Stump (wonder) | NA (1) | 8-12 | +7 | forest / grassland | 10 (4/6/0) | 12 | -; - |  |
| 313 | Beaverdam Tunnels (delve) | NA (1) | 10-14 | +9 | forest / grassland | 9 (1/6/2) | 10 | -; - | large: red-fox16, raccoon16, tawny-owl17, badger18 / else ordinary pool |
| 314 | Lighthouse of the Lost Lantern (wonder) | NA (1) | 8-12 | +7 | coast / grassland | 8 (2/6/0) | 12 | -; - |  |
| 315 | Den of the Great White Owl (lair) | NA (1) | 8-12 | +7 | tundra / grassland | 4 (1/3/0) | 12 | -; - | boss: NONE / else ordinary pool |
| 324 | The Stepped Seed Temple (wonder) | CA (4) | 8-12 | +4 | rainforest / rainforest | 9 (4/4/1) | 9 | -; - |  |
| 325 | Jaguar Root Caves (delve) | CA (4) | 10-14 | +6 | rainforest / grassland | 8 (1/5/2) | 10 | -; - | large: grass-snake14, mischief-monkey15 |
| 326 | Cenote of Echoes (wonder) | CA (4) | 8-12 | +4 | desert / grassland | 9 (3/5/1) | 12 | -; - |  |
| 327 | Smokecap Caldera (lair) | CA (4) | 6-10 | +2 | mountain / grassland | 9 (4/5/0) | 13 | -; - | boss: NONE / else ordinary pool |
| 336 | Sunken Gnome Galleon (wonder) | CB (8) | 8-12 | +0 | coast / island | 8 (2/6/0) | 6 | -; - |  |
| 338 | The Singing Waterfall (wonder) | CB (8) | 8-12 | +0 | rainforest / island | 9 (4/4/1) | 6 | -; - |  |
| 339 | Mangrove Root Maze (delve) | CB (8) | 20-24 | +12 | wetland / island | 9 (0/1/8) | 3 | ancient-snapper28; coconut-crab-titan26 | large: grass-snake14, grey-heron15, raccoon16, mire-toad18, bog-pike20, beaver-foreman22, delta-gharial24, emerald-python25 |
| 340 | Lair of the Hurricane Crab (lair) | CB (8) | 10-14 | +2 | wetland / island | 9 (1/5/3) | 5 | -; - | boss: NONE / else ordinary pool |
| 348 | The Sky City Ruins (wonder) | SA (12) | 8-12 | -4 | mountain / grassland | 8 (3/5/0) | 12 | -; - |  |
| 349 | Condor's Crag (lair) | SA (12) | 14-18 | +2 | mountain / mountain | 8 (0/5/3) | 8 | -; - | boss: NONE / else ordinary pool |
| 350 | Pink River Dolphin Pools (wonder) | SA (12) | 18-22 | +6 | rainforest / mountain | 6 (0/2/4) | 10 | -; - |  |
| 351 | Anaconda Hollows (delve) | SA (12) | 20-24 | +8 | rainforest / grassland | 8 (0/2/6) | 6 | jade-jaguar32; great-hawk28 | large: grass-snake14, mischief-monkey15, moss-golem20, giant-anteater22, emerald-python25, jungle-tiger26 |
| 352 | The Mirror Salt Flat (wonder) | SA (12) | 8-12 | -4 | desert / grassland | 9 (3/5/1) | 12 | -; - |  |
| 360 | The Standing Stones (wonder) | NWE (6) | 1-5 | -5 | grassland / forest | 8 (6/2/0) | 8 | -; - |  |
| 361 | Fairy-ring Clearing (wonder) | NWE (6) | 8-12 | +2 | forest / grassland | 10 (4/6/0) | 12 | -; - |  |
| 362 | Sea-cave Smugglers' Run (delve) | NWE (6) | 10-14 | +4 | coast / grassland | 7 (0/6/1) | 10 | -; - | large: grey-heron15 / else ordinary pool |
| 363 | Barrow of the Frost Toad (lair) | NWE (6) | 8-12 | +2 | tundra / grassland | 4 (1/3/0) | 12 | -; - | boss: NONE / else ordinary pool |
| 374 | Goat Path Vineyards (wonder) | SE (10) | 8-12 | -2 | mountain / coast | 8 (3/5/0) | 8 | -; - |  |
| 375 | The Labyrinth Isle (wonder) | SE (10) | 8-12 | -2 | island / coast | 6 (2/4/0) | 8 | -; - |  |
| 376 | Pirate-gull Grottoes (delve) | SE (10) | 10-14 | +0 | island / coast | 5 (0/4/1) | 7 | -; - | large: reef-turtle16 / else ordinary pool |
| 377 | Forge of the Cinder Wyrm (lair) | SE (10) | 12-16 | +2 | mountain / coast | 7 (0/5/2) | 6 | -; - | boss: NONE / else ordinary pool |
| 386 | The Amber Woods (wonder) | EE (14) | 8-12 | -6 | forest / grassland | 10 (4/6/0) | 12 | -; - |  |
| 387 | Salt Mine Galleries (delve) | EE (14) | 10-14 | -4 | forest / grassland | 9 (1/6/2) | 10 | -; - | large: red-fox16, raccoon16, tawny-owl17, badger18 / else ordinary pool |
| 388 | Stork Chimney Village (wonder) | EE (14) | 8-12 | -6 | wetland / grassland | 9 (4/4/1) | 12 | -; - |  |
| 389 | Lair of the Grey Wolf King (lair) | EE (14) | 16-20 | +2 | mountain / grassland | 9 (0/4/5) | 5 | -; great-hawk28 | boss: NONE / else ordinary pool |
| 398 | The Hanging Garden Ruins (wonder) | MENA (17) | 8-12 | -9 | grassland / coast | 12 (4/7/1) | 8 | -; - |  |
| 399 | Cedar Sanctuary (wonder) | MENA (17) | 8-12 | -9 | mountain / coast | 8 (3/5/0) | 8 | -; - |  |
| 400 | The Oasis That Moves (wonder) | MENA (17) | 18-22 | +1 | desert / coast | 6 (0/2/4) | 6 | dune-wyrm30; reef-leviathan29 |  |
| 401 | Rose-red Canyon City (delve) | MENA (17) | 20-24 | +3 | desert / grassland | 5 (0/1/4) | 6 | dune-wyrm30; great-hawk28 | large: grass-snake14, desert-gila-dragon20, desert-tortoise24, griffon-vulture24, desert-camel27 |
| 402 | Tomb of the Sand Scarab (lair) | MENA (17) | 19-23 | +2 | desert / coast | 5 (0/1/4) | 6 | dune-wyrm30; reef-leviathan29 | boss: dune-wyrm30 / else ordinary pool |
| 412 | Mud Mosque Library (wonder) | WCA (29) | 8-12 | -21 | wetland / grassland | 9 (4/4/1) | 12 | -; - |  |
| 413 | Gorilla Glade (wonder) | WCA (29) | 18-22 | -11 | rainforest / grassland | 6 (0/2/4) | 6 | -; great-hawk28 |  |
| 414 | The Canopy Bridges (delve) | WCA (29) | 20-24 | -9 | rainforest / grassland | 8 (0/2/6) | 6 | jade-jaguar32; great-hawk28 | large: grass-snake14, mischief-monkey15, moss-golem20, giant-anteater22, emerald-python25, jungle-tiger26 |
| 415 | Hollow of the Silverback Spider (lair) | WCA (29) | 18-22 | -11 | rainforest / grassland | 6 (0/2/4) | 6 | -; great-hawk28 | boss: NONE / else ordinary pool |
| 423 | The Great Migration (wonder) | ESA (32) | 1-5 | -31 | grassland / mountain | 8 (6/2/0) | 5 | -; - |  |
| 424 | Coffee Ceremony Hut (wonder) | ESA (32) | 8-12 | -24 | mountain / grassland | 8 (3/5/0) | 12 | -; - |  |
| 425 | Snowcrown Peak (lair) | ESA (32) | 34-38 | +2 | mountain / grassland | 2 (0/0/2) | 3 | storm-eagle32; great-hawk28 | boss: storm-eagle32 |
| 426 | Flamingo Shallows (wonder) | ESA (32) | 8-12 | -24 | wetland / grassland | 9 (4/4/1) | 12 | -; - |  |
| 427 | Fynbos Fire Trails (delve) | ESA (32) | 20-24 | -12 | desert / mountain | 5 (0/1/4) | 9 | dune-wyrm30; storm-eagle32 | large: grass-snake14, desert-gila-dragon20, desert-tortoise24, griffon-vulture24, desert-camel27 |
| 433 | The Silk Road Caravanserai (wonder) | CSA (23) | 8-12 | -15 | grassland / grassland | 12 (4/7/1) | 12 | -; - |  |
| 434 | Tea Garden Slopes (wonder) | CSA (23) | 8-12 | -15 | forest / forest | 10 (4/6/0) | 10 | -; - |  |
| 435 | Temple of the Tiger Moth (lair) | CSA (23) | 25-29 | +2 | forest / wetland | 8 (0/0/8) | 5 | old-bramblehorn30; ancient-snapper28 | boss: old-bramblehorn30 |
| 436 | Prayer-flag Pass (wonder) | CSA (23) | 18-22 | -5 | mountain / wetland | 10 (0/3/7) | 9 | -; ancient-snapper28 |  |
| 437 | Snowleopard Ledges (delve) | CSA (23) | 20-24 | -3 | mountain / wetland | 9 (0/1/8) | 9 | storm-eagle32; ancient-snapper28 | large: red-fox16, tawny-owl17, moss-golem20, cliff-ram21, wolverine21, tufted-lynx23, griffon-vulture24, black-bear25, cloud-leopard28 |
| 444 | The Thousand Gates (wonder) | EA (20) | 8-12 | -12 | forest / grassland | 10 (4/6/0) | 12 | -; - |  |
| 445 | Panda Bamboo Grove (wonder) | EA (20) | 8-12 | -12 | forest / grassland | 10 (4/6/0) | 12 | -; - |  |
| 446 | Pearl Diver Cove (wonder) | EA (20) | 8-12 | -12 | coast / forest | 8 (2/6/0) | 10 | -; - |  |
| 447 | The Long Wall Walk (delve) | EA (20) | 20-24 | +0 | desert / forest | 5 (0/1/4) | 12 | dune-wyrm30; old-bramblehorn30 | large: grass-snake14, desert-gila-dragon20, desert-tortoise24, griffon-vulture24, desert-camel27 |
| 448 | Lair of the Jade Dragon-fly (lair) | EA (20) | 22-26 | +2 | desert / grassland | 4 (0/0/4) | 5 | dune-wyrm30; great-hawk28 | boss: dune-wyrm30 |
| 456 | Lantern Festival River (wonder) | SEA (26) | 8-12 | -18 | coast / wetland | 8 (2/6/0) | 9 | -; - |  |
| 457 | Volcano Spice Gardens (wonder) | SEA (26) | 8-12 | -18 | island / coast | 6 (2/4/0) | 8 | -; - |  |
| 458 | Dragonlizard Den (lair) | SEA (26) | 28-32 | +2 | island / coast | 3 (0/1/2) | 5 | coconut-crab-titan26; reef-leviathan29 | boss: coconut-crab-titan26 |
| 459 | Root-wrapped Temple (wonder) | SEA (26) | 18-22 | -8 | rainforest / wetland | 6 (0/2/4) | 9 | -; ancient-snapper28 |  |
| 460 | Firefly Caves (delve) | SEA (26) | 20-24 | -6 | rainforest / wetland | 8 (0/2/6) | 9 | jade-jaguar32; ancient-snapper28 | large: grass-snake14, mischief-monkey15, moss-golem20, giant-anteater22, emerald-python25, jungle-tiger26 |
| 469 | Starpath Canoe (wonder) | OC (35) | 1-5 | -34 | island / island | 5 (3/2/0) | 5 | -; - |  |
| 470 | Glowworm Grotto (wonder) | OC (35) | 8-12 | -27 | coast / island | 8 (2/6/0) | 6 | -; - |  |
| 471 | Reef of the Box Jelly Queen (lair) | OC (35) | 35-39 | +0 | coast / island | 3 (0/0/3) | 4 | reef-leviathan29; coconut-crab-titan26 | boss: reef-leviathan29 |
| 472 | Stone Head Watchers (wonder) | OC (35) | 8-12 | -27 | forest / coast | 10 (4/6/0) | 8 | -; - |  |
| 473 | The Red Rock Songlines (delve) | OC (35) | 20-24 | -15 | desert / island | 5 (0/1/4) | 3 | dune-wyrm30; coconut-crab-titan26 | large: grass-snake14, desert-gila-dragon20, desert-tortoise24, griffon-vulture24, desert-camel27 |

Lair bosses (inside the lair, not on the route):

| lair | reg (L) | land | boss | Lv |
|---|---|---|---|---|
| Den of the Great White Owl | NA (1) | tundra | Great White Owl L10 | 10 |
| Smokecap Caldera | CA (4) | mountain | Guardian of Smokecap Caldera L8 | 8 |
| Lair of the Hurricane Crab | CB (8) | wetland | Hurricane Crab L12 | 12 |
| Condor's Crag | SA (12) | mountain | Guardian of Condor's Crag L16 | 16 |
| Barrow of the Frost Toad | NWE (6) | tundra | Frost Toad L10 | 10 |
| Forge of the Cinder Wyrm | SE (10) | mountain | Cinder Wyrm L14 | 14 |
| Lair of the Grey Wolf King | EE (14) | mountain | Grey Wolf King L18 | 18 |
| Tomb of the Sand Scarab | MENA (17) | desert | Sand Scarab L21 | 21 |
| Hollow of the Silverback Spider | WCA (29) | rainforest | Silverback Spider L20 | 20 |
| Snowcrown Peak | ESA (32) | mountain | Guardian of Snowcrown Peak L36 | 36 |
| Temple of the Tiger Moth | CSA (23) | forest | Tiger Moth L27 | 27 |
| Lair of the Jade Dragon-fly | EA (20) | desert | Jade Dragon-fly L24 | 24 |
| Dragonlizard Den | SEA (26) | island | Guardian of Dragonlizard Den L30 | 30 |
| Reef of the Box Jelly Queen | OC (35) | coast | Box Jelly Queen L37 | 37 |

### 3.3 Fixed extra mini-bosses 6+ levels over the route, or blocking (of 56; made by `tools/add_trail_extras.py:89` with target level `12 + 0.7 x region level`)

| route | region | from > to | land | route Lv | fixed creature | its Lv | Δ | blocks only path |
|---|---|---|---|---|---|---|---|---|
| 472 | OC | Brineglen > Stone Head Watchers | forest | 8 | fern-cassowary | 36 | +28 |  |
| 426 | ESA | Meadowbottom > Flamingo Shallows | wetland | 8 | mangrove-crab-king | 30 | +22 |  |
| 457 | SEA | Sandpiperglen > Volcano Spice Gardens | island | 8 | mangrove-crab-king | 30 | +22 |  |
| 310 | NA | Poppyburrow > Snowcombe | tundra | 1 | wolverine | 21 | +20 |  |
| 413 | WCA | Thistleholt > Gorilla Glade | rainforest | 18 | fern-cassowary | 36 | +18 |  |
| 433 | CSA | Poppythorpe > The Silk Road Caravanserai | grassland | 8 | prairie-bison | 26 | +18 | YES |
| 446 | EA | Bramblebrook > Pearl Diver Cove | coast | 8 | salt-sea-lion | 25 | +17 |  |
| 309 | NA | Cloverholt > Iciclecrest | tundra | 1 | arctic-fox | 17 | +16 |  |
| 314 | NA | Honeybrook > Lighthouse of the Lost Lantern | coast | 8 | clam-lurker | 23 | +15 |  |
| 398 | MENA | Gullwell > The Hanging Garden Ruins | grassland | 8 | giant-bumblebee | 23 | +15 |  |
| 312 | NA | Cloverholt > Thousand Rings Stump | forest | 8 | bramble-wolf | 22 | +14 |  |
| 321 | CA | Larkbrook > Stonethorpe | mountain | 4 | red-fox | 16 | +12 | YES |
| 338 | CB | Breezehollow > The Singing Waterfall | rainforest | 8 | moss-golem | 20 | +12 |  |
| 248 | CB | The Sunsprinkle Isles Market > Palmknoll | island | 8+g | tide-crab-knight | 19 | +11 |  |
| 317 | CA | Larkbrook > Frondthorpe | rainforest | 4 | mischief-monkey | 15 | +11 |  |
| 330 | CB | Palmknoll > Saltgate | coast | 8 | tide-crab-knight | 19 | +11 |  |
| 375 | SE | Driftmead > The Labyrinth Isle | island | 8 | tide-crab-knight | 19 | +11 |  |
| 240 | CA | Maizehollow Market > Meadowmere | grassland | 4+g | grass-snake | 14 | +10 |  |
| 256 | NWE | Mistmoor Market > Larkden | grassland | 6+g | red-fox | 16 | +10 |  |
| 334 | CB | Shoreford > Mireburrow | wetland | 8 | mire-toad | 18 | +10 |  |
| 353 | NWE | Windbottom > Fernden | forest | 6 | raccoon | 16 | +10 | YES |
| 357 | NWE | Windbottom > Froststead | tundra | 6 | red-fox | 16 | +10 |  |
| 367 | SE | Sprayglen > Screemere | mountain | 10 | moss-golem | 20 | +10 |  |
| 371 | SE | Brinewick > Echonook | mountain | 10 | moss-golem | 20 | +10 | YES |
| 264 | SE | Olivewhistle Shore Market > Sprayglen | coast | 10+g | tide-crab-knight | 19 | +9 |  |
| 250 | SA | Thistlebottom > Flintburrow | mountain | 12 | moss-golem | 20 | +8 |  |
| 341 | SA | Barleyglen > Stoneden | mountain | 12 | moss-golem | 20 | +8 | YES |
| 345 | SA | Highcove > Scorchby | desert | 12 | desert-gila-dragon | 20 | +8 |  |
| 361 | NWE | Windbottom > Fairy-ring Clearing | forest | 8 | raccoon | 16 | +8 |  |
| 380 | EE | Tussockgate > Fernford | forest | 14 | beaver-foreman | 22 | +8 |  |
| 268 | EE | Birchbramble Steppe Market > Tussockgate | grassland | 14+g | wild-boar | 21 | +7 |  |
| 384 | EE | Thistleburrow > Flintknoll | mountain | 14 | cliff-ram | 21 | +7 |  |
| 394 | MENA | Gullwell > Ambercrest | desert | 17 | desert-tortoise | 24 | +7 |  |
| 442 | EA | Birchford > Dunewick | desert | 20 | desert-camel | 27 | +7 |  |
| 272 | MENA | The Dunewhisper Market > Brineburrow | coast | 17+g | clam-lurker | 23 | +6 |  |
| 290 | EA | Poppywell > Bramblebrook | forest | 20 | jungle-tiger | 26 | +6 |  |
| 326 | CA | Poppynook > Cenote of Echoes | desert | 8 | grass-snake | 14 | +6 |  |
| 390 | MENA | Gullwell > Windford | grassland | 17 | giant-bumblebee | 23 | +6 |  |
| 438 | EA | Honeythorpe > Brambleburrow | forest | 20 | jungle-tiger | 26 | +6 |  |

### 3.4 Delves (inside)

`n by stage` = pool size at each stage level.

| delve | reg | land | lm Lv | stage levels (F tiles) | guardian Lv (B) | pool n by stage |
|---|---|---|---|---|---|---|
| Beaverdam Tunnels | NA (1) | forest | 10 | 10..13 | 15: tunnel-mole9, carrion-crow9, giant-centipede11, red-fox16, raccoon16, tawny-owl17 | 7 / 6 / 5 / 4 |
| Jaguar Root Caves | CA (4) | rainforest | 10 | 10..13 | 15: giant-centipede11, grass-snake14, mischief-monkey15, poison-dart-frog16, leafcutter-column17 | 5 / 5 / 4 / 5 |
| Mangrove Root Maze | CB (8) | wetland | 20 | 20..23 | 25: delta-gharial24, emerald-python25, bog-pike20, beaver-foreman22 | 7 / 6 / 6 / 5 |
| Anaconda Hollows | SA (12) | rainforest | 20 | 20..23 | 25: moss-golem20, emerald-python25, jungle-tiger26, spice-monitor27, giant-anteater22 | 6 / 5 / 4 / 4 |
| Sea-cave Smugglers' Run | NWE (6) | coast | 10 | 10..13 | 15: herring-gull10, grey-heron15, hermit-crab-hoarder12, sea-otter-bandit13 | 5 / 6 / 5 / 6 |
| Pirate-gull Grottoes | SE (10) | island | 10 | 10..13 | 15: herring-gull10, hermit-crab-hoarder12, reef-turtle16 | 4 / 4 / 3 / 3 |
| Salt Mine Galleries | EE (14) | forest | 10 | 10..13 | 15: tunnel-mole9, carrion-crow9, giant-centipede11, red-fox16, raccoon16, tawny-owl17 | 7 / 6 / 5 / 4 |
| Rose-red Canyon City | MENA (17) | desert | 20 | 20..23 | 25: desert-gila-dragon20, desert-tortoise24, griffon-vulture24, desert-camel27 | 3 / 2 / 3 / 3 |
| The Canopy Bridges | WCA (29) | rainforest | 20 | 20..23 | 25: moss-golem20, emerald-python25, jungle-tiger26, spice-monitor27, giant-anteater22 | 6 / 5 / 4 / 4 |
| Fynbos Fire Trails | ESA (32) | desert | 20 | 20..23 | 25: desert-gila-dragon20, desert-tortoise24, griffon-vulture24, desert-camel27 | 3 / 2 / 3 / 3 |
| Snowleopard Ledges | CSA (23) | mountain | 20 | 20..23 | 25: moss-golem20, cliff-ram21, wolverine21, tufted-lynx23, griffon-vulture24, black-bear25 | 6 / 7 / 8 / 8 |
| The Long Wall Walk | EA (20) | desert | 20 | 20..23 | 25: desert-gila-dragon20, desert-tortoise24, griffon-vulture24, desert-camel27 | 3 / 2 / 3 / 3 |
| Firefly Caves | SEA (26) | rainforest | 20 | 20..23 | 25: moss-golem20, emerald-python25, jungle-tiger26, spice-monitor27, giant-anteater22 | 6 / 5 / 4 / 4 |
| The Red Rock Songlines | OC (35) | desert | 20 | 20..23 | 25: desert-gila-dragon20, desert-tortoise24, griffon-vulture24, desert-camel27 | 3 / 2 / 3 / 3 |

The guardian is an ordinary pick at +2 (no size rule): Pirate-gull Grottoes can be guarded by a Herring Gull L10. Desert delves have 2-3 candidates per stage.

### 3.5 Explore from road stops

`xN` = number of road stops. Pool n at steps 3 / 5 / 7 (`*` = scaled).

| reg (L) | d1 own land | d2 near land (per stop) | d3-4 zone2 (L+1,+2) | d5-6 zone3 (L+3,+5) | d7-8 zone4 (L+7,+9; bosses, full strength) | pool n d3/d5/d7 | bosses possible at d7-8 |
|---|---|---|---|---|---|---|---|
| NA (1) | forestx1, grasslandx3 | coastx1, mountainx1, wetlandx1, forestx1 | forest | coast | tundra | 6 / 5 / 3 | - |
| CA (4) | rainforestx2, grasslandx3 | rainforestx2, desertx1, mountainx2 | rainforest | desert | mountain | 7 / 7 / 6 | - |
| NWE (6) | forestx2, grasslandx3 | forestx2, mountainx1, wetlandx1, tundrax1 | forest | coast | tundra | 11 / 5 / 1 | - |
| CB (8) | coastx1, islandx3 | rainforestx2, forestx1, coastx1 | coast | rainforest | wetland | 5 / 5 / 5 | - |
| SE (10) | mountainx1, coastx3 | forestx2, mountainx1, islandx1 | mountain | island | mountain | 6 / 3 / 6 | - |
| SA (12) | mountainx3, grasslandx3 | rainforestx3, mountainx1, desertx2 | mountain | rainforest | desert | 4 / 5 / 3 | - |
| EE (14) | forestx1, grasslandx3 | mountainx1, tundrax1, forestx1, wetlandx1 | forest | wetland | mountain | 6 / 6 / 7 | - |
| MENA (17) | grasslandx2, coastx3 | mountainx2, grasslandx1, desertx2 | grassland | mountain | desert | 4 / 6 / 3 | dune-wyrm30 |
| EA (20) | forestx3, grasslandx3 | mountainx3, wetlandx1, forestx1, desertx1 | forest | coast | desert | 10 / 4 / 3 | dune-wyrm30 |
| CSA (23) | grasslandx4, wetlandx3, forestx1 | mountainx4, grasslandx2, forestx2 | grassland | forest | mountain | 4 / 8 / 3 | storm-eagle32 |
| SEA (26+g) | coastx3, wetlandx3 | coastx2, islandx2, rainforestx2 | coast | island | rainforest | 4 / 2 / 1 | jade-jaguar32 |
| WCA (29+g) | wetlandx1, grasslandx3 | wetlandx2, forestx1, rainforestx1 | wetland | rainforest | coast | 3 / 2 / 3 | reef-leviathan29 |
| ESA (32+g) | mountainx2, grasslandx3 | desertx3, mountainx1, wetlandx1 | mountain | wetland | desert | 2 / 1 / 1 | dune-wyrm30 |
| OC (35+g) | coastx2, islandx3 | desertx2, mountainx1, rainforestx1, coastx1 | coast | forest | desert | 3 / 1 / 3* | dune-wyrm30 |

Bosses off the path are reachable at region level only in MENA, EA, CSA and the top four; elsewhere only from step 9 (gnome level). No region's zone 3-4 is grassland, forest (except OC zone 3) or island, so great-hawk, old-bramblehorn, coconut-crab-titan come only from return legs of landmark routes and lair-route E spots.

### 3.6 Trek pools (own system; fixed levels; bosses scripted, not in pools)

| file | ch | zone | fight chance (% of trek_enc_percent=9) | pool (slug sizeLv:weight) |
|---|---|---|---|---|
| tc | 1 | g | 100 | withered-aphid S15:1 |
| tc | 1 | w | 100 | withered-aphid S15:2, earthworm-bully S15:2, ashen-ant S16:1 |
| tc | 1 | c | 0 | withered-aphid S15:1 |
| tc | 1 | f | 100 | earthworm-bully S15:2, pill-bug-brute M16:2, root-weevil S17:2, grub-beetle M17:3, mole-cricket M17:1 |
| tc | 1 | d | 100 | dew-leech M16:4, rot-snail M16:1, earthworm-bully S15:1 |
| tc | 1 | h | 60 | ashen-ant S16:1, rot-snail M16:1, root-weevil S17:1 |
| tc | 1 | b | 200 | stag-beetle-patrol L18:1 |
| tc | 1 | r | 110 | rot-snail M16:2, ashen-ant S16:2, withered-aphid S15:1, mole-cricket M17:1 |
| tc | 1 | x | 0 | ashen-ant S16:1 |
| tc_ch2 | 2 | j | 115 | clay-crawler S17:3, mud-crayfish M18:2 |
| tc_ch2 | 2 | k | 0 | clay-crawler S17:1 |
| tc_ch2 | 2 | l | 130 | page-silverfish S18:3, spadefoot-toad M19:2, mud-crayfish M18:1, clay-crawler S17:1, claybound-millipede L20:1 |
| tc_ch2 | 2 | m | 100 | spadefoot-toad M19:3, clay-crawler S17:2, mud-crayfish M18:1, claybound-millipede L20:1 |
| tc_ch2b | 2 | n | 90 | mud-crayfish M18:2, spadefoot-toad M19:2, dimwing-moth S19:1 |
| tc_ch2b | 2 | o | 130 | claybound-millipede L20:1 |
| tc_ch2b | 2 | p | 95 | dimwing-moth S19:3, cistern-newt M20:2, spadefoot-toad M19:1 |
| tc_ch2b | 2 | q | 0 | dimwing-moth S19:1 |
| tc_ch2b | 2 | r | 105 | cistern-newt M20:3, mud-crayfish M18:1, claybound-millipede L20:1 |
| tc_ch2b | 2 | s | 110 | drumming-cricket M21:3, cistern-newt M20:1 |
| tc_ch3 | 3 | t | 105 | shale-slater S20:3, quartz-snail M21:2 |
| tc_ch3 | 3 | u | 0 | shale-slater S20:1 |
| tc_ch3 | 3 | v | 110 | quartz-snail M21:2, pale-olm M21:2, shale-slater S20:1, gravel-centipede L23:1 |
| tc_ch3 | 3 | w | 115 | echo-bat M22:3, pale-olm M21:2, gravel-centipede L23:1 |
| tc_ch3 | 3 | x | 105 | echo-bat M22:2, gravel-centipede L23:2, pale-olm M21:1 |
| tc_ch3b | 3 | y | 105 | tallow-grub S24:3, stone-loach M25:1, crystal-weaver M25:1 |
| tc_ch3b | 3 | z | 110 | stone-loach M25:3, tallow-grub S24:1, bellcap-beetle M26:1 |
| tc_ch3b | 3 | l | 0 | tallow-grub S24:1 |
| tc_ch3b | 3 | g | 115 | crystal-weaver M25:2, bellcap-beetle M26:2, basalt-borer L27:1 |
| tc_ch3b | 3 | k | 105 | bellcap-beetle M26:2, basalt-borer L27:2, crystal-weaver M25:1 |

All pool slugs exist; all non-boss trek creatures are in a pool.

### 3.7 Every route

`sec` = authored stretches. `E[...]` = expected random fights on the shortest line + door events. Camp = stretch:x,y. Pool for a row = 2.1 ladder cut at `Lv-6..Lv+2` for the out / back land.

| id | from > to | type | land out/back | Lv | sec | fight tiles plain+rough (rough %) | path len | E[random fights] walk+doors | roughest stretch | fixed fights (E/M) | camp sec:x,y | road kind |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 228 | The Maplewold Market > Poppyburrow | road | grassland/grassland | 1+g | 3 | 789+189 (19%) | 65 | 2.0+0.5 | s1 the scarecrow field, and the hay-bale  (26%) |  | 2:27,9 | toll |
| 229 | Poppyburrow > Larkbrook | road | grassland/grassland | 2 | 3 | 684+229 (25%) | 82 | 2.7+0.5 | s3 the daisy ring (31%) |  | 2:4,2 |  |
| 230 | Larkbrook > Poppynook | road | grassland/grassland | 4 | 3 | 676+232 (26%) | 84 | 2.8+0.5 | s3 the daisy ring (31%) |  | 2:20,4 |  |
| 231 | Poppynook > Maizehollow Market | road | grassland/grassland | 4+g | 3 | 620+264 (30%) | 76 | 2.7+0.5 | s1 the old milestone (35%) |  | 2:23,9 | toll |
| 232 | The Maplewold Market > Honeybrook | road | grassland/grassland | 1+g | 3 | 755+270 (26%) | 104 | 3.3+0.5 | s3 the clover crossroads, and the picnic  (37%) |  | 2:17,6 |  |
| 233 | Honeybrook > Windbottom | road | grassland/grassland | 3 | 3 | 587+253 (30%) | 115 | 3.9+0.5 | s1 the dandelion drift (34%) |  | 2:15,9 |  |
| 234 | Windbottom > Windburrow | road | grassland/grassland | 6 | 3 | 682+204 (23%) | 96 | 2.8+0.5 | s2 the plank footbridge (32%) |  | 2:3,2 |  |
| 235 | Windburrow > Mistmoor Market | road | grassland/grassland | 6+g | 3 | 709+225 (24%) | 114 | 4.0+0.5 | s3 the old milestone (27%) |  | 2:14,4 | toll |
| 236 | The Maplewold Market > Cloverholt | road | grassland/grassland | 1+g | 3 | 720+244 (25%) | 106 | 3.7+0.5 | s1 the wildflower slope, and the dandelio (40%) |  | 2:13,2 |  |
| 237 | Cloverholt > Honeythorpe | road | grassland/grassland | 10 | 3 | 631+245 (28%) | 98 | 3.4+0.5 | s3 the plank footbridge (37%) | M s2@13,13: grass-snake L14 (+4) | 2:27,13 |  |
| 238 | Honeythorpe > Clovercove | road | grassland/grassland | 20 | 3 | 627+198 (24%) | 109 | 3.1+0.5 | s2 the bramble gap (25%) |  | 2:10,2 |  |
| 240 | Maizehollow Market > Meadowmere | road | grassland/grassland | 4+g | 3 | 700+232 (25%) | 115 | 3.9+0.5 | s3 the shepherd's wall (30%) | M s2@16,7: grass-snake L14 (+10) | 2:15,6 |  |
| 241 | Meadowmere > Shoreford | road | island/grassland | 6 | 3 | 659+213 (24%) | 111 | 3.7+0.5 | s1 the hammock palms (28%) |  | 2:13,10 | ferry |
| 242 | Shoreford > Breezehollow | road | island/island | 8 | 3 | 714+212 (23%) | 108 | 3.2+0.5 | s1 the sand spit (25%) |  | 2:13,3 |  |
| 243 | Breezehollow > The Sunsprinkle Isles Market | road | island/island | 8+g | 3 | 702+215 (23%) | 104 | 3.3+0.5 | s1 the palm lean (30%) |  | 2:15,5 | ferry |
| 244 | Maizehollow Market > Jadedell | road | rainforest/rainforest | 4+g | 3 | 587+179 (23%) | 118 | 3.9+0.5 | s1 the stepping-roots (27%) |  | 2:18,5 | overgrown |
| 245 | Jadedell > Barleyglen | road | grassland/rainforest | 8 | 3 | 630+276 (30%) | 107 | 3.6+0.5 | s2 the picnic knoll (33%) |  | 2:18,2 |  |
| 246 | Barleyglen > Windwell | road | grassland/grassland | 12 | 3 | 651+273 (30%) | 85 | 2.5+0.5 | s2 the picnic knoll (33%) |  | 2:12,5 |  |
| 247 | Windwell > The Rainroot Reaches Market | road | grassland/grassland | 12+g | 3 | 733+240 (25%) | 94 | 3.0+0.5 | s2 the bramble gap (34%) |  | 2:7,2 | toll |
| 248 | The Sunsprinkle Isles Market > Palmknoll | road | island/island | 8+g | 3 | 633+277 (30%) | 74 | 2.1+0.5 | s3 the tide-cave (34%) | M s2@15,10: tide-crab-knight L19 (+11) | 2:7,5 | toll |
| 249 | Palmknoll > Thistlebottom | road | grassland/island | 10 | 3 | 684+245 (26%) | 76 | 2.1+0.5 | s1 the shepherd's wall (32%) |  | 2:4,2 |  |
| 250 | Thistlebottom > Flintburrow | road | mountain/grassland | 12 | 3 | 489+282 (37%) | 75 | 2.3+0.5 | s1 the rope bridge (38%) | M s3@17,9: moss-golem L20 (+8) | 2:2,6 |  |
| 251 | Flintburrow > The Rainroot Reaches Market | road | mountain/mountain | 12+g | 3 | 500+270 (35%) | 74 | 2.5+0.5 | s3 the echo wall (38%) |  | 2:21,5 |  |
| 252 | The Rainroot Reaches Market > Highcove | road | mountain/mountain | 12+g | 3 | 508+269 (35%) | 113 | 4.1+0.5 | s2 the switchback bend (36%) |  | 2:15,7 |  |
| 253 | Highcove > Palmgate | road | island/mountain | 23 | 3 | 629+217 (26%) | 109 | 3.6+0.5 | s3 the reef shallows (30%) |  | 2:10,3 | ferry |
| 254 | Palmgate > Reefknoll | road | island/island | 35+g | 3 | 675+224 (25%) | 112 | 3.3+0.5 | s2 the sand spit (28%) |  | 2:14,10 |  |
| 255 | Reefknoll > The Coralscatter Market | road | island/island | 35+g | 3 | 668+220 (25%) | 111 | 3.8+0.5 | s2 the palm lean (28%) |  | 2:18,5 | ferry |
| 256 | Mistmoor Market > Larkden | road | grassland/grassland | 6+g | 3 | 648+286 (31%) | 92 | 2.8+0.5 | s1 the picnic knoll (37%) | M s3@22,8: red-fox L16 (+10) | 2:12,7 |  |
| 257 | Larkden > Brinewick | road | coast/grassland | 8 | 3 | 743+224 (23%) | 90 | 2.6+0.5 | s1 the sandbar causeway (26%) |  | 2:12,6 | ferry |
| 258 | Brinewick > Driftmead | road | coast/coast | 10 | 3 | 745+216 (22%) | 87 | 2.8+0.5 | s1 the bottle post (27%) |  | 2:14,9 |  |
| 259 | Driftmead > Olivewhistle Shore Market | road | coast/coast | 10+g | 3 | 737+203 (22%) | 94 | 2.7+0.5 | s1 the rope-and-net rack (25%) |  | 2:7,2 | toll |
| 260 | Mistmoor Market > Hollowknoll | road | forest/forest | 6+g | 3 | 655+168 (20%) | 112 | 3.4+0.5 | s3 the fallen-log bridge (23%) |  | 2:16,8 | overgrown |
| 261 | Hollowknoll > Thistleburrow | road | grassland/forest | 10 | 3 | 603+256 (30%) | 116 | 3.9+0.5 | s1 the picnic knoll (34%) |  | 2:16,12 |  |
| 262 | Thistleburrow > Haynook | road | grassland/grassland | 14 | 3 | 696+254 (27%) | 112 | 4.0+0.5 | s1 the plank footbridge (28%) |  | 2:14,2 |  |
| 263 | Haynook > Birchbramble Steppe Market | road | grassland/grassland | 14+g | 3 | 600+230 (28%) | 127 | 4.4+0.5 | s1 the bramble gap (31%) |  | 2:15,2 | toll |
| 264 | Olivewhistle Shore Market > Sprayglen | road | coast/coast | 10+g | 3 | 786+201 (20%) | 110 | 3.4+0.5 | s2 the lighthouse shadow (23%) | M s2@14,10: tide-crab-knight L19 (+9) | 2:17,10 | overgrown |
| 265 | Sprayglen > Gullwell | road | coast/coast | 13 | 3 | 710+200 (22%) | 102 | 3.4+0.5 | s3 the sea-stack gap (27%) |  | 2:18,12 |  |
| 266 | Gullwell > Gullstead | road | coast/coast | 17 | 3 | 648+209 (24%) | 117 | 3.5+0.5 | s3 the shell-heap (29%) |  | 2:14,9 |  |
| 267 | Gullstead > The Dunewhisper Market | road | coast/coast | 17+g | 3 | 746+226 (23%) | 93 | 2.4+0.5 | s3 the sea-stack gap (24%) |  | 2:11,3 | ferry |
| 268 | Birchbramble Steppe Market > Tussockgate | road | grassland/grassland | 14+g | 3 | 645+235 (27%) | 99 | 2.9+0.5 | s3 the sleepy windmill (28%) | M s3@27,6: wild-boar L21 (+7) | 2:13,7 |  |
| 269 | Tussockgate > Newtdell | road | wetland/grassland | 18 | 3 | 500+272 (35%) | 89 | 2.5+0.5 | s3 the willow curtain (40%) |  | 2:6,2 |  |
| 270 | Newtdell > Rushdell | road | wetland/wetland | 23 | 3 | 562+224 (28%) | 85 | 2.5+0.5 | s2 the reed causeway (32%) |  | 2:15,12 | flooded |
| 271 | Rushdell > Spicepeak Market | road | wetland/wetland | 23+g | 3 | 554+225 (29%) | 92 | 2.9+0.5 | s3 the frog choir (35%) |  | 2:9,2 | toll |
| 272 | The Dunewhisper Market > Brineburrow | road | coast/coast | 17+g | 3 | 737+239 (24%) | 100 | 3.0+0.5 | s2 the shell-heap (25%) | M s2@16,13: clam-lurker L23 (+6) | 2:15,5 | toll |
| 273 | Brineburrow > Cloverbottom | road | grassland/coast | 23 | 3 | 663+256 (28%) | 103 | 3.6+0.5 | s3 the lonely scarecrow (31%) |  | 2:20,4 |  |
| 274 | Cloverbottom > Thistleholt | road | grassland/grassland | 29+g | 3 | 705+229 (25%) | 111 | 3.4+0.5 | s2 the plank footbridge (27%) |  | 2:16,8 |  |
| 275 | Thistleholt > The Greatcanopy Market | road | grassland/grassland | 29+g | 3 | 700+267 (28%) | 91 | 2.9+0.5 | s2 the shepherd's wall (33%) |  | 2:27,2 | toll |
| 276 | The Dunewhisper Market > Meadowbrook | road | grassland/grassland | 17+g | 3 | 672+277 (29%) | 109 | 3.3+0.5 | s1 the bramble gap (34%) |  | 2:8,2 | overgrown |
| 277 | Meadowbrook > Heronby | road | wetland/grassland | 20 | 3 | 565+199 (26%) | 118 | 3.8+0.5 | s2 the willow curtain (32%) |  | 2:16,10 |  |
| 278 | Heronby > Cloverburrow | road | grassland/wetland | 23 | 3 | 671+217 (24%) | 113 | 3.5+0.5 | s1 the shepherd's wall (28%) | M s2@15,9: prairie-bison L26 (+3) | 2:13,3 |  |
| 279 | Cloverburrow > Spicepeak Market | road | grassland/grassland | 23+g | 3 | 641+307 (32%) | 117 | 3.7+0.5 | s3 the clover patch (35%) |  | 2:15,6 |  |
| 280 | The Greatcanopy Market > Hayglen | road | grassland/grassland | 29+g | 3 | 657+224 (25%) | 116 | 3.9+0.5 | s2 the picnic knoll (29%) | M s3@15,13: honey-badger-brute L32 (+3) | 2:18,11 |  |
| 281 | Hayglen > Meadowden | road | grassland/grassland | 30+g | 3 | 687+243 (26%) | 102 | 3.5+0.5 | s1 the bramble gap (27%) |  | 2:18,5 |  |
| 282 | Meadowden > Clovergate | road | grassland/grassland | 32+g | 3 | 621+262 (30%) | 85 | 2.8+0.5 | s1 the hay-cart ruts (32%) |  | 2:11,2 |  |
| 283 | Clovergate > Thornacre Savanna Market | road | grassland/grassland | 32+g | 3 | 732+234 (24%) | 106 | 3.2+0.5 | s2 the daisy ring (27%) |  | 2:19,9 | toll |
| 284 | Thornacre Savanna Market > Meadowbottom | road | grassland/grassland | 32+g | 3 | 650+283 (30%) | 88 | 2.9+0.5 | s3 the sleepy windmill (35%) | M s2@11,3: honey-badger-brute L32 (+0) | 2:13,4 |  |
| 285 | Meadowbottom > Summitglen | road | mountain/grassland | 32+g | 3 | 515+296 (36%) | 88 | 3.0+0.5 | s3 the echo wall (42%) |  | 2:18,2 |  |
| 286 | Summitglen > Windstead | road | grassland/mountain | 27+g | 3 | 711+223 (24%) | 87 | 2.7+0.5 | s1 the clover patch (27%) |  | 2:14,15 |  |
| 287 | Windstead > Spicepeak Market | road | grassland/grassland | 23+g | 3 | 652+272 (29%) | 81 | 2.5+0.5 | s2 the hay-cart ruts (30%) |  | 2:14,8 |  |
| 288 | Spicepeak Market > Poppythorpe | road | grassland/grassland | 23+g | 3 | 687+279 (29%) | 85 | 2.8+0.5 | s1 the clover patch (34%) |  | 2:18,6 |  |
| 289 | Poppythorpe > Poppywell | road | grassland/grassland | 21 | 3 | 625+279 (31%) | 116 | 4.2+0.5 | s1 the dandelion drift (34%) | M s3@14,6: prairie-bison L26 (+5) | 2:13,8 |  |
| 290 | Poppywell > Bramblebrook | road | forest/grassland | 20 | 3 | 697+179 (20%) | 88 | 3.0+0.5 | s1 the mushroom ring (24%) | M s2@13,13: jungle-tiger L26 (+6) | 2:14,10 | overgrown |
| 291 | Bramblebrook > Blossomreach Market | road | forest/forest | 20+g | 3 | 608+202 (25%) | 116 | 3.7+0.5 | s1 the mushroom ring (27%) |  | 2:12,3 |  |
| 292 | Spicepeak Market > Leafmead | road | forest/forest | 23+g | 3 | 687+217 (24%) | 112 | 3.3+0.5 | s2 the bluebell glade (30%) |  | 2:13,4 | overgrown |
| 293 | Leafmead > Marshcrest | road | wetland/forest | 24 | 3 | 482+257 (35%) | 86 | 2.9+0.5 | s3 the mud-skipper flats (40%) |  | 2:18,12 | ferry |
| 294 | Marshcrest > Rushglen | road | wetland/wetland | 26+g | 3 | 520+269 (34%) | 112 | 3.8+0.5 | s3 the lily-pad ford (35%) |  | 2:17,6 |  |
| 295 | Rushglen > The Monsoon Tangle Market | road | wetland/wetland | 26+g | 3 | 524+240 (31%) | 113 | 3.7+0.5 | s2 the lily-pad ford (32%) |  | 2:15,2 | toll |
| 296 | Blossomreach Market > Birchford | road | forest/forest | 20+g | 3 | 641+235 (27%) | 71 | 2.1+0.5 | s2 the spring and the pebbles (29%) |  | 2:23,2 |  |
| 297 | Birchford > Lilyby | road | wetland/forest | 23 | 3 | 517+264 (34%) | 104 | 3.1+0.5 | s3 the dragonfly bend (39%) |  | 2:17,7 |  |
| 298 | Lilyby > Sandpiperglen | road | coast/wetland | 26+g | 3 | 753+234 (24%) | 85 | 2.4+0.5 | s1 the sandbar causeway (26%) | M s3@9,8: mangrove-crab-king L30 (+4) | 2:21,3 |  |
| 299 | Sandpiperglen > The Monsoon Tangle Market | road | coast/coast | 26+g | 3 | 765+202 (21%) | 74 | 2.0+0.5 | s3 the barnacle wall (23%) |  | 2:25,3 |  |
| 300 | The Monsoon Tangle Market > Shellnook | road | coast/coast | 26+g | 3 | 691+206 (23%) | 120 | 3.7+0.5 | s1 the driftwood arch (25%) |  | 2:14,12 | flooded |
| 301 | Shellnook > Turtleburrow | road | island/coast | 30+g | 3 | 686+229 (25%) | 93 | 2.8+0.5 | s2 the reef shallows (26%) |  | 2:8,2 |  |
| 302 | Turtleburrow > Brineglen | road | coast/island | 35+g | 3 | 717+210 (23%) | 95 | 2.7+0.5 | s3 the kelp-line (25%) | M s2@11,10: deep-octopus L37 (+2) | 2:11,2 | flooded |
| 303 | Brineglen > The Coralscatter Market | road | coast/coast | 35+g | 3 | 730+215 (23%) | 81 | 2.4+0.5 | s1 the barnacle wall (26%) |  | 2:13,6 | toll |
| 304 | Poppyburrow > Acornby | side>village | forest/grassland | 1 | 2 | 462+80 (15%) | 71 | 2.1+0.2 | s2 the acorn drop, and the owl-hole oak (18%) |  | 1:13,9 | overgrown |
| 305 | Honeybrook > Birchhollow | side>village | forest/grassland | 1 | 2 | 497+99 (17%) | 44 | 1.1+0.2 | s2 the fern hollow, and the sunbeam clear (22%) |  | 1:23,8 |  |
| 306 | Cloverholt > Mossgate | side>village | forest/grassland | 1 | 2 | 476+77 (14%) | 58 | 1.5+0.2 | s2 the mossy gate, and the toadstool step (19%) |  | 1:17,3 |  |
| 307 | Poppyburrow > Shellhollow | side>village | coast/grassland | 1 | 2 | 395+156 (28%) | 70 | 1.9+0.2 | s1 the long tideline, and the barnacle ro (32%) |  | 1:15,4 | flooded |
| 308 | Honeybrook > Pebblestead | side>village | coast/grassland | 1 | 2 | 404+126 (24%) | 68 | 2.0+0.2 | s1 the pebble bar, and the kelp line (29%) |  | 1:14,4 | ferry |
| 309 | Cloverholt > Iciclecrest | side>village | tundra/grassland | 1 | 2 | 475+173 (27%) | 74 | 2.7+0.2 | s1 the frozen pond, and the snowman galle (27%) | M s2@13,7: arctic-fox L17 (+16) | 1:15,8 | tunnel2 |
| 310 | Poppyburrow > Snowcombe | side>village | tundra/grassland | 1 | 2 | 455+171 (27%) | 68 | 1.9+0.2 | s1 the snowdrift pass, and the sled track (28%) | M s1@17,8: wolverine L21 (+20) | 1:13,8 | pass2 |
| 311 | Honeybrook > The Sugar Shack | side>haven | grassland/grassland | 1+g | 2 | 535+126 (19%) | 67 | 2.0+0.2 | s2 the Sugar Shack yard, and the pancake  (24%) |  | 1:18,2 |  |
| 312 | Cloverholt > Thousand Rings Stump | side>wonder | forest/grassland | 8-12 | 3 | 739+153 (17%) | 107 | 2.9+0.5 | s3 the great stump, and the squirrel's la (23%) | M s3@16,10: bramble-wolf L22 (+14) | 2:2,14 |  |
| 313 | Poppyburrow > Beaverdam Tunnels | side>delve | forest/grassland | 10-14 | 3 | 644+209 (25%) | 92 | 2.7+0.5 | s3 the tunnel mouth, and the glow-cap tun (36%) | E s3: miniboss | 2:16,11 |  |
| 314 | Honeybrook > Lighthouse of the Lost Lantern | side>wonder | coast/grassland | 8-12 | 3 | 655+204 (24%) | 85 | 2.4+0.5 | s1 the driftwood beach, and the shell pil (26%) | M s3@22,5: clam-lurker L23 (+15) | 2:16,6 |  |
| 315 | Cloverholt > Den of the Great White Owl | side>lair | tundra/grassland | 8-12 | 5 (steps 3!) | 1140+401 (26%) | 181 | 5.6+1.0 | s4 the giant feather, and the feather cai (34%) | E s5: boss | 3:17,5 |  |
| 316 | Poppyburrow > Aurora Camp | side>haven | tundra/grassland | 1+g | 2 | 492+125 (20%) | 72 | 2.2+0.2 | s2 the aurora camp, and the kettle tree (20%) |  | 1:14,6 |  |
| 317 | Larkbrook > Frondthorpe | side>village | rainforest/grassland | 4 | 2 | 419+144 (26%) | 75 | 3.1+0.2 | s1 the canopy gap (26%) | M s2@15,9: mischief-monkey L15 (+11) | 1:14,11 |  |
| 318 | Poppynook > Orchiddell | side>village | rainforest/grassland | 4 | 2 | 375+136 (27%) | 77 | 2.6+0.2 | s1 the vine bridge (28%) |  | 1:11,15 |  |
| 319 | Meadowmere > Saffroncrest | side>village | desert/grassland | 4 | 2 | 520+125 (19%) | 67 | 1.8+0.2 | s1 the waystone cluster (20%) |  | 1:14,4 |  |
| 320 | Jadedell > Scorchburrow | side>village | desert/rainforest | 4 | 2 | 469+110 (19%) | 76 | 2.5+0.2 | s1 the cactus garden (19%) |  | 1:15,9 |  |
| 321 | Larkbrook > Stonethorpe | side>village | mountain/grassland | 4 | 2 | 346+152 (31%) | 80 | 2.9+0.2 | s2 the stone hut (34%) | M s2@15,10: red-fox L16 (+12) | 1:17,7 | tunnel2 |
| 322 | Poppynook > Flintcove | side>village | mountain/grassland | 4 | 2 | 362+162 (31%) | 77 | 2.6+0.2 | s1 the echo wall (32%) |  | 1:11,8 | pass2 |
| 323 | Meadowmere > Market of a Thousand Chilies | side>haven | grassland/grassland | 4+g | 2 | 444+158 (26%) | 50 | 1.6+0.2 | s1 the picnic knoll (28%) |  | 1:19,7 |  |
| 324 | Jadedell > The Stepped Seed Temple | side>wonder | rainforest/rainforest | 8-12 | 3 | 586+218 (27%) | 89 | 2.6+0.5 | s1 the canopy gap (28%) |  | 2:15,8 | flooded |
| 325 | Larkbrook > Jaguar Root Caves | side>delve | rainforest/grassland | 10-14 | 3 | 588+231 (28%) | 109 | 3.4+0.5 | s3 the lantern line to Jaguar Root Caves (30%) | E s3: miniboss | 2:13,5 |  |
| 326 | Poppynook > Cenote of Echoes | side>wonder | desert/grassland | 8-12 | 3 | 803+239 (23%) | 113 | 3.6+0.5 | s3 the hush before Cenote of Echoes (24%) | M s2@15,9: grass-snake L14 (+6) | 2:17,8 |  |
| 327 | Meadowmere > Smokecap Caldera | side>lair | mountain/grassland | 6-10 | 5 (steps 3!) | 796+503 (39%) | 144 | 4.5+1.0 | s2 the wind notch (43%) | E s5: boss | 3:9,14 |  |
| 328 | Shoreford > Sandpipergate | side>village | coast/island | 8 | 2 | 487+159 (25%) | 46 | 1.2+0.2 | s2 the lighthouse shadow (26%) |  | 1:14,7 | tunnel2 |
| 329 | Breezehollow > Foamknoll | side>village | coast/island | 8 | 2 | 496+167 (25%) | 51 | 1.6+0.2 | s2 the tide-pool steps (28%) |  | 1:19,2 | pass2 |
| 330 | Palmknoll > Saltgate | side>village | coast/island | 8 | 2 | 450+147 (25%) | 74 | 2.1+0.2 | s1 the tide-pool steps (27%) | M s2@15,5: tide-crab-knight L19 (+11) | 1:13,10 |  |
| 331 | Shoreford > Lianacombe | side>village | rainforest/island | 8 | 2 | 381+157 (29%) | 50 | 1.7+0.2 | s1 the parrot perch (32%) |  | 1:5,5 | overgrown |
| 332 | Breezehollow > Canopybottom | side>village | rainforest/island | 8 | 2 | 380+152 (29%) | 64 | 1.9+0.2 | s1 the vine bridge (29%) |  | 1:21,14 |  |
| 333 | Palmknoll > Heronholt | side>village | wetland/island | 8 | 2 | 400+140 (26%) | 71 | 2.3+0.2 | s1 the mud-skipper flats (27%) |  | 1:16,6 |  |
| 334 | Shoreford > Mireburrow | side>village | wetland/island | 8 | 2 | 345+148 (30%) | 66 | 2.0+0.2 | s2 the willow curtain (33%) | M s2@10,4: mire-toad L18 (+10) | 1:15,6 |  |
| 335 | Breezehollow > Driftwood Tavern | side>haven | island/island | 8+g | 2 | 407+177 (30%) | 76 | 2.4+0.2 | s2 the last turn to Driftwood Tavern (31%) |  | 1:13,2 |  |
| 336 | Palmknoll > Sunken Gnome Galleon | side>wonder | coast/island | 8-12 | 3 | 748+263 (26%) | 89 | 3.0+0.5 | s1 the bottle post (28%) |  | 2:13,5 | flooded |
| 337 | Shoreford > Turtle Nesting Beach | side>haven | coast/island | 8+g | 2 | 487+134 (22%) | 66 | 2.1+0.2 | s2 the last turn to Turtle Nesting Beach (24%) |  | 1:13,14 |  |
| 338 | Breezehollow > The Singing Waterfall | side>wonder | rainforest/island | 8-12 | 3 | 592+222 (27%) | 77 | 2.5+0.5 | s3 the The Singing Waterfall gates (29%) | M s2@17,7: moss-golem L20 (+12) | 2:19,2 |  |
| 339 | Palmknoll > Mangrove Root Maze | side>delve | wetland/island | 20-24 | 4 | 703+270 (28%) | 124 | 3.9+0.7 | s3 the boardwalk gap (38%) | E s4: miniboss | 2:19,15 |  |
| 340 | Shoreford > Lair of the Hurricane Crab | side>lair | wetland/island | 10-14 | 5 (steps 3!) | 783+466 (37%) | 135 | 3.9+1.0 | s2 the reed causeway (48%) | E s5: boss | 3:17,6 |  |
| 341 | Barleyglen > Stoneden | side>village | mountain/grassland | 12 | 2 | 347+192 (36%) | 74 | 2.7+0.2 | s1 the pine shelf (36%) | M s2@13,1: moss-golem L20 (+8) | 1:13,2 | tunnel2 |
| 342 | Windwell > Figknoll | side>village | rainforest/grassland | 12 | 2 | 373+187 (33%) | 76 | 3.0+0.2 | s2 the vine bridge (41%) |  | 1:14,8 | overgrown |
| 343 | Thistlebottom > Frondstead | side>village | rainforest/grassland | 12 | 2 | 363+158 (30%) | 78 | 3.2+0.2 | s2 the orchid tree (35%) |  | 1:16,4 | flooded |
| 344 | Flintburrow > Canopyglen | side>village | rainforest/mountain | 12 | 2 | 408+180 (31%) | 77 | 2.6+0.2 | s2 the giant fern glade (32%) |  | 1:13,2 |  |
| 345 | Highcove > Scorchby | side>village | desert/mountain | 12 | 2 | 542+159 (23%) | 56 | 1.7+0.2 | s2 the sun-bleached bones (25%) | M s2@7,10: desert-gila-dragon L20 (+8) | 1:11,8 |  |
| 346 | Barleyglen > Duneford | side>village | desert/grassland | 12 | 2 | 519+145 (22%) | 71 | 2.1+0.2 | s1 the waystone cluster (22%) |  | 1:11,15 |  |
| 347 | Windwell > Gaucho Gnome Ranch | side>haven | grassland/grassland | 12+g | 2 | 501+177 (26%) | 67 | 2.2+0.2 | s1 the daisy ring (30%) |  | 1:13,15 |  |
| 348 | Thistlebottom > The Sky City Ruins | side>wonder | mountain/grassland | 8-12 | 3 | 541+228 (30%) | 117 | 4.4+0.5 | s3 the The Sky City Ruins gates (32%) |  | 2:14,2 | pass2 |
| 349 | Flintburrow > Condor's Crag | side>lair | mountain/mountain | 14-18 | 4 | 664+312 (32%) | 158 | 5.6+0.7 | s2 the echo wall (37%) | E s4: boss | 2:16,7 |  |
| 350 | Highcove > Pink River Dolphin Pools | side>wonder | rainforest/mountain | 18-22 | 4 | 790+335 (30%) | 102 | 2.9+0.7 | s3 the rain-drum leaf (31%) | M s3@14,7: moss-golem L20 (+2) | 2:14,4 |  |
| 351 | Barleyglen > Anaconda Hollows | side>delve | rainforest/grassland | 20-24 | 4 | 826+279 (25%) | 144 | 4.3+0.7 | s3 the parrot perch (27%) | E s4: miniboss | 2:17,7 |  |
| 352 | Windwell > The Mirror Salt Flat | side>wonder | desert/grassland | 8-12 | 3 | 740+243 (25%) | 120 | 3.6+0.5 | s3 the The Mirror Salt Flat gates (28%) |  | 2:18,7 |  |
| 353 | Windbottom > Fernden | side>village | forest/grassland | 6 | 2 | 408+137 (25%) | 51 | 1.3+0.2 | s2 the mushroom ring (26%) | M s2@16,8: raccoon L16 (+10) | 1:15,5 |  |
| 354 | Windburrow > Hazelmere | side>village | forest/grassland | 6 | 2 | 448+122 (21%) | 45 | 1.3+0.2 | s2 the lantern branch (22%) |  | 1:13,4 |  |
| 355 | Larkden > Spraywell | side>village | coast/grassland | 6 | 2 | 453+145 (24%) | 70 | 2.2+0.2 | s2 the lighthouse shadow (25%) |  | 1:14,2 | flooded |
| 356 | Hollowknoll > Brinehollow | side>village | coast/forest | 6 | 2 | 482+161 (25%) | 45 | 1.3+0.2 | s2 the stranded rowboat (28%) |  | 1:7,4 |  |
| 357 | Windbottom > Froststead | side>village | tundra/grassland | 6 | 2 | 368+162 (31%) | 50 | 1.6+0.2 | s2 the lone fir (31%) | M s2@13,7: red-fox L16 (+10) | 1:14,12 | tunnel2 |
| 358 | Windburrow > Sleetford | side>village | tundra/grassland | 6 | 2 | 420+178 (30%) | 51 | 1.5+0.2 | s1 the snow-fort (32%) |  | 1:23,7 | pass2 |
| 359 | Larkden > Thatchtop Tearoom | side>haven | grassland/grassland | 6+g | 2 | 463+117 (20%) | 80 | 2.6+0.2 | s2 the Thatchtop Tearoom path (22%) |  | 1:18,12 |  |
| 360 | Hollowknoll > The Standing Stones | side>wonder | grassland/forest | 1-5 | 2 | 486+143 (23%) | 52 | 1.4+0.2 | s1 the plank footbridge (26%) |  | 1:8,2 |  |
| 361 | Windbottom > Fairy-ring Clearing | side>wonder | forest/grassland | 8-12 | 3 | 619+212 (26%) | 66 | 1.8+0.5 | s2 the hollow oak (29%) | M s3@14,10: raccoon L16 (+8) | 2:19,6 |  |
| 362 | Windburrow > Sea-cave Smugglers' Run | side>delve | coast/grassland | 10-14 | 3 | 728+214 (23%) | 87 | 2.4+0.5 | s2 the rope-and-net rack (28%) | E s3: miniboss | 2:12,11 |  |
| 363 | Larkden > Barrow of the Frost Toad | side>lair | tundra/grassland | 8-12 | 5 (steps 3!) | 997+397 (28%) | 188 | 6.2+1.0 | s5 the threshold of Barrow of the Frost T (32%) | E s5: boss | 3:9,11 |  |
| 364 | Hollowknoll > Northern Lights Sauna | side>haven | tundra/forest | 6+g | 2 | 431+165 (28%) | 68 | 2.2+0.2 | s2 the Northern Lights Sauna path (30%) |  | 1:13,12 |  |
| 365 | Brinewick > Cliffbrook | side>village | mountain/coast | 10 | 2 | 368+147 (29%) | 73 | 2.3+0.2 | s1 the eagle's rest (29%) |  | 1:13,5 | tunnel2 |
| 366 | Driftmead > Screebottom | side>village | mountain/coast | 10 | 2 | 358+175 (33%) | 73 | 2.2+0.2 | s1 the rope bridge (38%) |  | 1:15,8 | pass2 |
| 367 | Sprayglen > Screemere | side>village | mountain/coast | 10 | 2 | 335+178 (35%) | 62 | 1.8+0.2 | s2 the eagle's rest (37%) | M s2@18,16: moss-golem L20 (+10) | 1:17,2 |  |
| 368 | Brinewick > Atollmead | side>village | island/coast | 10 | 2 | 417+117 (22%) | 86 | 2.8+0.2 | s1 the shell-bell tree (24%) |  | 1:13,2 |  |
| 369 | Driftmead > Turtlenook | side>village | island/coast | 10 | 2 | 455+138 (23%) | 78 | 2.2+0.2 | s2 the rope swing (25%) |  | 1:14,2 |  |
| 370 | Sprayglen > Cragholt | side>village | mountain/coast | 10 | 2 | 319+186 (37%) | 73 | 2.6+0.2 | s1 the goat ledge (38%) |  | 1:16,5 |  |
| 371 | Brinewick > Echonook | side>village | mountain/coast | 10 | 2 | 336+169 (33%) | 69 | 2.1+0.2 | s2 the stone hut (37%) | M s2@15,9: moss-golem L20 (+10) | 1:17,10 |  |
| 372 | Driftmead > Olive Press Piazza | side>haven | coast/coast | 10+g | 2 | 485+124 (20%) | 70 | 2.2+0.2 | s1 the lighthouse shadow (21%) |  | 1:12,3 | flooded |
| 373 | Sprayglen > Lemon Grove Monastery | side>haven | coast/coast | 10+g | 2 | 496+148 (23%) | 72 | 2.2+0.2 | s2 the last turn to Lemon Grove Monastery (24%) |  | 1:14,2 |  |
| 374 | Brinewick > Goat Path Vineyards | side>wonder | mountain/coast | 8-12 | 3 | 527+225 (30%) | 112 | 3.6+0.5 | s2 the pine shelf (37%) |  | 2:13,11 |  |
| 375 | Driftmead > The Labyrinth Isle | side>wonder | island/coast | 8-12 | 3 | 605+234 (28%) | 113 | 4.1+0.5 | s2 the reef shallows (31%) | M s2@17,6: tide-crab-knight L19 (+11) | 2:13,5 | ferry |
| 376 | Sprayglen > Pirate-gull Grottoes | side>delve | island/coast | 10-14 | 3 | 684+223 (25%) | 115 | 4.1+0.5 | s2 the tide-cave (26%) | E s3: miniboss | 2:15,8 |  |
| 377 | Brinewick > Forge of the Cinder Wyrm | side>lair | mountain/coast | 12-16 | 5 (steps 3!) | 803+443 (36%) | 148 | 4.6+1.0 | s5 the threshold of Forge of the Cinder W (37%) | E s5: boss | 3:10,10 |  |
| 378 | Thistleburrow > Hazelthorpe | side>village | forest/grassland | 14 | 2 | 457+95 (17%) | 44 | 1.3+0.2 | s1 the lantern branch (17%) |  | 1:11,2 | overgrown |
| 379 | Haynook > Mossknoll | side>village | forest/grassland | 14 | 2 | 450+140 (24%) | 45 | 1.4+0.2 | s2 the owl-watch bough (27%) |  | 1:22,4 |  |
| 380 | Tussockgate > Fernford | side>village | forest/grassland | 14 | 2 | 390+139 (26%) | 73 | 2.1+0.2 | s1 the glow-moss grotto (31%) | M s2@14,16: beaver-foreman L22 (+8) | 1:18,7 |  |
| 381 | Thistleburrow > Miregate | side>village | wetland/grassland | 14 | 2 | 372+187 (33%) | 45 | 1.2+0.2 | s2 the stilt-house (36%) |  | 1:2,6 |  |
| 382 | Haynook > Reedby | side>village | wetland/grassland | 14 | 2 | 307+195 (39%) | 49 | 1.8+0.2 | s1 the willow curtain (43%) |  | 1:9,6 | ferry |
| 383 | Tussockgate > Echohollow | side>village | mountain/grassland | 14 | 2 | 332+178 (35%) | 66 | 2.0+0.2 | s2 the pine shelf (41%) |  | 1:13,7 | tunnel3 |
| 384 | Thistleburrow > Flintknoll | side>village | mountain/grassland | 14 | 2 | 338+180 (35%) | 66 | 2.0+0.2 | s2 the goat ledge (36%) | M s2@9,4: cliff-ram L21 (+7) | 1:15,2 | pass3 |
| 385 | Haynook > Painted Egg House | side>haven | grassland/grassland | 14+g | 2 | 459+174 (27%) | 70 | 2.0+0.2 | s2 the Painted Egg House path (29%) |  | 1:13,4 |  |
| 386 | Tussockgate > The Amber Woods | side>wonder | forest/grassland | 8-12 | 3 | 622+196 (24%) | 111 | 3.6+0.5 | s1 the fern tunnel (27%) |  | 2:16,6 |  |
| 387 | Thistleburrow > Salt Mine Galleries | side>delve | forest/grassland | 10-14 | 3 | 618+194 (24%) | 87 | 2.5+0.5 | s2 the hollow oak (28%) | E s3: miniboss | 2:11,13 |  |
| 388 | Haynook > Stork Chimney Village | side>wonder | wetland/grassland | 8-12 | 3 | 493+267 (35%) | 88 | 2.5+0.5 | s2 the willow curtain (39%) |  | 2:12,15 | flooded |
| 389 | Tussockgate > Lair of the Grey Wolf King | side>lair | mountain/grassland | 16-20 | 5 (steps 4!) | 959+377 (28%) | 193 | 6.0+1.0 | s3 the waterfall mist (36%) | E s5: boss | 3:14,2 |  |
| 390 | Gullwell > Windford | side>village | grassland/coast | 17 | 2 | 451+182 (29%) | 63 | 2.1+0.2 | s1 the sleepy windmill (30%) | M s2@7,2: giant-bumblebee L23 (+6) | 1:13,13 |  |
| 391 | Gullstead > Prairieden | side>village | grassland/coast | 17 | 2 | 443+144 (25%) | 65 | 2.3+0.2 | s1 the hay-cart ruts (29%) |  | 1:15,5 |  |
| 392 | Brineburrow > Craghollow | side>village | mountain/coast | 17 | 2 | 336+167 (33%) | 75 | 2.2+0.2 | s2 the goat ledge (34%) |  | 1:13,5 | tunnel3 |
| 393 | Meadowbrook > Cragmead | side>village | mountain/grassland | 17 | 2 | 317+189 (37%) | 51 | 1.7+0.2 | s1 the stone hut (41%) |  | 1:19,12 | pass3 |
| 394 | Gullwell > Ambercrest | side>village | desert/coast | 17 | 2 | 498+164 (25%) | 72 | 2.3+0.2 | s2 the salt flat (28%) | M s2@18,16: desert-tortoise L24 (+7) | 1:13,2 |  |
| 395 | Gullstead > Amberholt | side>village | desert/coast | 17 | 2 | 513+153 (23%) | 72 | 2.4+0.2 | s2 the cactus garden (26%) |  | 1:12,2 |  |
| 396 | Brineburrow > Sandbottom | side>village | desert/coast | 17 | 2 | 557+135 (20%) | 66 | 1.9+0.2 | s2 the sand-ripple lane (20%) |  | 1:13,2 |  |
| 397 | Meadowbrook > Spice Souk | side>haven | coast/grassland | 17+g | 2 | 476+163 (26%) | 50 | 1.4+0.2 | s1 the bottle post (26%) |  | 1:2,3 | flooded |
| 398 | Gullwell > The Hanging Garden Ruins | side>wonder | grassland/coast | 8-12 | 3 | 685+271 (28%) | 117 | 4.2+0.5 | s1 the picnic knoll (32%) | M s2@16,5: giant-bumblebee L23 (+15) | 2:16,2 |  |
| 399 | Gullstead > Cedar Sanctuary | side>wonder | mountain/coast | 8-12 | 3 | 487+287 (37%) | 113 | 3.4+0.5 | s2 the cairn pass (40%) |  | 2:8,15 |  |
| 400 | Brineburrow > The Oasis That Moves | side>wonder | desert/coast | 18-22 | 4 | 1066+272 (20%) | 127 | 4.2+0.7 | s4 the hush before The Oasis That Moves (23%) |  | 2:15,4 |  |
| 401 | Meadowbrook > Rose-red Canyon City | side>delve | desert/grassland | 20-24 | 4 | 1070+331 (24%) | 127 | 3.7+0.7 | s2 the cactus garden (26%) | E s4: miniboss | 2:17,4 |  |
| 402 | Gullwell > Tomb of the Sand Scarab | side>lair | desert/coast | 19-23 | 5 (steps 4!) | 1311+388 (23%) | 181 | 5.6+1.0 | s3 the sand-ripple lane (25%) | E s5: boss | 3:14,2 |  |
| 403 | Cloverbottom > Fenmead | side>village | wetland/grassland | 29+g | 2 | 353+154 (30%) | 72 | 2.5+0.2 | s1 the willow curtain (40%) |  | 1:10,2 | flooded |
| 404 | Thistleholt > Fenwell | side>village | wetland/grassland | 29+g | 2 | 341+175 (34%) | 75 | 2.8+0.2 | s2 the heron's post (36%) |  | 1:14,6 |  |
| 405 | Hayglen > Heronwick | side>village | wetland/grassland | 29+g | 2 | 339+183 (35%) | 64 | 1.8+0.2 | s2 the willow curtain (36%) | M s2@18,13: mangrove-crab-king L30 (+1) | 1:16,4 |  |
| 406 | Cloverbottom > Vineden | side>village | rainforest/grassland | 29+g | 2 | 403+155 (28%) | 73 | 2.3+0.2 | s2 the rain-drum leaf (31%) |  | 1:14,3 | overgrown |
| 407 | Thistleholt > Lianawick | side>village | rainforest/grassland | 29+g | 2 | 373+176 (32%) | 78 | 2.9+0.2 | s2 the stepping-roots (35%) |  | 1:15,5 |  |
| 408 | Hayglen > Mistcrest | side>village | rainforest/grassland | 29+g | 2 | 435+128 (23%) | 83 | 2.5+0.2 | s2 the canopy gap (24%) |  | 1:12,4 |  |
| 409 | Cloverbottom > Driftglen | side>village | coast/grassland | 29+g | 2 | 456+171 (27%) | 65 | 2.3+0.2 | s2 the shell-heap (30%) | M s2@12,14: reef-eel-lord L34 (+5) | 1:12,4 | ferry |
| 410 | Thistleholt > Pebblenook | side>village | coast/grassland | 29+g | 2 | 474+132 (22%) | 65 | 2.0+0.2 | s1 the sea-stack gap (22%) |  | 1:4,14 | tunnel3 |
| 411 | Hayglen > Drum Circle Market | side>haven | grassland/grassland | 29+g | 2 | 421+133 (24%) | 83 | 3.0+0.2 | s1 the sleepy windmill (28%) |  | 1:13,7 | pass3 |
| 412 | Cloverbottom > Mud Mosque Library | side>wonder | wetland/grassland | 8-12 | 3 | 533+275 (34%) | 89 | 2.7+0.5 | s2 the reed causeway (34%) |  | 2:13,6 |  |
| 413 | Thistleholt > Gorilla Glade | side>wonder | rainforest/grassland | 18-22 | 4 | 808+324 (29%) | 113 | 3.6+0.7 | s3 the giant fern glade (33%) | M s4@18,4: fern-cassowary L36 (+18) | 2:18,3 |  |
| 414 | Hayglen > The Canopy Bridges | side>delve | rainforest/grassland | 20-24 | 4 | 822+281 (25%) | 144 | 4.5+0.7 | s4 the mine mouth of The Canopy Bridges (29%) | E s4: miniboss | 2:11,3 |  |
| 415 | Cloverbottom > Hollow of the Silverback Spider | side>lair | rainforest/grassland | 18-22 | 5 (steps 4!) | 1065+399 (27%) | 180 | 5.6+1.0 | s2 the vine bridge (32%) | E s5: boss | 3:12,2 |  |
| 416 | Meadowden > Pinecombe | side>village | mountain/grassland | 32+g | 2 | 302+219 (42%) | 64 | 2.3+0.2 | s1 the pine shelf (45%) |  | 1:14,5 | tunnel3 |
| 417 | Clovergate > Echoford | side>village | mountain/grassland | 32+g | 2 | 349+160 (31%) | 70 | 2.4+0.2 | s2 the rope bridge (32%) | M s2@10,2: thunder-yak L33 (+1) | 1:15,5 | pass3 |
| 418 | Meadowbottom > Bogmead | side>village | wetland/grassland | 32+g | 2 | 299+198 (40%) | 61 | 1.7+0.2 | s2 the lily-pad ford (42%) |  | 1:17,15 | ferry |
| 419 | Summitglen > Newtcombe | side>village | wetland/mountain | 32+g | 2 | 393+141 (26%) | 72 | 2.5+0.2 | s2 the frog choir (29%) |  | 1:14,7 | overgrown |
| 420 | Meadowden > Emberhollow | side>village | desert/grassland | 32+g | 2 | 508+138 (21%) | 70 | 2.0+0.2 | s1 the cactus garden (25%) |  | 1:19,2 |  |
| 421 | Clovergate > Amberburrow | side>village | desert/grassland | 32+g | 2 | 552+128 (19%) | 74 | 2.2+0.2 | s1 the waystone cluster (20%) | M s2@14,16: honey-badger-brute L32 (+0) | 1:14,4 |  |
| 422 | Meadowbottom > Baobab Inn | side>haven | grassland/grassland | 32+g | 2 | 438+144 (25%) | 64 | 2.1+0.2 | s1 the shepherd's wall (28%) |  | 1:15,4 |  |
| 423 | Summitglen > The Great Migration | side>wonder | grassland/mountain | 1-5 | 2 | 503+179 (26%) | 61 | 2.0+0.2 | s2 the hush before The Great Migration (31%) |  | 1:14,2 |  |
| 424 | Meadowden > Coffee Ceremony Hut | side>wonder | mountain/grassland | 8-12 | 3 | 507+245 (33%) | 111 | 3.6+0.5 | s2 the wind notch (38%) |  | 2:16,14 |  |
| 425 | Clovergate > Snowcrown Peak | side>lair | mountain/grassland | 34-38 | 4 (steps 5!) | 676+346 (34%) | 150 | 4.9+0.7 | s4 the threshold of Snowcrown Peak (42%) | E s4: boss | 2:14,6 |  |
| 426 | Meadowbottom > Flamingo Shallows | side>wonder | wetland/grassland | 8-12 | 3 | 512+259 (34%) | 88 | 2.4+0.5 | s2 the stilt-house (37%) | M s2@12,12: mangrove-crab-king L30 (+22) | 2:16,15 | flooded |
| 427 | Summitglen > Fynbos Fire Trails | side>delve | desert/mountain | 20-24 | 4 | 1044+313 (23%) | 124 | 3.8+0.7 | s3 the sun-bleached bones (24%) | E s4: miniboss | 2:9,2 |  |
| 428 | Newtdell > Hollowby | side>village | forest/wetland | 23 | 2 | 419+141 (25%) | 70 | 2.3+0.2 | s2 the acorn scatter (31%) |  | 1:15,8 |  |
| 429 | Rushdell > Cliffmead | side>village | mountain/wetland | 23 | 2 | 363+195 (35%) | 67 | 2.4+0.2 | s2 the waterfall mist (35%) | M s2@14,3: cloud-leopard L28 (+5) | 1:16,7 | tunnel3 |
| 430 | Heronby > Pinecrest | side>village | mountain/wetland | 23 | 2 | 324+205 (39%) | 67 | 2.0+0.2 | s1 the echo wall (41%) |  | 1:14,2 | pass3 |
| 431 | Cloverburrow > Screeden | side>village | mountain/grassland | 23 | 2 | 325+182 (36%) | 64 | 1.8+0.2 | s1 the goat ledge (40%) |  | 1:11,2 |  |
| 432 | Windstead > Floating Flower Market | side>haven | wetland/grassland | 23+g | 2 | 370+142 (28%) | 60 | 1.9+0.2 | s2 the Floating Flower Market path (31%) |  | 1:13,5 |  |
| 433 | Poppythorpe > The Silk Road Caravanserai | side>wonder | grassland/grassland | 8-12 | 3 | 662+217 (25%) | 96 | 2.9+0.5 | s2 the hay-cart ruts (28%) | M s3@28,9: prairie-bison L26 (+18) | 2:18,11 |  |
| 434 | Leafmead > Tea Garden Slopes | side>wonder | forest/forest | 8-12 | 3 | 648+217 (25%) | 87 | 2.5+0.5 | s3 the hush before Tea Garden Slopes (27%) |  | 2:15,8 |  |
| 435 | Newtdell > Temple of the Tiger Moth | side>lair | forest/wetland | 25-29 | 4 (steps 5!) | 809+266 (25%) | 114 | 3.4+0.7 | s3 the fern tunnel (29%) | E s4: boss | 2:17,4 |  |
| 436 | Rushdell > Prayer-flag Pass | side>wonder | mountain/wetland | 18-22 | 4 | 648+337 (34%) | 150 | 5.2+0.7 | s1 the wind notch (37%) |  | 2:15,13 |  |
| 437 | Heronby > Snowleopard Ledges | side>delve | mountain/wetland | 20-24 | 4 | 628+386 (38%) | 95 | 2.7+0.7 | s3 the eagle's rest (41%) | E s4: miniboss | 2:2,11 |  |
| 438 | Honeythorpe > Brambleburrow | side>village | forest/grassland | 20 | 2 | 455+114 (20%) | 49 | 1.7+0.2 | s2 the fern tunnel (22%) | M s2@14,7: jungle-tiger L26 (+6) | 1:17,6 |  |
| 439 | Clovercove > Sprayholt | side>village | coast/grassland | 20 | 2 | 476+152 (24%) | 65 | 2.0+0.2 | s1 the lighthouse shadow (25%) |  | 1:19,2 | flooded |
| 440 | Poppywell > Tidecombe | side>village | coast/grassland | 20 | 2 | 462+149 (24%) | 77 | 2.2+0.2 | s2 the lighthouse shadow (28%) |  | 1:10,2 |  |
| 441 | Bramblebrook > Coppergate | side>village | desert/forest | 20 | 2 | 524+142 (21%) | 79 | 2.6+0.2 | s1 the sun-bleached bones (23%) |  | 1:16,12 | tunnel3 |
| 442 | Birchford > Dunewick | side>village | desert/forest | 20 | 2 | 506+170 (25%) | 75 | 2.2+0.2 | s2 the shade awning (28%) | M s2@14,8: desert-camel L27 (+7) | 1:17,3 | pass3 |
| 443 | Honeythorpe > Cherry Blossom Teahouse | side>haven | grassland/grassland | 20+g | 2 | 444+201 (31%) | 44 | 1.6+0.2 | s1 the daisy ring (38%) |  | 1:25,4 |  |
| 444 | Clovercove > The Thousand Gates | side>wonder | forest/grassland | 8-12 | 3 | 649+198 (23%) | 94 | 3.0+0.5 | s3 the hush before The Thousand Gates (27%) |  | 2:15,3 |  |
| 445 | Poppywell > Panda Bamboo Grove | side>wonder | forest/grassland | 8-12 | 3 | 630+225 (26%) | 121 | 4.4+0.5 | s2 the glow-moss grotto (35%) |  | 2:12,6 |  |
| 446 | Bramblebrook > Pearl Diver Cove | side>wonder | coast/forest | 8-12 | 3 | 682+203 (23%) | 118 | 3.6+0.5 | s3 the hush before Pearl Diver Cove (25%) | M s2@13,11: salt-sea-lion L25 (+17) | 2:16,3 | ferry |
| 447 | Birchford > The Long Wall Walk | side>delve | desert/forest | 20-24 | 4 | 1116+261 (19%) | 142 | 4.6+0.7 | s1 the red rock arch (22%) | E s4: miniboss | 2:15,11 |  |
| 448 | Honeythorpe > Lair of the Jade Dragon-fly | side>lair | desert/grassland | 22-26 | 5 | 1364+407 (23%) | 151 | 4.5+1.0 | s4 the dry riverbed (26%) | E s5: boss | 3:24,2 |  |
| 449 | Marshcrest > Sandpiperhollow | side>village | coast/wetland | 26+g | 2 | 464+131 (22%) | 66 | 2.1+0.2 | s2 the kelp-line (23%) | M s2@13,4: mangrove-crab-king L30 (+4) | 1:15,3 | tunnel3 |
| 450 | Rushglen > Spindriftbottom | side>village | island/wetland | 26+g | 2 | 435+174 (29%) | 68 | 2.2+0.2 | s2 the tide-cave (31%) |  | 1:14,2 |  |
| 451 | Lilyby > Reefden | side>village | island/wetland | 26+g | 2 | 459+153 (25%) | 76 | 2.4+0.2 | s1 the shell-bell tree (28%) |  | 1:16,9 |  |
| 452 | Sandpiperglen > Canopyford | side>village | rainforest/coast | 26+g | 2 | 398+205 (34%) | 74 | 2.5+0.2 | s1 the vine bridge (36%) |  | 1:16,7 | overgrown |
| 453 | Shellnook > Monsoonburrow | side>village | rainforest/coast | 26+g | 2 | 429+158 (27%) | 75 | 2.5+0.2 | s2 the parrot perch (29%) | M s2@15,8: jungle-tiger L26 (+0) | 1:12,10 |  |
| 454 | Marshcrest > Parrotden | side>village | rainforest/wetland | 26+g | 2 | 376+160 (30%) | 65 | 2.1+0.2 | s2 the parrot perch (30%) |  | 1:17,3 |  |
| 455 | Rushglen > Floating Market | side>haven | wetland/wetland | 26+g | 2 | 351+160 (31%) | 75 | 2.7+0.2 | s1 the willow curtain (34%) |  | 1:15,5 |  |
| 456 | Lilyby > Lantern Festival River | side>wonder | coast/wetland | 8-12 | 3 | 694+217 (24%) | 110 | 3.3+0.5 | s3 the Lantern Festival River gates (30%) |  | 2:14,8 | pass3 |
| 457 | Sandpiperglen > Volcano Spice Gardens | side>wonder | island/coast | 8-12 | 3 | 631+248 (28%) | 118 | 3.8+0.5 | s2 the hammock palms (35%) | M s3@13,14: mangrove-crab-king L30 (+22) | 2:18,7 | ferry |
| 458 | Shellnook > Dragonlizard Den | side>lair | island/coast | 28-32 | 4 (steps 5!) | 847+267 (24%) | 159 | 5.2+0.7 | s4 the long approach to Dragonlizard Den (28%) | E s4: boss | 2:18,13 |  |
| 459 | Marshcrest > Root-wrapped Temple | side>wonder | rainforest/wetland | 18-22 | 4 | 779+336 (30%) | 144 | 5.4+0.7 | s3 the vine bridge (35%) |  | 2:15,3 |  |
| 460 | Rushglen > Firefly Caves | side>delve | rainforest/wetland | 20-24 | 4 | 761+296 (28%) | 147 | 5.2+0.7 | s2 the rain-drum leaf (37%) | E s4: miniboss | 2:17,10 |  |
| 461 | Palmgate > Shellknoll | side>village | coast/island | 35+g | 2 | 454+143 (24%) | 74 | 2.4+0.2 | s1 the shell-heap (24%) |  | 1:20,2 |  |
| 462 | Reefknoll > Salthollow | side>village | coast/island | 35+g | 2 | 452+118 (21%) | 46 | 1.5+0.2 | s1 the barnacle wall (25%) |  | 1:10,4 |  |
| 463 | Turtleburrow > Mossby | side>village | forest/island | 35+g | 2 | 437+145 (25%) | 72 | 2.1+0.2 | s2 the lantern branch (29%) | M s2@16,6: fern-cassowary L36 (+1) | 1:11,2 | overgrown |
| 464 | Brineglen > Toadstoolbrook | side>village | forest/coast | 35+g | 2 | 433+123 (22%) | 76 | 2.3+0.2 | s1 the root-tangle crossing (24%) |  | 1:15,8 |  |
| 465 | Palmgate > Miragewell | side>village | desert/island | 35+g | 2 | 544+165 (23%) | 42 | 1.1+0.2 | s1 the shade awning (24%) |  | 1:2,2 | tunnel3 |
| 466 | Reefknoll > Oasiswick | side>village | desert/island | 35+g | 2 | 562+165 (23%) | 43 | 1.3+0.2 | s2 the waystone cluster (27%) |  | 1:2,2 | pass3 |
| 467 | Turtleburrow > Ambercove | side>village | desert/island | 35+g | 2 | 512+143 (22%) | 76 | 2.5+0.2 | s2 the well and its rope (25%) | M s2@18,8: honey-badger-brute L32 (-3) | 1:13,11 |  |
| 468 | Brineglen > Kava Circle | side>haven | island/coast | 35+g | 2 | 441+161 (27%) | 74 | 2.2+0.2 | s1 the lagoon edge (30%) |  | 1:13,8 |  |
| 469 | Palmgate > Starpath Canoe | side>wonder | island/island | 1-5 | 2 | 470+146 (24%) | 64 | 1.8+0.2 | s2 the hush before Starpath Canoe (27%) |  | 1:13,8 |  |
| 470 | Reefknoll > Glowworm Grotto | side>wonder | coast/island | 8-12 | 3 | 728+224 (24%) | 89 | 2.7+0.5 | s1 the rope-and-net rack (25%) |  | 2:16,11 |  |
| 471 | Turtleburrow > Reef of the Box Jelly Queen | side>lair | coast/island | 35-39 | 4 (steps 5!) | 985+274 (22%) | 142 | 4.4+0.7 | s4 the threshold of Reef of the Box Jelly (23%) | E s4: boss | 2:17,7 |  |
| 472 | Brineglen > Stone Head Watchers | side>wonder | forest/coast | 8-12 | 3 | 629+212 (25%) | 111 | 3.7+0.5 | s3 the hush before Stone Head Watchers (29%) | M s3@15,9: fern-cassowary L36 (+28) | 2:12,5 |  |
| 473 | Palmgate > The Red Rock Songlines | side>delve | desert/island | 20-24 | 4 | 1070+335 (24%) | 110 | 3.3+0.7 | s1 the mirage pool (26%) | E s4: miniboss | 2:22,3 |  |

## 4. Variants

### 4.1 Gap list (what variants should fill)

| # | gap | where it bites | wanted |
|---|---|---|---|
| G1 | no S above L5 | every land, L8-40 | 1-2 swarm / flock / brood variants per land per 10 levels |
| G2 | no M at L13-26 (grassland), L12-36 (forest), L17-40 (wetland), L14-26 (coast), L13-26 (island), L16-34 (desert), L19-40 (mountain), L18-26 (rainforest) | EE, MENA, EA, CSA roads; all landmark routes L18-24 | 2-3 M per land in these bands |
| G3 | late game thin: grassland L36+ (2 -> 1), forest L29+ (4 -> 1; none at 33), wetland L31+ (2 -> 0), coast L34+ (2), desert L38+ (2 -> 1), mountain L32+ (2 -> 0), rainforest L32+ (2 -> 1) | WCA, ESA, OC and every near-home walk of a L30+ gnome | 4-6 per land at L30-40, mixed sizes |
| G4 | island L12-31 (3, then 2 at L23-31) | SEA island L26 (450, 451), OC 253 L23, 301 L30, 469, 457 | 4-5 island creatures L20-30 |
| G5 | tundra L1-3 (2), L12-14 (1-2) | NA 309 / 310 / 316; lair routes 315, 363; NWE explore steps 7-8 (L13, L15) | 3 S at L1-3; 4-5 at L8-16 |
| G6 | tundra L17+ has no host | arctic-fox, ptarmigan (tundra side), wolverine (tundra side), glacier-bear, lichen-reindeer, snow-owl-monarch | low-level tundra variants of these (below), or a tundra zone in a L15+ region (design change) |
| G7 | desert L17-22 (3, 2 at L21) | MENA desert 394-396, EA 441 / 442, 5 desert delves (2-3 per stage) | 3-4 desert S / M at L17-23 |
| G8 | mountain L1-8 (3-5, two are `any`), coast / island L1-5 (3-5) | CA 321 / 322, lair 327; NA coast 307 / 308 | 1-2 land-specific S / M each |
| G9 | wetland L9-13 (4) | CSA / EE approach, 388, 412, 426 | 2-3 |
| G10 | cond coverage | 23 of 88 have a cond. Unused: `dp=day`, `we=wind`, `we=cloud`, `se=spring/summer/autumn`. Island has no cond creature; coast only snail (rain) and rat (night); desert has no dawn / wind; mountain no wind / storm / fog; tundra no summer / night | give variants the missing conds (variants are the natural cond carriers) |
| G11 | do not add | grassland / forest L3-10 (9-12 already), forest L at L19-26 (9-10 larges) | - |
| G12 | no region input | a land's creatures appear in every region with that land (savanna-hyena on Maplewold roads for a L29 gnome near home; tundra L1 = aphids) | variants can only be told apart by land / level / cond unless a `regions` column is added |

### 4.2 Size of the problem

2-3 variants for each of 88 creatures = about 218 new rows. With today's rules (no region filter, 9-level window) that takes mid and late pools from 3-9 to 12-22. Pools of 5-9 need about 55 well-placed rows. So: tier A (55) can ship with the current picker; tier B (163) should wait for a region filter, or be made mutually exclusive by hard conds (`!dp=night`, `!se=winter`) or single-land lists.

Pool size (S/M/L) at sample levels:

Now:

| land | L1 | L4 | L6 | L8 | L10 | L12 | L14 | L17 | L20 | L23 | L26 | L29 | L32 | L35 | L38 | L40 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| grassland | 5 (5/0/0) | 8 (6/2/0) | 10 (6/4/0) | 10 (4/6/0) | 8 (1/7/0) | 7 (0/6/1) | 7 (0/5/2) | 4 (0/1/3) | 4 (0/0/4) | 3 (0/0/3) | 3 (0/0/3) | 3 (0/1/2) | 3 (0/1/2) | 3 (0/2/1) | 2 (0/1/1) | 1 (0/1/0) |
| forest | 5 (5/0/0) | 8 (6/2/0) | 9 (6/3/0) | 9 (4/5/0) | 7 (1/6/0) | 5 (0/5/0) | 6 (0/4/2) | 5 (0/1/4) | 8 (0/0/8) | 9 (0/0/9) | 8 (0/0/8) | 4 (0/0/4) | 1 (0/0/1) | 1 (0/0/1) | 1 (0/0/1) | 1 (0/0/1) |
| wetland | 5 (5/0/0) | 8 (6/2/0) | 9 (6/3/0) | 7 (4/3/0) | 4 (1/3/0) | 4 (0/3/1) | 5 (0/2/3) | 6 (0/2/4) | 7 (0/1/6) | 5 (0/0/5) | 4 (0/0/4) | 3 (0/0/3) | 1 (0/0/1) | 1 (0/0/1) | 0 (0/0/0) | 0 (0/0/0) |
| coast | 4 (4/0/0) | 5 (4/1/0) | 7 (4/3/0) | 6 (2/4/0) | 5 (0/5/0) | 5 (0/5/0) | 5 (0/4/1) | 4 (0/2/2) | 3 (0/0/3) | 4 (0/0/4) | 4 (0/1/3) | 4 (0/1/3) | 3 (0/1/2) | 3 (0/0/3) | 2 (0/0/2) | 2 (0/0/2) |
| island | 3 (3/0/0) | 4 (3/1/0) | 5 (3/2/0) | 5 (2/3/0) | 4 (0/4/0) | 3 (0/3/0) | 3 (0/2/1) | 3 (0/1/2) | 3 (0/0/3) | 2 (0/0/2) | 2 (0/1/1) | 2 (0/1/1) | 3 (0/1/2) | 4 (0/0/4) | 3 (0/0/3) | 3 (0/0/3) |
| desert | 4 (4/0/0) | 6 (4/2/0) | 7 (4/3/0) | 7 (3/4/0) | 5 (0/5/0) | 5 (0/4/1) | 5 (0/4/1) | 3 (0/2/1) | 3 (0/1/2) | 3 (0/0/3) | 4 (0/0/4) | 4 (0/0/4) | 3 (0/0/3) | 3 (0/1/2) | 2 (0/1/1) | 1 (0/1/0) |
| mountain | 3 (3/0/0) | 5 (4/1/0) | 5 (4/1/0) | 5 (3/2/0) | 6 (1/5/0) | 4 (0/4/0) | 5 (0/4/1) | 6 (0/4/2) | 6 (0/1/5) | 8 (0/1/7) | 7 (0/0/7) | 4 (0/0/4) | 2 (0/0/2) | 1 (0/0/1) | 1 (0/0/1) | 0 (0/0/0) |
| tundra | 2 (2/0/0) | 4 (2/2/0) | 4 (2/2/0) | 3 (1/2/0) | 3 (0/3/0) | 2 (0/2/0) | 2 (0/1/1) | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a |
| rainforest | 4 (4/0/0) | 6 (5/1/0) | 8 (5/3/0) | 7 (4/3/0) | 5 (1/4/0) | 4 (0/3/1) | 5 (0/3/2) | 5 (0/3/2) | 6 (0/2/4) | 4 (0/1/3) | 5 (0/1/4) | 3 (0/1/2) | 2 (0/1/1) | 1 (0/0/1) | 1 (0/0/1) | 1 (0/0/1) |

With tier A variants (55):

| land | L1 | L4 | L6 | L8 | L10 | L12 | L14 | L17 | L20 | L23 | L26 | L29 | L32 | L35 | L38 | L40 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| grassland | 5 (5/0/0) | 8 (6/2/0) | 10 (6/4/0) | 10 (4/6/0) | 9 (2/7/0) | 9 (2/6/1) | 9 (2/5/2) | 8 (3/2/3) | 7 (2/1/4) | 7 (1/3/3) | 6 (0/3/3) | 7 (1/4/2) | 6 (1/2/3) | 8 (2/3/3) | 7 (1/2/4) | 6 (1/2/3) |
| forest | 5 (5/0/0) | 8 (6/2/0) | 9 (6/3/0) | 9 (4/5/0) | 7 (1/6/0) | 6 (1/5/0) | 7 (1/4/2) | 6 (1/1/4) | 9 (1/0/8) | 9 (0/0/9) | 9 (0/1/8) | 6 (0/2/4) | 6 (1/3/2) | 6 (1/2/3) | 7 (1/1/5) | 5 (0/1/4) |
| wetland | 5 (5/0/0) | 8 (6/2/0) | 9 (6/3/0) | 7 (4/3/0) | 6 (3/3/0) | 6 (2/3/1) | 7 (2/2/3) | 9 (3/2/4) | 8 (1/1/6) | 7 (1/1/5) | 6 (1/1/4) | 6 (1/2/3) | 6 (2/2/2) | 7 (1/2/4) | 6 (1/1/4) | 5 (0/1/4) |
| coast | 4 (4/0/0) | 6 (5/1/0) | 8 (5/3/0) | 8 (4/4/0) | 7 (2/5/0) | 8 (2/6/0) | 8 (2/5/1) | 8 (2/4/2) | 7 (2/2/3) | 7 (1/2/4) | 6 (1/2/3) | 7 (2/2/3) | 7 (3/2/2) | 9 (3/1/5) | 7 (2/1/4) | 6 (1/1/4) |
| island | 3 (3/0/0) | 5 (4/1/0) | 6 (4/2/0) | 7 (4/3/0) | 6 (2/4/0) | 6 (2/4/0) | 6 (2/3/1) | 6 (1/3/2) | 6 (1/2/3) | 6 (1/3/2) | 6 (1/4/1) | 8 (2/5/1) | 6 (1/3/2) | 8 (2/1/5) | 6 (1/0/5) | 6 (1/0/5) |
| desert | 4 (4/0/0) | 6 (4/2/0) | 7 (4/3/0) | 8 (4/4/0) | 6 (1/5/0) | 7 (2/4/1) | 7 (2/4/1) | 6 (2/3/1) | 7 (3/2/2) | 7 (2/2/3) | 6 (1/1/4) | 6 (0/2/4) | 6 (0/2/4) | 7 (1/3/3) | 7 (1/3/3) | 5 (1/2/2) |
| mountain | 3 (3/0/0) | 5 (4/1/0) | 5 (4/1/0) | 7 (4/3/0) | 9 (3/6/0) | 7 (2/5/0) | 8 (2/5/1) | 7 (1/4/2) | 6 (0/1/5) | 8 (0/1/7) | 7 (0/0/7) | 6 (1/1/4) | 6 (1/2/3) | 7 (1/2/4) | 7 (0/2/5) | 4 (0/1/3) |
| tundra | 4 (4/0/0) | 6 (4/2/0) | 6 (4/2/0) | 7 (3/4/0) | 7 (1/5/1) | 6 (1/4/1) | 6 (1/3/2) | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a |
| rainforest | 4 (4/0/0) | 6 (5/1/0) | 8 (5/3/0) | 8 (5/3/0) | 6 (2/4/0) | 5 (1/3/1) | 6 (1/3/2) | 6 (1/3/2) | 7 (1/2/4) | 6 (1/2/3) | 7 (0/3/4) | 6 (0/4/2) | 7 (1/4/2) | 6 (1/3/2) | 6 (1/2/3) | 5 (0/2/3) |

With all 218:

| land | L1 | L4 | L6 | L8 | L10 | L12 | L14 | L17 | L20 | L23 | L26 | L29 | L32 | L35 | L38 | L40 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| grassland | 5 (5/0/0) | 8 (6/2/0) | 10 (6/4/0) | 11 (5/6/0) | 10 (3/7/0) | 11 (3/7/1) | 14 (5/7/2) | 16 (7/6/3) | 21 (7/10/4) | 21 (4/14/3) | 20 (2/14/4) | 18 (2/13/3) | 19 (3/11/5) | 20 (4/10/6) | 18 (3/7/8) | 14 (2/6/6) |
| forest | 5 (5/0/0) | 8 (6/2/0) | 9 (6/3/0) | 9 (4/5/0) | 7 (1/6/0) | 7 (1/6/0) | 10 (2/6/2) | 13 (3/6/4) | 21 (4/9/8) | 21 (3/9/9) | 22 (4/10/8) | 16 (3/9/4) | 18 (3/11/4) | 14 (1/7/6) | 15 (1/5/9) | 9 (0/2/7) |
| wetland | 5 (5/0/0) | 8 (6/2/0) | 9 (6/3/0) | 10 (5/5/0) | 11 (4/7/0) | 12 (3/8/1) | 16 (6/7/3) | 19 (6/9/4) | 20 (5/9/6) | 15 (2/8/5) | 14 (2/7/5) | 15 (2/6/7) | 19 (3/8/8) | 17 (2/5/10) | 11 (1/3/7) | 6 (0/1/5) |
| coast | 4 (4/0/0) | 6 (5/1/0) | 9 (6/3/0) | 11 (7/4/0) | 11 (5/6/0) | 12 (5/7/0) | 13 (5/7/1) | 15 (4/9/2) | 16 (5/8/3) | 16 (3/8/5) | 15 (2/8/5) | 16 (2/6/8) | 19 (3/7/9) | 17 (3/3/11) | 15 (2/3/10) | 9 (1/1/7) |
| island | 3 (3/0/0) | 5 (4/1/0) | 7 (5/2/0) | 10 (7/3/0) | 9 (5/4/0) | 9 (5/4/0) | 9 (4/4/1) | 8 (1/5/2) | 10 (1/5/4) | 11 (1/6/4) | 15 (1/9/5) | 18 (2/10/6) | 16 (1/7/8) | 13 (2/2/9) | 8 (1/0/7) | 6 (1/0/5) |
| desert | 4 (4/0/0) | 6 (4/2/0) | 8 (5/3/0) | 10 (6/4/0) | 8 (3/5/0) | 10 (4/5/1) | 11 (4/6/1) | 13 (4/8/1) | 19 (5/11/3) | 19 (3/12/4) | 16 (1/10/5) | 13 (0/9/4) | 12 (0/8/4) | 16 (2/8/6) | 15 (2/6/7) | 12 (2/4/6) |
| mountain | 3 (3/0/0) | 7 (5/2/0) | 11 (7/4/0) | 14 (8/6/0) | 16 (7/9/0) | 16 (6/9/1) | 19 (5/12/2) | 16 (3/10/3) | 17 (2/10/5) | 16 (1/7/8) | 16 (0/8/8) | 14 (1/7/6) | 14 (1/8/5) | 17 (1/6/10) | 15 (0/4/11) | 12 (0/3/9) |
| tundra | 5 (5/0/0) | 9 (5/4/0) | 10 (6/4/0) | 12 (6/6/0) | 12 (3/8/1) | 10 (3/6/1) | 11 (3/5/3) | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a |
| rainforest | 4 (4/0/0) | 6 (5/1/0) | 8 (5/3/0) | 9 (5/4/0) | 8 (2/6/0) | 8 (2/5/1) | 9 (2/5/2) | 10 (2/6/2) | 12 (1/7/4) | 14 (2/9/3) | 17 (2/11/4) | 19 (3/13/3) | 21 (3/13/5) | 18 (2/10/6) | 12 (1/5/6) | 7 (0/3/4) |

Tier A was chosen greedily: repeatedly take the variant that lifts the most (land, level) slots below 6 and adds a missing size, never pushing a slot past 9, spreading over base creatures. After tier A: slots under 5 go from 202 to 13 (of 336); 6 slots exceed 9 (max 12, low-level mountain / tundra overlap).

### 4.3 Variant table (A = fills a measured gap with the current picker; B = variety, needs region filter or hard cond)

Format: tier · name · size · landscapes · level · cond. Bosses' variants are ordinary creatures unless marked B(oss).

| base (size, Lv, lands) | variants: tier · name · size · lands · Lv · cond |
|---|---|
| aphid-swarm (S1; any) | A · **Fly Swarm** · S · grassland,wetland · L12 · we=heat,sun<br>B · **Mite Swarm** · S · forest,mountain · L15 · -<br>B · **Snow Flea Swarm** · S · tundra · L2 · we=snow,frost |
| garden-snail (S1; forest,grassland,wetland,coast) | A · **Dune Snail** · S · desert,coast · L9 · dp=dawn<br>B · **Ramshorn Pond Snail** · S · wetland · L10 · we=rain<br>B · **Giant Banded Snail** · M · rainforest,island · L20 · we=rain,fog |
| ant-scouts (S2; any) | A · **Fire Ant Raiders** · S · desert,grassland · L18 · we=heat,sun<br>B · **Carpenter Ant Gang** · S · forest · L28 · -<br>B · **Army Ant Column** · M · rainforest · L31 · - |
| gnat-cloud (S2; wetland,rainforest) | A · **Midge Cloud** · S · wetland,mountain · L11 · se=summer<br>A · **Sandfly Cloud** · S · coast,island · L14 · dp=dawn,dusk<br>B · **Mosquito Storm** · S · rainforest,wetland · L31 · we=rain,storm |
| leopard-slug (S2; forest,wetland,rainforest) | B · **Banana Slug** · S · rainforest · L13 · we=rain,fog<br>A · **Sea Slug Drift** · S · island,coast · L5 · we=fog,rain<br>B · **Ghost Slug** · M · forest,mountain · L19 · dp=night |
| sand-fleas (S3; coast,island,desert) | B · **Kelp Fly Swarm** · S · coast · L21 · we=sun,heat<br>A · **Beach Hopper Horde** · S · island · L25 · dp=dusk,night<br>A · **Salt Mite Swarm** · S · desert · L22 · we=wind |
| dusk-moth (S3; forest,grassland,mountain) | B · **Dawn Skipper Flutter** · S · grassland,mountain · L17 · dp=dawn<br>A · **Snow Moth** · S · tundra,mountain · L9 · we=snow,frost<br>B · **Luna Moth** · M · forest,rainforest · L30 · dp=night |
| dung-beetle (S3; grassland,desert) | B · **Scarab Roller** · M · desert · L18 · dp=dawn,day<br>B · **Carrion Beetle Crew** · S · grassland,forest · L21 · se=autumn<br>B · **Tumblebug Troupe** · S · grassland · L33 · we=wind |
| earwig (S4; forest,grassland,wetland) | B · **Rock Earwig** · S · mountain · L6 · -<br>B · **Shore Earwig** · S · coast,island · L9 · dp=night<br>B · **Earwig Matron** · M · wetland,forest · L28 · - |
| cave-glowworm (S5; mountain,rainforest) | B · **Firefly Flicker** · S · grassland,wetland · L15 · dp=dusk,night/se=summer<br>B · **Glow Grub Cluster** · S · rainforest,forest · L24 · dp=night<br>B · **Lantern Glowworm Queen** · M · mountain · L34 · dp=night |
| orb-spider (M5; any) | B · **Jumping Spider** · S · mountain,desert · L7 · dp=day<br>B · **Fishing Spider** · M · wetland,coast · L11 · -<br>A · **Golden Orb Weaver** · M · rainforest,island · L23 · - |
| paper-wasp (M6; grassland,forest,desert) | B · **Mud Dauber** · M · desert,mountain · L14 · we=sun,heat<br>B · **Hornet Sentry** · M · forest,grassland · L24 · se=summer,autumn<br>A · **Yellowjacket Mob** · S · grassland,mountain · L30 · se=autumn |
| bog-leech (M6; wetland) | B · **Tiger Leech** · M · rainforest · L10 · we=rain<br>B · **Saltmarsh Leech** · M · coast,wetland · L18 · we=fog,rain<br>B · **Giant Mire Leech** · M · wetland · L33 · we=rain |
| grumpy-lemming (M6; tundra) | A · **Lemming Kit Scurry** · S · tundra · L1 · -<br>B · **Pika Sentry** · M · mountain · L8 · -<br>B · **Marmot Bruiser** · M · mountain,grassland · L22 · se=summer |
| bullfrog (M7; wetland,rainforest) | A · **Tree Frog Chorus** · S · rainforest,island · L9 · we=rain<br>B · **Cane Toad** · M · grassland,wetland · L19 · dp=night<br>A · **Goliath Frog** · L · wetland,rainforest · L34 · we=rain,storm |
| shore-crab (M7; coast,island) | B · **Fiddler Crab Band** · S · wetland,coast · L16 · dp=dawn,dusk<br>B · **Ghost Crab** · M · coast,island · L17 · dp=night<br>B · **Land Crab March** · M · island,rainforest · L24 · we=rain |
| barn-rat (M8; grassland,forest,coast) | B · **Pack Rat** · M · desert,mountain · L16 · dp=night<br>B · **Marsh Rat** · M · wetland · L21 · -<br>B · **Ship Rat Crew** · M · coast,island · L28 · dp=night |
| sun-lizard (M8; desert,grassland,rainforest) | B · **Rock Agama** · M · mountain · L5 · we=sun,heat<br>B · **Basilisk Runner** · M · rainforest,wetland · L21 · -<br>B · **Frilled Lizard** · M · desert,forest · L33 · we=heat,sun |
| tunnel-mole (M9; grassland,forest) | B · **Star-nosed Mole** · M · wetland · L12 · -<br>B · **Golden Mole** · M · desert · L26 · dp=night<br>B · **Mole-rat Gang** · M · grassland · L31 · - |
| carrion-crow (M9; grassland,forest,mountain) | B · **Magpie Mob** · M · grassland · L17 · dp=dawn,day<br>B · **Raven Pair** · M · mountain · L13 · we=wind<br>B · **Jungle Crow** · M · rainforest,coast · L32 · - |
| herring-gull (M10; coast,island) | A · **Tern Squadron** · M · coast,island · L18 · we=wind<br>B · **Skua Raider** · M · coast,tundra · L20 · se=summer<br>B · **Frigatebird** · L · island,coast · L29 · we=storm,wind |
| dune-scorpion (M10; desert) | B · **Bark Scorpion** · M · rainforest · L19 · dp=night<br>B · **Whip Scorpion** · M · desert · L22 · dp=night<br>B · **Emperor Scorpion** · L · desert,rainforest · L37 · dp=dusk,night |
| frost-hare (M11; tundra,mountain) | A · **Snowshoe Leveret Dash** · S · tundra · L3 · we=snow,frost<br>B · **Mountain Hare** · M · mountain,grassland · L20 · se=spring<br>B · **Jackrabbit** · M · desert,grassland · L25 · dp=dawn,dusk |
| giant-centipede (M11; rainforest,forest) | B · **House Centipede Skitter** · S · mountain,desert · L10 · dp=night<br>B · **Cave Centipede** · M · mountain · L30 · dp=night<br>A · **Giant Millipede** · M · rainforest,forest · L34 · we=rain |
| thistle-beast (M12; grassland,mountain) | B · **Nettle Lurker** · M · forest,wetland · L14 · se=spring,summer<br>B · **Cactus Beast** · M · desert · L19 · we=heat,sun<br>A · **Gorse Beast** · L · grassland,forest · L38 · se=autumn |
| ember-beetle (M12; desert,mountain) | B · **Frost Beetle** · M · tundra · L12 · we=snow,frost<br>A · **Bombardier Beetle** · M · grassland,forest · L27 · -<br>A · **Lava Beetle** · M · mountain,desert · L38 · we=heat |
| will-o-wisp (M13; wetland) | B · **Marsh Spark Swarm** · S · wetland · L22 · dp=night<br>A · **Storm Wisp** · M · coast,island · L24 · we=storm<br>B · **Foxfire Wisp** · M · forest · L32 · dp=night |
| grass-snake (L14; grassland,wetland,rainforest,desert) | B · **Smooth Snake** · M · grassland · L22 · we=sun<br>B · **Water Snake** · M · wetland,coast · L26 · -<br>A · **Tree Snake** · M · rainforest,island · L28 · - |
| grey-heron (L15; wetland,coast) | B · **Night Heron** · M · wetland,coast · L22 · dp=night,dusk<br>A · **Egret Flock** · M · grassland,wetland · L25 · se=spring,summer<br>A · **Goliath Heron** · L · wetland · L35 · - |
| mischief-monkey (L15; rainforest) | B · **Capuchin Pickpocket** · M · rainforest · L12 · dp=day<br>B · **Macaque Troop** · M · forest,mountain · L20 · -<br>B · **Mandrill Boss** · L · rainforest,grassland · L32 · - |
| red-fox (L16; forest,grassland,mountain,tundra) | A · **Fox Kit Pair** · M · tundra,mountain · L10 · se=spring<br>B · **Fennec** · M · desert · L17 · dp=night<br>B · **Silver Fox** · L · mountain · L34 · se=winter |
| raccoon (L16; forest,wetland) | B · **Coati Band** · M · rainforest · L19 · dp=day<br>B · **Tanuki** · M · forest,grassland · L21 · dp=night,dusk<br>B · **Crab-eating Raccoon** · L · coast,wetland · L32 · dp=night |
| tawny-owl (L17; forest,mountain) | B · **Snowy Owl Scout** · M · tundra · L14 · dp=night<br>B · **Burrowing Owl** · M · grassland,desert · L20 · dp=dawn,dusk<br>A · **Eagle Owl** · L · mountain,forest · L35 · dp=night |
| arctic-fox (L17; tundra) | B · **Arctic Fox Kit** · M · tundra · L5 · se=summer<br>B · **Tundra Fox (summer coat)** · L · tundra,mountain · L24 · se=summer |
| badger (L18; forest,grassland) | B · **Badger Cub Gang** · M · grassland · L13 · dp=dusk,night<br>B · **Stink Badger** · M · rainforest,island · L26 · dp=night<br>B · **Old Brock** · L · forest,grassland · L38 · - |
| mire-toad (L18; wetland) | A · **Natterjack Chorus** · S · wetland,coast · L17 · dp=dusk,night<br>B · **Desert Spadefoot** · M · desert · L21 · we=rain,storm<br>B · **Elder Mire Toad** · L · wetland · L36 · we=rain,fog |
| tide-crab-knight (L19; coast,island) | A · **Tide Crab Squire** · M · coast,island · L14 · -<br>B · **Mud Crab Brawler** · M · wetland,coast · L28 · -<br>B · **Tide Crab Paladin** · L · island,coast · L30 · we=storm |
| moss-golem (L20; forest,rainforest,mountain) | B · **Lichen Golem** · L · mountain · L13 · -<br>B · **Coral Golem** · L · coast,island · L26 · -<br>B · **Peat Golem** · L · wetland · L31 · we=fog |
| bramble-wolf (L22; forest) | B · **Bramble Pup Pack** · M · forest · L18 · -<br>A · **Thorn Jackal** · M · grassland,desert · L23 · dp=dusk,night<br>B · **Elder Bramble Wolf** · L · forest · L34 · se=autumn |
| coconut-crab-titan (B26; island) | B · **Coconut Crab Youngster** · L · island · L22 · dp=night<br>B · **Robber Crab Baron** · B · coast,island · L36 · - |
| great-hawk (B28; grassland) | B · **Kestrel Hoverer** · M · grassland,mountain · L15 · we=wind<br>B · **Marsh Harrier** · L · wetland,grassland · L27 · dp=dawn,dusk |
| ancient-snapper (B28; wetland) | B · **Snapper Hatchling Bask** · M · wetland · L9 · we=sun<br>B · **Alligator Snapper** · L · wetland,coast · L29 · - |
| reef-leviathan (B29; coast) | B · **Moray Lurker** · L · coast,island · L24 · dp=night<br>B · **Conger Brute** · L · coast · L38 · we=storm |
| old-bramblehorn (B30; forest) | B · **Roebuck** · M · forest,mountain · L15 · se=autumn<br>A · **Red Stag** · L · forest,mountain · L32 · se=autumn |
| dune-wyrm (B30; desert) | A · **Sandfish Skink Shoal** · S · desert · L14 · we=heat,sun<br>B · **Dune Wyrmling** · L · desert · L22 · - |
| snow-owl-monarch (B30; tundra) | B · **Frost Owl Regent** · B · tundra · L14 · se=winter<br>B · **Snow Owl Fledgling** · M · tundra,mountain · L27 · dp=night |
| storm-eagle (B32; mountain) | B · **Mountain Buzzard** · M · mountain,grassland · L26 · we=wind<br>B · **Lammergeier** · L · mountain · L36 · - |
| jade-jaguar (B32; rainforest) | B · **Ocelot** · M · rainforest,forest · L23 · dp=night,dusk<br>A · **Jaguarundi** · M · rainforest,grassland · L35 · - |
| delta-gharial (L24; wetland) | A · **Croc Hatchling Scatter** · S · wetland,coast · L27 · -<br>A · **Saltwater Gharial** · L · coast,wetland · L36 · - |
| emerald-python (L25; rainforest,wetland) | B · **Vine Snake** · M · rainforest,forest · L30 · -<br>A · **Rock Python** · L · grassland,mountain · L36 · we=sun,heat |
| jungle-tiger (L26; forest,rainforest) | A · **Fishing Cat** · M · wetland,rainforest · L29 · dp=night<br>A · **Elder Tiger** · L · forest,rainforest · L38 · - |
| spice-monitor (M27; rainforest,island,coast) | A · **Tree Monitor** · M · forest,island · L31 · -<br>B · **Water Monitor** · M · wetland,coast · L33 · - |
| cloud-leopard (L28; mountain) | B · **Snow Leopard Cub** · M · mountain,tundra · L23 · we=snow,frost<br>B · **Ghost Leopard** · L · mountain · L37 · dp=night |
| savanna-hyena (M29; grassland) | B · **Hyena Pup Cackle** · S · grassland · L26 · dp=night<br>A · **Striped Hyena** · M · desert,mountain · L33 · dp=night |
| mangrove-crab-king (L30; coast,island,wetland) | A · **Mangrove Crab Court** · S · wetland,coast · L32 · -<br>A · **Mangrove Crab Emperor** · L · wetland,island · L38 · we=storm |
| sand-viper-matriarch (L31; desert) | B · **Horned Viper** · M · desert · L29 · dp=dusk,night<br>B · **Rock Viper** · M · mountain · L36 · we=sun |
| honey-badger-brute (L32; grassland,desert) | A · **Zorilla Stink Squad** · S · grassland,desert · L35 · dp=night<br>B · **Ratel Pair** · M · grassland · L38 · - |
| thunder-yak (L33; mountain) | B · **Yak Calf Herd** · M · mountain,grassland · L31 · -<br>B · **Musk Ox** · L · mountain,tundra · L39 · se=winter |
| reef-eel-lord (L34; coast,island) | A · **Garden Eel Colony** · S · coast,island · L30 · -<br>B · **Reef Eel Tyrant** · L · coast · L39 · - |
| outback-dingo (M35; desert,grassland) | B · **Dingo Pup Pack** · S · desert,grassland · L37 · dp=dawn,dusk<br>B · **Alpha Dingo** · L · desert · L39 · - |
| fern-cassowary (L36; forest,rainforest,island) | A · **Cassowary Chick Creche** · S · forest,rainforest · L33 · -<br>B · **Emu Mob** · M · grassland,forest · L38 · - |
| deep-octopus (L37; island,coast) | A · **Blue-ring Octopus** · S · coast,island · L36 · -<br>B · **Kraken Spawn** · L · coast · L40 · we=storm |
| hermit-crab-hoarder (M12; island,coast) | B · **Hermit Crab Convoy** · S · island,coast · L7 · -<br>B · **Coconut Hermit** · M · island,rainforest · L27 · dp=night |
| sea-otter-bandit (M13; coast) | B · **River Otter** · M · wetland,forest · L17 · -<br>B · **Giant Otter Gang** · L · wetland,rainforest · L30 · - |
| dust-sidewinder (M15; desert) | B · **Dune Racer** · M · desert,coast · L24 · we=heat,sun<br>B · **Night Adder** · M · grassland,desert · L34 · dp=night |
| poison-dart-frog (M16; rainforest,wetland) | A · **Glass Frog** · S · rainforest · L18 · dp=night<br>B · **Golden Mantella** · M · rainforest,island · L29 · we=rain |
| reef-turtle (L16; island) | B · **Turtle Hatchling Dash** · S · island,coast · L10 · dp=night<br>B · **Leatherback** · L · island,coast · L32 · - |
| leafcutter-column (M17; rainforest) | A · **Termite Column** · M · grassland,desert · L19 · -<br>B · **Weaver Ant Nest** · S · rainforest,forest · L26 · - |
| ptarmigan-flock (M18; tundra,mountain) | B · **Snow Bunting Flurry** · S · tundra,mountain · L8 · se=winter<br>A · **Rock Partridge Covey** · M · mountain,desert · L29 · - |
| bog-pike (L20; wetland) | B · **Stickleback Shoal** · S · wetland · L16 · se=spring<br>A · **Garfish** · M · coast,wetland · L34 · - |
| desert-gila-dragon (L20; desert) | B · **Thorny Devil** · S · desert · L19 · we=heat,sun<br>B · **Beaded Lizard** · M · desert,rainforest · L35 · - |
| cliff-ram (L21; mountain) | B · **Goat Kid Gang** · M · mountain · L8 · -<br>A · **Ibex Patriarch** · L · mountain,desert · L38 · - |
| wolverine (L21; tundra,mountain) | B · **Stoat** · S · tundra,grassland · L10 · se=winter<br>B · **Fisher** · M · forest,mountain · L28 · - |
| wild-boar (L21; forest,grassland) | A · **Piglet Squeal** · S · forest,grassland · L14 · se=spring<br>B · **Warthog** · M · grassland · L34 · -<br>B · **Bearded Pig** · L · rainforest,wetland · L33 · - |
| pelican-parliament (L21; coast,island) | B · **Cormorant Line** · M · coast,wetland · L19 · dp=dawn<br>B · **Albatross** · L · island,coast · L33 · we=wind,storm |
| beaver-foreman (L22; wetland,forest) | B · **Muskrat Crew** · M · wetland · L10 · -<br>B · **Capybara Herd** · M · wetland,grassland · L30 · - |
| giant-anteater (L22; rainforest) | B · **Tamandua** · M · rainforest,forest · L22 · dp=night<br>B · **Pangolin** · M · grassland,forest · L32 · dp=night<br>B · **Aardvark** · L · grassland,desert · L36 · dp=night |
| giant-bumblebee (L23; grassland,forest) | B · **Honeybee Swarm** · S · grassland,forest · L17 · se=spring,summer<br>B · **Carpenter Bee** · M · rainforest,desert · L28 · we=sun,heat |
| tufted-lynx (L23; forest,mountain) | B · **Wildcat** · M · forest,grassland · L26 · dp=dusk,night<br>B · **Caracal** · M · desert,grassland · L31 · dp=dusk<br>B · **Snow Lynx** · L · mountain,tundra · L30 · se=winter |
| clam-lurker (L23; coast) | B · **Cockle Bed** · S · coast · L19 · dp=dawn<br>B · **Giant Clam** · L · island · L28 · - |
| desert-tortoise (L24; desert) | B · **Tortoise Hatchling Trundle** · S · desert,grassland · L16 · -<br>A · **Spurred Tortoise** · L · grassland,desert · L34 · - |
| griffon-vulture (L24; mountain,desert) | B · **Turkey Vulture** · M · grassland,desert · L21 · dp=day<br>B · **Condor** · L · mountain · L35 · we=wind |
| black-bear (L25; forest,mountain) | B · **Bear Cub Tumble** · M · forest,mountain · L20 · se=spring<br>B · **Sun Bear** · M · rainforest · L33 · -<br>B · **Sloth Bear** · L · forest,grassland · L35 · dp=night |
| salt-sea-lion (L25; coast) | B · **Seal Pup Raft** · M · coast,island · L15 · -<br>A · **Elephant Seal Bull** · L · coast,island · L36 · - |
| glacier-bear (L26; tundra) | A · **Glacier Cub** · M · tundra · L9 · we=snow,frost<br>B · **Ice Bear** · L · tundra · L16 · se=winter |
| prairie-bison (L26; grassland) | B · **Bison Calf Stampede** · M · grassland · L25 · -<br>B · **Wood Bison** · L · forest,tundra · L32 · se=winter |
| desert-camel (L27; desert) | B · **Camel Calf** · M · desert · L23 · -<br>B · **Wild Bactrian** · L · desert,mountain · L37 · - |
| lichen-reindeer (L28; tundra) | B · **Reindeer Calf Herd** · M · tundra · L4 · se=spring,summer<br>A · **Caribou Bull** · L · tundra · L12 · se=autumn |

Placement notes:
- Swarms (S) carry G1: Fly Swarm L12, Mite Swarm L15, Fire Ant Raiders L18, Kelp Fly Swarm L21, Salt Mite Swarm L22, Beach Hopper Horde L25, Carpenter Ant Gang L28, Yellowjacket Mob L30, Mosquito Storm L31, Tumblebug Troupe L33, Zorilla Stink Squad L35, Dingo Pup Pack L37.
- Tundra (G5, G6): Lemming Kit Scurry 1, Snow Flea Swarm 2, Snowshoe Leveret Dash 3, Reindeer Calf Herd 4, Arctic Fox Kit 5 for NA / NWE roads; Snow Moth 9, Glacier Cub 9, Stoat 10, Frost Beetle 12, Caribou Bull 12, Snowy Owl Scout 14, Ice Bear 16, boss Frost Owl Regent 14 for the two lair routes and NWE steps 7-8. Tundra tags above L16 (Tundra Fox, Snow Lynx, Musk Ox, Wood Bison) only show for out-levelled gnomes.
- Island (G4): Coconut Crab Youngster 22, Golden Orb Weaver 23, Land Crab March 24, Storm Wisp 24, Moray Lurker 24, Beach Hopper Horde 25, Coral Golem 26, Stink Badger 26, Coconut Hermit 27, Tree Snake 28, Giant Clam 28, Ship Rat Crew 28, Frigatebird 29.
- Cond spread of the 218: night 48, dusk 18, dawn 12, day 6; sun 15, rain 15, heat 13, storm 10, wind 9, fog 6, snow / frost 6; spring 9, summer 11, autumn 8, winter 8. Soft conds only (x3), so none can vanish; add `!` only where a variant must be exclusive.
- Each new slug also needs a row in `data/pf_creature_class.txt` (linted by `tests/pfdeck_v1.php`) and drops.

## 5. Odd things and bugs

| # | what | evidence | effect |
|---|---|---|---|
| B1 | Fresh install numbers routes one lower from 239 up | `roads.php:96-98` (`$deadEnd ? 0 : $tb`, added in commit e21c8d65) no longer inserts the Clovercove > Blossomreach Market leg that `cut_dead_end_roads()` (`roads.php:213`) used to delete. Fresh SQLite install: 245 routes, ids 228-472; map data has 228-473 without 239. 234 of 245 routes then match another route's `from`/`to` in `trail_maps/*.json` | on a new world `trail_maps`, `trail_camps.json`, `road_kinds.txt`, ground pictures (`<route>-<sec>.png`) attach to the neighbouring route. Existing worlds keep their ids |
| B2 | Lair routes: stretch count differs from the authored map on a fresh install | `roads.php:141` `steps = 2 + min(3, lvl / 8)` with the new lair levels; `trail_sections()` (`trail_tiles.php:33`) uses `steps`, the map has its own count. 315, 327, 340, 363, 377: 5 authored / 3 steps; 389, 402, 415: 5 / 4; 425, 435, 458, 471: 4 / 5. Boot step `medium_lair_levels_1115` (`bootstrap.php:551`) changes levels only, so existing worlds keep the old steps | 5 / 3: the walk ends after stretch 3, the `E` boss spot on stretch 5 is never reached; walking back uses stretches 5, 4, 3 (`trail_phys_sec()` `trail_tiles.php:50`). 4 / 5: the fifth stretch is a generated 11x7 map |
| B3 | Lair-route boss spot gives an ordinary creature | `trail_pick_fixed()` needs a boss of the land with level <= L+8; none for 315, 327, 340, 349, 363, 377, 389, 415 (and 402 below L22). Falls to `pick_creature` | "⚔️ A fight waits" on the last stretch is a Grumpy Lemming / Frost Hare (315, 363) etc. |
| B4 | Extra mini-bosses far over the route | 3.3: 472 fern-cassowary L36 on a L8-12 route; 426, 457 mangrove-crab-king L30 on L8-12; 310 wolverine L21 and 309 arctic-fox L17 in the Maplewold (L1); 312 bramble-wolf L22, 314 clam-lurker L23 | full-strength fight (not eased); 321 (L4, red-fox L16), 341, 353, 371, 433 (prairie-bison L26 on L8-12) block the only path. Only an easy road turns `M` into a find, and easy roads apply only next to home |
| B5 | Wonder / delve route levels ignore the region | `roads.php:131-134`, `DIFFICULTY_LEVELS` (`adventure_data.php:115`): wonder 1-5 / 8-12 / 18-22, delve 10-14 / 20-24 by zone difficulty | OC wonders at L1-5 and L8-12 next to L35 roads; NA delve at L10-14 next to L1 roads; aphid-swarm is on-level in ESA and OC only through these |
| B6 | Return leg uses the village's land and the landmark's level with bosses allowed | `exp_scene()` takes `to`; fixed routes are not `scaled` | great-hawk L28 (6% per door) walking back from Anaconda Hollows, Rose-red Canyon City, Grey Wolf King, Gorilla Glade, Canopy Bridges, Silverback Spider, Jade Dragon-fly, Snowcrown Peak; side-path lands never appear on the way home |
| B7 | Delve mini-boss pool has no lower bound | `trail_tiles.php:245-246`: every large `<= L+4`, uniform `array_rand`, no cond, no ring | grass-snake L14 grown to L20-24 is as likely as an on-level large; 362 and 376 have one candidate (grey-heron, reef-turtle), below L11 / L12 none |
| B8 | Boss pick: lower bound missing too | `adventure.php:356`: any boss `<= L+8` however far below | coconut-crab-titan L26 grown to L35-39 on OC routes |
| B9 | `quiet` and `fights` counters do nothing | `trail_art.php:284-297`: counted, returned, saved, never used in the chance | no pity timer and no cap: fights per stretch are unbounded (Hunt on rough ground = 18.75% a tile) |
| B10 | Camp entry for a route that does not exist | `trail_camps.json` has `239`; so does `road_kinds.txt` (`239|toll`) | harmless on old worlds; on a fresh install (B1) it lands on Maizehollow Market > Meadowmere |
| B11 | Weather / time come from the destination region | `road_now()` | snow / frost conds (frost-hare) can only match where the region has that weather; mountain creatures in SE / MENA rarely get their boost |
| B12 | creatures.txt header says "3x likelier ... never excluded", and `!` makes it a must | `road_cond_weight()` | no creature uses `!`; all 23 conds are soft |
| B13 | `pick_creature` last-resort branch returns an unscaled creature of any level | `adventure.php:364-368` | unreachable while `any` creatures exist at L1-5; becomes live if they are retagged |
| B14 | Tile walks are off by default | `gnav_on` = 0, `gnav_tiles` = 0 on a fresh install | until switched on, all of section 3 applies as "40% per space" timer walks; `E`, `M`, camps do not exist |
| B15 | `creature_scale_percent` label says "above level 22" | `functions.php:731`; used for every scaled-up pick | forest L33 (WCA explore, OC) is the one walked slot that always scales (jungle-tiger / black-bear class grown to 31-33) |
