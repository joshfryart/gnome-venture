# trek-floor-o-2

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 1 (Open ground). Draw order inside the family: see families.md
- concept: Dry cracked dust: a sun-baked patch of the trail with a hairline crack, flat sandy flecks and a fallen twig. Drier and sparser than floor-o-1.
- palette: so_base, so_shade, so_rim, so_gloss, so_deep, wd_shade, wd_rim (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill so_base.
  - Hairline crack, 1 px so_shade: (8,22)-(13,22), (14,23), (15,24)-(15,25), (16,25)-(21,25), (22,26), (23,27)-(23,28), (24,28)-(30,28). Branch: (15,26),(14,27),(14,28),(13,29),(14,30).
  - Lit lip: 1 px so_rim directly above every third crack pixel (starting at (10,21)).
  - Three flat sandy flecks 6x2 so_rim at (24,10), (9,12), (27,33); each gets 1 px so_gloss at its left end.
  - Fallen twig, 2 px thick, from (12,34) to (19,31) stepped: wd_shade, with 1 px wd_rim above the thicker end. Two tiny so_deep knots (2x2) at (33,17) and (7,29).
  - No moss on this variant.
- edge rules:
  - Ring: x or y in 0-2 and 39-41 is pure so_base (no texture, no outline). Texture and objects live in the safe zone x,y 3..38.
  - Variants floor-o-1..3 share the identical ring, so any variant can sit next to any other (and next to itself) with no seam.
- must match (neighbours):
  - Ring identical to floor-o-1 and floor-o-3 (pure so_base).
  - The crack must stay inside the safe zone: it does not cross any edge.
- readAt: 42: crack and twig clear. 35: crack reads as a dark squiggle. 21: tile looks drier and paler than floor-o-1 (flecks), twig as a short dark dash.
- must-haves:
  - Crack with branch
  - Twig 2 px thick
  - No green
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
