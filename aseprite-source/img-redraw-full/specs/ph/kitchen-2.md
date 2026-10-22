# ph/kitchen-2
- canvas: 64x64, mode sticker, 1x.
- subject: A cosy cottage kitchen building with a red pitched roof, tan walls, an arched dark door, a window with a flower box, and a smoking grey chimney; second (upgraded) kitchen tier.
- must-read-at-16px: a tan cottage with a red triangle roof and a grey chimney with smoke.
- distinct: tall grey chimney on the right with a puff of smoke, an arched door at left and a flower-box window at right.
- parts:
  1. shadow ellipse (32,58) rx27 ry4, #6a4528
  2. chimney: rect x 40..47, y 15..29, #968f96; cap rrect x 39..48, y 14..17 #6a6070; smoke disc r3 at (45,11) #d6c9b6
  3. wall: rrect x 11..53, y 33..56, #dcb06a (wood #d9a660); two darker brick lines y 41, 49 (#8a4f2a)
  4. roof: poly (7,36),(32,18),(57,36), #d6322b (red #dd3a2a); eave bar rrect x 7..57, y 35..38 #c66b50
  5. door: arch x 17..25, y 46..56, round top at y 46, #44281c; knob 1 px #e8a317 at (24,51)
  6. window: rrect x 34..44, y 41..49, #f5cf6a with 1 px cross #2a1a10
  7. flower box: rrect x 33..46, y 48..51, #b6814d; flowers at (36,47) #e46a9b, (39,47) #e8a317, (43,47) #f6b8cf
  8. pennant: pole x 32, y 8..18 #44281c; flag (32,8),(40,11),(32,13) #d6322b
- joins: gold hem line y 55, x 9..55, #e8a317.
- face: none.
- notes: keep the roof the dominant red shape; smoke is pale so umber outline.
