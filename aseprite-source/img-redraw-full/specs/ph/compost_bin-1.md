# ph/compost_bin-1
- canvas: 64x64, mode sticker, 1x.
- subject: A wooden slatted compost bin with a heap of dark scraps piled above the rim, a leaf and colourful scraps on top; first (small) tier of the compost bin.
- must-read-at-16px: a brown slatted box with a dark mound heaped on top.
- distinct: heap of dark compost bulging above the box with a green leaf, and corner posts taller than the slats; no lid.
- parts:
  1. shadow ellipse (32,58) rx24 ry4, #6a4528
  2. compost heap: dome x 12..52, y 9..33 (peak at (32,9)), base #44281c (soil #3d2a1c)
  3. scraps on heap: discs r2: green (24,20) #58a03e, orange (38,17) #e0501f, gold (33,25) #e8a317; leaf wedge (42,24)->(46,21)->(47,25) #7ab55c
  4. bin box: rrect x 10..54, y 30..56 (r2), base #a5663a (wood #a8582f)
  5. three slats: rrect x 10..54, 4 px tall at y 34, 43, 51, lighter #b6814d (wood rim #d9a660)
  6. corner posts: rrect x 8..13 and x 51..56, y 28..56, #b6814d with 1 px #f0d49a rim
- joins: none; slat nails as 1 px #5e2f1e at post ends.
- face: none.
- notes: posts overhang the box by 2 px each side so the silhouette steps. Wood has no stitch. Heap darkest, wood mid.
