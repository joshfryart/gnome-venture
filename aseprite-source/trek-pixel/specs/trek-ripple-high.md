# trek-ripple-high

- canvas: 42x42 PNG. Transparent background (alpha 0 or 255).
- family: 3 (Water and clay). Draw order inside the family: see families.md
- concept: High-water ripples: bolder double waves plus spray dots. This is the map-key sign for HIGH water, so it must be unmistakable on top of a water tile.
- palette: wa_gloss, wa_rim, wa_base (for shadow under the crests) (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Transparent background, 42x42.
  - Strand A (the game's double wave 'q6-4 12 0 q6 4 12 0'), baseline y=17. Hump x8..20: feet (8..9,17),(19..20,17) wa_rim; shoulders (10..11,16),(17..18,16) wa_gloss; crest (12..16,15) wa_gloss; under-crest (12..16,16) wa_rim. Trough x21..33: feet (21..22,17),(32..33,17) wa_rim; shoulders (23..24,18),(30..31,18) wa_rim; bottom (25..29,19) wa_rim with (25..29,18) wa_base above it.
  - Strand B (same idea, shorter), baseline y=29. Hump x12..23: feet (12..13,29),(22..23,29) wa_rim; shoulders (14..15,28),(20..21,28) wa_gloss; crest (16..19,27) wa_gloss; under-crest (16..19,28) wa_rim. Trough x24..34: feet (24..25,29),(33..34,29) wa_rim; shoulders (26..27,30),(31..32,30) wa_rim; bottom (28..30,31) wa_rim.
  - Spray: four single wa_gloss pixels at (6,8), (35,12), (9,36), (33,35).
- edge rules:
  - Every opaque pixel is >= 3 px from all edges; strands end well inside.
- must match (neighbours):
  - Lies on top of trek-water-auto interior. The ripple pair is the only difference between a pool tile and a high-water tile.
- readAt: 42: two strands plus spray. 35: two wavy lines. 21: two clear wavy ticks (must remain visible, brighter than ripple-pool).
- must-haves:
  - Two double-wave strands
  - Wavier and brighter than ripple-pool
  - Alpha 0 or 255 only

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
