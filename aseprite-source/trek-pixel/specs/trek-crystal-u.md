# trek-crystal-u

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 2 (Underground ground). Draw order inside the family: see families.md
- concept: A glow crystal in the dark: a tall gold diamond with two small shards beside it, on a lit floor pool with sparks. Bigger glow than crystal-o, clearly a different layout.
- palette: su_base (ring), su_gloss, su_rim, su_deep, gd_gloss, gd_rim, gd_base, gd_bounce, gd_shade, gd_deep, umber1, umber2, umber3 (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill su_base. Lit pad: stepped ellipse su_rim, 32 wide x 22 tall centred (21,26), then a smaller su_gloss ellipse 18x10 centred (21,28) ON TOP (two concentric steps, not a gradient). Keep >= 4 px from the ring.
  - Main crystal: diamond 17 wide x 28 tall: top tip (21,4), bottom tip (21,31), side tips (13,17) and (29,17). Outline umber1/umber2/umber3 by light (top-left, left-bottom/top-right, bottom-right).
  - Fill: left facet gd_rim with 3 px gd_gloss comma at (15..17,12..16); right facet gd_base; lower-right 2 px gd_shade, 1 px gd_bounce inside; bottom tip gd_deep. Inner diamond 8x14 centred (21,17), 1 px gd_deep outline, fill gd_gloss.
  - Shard A: diamond 7x12 at x6..12, y22..33 (left), shard B: diamond 6x10 at x30..35, y25..34 (right). Outlined umber2/umber3, fill gd_base with gd_gloss left edge pixel and gd_shade lower-right.
  - Four sparks (3 px plus gd_gloss), centres (6,6), (35,6), (5,19), (36,19).
- edge rules:
  - Ring x or y 0-2 and 39-41 pure su_base. Texture in the safe zone 3..38.
  - Ring pure su_base. Lit pad and shard B must not reach the ring (shard B bottom at y<=34).
- must match (neighbours):
  - Ring identical to floor-u-1.
- readAt: 42: main crystal, shards, pad. 35: tall diamond with two small ones. 21: bright gold diamond on a lit patch.
- must-haves:
  - Diamond silhouette = map key
  - Two shards
  - No halo ring
  - Umber outline only on crystals

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
