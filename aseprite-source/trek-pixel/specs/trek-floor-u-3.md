# trek-floor-u-3

- canvas: 42x42 PNG. Opaque, full-bleed ground tile (no transparent pixel).
- family: 2 (Underground ground). Draw order inside the family: see families.md
- concept: Cave floor with worm tracks: a long S-shaped trail of small bumps, two burrow holes, and a moss-like dim lichen patch. The quiet variant, mostly flat.
- palette: su_base, su_shade, su_bounce, su_deep, su_rim, ur_base, ur_hi (#6e6e48) (names from palette.md)
- layout (pixels, x right, y down, 0-based, inclusive):
  - Fill su_base.
  - Worm track, 2 px wide, S curve from (6,12) to (34,30): alternating 2-px bumps su_bounce with 1 px su_shade below each (track of 9 bumps, spacing 3 px).
  - Burrow holes: 4x3 ellipses su_deep at (12,26) and (29,11); each with 1 px su_rim lit lip upper-left and 1 px su_shade under.
  - Lichen patch: 8x5 irregular blob at x20..27, y18..22 in ur_base with 1 px ur_hi on top row (flat, no outline).
  - Flecks: su_rim 1 px at (9,34),(36,17),(18,8).
- edge rules:
  - Ring x or y 0-2 and 39-41 pure su_base. Texture in the safe zone 3..38.
  - The game's lantern vignette is applied by the page over the whole window; do not paint any vignette or darkening into the tile.
- must match (neighbours):
  - Ring identical to floor-u-1 and floor-u-2.
- readAt: 42: track, holes, lichen. 35: a bumpy S-line. 21: smooth warm tile with one olive patch.
- must-haves:
  - S-shaped track
  - Two burrow holes
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
