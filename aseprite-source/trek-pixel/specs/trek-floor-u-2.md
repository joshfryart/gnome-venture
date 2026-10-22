# trek-floor-u-2

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 2 (Underground ground). Draw order inside the family: see families.md
- concept: Cave floor with angular slate chips and a drip stain: a thin stain of damp darker earth under a two-pixel drip mark. Chips are sharp, pebbles in floor-u-1 are round.
- palette: su_base, su_shade, su_deep, su_rim, su_gloss, umber2, wa_rim (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill su_base.
  - Chips (angular, 3 stones): triangle-ish 5x4 at (10,26) with points up-left, 4x4 at (17,29), 3x3 at (27,13): body su_rim, 1 px su_gloss on the top-left pixel, umber2 lower-right edge (diagonal).
  - Drip stain: rounded blotch 9x6 at x24..32, y22..27 in su_shade (flat, no outline), 3 su_deep pixels on its lower-right, and a 2 px wa_rim drop at (28,19) above it (the drip).
  - Hairline crack 1 px su_deep: (6,8)-(11,8), (12,9)-(13,10), (14,10)-(18,10).
  - Flecks su_gloss 1 px: (33,9),(8,18),(21,36).
- edge rules:
  - Ring x or y 0-2 and 39-41 pure su_base. Texture in the safe zone 3..38.
  - The game's lantern vignette is applied by the page over the whole window; do not paint any vignette or darkening into the tile.
- must match (neighbours):
  - Ring identical to floor-u-1.
- readAt: 42: slate chips and stain. 35: stain visible. 21: darker patch right of centre plus two small stones.
- must-haves:
  - Angular chips (not round)
  - Drip stain with drop
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
