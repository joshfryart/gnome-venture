# ph/sunflower-seed
- canvas: 64x64, mode sticker (halo 5), 1x.
- subject: A seed item: a clear glass jar sealed with a cork stopper, full of striped sunflower seeds, with a small sunflower drawn on a round label; sunny and generous.
- must-read-at-16px: a glassy jar with a brown cork on top and a gold sunflower disc on the label.
- distinct: transparent-looking glass jar (the only see-through container) with a seed-fill line and round paper label; cork is a tapered brown plug.
- parts:
  1. ground shadow: ellipse (32,57) rx17 ry3, #6a4528
  2. jar body: rrect x 14..50, y 18..56 (r8), glass #c8ecdc, rim #8fcbd8, shade #3f8fb0 (water ramp)
  3. seed fill: rrect x 16..48, y 32..54 (r6), #9a6b3f with 1px #f1ece0 seed stripes in a diamond pattern
  4. jar neck: bar x 22..42, y 14..20, #8fcbd8
  5. cork: trapezoid x 24..40, y 6..15, base #d9a660, grain 1px #a8582f
  6. label: circle (32,38) r10 #f4f0e0; sunflower disc r4 #7a3a14 with 8 petals 2px #e8a317
  7. glass gloss: long vertical comma x 18..20, y 22..40 #c8ecdc and dot
- joins: none.
- face: none.
- notes: glass: no edge stitch; keep every pixel opaque. Label overlaps seeds: inner contour. Gold ramp for petals.
