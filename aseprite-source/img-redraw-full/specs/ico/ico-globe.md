# ico/ico-globe
- canvas: 64x64, mode icon, 1x.
- subject: A round blue Earth globe with green continents; friendly world icon.
- must-read-at-16px: a big blue sphere with chunky green land blobs.
- distinct: perfectly round blue ball with three bold land shapes and a curved equator line; no stand.
- parts (back to front):
  1. ocean sphere: circle (32,31) r 25, base #3f93b2 (water)
  2. ocean glaze: upper-left lighter crescent #5fb0c8, 3px
  3. continent A: blob x 14..30, y 16..34, base #58a03e
  4. continent B: blob x 36..50, y 30..50, base #7ab55c
  5. continent C: blob x 34..48, y 8..18 (clipped by sphere), base #58a03e
  6. equator curve: 1px #256a80 from (10,31) via (32,37) to (54,31)
- joins: none.
- face: none.
- notes: continents min 3px; ocean shade crescent lower right #2f6290. Gloss on the upper-left sphere. Land blobs stay inside the sphere edge.
