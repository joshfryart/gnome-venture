# ph/banner-mena
- canvas: 240x80 original; mode scene; draw at 120x40 and write 2x (out=2).
- subject: A desert dunes banner ("Dunewhisper"): pale sand sky with a low orange sun, three layered golden dunes, and an oasis with a small blue pool and two date palms.
- must-read-at-16px: layered gold dunes with an orange sun at upper right and a small palm.
- parts (draw grid 120x40):
  1. sky: whole #f4f0e0; top band y 0..14 #f5cf6a (hard step)
  2. sun: circle (93,10) r6 #f08a24, inner r4 #f5cf6a
  3. far dune: ridge y22 at edges rising to y19 at x60, filled down, #f5cf6a
  4. mid dune: ridge y31 at left falling to y~24.5 at x30..37, dipping to y32 at x75, back to 24.5 at x112; #e8a317
  5. near dune: gently waving ridge y 33..37, filled down, #f5cf6a
  6. oasis pool: ellipse (30,33) rx 5 ry 1.5 #3f93b2
  7. palms: trunk 2px curved #c4925f (24,33)->(27,20), crown of 5 green 2px fronds #58a03e at (27,20); smaller palm (36,33)->(34,23)
- joins: hem stitch (gold 2 on/1 off) along top and bottom edges.
- face: none.
- notes: banner, no halo, bleeds all edges. Palms read as a crown of 4-5 green strokes. Warm and quiet; only a 1px #b07a10 ridge line, no heavy outlines on dunes.
