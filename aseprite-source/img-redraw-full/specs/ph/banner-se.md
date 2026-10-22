# ph/banner-se
- canvas: 240x80, mode scene, draw at half-size (120x40), write 2x. Full-bleed, no halo, no text.
- subject: Region banner for the south-east olive coast: a calm sunny sea under a pale sky, a sandy headland on the right with a tiny white cottage and four round olive trees.
- must-read-at-16px: tan headland wedge rising from the lower right against the blue sea, with a red-roofed white cottage on top.
- distinct: diagonal sandy headland sloping up to the right with a red-roof cottage and four round grey-green olive trees on stub trunks; low gold sun at far left.
- parts (half-size coords, x2 for final):
  1. sky: rect 0..120 x 0..19, pale blue #a9d6ea, 2-3 hard bands lighter toward the horizon
  2. sun: circle (24,9) r4, gold #f5cf6a with gloss dot #fff1c8
  3. sea: rect 0..120 x 19..40, water base #3f8fb0; 1px pale #a9d6ea horizon line at y19; cream #f4f0e0 scalloped wave dashes along y36 x0..24
  4. headland: poly (42,40),(60,22),(84,16),(120,16),(120,40), sand #dcb06a; 1px olive-green line #b0bc66 along the top edge from (60,22) curving to (120,17)
  5. cottage: rect 89..97 x 19..25 cream #f4f0e0; roof tri (88,19),(93,15),(98,19) red #d6322b; door 2x4 blue #3f8fb0 at (92,21)
  6. olive trees: four balls r3 grey-green #968f96 with lit patch #b0bc66 upper-left, on 1x3 wood trunks #b6814d at x 69, 98, 81, 110 (y 27, 29, 33, 35)
  7. corner vignette: 2-3 px stepped dark corner bands #12324a only at the corners
- joins: thread-gold hem stitch (2 on/1 off) 2 px in along top and bottom edges.
- face: none.
- notes: scene bleeds all edges; keep the headland diagonal clearly different from other region banners; no text.
