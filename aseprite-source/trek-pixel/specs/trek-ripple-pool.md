# trek-ripple-pool

- canvas: 42x42 PNG. Transparent background (alpha 0 or 255).
- family: 3 (Water and clay). Draw order inside the family: see families.md
- concept: Calm pool glints: a transparent overlay for a water tile. Two short, single, low waves. Quiet: this is NOT high water.
- palette: wa_gloss (#c8ecdc), wa_rim (#a9d6ea) (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Transparent background (alpha 0 everywhere except the strokes). 42x42.
  - Wave 1: a single arc, 14 wide (x10..23), rising 2 px: crest row y=21 x14..19 (6 px) wa_gloss, shoulders (12..13,22) and (20..21,22) wa_gloss, feet (10..11,23) and (22..23,23) wa_rim. One wa_rim px under the crest's left half at (14..16,22).
  - Wave 2: shorter arc 10 wide: crest y=11 x25..28 wa_gloss; shoulders (23..24,12),(29..30,12) wa_gloss; feet (21..22,13),(31..32,13) wa_rim.
  - Nothing else. No dots, no spray.
- edge rules:
  - Every opaque pixel is >= 3 px from all four edges. Two waves only.
- must match (neighbours):
  - Lies on top of trek-water-auto interior (or on any water). Never edges the tile; no seam.
- readAt: 42: two thin arcs. 35: two arcs. 21: two tiny light ticks; fine if they nearly vanish (calm).
- must-haves:
  - Exactly two single arcs
  - Fewer and smaller than ripple-high
  - Alpha is 0 or 255 only

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
