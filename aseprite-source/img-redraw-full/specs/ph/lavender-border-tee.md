# ph/lavender-border-tee
- canvas: 64x64, mode sticker, 1x. Top-down border piece, bleeds off left, right and bottom edges.
- subject: A lavender flower border in a T-junction seen from above: green leafy band and stem with rows of purple flower spikes along both sides.
- must-read-at-16px: green T with a purple stripe along its upper edge and a lilac stripe along its lower edge.
- distinct: two offset rows of purple (#7a5cc0) and lilac (#c3b2ea) flower dots above and below, making a striped look.
- parts (back to front):
  1. soil shadow: T shape x 0..63 y 37..44 plus stem x 40..45 to y63, #7a4a1f
  2. leaf band: scalloped x 0..63, y 24..40, #58a03e (moss #7ab55c); stem x 24..40, y 24..63
  3. purple row (upper/left): 5px round dots #7a5cc0 (dusk #7b66b4) every 6 px along y~30 and down x~31, 1px #a894dc glint each
  4. lilac row (lower/right): 4px round dots #c3b2ea (pale, cream-safe) every 6 px along y~34 and down x~34, offset half a step
  5. lower shade: #2f5a2a crescent 3px along bar bottom and stem right
- joins: none.
- face: none.
- notes: dots 4-5 px, never 1 px. Keep rows offset so it reads striped not checkered. Halo on free edges only.
