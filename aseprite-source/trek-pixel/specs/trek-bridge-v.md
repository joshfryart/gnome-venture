# trek-bridge-v

- canvas: 42x42 PNG. Transparent background (alpha 0 or 255).
- family: 5 (Bridge and rails). Draw order inside the family: see families.md
- concept: A plank bridge for north-south travel: three wide horizontal planks stacked across the chasm, the top and bottom pale, the middle darker, with iron-style pegs instead of nails. Planks lie OVER a chasm tile: the 2 px gaps between planks are transparent so the chasm shows through.
- palette: wd_gloss, wd_rim, wd_base, wd_shade, wd_deep, umber1, umber2, umber3, thread, thread2 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Transparent background. Three planks 12 tall, 38 wide: y1..12, y15..26, y29..40; x2..39. Gaps y13..14, y27..28 and y41+y0 (2 px) are transparent.
  - Each plank: outline (top umber1, left umber1, bottom umber3, right umber3), 1 px lit rim at top and left, bodies: plank 1 and 3 wd_rim, plank 2 wd_base; 2 px wd_shade along the bottom and right with 1 px wd_bounce inside.
  - Grain: horizontal 1 px wd_base lines. Plank 1 at y5 (x8..20) and y9 (x24..34); plank 2 at y19 (x6..16) and y23 (x20..34); plank 3 at y33 (x10..24) and y37 (x6..14).
  - Pegs (not nails): 3x3 wd_deep discs with 1 px wd_rim upper-left at (6..8,4..6) and (33..35,4..6) in plank 1; (6..8,18..20) and (33..35,18..20) in plank 2; (6..8,32..34) and (33..35,32..34) in plank 3. Distinct from bridge-h's 2x2 nails.
  - Lashing, ONLY at the rail joins: 1x2 thread gold at the left and right ends of each plank: x3 and x38 (y at plank centre rows 5..6, 19..20, 33..34), thread2 under it.
- edge rules:
  - Planks never touch y=0 or y=41 (constant 2 px gap).
  - Rails (rail-w at x0..3, rail-e at x38..41) overlap plank ends; draw nothing in x0..1 and x40..41.
- must match (neighbours):
  - Sits on trek-chasm-1/2 and joins end to end with itself. Rails: trek-rail-w / trek-rail-e.
- readAt: 42: planks and pegs. 35: three horizontal stripes. 21: three horizontal light bars.
- must-haves:
  - Horizontal planks (north-south travel)
  - Pegs not nails
  - Not bridge-h rotated: different grain and fasteners
  - Transparent gaps

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
