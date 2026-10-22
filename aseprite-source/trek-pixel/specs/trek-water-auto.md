# trek-water-auto

- canvas: 84x126 PNG. Opaque auto-join sheet, cut into 21x21 quarters.
- family: 4 (Auto-join sheets and wall extras). Draw order inside the family: see families.md
- concept: Pool water: a flat teal body with a soft shoreline of wet bank, glints inside. Not raised, so no umber outline. Pools and high water use this same sheet; high water adds ripple-high on top.
- palette: wa ramp, mud_base (apron #7a4a1f), mud_shade (#5c3520 bank line) (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Apron colour (empty sides) = mud_base #7a4a1f (mud ring).
  - Empty-side geometry, replacing the wall rules: d 0-2 apron, d 3 bank line 1 px mud_shade (no umber), d 4 wa_shade 1 px, d 5-6 wa_base. Add a 1 px wa_rim glint line at d 6 on N and W edges only, 6 px on / 4 off.
  - Outer corner arcs and inner square corners follow the shared table, using mud_shade for the bank line and wa_shade for the water edge.
  - Interior quarters: water body wa_base with a 1 px wa_shade underline. Quarter (1,3): glints wa_rim 3 px at (5..7,6) and 2 px at (12..13,14). (2,3): wa_rim 4 px at (8..11,11). (1,4): wa_rim 3 px at (4..6,13) and 1 px wa_gloss at (14,5). (2,4): wa_rim 3 px at (10..12,8) and 1 px wa_gloss (4,16). Keep every glint >= 2 px from the quarter borders so quarter lines are plain wa_base.
  - Edge quarters: only the shoreline plus one wa_rim glint of 2 px, >= 3 px from the apron rows.
- edge rules:
  - Apron 3 px on every empty side = mud_base #7a4a1f.
  - Quarter-line columns/rows are plain wa_base (no glints within 2 px), so tiles join invisibly.
  - check.py composes all 47 tiles from the quarters, then tests: apron match on every empty side, quarter-line (x=21, y=21) continuity, and left/right + top/bottom self-tiling of tiles whose E+W or N+S are mass.
- must match (neighbours):
  - Ground next to a pool is mud; underground pools sit on mud-u whose ring is also #7a4a1f, so one sheet serves both styles.
  - ripple-pool / ripple-high overlays sit on its interior.
- readAt: 42: shore + glints. 35: teal pool with bank. 21: teal blob on brown; no outline.
- must-haves:
  - No umber on water
  - Wet bank line
  - Interior plain at quarter lines
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
