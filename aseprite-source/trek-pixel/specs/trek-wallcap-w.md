# trek-wallcap-w

- canvas: 5x42 PNG. Transparent background (alpha 0 or 255).
- family: 4 (Auto-join sheets and wall extras). Draw order inside the family: see families.md
- concept: Moss ridge: the game's 'wo_cap' strip (30 wide, 5 high, round ends, moss800 with moss600 dots), drawn in pixels. Cap-n and cap-s are the two halves that meet across a join between an open (stone) wall and an underground (clay) wall; together they form a 10 px ridge sewn shut with thread. Vertical: sits on the LEFT edge (x0..4) of the right tile, facing a wall of the other style on its west.
- palette: moss800, mo_shade, mo_base, moss600, mo_rim, thread, thread2 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Transparent background. Cap spans y6..35, columns x0..4, rounded ends.
  - Columns: x0 = SEAM COLUMN: thread stitch 2 on / 1 off, same y positions as cap-e (y8-9, 11-12, ...). x1 mo_shade, x2-x3 moss800, x4 mo_shade underside.
  - Dots: 2x2 moss600 at (2,17), (2,29); 1 px mo_base at (3,10); 1 px mo_rim at (1,9). Placement differs from cap-e.
- edge rules:
  - Seam column x=0, same y span as cap-e.
  - Alpha 0 or 255.
- must match (neighbours):
  - Mates with trek-wallcap-e.
- readAt: 42: moss ridge, vertical. 35: green bar. 21: green strip.
- must-haves:
  - Seam column x0
  - Same span as cap-e
  - Not a flipped copy

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
