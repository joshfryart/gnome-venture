# ph/lime-seed
- canvas: 64x64, mode sticker, 1x.
- subject: Seed item: a flat paper seed packet with a folded top flap and a round green lime printed on the front, plus a small green pennant tab at the upper right.
- must-read-at-16px: an upright cream rectangle with a darker folded flap band on top and a green circle in the middle.
- distinct: flat upright paper packet with a clearly folded top flap and a small green pennant tab poking out the upper right.
- parts (back to front):
  1. packet body: poly x 13..51, y 12..56 with clipped upper-right corner (48,12)->(51,18), base #f1ece0 (pale)
  2. flap band: rect x 13..51, y 12..20, base #dcb06a (wood rim family), fold line 2px at y 19
  3. label window: rrect x 18..46, y 24..50 (r6), base #f4f0e0, 1px outline #7ab55c
  4. lime: circle (32,37) r7, base #7ab55c (moss), lower-right crescent #58a03e
  5. lime stem + leaf: 2px stem (32,29)->(32,26) #2e5a2c, leaf at (36,25) #58a03e
  6. pennant tab: triangle (45,9)->(50,17)->(40,17), #2e5a2c
  7. three seed dots: 2px dots at (26,53),(32,53),(38,53), #8c4a1a
- joins: gold seam 2 on / 1 off along the flap fold y 19, x 15..49.
- face: none.
- notes: pale paper subject, cream-safe gloss #fff3c8. No edge stitch (paper).
