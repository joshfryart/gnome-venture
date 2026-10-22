# Trek pixel: drawing families

46 assets, 6 families, one Opus drawing pass per family (or per sheet for family 4). Specs are in `specs\<name>.md`; colours in `palette.md`; run `check.py` after each family. Output: `png\<name>.png` + `aseprite\<name>.aseprite`, Lua scripts in `scripts\`.

## Draw order (edge-matching bases come first)
1. Family 1, then family 2 (they fix every ring colour). 2. Family 3 opaque tiles. 3. Family 4 (needs the rings). 4. Family 3 ripples (need water-auto). 5. Family 5. 6. Family 6.

## Rules baked into every spec
- Stitched Toy hard pixels: no anti-aliasing, no blends, no dither, no gradients. Alpha is 0 or 255 only.
- Palette: only colours from `palette.md`. No pure black `#000000`, no pure white `#ffffff`.
- One light from the upper left. Shade (1-2 px, lower-right) ONLY on objects inside the tile. No whole-tile crescent.
- NO halo, NO black border, no sticker outline. Umber outline only on raised objects (crystal, planks, stones, markers, wall masses).
- Gold thread stitch (2 on / 1 off) only at real joins.
- No flip or rotate reuse: every asset and every variant is drawn separately; recolouring another asset is not allowed.
- Ground tiles are full-bleed, opaque and seamless: outer 3 px ring = the terrain's base colour; details at least 3 px from the edges unless designed to cross; variants of one terrain swap with no seam.
- Keep the map-key meaning: ripples = high water, two dots = wet clay, cracks = loose clay, diamond = crystal, tuft = roots, dots = mud/blight.
- Read at 42, 35 and 21 px (the contact sheet shows all three).

## Auto-join sheets (family 4)
Sheet layout (84x126 = 4 columns x 6 rows of 21x21 quarters, RPG-Maker A2 style). (qx,qy) = quarter column,row; pixel origin = (21*qx, 21*qy).
| qy \ qx | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| 0 | iso TL corner | iso TR corner | inner-corner TL | inner-corner TR |
| 1 | iso BL corner | iso BR corner | inner-corner BL | inner-corner BR |
| 2 | corner TL | top edge (TL quadrant) | top edge (TR quadrant) | corner TR |
| 3 | left edge (TL quadrant) | interior TL | interior TR | right edge (TR quadrant) |
| 4 | left edge (BL quadrant) | interior BL | interior BR | right edge (BR quadrant) |
| 5 | corner BL | bottom edge (BL quadrant) | bottom edge (BR quadrant) | corner BR |
The 47 tiles are composed from four quarters, one per quadrant, chosen by the 8 neighbours (mass = same kind present):
- quadrant needs N and W mass: if the diagonal is mass use interior, else the inner-corner quarter.
- exactly one of N, W is mass: the edge quarter on the empty side (N empty = top edge, W empty = left edge, etc.).
- neither: the outer corner quarter.
- Quadrant neighbours: TL = N,W,NW; TR = N,E,NE; BL = S,W,SW; BR = S,E,SE.
- Iso quarters (0,0),(1,0),(0,1),(1,1) are pixel copies of the sheet's own corner quarters (0,2),(3,2),(0,5),(3,5). Draw the corners first and copy them with the same pixels (copy, not flip or rotate).
Apron and outline geometry (tile pixels; d = distance in px from the tile border on an EMPTY side):
- d 0-2: APRON, the ground ring colour, pure, so it joins a plain ground tile at the quarter lines 0, 21, 42.
- d 3: outline 1 px (raised mass): N edge umber1, W umber2, E umber2, S umber3.
- d 4: N/W edges: lit rim 1 px; S/E edges: bounce 1 px; d 5-6 on S/E edges: shade 2 px. Then the base.
- Outer corner: rounded, 1 px outline following the arc, outside the arc inside the 3..9 box = apron colour. Arc pixels, TL: (9,3)(8,3)(7,4)(6,4)(5,5)(4,6)(4,7)(3,8)(3,9). TR: (32,3)(33,3)(34,4)(35,4)(36,5)(37,6)(37,7)(38,8)(38,9). BL: (9,38)(8,38)(7,37)(6,37)(5,36)(4,35)(4,34)(3,33)(3,32). BR: (32,38)(33,38)(34,37)(35,37)(36,36)(37,35)(37,34)(38,33)(38,32).
- Inner corner (diagonal empty, both sides mass): square notch. Quarter TL: apron colour at x,y 0..2 (3x3); outline L: (3,0)-(3,3) umber2 and (0,3)-(3,3) umber1; rim L at (4,0)-(4,4) and (0,4)-(4,4). TR/BL/BR are the same idea at their own corner: apron 3x3 at the tile corner, outline L two px away in the colours of the edge it belongs to.
Shared skeleton: every quarter follows the same skeleton on its four border lines (x=0, x=20, y=0, y=20 in quarter coordinates), so ANY two quarters can sit side by side; interior quarters differ only in speckle, crack and moss placement. Details of the skeleton are in the sheet's own spec.

The 47 combinations: 16 orthogonal masks (N,E,S,W) x the diagonals that count (a diagonal only matters when both its neighbours are mass), which gives exactly 47 distinct tiles.

## Family 1: Open ground
Opaque 42x42 ground tiles for open (daylight) zones. Master first: floor-o-1 fixes the open ring colours, then everything else.

Variant groups (must swap with no seam): floor-o-1..3 (ring #9a6b3f), mud-o-1..2 (#7a4a1f), roots-o-1..2 (#7d8a62), blight-o-1..2 (#4e3a8a). crystal-o uses the floor-o ring.

| # | asset | size | kind | one-line design |
|---|---|---|---|---|
| 1 | trek-floor-o-1 | 42x42 | ground | Sunlit packed-earth trail: the plain default open floor and the COLOUR MASTER for the open set |
| 2 | trek-floor-o-2 | 42x42 | ground | Dry cracked dust: a sun-baked patch of the trail with a hairline crack, flat sandy flecks and a fallen twig |
| 3 | trek-floor-o-3 | 42x42 | ground | Meadow edge: the trail where grass has crept in |
| 4 | trek-mud-o-1 | 42x42 | ground | Open mud with the map-key three dark wet dots, one big and two small, in a diagonal line |
| 5 | trek-mud-o-2 | 42x42 | ground | Open mud, trampled: the same three-dots key but the dots sit in a triangle, with a boot-print dent and a gluey smear |
| 6 | trek-roots-o-1 | 42x42 | ground | Open ground knotted with roots: one thick root crossing diagonally, moss tufts on it, a grey-green base |
| 7 | trek-roots-o-2 | 42x42 | ground | Open ground with a Y-shaped root network and a single large tuft |
| 8 | trek-blight-o-1 | 42x42 | ground | Open blighted ground: dusk-purple soil with the map-key dots (two spore dots) and a faint webbing of thin cracks |
| 9 | trek-blight-o-2 | 42x42 | ground | Open blighted ground, further gone: one large blister (pustule) with a drip trail instead of webbing, three small dots |
| 10 | trek-crystal-o | 42x42 | ground | A glow crystal standing on open floor: the diamond is the map key |

## Family 2: Underground ground
Opaque 42x42 ground tiles for cave zones. Master first: floor-u-1. Same terrain ideas as family 1 but a different layout in every tile (no recolours).

Variant group: floor-u-1..3 (ring #8a5a30). mud-u shares the mud ring #7a4a1f with mud-o. The lantern vignette is added by the page: never paint it in.

| # | asset | size | kind | one-line design |
|---|---|---|---|---|
| 1 | trek-floor-u-1 | 42x42 | ground | Cave floor with two flat pebbles on warm dark earth: the underground colour master |
| 2 | trek-floor-u-2 | 42x42 | ground | Cave floor with angular slate chips and a drip stain: a thin stain of damp darker earth under a two-pixel drip mark |
| 3 | trek-floor-u-3 | 42x42 | ground | Cave floor with worm tracks: a long S-shaped trail of small bumps, two burrow holes, and a moss-like dim lichen patch |
| 4 | trek-mud-u | 42x42 | ground | Underground mud: wet, black-brown mud with two dark holes (map key) and a stepped drip ring around the larger hole where something fell in |
| 5 | trek-roots-u | 42x42 | ground | Underground roots: dark soil where pale root hairs spiral out of a central knot, with two glow-green tufts |
| 6 | trek-blight-u | 42x42 | ground | Underground blight: deep indigo ground with a pulsing pustule cluster (one glowing big, four small) and cracks |
| 7 | trek-crystal-u | 42x42 | ground | A glow crystal in the dark: a tall gold diamond with two small shards beside it, on a lit floor pool with sparks |

## Family 3: Water and clay
Chasm, drained pool, the two clay states, and the two ripple overlays. Draw the five opaque tiles first. The ripple overlays are drawn LAST (after trek-water-auto from family 4 exists) so they can be tested on its interior.

Variant group: chasm-1..2 (ring #143645). drained and clay-loose use the mud ring #7a4a1f; clay-wet uses #944c1f. Ripples are transparent 42x42 overlays, all opaque pixels >= 3 px from the edges.

| # | asset | size | kind | one-line design |
|---|---|---|---|---|
| 1 | trek-chasm-1 | 42x42 | ground | A drop into darkness: deep teal-black with a pit in the middle and two thin wave arcs (the game's chasm ripple) |
| 2 | trek-chasm-2 | 42x42 | ground | A drop seen from the cliff: three stepped rock ledges descend into the dark, a falling pebble and a dull gleam at the bottom |
| 3 | trek-drained | 42x42 | ground | A drained pool: wet mud with the last small sheen of water in a dried-out basin, mud cracks around its rim |
| 4 | trek-clay-wet | 42x42 | ground | Wet clay: orange-brown glossy clay with the map-key colon (two dots stacked) and two slumped wavy bands |
| 5 | trek-clay-loose | 42x42 | ground | Loose clay: dry crumbling mud with deep cracks and three loose crumbs ready to give way |
| 6 | trek-ripple-pool | 42x42 | overlay | Calm pool glints: a transparent overlay for a water tile |
| 7 | trek-ripple-high | 42x42 | overlay | High-water ripples: bolder double waves plus spray dots |

## Family 4: Auto-join sheets and wall extras
Three 84x126 RPG-Maker-style sheets (47 combos from 24 quarters) plus the deep fillers and the four cap overlays. Needs the ground rings of families 1 and 2 (apron colours) and the mud ring. Draw order inside each sheet: interior quarters, then edge quarters, then corners, then the inner-corner quarters, then copy the corners into the iso quarters.

Apron colours: wall-o #9a6b3f, wall-u #8a5a30, water #7a4a1f. Deep tiles share the sheet's mortar/strata edge lines. Caps are transparent and mate in pairs (n/s, e/w) on a 10 px stitched ridge.

| # | asset | size | kind | one-line design |
|---|---|---|---|---|
| 1 | trek-wall-o-auto | 84x126 | sheet | Open-zone wall: a coursed fieldstone wall in grey stone, mossy and a little thorny |
| 2 | trek-wall-u-auto | 84x126 | sheet | Underground wall: banded clay rock in pale tan with slumped strata and dangling root hairs |
| 3 | trek-water-auto | 84x126 | sheet | Pool water: a flat teal body with a soft shoreline of wet bank, glints inside |
| 4 | trek-wall-o-deep | 42x42 | ground | Deep stone: the heart of a thick open wall, one step darker than the auto-sheet interior |
| 5 | trek-wall-u-deep | 42x42 | ground | Deep clay rock: the core of a thick underground wall, darker tan with slump bands and a few embedded pebbles |
| 6 | trek-wallcap-n | 42x5 | overlay | Moss ridge: the game's 'wo_cap' strip (30 wide, 5 high, round ends, moss800 with moss600 dots), drawn in pixels |
| 7 | trek-wallcap-s | 42x5 | overlay | Moss ridge: the game's 'wo_cap' strip (30 wide, 5 high, round ends, moss800 with moss600 dots), drawn in pixels |
| 8 | trek-wallcap-e | 5x42 | overlay | Moss ridge: the game's 'wo_cap' strip (30 wide, 5 high, round ends, moss800 with moss600 dots), drawn in pixels |
| 9 | trek-wallcap-w | 5x42 | overlay | Moss ridge: the game's 'wo_cap' strip (30 wide, 5 high, round ends, moss800 with moss600 dots), drawn in pixels |

## Family 5: Bridge and rails
Transparent plank bridge tiles and the four rail strips that sit over their edges. Draw after the chasm tiles (family 3) exist, so the transparent gaps can be previewed on them.

Plank pitch 14 (12 plank + 2 gap) and rail post pitch 21 repeat across tile lines with no break.

| # | asset | size | kind | one-line design |
|---|---|---|---|---|
| 1 | trek-bridge-h | 42x42 | overlay | A plank bridge for east-west travel: three tall vertical planks side by side across the chasm, middle one darker, lashed with gold thread where they meet the rails |
| 2 | trek-bridge-v | 42x42 | overlay | A plank bridge for north-south travel: three wide horizontal planks stacked across the chasm, the top and bottom pale, the middle darker, with iron-style pegs instead of nails |
| 3 | trek-rail-n | 42x4 | overlay | Rail on the north side of a bridge tile: a 4 px wood beam with square posts every 21 px, lashed with a gold thread at each post |
| 4 | trek-rail-s | 42x4 | overlay | Rail on the south side of a bridge tile: a 4 px wood beam with square posts every 21 px, lashed with a gold thread at each post |
| 5 | trek-rail-e | 4x42 | overlay | Rail on the east side of a bridge tile: a 4 px wood beam with square posts every 21 px, lashed with a gold thread at each post |
| 6 | trek-rail-w | 4x42 | overlay | Rail on the west side of a bridge tile: a 4 px wood beam with square posts every 21 px, lashed with a gold thread at each post |

## Family 6: Markers
Small objects that sit on top of the map. No ground tile dependency; draw last. Each is a raised object with an umber outline and a 1 px gloss.

Tokens keep the centre 16x16 flat for the page's emoji. trek-me is the only asset with a ground shadow (stepped 1 px per row).

| # | asset | size | kind | one-line design |
|---|---|---|---|---|
| 1 | trek-token-gold | 34x34 | marker | Gold spot token: a cream coin with a stitched gold rim |
| 2 | trek-token-ember | 34x34 | marker | Ember (danger) spot token: a cream coin in an ember-red rim with four short spikes, so it is distinguishable from the gold token by silhouette alone |
| 3 | trek-me | 38x40 | marker | The player marker: a gnome head and tall red hat in a cream disc with a gold ring, standing on its own small ground shadow |
| 4 | trek-foot-h | 12x12 | marker | Footprints for a walk going east or west: two oval prints, the left one higher and one lower, each with a small toe dot ahead of it |
| 5 | trek-foot-v | 12x12 | marker | Footprints for a walk going north or south: two upright oval prints, side by side offset in depth, each with a small heel notch |
| 6 | trek-bang | 24x24 | marker | Objective mark: a red round badge with a cream exclamation mark, the 'something to do here' flag |
| 7 | trek-flag | 20x20 | marker | Destination flag: a red pennant on a wooden pole planted in a small stone |
