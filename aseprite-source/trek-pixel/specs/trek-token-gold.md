# trek-token-gold

- canvas: 34x34 PNG. Transparent background (alpha 0 or 255).
- family: 6 (Markers). Draw order inside the family: see families.md
- concept: Gold spot token: a cream coin with a stitched gold rim. Quiet, welcoming. The centre is left flat and empty for the page's emoji icon.
- palette: umber1/2/3, gd_gloss, gd_rim, gd_base, gd_bounce, gd_shade, thread, cr base (#f4f0e0), cr_shade (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Markers are raised objects: umber outline by light (top/left umber1, sides umber2, bottom/right umber3), one lower-right shade and a 1 px gloss. No halo, no ground blob (only trek-me has a shadow). Transparent outside.
  - Disc 32 px across, centre (16.5,16.5), x1..32, y1..32, stepped circle radius 16.
  - Outline 1 px (r 16). Gold ring 2 px (r 15..14): lit half gd_rim, body gd_base, lower-right arc 1 px gd_bounce then 1 px gd_shade; 1 px gd_gloss comma on the upper-left arc (x6..10, y7..8).
  - Thread ring 1 px at r 13, dashed 2 on / 1 off, colour thread, skipping the gloss comma (the join between rim and coin).
  - Cream coin r<=12 (24 across): flat cr base (#f4f0e0) with a 1 px cr_shade crescent only on its lower-right edge. The central 16x16 square (x9..24, y9..24, corners cut 2 px) is PURE flat cream: no marks.
  - Button: 4x4 gold button at 12 o'clock on the outline/ring, x15..18, y1..4, thread_hole pixels on the diagonal.
- edge rules:
  - Bounding box inside 34x34 with at least 1 px transparent margin.
  - Cream centre 16x16 untouched so the emoji overlay stays legible.
- must match (neighbours):
  - Pair with trek-token-ember: same 34x34 grid, same centre area.
- readAt: 42 shows 34 px. 35: ring + stitch. 21: gold ring around a cream centre; stitch and button may fade.
- must-haves:
  - Gold ring
  - Flat cream centre 16x16
  - Button at top
  - Thread only at the join

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
