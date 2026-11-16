# Verify content (2.7.01, verifier 2, read-only)

Input: `game/includes/data/pf_creatures.txt` (318 rows), parsed with a script; pools recomputed with the picker rule (`level-6 <= Lv <= level+2`, non-boss, land fit, region filter when a region is given).

## Counts
- 318 rows = 88 base + 230 variants. All 88 slugs of `creatures.txt` present once, all `=`. No slug or name duplicates. No `*` on a variant. Every region code valid and has a land of the row.
- Variants per family (by `family` column): 2 -> 30, 3 -> 52, 4 -> 3, 1 -> 2, 0 -> 1. Off the 2-3 rule: dune-scorpion 4, tufted-lynx 4, griffon-vulture 4, dune-wyrm 1, storm-eagle 1, jade-jaguar 0.
- Ability ids all valid; within every family abilities and AI styles are pairwise distinct. Deck format, budget bands, tag legality, D-ability deck tests, 1 Hurt + 1 non-Hurt, unique piece names: 0 failures. Petals/exp in range, monotone by level. Every variant has >= 2 ungated drops and >= 1 region or level gate; no drop above 75%; every drop item is either found elsewhere in the game files or declared in `new_items` (text search, not a DB check).

## Fix list (rows)
| # | rows | problem | fix |
|---|---|---|---|
| F1 | jade-jaguar (0), dune-wyrm (1: dune-wyrmling), storm-eagle (1: lammergeier) | families under 2 variants | add 1-2 variants each |
| F2 | dune-scorpion (bark-scorpion, whip-scorpion, sandfish-skink-shoal, emperor-scorpion), tufted-lynx (wildcat, ocelot, caracal, snow-lynx), griffon-vulture (turkey-vulture, gyrfalcon, mountain-buzzard, condor) | 4 variants | move one to another family or accept 4 (SPEC sec 1 says 2-4, owner says 2-3) |
| F3 | 8 pairs, deck differs in only 1 piece by (type, tag): arctic-fox-kit/tundra-fox, rock-crab-pincher/mangrove-crab-emperor, tundra-vole-swarm/ibex-patriarch (same `family` cliff-ram), ocelot/snow-lynx, cockle-bed/giant-clam, gyrfalcon/condor, ice-floe-seal/elephant-seal-bull, reindeer-calf-herd/caribou-bull | deck is a number tweak of the sibling | change one piece (type or tag) in the later row |
| F4 | 86 rows with `@lv>=N` where N > the creature's own level (gate checks the FIGHT level, only a grown creature passes): bases with `Item:15-20@lv>=L+1..4` (ant-scouts, gnat-cloud, leopard-slug, dusk-moth, dung-beetle, earwig, orb-spider, paper-wasp, bog-leech, bullfrog, barn-rat, tunnel-mole, carrion-crow, thistle-beast, will-o-wisp, savanna-hyena, sand-fleas, cave-glowworm, grumpy-lemming, shore-crab, sun-lizard, herring-gull, dune-scorpion, frost-hare, giant-centipede, ember-beetle, hermit-crab-hoarder, sea-otter-bandit, dust-sidewinder, poison-dart-frog, leafcutter-column, ptarmigan-flock, spice-monitor, outback-dingo, skua-raider, jackrabbit, giant-millipede, snowy-owl-scout, ...) and variants (carpenter-ant-gang, tumblebug-troupe, yellowjacket-mob, giant-mire-leech, star-nosed-mole, foxfire-wisp, egret-flock, zorilla-stink-squad, cassowary-chick-creche, emu-mob, warthog, pangolin, giant-banded-snail, beach-hopper-horde, salt-mite-swarm, golden-mole, jungle-crow, whip-scorpion, arctic-fox-kit, whiteout-fox, desert-spadefoot, palm-thief-crab, snow-owl-fledgling, jaguarundi, snow-leopard-cub, rock-viper, dingo-pup-pack, blue-ring-octopus, rock-crab-pincher, dune-racer, willow-grouse-covey, beaded-lizard, booby-colony, caracal, sun-bear, glacier-cub, reindeer-calf-herd, tundra-vole-swarm, lichen-golem, ice-bear, caribou-bull, eagle-owl, elder-bramble-wolf, robber-crab-baron, wolverine-cub, ...) | the drop never opens | use `@lv<=` gates, `@reg` gates, or no gate; or `@lv>=` = the creature's own level |
| F5 | bark-scorpion L19 (SEA, WCA), coati-band L19 (SEA, WCA) | region level above Lv+6: dead on every road (SEA window starts at L20) | level 20, or regions CB/SA (rainforest) |
| F6 | glass-frog L18 (SA, SEA), palm-thief-crab L18 (SE), rock-crab-pincher L19 (SE), camel-calf L23 (EA, ESA) | region too low or too high for the level (rainforest and island have no region with window 15-25; desert none 23-25): only a gnome out-levelling near home meets them (glass-frog in SEA never) | move level to 20+ (island, rainforest) or 22 (camel-calf) |
| F7 | sibling pairs sharing land + window 8 + a region with the same or no cond: pangolin/aardvark (OC, both dp=night), wildcat/ocelot (WCA, both dusk+night), jaguarundi/elder-tiger (OC, both -), fishing-cat/jaguarundi (OC) | SPEC allows 7 pairs with different conds only | disjoint regions or a different cond |
| F8 | Black Truffle in `new_items` of both wild-boar and piglet-squeal | declared twice | declare once |
| F9 | 23 drops `@reg=X` where X is every region of the row (mole-rat-gang, thorn-jackal, banana-slug, coconut-crab-youngster, dune-wyrmling, giant-clam, emperor-scorpion, tide-crab-paladin, frost-owl-regent, lammergeier, saltwater-gharial, rock-python, ghost-leopard, alpha-dingo, kraken-spawn, leatherback, albatross, aardvark, condor, sloth-bear, elephant-seal-bull, wood-bison, wild-bactrian) | gate does nothing | drop the gate or widen the region list |
| F10 | 97 pairs of rows share an ability string, a landscape and a level window of 8 (SPEC sec 2 rule; full list in the scratchpad `abil_dups.txt`); worst: drain1 x14 rows, D5, grudge-fury+enrage1, plated1, toughhide1, regrow1 | SPEC rule broken (not family-unique) | vary params `(k=v)` or swap ids |
| F11 | no `we=cloud` cond in any row; mountain has no storm or fog row | G10 partial | one mountain `we=storm,fog` row; one `we=cloud` row |

## Gap check (spawn-review sec 4.1)
| gap | result |
|---|---|
| G1 smalls above L5 per land per 10 levels | filled except mountain L20-29 (0 variant smalls), tundra n/a, forest L30s 1, wetland 2-3 |
| G2 M in L18-26 bands | 7-15 variant M per land: filled. Island L30+ M variants 1 (pool: island no M at L38-40) |
| G3 late L30-40 | 12-23 rows per land: filled |
| G4 island L20-30 | 20 variants: filled |
| G5 tundra L1-3 smalls (4), L8-16 (13) | filled |
| G6 tundra kin of arctic-fox, ptarmigan, wolverine, glacier-bear, lichen-reindeer, snow-owl-monarch | filled (kit L5, grouse L7, cub L9-13, calf L4, regent L14) |
| G7 desert L17-23 | 14 variants: filled; desert L23-25 has no region window (F6) |
| G8 mountain L1-8 (6), coast L1-5 (1: sea-slug-drift L5), island L1-5 (1) | coast L1-4 not filled: NA coast pool at L1 is 4 |
| G9 wetland L9-13 | 7 variants: filled |
| G10 conds | all but `we=cloud` used; dp=day 8, we=wind 11; desert dawn and wind now exist; mountain storm/fog and cloud missing |

## Pools (land only, region ignored; S/M/L, all rows; level 1-40 all checked)
| land | L1 | L4 | L8 | L12 | L17 | L20 | L26 | L32 | L38 | L40 |
|---|---|---|---|---|---|---|---|---|---|---|
| grassland | 5 | 8 | 11 | 11 | 16 | 21 | 20 | 19 | 18 | 14 |
| forest | 5 | 8 | 9 | 7 | 13 | 21 | 22 | 18 | 15 | 9 |
| wetland | 5 | 8 | 10 | 12 | 19 | 21 | 15 | 19 | 11 | 6 |
| coast | 4 | 6 | 11 | 13 | 17 | 19 | 17 | 19 | 15 | 9 |
| island | 3 | 5 | 10 | 10 | 11 | 15 | 18 | 16 | 8 | 6 |
| desert | 4 | 6 | 10 | 10 | 13 | 19 | 16 | 12 | 15 | 12 |
| mountain | 3 | 7 | 14 | 17 | 18 | 18 | 16 | 14 | 15 | 12 |
| tundra | 6 | 10 | 14 | 13 | 12 | 9 | 7 | 5 | 2 | 1 |
| rainforest | 4 | 6 | 9 | 8 | 10 | 12 | 17 | 21 | 12 | 7 |

Under 5: coast L1-2 (4), island L1-2 (3), desert L1-2 (4), mountain L1-2 (3), rainforest L1-2 (4), tundra L33-40 (no tundra region there). No small at: forest L11 and L40, wetland L39-40, desert L29-32, mountain L24-27 and L37-40, rainforest L40; no medium at island L38-40; every land has a large from L14.

Region-filtered (walk level = region level, main lands): all >= 5 except NA coast 4 (L1). Explore-only lands: NA mountain 3. Out-levelled walks (W up to 40): SEA wetland L37-40 0-1, SEA rainforest L35-40 1, SEA coast 2-4 from L34, SEA island 3-4 from L35, WCA grassland/wetland/rainforest L38-40 2-3, NWE tundra W12 4, CSA wetland W29 3. ESA desert at W=32: 0 small, 7 M, 4 L.

## Rows that can never spawn
On ordinary roads, no listed region with the land in window: bark-scorpion, coati-band (F5), glass-frog at SEA. Out-levelled only (every listed region below Lv-2): palm-thief-crab, rock-crab-pincher, camel-calf, glass-frog (SA). L35-40 rows reachable only by a gnome of level >= Lv-2 in a listed region (no region level above 35): goliath-heron, elder-mire-toad, ratel-pair, emu-mob, lava-beetle, gorse-beast, old-brock, conger-brute, elder-tiger, mangrove-crab-emperor, musk-ox, reef-eel-tyrant, alpha-dingo, kraken-spawn, ibex-patriarch. Bases without a window region (pre-existing, rainforest L15-17, island L16, desert L24, tundra L17-28): leafcutter-column, mischief-monkey, reef-turtle, desert-tortoise, arctic-fox, glacier-bear, lichen-reindeer.
