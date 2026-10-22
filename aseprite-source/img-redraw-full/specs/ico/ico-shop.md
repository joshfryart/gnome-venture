# ico/ico-shop
- canvas: 64x64, mode icon, 1x.
- subject: A market-stall shopfront with a scalloped red-and-cream striped awning above a tan wall with a brown door; a shop icon.
- must-read-at-16px: a red-and-cream striped scalloped awning over a small boxy building.
- distinct: four-stripe SCALLOPED awning (alternating red / cream, round lobes along the bottom) spanning wider than the walls.
- parts:
  1. wall: rect x 12..51, y 28..56, base #e8d3a2 (pale tan, cream-safe)
  2. door: rect x 20..43, y 38..48, base #5e2f1e (wood deep)
  3. awning stripes: four 12 px stripes x 8..55, y 12..28, with half-circle lobes (r 6) at the bottom; red #d6322b at x 8..19 and x 32..43, cream #f8eed2 at x 20..31 and x 44..55
  4. awning top bar: rect x 8..55, y 12..15, the shade of each stripe
- joins: thread hem seam along the lobe line y 27 on the red stripes; no button.
- face: none.
- notes: cream stripes need umber outline all around. Lobes are 12 px so they read at 16 px as a bumpy edge. Door is a plain dark block, no knob under 3 px.
