# stops/stamp-inn
- canvas: 64x64, mode sticker, 1x.
- subject: A round rubber travel-stamp of an inn: a dashed ring around a small cottage with a chimney, as if inked on a passport page; cosy, tidy.
- must-read-at-16px: a pitched-roof house silhouette (triangle roof over a square body) inside a round ring.
- distinct: only asset that is a ring-stamp with a dashed outer border and a house inside; chimney notch on the roof's upper right.
- parts (back to front):
  1. stamp disc: circle (32,32) r29, base #f5cf6a (gold rim family, cream-safe)
  2. outer dashed ring: r26..28, 2px dashes 2 on / 1 off, #b8661a (gold shade)
  3. inner thin ring: r22, 1px #d0862a
  4. house body: rect x 22..42, y 31..46, base #b07a45 (wood)
  5. roof: triangle (18,32) (32,17) (46,32), base #a8582f
  6. chimney: rect x 38..42, y 17..24, #8a4f2a
  7. door: rect x 29..35, y 36..46, #5e2f1e; two 4x4 window squares at (24,34) and (37,34), #fff1c8
  8. ground line: 2px at y 47, x 18..46, #8a4f2a
- joins: none.
- face: none.
- notes: ink-stamp feel, one gold family plus wood house; ring dashes evenly spaced; no text. Roof overhangs the walls by 2px.
