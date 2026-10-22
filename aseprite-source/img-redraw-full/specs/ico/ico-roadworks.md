# ico/ico-roadworks
- canvas: 64x64, mode icon, 1x.
- subject: A roadworks barrier: a wide cream plank with three diagonal red stripes, held up by two short brown legs; a construction warning sign.
- must-read-at-16px: a wide striped board (red/cream diagonals) on two legs.
- distinct: horizontal striped barricade with two posts; red-cream diagonals are unique among icons.
- parts:
  1. legs: two rects x 12..20 and x 42..50, y 36..58, base #c4925f (wood #b07a45)
  2. board: rrect x 8..56, y 14..38 (r3), base #f8eed2 (pale)
  3. stripe 1: parallelogram (13,14),(23,14),(17,38),(8,38), base #9c2a1e (red shade)
  4. stripe 2: parallelogram (30,14),(40,14),(34,38),(24,38), #9c2a1e
  5. stripe 3: parallelogram (47,14),(56,14),(52,38),(41,38), #9c2a1e
- joins: thread-gold seam along the board bottom edge y 36, 2 on 1 off, x 10..54.
- face: none.
- notes: legs at least 3px wide (use 8). Cream board is cream-safe (umber outline all round, gloss #fff3c8). Keep 3px halo margin from the frame.
