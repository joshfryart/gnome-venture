# trek-foot-h

- canvas: 12x12 PNG. Transparent background (alpha 0 or 255).
- family: 6 (Markers). Draw order inside the family: see families.md
- concept: Footprints for a walk going east or west: two oval prints, the left one higher and one lower, each with a small toe dot ahead of it. Pale gold on the ground.
- palette: thread (#f5cf6a) body, thread2 (#e8a317) 1 px shade, gd_gloss (#fff1c8) 1 px (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Transparent background, no outline (footprints are flat marks on the ground, not raised).
  - Print A: horizontal oval 6x4 at x0..5, y1..4, body thread, 1 px gd_gloss at (1,1), 1 px thread2 lower-right pixel (5,4). Toe dot 1x1 at (7,2) thread.
  - Print B: horizontal oval 6x4 at x5..10, y7..10, same shading; toe dot 1x1 at (11,8).
- edge rules:
  - Alpha 0 or 255. Reads as a tilted pair along a diagonal.
- must match (neighbours):
  - Drawn many times in a row by the page (opacity is handled in CSS). Two prints per image.
- readAt: 42 shows 12x12 (3x zoom in sheet). 21: two light dashes along a diagonal.
- must-haves:
  - Horizontal ovals
  - Toe dots
  - No outline

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
