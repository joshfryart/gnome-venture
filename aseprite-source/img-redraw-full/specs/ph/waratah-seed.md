# ph/waratah-seed
- canvas: 64x64, mode sticker, 1x.
- subject: A seed item: a flat paper seed packet with a pointed triangular flap and a gold sticker, showing a big round pink waratah bud with a green leaf on the label; cheerful.
- must-read-at-16px: a cream rectangle with a pointed triangle flap on top and a big pink dot in the middle.
- distinct: packet with a pointed triangular flap and round gold sticker (not a straight flap band), and a large pink bud nearly filling the window.
- parts:
  1. packet body: rect x 12..52, y 18..56, base #f1ece0 (pale)
  2. triangle flap: poly (12,18),(52,18),(32,34), base #f6b8cf (petal light)
  3. gold sticker: circle r4 at (32,32), base #e8a317
  4. label window: rrect x 18..46, y 36..54 (r 5), base #f4f0e0, 2px ring #e46a9b
  5. bud: circle r7 at (32,45), base #e46a9b, shade #a8241f
  6. leaf: 6x3 bean at (38,38) tilted #58a03e; stem 2x3 #2e5a2c
- joins: flap edge thread-gold seam 2 on/1 off from (12,18) to (32,34) to (52,18).
- face: none.
- notes: pale paper cream-safe, umber outline every side; top is a triangle point, unlike peony's straight flap.
