# trek-rail-e

- canvas: 4x42 PNG. Transparent background (alpha 0 or 255).
- family: 5 (Bridge and rails). Draw order inside the family: see families.md
- concept: Rail on the east side of a bridge tile: a 4 px wood beam with square posts every 21 px, lashed with a gold thread at each post. Transparent.
- palette: wd_gloss, wd_rim, wd_base, wd_shade, umber1, umber2, umber3, thread (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Columns: x0 umber1 (outline, lit), x1 wd_rim, x2 wd_base, x3 umber3 (shaded). Full height y0..41.
  - Posts: 4x4 blocks at y5..8 and y26..29: left column umber1, x1 wd_gloss, x2 wd_rim, x3 umber3.
  - Lashing: thread 2 px at (1,6..7) over each post; knots 1 px wd_shade at (2,15),(2,36).
- edge rules:
  - Alpha 0 or 255. Posts pitch exactly 21 px so rail tiles repeat across a long bridge without a break.
  - Posts at y5..8 and y26..29 (pitch 21).
- must match (neighbours):
  - Draws over trek-bridge-v plank ends and over the chasm edge; ends meet the next rail tile with the same beam rows.
- readAt: 42: beam, posts, lashings. 35: dark beam with post bumps. 21: a thin dark line with light posts.
- must-haves:
  - Umber outline
  - Posts every 21 px
  - Gold only at post joins
  - Not a copy of the opposite rail

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
