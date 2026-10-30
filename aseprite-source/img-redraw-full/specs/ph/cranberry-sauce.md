# ph/cranberry-sauce
- canvas: 64x64, mode icon, 1x.
- subject: A tin can of ruby cranberry sauce, lid peeled back, jelly slumped out with the can's ridges printed on it.
- must-read-at-16px: upright tin can with a ruby jelly dome on top and a curled lid.
- distinct: only tin can in the shard (no glass): grey tin, ridged rolled rim, ruby #d6322b jelly cylinder with ring grooves. Signature detail: the jelly dome sits above a can rim with a curled lid beside it.
- parts (back to front):
  1. can body: rect x 15..49, y 26..54 (r2), tin #8b8f96 with ridge lines at y 31 and y 49 #5b6470
  2. rim: rrect x 14..50, y 24..28, #c9c5bc
  3. jelly: rrect x 17..47, y 12..26 (r5), ruby #d6322b with 2 ring grooves #a8241f and glint (24,16)
  4. label band: rect x 15..49, y 34..46, cream; emblem 8px: two cranberries #a8241f with a leaf #4f9a45
  5. curled lid: ellipse + curl x 44..56, y 20..30, #c9c5bc, 1px #8b8f96 edge
- joins: tin ridge lines cross the whole body.
- face: none.
- notes: pantry food from the Pantry (cranberry x5). Own jar, lid and label emblem, no recolour of a sibling. Cel-shade lower right, gloss upper-left, umber #2a1a10 outline, cream #f4f0e0 label. No pure #ffffff except one highlight pixel; keep coordinates within 2..61 (2px edge margin); no semi-transparent pixels. Keep the ingredient colour dominant.
