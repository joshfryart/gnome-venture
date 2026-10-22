# stops/stamp-herb
- canvas: 64x64, mode icon, 1x (map stop, may be scaled later).
- subject: A round herb stamp: a dotted ring around a green herb sprig with leaves, like a garden passport stamp.
- must-read-at-16px: a circular ring with a green sprig of leaves in the centre.
- distinct: a double ring (dotted outer, solid inner) enclosing a central sprig with two side leaves, a top bud and a baseline bar.
- parts (back to front):
  1. disc: circle centre (32,32) r26, base #f1ece0 (pale parchment)
  2. outer ring: dotted ring r29 (1 on / 2 off), #74462a
  3. inner ring: 2px ring r26, #4a2c1a, plus 1px ring r22
  4. stem: 3px line from (32,48) to (32,24), #6a9a3a
  5. leaves: left (32,41)->(22,31) and right (32,36)->(42,26) teardrops, #7ab55c; top bud (32,25)->(30,17), #a4b86a
  6. baseline bar: 3px rect x 22..42, y 48, #2f5a2a
- joins: none.
- face: none.
- notes: ring is the stamp rim; keep 3px inside the frame. Leaves 3px minimum. Pale disc is cream-safe with umber outline on every side.
