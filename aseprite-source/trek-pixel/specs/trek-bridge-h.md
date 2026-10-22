# trek-bridge-h

- canvas: 42x42 PNG. Transparent background (alpha 0 or 255).
- family: 5 (Bridge and rails). Draw order inside the family: see families.md
- concept: A plank bridge for east-west travel: three tall vertical planks side by side across the chasm, middle one darker, lashed with gold thread where they meet the rails. Planks lie OVER a chasm tile: the 2 px gaps between planks are transparent so the chasm shows through.
- palette: wd_gloss, wd_rim, wd_base, wd_shade, wd_deep, umber1, umber2, umber3, thread, thread2 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Transparent background. Three planks 12 wide, 38 tall: x1..12, x15..26, x29..40; y2..39. Gaps x13..14, x27..28 and x41+x0 (2 px) are transparent.
  - Each plank: 1 px outline (top and left umber1, right umber3, bottom umber3, left umber2 for the middle plank), lit rim 1 px at top and left inside, body: planks 1 and 3 wd_rim, plank 2 wd_base; lower-right shade 2 px wd_shade with 1 px bounce wd_bounce inside it.
  - Grain: plank 1 two vertical 1 px lines wd_base at x4 and x8 (y8..20 and y26..34); plank 2 a knot 3x3 wd_shade/wd_deep at (19..21,18..20) with 1 px wd_rim; plank 3 one line at x33 (y6..16) and x36 (y22..34).
  - Nails: 2x2 wd_deep with 1 px wd_gloss, two per plank at (4..5,5..6) and (4..5,35..36) (planks 1), x offset to 18..19 and 32..33 for planks 2 and 3 but y the same.
  - Lashing, ONLY at the rail joins: 2x1 thread gold on the top and bottom of every plank at y3 and y38 (x offsets: plank 1 x5..6, plank 2 x19..20, plank 3 x33..34), with 1 px thread2 under it.
- edge rules:
  - Planks never touch x=0 or x=41 (2 px gap across the tile line): a row of bridge-h tiles has a constant 2 px gap.
  - Rails (rail-n at y0..3, rail-s at y38..41) overlap the plank tops/bottoms; draw nothing in rows y0..1 and y40..41.
- must match (neighbours):
  - Sits on trek-chasm-1/2 and joins end to end with itself. Rails: trek-rail-n / trek-rail-s.
- readAt: 42: planks, nails, knots. 35: three plank stripes. 21: three vertical light bars.
- must-haves:
  - Vertical planks (east-west travel)
  - Umber outline
  - Gold only at the lashing
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
