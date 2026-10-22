# ico/ico-gnome-hat
- canvas: 64x64, mode icon, 1x.
- subject: A gnome head peeking under a tall red pointed hat with a rust band and a cream pom on the tip; round tan face, tiny pink nose, white beard; friendly.
- must-read-at-16px: a tall red pointed hat with a pale pom on top over a round face and cream beard.
- distinct: a TALL LEANING HAT whose tip bends slightly to the right ending in a cream pom, the tallest silhouette among head icons.
- parts (back to front):
  1. face: circle (32,36) r10, base #dcb06a (tan skin, skin ramp #e9b98a nudged)
  2. beard: shape from (22,38) curving down to point (32,59) and back to (42,38), base #f1ece0 (pale, cream-safe)
  3. nose: circle (32,38) r3, base #f6b8cf (petal pink)
  4. hat: triangle (18,29),(34,6),(46,29) leaning right, base #d6322b (red)
  5. hat band: rect x 16..48, y 27..32, base #c66b50
  6. pom: circle (34,7) r3, base #f4f0e0 (pale, cream-safe)
- joins: thread-gold seam along band y 29 (x 17..47); band is the brim.
- face: small eyes (3x3 disc, 2x2 pupil) at (26,34) and (35,34), just under the band.
- notes: pale beard and pom cream-safe. Pom must stay inside 3 px of the frame margin (tip at y>=6 is OK after halo check). Band overlaps face with contact shadow.
