# ph/pecan-seed
- canvas: 64x64, mode sticker, 1x.
- subject: A pecan seed item: a flat paper packet with a folded flap and a glossy brown pecan visible in a window; neat and tidy.
- must-read-at-16px: flat upright rectangle with a triangular flap folded over the top.
- distinct: flat paper packet (squared rectangle, V-shaped flap), the flattest, most angular silhouette in its set.
- parts:
  1. packet body: rrect x 14..50, y 14..56 (r3), base #f1ece0 (pale paper)
  2. flap: poly (14,14) (50,14) (32,32), base #dcb06a, 1px contour below it
  3. flap sticker dot: circle c(32,28) r3, base #8c4a1a
  4. window: rrect x 20..44, y 34..52 (r5), base #f4f0e0, 2px rim #8c4a1a
  5. pecan: ellipse c(32,44) rx 7 ry 8 base #8c4a1a; cap poly (25,41) (32,35) (39,41) base #44281c; 2px smile curve #44281c at y 47, x 29..35
  6. stem: 2x4 #2e5a2c at (31,31)
- joins: thread-gold seam along the flap edge (14,14)-(32,32)-(50,14); 3 dots 2x2 #8c4a1a at (26,54),(32,54),(38,54).
- face: none.
- notes: pale paper cream-safe (gloss #fff3c8, rim #f5b860). Dark pecan on light window.
