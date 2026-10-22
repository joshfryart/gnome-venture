# ph/banner-sea
- canvas: 240x80, mode scene, draw at half-size (120x40), write 2x.
- subject: Monsoon jungle banner for the sea region: layered green jungle ridges over stacked wavy river bands, palm fans at both ends and rain streaks; humid and lush, no text.
- must-read-at-16px: a pale sky band over dark green jungle, with four wavy lighter-green river stripes below.
- distinct: four horizontal wavy water bands with pale-blue ripple lines, a palm-frond fan at each end, and diagonal rain ticks across the sky.
- parts (half-size coords, full-bleed, back to front):
  1. sky: rect x 0..119, y 0..39, #d6c9b6 pale warm grey
  2. far jungle: ridge y 10..14 across the width, #b0bc66 (moss), fills to the bottom
  3. canopy ridge: wavy line y 10..14 peaking at x 60, #58a03e
  4. dark mid-ridge: y 15..17 undulating, #2e5a2c
  5. river bands: four waves at y 22, 26, 30, 34 (each rises 3px at the centre), alternating #7ab55c / #b0bc66 / #7ab55c / #58a03e, with 1px #a9d6ea ripple on each top edge
  6. palm fans: two fans of 4 leaf ellipses (about 2x6 each) at x 6..14 and x 106..114, y 8..24, #58a03e
  7. rain ticks: about 22 diagonal 1x3 strokes scattered above y 30, #3f93b2
- joins: thread-gold hem stitch along top and bottom edges (2 on / 1 off, 2px in).
- face: none.
- notes: scene full-bleed, no halo. Darken corner pixels one ramp step only for a vignette. 2px selective outline on palms and ridges. Keep the centre calmer for UI overlay.
