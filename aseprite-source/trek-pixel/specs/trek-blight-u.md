# trek-blight-u

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 2 (Underground ground). Draw order inside the family: see families.md
- concept: Underground blight: deep indigo ground with a pulsing pustule cluster (one glowing big, four small) and cracks. Darker than blight-o and glows.
- palette: du_shade (#3e2f66 ring, field), du_deep, du_base, dusk500, du_rim, du_gloss (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill du_shade (#3e2f66).
  - Big glowing pustule 8x8 cut corners at x17..24, y16..23: outer ring du_base, inner 5x5 dusk500, 3x3 du_rim core, 1 px du_gloss at (19,18); lower-right 2 px du_deep.
  - Four small dots 4x4 cut corners dusk500 with 1 px du_gloss: at (8,9), (30,10), (9,29), (31,30). Each is the map-key dot pair feel: two near the top, two near the bottom.
  - Veins 1 px du_deep from the big pustule to the small dots: (17,19)-(13,15)-(11,12); (24,19)-(28,15)-(30,13); (18,23)-(14,27)-(12,29); (24,23)-(28,27)-(30,29).
  - Flecks du_base at (21,6),(36,21),(5,20),(22,35).
- edge rules:
  - Ring x or y 0-2 and 39-41 pure du_shade. Texture in the safe zone 3..38.
  - The game's lantern vignette is applied by the page over the whole window; do not paint any vignette or darkening into the tile.
- must match (neighbours):
  - Ring is du_shade: differs from blight-o on purpose.
- readAt: 42: glowing core with veins. 35: five dots in an X. 21: dark purple tile with a bright centre.
- must-haves:
  - Glowing centre pustule
  - Four dots around it
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
