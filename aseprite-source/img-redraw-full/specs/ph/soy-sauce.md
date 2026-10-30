# ph/soy-sauce
- canvas: 64x64, mode sticker, 1x.
- subject: A square dark-glass soy bottle with a red cap and pouring spout, black-brown sauce, a soybean pod on the label.
- must-read-at-16px: square shouldered dark bottle with a red cap and a visible spout lip.
- distinct: vs fermented-hot-sauce: near-black #3a2a1f liquid in a SQUARE-section bottle with wide flat shoulders, a spout, and cream label with pod emblem; cap red #a8241f.
- parts (back to front):
  1. bottle body: rrect x 16..48, y 20..57 (r3), dark glass #3a2a1f with a left highlight 2px #5b6470, shade right #2a1a10
  2. neck: rect x 26..38, y 12..21, #3a2a1f
  3. spout: small wedge (38,14),(44,14),(38,18) #3a2a1f lip highlight px
  4. cap: rrect x 25..39, y 6..13 (r2), red #a8241f shade #5a1010
  5. label: rect x 20..44, y 30..50 cream #f1ece0; soy pod emblem: green pod #7ab55c with 3 bumps and bean dots #e8d890
  6. liquid line: 1px #c9a96e at y 24 through glass shoulder
- joins: cap over neck y13.
- face: none.
- notes: pantry food from the Pantry (soybean x4, wheat x2). Lit upper-left, gloss comma on the body. dark body, strong cream label. Its own vessel/lid/emblem, never a recolour of a sibling. Style: all coords within 2..61 (edge margin >=2px), no semi-transparent px, no pure #ffffff except ONE highlight pixel (use #fbf6e8 for bubbles/sheen).
