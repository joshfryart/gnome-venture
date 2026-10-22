# gather/calm-ripple
- canvas: 200x200 (draw on a 100x100 grid), mode scene overlay (transparent bg, no halo); draw at half-size, write 2x.
- subject: Calm water ripple effect: concentric rings spreading from the centre, the outer rings broken into dashed arcs; soft, peaceful, near-white.
- must-read-at-16px: concentric rings around a single centre point.
- distinct: three rings, the inner one solid and the two outer ones dashed with long gaps, centred exactly on the canvas.
- parts:
  1. inner ring: circle centre (100,100) r30, 2-3px stroke, #c8ecdc (water gloss)
  2. mid ring: r58, dashed 40 on / 14 off, #c8ecdc
  3. outer ring: r86, dashed 60 on / 20 off, #c8ecdc
  4. faint shade ring: 1px #8fcbd8 just outside the inner and mid rings (r33, r61)
- joins: none.
- face: none.
- notes: transparent everywhere else; rings at least 2px wide at final; falloff by palette (inner brightest), not alpha. Keep pixel circles symmetrical about the centre.
