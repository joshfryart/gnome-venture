# gather/calm-bg
- canvas: 200x200 original; mode scene; draw at 100x100 and write 2x (out=2).
- subject: A calm dusk cave-pond background: deep teal-blue water with dark rock walls at top and sides, a mossy bank along the bottom and two glowing mint mushrooms.
- must-read-at-16px: dark teal field, lighter centre, bright mint glows at the bottom corners.
- parts (draw grid 100x100):
  1. water: c:bands radial centre (50,55): #4f6f78 centre, #2f4a58 mid, #1b2e3b edge, ~5 hard steps
  2. top rock: wavy mass y 0..24 (lower edge undulating 15..26), #26404e
  3. side rocks: left x 0..30 (edge bulging out to x30 at y70) y 35..100; right x 73..100, y 30..100; #223846
  4. bank: wavy strip y 86..100 #3a5a46; darker strip y 94..100 #2c4636
  5. water sheen: ellipse (50,95) rx 25 ry 3 #5fa1b6; inner ellipse (48,94) rx 11 ry 1 #bfe6ee
  6. mushrooms at (11,88) and (89,86): stem 3x5 #bff7d4, cap half-ellipse 8 wide #7fe0a8, glow as 2 hard rings
  7. four 1px motes #8fcbd8 at (32,35),(70,46),(18,60),(84,65)
- joins: none.
- face: none.
- notes: no gradients, hard bands only. Bleeds all edges, no halo. Keep values dark and low contrast; mushrooms are the only bright items.
