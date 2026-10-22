# trek-mud-u

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 2 (Underground ground). Draw order inside the family: see families.md
- concept: Underground mud: wet, black-brown mud with two dark holes (map key) and a stepped drip ring around the larger hole where something fell in.
- palette: mud_base, soil900, mud_shade (#5c3520), so_base, so_bounce, wa_rim (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill mud_base (#7a4a1f), same ring as mud-o.
  - Dot 1 (key) 6x6 cut corners at x13..18, y13..18 soil900, 1 px so_base wet lip on lower-right outside, 1 px mud_shade upper-left inside. Dot 2 4x4 at x28..31, y26..29 same.
  - Drip ring around dot 1: stepped circle of radius 7, 1 px so_bounce on its upper-left arc only (6 px) and 1 px mud_shade on the lower-right arc (6 px). No full ring.
  - Water bead: 2x2 wa_rim at (20,9) with 1 px wa_gloss (#c8ecdc) top-left.
  - Flecks mud_shade at (7,28),(34,12),(22,35).
- edge rules:
  - Ring x or y 0-2 and 39-41 pure mud_base. Texture in the safe zone 3..38.
  - The game's lantern vignette is applied by the page over the whole window; do not paint any vignette or darkening into the tile.
- must match (neighbours):
  - Ring identical to mud-o-1/2: mud tiles of the open and underground sets can meet with no seam.
- readAt: 42: holes, ring arcs, bead. 35: two holes. 21: dark brown with two darker dots.
- must-haves:
  - Two dark holes
  - Drip arcs only on lit/shade sides
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
