# Art notes: set pieces for the routes outside the Maplewold

Generated from `claude/trail-landmarks/setpieces.json` (made by `python3 tools/gen_trail_maps.py`). **137** shared set pieces; each is one raised sprite, `game/assets/img/trail/obj/lm-<slug>.png`, drawn by `claude/tile-art-v3-proposal/landmarks_<name>.py` like the Maplewold ones.

Today every one is a **stand-in** (`landmarks_setpieces.py`: lumps and a flag post sized by name). To replace one, draw it in a new `landmarks_<name>.py` under the same slug and delete that slug from the stand-in file (gen2 asserts a name is defined once), then re-bake with `--route=N` for its routes.

## House rules (same as the Maplewold landmarks, see `maplewold_landmarks.json`)
- Any size, drawn at 64 px a tile; centred on its tile, **bottom edge is the feet line**. The sprite hides the walker if the walker stands behind it, so it sits **off the walk line** (the generator keeps it at least 1 tile from the path, feet row 3 to 5).
- Hearth Pop v3 look: hard pixels, 5-tone ramps, auto outline, warm and a bit silly, nothing grim. Wide pieces about 130 to 190 px, tall ones up to ~190 px; the end pieces (`end-*`) are the biggest (~200 x 190) because they announce the place.
- The ground under it is already baked with a soft contact shadow and a worn path. Do not paint the path.
- The ground art for desert, island, mountain, rainforest and wetland is still a **stand-in land** (coast, coast, tundra, forest, forest), so draw set pieces to read on that ground, or tell the land art pass first.

## Summary

| Land | Set pieces | Routes using them (sections) | Art ground now |
|---|---|---|---|
| coast | 18 | 90 | coast |
| forest | 17 | 58 | forest |
| desert | 17 | 64 | coast |
| grassland | 16 | 130 | grassland |
| mountain | 16 | 89 | tundra |
| wetland | 15 | 64 | forest |
| rainforest | 15 | 67 | forest |
| island | 15 | 51 | coast |
| tundra | 8 | 11 | tundra |

## Coast  (18; ground art: coast)

- **`coast-the-barnacle-wall`**: the barnacle wall. _A rock wall crusted with barnacles. Please do not tickle them._  Stand-in 149x63. Used 8x (routes 257, 303, 462, 272, 409, 299 ...).
- **`coast-the-bottle-post`**: the bottle post. _A post with a bottle on top. There is a note inside. It says 'hello'._  Stand-in 137x62. Used 12x (routes 446, 258, 264, 302, 471, 397 ...).
- **`coast-the-driftwood-arch`**: the driftwood arch. _A bleached arch of driftwood, hung with shells that click in the wind._  Stand-in 189x77. Used 7x (routes 258, 259, 264, 266, 410, 298 ...).
- **`coast-the-dune-grass-sweep`**: the dune grass sweep. _Tall dune grass bows all one way, like an audience._  Stand-in 138x69. Used 3x (routes 257, 259, 267).
- **`coast-the-kelp-line`**: the kelp-line. _A line of kelp left by the tide, as neat as a ribbon._  Stand-in 185x74. Used 9x (routes 439, 355, 265, 302, 303, 471 ...).
- **`coast-the-lighthouse-shadow`**: the lighthouse shadow. _A far lighthouse throws a slow sweep of light over the sand._  Stand-in 151x66. Used 9x (routes 439, 440, 446, 355, 264, 372 ...).
- **`coast-the-rope-and-net-rack`**: the rope-and-net rack. _Nets drying on a rack. A gull stands guard, badly._  Stand-in 152x77. Used 7x (routes 440, 362, 258, 259, 303, 470 ...).
- **`coast-the-sandbar-causeway`**: the sandbar causeway. _A narrow bar of sand with water either side, sparkling._  Stand-in 189x71. Used 4x (routes 257, 298, 329, 330).
- **`coast-the-sea-stack-gap`**: the sea-stack gap. _A gap between two tall rocks where the spray tickles your ankles._  Stand-in 151x75. Used 7x (routes 373, 265, 302, 461, 470, 267 ...).
- **`coast-the-shell-heap`**: the shell-heap. _A mound of shells, sorted by someone with strong feelings about spirals._  Stand-in 137x75. Used 7x (routes 461, 266, 272, 409, 298, 299 ...).
- **`coast-the-stranded-rowboat`**: the stranded rowboat. _A rowboat on the sand, waiting for the sea to come back and apologise._  Stand-in 160x75. Used 1x (routes 356).
- **`coast-the-tide-pool-steps`**: the tide-pool steps. _Flat rocks full of small pools, each with a crab who has opinions._  Stand-in 188x66. Used 6x (routes 356, 362, 462, 267, 329, 330).
- **`end-delve-1-coast`**: the way into a delve: the mine mouth of <the place>. _The mouth of <the place> breathes cool air and a hint of old echoes._  Stand-in 200x117. Used 1x (routes 362).
- **`end-haven-1-coast`**: the way into a haven: the <the place> path. _A smell of something warm drifts down the path from <the place>._  Stand-in 200x117. Used 1x (routes 397).
- **`end-haven-2-coast`**: the way into a haven: the last turn to <the place>. _A little sign, hand-painted: 'Rest Here'._  Stand-in 200x117. Used 3x (routes 372, 373, 337).
- **`end-lair-2-coast`**: the way into a lair: the threshold of <the place>. _A wide, scuffed circle of earth. The kind of place a very large friend might sleep._  Stand-in 200x117. Used 1x (routes 471).
- **`end-wonder-1-coast`**: the way into a wonder: the <the place> gates. _Something wonderful is close. You can feel it in your shoes._  Stand-in 200x117. Used 2x (routes 470, 456).
- **`end-wonder-2-coast`**: the way into a wonder: the hush before <the place>. _The air goes quiet, as if <the place> were about to speak._  Stand-in 200x117. Used 2x (routes 446, 336).

## Desert  (17; ground art: coast)

- **`desert-the-cactus-garden`**: the cactus garden. _Cactus in a neat row. Somebody waters them. Somebody is brave._  Stand-in 168x68. Used 5x (routes 320, 395, 400, 401, 420).
- **`desert-the-dry-riverbed`**: the dry riverbed. _A river that left years ago and kept the bed made._  Stand-in 166x68. Used 5x (routes 448, 467, 473, 396, 402).
- **`desert-the-mirage-pool`**: the mirage pool. _A pool that is mostly shimmer, and a little bit not._  Stand-in 168x68. Used 7x (routes 319, 473, 395, 401, 345, 352 ...).
- **`desert-the-red-rock-arch`**: the red rock arch. _A rock arch that glows when the sun is low._  Stand-in 179x69. Used 2x (routes 447, 401).
- **`desert-the-salt-flat`**: the salt flat. _A flat of white salt that crunches pleasantly._  Stand-in 175x71. Used 4x (routes 441, 442, 448, 394).
- **`desert-the-sand-ripple-lane`**: the sand-ripple lane. _Sand rippled like a washboard in neat lines._  Stand-in 154x63. Used 7x (routes 447, 466, 473, 396, 400, 402 ...).
- **`desert-the-shade-awning`**: the shade awning. _A faded awning on two poles. Perfect for a very small nap._  Stand-in 188x73. Used 4x (routes 442, 326, 465, 400).
- **`desert-the-sun-bleached-bones`**: the sun-bleached bones. _The bones of a very large, very friendly fish. Do not ask._  Stand-in 189x64. Used 7x (routes 441, 447, 448, 402, 345, 421 ...).
- **`desert-the-trader-s-tent-poles`**: the trader's tent poles. _Poles from a trader's tent, left up in case they return._  Stand-in 172x67. Used 4x (routes 326, 465, 394, 346).
- **`desert-the-waystone-cluster`**: the waystone cluster. _Three weathered waystones leaning together like old friends._  Stand-in 143x64. Used 7x (routes 448, 319, 320, 466, 346, 421 ...).
- **`desert-the-well-and-its-rope`**: the well and its rope. _A well with a rope and a very patient bucket._  Stand-in 172x79. Used 3x (routes 467, 402, 352).
- **`end-delve-1-desert`**: the way into a delve: the mine mouth of <the place>. _The mouth of <the place> breathes cool air and a hint of old echoes._  Stand-in 200x117. Used 2x (routes 473, 427).
- **`end-delve-2-desert`**: the way into a delve: the lantern line to <the place>. _A line of old lanterns leads to <the place>. Please bring your own light._  Stand-in 200x117. Used 2x (routes 447, 401).
- **`end-lair-1-desert`**: the way into a lair: the long approach to <the place>. _The grass goes silent. Something big is thinking about you from <the place>._  Stand-in 200x116. Used 1x (routes 448).
- **`end-lair-2-desert`**: the way into a lair: the threshold of <the place>. _A wide, scuffed circle of earth. The kind of place a very large friend might sleep._  Stand-in 200x117. Used 1x (routes 402).
- **`end-wonder-1-desert`**: the way into a wonder: the <the place> gates. _Something wonderful is close. You can feel it in your shoes._  Stand-in 200x117. Used 1x (routes 352).
- **`end-wonder-2-desert`**: the way into a wonder: the hush before <the place>. _The air goes quiet, as if <the place> were about to speak._  Stand-in 200x117. Used 2x (routes 326, 400).

## Forest  (17; ground art: forest)

- **`forest-the-acorn-scatter`**: the acorn scatter. _Acorns everywhere, as though a squirrel had a very bad day._  Stand-in 153x80. Used 3x (routes 386, 428, 435).
- **`forest-the-bluebell-glade`**: the bluebell glade. _A glade of bluebells that seems to ring if you listen closely._  Stand-in 169x63. Used 3x (routes 353, 292, 472).
- **`forest-the-fallen-log-bridge`**: the fallen-log bridge. _A great log laid across a gully. It wobbles, but only out of politeness._  Stand-in 132x75. Used 2x (routes 260, 354).
- **`forest-the-fern-tunnel`**: the fern tunnel. _Ferns arch overhead and drip softly on everyone's hat._  Stand-in 144x80. Used 4x (routes 386, 438, 445, 435).
- **`forest-the-glow-moss-grotto`**: the glow-moss grotto. _A damp hollow with moss that glows faintly, like a night-light._  Stand-in 146x76. Used 5x (routes 380, 444, 445, 428, 434).
- **`forest-the-hollow-oak`**: the hollow oak. _An oak so hollow it could host tea for six._  Stand-in 140x76. Used 3x (routes 387, 291, 361).
- **`forest-the-lantern-branch`**: the lantern branch. _An old lantern hangs from a branch. Somebody trims its wick._  Stand-in 182x74. Used 6x (routes 378, 260, 354, 292, 434, 463).
- **`forest-the-mossy-stair`**: the mossy stair. _Steps of root and moss, worn smooth by many small boots._  Stand-in 186x62. Used 2x (routes 296, 361).
- **`forest-the-mushroom-ring`**: the mushroom ring. _Toadstools in a tidy ring. The path goes round, because the path is sensible._  Stand-in 143x71. Used 6x (routes 290, 291, 438, 444, 353, 472).
- **`forest-the-owl-watch-bough`**: the owl-watch bough. _A low bough where an owl pretends not to see you._  Stand-in 172x69. Used 5x (routes 379, 380, 387, 290, 464).
- **`forest-the-root-tangle-crossing`**: the root-tangle crossing. _Roots knot across the path like a puzzle with one answer: step high._  Stand-in 133x66. Used 6x (routes 378, 291, 260, 292, 435, 464).
- **`forest-the-spring-and-the-pebbles`**: the spring and the pebbles. _A trickle of spring water over bright pebbles._  Stand-in 175x74. Used 3x (routes 379, 290, 296).
- **`forest-the-woodcutter-s-stump`**: the woodcutter's stump. _A giant stump, still carrying a very small axe._  Stand-in 164x77. Used 2x (routes 296, 463).
- **`end-delve-2-forest`**: the way into a delve: the lantern line to <the place>. _A line of old lanterns leads to <the place>. Please bring your own light._  Stand-in 200x117. Used 1x (routes 387).
- **`end-lair-2-forest`**: the way into a lair: the threshold of <the place>. _A wide, scuffed circle of earth. The kind of place a very large friend might sleep._  Stand-in 200x117. Used 1x (routes 435).
- **`end-wonder-1-forest`**: the way into a wonder: the <the place> gates. _Something wonderful is close. You can feel it in your shoes._  Stand-in 200x117. Used 1x (routes 386).
- **`end-wonder-2-forest`**: the way into a wonder: the hush before <the place>. _The air goes quiet, as if <the place> were about to speak._  Stand-in 200x117. Used 5x (routes 444, 445, 361, 434, 472).

## Grassland  (16; ground art: grassland)

- **`grassland-the-bramble-gap`**: the bramble gap. _A gap in the brambles, wide enough for one gnome and one opinion._  Stand-in 138x66. Used 10x (routes 262, 263, 268, 238, 256, 276 ...).
- **`grassland-the-clover-patch`**: the clover patch. _A clover patch. Someone has already checked every leaf for luck._  Stand-in 159x65. Used 8x (routes 238, 239, 240, 278, 279, 288 ...).
- **`grassland-the-daisy-ring`**: the daisy ring. _A circle of daisies so even that someone must have measured. Nobody will own up._  Stand-in 175x68. Used 10x (routes 385, 443, 230, 275, 280, 281 ...).
- **`grassland-the-dandelion-drift`**: the dandelion drift. _A drift of dandelion fluff, ready to leave at the first sneeze._  Stand-in 164x77. Used 9x (routes 268, 231, 261, 289, 276, 275 ...).
- **`grassland-the-hay-cart-ruts`**: the hay-cart ruts. _Two deep ruts from a cart that has long since gone home._  Stand-in 152x79. Used 9x (routes 235, 279, 287, 433, 289, 391 ...).
- **`grassland-the-lonely-scarecrow`**: the lonely scarecrow. _A scarecrow with a very small hat. The crows seem to like him._  Stand-in 172x63. Used 10x (routes 239, 240, 288, 390, 273, 274 ...).
- **`grassland-the-old-milestone`**: the old milestone. _A mossy milestone with the numbers worn off. It still points confidently._  Stand-in 166x80. Used 10x (routes 239, 231, 245, 235, 278, 287 ...).
- **`grassland-the-picnic-knoll`**: the picnic knoll. _A flat green knoll with a dent in it exactly the shape of a picnic._  Stand-in 153x70. Used 18x (routes 262, 238, 231, 323, 245, 234 ...).
- **`grassland-the-plank-footbridge`**: the plank footbridge. _A plank bridge over a ditch. The ditch is not deep, but the bridge is proud._  Stand-in 188x76. Used 9x (routes 262, 230, 234, 256, 360, 273 ...).
- **`grassland-the-shepherd-s-wall`**: the shepherd's wall. _A dry-stone wall running off into the grass, with a gate that is mostly decoration._  Stand-in 167x67. Used 10x (routes 263, 240, 234, 359, 278, 433 ...).
- **`grassland-the-sleepy-windmill`**: the sleepy windmill. _A little windmill turning slowly, in no hurry at all._  Stand-in 151x74. Used 9x (routes 268, 230, 235, 261, 287, 390 ...).
- **`grassland-the-wind-combed-meadow`**: the wind-combed meadow. _Grass lying down in one direction, as if told to. A kite string trails over the path._  Stand-in 152x68. Used 7x (routes 263, 245, 279, 288, 282, 283 ...).
- **`end-haven-1-grassland`**: the way into a haven: the <the place> path. _A smell of something warm drifts down the path from <the place>._  Stand-in 200x117. Used 2x (routes 385, 359).
- **`end-haven-2-grassland`**: the way into a haven: the last turn to <the place>. _A little sign, hand-painted: 'Rest Here'._  Stand-in 200x117. Used 5x (routes 443, 323, 411, 347, 422).
- **`end-wonder-1-grassland`**: the way into a wonder: the <the place> gates. _Something wonderful is close. You can feel it in your shoes._  Stand-in 200x117. Used 2x (routes 360, 398).
- **`end-wonder-2-grassland`**: the way into a wonder: the hush before <the place>. _The air goes quiet, as if <the place> were about to speak._  Stand-in 200x117. Used 2x (routes 433, 423).

## Island  (15; ground art: coast)

- **`island-the-coconut-grove`**: the coconut grove. _A grove of coconuts, each one trying to look innocent._  Stand-in 169x71. Used 3x (routes 254, 301, 243).
- **`island-the-hammock-palms`**: the hammock palms. _Two palms with a hammock. It has already been claimed by a crab._  Stand-in 138x68. Used 5x (routes 241, 254, 457, 458, 335).
- **`island-the-lagoon-edge`**: the lagoon edge. _A lagoon as clear as glass, with tiny striped fish._  Stand-in 135x71. Used 4x (routes 468, 253, 242, 248).
- **`island-the-palm-lean`**: the palm lean. _A palm tree that leans so far it has to be holding something._  Stand-in 146x65. Used 5x (routes 376, 255, 458, 243, 248).
- **`island-the-reef-shallows`**: the reef shallows. _Warm shallows full of brightly coloured fish._  Stand-in 175x74. Used 7x (routes 375, 255, 450, 457, 301, 253 ...).
- **`island-the-rope-swing`**: the rope swing. _A rope swing over a deep blue pool. It is begging to be used._  Stand-in 146x74. Used 4x (routes 369, 375, 255, 243).
- **`island-the-sand-spit`**: the sand spit. _A spit of white sand reaching out like a pointing finger._  Stand-in 146x70. Used 4x (routes 368, 254, 451, 242).
- **`island-the-shell-bell-tree`**: the shell-bell tree. _A tree hung with shells that chime like bells._  Stand-in 180x70. Used 5x (routes 241, 368, 451, 301, 253).
- **`island-the-tide-cave`**: the tide-cave. _A small cave that breathes in and out with the tide._  Stand-in 173x76. Used 7x (routes 241, 369, 376, 469, 450, 458 ...).
- **`end-delve-2-island`**: the way into a delve: the lantern line to <the place>. _A line of old lanterns leads to <the place>. Please bring your own light._  Stand-in 200x117. Used 1x (routes 376).
- **`end-haven-1-island`**: the way into a haven: the <the place> path. _A smell of something warm drifts down the path from <the place>._  Stand-in 200x117. Used 1x (routes 468).
- **`end-haven-2-island`**: the way into a haven: the last turn to <the place>. _A little sign, hand-painted: 'Rest Here'._  Stand-in 200x117. Used 1x (routes 335).
- **`end-lair-1-island`**: the way into a lair: the long approach to <the place>. _The grass goes silent. Something big is thinking about you from <the place>._  Stand-in 200x117. Used 1x (routes 458).
- **`end-wonder-1-island`**: the way into a wonder: the <the place> gates. _Something wonderful is close. You can feel it in your shoes._  Stand-in 200x117. Used 1x (routes 375).
- **`end-wonder-2-island`**: the way into a wonder: the hush before <the place>. _The air goes quiet, as if <the place> were about to speak._  Stand-in 200x116. Used 2x (routes 469, 457).

## Mountain  (16; ground art: tundra)

- **`mountain-the-cairn-pass`**: the cairn pass. _A pass marked with cairns, each taller than the last._  Stand-in 169x79. Used 7x (routes 366, 374, 430, 437, 399, 285 ...).
- **`mountain-the-eagle-s-rest`**: the eagle's rest. _A flat boulder where an eagle likes to think._  Stand-in 179x80. Used 7x (routes 321, 327, 365, 367, 377, 437 ...).
- **`mountain-the-echo-wall`**: the echo wall. _A rock wall that gives your own voice back, only cheekier._  Stand-in 184x73. Used 8x (routes 322, 430, 393, 251, 348, 349 ...).
- **`mountain-the-goat-ledge`**: the goat ledge. _A ledge with a goat. The goat is entirely unbothered._  Stand-in 159x61. Used 11x (routes 384, 389, 327, 367, 370, 431 ...).
- **`mountain-the-pine-shelf`**: the pine shelf. _A shelf of pines clinging to a cliff for dear life._  Stand-in 146x67. Used 8x (routes 383, 370, 374, 377, 399, 252 ...).
- **`mountain-the-rope-bridge`**: the rope bridge. _A rope bridge, sturdy for its age and fond of swaying._  Stand-in 145x76. Used 9x (routes 389, 366, 371, 392, 250, 341 ...).
- **`mountain-the-scree-slope`**: the scree slope. _A slope of loose small stones that tick and chatter underfoot._  Stand-in 179x79. Used 4x (routes 383, 365, 429, 436).
- **`mountain-the-stone-hut`**: the stone hut. _A little stone hut with a chimney and no one at home._  Stand-in 185x65. Used 8x (routes 321, 322, 371, 431, 436, 437 ...).
- **`mountain-the-switchback-bend`**: the switchback bend. _A tight bend in the path, with a view of the way you just came._  Stand-in 162x80. Used 7x (routes 327, 377, 250, 251, 252, 349 ...).
- **`mountain-the-waterfall-mist`**: the waterfall mist. _A waterfall mists the path with tiny rainbows._  Stand-in 152x61. Used 2x (routes 389, 429).
- **`mountain-the-wind-notch`**: the wind notch. _A notch in the ridge where the wind plays whatever it likes._  Stand-in 150x75. Used 7x (routes 384, 389, 327, 377, 436, 424 ...).
- **`end-delve-1-mountain`**: the way into a delve: the mine mouth of <the place>. _The mouth of <the place> breathes cool air and a hint of old echoes._  Stand-in 200x117. Used 1x (routes 437).
- **`end-lair-1-mountain`**: the way into a lair: the long approach to <the place>. _The grass goes silent. Something big is thinking about you from <the place>._  Stand-in 200x117. Used 2x (routes 389, 327).
- **`end-lair-2-mountain`**: the way into a lair: the threshold of <the place>. _A wide, scuffed circle of earth. The kind of place a very large friend might sleep._  Stand-in 200x117. Used 3x (routes 377, 349, 425).
- **`end-wonder-1-mountain`**: the way into a wonder: the <the place> gates. _Something wonderful is close. You can feel it in your shoes._  Stand-in 200x117. Used 2x (routes 374, 348).
- **`end-wonder-2-mountain`**: the way into a wonder: the hush before <the place>. _The air goes quiet, as if <the place> were about to speak._  Stand-in 200x117. Used 3x (routes 436, 399, 424).

## Rainforest  (15; ground art: forest)

- **`rainforest-the-canopy-gap`**: the canopy gap. _A gap in the canopy where the sun comes down in a column._  Stand-in 142x75. Used 4x (routes 317, 324, 408, 460).
- **`rainforest-the-fallen-giant`**: the fallen giant. _A fallen tree, so big the path goes along its trunk._  Stand-in 183x80. Used 4x (routes 406, 413, 414, 343).
- **`rainforest-the-giant-fern-glade`**: the giant fern glade. _Ferns taller than a gnome, nodding in the drip._  Stand-in 163x76. Used 7x (routes 244, 325, 413, 414, 459, 344 ...).
- **`rainforest-the-lantern-fruit`**: the lantern fruit. _Small glowing fruits hang low, just to be friendly._  Stand-in 160x66. Used 2x (routes 408, 338).
- **`rainforest-the-mist-pool`**: the mist-pool. _A still pool with mist curling over it like steam from soup._  Stand-in 185x72. Used 3x (routes 453, 350, 351).
- **`rainforest-the-orchid-tree`**: the orchid tree. _A tree dressed head to toe in orchids._  Stand-in 131x72. Used 7x (routes 244, 318, 414, 415, 459, 460 ...).
- **`rainforest-the-parrot-perch`**: the parrot perch. _A tall branch where parrots argue in three languages._  Stand-in 182x69. Used 8x (routes 317, 452, 453, 454, 342, 350 ...).
- **`rainforest-the-rain-drum-leaf`**: the rain-drum leaf. _A huge leaf that drums when it rains. It is raining a little._  Stand-in 185x69. Used 8x (routes 406, 407, 415, 454, 460, 350 ...).
- **`rainforest-the-stepping-roots`**: the stepping-roots. _Roots arching out of the mud like a row of green stairs._  Stand-in 151x72. Used 4x (routes 244, 325, 407, 415).
- **`rainforest-the-vine-bridge`**: the vine bridge. _A bridge of woven vines that hums when the wind comes through._  Stand-in 131x79. Used 10x (routes 318, 324, 413, 415, 452, 459 ...).
- **`end-delve-1-rainforest`**: the way into a delve: the mine mouth of <the place>. _The mouth of <the place> breathes cool air and a hint of old echoes._  Stand-in 200x117. Used 2x (routes 414, 351).
- **`end-delve-2-rainforest`**: the way into a delve: the lantern line to <the place>. _A line of old lanterns leads to <the place>. Please bring your own light._  Stand-in 200x117. Used 2x (routes 325, 460).
- **`end-lair-2-rainforest`**: the way into a lair: the threshold of <the place>. _A wide, scuffed circle of earth. The kind of place a very large friend might sleep._  Stand-in 200x117. Used 1x (routes 415).
- **`end-wonder-1-rainforest`**: the way into a wonder: the <the place> gates. _Something wonderful is close. You can feel it in your shoes._  Stand-in 200x117. Used 3x (routes 324, 459, 338).
- **`end-wonder-2-rainforest`**: the way into a wonder: the hush before <the place>. _The air goes quiet, as if <the place> were about to speak._  Stand-in 200x117. Used 2x (routes 413, 350).

## Tundra  (8; ground art: tundra)

- **`tundra-the-aurora-rise`**: the aurora rise. _A low rise where the sky does green things at night._  Stand-in 140x63. Used 3x (routes 358, 363, 364).
- **`tundra-the-frozen-stream`**: the frozen stream. _A frozen stream, bright as a window._  Stand-in 144x79. Used 1x (routes 363).
- **`tundra-the-ice-shelf-steps`**: the ice-shelf steps. _Steps of pale ice that squeak under each boot._  Stand-in 182x75. Used 1x (routes 363).
- **`tundra-the-lone-fir`**: the lone fir. _One fir tree wearing a good deal of snow._  Stand-in 177x70. Used 1x (routes 357).
- **`tundra-the-snow-fort`**: the snow-fort. _A snow fort with a flag. It has seen better battles, and better snacks._  Stand-in 160x66. Used 2x (routes 357, 358).
- **`tundra-the-star-chart-stones`**: the star-chart stones. _Flat stones scratched with constellations by patient hands._  Stand-in 154x70. Used 1x (routes 363).
- **`end-haven-1-tundra`**: the way into a haven: the <the place> path. _A smell of something warm drifts down the path from <the place>._  Stand-in 200x117. Used 1x (routes 364).
- **`end-lair-2-tundra`**: the way into a lair: the threshold of <the place>. _A wide, scuffed circle of earth. The kind of place a very large friend might sleep._  Stand-in 200x117. Used 1x (routes 363).

## Wetland  (15; ground art: forest)

- **`wetland-the-boardwalk-gap`**: the boardwalk gap. _A boardwalk with one plank missing. A neat little hop._  Stand-in 165x80. Used 5x (routes 269, 271, 293, 294, 339).
- **`wetland-the-dragonfly-bend`**: the dragonfly bend. _A bend where dragonflies stitch the air with blue._  Stand-in 151x79. Used 4x (routes 297, 277, 405, 340).
- **`wetland-the-frog-choir`**: the frog choir. _A bank of frogs rehearsing something important._  Stand-in 145x63. Used 6x (routes 388, 297, 271, 293, 334, 419).
- **`wetland-the-heron-s-post`**: the heron's post. _A post where a heron stands as if on a stage._  Stand-in 141x79. Used 7x (routes 271, 404, 412, 295, 333, 339 ...).
- **`wetland-the-lily-pad-ford`**: the lily-pad ford. _Lily pads big enough to stand on. Almost._  Stand-in 171x76. Used 5x (routes 297, 294, 295, 340, 418).
- **`wetland-the-mud-skipper-flats`**: the mud-skipper flats. _Wet flats with small skippers who race for no reason._  Stand-in 140x74. Used 3x (routes 381, 293, 333).
- **`wetland-the-peat-bank`**: the peat bank. _A soft brown bank that smells of rain and old books._  Stand-in 163x77. Used 6x (routes 382, 269, 432, 277, 403, 294).
- **`wetland-the-reed-causeway`**: the reed causeway. _A narrow causeway through tall reeds, nodding hello._  Stand-in 172x71. Used 5x (routes 270, 404, 412, 340, 426).
- **`wetland-the-stilt-house`**: the stilt-house. _A house on stilts, with a ladder that has gone for a walk._  Stand-in 176x64. Used 5x (routes 381, 270, 295, 419, 426).
- **`wetland-the-willow-curtain`**: the willow curtain. _Willow branches drape the path like a gentle curtain._  Stand-in 188x75. Used 11x (routes 382, 388, 269, 270, 277, 403 ...).
- **`end-delve-2-wetland`**: the way into a delve: the lantern line to <the place>. _A line of old lanterns leads to <the place>. Please bring your own light._  Stand-in 200x117. Used 1x (routes 339).
- **`end-haven-1-wetland`**: the way into a haven: the <the place> path. _A smell of something warm drifts down the path from <the place>._  Stand-in 200x117. Used 2x (routes 432, 455).
- **`end-lair-2-wetland`**: the way into a lair: the threshold of <the place>. _A wide, scuffed circle of earth. The kind of place a very large friend might sleep._  Stand-in 200x117. Used 1x (routes 340).
- **`end-wonder-1-wetland`**: the way into a wonder: the <the place> gates. _Something wonderful is close. You can feel it in your shoes._  Stand-in 200x117. Used 1x (routes 426).
- **`end-wonder-2-wetland`**: the way into a wonder: the hush before <the place>. _The air goes quiet, as if <the place> were about to speak._  Stand-in 200x117. Used 2x (routes 388, 412).
