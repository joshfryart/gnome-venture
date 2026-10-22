# ph/ixora-seed
- canvas: 64x64, mode sticker, 1x.
- subject: A seed item: a flat paper seed packet with a folded-over flap at the top, a golden-orange ixora fruit printed on the front. Tidy garden-shop feel.
- must-read-at-16px: a tall upright rectangle with a darker triangular flap fold across its top.
- distinct: flat paper envelope with sharp corners, a pointed triangular flap and a seal dot; the only flat, sharp-cornered seed container.
- parts:
  1. packet body: rect x 15..49, y 14..56, corners r1, base #f1ece0 (pale paper)
  2. flap: triangle (15,14)->(49,14)->(32,29) folded down, base #dcb06a (paper shade), 1px umber contour below the fold
  3. label window: rrect x 20..44, y 31..51 (r4), #f4f0e0 with a 2px #e8a317 border
  4. printed fruit: circle (32,41) r7, base #e8a317 (gold family), shade crescent #b8661a lower right
  5. sprout on the print: 2px stem (32,34)->(32,31), leaf bean #58a03e (34,31)->(38,34)
  6. seal dot: circle (32,29) r2.5 #a8582f on the flap tip
  7. three seed dashes y 53 at x 26,32,38 #8c4a1a (1px accents)
- joins: fold edges across the flap, y 14..29.
- face: none.
- notes: paper is pale, so cream-safe gloss and umber outline on all sides. No edge stitch (paper). Slight ground shadow.
