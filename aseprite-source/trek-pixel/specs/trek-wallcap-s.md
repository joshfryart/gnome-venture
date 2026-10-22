# trek-wallcap-s

- canvas: 42x5 PNG. Transparent background (alpha 0 or 255).
- family: 4 (Auto-join sheets and wall extras). Draw order inside the family: see families.md
- concept: Moss ridge: the game's 'wo_cap' strip (30 wide, 5 high, round ends, moss800 with moss600 dots), drawn in pixels. Cap-n and cap-s are the two halves that meet across a join between an open (stone) wall and an underground (clay) wall; together they form a 10 px ridge sewn shut with thread. This half sits on the BOTTOM edge of the upper tile.
- palette: moss800, mo_shade, mo_base, moss600, mo_rim, thread, thread2 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Transparent background. Same x6..35 span, rows y0..4, rounded ends.
  - Rows: y4 = SEAM ROW (touches the other tile): thread stitch 2 on / 1 off with the SAME x positions as cap-n (x8-9, 11-12, ...). y3 mo_shade, y1-y2 moss800, y0 mo_shade top edge with 1 px mo_rim on x8..9 (lit).
  - Dots: 2x2 moss600 at (16,1), (30,1) and 1 px mo_base at (11,2). Different dot placement from cap-n.
- edge rules:
  - Seam row is y=4 (mirror role of cap-n), same x span and stitch positions.
  - Alpha 0 or 255.
- must match (neighbours):
  - Mates with trek-wallcap-n.
- readAt: 42: moss ridge. 35: green bar. 21: green strip.
- must-haves:
  - Seam row y4
  - Same span as cap-n
  - Not a flipped copy: different dots

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
