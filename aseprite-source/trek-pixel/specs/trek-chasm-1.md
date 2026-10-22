# trek-chasm-1

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 3 (Water and clay). Draw order inside the family: see families.md
- concept: A drop into darkness: deep teal-black with a pit in the middle and two thin wave arcs (the game's chasm ripple). It must feel empty, not wet.
- palette: ch_base (ring, field), ch_shade, ch_deep, ch_gloss (#2d6479), ch_rim (#24556b) (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill ch_base (#143645).
  - Pit: stepped oval 18x11 at x12..29, y10..20, ch_shade; inner oval 10x5 at x16..25, y13..17, ch_deep.
  - Wave arcs (the game's chasm_rip, 1 px ch_gloss, arc rises 2 px): arc 1 from (8,23) to (20,23) with top at y=21; arc 2 from (22,32) to (33,32) top at y=30. Under each arc 1 px ch_rim for the first half.
  - Three single-pixel ch_rim speckles at (6,12),(34,17),(15,36).
- edge rules:
  - Ring x or y 0-2 and 39-41 pure ch_base. Pit stays >= 4 px inside.
  - chasm-1 and chasm-2 share the ring.
- must match (neighbours):
  - Ring identical to chasm-2. The bridge tiles are drawn OVER a chasm tile; their gaps show this art.
- readAt: 42: pit + arcs. 35: pit + arcs. 21: dark tile with a darker centre; arcs fade but dark must dominate.
- must-haves:
  - Reads as a drop (darkest tile on the map)
  - Two wave arcs
  - No black pixel
  - Ring untouched

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
