# ph/holly-hedge-straight
- canvas: 64x64, mode scene (tile piece), 1x. Bleeds left and right edges, no halo.
- subject: A straight run of dark holly hedge crossing the tile, dotted with bright red berries; festive and prickly-looking.
- must-read-at-16px: green band with a regular row of red dots on it.
- distinct: red berry pairs (3 px dots) pushed into the hedge at x 2,5,14,18,27,30,40,43,53,56; berries are the signature (box and lavender siblings have none).
- parts:
  1. soil strip: x 0..63, y 37..43, #7a4a1f
  2. hedge body: band y 24..40 of overlapping r 8 puffs spaced 6.4 px, base #4a8a3e (darker, holly), shade #2f5a2a
  3. top highlight line: x 0..63, y 27..28, #a4b86a
  4. berry pairs: 3x3 round dots at (2,31),(5,31),(14,31),(18,31),(27,31),(30,31),(40,31),(43,31),(53,31),(56,31), base #dd3a2a, 1px gloss #ff9158 upper-left, shade #ae2a2a lower-right
  5. spiky nicks: 1 px lighter #7ab55c notches on the top scallop edge between berry pairs
- joins: tileable left to right; berry pattern repeats so x 0 and x 63 match.
- face: none.
- notes: rhythm pair, gap, pair; do not scatter randomly. Berries must not touch the outline. Top edge has sharper points than the box hedge.
