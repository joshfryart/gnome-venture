# trek-clay-loose

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 3 (Water and clay). Draw order inside the family: see families.md
- concept: Loose clay: dry crumbling mud with deep cracks and three loose crumbs ready to give way. Flat, matte, dangerous.
- palette: mud_base (ring, field), mud_shade, soil900, soil300, so_bounce, umber2 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill mud_base (#7a4a1f).
  - Crack 1, 2 px wide soil900 with 1 px so_bounce lit lip along the right side: (8,10) -> (16,17) -> (13,25) -> (22,31) (polyline, steps of the game's 'l8 7 l-3 8 l9 6').
  - Crack 2: (30,8) -> (24,17) -> (29,24), same style.
  - Crumbs (objects, umber lower-right L outline): 3x3 soil300 at (11,30), (30,29) and (23,11), each with a 1 px so_bounce glint upper-left.
  - Flat dust specks mud_shade at (6,22),(35,14),(18,36).
- edge rules:
  - Ring pure mud_base (#7a4a1f); cracks end >= 3 px from the ring.
- must match (neighbours):
  - Ring identical to mud tiles: loose clay can sit in a mud field. Must be distinguishable from mud by cracks.
- readAt: 42: cracks + crumbs. 35: two dark lines. 21: dark tile with a Y-shaped dark line and a few light dots.
- must-haves:
  - Two cracks = map key for loose clay
  - Crumbs on top
  - Matte

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
