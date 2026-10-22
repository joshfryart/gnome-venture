# ph/land-island
- canvas: 64x64, mode scene, full-bleed tile, 1x.
- subject: Island landscape tile: a small sandy island with a green top and a single palm tree, surrounded by blue sea under a pale sky with a gold sun top right.
- must-read-at-16px: a lone palm tree on a sandy island above a blue sea band.
- distinct: a single palm with four fronds on a sand oval mid-sea, a sun in the top-right corner, and sea wave arcs.
- parts (back to front):
  1. sky: full frame, base #a9d6ea
  2. sun: circle (50,14) r5 #f5cf6a, 1px glint
  3. sea: bottom band y 40..63, base #3f93b2; wave arcs #a9d6ea at y 52 (x8..24) and y 50 (x42..50)
  4. island sand: ellipse (32,40) rx20 ry7, base #dcb06a
  5. grass top: ellipse (32,38) rx15 ry5, base #7ab55c
  6. trunk: rect x 31..34, y 24..38, base #b6814d
  7. fronds: four curved leaves from (32,25) to (18,28), (46,28), (24,15), (40,15), base #58a03e
  8. coconut: circle (32,27) r2 #44281c
- joins: thread-gold hem stitch inside the frame edge.
- face: none.
- notes: tile full-bleed, no halo. Moss ramp for leaves. Trunk 3px wide.
