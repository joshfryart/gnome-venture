# trek-wall-o-auto

- canvas: 84x126 PNG. Opaque auto-join sheet, cut into 21x21 quarters.
- family: 4 (Auto-join sheets and wall extras). Draw order inside the family: see families.md
- concept: Open-zone wall: a coursed fieldstone wall in grey stone, mossy and a little thorny. A solid, heavy, raised mass with an umber edge. The raised object is the stone mass; the apron ground is floor-o.
- palette: sn ramp (gloss/rim/base/bounce/shade/deep), umber1/2/3, so_base (apron), moss800, mo_base, ember400, ember700, ink (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Apron colour (empty sides) = so_base #9a6b3f (floor-o ring).
  - Skeleton, quarter coordinates: mortar rows at y=0 and y=10, 1 px sn_shade. Course A (rows 1-9): vertical joints at x=0 and x=10. Course B (rows 11-20): joints at x=5 and x=15. All joints 1 px sn_shade. Each stone: top row sn_rim, body sn_base, bottom row sn_bounce, 1 px sn_gloss at its upper-left pixel only on every second stone.
  - Interior quarters: (1,3) TL has a moss patch 4x3 moss800 + 1 px mo_base at (6..9,3..5); (2,3) TR has a crack 1 px ink: (8,13),(9,14),(9,15),(10,16),(10,17); (1,4) BL has a thorn dot 3x3 ember400 at (12..14,4..6) with 1 px ember700 on the lower-right and a 3 px ember700 stroke (9,13)-(11,11); (2,4) BR is plain except three sn_deep specks at (4,5),(14,13),(18,2).
  - Edge quarters: each gets one feature drawn away from the apron: (1,2) moss tuft 3 px at (14..16,8); (2,2) sn_deep speck pair at (6,11),(15,15); (0,3) crack (4,10)-(5,13); (0,4) moss patch (7..9,14..16); (3,3) thorn dot (6..8,12..14); (3,4) crack (11,5)-(12,8); (1,5),(2,5) 1 px sn_deep speck pairs.
  - Corner quarters: outline arc as above; the corner stone is a single rounded stone (no joint through the arc).
  - Inner-corner quarters: the square notch only; skeleton continues around it.
- edge rules:
  - Apron 3 px on every empty side = so_base (exactly floor-o).
  - Quarter lines 21/42: skeleton rows y=0,10 and joints follow the table above so tiles tile into a seamless wall.
  - check.py composes all 47 tiles from the quarters, then tests: apron match on every empty side, quarter-line (x=21, y=21) continuity, and left/right + top/bottom self-tiling of tiles whose E+W or N+S are mass.
- must match (neighbours):
  - Must join with trek-floor-o-1..3 at the apron (flat so_base) and with trek-wall-o-deep (same skeleton, deep tile edge rows y=0 and x=0 are the sn_shade mortar).
  - Walls of the two styles meet each other through trek-wallcap-* (not drawn into the sheet).
- readAt: 42: stones, joints, moss. 35: mass with coursing. 21: grey blocked tile with a dark outline; mortar may blur but the silhouette and umber edge must stay.
- must-haves:
  - Umber outline only on the mass edge
  - 3 px apron of floor colour, no halo
  - Skeleton identical on all quarters
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
