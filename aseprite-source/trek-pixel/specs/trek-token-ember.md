# trek-token-ember

- canvas: 34x34 PNG. Transparent background (alpha 0 or 255).
- family: 6 (Markers). Draw order inside the family: see families.md
- concept: Ember (danger) spot token: a cream coin in an ember-red rim with four short spikes, so it is distinguishable from the gold token by silhouette alone. Centre left empty for the icon.
- palette: umber1/2/3, rd_gloss, rd_rim, rd_base, rd_bounce, rd_shade, rd_deep, ember300, thread, cr base, cr_shade (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Markers are raised objects: umber outline by light (top/left umber1, sides umber2, bottom/right umber3), one lower-right shade and a 1 px gloss. No halo, no ground blob (only trek-me has a shadow). Transparent outside.
  - Core disc radius 14, centre (16.5,16.5), x3..30, y3..30. Outline 1 px (r 14), ember ring 2 px (r 13..12): rd_rim lit half, rd_base, lower-right 1 px rd_bounce + 1 px rd_shade, rd_deep on the lowest px; 1 px rd_gloss comma at (7..10,8).
  - Four spikes, 2 rows tall, stepped 6 / 4 px wide: north rows y2 x14..19 and y1 x15..18; south rows y31 x14..19 and y32 x15..18; west cols x2 y14..19 and x1 y15..18; east cols x31 y14..19 and x32 y15..18. Body rd_base, north/west spikes get rd_rim edge pixel, south/east rd_shade; 1 px umber outline around each spike (umber1 north/west, umber3 south/east).
  - Thread ring 1 px at r 11, dashed 2 on / 1 off, colour thread over rd_shade, skipping the gloss comma.
  - Cream coin r<=10 (20 across): flat cream, cr_shade crescent on its lower-right edge only. The central 16x16 square (x9..24, y9..24) with 3 px cut corners is PURE flat cream.
  - Three 1 px ember300 glints on the ring at 45 degrees: (25,8), (8,25), (25,25).
- edge rules:
  - Spike tips reach 1 px from each edge (34x34 box)
  - Centre 16x16 untouched.
- must match (neighbours):
  - Pair with trek-token-gold.
- readAt: 42: ring, spikes, stitch. 35: red coin with 4 spikes. 21: red spiked coin; spikes remain visible.
- must-haves:
  - Red + spikes
  - Flat cream centre 16x16
  - Not a recolour of the gold token: spikes, no button

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
