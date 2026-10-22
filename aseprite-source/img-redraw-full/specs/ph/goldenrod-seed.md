# ph/goldenrod-seed
- canvas: 64x64, mode sticker, 1x.
- subject: A seed item: a bundle of seeds wrapped in a cloth square and tied at the top with string, a blue seed on its front patch; rustic.
- must-read-at-16px: a round-bellied cloth bundle pinched at the top with a string tie.
- distinct: STRING-TIED CLOTH BUNDLE: a gathered round sack with a pinched neck, string knot and two cloth ears above it; soft, no flat edges.
- parts:
  1. bundle body: ellipse (32,40) rx 20 ry 17, base #f4f0e0 (cloth, pale)
  2. gathered neck: poly (24,26),(40,26),(36,18),(28,18), base #e8d8b0
  3. cloth ears: two bean tips at (24,16) and (40,16), each 6x5, #f4f0e0
  4. string tie: 2px band y 24, x 24..40 #8c4a1a; knot 3x3 at (32,24); two hanging ends 2px to (28,30),(36,30)
  5. cloth patch: rrect x 20..44, y 34..50 (r 6), 2px border #3f93b2
  6. blue seed: circle (32,42) r 6.5, #3f93b2 (water), crescent #256a80; leaf bean 4x3 at (35,33) #58a03e
  7. fold lines: 1px #dcb06a curves from neck to (22,36) and (42,36)
- joins: seam: thread-gold 2 on/1 off along the patch hem (22,50)->(42,50); the string tie is the other join.
- face: none.
- notes: pale cloth: cream-safe gloss #fff3c8, umber outline all round. Edge stitch allowed on the cloth body. Bundle wider than tall, neck narrow.
