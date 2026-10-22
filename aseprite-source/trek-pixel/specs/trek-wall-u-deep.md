# trek-wall-u-deep

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 4 (Auto-join sheets and wall extras). Draw order inside the family: see families.md
- concept: Deep clay rock: the core of a thick underground wall, darker tan with slump bands and a few embedded pebbles.
- palette: wl_shade (field), wl_deep, wl_base, wl_bounce, su_deep (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Same strata skeleton as wall-u-auto: lines centred at y=6, 16, 27, 37 (period 21 repeated), wave offsets by x mod 7 = [0,-1,-1,0,1,1,0].
  - Body wl_shade (#9a6b3f); each strata line 1 px wl_deep with 1 px wl_base lit line above it; band bottoms wl_bounce. The tile edge lines y=0 and x=0 are wl_shade like the auto-sheet interior.
  - Embedded pebbles 4x3 at (9,10),(29,20),(15,31): wl_base body, 1 px wl_gloss upper-left, lower-right wl_deep (1 px L), no umber.
  - Hairs: wl_deep 1 px, 4 px long at (22,7)-(22,11) and (6,28)-(7,32). Pit pixels su_deep at (34,6),(12,22).
- edge rules:
  - Fully opaque. Waves continuous at x=0/x=42 (period 7).
- must match (neighbours):
  - Appears only when all 8 neighbours are wall-u; meets trek-wall-u-auto interior across a strata line.
- readAt: 42: dark clay with bands. 35: banded dark tan. 21: darker than the wall interior.
- must-haves:
  - Darker than wall-u-auto interior
  - No outline
  - Wave-continuous edges

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
