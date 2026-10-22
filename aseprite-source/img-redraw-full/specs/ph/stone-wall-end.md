# ph/stone-wall-end
- canvas: 64x64, mode icon, 1x.
- subject: The end of a dry stone wall: a row of alternating grey blocks extending right, capped on the left by a large rounded square end-stone.
- must-read-at-16px: a horizontal grey band with a big rounded square end-block on its left.
- distinct: right-running wall of six alternating light and dark blocks bleeding off the right edge, with a bigger rounded square cap at the left.
- parts:
  1. wall row: rect x 32..64, y 26..38 (bleeds right); blocks 7px wide alternating #d6c9b6 and #968f96, r3, 1px gaps
  2. end-stone: rrect x 25..39, y 25..39 (r4) #6a6070 outer, inner x 27..37 y 27..37 #968f96
  3. shadow strip below: y 33..42 darker tint, #5b6470
  4. top glints: 1px #c9c5bc on blocks upper left
- joins: none (stone gaps act as seams).
- face: none.
- notes: pale blocks cream-safe, umber outline. Stone family #5b6470/#8b8f96/#c9c5bc. Wall is the right end of the tile and clips at the frame.
