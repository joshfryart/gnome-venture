# trek-mud-o-2

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 1 (Open ground). Draw order inside the family: see families.md
- concept: Open mud, trampled: the same three-dots key but the dots sit in a triangle, with a boot-print dent and a gluey smear. Looks churned rather than still.
- palette: mud_base, soil900, mud_shade (#5c3520), so_base, so_bounce, so_shade (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill mud_base.
  - Dot 1 (big) 5x5 cut corners at x27..31, y11..15. Dot 2 4x4 at x11..14, y25..28. Dot 3 3x3 plus at x28..30, y30..32 (triangle of dots).
  - Boot-print dent: oval 8x5 at x11..18, y10..14, filled mud_shade, with a 1 px so_base lit lip along its lower-right and 2 px soil900 heel notch at (12,12)-(13,12).
  - Smear: a 2 px thick curved ridge from (18,31) to (26,27) (steps +2,-1), mud_shade with 1 px so_bounce above it.
  - Three 1 px so_shade crumbs: (21,16),(35,22),(8,34).
- edge rules:
  - Ring: x or y in 0-2 and 39-41 is pure so_base (no texture, no outline). Texture and objects live in the safe zone x,y 3..38.
  - Ring pure mud_base.
- must match (neighbours):
  - Ring identical to mud-o-1. Must swap with mud-o-1 with no seam.
- readAt: 42: dent + dots. 35: dots + one oval. 21: dark tile, three dots; the dent shows as a slightly lighter blob.
- must-haves:
  - Three dots in a triangle
  - Oval dent
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
