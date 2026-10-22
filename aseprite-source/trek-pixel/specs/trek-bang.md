# trek-bang

- canvas: 24x24 PNG. Transparent background (alpha 0 or 255).
- family: 6 (Markers). Draw order inside the family: see families.md
- concept: Objective mark: a red round badge with a cream exclamation mark, the 'something to do here' flag. Bold and simple.
- palette: umber1/2/3, rd_gloss, rd_rim, rd_base, rd_bounce, rd_shade, rd_deep, cr base, cr_shade (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Markers are raised objects: umber outline by light (top/left umber1, sides umber2, bottom/right umber3), one lower-right shade and a 1 px gloss. No halo, no ground blob (only trek-me has a shadow). Transparent outside.
  - Disc 22 px across, centre (11.5,11.5), x1..22, y1..22. Outline 1 px; rd_rim lit arc, rd_base body, lower-right 2 px rd_shade + 1 px rd_bounce inside it; rd_deep on the bottom-right 1 px; rd_gloss comma (3 px) at (4..6,5).
  - Exclamation mark, cream (#f4f0e0), centred on x=11.5: bar y5..9 is 4 wide (x10..13), bar y10..13 tapers to 2 wide (x11..12); dot 4 wide x 3 tall with cut corners: (11..12,16),(10..13,17),(11..12,18). cr_shade 1 px under the right and bottom of the bar and dot.
- edge rules:
  - Mark centred horizontally within +/- 1 px; badge touches no edge (1 px transparent margin).
- must match (neighbours):
  - Placed at the top-right of a spot tile by the page.
- readAt: 42 shows 24x24. 21: red dot with a vertical cream mark.
- must-haves:
  - Cream bar + dot
  - Red badge
  - Umber outline

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
