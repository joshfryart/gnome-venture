# ph/box-hedge-straight
- canvas: 64x64, mode scene (tile piece), 1x. Bleeds left and right edges, no halo.
- subject: A straight run of clipped box hedge crossing the tile, a smooth band of rounded green puffs, trimmed and tidy.
- must-read-at-16px: one solid horizontal green band with a scalloped top edge, mid-tile.
- distinct: the plainest hedge: uniform green scallops only, no berries or flowers; smooth clipped top with a pale highlight line.
- parts:
  1. soil strip under hedge: x 0..63, y 37..43, #7a4a1f (soil family)
  2. hedge body: band x 0..63, y 24..40, built from 11 overlapping circles r 8 at x = 0,6,13,19,26,32,38,45,51,58,64, centre y 32; base #7ab55c moss (SVG #58a03e)
  3. light top line: 2 px from x 0..63 at y 27..28, #c8d77a
  4. lower shade belt: y 34..40 across, moss shade #2f5a2a, scalloped along puffs
- joins: scallop repeats every 6.4 px; left and right ends must match at x 0 and x 63 (tileable).
- face: none.
- notes: 2 px umber outline along top and bottom scallops only. Keep puffs at least 6 px so it reads at 16 px. Straight piece: no corner or end cap.
