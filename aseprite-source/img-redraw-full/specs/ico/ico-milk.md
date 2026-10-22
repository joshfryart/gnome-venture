# ico/ico-milk
- canvas: 64x64, mode icon, 1x.
- subject: A gable-top milk carton with a blue band and a white drop on the label; wholesome dairy icon.
- must-read-at-16px: a boxy carton with a pointed triangular roof and a blue stripe across the middle.
- distinct: GABLE-TOP CARTON (box + trapezoid roof) with a wide blue band and a milk-drop emblem.
- parts (back to front):
  1. roof: trapezoid (16,26) (24,8) (40,8) (48,26), base #3f93b2 (water)
  2. carton body: rect x 16..48, y 26..58, base #f8eed2 (pale, cream-safe)
  3. blue band: rect x 16..48, y 36..52, base #3f93b2
  4. milk drop: teardrop centre (32,45), tip (32,38), width 10, height 12, base #f8eed2
  5. roof ridge: 1px #256a80 line x 24..40 at y 10 and shade #2f6290 on the right slope
- joins: thread-gold seam 2on/1off along the roof/body join (x 17..47 at y 26).
- face: none.
- notes: pale body: gloss #fff3c8, dot #ffffff, umber outline. Roof clearly wider at the bottom. Parts min 3px.
