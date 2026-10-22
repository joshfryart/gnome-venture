# gather/knife-bg
- canvas: 200x200, mode scene, draw at half-size (100x100), write 2x. Full-bleed, no halo, no text.
- subject: Background art for a knife gathering view: a wooden chopping board on a checked cream cloth, with a few leaves and berries at the edges.
- must-read-at-16px: tan board with rounded corners on a pale checked ground, red berries at lower right.
- distinct: rounded wooden board with horizontal wavy grain lines and two knots, a red berry pair and green leaves peeking in at the corners.
- parts (half-size coords, x2 for final):
  1. cloth: full 0..100, cream #efe6cf with 10x10 check squares of #e3d6b6 alternating
  2. board shadow: rrect x5..97, y7..98 r8, dark #5a3d20 as a stepped band offset +1,+3
  3. board: rrect x4..96, y4..95 r8, wood #d6a96b (wood rim #d9a660), lower half #bd8c52 as a hard band
  4. top highlight band: rrect x4..96, y4..8 r4, #e8c88e
  5. grain lines: five wavy 1px lines #a97b42 at y 18, 37, 56, 75, 89, x10..92
  6. knots: ellipse (80,23) rx4 ry3 #a97b42 with inner ellipse rx2 #8f6431; small knot (20,84) rx3 ry2
  7. leaves: green #7fae4c blobs at left (0..12, 75..80) and (0..10, 88..94) and top right (90..100, 13..17), highlight #a3cf6a
  8. berries: two red discs #e24f5a r2 at (93,94) and (96,91)
- joins: thread-gold hem stitch 2 px in along the cloth top and bottom edges (2 on/1 off).
- face: none.
- notes: full-bleed; board is the focal shape; keep the centre calm and low contrast so a knife can sit on it. Hard 1px steps only, the original gradient becomes 2 hard bands.
