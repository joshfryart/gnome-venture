# trek-wall-o-deep

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 4 (Auto-join sheets and wall extras). Draw order inside the family: see families.md
- concept: Deep stone: the heart of a thick open wall, one step darker than the auto-sheet interior. Fully surrounded, no outline, speckled with lit pits.
- palette: sn_shade (field), sn_deep (mortar), sn_base, sn_rim, ink, moss800 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Same skeleton as wall-o-auto, doubled over 42x42: mortar rows y=0, 10, 21, 31; course A joints x=0,10,21,31; course B joints x=5,15,26,36.
  - Stones: body sn_shade (#5b6470), top row sn_base, bottom row sn_deep. Mortar lines sn_deep EXCEPT the tile edge lines y=0 and x=0, which are sn_shade like the auto-sheet interior, so a deep tile meets a normal interior tile with a mortar line.
  - Speckles (lit pits): 3x3 sn_base discs with 1 px sn_rim at (7,5),(27,13),(15,25),(33,35) and 1 px sn_deep dots at (18,6),(37,20),(5,33).
  - One moss800 patch 3x2 at (12,34) and one crack 1 px ink (26,3)-(27,6), kept 3 px from the edge.
- edge rules:
  - Fully opaque. No apron. Self-tiling: opposite edges are identical in the skeleton lines.
- must match (neighbours):
  - Appears only when all 8 neighbours are wall of the same style; meets trek-wall-o-auto interior across mortar lines.
- readAt: 42: dark speckled stone. 35: dark brick-ish tile. 21: noticeably darker than the wall interior.
- must-haves:
  - Darker than wall-o-auto interior
  - No outline
  - Speckles

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
