# ico/ico-house-row
- canvas: 64x64, mode icon, 1x.
- subject: Navigation icon for the town: two cosy toy houses side by side, a small one on the left with a red roof, a bigger one on the right with a purple roof.
- must-read-at-16px: two triangle roofs of different heights (red low-left, purple high-right) over two boxes.
- distinct: a ROW of two houses of different sizes and roof colours; the right roof peak is the highest point.
- parts:
  1. left house wall: rect x 6..28, y 33..53, base #dcb06a
  2. left roof: triangle (5,35) (17,20) (30,35), base #d6322b
  3. left door rect x 14..21, y 42..53, #b6814d; left window 5x5 at (10,36), #a9d6ea
  4. right house wall: rect x 30..57, y 28..53, base #f1ece0 (pale)
  5. right roof: triangle (27,29) (43,11) (59,29), base #7a5cc0
  6. right door: rect x 39..48, y 40..53, #8c4a1a
  7. two windows 6x5 at (33,33) and (48,33), #a9d6ea
- joins: none.
- face: none.
- notes: all parts min 3 px. Right roof overhangs its wall 2 px each side. Pale wall needs umber outline.
