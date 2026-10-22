# trek-flag

- canvas: 20x20 PNG. Transparent background (alpha 0 or 255).
- family: 6 (Markers). Draw order inside the family: see families.md
- concept: Destination flag: a red pennant on a wooden pole planted in a small stone. The pennant points right, with a thread-gold hem stitched at the pole.
- palette: umber1/2/3, wd_gloss, wd_rim, wd_base, wd_shade, rd_gloss, rd_rim, rd_base, rd_shade, rd_deep, sn_rim, sn_base, sn_shade, thread (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Markers are raised objects: umber outline by light (top/left umber1, sides umber2, bottom/right umber3), one lower-right shade and a 1 px gloss. No halo, no ground blob (only trek-me has a shadow). Transparent outside.
  - Pole: 2 px wide at x4..5, y1..16: wd_rim left px, wd_base right px, 1 px wd_gloss at (4,2), top cap 2x2 at (4..5,0..1) wd_gloss; outline umber1 left x3 and umber3 right x6.
  - Pennant: triangle with points (6,2), (18,6), (6,11): rd_base body, rd_rim upper edge 1 px, lower-right 2 px rd_shade, rd_deep at the tip pixel, 1 px rd_gloss at (8,3)..(9,3). Outline: top edge umber1, lower edge umber3, tip umber2.
  - Hem stitch (the join of cloth and pole): thread gold dashes 2 on / 1 off along x=7 from y3 to y10 (3 px dashes in 2/1 pattern: y3-4, y6-7, y9-10).
  - Base stone: 8x3 centred under the pole, x1..8, y16..18, sn_base body, sn_rim top row, sn_shade lower-right, umber2 outline lower row.
  - No ground shadow.
- edge rules:
  - 1 px transparent margin on all sides; pole base at y<=18.
- must match (neighbours):
  - Placed on the destination tile by the page.
- readAt: 42 shows 20x20 (2x zoom in sheet). 21: red triangle on a thin pole.
- must-haves:
  - Pennant points right
  - Gold hem at the pole
  - Stone base
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
