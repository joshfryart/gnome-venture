# ph/rain_barrel-mossy
- canvas: 64x64, mode sticker, 1x.
- subject: A wooden rain barrel with iron hoops, full of water to the brim, a drainpipe feeding in from upper left and a tap at the bottom, with moss clumps on top and base; damp, old, cosy.
- must-read-at-16px: a plump brown barrel with an open blue water top and green moss patches on the rim.
- distinct: barrel with a pipe elbow entering from the upper left and a drip on the left, covered in moss lumps (the MOSSY variant).
- parts (back to front):
  1. drainpipe: vertical rect x 7..12, y 6..22 then horizontal rect x 7..21, y 19..24, base #968f96 (stone grey); drip circle (9,27) r2 #a9d6ea
  2. barrel body: rrect x 14..50, y 21..56 (r8), base #a5663a (wood)
  3. stave lines: three 2px vertical lines x 23, 32, 41, y 22..55, #5e2f1e
  4. hoops: two bands x 14..50, y 28..32 and y 46..50, #6a6070
  5. rim ellipse: (32,21) rx18 ry5.5, #8c4a1a; water ellipse (32,21.5) rx15 ry4 #3f93b2 with 2px ripple #a9d6ea
  6. tap: rect x 29..35, y 49..52 #6a6070; drop (32,55) r1.5 #a9d6ea
  7. moss: blobs (19,20),(42,22) #7ab55c, (32,18) #58a03e, bottom (23,54) #58a03e, (39,55) #7ab55c; 2px side drips (18,42..56) and (45,44..56) #58a03e
- joins: none (hoops are plain metal).
- face: none.
- notes: moss must overlap the rim and base so it breaks the silhouette. Differs from the non-mossy sibling by the pipe plus moss.
