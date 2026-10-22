# ico/ico-calendar
- canvas: 64x64, mode icon, 1x.
- subject: A wall calendar page: a cream square sheet with a red header band, two dark binder rings at the top, and a grid of day squares with one highlighted; tidy date icon.
- must-read-at-16px: a cream square with a red top band and two dark rings above it.
- distinct: red header strip with TWO tall ring pegs poking above the top, and a lower grid where the bottom-right area is empty and one day is highlighted in rust.
- parts:
  1. page: rrect x 10..54, y 13..57, r 5, base #f8eed2 (pale, cream-safe)
  2. header: top band x 10..54, y 13..27, rounded top corners, base #9c2a1e (red family #ae2a2a)
  3. rings: two 5px wide pegs at x 19..23 and x 41..45, y 9..18, rounded, #2a1a10
  4. day cells (grey): rects 8x7 at (17,34), (28,34), (17,45), (28,45), base #968f96 (stone #8b8f96)
  5. highlighted day: rect 8x7 at (39,34), base #bf6f4f (rust #d9885a)
- joins: none.
- face: none.
- notes: pale page gets umber outline on every side; cells min 3px with 1px gaps; gloss comma on the upper-left of the header; crescent lower right.
