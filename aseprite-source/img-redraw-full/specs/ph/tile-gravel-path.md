# ph/tile-gravel-path
- canvas: 64x64, mode scene (tile), full-bleed, no halo, no outline.
- subject: A seamless top-down gravel path tile: pale sandy ground scattered with small round pebbles.
- must-read-at-16px: pale sand field dotted with a few darker and lighter pebble specks.
- distinct: busy pebble scatter of four colours, no border, no object; edges must tile (pebbles wrap).
- parts:
  1. ground fill: full 64x64, #d6c9b6 (stone #c9c5bc, slightly warmer)
  2. grey pebbles: ~10 discs 2-4 px, #968f96 (stone #8b8f96)
  3. dark pebbles: ~9 discs 2-4 px, #6a6070 (stone #5b6470)
  4. cream pebbles: ~9 discs 2-3 px, #f4f0e0 (#f1ece0)
  5. tan pebbles: ~8 discs 2-4 px, #dcb06a (soil #c9a96e)
  6. each pebble: 1px lower-right shade in its own ramp, 1px lighter pixel upper-left
- joins: tiles on all four edges; keep 2-3 pebbles cut by the edge and matched on the opposite side.
- face: none.
- notes: scattered, no grid, no clumps; spread evenly, a few pairs touching. Hard pixels only, no dither.
