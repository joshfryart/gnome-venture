# trek-roots-o-1

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 1 (Open ground). Draw order inside the family: see families.md
- concept: Open ground knotted with roots: one thick root crossing diagonally, moss tufts on it, a grey-green base. The map key is the moss tuft (two V blades).
- palette: or_base (field, ring), or_shade, or_deep, or_hi (#b9c58a), so_base, so_shade, so_rim, mo_base, moss600, mo_rim (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill or_base.
  - Main root, 3 px thick, from (5,28) to (36,16) stepped (about 1 px up per 2.5 px right): body so_base, upper row so_rim, lowest row so_shade, 1 px or_deep contact line under it. A knot 5x5 at (19..23,19..23) with so_shade ring and so_base core.
  - Tuft 1 (key): base (12,30); two V blades: left (11,29),(10,28),(10,27),(9,26); right (13,29),(14,28),(14,27),(15,26),(15,25). moss600 with mo_rim tips and mo_shade base pixel.
  - Tuft 2: base (30,17) on the root: left (29,16),(28,15),(28,14); right (31,16),(32,15),(32,14),(33,13). Same colours.
  - Speckles: 1 px or_hi at (24,10),(8,12),(33,33); 1 px or_shade at (16,10),(26,35),(36,26).
- edge rules:
  - Ring x or y 0-2 and 39-41 pure or_base. The main root starts at x>=5 and ends at x<=36 (does not cross the edge).
  - roots-o-1 and roots-o-2 share the same ring and swap freely.
- must match (neighbours):
  - Ring identical to roots-o-2. Different from floor-o ring by design.
- readAt: 42: root, knot, two tufts. 35: diagonal root and two green V tufts. 21: grey-green tile with a brown diagonal stroke and green ticks.
- must-haves:
  - Diagonal root
  - Two V-shaped tufts
  - Grey-green not brown
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
