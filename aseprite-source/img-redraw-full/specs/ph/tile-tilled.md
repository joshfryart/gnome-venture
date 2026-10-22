# ph/tile-tilled
- canvas: 64x64, mode scene (tile, full-bleed, no halo), 1x. Must tile edge to edge.
- subject: Freshly tilled soil seen from above: four dark furrows running horizontally between lighter raised ridges, with scattered pale pebbles; ready-to-plant garden bed.
- must-read-at-16px: alternating dark and light horizontal stripes of brown soil.
- distinct: four evenly spaced 7px dark furrows each with a 3px lighter ridge highlight beneath, plus six pale pebble dots; horizontal stripes only, no border.
- parts (back to front):
  1. base soil: full rect, #7a4a1f
  2. furrows: rects 64x7 at y 6, 21, 36, 51, base #3d2a1c
  3. ridge tops: rects 64x3 at y 13, 28, 43, 58, base #9a6b3f
  4. pebbles: 2x2 dots #c9a96e at (6,6), (30,12), (35,34), (15,45), (39,27), (49,40)
  5. clod ticks: 1px #2a1a10 near x 12..16 y 20, x 44..47 y 8, x 26..30 y 46, x 52..55 y 38
- joins: none; left and right edges must match for tiling.
- face: none.
- notes: soil family #3d2a1c / #7a4a1f / #9a6b3f / #c9a96e. No halo, no outline. Hard 2px steps on furrow edges; light from the upper left brightens each ridge's top edge.
