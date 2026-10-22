# trek-roots-o-2

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 1 (Open ground). Draw order inside the family: see families.md
- concept: Open ground with a Y-shaped root network and a single large tuft. Thinner roots, more grey ground visible than roots-o-1, a few stones caught in the roots.
- palette: or_base, or_shade, or_deep, or_hi, so_shade, so_base, so_rim, mo_base, moss600, mo_rim, umber2, sn_rim (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill or_base.
  - Y root, 2 px thick, so_shade body with 1 px so_base lit pixels on the upper edge: trunk from (8,35) up to (17,24); left branch to (9,12); right branch to (32,10). Junction knot 4x4 at (16..19,22..25) so_base with so_shade lower-right.
  - Big tuft at the junction, base (21,27): 3 V blades, heights 6, 8, 5: x=19,21,23, moss600, tips mo_rim, 1 px mo_shade at the base. Make it taller and wider than the roots-o-1 tufts.
  - Two caught stones: 4x3 at (28,26) and 3x3 at (11,29): sn_rim body, 1 px sn_gloss (#c9c5bc) upper-left, lower-right L outline umber2.
  - Speckles: 1 px or_hi (30,19),(5,18),(25,36); 1 px or_deep (12,17),(34,22).
- edge rules:
  - Ring pure or_base. Y root starts at y<=35 and x>=8: must stay inside the safe zone.
- must match (neighbours):
  - Ring identical to roots-o-1.
- readAt: 42: network, stones, tuft. 35: Y shape and tuft visible. 21: Y-shaped dark line plus one green tuft.
- must-haves:
  - Y-shaped network
  - One big tuft
  - Two stones with umber edge
  - Ring untouched

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
