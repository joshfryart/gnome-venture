# ph/nav-garden
- canvas: 64x64, mode icon, 1x.
- subject: Navigation icon for the garden: a round soil bed with a two-leaf seedling, framed by a wooden fence; tidy and welcoming.
- must-read-at-16px: a round soil bed with two green leaves above it, between fence posts.
- distinct: four pointed fence posts flank the bed (two each side) with two horizontal rails, the seedling rises between them.
- parts:
  1. soil bed: ellipse (32,43) rx20 ry7, base #7a4a1f; top disc ellipse (32,41) rx16 ry4.5 #9a6b3f
  2. seedling stem: 3px line x32, y 25..41 #2f5a2a
  3. left leaf: teardrop (32,28)->tip (17,19), base #6a9a3a
  4. right leaf: teardrop (32,25)->tip (47,14), base #7ab55c
  5. fence posts: rects x 7..13, 16..22, 42..48, 51..57, y 30..50, pointed tops to y 25, base #dcb06a
  6. rails: rects x 6..57, y 36..38 and y 43..45, base #c4925f (no rail through the middle gap)
- joins: none.
- face: none.
- notes: chunky icon, parts min 3px. Posts overlap the bed edges with contours. Rails stop at the inner posts so the seedling stays clear.
