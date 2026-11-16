# Drops audit (creature pass 2.7.00 -> 2.7.01)

Owner: drops auditor. Read-only analysis of `game/includes/data/*`, `adventure.php`, `adventure_data.php`, `catalog.php`, `gathering.php`, `rewards.php`, `pfight_data.php`. No code changed.

## 0. Findings that change the SPEC (read first)

1. **Item identity is the SLUG, not the name.** A drop name resolves by `item_id_by_slug(slugify(name))` (`import_creatures_txt`). A gatherable item's slug is col 1 of `gatherables.txt`; a trail-sight item's slug is col 1 of `trail_sight_items*.txt`; a crop's produce item slug is the crop slug (col 1 of `crops.txt`); a flower's cut-flower item slug is `cut-` + flower slug. SPEC 5.1 says "col 2" (the display name): wrong for any item whose name does not slugify to its slug. The lint must compare against col-1 slugs (plus `cut-<flower>`). Names that do NOT resolve are silently created as new 'part' items (a duplicate of the real item). Safe drop name = title-case of the slug (`fiddleheads` -> `Fiddleheads`, `perch` -> `Perch`, `date` -> `Date`, `cut-dahlia` -> `Cut Dahlia`). Existing mismatches (never use the display name as a drop): Shed Butterfly Scales = `Butterfly Scales`, Flint Nodule = `Flint`, Fiddlehead Ferns = `Fiddleheads`, Sphagnum Moss = `Sphagnum`, Shed Dragonfly Wing = `Dragonfly Wing`, Urchin Shell = `Urchin Test`, River Perch = `Perch`, Brook Trout = `Trout` (left: display name, right: drop name).

2. **Crop produce can be renamed on import** (`catalog.php` `$produceNames`: slug `date` -> item "Dates", `coffee` -> "Coffee Cherries", `almond` -> "Almonds", `cacao` -> "Cacao Pods", `olive` -> "Olives", ...). The drop name "Dates" would NOT resolve (slug `dates`); "Date" does. Flowers: the item is "Cut X" (or "X Blossoms" for tree-like) but the slug is always `cut-<slug>`: drop name `Cut <Title(slug)>`. Accented names (`Lucuma`, `Acai`) in `crops.txt` slugify wrongly: use the slug-derived name only.
3. **Nothing is missing.** Every item named in `creatures.txt` resolves: 18 are existing non-creature items, 103 are creature-only 'part' items made by `import_creatures_txt` (rarity `min(95,max(5,100-chance+level))`, price `max(5,round(L*4*(110-chance)/60))` from the FIRST creature that names it). `Straw Mulch` collides with a crafted item of the same slug (`crafts.txt`/`recipes.txt`): Prairie Bison drops that real item. `PF_GIFT` (pfight_data.php) has all 88 base slugs and each gift name is one of that creature's drops; a variant needs no PF_GIFT entry (fallback in `win_fight` = its highest-chance item, so put the signature common item FIRST/highest).
4. **No creature gives Petals today.** `win_fight` (adventure.php:968) gives XP (`c.xp`, half if peaceful and not a puzzle Charm; then `outlevel_scale`, pal `lesson`, `add_action_xp`) and drops only. Petals exist only via `give_petals` (rewards.php:20, `UPDATE users SET coins`) and the find reward (adventure.php:451: `round((rand(5,15)+2*L)*(1+rich/100))`, outlevel scaled). New Petals in `win_fight` must pass through `outlevel_scale(n, outlevel_percent(...))` (the setting text already says XP and Petals shrink for outgrown areas) and halve when `$peaceful && !$full`; the importer stores `xp = round(6*L*m)` (m small .8, medium 1.1, large 1.6, boss 2.4) in `creatures.xp`. Gate rolls: drops are rolled per entry with `chance + luckBonus(luck_mod*2) + pal spoils`, capped 100: a 1-5% rare is no longer 1-5% for a lucky gnome; gates must be checked BEFORE the roll.
5. Specials in use: `*seed` on 11 base rows (ant-scouts, grumpy-lemming, barn-rat, mischief-monkey, moss-golem, coconut-crab-titan, delta-gharial, spice-monitor, leafcutter-column, wild-boar, glacier-bear); `*guide:5` on 8 bosses. Roster: small 10, medium 26, large 43, boss 9 = 88 rows.

## 1. Existing items dropped by creatures.txt that already exist elsewhere (18)

| drop name (use exactly) | item slug | source | dropped by |
|---|---|---|---|
| Spiral Shell | spiral-shell | gather | garden-snail, hermit-crab-hoarder |
| Blue Mussels | blue-mussels | gather | sea-otter-bandit, clam-lurker |
| Seed Pearl | seed-pearl | gather | sea-otter-bandit, clam-lurker |
| Morpho Scales | morpho-scales | gather | poison-dart-frog |
| Fiddleheads | fiddleheads | gather | poison-dart-frog, leafcutter-column |
| Sea Grapes | sea-grapes | gather | reef-turtle |
| Cottongrass | cottongrass | gather | ptarmigan-flock, lichen-reindeer |
| Perch | perch | gather | bog-pike |
| Scarab Shell | scarab-shell | gather | desert-gila-dragon |
| Slate Shard | slate-shard | gather | cliff-ram |
| Oak Gall | oak-gall | gather | wild-boar |
| Sardine | sardine | gather | pelican-parliament |
| Birch Log | birch-log | gather | beaver-foreman |
| Cattail Root | cattail-root | gather | beaver-foreman |
| Rubber Sap | rubber-sap | gather | giant-anteater |
| Mesquite Pods | mesquite-pods | gather | desert-tortoise, desert-camel |
| Sea Salt | sea-salt | gather | salt-sea-lion |
| Bladderwrack | bladderwrack | gather | salt-sea-lion |

## 2. Creature-only 'part' items (103), by number of users

Drop name -> creatures that drop it (old rows). Names used by 2+ creatures are shared parts writers may reuse freely; singletons are species identity parts (do not reuse them on another family).

| drop name | n | creatures |
|---|---|---|
| Sea Glass | 7 | sand-fleas, herring-gull, reef-leviathan, reef-eel-lord, deep-octopus, hermit-crab-hoarder, pelican-parliament |
| Pearl | 6 | tide-crab-knight, reef-leviathan, mangrove-crab-king, reef-eel-lord, deep-octopus, clam-lurker |
| Eel Skin | 5 | reef-leviathan, delta-gharial, reef-eel-lord, bog-pike, salt-sea-lion |
| Fox Fang | 5 | red-fox, arctic-fox, jungle-tiger, savanna-hyena, outback-dingo |
| Frost Crystal | 5 | frost-hare, snow-owl-monarch, cliff-ram, wolverine, glacier-bear |
| Antler Shard | 4 | old-bramblehorn, cloud-leopard, thunder-yak, lichen-reindeer |
| Desert Gem | 4 | dune-wyrm, sand-viper-matriarch, desert-tortoise, desert-camel |
| Frost Fur | 4 | frost-hare, cloud-leopard, thunder-yak, glacier-bear |
| Long Feather | 4 | grey-heron, fern-cassowary, pelican-parliament, griffon-vulture |
| Snake Skin | 4 | grass-snake, emerald-python, sand-viper-matriarch, dust-sidewinder |
| Spotted Pelt | 4 | jade-jaguar, jungle-tiger, cloud-leopard, tufted-lynx |
| Velvet Pelt | 4 | tunnel-mole, jungle-tiger, beaver-foreman, prairie-bison |
| Ant Chitin | 3 | ant-scouts, leafcutter-column, giant-anteater |
| Badger Claw | 3 | badger, honey-badger-brute, wolverine |
| Badger Pelt | 3 | badger, honey-badger-brute, black-bear |
| Lizard Scale | 3 | sun-lizard, spice-monitor, desert-gila-dragon |
| Spotted Hide | 3 | leopard-slug, savanna-hyena, fern-cassowary |
| White Pelt | 3 | arctic-fox, wolverine, glacier-bear |
| Beetle Shell | 2 | dung-beetle, earwig |
| Black Feather | 2 | carrion-crow, fern-cassowary |
| Bright Feather | 2 | ptarmigan-flock, griffon-vulture |
| Bushy Tuft | 2 | red-fox, tufted-lynx |
| Cowrie Shell | 2 | hermit-crab-hoarder, reef-turtle |
| Crab Claw | 2 | shore-crab, mangrove-crab-king |
| Crab Shell | 2 | shore-crab, mangrove-crab-king |
| Desert Rose Stone | 2 | dust-sidewinder, desert-gila-dragon |
| Digging Claw | 2 | tunnel-mole, giant-anteater |
| Dung Ball | 2 | dung-beetle, prairie-bison |
| Fox Pelt | 2 | red-fox, outback-dingo |
| Frog Skin | 2 | bullfrog, poison-dart-frog |
| Glowing Bead | 2 | cave-glowworm, deep-octopus |
| Goat Hair | 2 | cliff-ram, desert-camel |
| Jade Eye | 2 | jade-jaguar, emerald-python |
| Leaf Mould Clump | 2 | wild-boar, black-bear |
| Mire Hide | 2 | mire-toad, delta-gharial |
| Owl Feather | 2 | tawny-owl, tufted-lynx |
| Pretty Feather | 2 | ptarmigan-flock, giant-bumblebee |
| Rat Tooth | 2 | barn-rat, savanna-hyena |
| Shed Skin | 2 | sun-lizard, spice-monitor |
| Snake Fang | 2 | grass-snake, emerald-python |
| Tortoise Scute | 2 | reef-turtle, desert-tortoise |
| Venom Fang | 2 | giant-centipede, sand-viper-matriarch |
| Wild Honeycomb | 2 | giant-bumblebee, black-bear |
| Aphid Wings | 1 | aphid-swarm |
| Beeswax | 1 | giant-bumblebee |
| Bog Peat | 1 | bog-pike |
| Bramble Pelt | 1 | bramble-wolf |
| Centipede Plate | 1 | giant-centipede |
| Coconut Husk | 1 | coconut-crab-titan |
| Croak Sac | 1 | bullfrog |
| Eagle Down | 1 | griffon-vulture |
| Earwig Pincer | 1 | earwig |
| Elder Pelt | 1 | old-bramblehorn |
| Ember Shell | 1 | ember-beetle |
| Ember Spark | 1 | ember-beetle |
| Flea Legs | 1 | sand-fleas |
| Forager's Crumb | 1 | ant-scouts |
| Glow Silk | 1 | cave-glowworm |
| Gnat Dust | 1 | gnat-cloud |
| Golden Talon | 1 | storm-eagle |
| Golem Pebble | 1 | moss-golem |
| Gull Feather | 1 | herring-gull |
| Hawk Feather | 1 | great-hawk |
| Heron Plume | 1 | grey-heron |
| Honeydew | 1 | aphid-swarm |
| Kelp Frond | 1 | sea-otter-bandit |
| Leech Slime | 1 | bog-leech |
| Lemming Fluff | 1 | grumpy-lemming |
| Living Moss | 1 | moss-golem |
| Marsh Pearl | 1 | will-o-wisp |
| Monkey Fur | 1 | mischief-monkey |
| Mossy Shell | 1 | ancient-snapper |
| Moth Wing | 1 | dusk-moth |
| Owl Pellet | 1 | tawny-owl |
| Paper Comb | 1 | paper-wasp |
| Raccoon Pelt | 1 | raccoon |
| Rat Pelt | 1 | barn-rat |
| Reindeer Lichen | 1 | lichen-reindeer |
| Scorpion Plate | 1 | dune-scorpion |
| Scorpion Stinger | 1 | dune-scorpion |
| Shiny Trinket | 1 | carrion-crow |
| Sky Talon | 1 | great-hawk |
| Slug Slime | 1 | leopard-slug |
| Snail Slime | 1 | garden-snail |
| Snowy Plume | 1 | snow-owl-monarch |
| Spider Fang | 1 | orb-spider |
| Spider Silk | 1 | orb-spider |
| Stolen Bauble | 1 | raccoon |
| Stolen Trinket | 1 | mischief-monkey |
| Storm Feather | 1 | storm-eagle |
| Straw Mulch | 1 | prairie-bison |
| Thistle Heart | 1 | thistle-beast |
| Thistle Spines | 1 | thistle-beast |
| Thorn Fang | 1 | bramble-wolf |
| Tide Shell | 1 | tide-crab-knight |
| Titan Claw | 1 | coconut-crab-titan |
| Toad Jewel | 1 | mire-toad |
| Turtle Scute | 1 | ancient-snapper |
| Wasp Stinger | 1 | paper-wasp |
| Wing Dust | 1 | dusk-moth |
| Wisp Light | 1 | will-o-wisp |
| Wyrm Fang | 1 | dune-wyrm |
| Wyrm Scale | 1 | dune-wyrm |

## 3. Petals and exp scale (proposal = SPEC 5.2 / 5.3 made concrete)

Petals per win: `mid = max(1, round(K*(2+0.6*L)))`, K = .5 small / 1.0 medium / 1.8 large / 4.0 boss; `min = max(1,round(.7*mid))`, `max = max(min,round(1.3*mid))`; written `min-max`; random_int(min,max) in `win_fight`, then `outlevel_scale`, halved for a peaceful non-puzzle win. Old XP = `round(6*L*m)`; the new `exp` column multiplies it (0.8-1.5); a 1.0 row is unchanged.

Reference: a find pays `5..15 + 2L` Petals (L10 avg 30), so a fight win must pay less than a find at equal level: small L10 4-7 (mid 5), medium L10 6-10 (mid 8), large L20 18-33 (mid 25), boss L30 56-104 (mid 80). Drops stay the main income (a 50% part at L10 prices about 40 Petals).

| L | small petals | small XP | medium petals | medium XP | large petals | large XP | boss petals | boss XP |
|---|---|---|---|---|---|---|---|---|
| 1 | 1-1 | 5 | - | - | - | - | - | - |
| 3 | 1-3 | 14 | - | - | - | - | - | - |
| 5 | 2-4 | 24 | 4-7 | 33 | - | - | - | - |
| 8 | 2-4 | 38 | 5-9 | 53 | - | - | - | - |
| 10 | 3-5 | 48 | 6-10 | 66 | - | - | - | - |
| 12 | 4-7 | 58 | 6-12 | 79 | - | - | - | - |
| 15 | 4-8 | 72 | 8-14 | 99 | 14-26 | 144 | - | - |
| 18 | 4-8 | 86 | 9-17 | 119 | 16-30 | 173 | - | - |
| 20 | 5-9 | 96 | 10-18 | 132 | 18-33 | 192 | - | - |
| 22 | 6-10 | 106 | 11-20 | 145 | 19-35 | 211 | - | - |
| 25 | 6-12 | 120 | 12-22 | 165 | 22-40 | 240 | - | - |
| 28 | 6-12 | 134 | 13-25 | 185 | 24-44 | 269 | 53-98 | 403 |
| 30 | 7-13 | 144 | 14-26 | 198 | 25-47 | 288 | 56-104 | 432 |
| 32 | 8-14 | 154 | 15-27 | 211 | 27-49 | 307 | 59-111 | 461 |
| 35 | 8-16 | 168 | 16-30 | 231 | 29-53 | 336 | - | - |
| 38 | - | - | 18-33 | 251 | - | - | - | - |

Valid level ranges in the roster: small 1-35, medium 5-38, large 14-37, boss 26-32 (variants: level +-1, never across a size). `-` = no creature of that size at that level.

Exp multiplier by ability cost: cost 0 -> 1.0, 1 -> 1.1, 2 -> 1.2, 3 -> 1.3; easier-than-base small variant 0.9; cap 1.5. Effective XP = `round(round(6*L*m) * exp)` (round half up), before outlevel/lesson. Example: medium L20 base XP 132, cost 2 -> 158.

Petals/drop-price consistency check: petals value of a win at the lint's 25% band is +-25% of the table; boss petals (K=4) stay below the 3-5 part drops a boss row gives at its level (boss part at L30, 60% chance prices about 100, a 5% one about 210).
## 4. Region-gated candidate drops (14 regions)

How to use: copy the name exactly (all resolve to EXISTING items, no column-17 entry needed) and append the gate: `Pecan:4%@reg=NA`, `Cut Dahlia:12%@reg=CA@lv>=10`. `@reg=A/B` lists several. The gated entry of a variant row should use a region that is in that row's `regions` list; a gate for a region outside the row never rolls (wasted). Chance bands: staple crop / local material 20-40% (the "common gated" slot, cap 60), uncommon crop / flower 8-20%, treasure crop / rare flower 2-5% (keep one UNGATED 1-5% rare as well: a gated-only rare is invisible outside its region). `@lv>=N` for treasure items on rows whose level is below the region level + 4 (the picker rule lets a row of level Lv walk regions R with Lv-2<=R<=Lv+6, so low rows meet high-region gates: gate treasure with `@lv>=R-4`).

Rules from the lookup: crops use the slug-derived Title Case name (so `Date`, not `Dates`; `Corn`, not `Maize`; `Nopal`, not `Prickly Pear Cactus`; `Tamarillo`, not `Tree Tomato`; the names below are already the safe ones); flowers `Cut <slug>`; 'local' = the region's two building materials from `region_locals.txt` (real gatherables).

| region | lvl | lands | common gated (20-40%) | uncommon gated (8-20%) | rare gated (2-5%) | NEW part ideas (flavour, col 17) |
|---|---|---|---|---|---|---|
| NA | 1 | grassland forest coast tundra +mountain +wetland | Birch Log, Pine Resin, Soybean, Lentil | Apple, Hops, Raspberry, Cut Coneflower, Cut Black Eyed Susan | Pecan, Cranberry, Blueberry, Cut Fireweed, Cut Blue Flag Iris | Maple Key, Acorn Cap |
| CA | 4 | grassland rainforest desert mountain | Red Ochre, Laterite Clay, Corn, Black Bean | Chayote, Avocado, Nopal, Cut Dahlia, Cut Poinsettia | Vanilla, Cacao, Cardamom, Cut Tiger Flower, Cut Chocolate Cosmos | Maize Husk, Obsidian Chip |
| NWE | 6 | grassland forest coast tundra +mountain +wetland | Sphagnum, Cottongrass, Rye, Barley | Rhubarb, Blackcurrant, Lingonberry, Cut Heather, Cut Lily Of The Valley | Cloudberry, Gooseberry, Hazelnut, Cut Daffodil, Cut Sea Thrift | Heather Sprig, Mist Pearl |
| CB | 8 | island coast rainforest wetland +forest | Driftwood, Coir Fibre, Sweet Potato, Pigeon Pea | Breadfruit, Guava, Soursop, Cut Pride Of Barbados, Cut Lignum Vitae | Ackee, Nutmeg, Sugarcane, Cut White Ginger Lily, Cut Red Hibiscus | Conch Whorl, Hurricane Bead |
| SE | 10 | coast mountain island +forest | Flint, Sea Salt, Fava Bean, Oregano | Olive, Grape, Fig, Cut Lavender, Cut Carnation | Caper, Carob, Chestnut, Cut Snapdragon, Cut Field Gladiolus | Olive Stone, Terracotta Chip |
| SA | 12 | grassland mountain rainforest desert | Palm Trunk, Fiddleheads, Quinoa, Cassava | Passion Fruit, Cherimoya, Lucuma, Cut Bougainvillea, Cut Alstroemeria | Brazil Nut, Acai, Cashew, Cut Lapacho, Cut Ceibo | Condor Quill, Andean Wool Tuft |
| EE | 14 | grassland forest wetland mountain +tundra | Birch Log, River Clay, Buckwheat, Bell Pepper | Cherry, Pear, Elderberry, Cut Lilac, Cut Chamomile | Walnut, Quince, Sea Buckthorn, Cut Lungwort, Cut Spring Adonis | Birch Bark Scroll, Amber Bead |
| MENA | 17 | coast grassland mountain desert | Red Ochre, Desert Sage, Chickpea, Eggplant | Date, Pomegranate, Jute Mallow, Cut Damask Rose, Cut Blue Lotus | Saffron, Pistachio, Almond, Cut Henna, Cut Hyacinth | Dune Glass Bead, Camel Hair Tuft |
| EA | 20 | grassland forest coast desert +mountain +wetland | Pine Log, Slate Shard, Napa Cabbage, Daikon | Peach, Perilla, Lotus Root, Cut Sakura, Cut Chrysanthemum | Wasabi, Ginseng, Yuzu, Cut Osmanthus, Cut Balloon Flower | Lacquer Chip, Silk Floss |
| CSA | 23 | wetland grassland forest mountain | Slate Shard, Pine Resin, Wheat, Mung Bean | Turmeric, Mango, Jackfruit, Cut Greigs Tulip, Cut Foxtail Lily | Cinnamon, Tea, Black Pepper, Cut Cannonball Tree, Cut Tibetan Gentian | Prayer Flag Scrap, Monsoon Bead |
| SEA | 26 | wetland coast island rainforest | Coir Fibre, Palm Trunk, Rice, Kangkong | Dragon Fruit, Rambutan, Longan, Cut Moth Orchid, Cut Sampaguita | Durian, Mangosteen, Salak, Cut Golden Shower, Cut Rangoon Creeper | Teak Chip, Lantern Shard |
| WCA | 29 | grassland wetland rainforest coast +forest | Laterite Clay, Palm Trunk, Yam, Cowpea | Egusi, Hibiscus, Bambara, Cut African Tulip Tree, Cut Desert Rose | Kola, Shea, Grains Of Paradise, Cut Sausage Tree, Cut Kapok Blossom | Kente Thread, Mahogany Chip |
| ESA | 32 | grassland mountain wetland desert | Flint, Red Ochre, Teff, Collard | Ensete, Tamarind, Watermelon, Cut African Violet, Cut Busy Lizzie | Coffee, Baobab, Clove, Cut Red Hot Poker, Cut Cape Daisy | Acacia Thorn, Ostrich Eggshell |
| OC | 35 | island coast forest desert +mountain +rainforest | Coir Fibre, Spiral Shell, Taro, Coconut | Noni, Sago, Kiwi, Cut Kangaroo Paw, Cut Waratah | Kava, Macadamia, Finger Lime, Cut Heilala, Cut Beach Hibiscus | Greenstone Chip, Opal Fleck |

Full lists per region (all safe drop names):

- **NA**: staple Soybean, Lentil, Oats, Kidney Bean; uncommon Apple, Hops, Raspberry, Wild Rice; treasure Pecan, Cranberry, Blueberry; local Birch Log, Pine Resin; flowers Cut Coneflower, Cut Black Eyed Susan, Cut Blue Violet, Cut Milkweed, Cut California Poppy, Cut Trillium, Cut Columbine, Cut Bee Balm, Cut Goldenrod, Cut Lupine, Cut Fireweed, Cut Blue Flag Iris.
- **CA**: staple Corn, Black Bean, Chili Pepper, Tomatillo; uncommon Chayote, Avocado, Nopal, Amaranth, Papaya, Mamey; treasure Vanilla, Cacao, Cardamom; local Red Ochre, Laterite Clay; flowers Cut Dahlia, Cut Poinsettia, Cut Guaria Morada, Cut Monja Blanca, Cut Marigold, Cut Cosmos, Cut Zinnia, Cut Mexican Sunflower, Cut Tuberose, Cut Mexican Sage, Cut Tiger Flower, Cut Chocolate Cosmos.
- **NWE**: staple Rye, Barley, Leek, Brussels Sprouts; uncommon Rhubarb, Blackcurrant, Lingonberry, Asparagus, Kohlrabi; treasure Cloudberry, Gooseberry, Hazelnut; local Sphagnum, Cottongrass; flowers Cut Heather, Cut Lily Of The Valley, Cut Cornflower, Cut Bluebell, Cut Dutch Tulip, Cut Edelweiss, Cut Corn Poppy, Cut Forget Me Not, Cut Primrose, Cut Foxglove, Cut Daffodil, Cut Sea Thrift.
- **CB**: staple Sweet Potato, Pigeon Pea, Plantain, Lime; uncommon Breadfruit, Guava, Soursop, Pineapple, Grapefruit; treasure Ackee, Nutmeg, Sugarcane; local Driftwood, Coir Fibre; flowers Cut Pride Of Barbados, Cut Lignum Vitae, Cut Bayahibe Rose, Cut Chaconia, Cut Frangipani, Cut Ixora, Cut Allamanda, Cut Lantana, Cut Peregrina, Cut Yellow Elder, Cut White Ginger Lily, Cut Red Hibiscus.
- **SE**: staple Fava Bean, Oregano, Artichoke; uncommon Olive, Grape, Fig, Lemon, Orange, Mandarin; treasure Caper, Carob, Chestnut; local Flint, Sea Salt; flowers Cut Lavender, Cut Carnation, Cut Rock Rose, Cut Florentine Iris, Cut Myrtle, Cut Spanish Broom, Cut Acanthus, Cut Sea Daffodil, Cut Sweet Pea, Cut Stock, Cut Snapdragon, Cut Field Gladiolus.
- **SA**: staple Quinoa, Cassava, Peanut; uncommon Passion Fruit, Cherimoya, Lucuma, Feijoa, Naranjilla, Yerba Mate, Tamarillo; treasure Brazil Nut, Acai, Cashew; local Palm Trunk, Fiddleheads; flowers Cut Bougainvillea, Cut Alstroemeria, Cut Cantuta, Cut Copihue, Cut Heliconia, Cut Passionflower, Cut Fuchsia, Cut Nasturtium, Cut Petunia, Cut Cattleya, Cut Lapacho, Cut Ceibo.
- **EE**: staple Buckwheat, Bell Pepper, Plum; uncommon Cherry, Pear, Elderberry, Sorrel; treasure Walnut, Quince, Sea Buckthorn; local Birch Log, River Clay; flowers Cut Lilac, Cut Chamomile, Cut Snowdrop, Cut Kalyna, Cut Martagon Lily, Cut Pasque Flower, Cut Steppe Peony, Cut Hollyhock, Cut Dog Rose, Cut Marsh Marigold, Cut Lungwort, Cut Spring Adonis.
- **MENA**: staple Chickpea, Eggplant, Cumin; uncommon Date, Pomegranate, Jute Mallow, Sesame; treasure Saffron, Pistachio, Almond; local Red Ochre, Desert Sage; flowers Cut Damask Rose, Cut Blue Lotus, Cut Oleander, Cut Atlas Daisy, Cut Crown Anemone, Cut Persian Buttercup, Cut Cyclamen, Cut Black Iris, Cut Star Of Bethlehem, Cut Statice, Cut Henna, Cut Hyacinth.
- **EA**: staple Napa Cabbage, Daikon, Adzuki, Bok Choy; uncommon Peach, Perilla, Lotus Root, Jujube, Persimmon, Lychee, Bamboo Shoot; treasure Wasabi, Ginseng, Yuzu; local Pine Log, Slate Shard; flowers Cut Sakura, Cut Chrysanthemum, Cut Tree Peony, Cut Rose Of Sharon, Cut Camellia, Cut Plum Blossom, Cut Morning Glory, Cut Hydrangea, Cut Wisteria, Cut Satsuki Azalea, Cut Osmanthus, Cut Balloon Flower.
- **CSA**: staple Wheat, Mung Bean, Fenugreek, Ginger; uncommon Turmeric, Mango, Jackfruit, Melon, Apricot, Mulberry; treasure Cinnamon, Tea, Black Pepper; local Slate Shard, Pine Resin; flowers Cut Greigs Tulip, Cut Foxtail Lily, Cut Giant Allium, Cut Bukhara Iris, Cut Sacred Lotus, Cut Rhododendron, Cut Blue Poppy, Cut Night Jasmine, Cut Flame Of The Forest, Cut Champak, Cut Cannonball Tree, Cut Tibetan Gentian.
- **SEA**: staple Rice, Kangkong, Lemongrass, Bitter Melon; uncommon Dragon Fruit, Rambutan, Longan, Starfruit, Moringa; treasure Durian, Mangosteen, Salak; local Coir Fibre, Palm Trunk; flowers Cut Moth Orchid, Cut Sampaguita, Cut Miss Joaquim, Cut Torch Ginger, Cut Dendrobium, Cut Croton, Cut Ylang Ylang, Cut Spider Lily, Cut Jade Vine, Cut Siam Tulip, Cut Golden Shower, Cut Rangoon Creeper.
- **WCA**: staple Yam, Cowpea, Millet, Okra; uncommon Egusi, Hibiscus, Bambara, Fonio; treasure Kola, Shea, Grains Of Paradise; local Laterite Clay, Palm Trunk; flowers Cut African Tulip Tree, Cut Desert Rose, Cut Crinum Lily, Cut Wild Gardenia, Cut Blood Lily, Cut Glory Bower, Cut Gloriosa Lily, Cut Congo Cockatoo, Cut Ashanti Blood, Cut Senegal Coral Tree, Cut Sausage Tree, Cut Kapok Blossom.
- **ESA**: staple Teff, Collard, Banana, Sorghum; uncommon Ensete, Tamarind, Watermelon, Rooibos; treasure Coffee, Baobab, Clove; local Flint, Red Ochre; flowers Cut African Violet, Cut Busy Lizzie, Cut Flamboyant, Cut Periwinkle, Cut King Protea, Cut Bird Of Paradise, Cut Agapanthus, Cut Gerbera, Cut Pentas, Cut Clivia, Cut Red Hot Poker, Cut Cape Daisy.
- **OC**: staple Taro, Coconut, Pandanus; uncommon Noni, Sago, Kiwi, Warrigal Greens; treasure Kava, Macadamia, Finger Lime; local Coir Fibre, Spiral Shell; flowers Cut Kangaroo Paw, Cut Waratah, Cut Golden Wattle, Cut Kowhai, Cut Pohutukawa, Cut Tagimoucia, Cut Naupaka, Cut Pua Kenikeni, Cut Tiare, Cut Teuila, Cut Heilala, Cut Beach Hibiscus.

### 4.1 Gatherables by landscape (usable in any region; ungated or gated by `@reg`)

(c common, u uncommon, r rare; tool in brackets of the finder, irrelevant for drops.) Use for the ungated/common slots and for land-themed gates.

- **coast**: Sea Salt (c,bucket), Blue Mussels (c,bucket), Bladderwrack (c,bucket), Samphire (u,forage), Urchin Test (u,bucket), Seed Pearl (r,bucket), Spiral Shell (c,bucket), Sea Grapes (c,forage), Driftwood (c,axe), Mangrove Root (u,axe), Sardine (c,rod), Mackerel (u,rod), Moonfish (r,rod).
- **island**: Sea Salt (c,bucket), Urchin Test (u,bucket), Seed Pearl (r,bucket), Spiral Shell (c,bucket), Sea Grapes (c,forage), Coir Fibre (c,forage), Pink Sand (u,bucket), Coral Fragment (r,bucket), Driftwood (c,axe), Palm Trunk (c,axe), Reef Fish (c,rod), Mackerel (u,rod), Moonfish (r,rod).
- **forest**: Chanterelle (c,forage), Ramsons (c,forage), Oak Gall (u,forage), Morel (r,forage), Pine Resin (u,forage), Stag Beetle Shell (u,net), Firefly Glow (r,net), Wild Strawberries (c,forage), Bilberries (c,forage), Fiddleheads (c,forage), Pine Log (c,axe), Birch Log (c,axe), Oak Log (u,axe), Heartwood (r,axe), Perch (c,rod), Trout (u,rod).
- **grassland**: Wild Strawberries (c,forage), Meadowsweet (c,forage), Butterfly Scales (u,net), Cricket Chirp (c,net), Flint (c,pick), River Clay (c,pick), Birch Log (c,axe), Oak Log (u,axe), Minnow (c,rod), Golden Carp (r,rod).
- **desert**: Flint (c,pick), Geode (r,pick), Red Ochre (c,pick), Desert Sage (c,forage), Mesquite Pods (u,forage), Scarab Shell (u,net), Desert Glass (r,pick), Fossil Shell (r,pick), Cork Bark (u,axe).
- **mountain**: Pine Resin (u,forage), Flint (c,pick), Bilberries (c,forage), Edelweiss (r,forage), Slate Shard (c,pick), Rock Crystal (u,pick), Geode (r,pick), Red Ochre (c,pick), Fossil Shell (r,pick), Pine Log (c,axe), Cork Bark (u,axe), Trout (u,rod).
- **rainforest**: Butterfly Scales (u,net), Fiddleheads (c,forage), Rubber Sap (u,forage), Laterite Clay (c,pick), Morpho Scales (r,net), Bromeliad Seeds (u,forage), Palm Trunk (c,axe), Heartwood (r,axe), Rainbow Fish (u,rod).
- **tundra**: Bilberries (c,forage), Sphagnum (c,forage), Crowberries (c,forage), Cottongrass (c,forage), Snow Moth Dust (u,net), Fossil Shell (r,pick), Birch Log (c,axe), Arctic Char (u,rod).
- **wetland**: Ramsons (c,forage), Firefly Glow (r,net), Meadowsweet (c,forage), River Clay (c,pick), Cattail Root (c,forage), Sphagnum (c,forage), Dragonfly Wing (u,net), Bog Iron (r,pick), Cottongrass (c,forage), Samphire (u,forage), Mangrove Root (u,axe), Minnow (c,rod), Perch (c,rod), Rainbow Fish (u,rod), Golden Carp (r,rod).

### 4.2 Item-use notes

- Parts already shared by many rows (ok to reuse with other chances): Sea Glass 7, Pearl 6, Eel Skin 5, Fox Fang 5, Frost Crystal 5, Antler Shard/Frost Fur/Long Feather/Snake Skin/Spotted Pelt/Velvet Pelt/Desert Gem 4. Do not give any variant the base's whole list.
- Non-part items that fit gated slots but sit outside the SPEC KNOWN rule once the lint uses col-1 slugs: all of section 1, all crops and flowers above, `region_locals` slugs, sight 'part' items `Tuft Of Fleece`, `Willow Withies`, `Vine Twine`, `Flamingo Feather` (these four are trail-sight rewards; creatures dropping them would flood a quest item: avoid).
- Rare drops "things a gnome keeps" that already exist: Pearl, Seed Pearl, Coral Fragment, Geode, Rock Crystal, Desert Glass, Bog Iron, Fossil Shell, Morpho Scales, Edelweiss, Morel, Firefly Glow, Golden Carp, Moonfish (gatherable rares, rarity 70, good for 1-3% slots).

## 5. Lint and importer changes this implies (for the lead)

1. KNOWN test = `slugify(name)` in {gatherables col 1, trail_sight_items* col 1, crops col 1, `cut-`+flowers col 1, creatures.txt drop slugs, drop slugs of earlier rows of pf_creatures}; not col 2 (SPEC 5.1 wording).
2. A drop name that slugifies to an existing item but differs in spelling from the safe name (e.g. `Fiddlehead Ferns`) resolves to nothing -> a duplicate 'part' item. Lint: warn when a NEW (col 17) name's slug is `cut-*` or a crop/gatherable slug-title.
3. Importer `creature_drops` gate columns (`reg`, `lvmin`, `lvmax`) and the roll in `win_fight` must test the gate before the luck/spoils-boosted roll; `exp_scene($exp)['region']` gives the fight region (code), `c['level']` the creature level (fight level after scaling: use the value `win_fight` already passes as `$c['level']`).
4. `win_fight` Petals: `give_petals($uid, outlevel_scale(random_int(min,max), $pct) / 2 when peaceful and not full, 'fight')`; put it next to the XP line and add a `+N Petals` fragment to the win log and the `fight_ev` merge (`petals`).
5. NEW part price/rarity uses the variant's own chance and level (`import_creatures_txt` formula), so a 2% rare at L30 gets rarity 72, price 215: no override needed.