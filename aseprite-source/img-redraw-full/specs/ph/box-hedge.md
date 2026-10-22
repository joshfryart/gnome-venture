# ph/box-hedge
- canvas: 64x64, mode sticker, 1x.
- subject: A neatly clipped box hedge: a tidy low block of dense green foliage with small leaf clumps on its face; calm, formal garden piece.
- must-read-at-16px: one tidy squared-off green block with a flat top and rounded corners.
- distinct: flat-topped rectangular block with crisp shoulders (corner radius 5) and three evenly spaced round leaf clumps on the front; no berries, no spikes.
- parts (back to front):
  1. ground shadow: ellipse (32,57) rx17 ry3.5, #6a4528
  2. hedge block: rrect x 8..56, y 18..52 (r5), base #58a03e (moss)
  3. leaf clumps: circle r6 at (20,28) light #7ab55c; r7 at (38,32) dark #2e5a2c; r5 at (47,25) light #7ab55c; 1px inner contours
  4. clip lines: two 1px curves #2f5a2a at y 38, x 14..50
  5. glint: 1px cream dot on a clump top at (22,24)
- joins: none; no edge stitch (foliage).
- face: none.
- notes: moss family. The wide flat top is the identity. Crescent at the lower right of the block. Differs from holly-hedge by smooth outline and no red.
