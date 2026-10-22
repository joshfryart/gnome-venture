# trek-blight-o-2

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 1 (Open ground). Draw order inside the family: see families.md
- concept: Open blighted ground, further gone: one large blister (pustule) with a drip trail instead of webbing, three small dots. More dramatic than blight-o-1.
- palette: du_base, dusk500, du_rim, du_gloss, du_shade, du_deep (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill du_base.
  - Blister 9x7 at x23..31, y10..16: outline du_deep (1 px), fill dusk500, du_rim ring inside on upper-left, du_gloss comma (3 px) at (25..27,11), du_shade lower-right 2 px.
  - Drip trail: from (27,17) down to (27,24), 2 px wide du_shade with 1 px du_deep on the right; ends in a 4x3 puddle du_shade at x25..28, y25..27.
  - Three small dots 3x3 plus: dusk500 at centres (11,14), (14,28), (33,32); each with 1 px du_gloss.
  - Two specks du_deep (8,22),(19,35).
- edge rules:
  - Ring pure du_base.
- must match (neighbours):
  - Ring identical to blight-o-1; must swap with it seamlessly.
- readAt: 42: blister with drip. 35: blister and dots. 21: purple tile with one larger light blob and dots.
- must-haves:
  - One big blister, three small dots
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
