# trek-floor-u-1

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 2 (Underground ground). Draw order inside the family: see families.md
- concept: Cave floor with two flat pebbles on warm dark earth: the underground colour master. Dimmer and cooler-edged than open floor.
- palette: su_base (ring and field), su_rim, su_gloss, su_bounce, su_shade, su_deep, umber2 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill su_base (#8a5a30).
  - Pebble 1 oval 7x5 at x9..15, y12..16: body su_shade, 1 px su_gloss upper-left, lower-right outline umber2 (right column + bottom row), 1 px su_rim above the top edge.
  - Pebble 2 oval 6x4 at x25..30, y27..30: same treatment, body su_bounce.
  - Flecks: 1 px su_rim at (20,10),(32,16),(14,30),(36,34); 1 px su_deep at (22,22),(9,24).
- edge rules:
  - Ring x or y 0-2 and 39-41 pure su_base. Texture in the safe zone 3..38.
  - The game's lantern vignette is applied by the page over the whole window; do not paint any vignette or darkening into the tile.
- must match (neighbours):
  - Colour master for the underground set; floor-u-2, floor-u-3, crystal-u, wall-u-auto apron match this ring exactly.
- readAt: 42: pebbles and flecks. 35: two dark ovals. 21: warm brown, two darker spots.
- must-haves:
  - Two outlined pebbles
  - Dim look, no vignette
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
