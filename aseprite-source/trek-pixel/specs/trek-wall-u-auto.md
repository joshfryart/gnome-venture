# trek-wall-u-auto

- canvas: 84x126 PNG. Opaque auto-join sheet, cut into 21x21 quarters.
- family: 4 (Auto-join sheets and wall extras). Draw order inside the family: see families.md
- concept: Underground wall: banded clay rock in pale tan with slumped strata and dangling root hairs. Lighter than the dark floor so it reads against it. A different texture language from the stone wall: waves, not bricks.
- palette: wl ramp, umber1/2/3, su_base (apron), wl_deep, ember400 (one drip stain), moss600 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Apron colour (empty sides) = su_base #8a5a30 (floor-u ring).
  - Skeleton, quarter coordinates: two strata lines per quarter, each 1 px wl_shade with a lit 1 px wl_gloss line above it. Line 1 centre y=6, line 2 centre y=16. Wave offsets by x mod 7 = [0,-1,-1,0,1,1,0] (period 7 divides 21, so the wave is continuous across quarter lines). Body wl_base; bottom row of each band wl_bounce.
  - Root hairs: wl_deep 1 px curls hanging from a strata line, 3 to 5 px long, only in interior/edge quarters: (1,3) at (4,7)-(4,11); (2,3) at (13,7)-(14,10)-(14,12); (1,4) at (8,17)-(8,20); (2,4) at (3,17)-(4,19). One hair per quarter, different lengths.
  - Features: (2,4) a 3x3 ember400 stain with 1 px wl_deep lower-right at (15..17,9..11); (1,4) two moss600 pixels at (14,5),(15,5); (1,3) 1 px wl_deep pits at (10,2),(17,12).
  - Edge quarters carry one strata line each plus one pit; corners are single rounded rock lumps; inner corners are the square notch.
  - Distinct from wall-o: no mortar joints, no thorns, no moss patches.
- edge rules:
  - Apron 3 px on every empty side = su_base (exactly floor-u).
  - Strata wave period 7 keeps all quarter lines continuous.
  - check.py composes all 47 tiles from the quarters, then tests: apron match on every empty side, quarter-line (x=21, y=21) continuity, and left/right + top/bottom self-tiling of tiles whose E+W or N+S are mass.
- must match (neighbours):
  - Must join with trek-floor-u-1..3 at the apron and with trek-wall-u-deep (same strata lines, deep tile darker).
- readAt: 42: waves and hairs. 35: banded tan mass. 21: pale tan blocks with a dark umber edge on a darker floor.
- must-haves:
  - Umber outline only on mass edge
  - Waves not bricks
  - Pale against dark floor
  - Iso quarters are copies of corners

## Auto-join layout
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

## Rules (all trek assets)
- Stitched Toy hard pixels: no anti-aliasing, no blends, no dither, no gradients. Alpha is 0 or 255 only.
- Palette: only colours from `palette.md`. No pure black `#000000`, no pure white `#ffffff`.
- One light from the upper left. Shade (1-2 px, lower-right) ONLY on objects inside the tile. No whole-tile crescent.
- NO halo, NO black border, no sticker outline. Umber outline only on raised objects (crystal, planks, stones, markers, wall masses).
- Gold thread stitch (2 on / 1 off) only at real joins.
- No flip or rotate reuse: every asset and every variant is drawn separately; recolouring another asset is not allowed.
- Ground tiles are full-bleed, opaque and seamless: outer 3 px ring = the terrain's base colour; details at least 3 px from the edges unless designed to cross; variants of one terrain swap with no seam.
- Keep the map-key meaning: ripples = high water, two dots = wet clay, cracks = loose clay, diamond = crystal, tuft = roots, dots = mud/blight.
- Read at 42, 35 and 21 px (the contact sheet shows all three).
