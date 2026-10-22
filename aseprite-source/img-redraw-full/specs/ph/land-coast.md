# ph/land-coast
- canvas: 64x64, mode scene (rounded tile), 1x. Full-bleed inside the rounded frame, no halo.
- subject: Coast landscape tile: pale blue sky with a small sun, a teal sea band, a sandy beach in front with a pink shell, wave lines, and a tiny red sail boat.
- must-read-at-16px: three horizontal bands, sky blue on top, teal sea in the middle, tan sand below.
- distinct: a tiny red triangular sail on a dark base line sitting on the sea at lower right, plus a pink shell on the sand at lower left.
- parts:
  1. tile: rrect x 3..60, y 3..60 (r7), sky #a9d6ea
  2. sun: circle (48,15) r5 #f5cf6a, 2x2 glint #fff1c8
  3. sea: rect y 34..60 clipped to the tile, #3f93b2 (water), darker line y 34..37 #256a80
  4. sand: wavy shore from (3,46) to (61,44) down to the bottom, #dcb06a
  5. wave crests: two 2 px scalloped lines #f4f0e0 at x 8..24, y 40 and x 36..52, y 38
  6. shell: circle (22,54) r2.5 #f6b8cf
  7. sail: triangle (46,46),(46,38),(54,42) #d6322b with a 2 px #44281c base line at y 46, x 46..54
- joins: thread-gold hem stitch inside the frame edge allowed.
- face: none.
- notes: tile bleeds to its rounded frame. Sail at least 7 px tall. Keep the three bands readable at 16 px.
