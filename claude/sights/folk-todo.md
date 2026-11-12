# Trail Sights: villager points still open

Status: TODO list (2026-11-12). Rows: `game/includes/data/trail_sight_folk.txt` (161 rows on 160 Sights: 46 Maplewold, 72 shared land, all 43 end pieces; one villager point per Sight, 306-dripgrotto has 2). Designs: `claude/sights/ideas-*.md`, `*-p2-todo.md`.
Every name was checked against a fresh install (stop_folk made for every village + npcs). Generic design villagers ("a Shy local") became a real villager of that personality from a region the Sight stands in. The kind or role is changed where none fits (noted below).

## Skipped design points (no row)
- **Pomeroy Crumbworth** (236-haywagon, 311-pancakelane, coast-the-kelp-line, desert-the-salt-flat, rainforest-the-mist-pool, island-the-coconut-grove): he is `active = 0` until the admin turns on `gourmand_open`, and a folk row has no way to check that, so he would turn up while hidden. Needs a `when` word for "Gourmand open" (or the folk code skipping inactive npcs).
- **306-mosslog**: "Nettle Cobblefield of Mossgate". Two Maplewold villagers have that name (Cloverholt herbalist, Mossgate keeper) and `trail_sight_folk_id()` takes the first by id (Cloverholt), so her friendship would go to the wrong Nettle. 306-mossgate uses Posy Mossgrove (Mossgate pilgrim) instead of her. Needs a `name@village` form in the folk file (or renaming one of the Nettles).
- **313-beaverdam**: the Beaver Foreman is a creature, not a villager.
- **314-shellpile**: the sorter is a `hermit-crab-hoarder` creature.
- **314-lanternrocks**: Keeper Marram (new) is a quest giver only (`trail_sight_quests.txt`), not in npcs / stop_folk.
- **desert-the-trader-s-tent-poles**: Old Marrowby (after TRADER) does not exist as a villager.
- **island-the-hammock-palms**: Pinchwell is a crab in a quest letter, not a villager.

## Name twins (rows written; check later)
Posy Thistledown, Moss Sedgemoor, Basil Teaspoon, Fennel Crumblewick, Hazel Nettlebed, Yarrow Mossgrove, Willa Gillyflower, Wick Kettleby, Elm Wickerby, Nettle Cobblefield also live in other regions. `trail_sight_folk_id()` gives the friendship to the lowest stop_folk id. In a fresh install the Maplewold one is first (lowest location ids), but on a site where another region's village made its folk first, the friendship goes to the twin. Fix: prefer the twin of the walk's region, or `name@village`. All shared / end rows use names that are unique.

## Kind / role swaps (no exact villager of that kind on the Sight's routes)
- forest-the-woodcutter-s-stump: "Proud retired woodcutter" -> Linden Honeycomb (Cheerful carpenter, Blossomreach).
- forest-the-lantern-branch: Sleepy "Wick-Keeper" -> Alder Thistledown (Sleepy storyteller, Mistmoor grassland).
- wetland-the-mud-skipper-flats: Eager bookie -> Rook Acorncap (Chatty, Birchbramble).
- wetland-the-dragonfly-bend: Fussy seamstress -> Pip Oakenpot (Fussy weigher, Greatcanopy).
- coast-the-lighthouse-shadow: "the Keeper (new, Generous mole)" -> Basil Burrowby (Sleepy cartographer, Blossomreach coast).
- coast-the-stranded-rowboat: Grumpy old fisher -> Ferrin Pennywhistle (Grumpy cook, Mistmoor; also the Grumpy regular at end-haven-1-tundra).
- coast-the-driftwood-arch: Cheerful -> Ulric Puddlefoot (Eager cook, Olivewhistle).
- desert-the-red-rock-arch: Dreamy -> Ivy Brambleby (Dunewhisper shopkeeper npc).
- end-wonder-1-wetland: Cheerful feather-crafter -> Marigold Gillyflower (Generous, Thornacre).
- end-delve-1-coast: Grumpy retired smuggler -> Fig Windlass (Fussy porter, Mistmoor).
- end-delve-2-island: Generous fisher -> Dew Dewberry (Generous Olivewhistle shopkeeper npc).
- end-lair-1-desert: Proud lair-watcher -> Linden Thistledown (Grumpy scout, Blossomreach).
- end-lair-2-forest / tundra-the-aurora-rise / end-lair-1-island: Dreamy / Sleepy locals -> shopkeeper npcs Tumble Seedwell, Thistle Leafwhisker, Moss Petalwing (no stop villager of that kind in the region).
- end-lair-2-wetland: Eager crab-sitter -> Fig Gillyflower (Generous scout, Sunsprinkle).

## Parts of the designs the folk rows cannot do (rows pay fp + a small goodie instead)
- **Away days / traveller days**: "on away days", "on her Maplewold half-days", "between towns", "every 7th game day" (Bracken), "when she is in the Sunsprinkle Isles" (Lyra): no `when` word for these, so rows use dp/se/we only.
- **Market rest days / festival days** (hedgerow Clover Puddlejump): no condition word.
- **Errands and escorts**: Dorrit Snailwick escort (ford), Clover Brambleby's parcel for Bunty (232-logbridge), Dorrit Thistledown's 3 wheat (236-beanpoles), Bramble's first errand (232-picnicrise), mossy-stair basket.
- **"No roll with them"** (ford hop together, beehive with Mabel, logbridge with a villager): the villager is rolled after a successful use, so they cannot skip the check.
- **Once per week / season / once ever** goodies (Yarrow's stew, Sorrel Rushworth's oak log / plank, Hazel's beeswax, Dorrit Snailwick's toad jewel, Wick-Keeper's lantern): rows use a low chance instead.
- **Choices and takes**: leave a white clover (apple), bring meadowsweet (beehive), give a spiral shell, give desert glass, bring blue mussels, goat cheese for the guide, share food: folk rows never take items.
- **Shop effects**: Tobias's seed without town / 10% off his seed, Alder's punnet swap, Moss Windlass selling sea salt, Bunty's 10% inn voucher, Lyra's half-price song, a shop peek of today's shelf (end-haven-1-grassland), the next market hint.
- **Forecast / hint effects**: Fennick's sale tip, Basil's bee flower (+10% growth), Elm's +20% chanterelle, fish-shoal tip (+1 catch), Lyra coaching next crossing +2, riddle hints, Thornblade tip, hay-ride skip of 10 minutes, the boat-gnome short hop.
- **Almanac**: sign giggle (beehive), Willa's five-part tale, record stone, flag lessons, tide note, Fennick's wish, Lyra's "Grotto Waltz", firefly naming, a named sea-bird, the book recommendation: needs `unlock=` (P3).
- **Two buffs**: rows keep the Sight's own buff and add none where the Sight already pays one (wind-combed meadow, bluebell glade, dune grass, vine bridge, shell-bell tree, dripgrotto Lyra, delve-1-desert songline, haven-2-grassland luck).
- Letters: end-wonder-2-wetland letter from a friend villager (`letters.php` hook).

## New items wished for (none exist; rows use a near item or none)
white clover (apple), map scrap (308-tidesteps), lantern oil refill (314-lanternrocks), room voucher (307-sandcastle), Root-Race Ribbon, The Clover Ledger, Blue-Stitch Hat Patch, Waterfall Sketch, Dare Pebble, Orchid Cutting (-> `cut-moth-orchid`), Fir Ornament, Flamingo Feather (-> `pretty-feather`), Lucky Wick (-> `beeswax-candles`), rope-cattail (-> `rope`), custard tart slice is real (`custard-tart`).
