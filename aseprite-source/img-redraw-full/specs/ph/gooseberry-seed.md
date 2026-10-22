# ph/gooseberry-seed
- canvas: 64x64, mode sticker, 1x.
- subject: A seed item: a flat paper packet with a folded flap, its label showing a small cluster of six red gooseberries with a green stem and leaf.
- must-read-at-16px: flat cream square packet with a cluster of red round berries on it.
- distinct: FLAT PAPER PACKET WITH FOLDED FLAP: a wide low packet with a V-shaped flap fold and a six-berry cluster label (not a single seed).
- parts:
  1. packet body: rect x 10..54, y 14..56 (top corners clipped 2 px), base #f1ece0 (pale)
  2. folded flap: poly (10,14),(54,14),(32,30), base #e8d8b0, 2px fold lines #dcb06a along its edges
  3. label window: rrect x 18..46, y 30..53 (r 6), base #f4f0e0, 2px border #d6322b
  4. six berries r 3.5 in a pyramid, alternating #d6322b / #a8241f: top (32,34); middle (27,39),(37,39); bottom (22,46),(32,46),(42,46)
  5. stem: 2px #2e5a2a at x 32, y 24..30; leaf bean 5x3 at (35,24) #58a03e
- joins: seam: thread-gold 2 on/1 off along the flap fold (10,14)->(32,30)->(54,14).
- face: none.
- notes: pale paper: cream-safe gloss #fff3c8, umber outline. Berries touch so they read as one cluster; red ramp base #dd3a2a, darker berries #ae2a2a.
