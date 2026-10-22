# trek-me

- canvas: 38x40 PNG. Transparent background (alpha 0 or 255).
- family: 6 (Markers). Draw order inside the family: see families.md
- concept: The player marker: a gnome head and tall red hat in a cream disc with a gold ring, standing on its own small ground shadow. Friendly, readable at 21 px as 'a red hat on a cream coin'. (The game may overdraw the player's own avatar; this is the fallback.)
- palette: umber1/2/3, gd_gloss, gd_rim, gd_base, gd_shade, cr base, cr_shade, rd ramp, skin ramp, lav, umber2 (shadow) (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Markers are raised objects: umber outline by light (top/left umber1, sides umber2, bottom/right umber3), one lower-right shade and a 1 px gloss. No halo, no ground blob (only trek-me has a shadow). Transparent outside.
  - Ground shadow first (bottom layer): a stepped ellipse of umber2 (flat colour, 1 px per row, no blending), rows y32..39: y32 x14..23, y33 x10..27, y34 x8..29, y35 x7..30, y36 x7..30, y37 x8..29, y38 x10..27, y39 x14..23. The disc covers its top rows.
  - Disc: stepped circle radius 17, centre (18.5,16.5), x2..35, y0..33. Outline 1 px; gold ring 2 px (gd_rim lit upper-left, gd_base, gd_shade lower-right, 1 px gd_gloss comma at (7..10,6)); cream interior with a 1 px cr_shade lower-right edge.
  - Hat (row spans x from..to): y3 x24..25 (bent tip), y4 x24..25, y5 x21..24, y6 x20..25, y7 x19..25, y8 x18..26, y9 x17..26, y10 x16..27, y11 x15..27, y12 x14..28, y13 x13..28, y14 x12..28, brim y15..16 x9..28. rd ramp: rd_rim left edge, rd_base, rd_shade right 2 px, rd_deep on the lowest brim row; 1 px rd_gloss at (14..15,9..11). Umber outline 1 px (umber1 left, umber3 right). Brim stitch: thread gold dashes 2 on / 1 off along y=15, x11..26 (this is the join between hat and head).
  - Head: skin_base oval 14 wide x 8 tall at x12..25, y17..24 with skin_rim on the upper-left, skin_shade lower-right 2 px; nose 2x2 skin_bounce at (18..19,20..21).
  - Eyes (small version, head < 20 px): 3x3 cream disc with cut corners, 2x2 umber3 pupil with 1 px cream glint: left eye x14..16,y18..20, right eye x21..23,y18..20. NO blush.
  - Beard: cream-safe, cr base with umber2 1 px outline (pale rule) from y24 to y31, V shape x12..25 narrowing to a 4 px tip at (17..20,31); cr_shade lower-right 2 px; 1 px cr_gloss (#fff3c8) at (14,26).
- edge rules:
  - Overall bounding box 38x40 with the shadow reaching y39.
  - Shadow rows span a symmetric ellipse around x=18.5; the disc covers its top rows.
- must match (neighbours):
  - Stand-alone marker; at 21 px the shadow should read as a flat dark ellipse under the disc.
- readAt: 42 shows 38x40. 35: hat + beard clear. 21: red cone + cream coin + shadow.
- must-haves:
  - Red bent-tip hat
  - Gold ring
  - Ground shadow with 1 px-per-row steps
  - Eyes small version

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
