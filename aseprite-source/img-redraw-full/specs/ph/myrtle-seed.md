# ph/myrtle-seed
- canvas: 64x64, mode sticker, 1x.
- subject: A seed item: a flat paper seed packet with a folded top flap, a window on the front showing a green round myrtle berry-seed with a tiny leaf; neat and light.
- must-read-at-16px: an upright cream rectangle with a darker folded flap band across the top.
- distinct: FLAT PAPER PACKET with a trapezoid folded flap and crimped top edge; tall rectangle silhouette.
- parts (back to front):
  1. packet body: rect x 13..51, y 18..56, base #f1ece0 (pale cream)
  2. folded flap: trapezoid, top y 12 x 16..48, bottom y 18 x 13..51, #f1ece0, fold edge 2px #dcb06a at y 18
  3. window panel: rrect x 18..46, y 22..50 (r 6), #f4f0e0, 2px outline #7ab55c
  4. seed berry: circle centre (32,38) r 8, base #7ab55c, lower crescent #4a8a3e, deep #2f5a2a
  5. stalk: 2px line (32,29)->(32,26), #2f5a2a
  6. leaf: x 33..40, y 24..30 tilted 50 deg, #6a9a3a
  7. three print dots at y 53 (x 26, 32, 38), #8c4a1a, 2px
- joins: crimp seam along the flap bottom y 18, thread gold 2-on-1-off.
- face: none.
- notes: pale subject, cream-safe: gloss #fff3c8, dot #ffffff, rim #f5b860, umber outline on every side. Flap gets a 1px contact shadow under it.
