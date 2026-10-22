# trek-blight-o-1

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 1 (Open ground). Draw order inside the family: see families.md
- concept: Open blighted ground: dusk-purple soil with the map-key dots (two spore dots) and a faint webbing of thin cracks. Sick and quiet.
- palette: du_base (#4e3a8a ring/field), dusk500, du_rim, du_gloss, du_shade, du_deep (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill du_base.
  - Spore dot 1 5x5 cut corners at x11..15, y13..17: dusk500 body, 1 px du_gloss at (12,14), 1 px du_shade lower-right row/column. Spore dot 2 5x5 at x26..30, y25..29 same treatment.
  - Cracks, 1 px du_deep: (20,8)-(20,11), (21,12)-(23,14), (24,15)-(24,18); and (6,30)-(9,30), (10,31)-(12,33). 3 px gaps allowed.
  - Five single-pixel specks: dusk500 at (32,12),(8,22),(22,34); du_shade at (17,24),(35,19).
  - Nothing green.
- edge rules:
  - Ring x or y 0-2 and 39-41 pure du_base.
  - Both blight-o variants share the ring.
- must match (neighbours):
  - Ring identical to blight-o-2. Underground blight (blight-u) is a different, darker ring (du_shade).
- readAt: 42: two dots + cracks. 35: two dots. 21: purple tile with two lighter dots on a diagonal.
- must-haves:
  - Two spore dots = map key for blight
  - Purple
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
