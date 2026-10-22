# ico/ico-sun-rain
- canvas: 64x64, mode icon, 1x.
- subject: Weather icon: a sun peeking out from behind a rain cloud with raindrops falling; sun showers.
- must-read-at-16px: a yellow sun disc at upper left overlapped by a grey cloud with blue drops below.
- distinct: the sun sits BEHIND the cloud at upper left and two slanted blue rain streaks fall from the cloud bottom; no rays.
- parts:
  1. sun disc: circle (21,21) r12, base #f2b830 (gold family)
  2. cloud puffs: circle (35,37) r9, circle (46,39) r8, rrect x 24..53, y 39..49 (r5), union, base #8c9ca6 (stone family)
  3. rain streak L: line (31,52)->(29,58) w4, #3f93b2 (water)
  4. rain streak R: line (43,52)->(41,58) w4, #3f93b2
- joins: none.
- face: none.
- notes: cloud overlaps sun with 1px inner contour; all parts min 3px; gloss on sun upper-left and on the cloud top puff.
