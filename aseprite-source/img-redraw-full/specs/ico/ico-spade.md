# ico/ico-spade
- canvas: 64x64, mode icon, 1x.
- subject: A garden digging spade standing upright, steel scoop blade at the bottom, wooden shaft with a D-grip handle at the top.
- must-read-at-16px: a pointed grey-steel scoop at the bottom of a long wooden shaft.
- distinct: rounded-shoulder blade tapering to a rounded point, straight vertical shaft, small grip bar at the very top.
- parts (back to front):
  1. shaft: 5px rect x 29..34, y 8..38, base #b6814d (wood)
  2. grip: rrect x 22..42, y 5..11 (r2), base #b6814d, 1px contour
  3. blade: poly (18,32)->(46,32)->(44,46)->(32,58)->(20,46), base #d6c9b6 (stone #c9c5bc range, steel)
  4. blade socket: rect x 27..36, y 28..36, #8b8f96
  5. step ledge: 3px bar x 20..44, y 32..34, #8b8f96
- joins: none.
- face: none.
- notes: gloss on blade upper-left, #fff3c8 (pale steel). Shaft joins blade at socket with inner contour. Parts min 3px.
