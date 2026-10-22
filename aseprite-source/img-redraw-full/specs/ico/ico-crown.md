# ico/ico-crown
- canvas: 64x64, mode icon, 1x.
- subject: A royal gold crown with three tall points, a thick band at the base and one big red jewel in the middle; proud and cheerful.
- must-read-at-16px: three triangular points (the middle one tallest) over a wide flat band.
- distinct: a middle point taller than the side points and a round red jewel on the front, with a darker-gold band.
- parts:
  1. crown body polygon: (7,46),(7,16),(21,29),(32,10),(43,29),(57,16),(57,46), base #dcb06a (gold ramp, nudge toward #e8a317)
  2. band: rrect x 7..57, y 45..54 (r 2), base #b8893f
  3. jewel: circle cx 32 cy 35 r 4.5, base #9c2a1e (red family #dd3a2a shade)
  4. point tips: 3x3 gold balls #f5cf6a at (7,15),(32,9),(57,15)
- joins: seam along the band top y 46 (thread gold 2 on/1 off); no button.
- face: none.
- notes: icon parts min 3 px; jewel 9 px wide with gloss. Points are the silhouette, keep V notches about 8 px deep.
