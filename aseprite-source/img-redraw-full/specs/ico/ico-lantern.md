# ico/ico-lantern
- canvas: 64x64, mode icon, 1x.
- subject: A little tin lantern: rounded glowing yellow glass body with a flame ball inside, tan caps top and bottom, and a short handle on top.
- must-read-at-16px: tall glowing yellow body capped top and bottom by wide tan bars with a handle on top.
- distinct: glowing yellow glass window with a round orange flame at its centre, between two wide pill caps.
- parts:
  1. handle: 4px thick line (32,8)->(32,16), #c4925f
  2. top cap: rrect x20..44, y16..22 (r3), #b6814d
  3. glass body: rrect x22..42, y22..50 (r4), base #f5cf6a
  4. flame: disc cx32 cy36 r6, #e8a317 with inner 3x3 #f08a24
  5. bottom cap: rrect x20..44, y50..56 (r3), #b6814d
- joins: optional thread-gold seam on the cap joins y22 and y50.
- face: none.
- notes: gloss brightest on the glass upper left. Keep flame inside glass with 2px margin.
