# trek-wallcap-n

- canvas: 42x5 PNG. Transparent background (alpha 0 or 255).
- family: 4 (Auto-join sheets and wall extras). Draw order inside the family: see families.md
- concept: Moss ridge: the game's 'wo_cap' strip (30 wide, 5 high, round ends, moss800 with moss600 dots), drawn in pixels. Cap-n and cap-s are the two halves that meet across a join between an open (stone) wall and an underground (clay) wall; together they form a 10 px ridge sewn shut with thread. This half sits on the TOP edge of the lower tile.
- palette: moss800, mo_shade, mo_base, moss600, mo_rim, thread, thread2 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Transparent background. Cap body spans x6..35, rows y0..4, rounded ends (end columns 3 px high at y1..3).
  - Rows: y0 = SEAM ROW (touches the other tile): thread-gold stitch, 2 on / 1 off from x8: thread pixels at x8-9, 11-12, 14-15, ... up to x33, with mo_shade between. y1 mo_shade, y2-y3 moss800, y4 mo_shade underside.
  - Dots: 2x2 moss600 at (12,2), (22,2); 1 px mo_base at (28,1); 1 px mo_rim at (9,1).
- edge rules:
  - Row y=0 is the seam row; cap-s row y=4 must show the same x-span (x6..35) and the same stitch positions so the two halves mate.
  - Alpha 0 or 255.
- must match (neighbours):
  - Mates with trek-wallcap-s (stitch dashes continue through the seam as one line of 2-on/1-off).
- readAt: 42: moss ridge with gold dashes. 35: green bar. 21: green strip, stitch may vanish.
- must-haves:
  - Exact x6..35 span
  - Stitch on row y0
  - Round ends

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
