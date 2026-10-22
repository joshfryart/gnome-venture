# trek-mud-o-1

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 1 (Open ground). Draw order inside the family: see families.md
- concept: Open mud with the map-key three dark wet dots, one big and two small, in a diagonal line. Dark, matte, with a faint lit rim on each hole.
- palette: mud_base, soil900, mud_hi (so_base), so_bounce, mud_shade (#5c3520), so_shade (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill mud_base (#7a4a1f).
  - Dot 1 (big) stepped disc 5x5 with cut corners, x12..16, y12..16, soil900. Dot 2 4x4 cut corners x27..30, y23..26. Dot 3 3x3 plus cross x14..16, y30..32.
  - Each dot: 1 px so_base 'wet lip' on its lower-right outside edge (offset +1,+1 from the lower-right pixels) and 1 px mud_shade on its upper-left inside pixel (sunk shadow).
  - Mud sheen: three 1 px so_bounce dashes (3 long): (21..23,18), (31..33,32), (7..9,36).
  - Two soft ridges 8x2 mud_shade at (20,10) and (6,27).
- edge rules:
  - Ring: x or y in 0-2 and 39-41 is pure so_base (no texture, no outline). Texture and objects live in the safe zone x,y 3..38.
  - Ring is pure mud_base (#7a4a1f), same for mud-o-2, mud-u and drained.
- must match (neighbours):
  - Exact ring match with mud-o-2 and mud-u. Water-auto's bank apron uses the same colour.
- readAt: 42: three dots and ridges. 35: three dots clear. 21: dark brown tile with three dark specks in a diagonal.
- must-haves:
  - Three dots (big to small) = map key for mud
  - Dark matte look
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
