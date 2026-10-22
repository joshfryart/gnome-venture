# ph/holly-hedge-gate
- canvas: 64x64, mode icon, 1x.
- subject: A wooden garden gate flanked by two dark spiky holly hedges, each with dark inner leaf clusters.
- must-read-at-16px: tan gate in the middle with two darker green hedge masses either side.
- distinct: hedges darker and two-toned (bright moss with a deep green leaf lobe inside), more ragged edge than the box-hedge sibling; add 2px red berry dots.
- parts:
  1. ground strip: y 37..44, x 0..64, #6a4528 at 50%
  2. hedge left: overlapping circles r8 at (0,32), (6,32), x 0..14, base #58a03e
  3. hedge right: circles r8 at (54,32), (64,32), x 50..64, base #58a03e
  4. deep leaf lobes: circle r8 at (10,32) and (54,32), #2e5a2c (moss deep #2f5a2a)
  5. rails: x 15..49, y 28..31 and 36..39, #c4925f
  6. pickets: six 3.6x17 slats from x 16 to 47.6, y 25..42, #dcb06a
  7. brace: 2px line (16,38)->(48,28) #2a1a10
  8. berries: 2px dots #d6322b in the hedges at (5,29), (8,35), (56,30), (59,36)
- joins: none.
- face: none.
- notes: contrast with box-hedge-gate by darker lobes and berries. Hedge min 14px wide; keep berries 2px accents only.
