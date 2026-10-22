# ph/box-hedge-tee
- canvas: 64x64, mode sticker, 1x. Top-down hedge piece, bleeds off left, right and bottom edges.
- subject: A clipped box hedge in a T-junction seen from above: a thick green band across the middle with a branch running straight down; neat, plain, lumpy foliage.
- must-read-at-16px: a green T, wide bar across the centre and a stem going down.
- distinct: plain uniform green with scalloped bumpy edges and no berries or flowers; the clean one of the three tee hedges.
- parts (back to front):
  1. soil shadow: T shape x 0..63 y 37..44 plus x 40..45 down to y63, #7a4a1f, low contrast
  2. hedge bar: scalloped band x 0..63, y 24..40 from overlapping circles r8 every 6 px, #58a03e (moss #7ab55c)
  3. hedge stem: scalloped band x 24..40, y 24..63, same green
  4. highlight: 2px #b8d47c (moss rim #a4b86a) dashes along bar top (y~27) and stem left (x~27)
  5. lower shade: #2f5a2a crescent 3px along bar bottom and stem right
- joins: none.
- face: none.
- notes: halo only on free edges (bar top, stem sides); ends bleed. Keep scallops visible so it reads as hedge, not pipe.
