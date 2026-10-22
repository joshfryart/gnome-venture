# ph/nav-world
- canvas: 64x64, mode icon, 1x.
- subject: Navigation icon for the world map tab: a small blue globe with three green continents.
- must-read-at-16px: a round blue ball with green land patches.
- distinct: three distinct landmasses (big upper-left, tall right, small top cap) and a faint equator curve; no stand or ring.
- parts:
  1. ocean sphere: circle (32,31) r25, base #3f93b2 (water base)
  2. upper-left continent: blob (14,22),(22,12),(30,16),(34,24),(26,28),(22,36),(16,34), #58a03e (moss)
  3. right continent: (36,30),(46,26),(50,34),(48,46),(40,50),(36,42),(36,36), #7ab55c
  4. top cap land: (34,8),(44,10),(48,16),(40,18),(34,14), #58a03e
  5. equator curve: 1px (10,31)->(32,36)->(54,31), #256a80
- joins: none.
- face: none.
- notes: continents are flat parts with inner contours; shade crescent at the lower right; gloss comma upper left over the ocean; chunky icon, parts min 3px.
