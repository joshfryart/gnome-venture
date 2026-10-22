# trek-floor-o-1

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 1 (Open ground). Draw order inside the family: see families.md
- concept: Sunlit packed-earth trail: the plain default open floor and the COLOUR MASTER for the open set. Calm. A pebble cluster upper left, a dashed scuff trail lower right, one moss tuft.
- palette: so_base (field and ring), so_rim, so_gloss, so_bounce, so_shade, umber2, mo_base, mo_rim, mo_shade (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill 42x42 with so_base.
  - Pebble cluster (3 stones): A 5x4 at (9,9), B 4x3 at (15,12), C 3x3 at (11,15). Body so_rim, 1 px so_gloss on the upper-left pixel, lower-right L outline (right column + bottom row) umber2.
  - Scuff trail, 1 px so_bounce dashes (3 on / 2 off): (20..22,30), (25..27,30), (30..32,29), (34..36,27). Put 1 px so_shade under the 2nd and 4th dash.
  - Moss tuft, base at (30,15): left blade (29,14),(28,13),(28,12); right blade (31,14),(32,13),(32,12),(32,11); mo_base, tips (28,12) and (32,11) mo_rim, root pixels (30,15),(30,16) mo_shade.
  - Six dust specks, 1 px so_gloss: (24,9),(33,21),(14,25),(8,33),(27,35),(36,12).
- edge rules:
  - Ring: x or y in 0-2 and 39-41 is pure so_base (no texture, no outline). Texture and objects live in the safe zone x,y 3..38.
  - Variants floor-o-1..3 share the identical ring, so any variant can sit next to any other (and next to itself) with no seam.
- must match (neighbours):
  - Is the colour master: floor-o-2, floor-o-3, crystal-o and wall-o-auto's apron must use its exact so_base.
  - Next to mud-o, roots-o, blight-o: flat colour step at the tile line is expected (ring colours differ by terrain).
- readAt: 42: pebbles and tuft clear. 35: pebbles read as a 3-dot cluster. 21: flat warm brown with one green fleck and a light cluster; no texture mush.
- must-haves:
  - Cluster of three stones with umber lower-right edge
  - Green tuft
  - Ring untouched
  - No crescent, no gradient

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
