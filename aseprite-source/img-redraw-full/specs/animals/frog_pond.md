# animals/frog_pond
- canvas: 64x64, mode sticker, 1x.
- subject: A small round pond seen from above with a stone rim, blue water, two lily pads and a happy green frog in the middle; calm and cute.
- must-read-at-16px: a blue oval pond ringed in grey stone with a green frog dot and two eyes.
- distinct: top-down stone-ringed oval pond with a visible frog face and one pink bud on a pad; reed tufts curling at the left and right rim.
- parts:
  1. stone rim: ellipse (32,38) rx30 ry22, #8b8f96 (stone); inner step ellipse (32,36) rx27 ry19 #5b6470
  2. water: ellipse (32,36) rx24 ry16, #4a90b8 (water #3f8fb0); lit patch ellipse (26,31) rx13 ry6 #8fcbd8 (hard step); 1px ripple arc (14,40)->(32,44) #c8ecdc
  3. lily pad left: ellipse (22,42) rx8 ry5 #4f9a45, notch line to (27,39) in water blue; pink bud circle (19,40) r2.5 #f6b8cf
  4. lily pad right: ellipse (44,30) rx7 ry4.5 #4f9a45, notch toward (40,27)
  5. frog: body ellipse (36,30) rx7 ry5 #5da443; two eye bumps circles r2.5 at (33,26.5),(39,26.5) #6fb552
  6. reed tufts: 3px curved strokes at left (8,40..46) and right (56,22..28), #5a7a3a
- joins: none.
- face: locked eyes on the frog bumps at about (31,24) and (37,24), set wide; 3x3 disc with 2x2 pupil since the head is under 20 px.
- notes: frog is the only face; pink bud is the one accent; no blush.
