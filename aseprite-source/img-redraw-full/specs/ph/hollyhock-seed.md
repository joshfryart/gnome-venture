# ph/hollyhock-seed
- canvas: 64x64, mode sticker, 1x.
- subject: A hollyhock seed item: a lumpy burlap sack gathered at the neck and tied with twine, a golden round seed printed on its belly; rustic and soft.
- must-read-at-16px: a plump sack with a pinched neck and two floppy ears on top, wider at the bottom.
- distinct: slumped sack silhouette (round bottom, cinched neck, two ear flaps) tied with twine; the only soft, non-rigid container.
- parts:
  1. sack body: ellipse c(32,40) r 19x16 (flat bottom at y 55), base #c9a96e (soil-light burlap)
  2. neck gather: trapezoid x 25..39, y 18..28, base #c9a96e
  3. top flaps: left poly (22,12),(28,20),(24,24), right poly (42,12),(36,20),(40,24), base #9a6b3f
  4. twine wrap: line x 24..40 at y 26..27, 2px, #7a4a1f; knot 4x4 at (30,25)
  5. twine tails: 2px lines from (32,27) to (27,33) and (37,33), #7a4a1f
  6. seed badge on belly: ellipse c(32,44) r 9x8, base #e8a317 (gold)
  7. seed sprout: 2px stem (32,35)-(32,38) #4a8a3e, leaf 4x3 #7ab55c
- joins: edge stitch ring around sack body (2px in, skip gloss); twine knot acts as the tie.
- face: none.
- notes: burlap = soil family ramp; seed uses gold ramp; weave texture only as 2-3 single dark pixels, no dither.
