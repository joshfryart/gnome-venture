# ico/ico-storm
- canvas: 64x64, mode icon, 1x.
- subject: A storm cloud with a lightning bolt beneath it; threatening weather.
- must-read-at-16px: A yellow zig-zag bolt cutting through the bottom of a grey cloud.
- distinct: Lumpy grey cloud above and a bright yellow bolt, the highest-contrast shape, crossing the cloud base.
- parts:
  1. cloud puffs: circle r 8 at (24,22), circle r 11 at (34,17), circle r 8 at (45,23)
  2. cloud base: rrect x 14..52, y 22..33 (r 6), base #8c9ca6 (stone cool family), shade #5b6470, deep #3a4452
  3. bolt: polygon (38,30),(28,42),(34,42),(30,55),(44,38),(37,38),(42,30), base #f2b830, shade #d0862a, gloss #fff1c8
  4. contact shadow: 1px #5b6470 where the bolt overlaps the cloud
- joins: none
- face: none.
- notes: Gloss on the upper-left puff. Bolt starts inside the cloud and extends below.
