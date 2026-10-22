# trek-clay-wet

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 3 (Water and clay). Draw order inside the family: see families.md
- concept: Wet clay: orange-brown glossy clay with the map-key colon (two dots stacked) and two slumped wavy bands. Slick, with a lit sheen, no cracks.
- palette: cl_base (#944c1f ring, field), cl_gloss, cl_rim, cl_bounce, cl_shade, soil300, soil900 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill cl_base.
  - Sheen pad: rounded rect 30x30 at x6..35, y6..35, corners cut 4 px, colour cl_rim (flat); NO outline; this stays >= 6 px from the ring.
  - Slump bands (wavy, amplitude 2, period 8 px): band A from (6,10) to (35,10) 2 px thick cl_gloss with a 1 px cl_shade line under it; band B from (6,32) to (35,32) same. Phase of B shifted 4 px relative to A.
  - Colon (key): dot 1 7x7 cut corners at x18..24, y12..18; dot 2 7x7 at x18..24, y24..30: body soil300, 1 px soil900 lower-right, 1 px cl_gloss upper-left glint.
  - Gloss comma: 3 px cl_gloss at (9..11,17) and 1 px at (30,22).
- edge rules:
  - Ring pure cl_base. Sheen pad does not reach the ring.
  - Wavy bands do not cross the ring.
- must match (neighbours):
  - Ring is a unique clay orange; used next to clay-loose and walls-u. Flat step at the line is expected.
- readAt: 42: colon + bands. 35: colon + bands. 21: glossy orange tile with two cream dots stacked in the middle.
- must-haves:
  - Two dots stacked vertically (colon)
  - Glossy slumped bands
  - No cracks

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
