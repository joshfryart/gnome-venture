# ph/holly-hedge-tee
- canvas: 64x64, mode sticker, 1x. Top-down hedge piece, bleeds off left, right and bottom edges.
- subject: A holly hedge in a T-junction seen from above: darker green scalloped band across with a branch down, dotted with bright red berries.
- must-read-at-16px: green T with a scatter of red dots along it.
- distinct: red berry clusters (3x3 dots) scattered on a darker green than the box hedge.
- parts (back to front):
  1. soil shadow: T shape x 0..63 y 37..44 plus stem x 40..45 to y63, #7a4a1f
  2. hedge bar: scalloped band x 0..63, y 24..40, #4a8a3e (moss shade tone)
  3. hedge stem: scalloped band x 24..40, y 24..63, same green
  4. top highlight: dashed 2px #7ab55c along bar top (y~27) and stem left (x~27)
  5. lower shade: #2f5a2a crescent 3px along bar bottom and stem right
  6. berries: 3x3 round #dd3a2a, glint 1px #ff9158, at ~(4,30),(10,30),(22,30),(28,30),(40,30),(46,30),(58,30) and down the stem (30,37),(35,43),(30,50),(35,57)
- joins: none.
- face: none.
- notes: berries get a 1px #6b1b2c contact shadow; vary spacing, not a grid. Halo on free edges only.
