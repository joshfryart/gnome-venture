# ph/stone-wall-straight
- canvas: 64x64, mode sticker, 1x. Wall spans full width and bleeds off left and right edges.
- subject: A straight run of dry stone wall seen from the front: a horizontal band of alternating light and dark stones with one big square keystone block in the centre.
- must-read-at-16px: flat horizontal grey band across the middle with a square block bulging above and below at the centre.
- distinct: alternating cream/grey rounded stones with a larger raised centre block as the only vertical break.
- parts (back to front):
  1. wall band: rect x 0..63, y 25..38 (13 tall), #968f96 (stone #8b8f96)
  2. stones: rrects 7 wide, 13 tall, r3, alternating #d6c9b6 (stone #c9c5bc) and #968f96, starting x0,7,14..., 1px joint #6a6070 between
  3. centre block: rrect x 25..38, y 24..39 (r4) #6a6070, inner rrect x 27..36, y 27..36 (r3) #968f96, 1px proud above and below the band
  4. lower shade: #5b6470 along the bottom 3 px of the band
  5. gloss comma on the top-left stone (3,28) and on the centre block
- joins: none.
- face: none.
- notes: 2px umber outline along top and bottom only; ends run off the frame (no outline/halo there). Cream-safe light stones.
