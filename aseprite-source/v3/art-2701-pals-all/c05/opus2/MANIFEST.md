# Puzzle Pals batch c05, Opus second pass (art-2701-pals-all/c05/opus2)

Worklist index 5 of `../../worklist.json`. Same 8 pals, keys, callings and concepts as the Haiku first pass in
`../haiku/`; every sprite is redrawn. Yard 64x64 uses `c:eyeLocked`; perch 36x36 is hand-built at its size with
`c:eyeSmall` pills (pale sockets added where the fur or face is too dark or too light for the pill to read).
`_opus.lua` is a copy of the tools in `art-2701-batch3/pals/opus3/_opus.lua` (shade / rim / bounce / tex), no pal art.
`HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white); 1 px ink outline inside the canvas on all.
Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua` (same for `-perch`).

| key | design | fixed vs Haiku | quirk (one) |
|---|---|---|---|
| th-coffee-crumb | glossy roasted bean with an S-crease, oversized dusk-purple fedora with red band, brim shadow on the brow; holds a roasting paddle with two beans (yard) | bean read (crease, gloss), fedora shape instead of a box, 6-tone ramps | roasting steam wisps rising from the crown dent (un-outlined) |
| th-flamingo-flick | flamingo on one leg in a waterhole with ripple rings, other leg folded under, S-neck, head facing you, bent plum-tipped beak | wing no longer a fin; real S-neck and beak; waterhole instead of a bar | near wing flung up, dark primaries fanned like beckoning fingers (the dare) |
| th-termite-tower | knobbly red laterite mound with two shoulder chimneys, grain courses, vents, smug face and one-sided smirk | no longer a traffic cone | a pale termite on the spire's shoulder heaving one red grain up |
| th-acacia-antler | olive leaflet-textured bush ball with leaf ears, bark nose and legs; branching thorny twig antlers | antlers branch and carry thorns; nests are woven pouches hanging on fibres with spouts | a yellow weaver bird peeking out of one nest |
| th-kopje-keeper | warm pink-ochre granite boulder with a smaller boulder balanced on top, pebble at the foot, exfoliation curves, lichen, dry grass, thorn sprig; wide unblinking eyes under a ledge | was one cool-grey blob with 10 colours; now a kopje stack, warm 6-tone granite | blue-and-orange agama lizard sunning on the top boulder |
| th-tall-tiptoe | young giraffe on tiptoe: Voronoi patch coat, mane, ossicones with tufts, side ears, pale muzzle, tan eye sockets | three blot spots -> patch net; leaf no longer jammed on the head | long purple tongue curling up to hook the top acacia leaves (+ rare sparkle) |
| sp-saffron-snip | round saffron-gold sprite with a three-petal lilac crocus cap and three crimson threads; humming "o" mouth | grey X now reads as scissors (brass loops, steel blades, rivet); threads come from a crocus | the hum: a plum music note floating at the left |
| sp-yak-yonder | shaggy dark yak heading left, jagged fringe skirt, cream forelock, pale horns; striped red/teal/gold blanket, two rope-tied burlap bundles | no longer a cow with a purple box | orange pennant on a pole in the load, streaming forward (yonder) |

Weakest: termite-tower perch (shoulder chimneys make the outline read a little like a crown); kopje-keeper and
saffron-snip perch quirks (lizard, scissors) are small at 1x; saffron-snip crocus cap can read as a purple crown
rather than petals; acacia-antler perch nests sit 2 px from the canvas edge.
