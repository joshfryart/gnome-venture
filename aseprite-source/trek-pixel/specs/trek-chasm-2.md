# trek-chasm-2

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 3 (Water and clay). Draw order inside the family: see families.md
- concept: A drop seen from the cliff: three stepped rock ledges descend into the dark, a falling pebble and a dull gleam at the bottom. A strata look, unlike the round pit of chasm-1.
- palette: ch_base, ch_rim, ch_shade, ch_deep, ch_gloss, su_deep (#33221a) for the pebble (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill ch_base.
  - Ledge bands, horizontal, stepped (each band has a 2 px staircase on its right end): band 1 y9..11 x6..34 ch_rim top row + ch_shade 2 rows; band 2 y17..19 x9..31 same; band 3 y25..27 x12..28 same; below band 3 a 10x4 ch_deep slot at x16..25, y30..33.
  - Falling pebble 3x3 at (31,13): su_deep body, 1 px ch_gloss upper-left, with a 3 px ch_rim motion tick above at (31,10).
  - Gleam: 2x1 ch_gloss at (20,32) in the slot.
  - Speckles ch_shade at (5,16),(36,22),(10,35).
- edge rules:
  - Ring pure ch_base. No ledge touches x<4 or x>37.
- must match (neighbours):
  - Ring identical to chasm-1; swap with no seam.
- readAt: 42: three ledges + pebble. 35: three light lines. 21: dark with horizontal banding.
- must-haves:
  - Three ledges
  - Falling pebble
  - Darker than every ground tile
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
