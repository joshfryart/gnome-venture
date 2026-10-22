# ph/banner-wca
- canvas: 240x80, mode scene, draw at half-size (120x40), write 2x. Region banner, no text.
- subject: Greatcanopy rainforest: four tall trunks with huge round canopies against a sky strip, over a mossy floor with tiny flowers.
- must-read-at-16px: dark green canopy balls on thin brown trunks over bright green ground.
- distinct: four evenly spaced trunk-and-canopy trees (x 14, 45, 77, 108 at half-size) giving a repeated round-crown rhythm.
- parts: (half-size coords)
  1. backdrop: full-bleed #b0bc66 (olive mist)
  2. sky strip: rect y 0..12, #a9d6ea
  3. trunks: 4 rects 4px wide, y 8..40, #8c4a1a (wood)
  4. canopies: ellipse rx13 ry6 at (14,9),(45,9),(77,9),(108,9), #2e5a2c
  5. canopy highlight: ellipse rx7 ry3 up-left of each, #58a03e
  6. hanging vine: 1px curve right of each trunk, y 12..25, #7ab55c
  7. ground: rect y 34..40 #58a03e with scalloped bumps #7ab55c every 20px
  8. flowers: 2px dots at (30,32) #e46a9b, (60,33) #e8a317, (94,32) #d6322b
- joins: thread-gold hem stitch along top and bottom edges allowed.
- face: none.
- notes: full-bleed, no halo; canopies shaded lower right; soft dark vignette #17361c at the corners.
