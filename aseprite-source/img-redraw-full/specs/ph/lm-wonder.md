# ph/lm-wonder
- canvas: 64x64, mode sticker, 1x.
- subject: A landmark icon for a wonder: two stone pillars carrying a wide lintel with a golden four-pointed star between them, standing on a green mound.
- must-read-at-16px: a wide stone gate (two pillars plus lintel) with a gold star in the opening.
- distinct: open stone gateway with a big gold four-point star in the middle plus tiny gold sparkles.
- parts:
  1. ground shadow: ellipse (32,58) r 25x4, #6a4528
  2. grass mound: ellipse (32,52) r 22x6, #58a03e
  3. left pillar: rrect x 10..20, y 22..55, #968f96
  4. right pillar: rrect x 44..54, y 22..55, #968f96
  5. lintel: rrect x 8..56, y 14..26 (r5), #6a6070
  6. star: four-point star centre (32,38), about 24 px tall and wide, base #e8a317
  7. sparkles: 3-4 px dots at (50,36) and (14,40), #f5cf6a
- joins: lintel/pillar seam at y 26, gold 2-on-1-off stitch.
- face: none.
- notes: stone ramp from #8b8f96. Star in gold ramp, gloss #fff1c8. Star points min 3 px at base. Inner contour where the lintel overlaps pillars.
