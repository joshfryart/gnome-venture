# ph/land-wetland
- canvas: 64x64, mode scene (tile), 1x full-bleed, rounded 7px corners.
- subject: A wetland landscape tile: pale sky over cattails standing in blue water with a lily pad and pink flower, quiet and marshy.
- must-read-at-16px: four tall brown cattail sticks with dark tips standing in blue water under pale sky.
- distinct: four cattails (two left, two right) framing a green lily pad with a single pink bloom in the centre water.
- parts (back to front):
  1. sky: rrect 3..60 x 3..60, #a9d6ea (water gloss family #c8ecdc / #8fcbd8)
  2. water: block y 36..60, #3f93b2
  3. reed bank: wavy strip y 33..38, #58a03e
  4. ripples: two 2px wavy lines (12..28,48) and (36..44,52), #a9d6ea
  5. cattail stems: 2px lines at x 14 (y 24..44), x 20 (y 20..44), x 46 (y 22..44), x 52 (y 26..44), #c4925f
  6. cattail heads: ellipses 4x8 at (14,22), (20,18), (46,20), (52,24), #8c4a1a
  7. lily pad: ellipse (34,48) rx7 ry3, #58a03e
  8. pink bloom: 3px blob at (36,47), #e46a9b
- joins: none.
- face: none.
- notes: tile bleeds to frame, no halo; 2px selective outline on the tile edge. Heads overlap the sky; heights stagger.
