# trek-crystal-o

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 1 (Open ground). Draw order inside the family: see families.md
- concept: A glow crystal standing on open floor: the diamond is the map key. An umber-outlined gold diamond, cut like a gem, on a floor patch lit by four sparks. No halo ring.
- palette: so_base (ring), so_rim, so_gloss, gd_gloss, gd_rim, gd_base, gd_shade, gd_deep, umber1, umber2, umber3, ink (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill so_base. Lit floor patch: a stepped diamond-ish pad so_rim, 28 wide x 26 tall centred (21,21), at least 7 px from the edge (no ring contact).
  - Crystal: diamond silhouette 21 wide (x11..31) x 33 tall (y5..37), points at top (21,5) and bottom (21,37), left (11,21), right (31,21). Stepped edge: 1 px horizontal run per 1.6 rows (pattern 2,2,1,2,2,1...).
  - Outline 1 px: top-left edges umber1, bottom-left umber2, bottom-right umber3, top-right umber2.
  - Fill by light: left half gd_rim, right half gd_base; upper-left facet gd_gloss (a 4 px wide comma on the left edge, x13..16, y14..22) ; lower-right edge band 2 px gd_shade, with 1 px gd_bounce just inside, bottom tip 3 px gd_deep.
  - Inner diamond (table facet): 10 wide x 18 tall centred (21,21), 1 px gd_deep outline, fill gd_gloss upper half / gd_rim lower half. Facet line: 1 px gd_deep along x=22 from y=9 to y=33.
  - Four sparks, 3 px plus-shape gd_gloss: (6,8), (35,10), (7,33), (36,31) (all >= 3 px from edge).
- edge rules:
  - Ring: x or y in 0-2 and 39-41 is pure so_base (no texture, no outline). Texture and objects live in the safe zone x,y 3..38.
  - Ring pure so_base, identical to floor-o. The lit pad must not reach the ring.
- must match (neighbours):
  - Ring identical to floor-o-1. Crystal-u shares the shape idea but not the layout.
- readAt: 42: facets + sparks. 35: diamond with a bright left half. 21: unmistakable gold diamond on brown.
- must-haves:
  - Diamond silhouette = map key
  - Umber outline on the crystal only
  - No halo ring around it
  - Gold stays inside the diamond

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
