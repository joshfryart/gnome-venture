# trek-floor-o-3

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 1 (Open ground). Draw order inside the family: see families.md
- concept: Meadow edge: the trail where grass has crept in. A big grass clump upper right, two flat moss blotches, a leaf and one small stone. The greenest open floor.
- palette: so_base, so_shade, so_rim, umber2, mo_base, mo_rim, mo_shade, mo_deep, moss600 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill so_base.
  - Grass clump, base line y=19 from x=27 to x=34: 5 blades 1 px wide moss600 with heights 8,6,9,5,7 at x=27,29,31,33,34 (tips go up from y=19). Tips are mo_rim, the right-hand pixel column of each blade is mo_shade where the blade is 5+ px tall. Clump roots: 2 px mo_deep at (29..30,20) and (32..33,20).
  - Moss blotches (flat, no outline): 6x3 at (8,20) and 7x3 at (22,32): top row mo_base, lower two rows mo_shade, 1 px mo_rim on the top-left pixel.
  - Leaf 4x3 at (10,28): mo_shade body, 1 px mo_rim upper-left, 1 px so_shade stem at (9,30).
  - One small stone 4x3 at (13,10): so_rim body, 1 px so_gloss upper-left, lower-right L outline umber2.
  - No scuffs, no cracks.
- edge rules:
  - Ring: x or y in 0-2 and 39-41 is pure so_base (no texture, no outline). Texture and objects live in the safe zone x,y 3..38.
  - Variants floor-o-1..3 share the identical ring, so any variant can sit next to any other (and next to itself) with no seam.
- must match (neighbours):
  - Ring identical to floor-o-1 and floor-o-2.
  - Grass clump must not touch the ring (top of tallest blade y>=10).
- readAt: 42: clump + blotches clear. 35: clump reads as a green spiky tuft. 21: noticeably greener than the other two floors, no single-pixel noise.
- must-haves:
  - Clump of 5 blades, tallest 9 px
  - Two moss blotches
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
