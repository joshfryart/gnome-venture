# trek-roots-u

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 2 (Underground ground). Draw order inside the family: see families.md
- concept: Underground roots: dark soil where pale root hairs spiral out of a central knot, with two glow-green tufts. Wiry, not thick like roots-o.
- palette: ur_base (ring, field), ur_shade, ur_deep, ur_hi, wl_base (#c9a96e), wl_shade, moss600, mo_rim, mo_shade (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill ur_base (#4a4632).
  - Central knot 6x6 cut corners at x18..23, y18..23: wl_shade body, 1 px wl_base upper-left, 1 px ur_deep lower-right.
  - Six hairs, 1 px wl_base, curling out of the knot: (17,20)-(13,20)-(11,17)-(11,13); (24,20)-(28,19)-(31,15); (19,24)-(17,28)-(13,30); (23,24)-(26,28)-(31,28)-(33,31); (20,17)-(20,13)-(23,10); (22,17)-(25,13). Add 1 px wl_shade under each hair every third pixel.
  - Tufts: base (9,32): V blades (8,31),(7,30),(7,29) and (10,31),(11,30),(11,29),(11,28); base (32,12): V blades (31,11),(30,10),(30,9) and (33,11),(34,10),(34,9),(34,8); moss600, tips mo_rim, base mo_shade.
  - Dark flecks ur_shade at (6,22),(35,24),(15,36).
- edge rules:
  - Ring x or y 0-2 and 39-41 pure ur_base. Texture in the safe zone 3..38.
  - The game's lantern vignette is applied by the page over the whole window; do not paint any vignette or darkening into the tile.
- must match (neighbours):
  - Distinct ring from mud-u (ur_base vs mud_base): flat colour step expected.
- readAt: 42: knot and hair. 35: pale hairs on dark. 21: dark olive tile with a pale lump and two green ticks.
- must-haves:
  - Knot + spiralling hairs
  - Two green tufts
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
