# gather/rod-bg
- canvas: 200x200, mode scene, draw at half-size (100x100), write 2x. Full-bleed, no halo.
- subject: Side-on view of a calm pond for the fishing mini-game: a pale sky strip on top, lily pads and a pink flower on the surface, reeds on both banks, water deepening from turquoise to navy with soft light shafts, sandy bank at the bottom.
- must-read-at-16px: a thin bright sky band over a big water field that darkens toward the bottom.
- distinct: three diagonal light shafts fanning down from the surface, cattail reeds framing both sides, a muddy bank along the bottom.
- parts (final px; half-size grid is x/2):
  1. water: full rect, hard bands top to bottom #86d6cf, #46a6b4, #25708c, #143d57 (water family, 4-5 bands, no gradient)
  2. sky strip: y 0..27, #f4ecc8 upper, #cfe6c6 lower; sun disc (160,11) r7 #fff6c9
  3. far shore hills: y 14..32 wavy, #9fc99a, nearer #7fb085 (moss)
  4. surface line: wavy 2px #f1fff4 at y 27
  5. light shafts: three slanted quads from y27 down: (30..62)->(56..112), (96..120)->(140..176), (150..162)->(188..200); one lighter water band step, no blending
  6. lily pads: ellipse (34,28) rx21 ry4 #4c9a56 with lit top #78c06e; (158,29) rx17; pink flowers (44,24) and (164,25) #f5a9bf with #fff3a8 centre
  7. reeds: stems at x 10,17,24 (left, tops y 50,68,90) and x 186,193,179 (right) down to the bottom, 3px #5f8a3e; blades #7fae4c; brown cattails (24,62..78) and (179,52..68) #7a5230
  8. bank: bottom wavy band y 176..200 #8c7a58, front layer #a8946c, pebbles #c9b78f
- joins: optional thread-gold hem stitch along the top and bottom edges.
- face: none.
- notes: keep the centre water calm and empty for fish sprites; stepped bands only; scene outlines 2 px per part.
