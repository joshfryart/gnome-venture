# ph/banner-nwe
- canvas: 240x80, mode scene (full-bleed, no halo); draw at half-size (120x40), write 2x. Region banner, NO text. Coordinates below are final 240x80.
- subject: Misty moorland panorama (Mistmoor): pale fog sky over grey far hills, violet heath hills and a green foreground with scattered heather dots, a lone standing stone and a low stone wall; quiet, hazy, calm.
- must-read-at-16px: layered hill bands in grey, violet and green from back to front.
- distinct: a hard-stepped cream mist band across the violet hills, a lone standing stone at x~45 and a low dry-stone wall at the lower right.
- parts (back to front):
  1. sky: full rect, bands of #d6c9b6 lightening upward (about 4 steps)
  2. far hills: wavy top y 31..41 across x 0..240, base #968f96
  3. heath hills: wavy top y 42..51, base #7a5cc0 (dusk family)
  4. mist band: stepped ellipse y 38..50 across x 12..228, #f4f0e0 (hard 2-tone, no alpha)
  5. meadow: wavy top y 57..63 down to y 80, base #58a03e (moss)
  6. heather dots: about 24 2x2 dots in #4e3a8a and #c3b2ea scattered on y 50..59
  7. standing stone: rrect x 43..49, y 40..61, #6a6070 with 1px lit edge #968f96
  8. stone wall: row of rrect 7x6 blocks x 132..182, y 66..73, alternating #968f96 and #6a6070
- joins: thread-gold hem stitch along top and bottom edges (2 on, 1 off), 3px in.
- face: none.
- notes: scene bleeds all edges; each hill band gets its own 2px outline and crescent. Bands run full width with no gaps.
