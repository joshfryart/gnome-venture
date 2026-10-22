# ph/kitchen-3
- canvas: 64x64, mode sticker, 1x. Level 3 of the kitchen building.
- subject: A cosy cottage kitchen with a red triangular roof, tan walls, a stone chimney puffing smoke, an arched dark door, a lit window with flowers and a little flag; warm and busy.
- must-read-at-16px: a red triangle roof over a tan box with a chimney at the right.
- distinct: tall stone chimney with a smoke puff, a wall with two dark plank lines, a window with a flowerbox of three blooms and a gold lantern at the left.
- parts:
  1. ground shadow: ellipse cx 32, cy 58, rx 27, ry 4, #6a4528 low contrast
  2. chimney: rect x 40..47, y 15..29 base #968f96, cap x 39..48, y 14..17 #6a6070; smoke puff circle r 3 at (45,11) #d6c9b6
  3. wall: rrect x 11..53, y 33..56, base #dcb06a (wood #d9a660), two dark plank lines at y 41 and y 49
  4. roof: triangle (7,36),(32,18),(57,36), base #d6322b (red #dd3a2a / #ae2a2a); eave bar x 7..57, y 35..38 #c66b50 with 1 px #f0d49a rim
  5. door: arch x 17..26, y 46..56, #44281c with a 1 px gold knob at (24,51)
  6. window: rrect x 34..45, y 41..49, #f5cf6a with a 2 px dark cross #2a1a10; flowerbox x 33..46, y 48..52 #b6814d with 3 dots #e46a9b, #e8a317, #f6b8cf
  7. flag: pole 2 px #44281c at x 32, y 8..18; pennant #d6322b x 32..41, y 8..13
  8. lantern: faint glow circle r 6 #f5cf6a at (12,37), body #e8a317 x 10..14, y 34..40
  9. sparkle: 4-point #f5cf6a at (52,23)
- joins: roof eave and base trim use a thread-gold seam; trim line #e8a317 at y 55.
- face: none.
- notes: shade crescent at lower right of roof and wall; gloss on the roof upper-left.
