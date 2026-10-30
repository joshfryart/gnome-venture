# ph/dried-mushrooms
- canvas: 64x64, mode sticker, 1x.
- subject: A brown paper lunch bag, top folded twice and clipped with a wooden clothes-peg, brown mushroom slices sticking out.
- must-read-at-16px: a paper bag with a peg at the top and a few umbrella-shaped slices peeking out.
- distinct: peg-clipped paper bag: a boxy bag with a double-fold top and a wooden clothes-peg; the only bag with a peg and visible mushroom cap shapes.
- parts (back to front):
  1. bag body: rect x14..50, y22..57 (r2), paper #d8b97e, 1px #c9a96e side gusset at x44
  2. folded top: rect x12..52, y16..24, #c9a96e, fold line 1px #9a6b3f at y20
  3. peg: rect x28..36, y12..30 #c9a96e with a 2px split #7a4a1f, spring dot 2x2 at (32,22)
  4. mushroom slices: four slices, caps ellipse 9x5 + stem 3x5 at (20,16),(26,13),(38,13),(44,16), #8a5a2f with #c9a96e gills line
  5. label: stamp rect x22..42, y32..50 cream #f4f0e0; emblem morel: cone 6x8 #8a5a2f with 1px honeycomb dots #5a3a1f
- joins: fold line and peg are the join; edge stitch dashes at the bag sides.
- face: none.
- notes: pantry food from the Pantry. Morel x4. Colour #8a5a2f; the peg stops it reading as a plain linen sack. Style: no pure #ffffff except one highlight pixel; keep every coordinate within 2..61 (2px edge margin); solid opaque pixels only, no semi-transparent shading; cel shade lower right.
