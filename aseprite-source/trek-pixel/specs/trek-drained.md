# trek-drained

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 3 (Water and clay). Draw order inside the family: see families.md
- concept: A drained pool: wet mud with the last small sheen of water in a dried-out basin, mud cracks around its rim. The 'water went away' tile; mud in feel, water in a hint.
- palette: mud_base (ring), mud_shade, soil900, so_bounce, wa_shade, wa_base, wa_rim, wa_gloss (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill mud_base (#7a4a1f).
  - Basin: irregular blob 26x20 at x8..33, y9..28, flat mud_shade (no outline); its rim has a 1 px so_bounce lit edge along the upper-left side only.
  - Last water: blob 14x8 at x14..27, y15..22: outer wa_shade, inner 10x4 wa_base at x16..25, y17..20; one 4 px wa_gloss arc on the upper-left (x16..19, y17) and one 3 px wa_rim ripple under it.
  - Mud dots outside the basin: 5x5 cut-corner soil900 at x6..10, y31..35 and 4x4 at x32..35, y31..34; 1 px so_bounce lip on each lower-right.
  - Rim cracks: three 1 px soil900 ticks of 3 px at (7,18),(34,20),(21,30) pointing outward from the basin.
- edge rules:
  - Ring pure mud_base (#7a4a1f). Basin stays >= 5 px from ring.
- must match (neighbours):
  - Ring identical to mud-o, mud-u. Remains visibly different from mud tiles through the sheen.
- readAt: 42: basin, sheen, cracks. 35: brown tile with a small blue patch. 21: blue sliver must still read inside a brown tile.
- must-haves:
  - Blue patch smaller than the basin
  - Cracks around
  - Mud ring pure

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
