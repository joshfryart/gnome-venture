# ph/tepache
- canvas: 64x64, mode sticker, 1x.
- subject: A glass pitcher of cloudy golden pineapple drink with froth, a handle, and a pineapple-crown lid.
- must-read-at-16px: pitcher with handle on right and a spiky green crown on top.
- distinct: vs kvass/kombucha: PITCHER with side handle and pouring lip, crown lid of spiky leaves, pale cloudy gold #f5cf6a with froth and rind pieces.
- parts (back to front):
  1. pitcher body: rrect x 12..44, y 20..57 (r8), glass #a9d6ea; lip notch at (12,20)
  2. drink: rrect x 14..42, y 28..55 (r6), #f5cf6a shade #e8a317; froth row y 26..29 #fbf6e8
  3. rind pieces: three small diamonds #e8a317 with #7ab55c px
  4. handle: C shape 3px #a9d6ea x 44..54 y 28..48
  5. crown lid: spikes polygon (16,20),(40,20),(36,6),(32,12),(28,4),(24,12),(20,6) green #4f9a45 shade #2f5a2a
  6. label: rect x 18..38, y 40..52 cream #f1ece0 with pineapple emblem: body #e8a317 diamond-hatch #b07a10, crown 3 leaves #4f9a45
- joins: crown rests on rim y 20.
- face: none.
- notes: pantry food from the Pantry (pineapple x2, sugarcane x1). Lit upper-left, gloss comma on the body. froth is cream not white. Its own vessel/lid/emblem, never a recolour of a sibling. Style: all coords within 2..61 (edge margin >=2px), no semi-transparent px, no pure #ffffff except ONE highlight pixel (use #fbf6e8 for bubbles/sheen).
