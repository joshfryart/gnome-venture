# trek-foot-v

- canvas: 12x12 PNG. Transparent background (alpha 0 or 255).
- family: 6 (Markers). Draw order inside the family: see families.md
- concept: Footprints for a walk going north or south: two upright oval prints, side by side offset in depth, each with a small heel notch. Pale gold.
- palette: thread, thread2, gd_gloss (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Transparent background, no outline.
  - Print A: upright oval 4x6 at x1..4, y0..5, body thread, 1 px gd_gloss at (2,1), 1 px thread2 at (4,5). Heel notch: transparent pixel at (2,5).
  - Print B: upright oval 4x6 at x7..10, y6..11, body thread, 1 px gd_gloss at (8,7), 1 px thread2 at (10,11), heel notch transparent at (8,11).
- edge rules:
  - Alpha 0 or 255.
- must match (neighbours):
  - Same role as trek-foot-h for vertical walks.
- readAt: 42 shows 12x12. 21: two light vertical dashes offset.
- must-haves:
  - Upright ovals
  - Heel notch
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
