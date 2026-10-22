# games/crop-nut
- canvas: 64x64, mode sticker, 1x.
- subject: A giant acorn crop: a plump tan nut body under a scaled brown cap with a short stalk on top; sturdy and cheerful.
- must-read-at-16px: a round tan nut under a darker cap with a small stalk on top.
- distinct: a crosshatched scale cap overlapping a rounded nut, with a short vertical stalk; cap wider than the nut.
- parts:
  1. ground shadow: ellipse (32,57) rx22 ry3.2, #5e2f1e
  2. nut body: from (32,22) wide to x 14..50, down to a rounded bottom at y 57, #c68a4a (wood #b07a45)
  3. nut shade side: crescent lower right x 35..50, y 34..56, #8d5a28
  4. cap: dome x 10..54, y 12..32, curved flat bottom, #7e5430
  5. scale lines on cap, 1px #5e3b1c: (16,22)->(22,28), (24,17)->(30,28), (34,17)->(33,28), (44,18)->(38,28), (50,24)->(43,28)
  6. stalk: line (32,12)->(32,6), 3px wide, #5e3b1c
  7. cap gloss arc (16,20)->(30,14) #a97640; nut highlight arc (19,40)->(28,31) #efc890
- joins: thread-gold seam along the cap's lower edge (y~31, x 14..50).
- face: none.
- notes: cap overlaps the nut with a 1px contact shadow.
