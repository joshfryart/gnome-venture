# ph/land-desert
- canvas: 64x64, mode scene, 1x, full-bleed rounded-square tile.
- subject: Desert landscape tile: sandy yellow sky with a small sun, layered dunes below, a tall green saguaro cactus with two arms, and a small grey rock beside it.
- must-read-at-16px: a green two-armed cactus silhouette against warm yellow.
- distinct: a single saguaro with a low left arm and short right arm, two dune layers (tan, gold), and a tiny grey rock with a pale cone at the lower right.
- parts:
  1. tile base: rrect x 3..60, y 3..60 (r7), #f5cf6a (gold), bleeds to the frame
  2. sun: circle (48,14) r5 #f5cf6a with a 1px #fff3c8 glint at (46,12)
  3. far dune: wavy band y 36..60, #dcb06a (wood rim)
  4. near dune: wavy band y 44..60, #e8a317 (gold base), stepped darker
  5. cactus trunk rrect x 20..26, y 22..49 (r3) #58a03e; left arm rrect x 12..15, y 30..39 plus bar x 12..23, y 38..40; right arm rrect x 27..30, y 28..36 plus bar x 23..30, y 35..37; all #58a03e
  6. cactus highlight: 1px column x 21..22, y 26..44 #7ab55c
  7. rock: circle (47,50) r3 #968f96 with a cone (42,48),(45,44),(48,48) #d6c9b6
- joins: thread-gold edge stitch 2px inside the tile edge.
- face: none.
- notes: no halo; arms joined cleanly to the trunk, no gaps.
