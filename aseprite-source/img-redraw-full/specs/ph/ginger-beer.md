# ph/ginger-beer
- canvas: 64x64, mode sticker, 1x.
- subject: A fat champagne-style bottle of fizzy ginger beer with a wired cork cage and a ginger root on the label.
- must-read-at-16px: heavy bottle with a wire cage over a thick cork and foil neck; golden #e8c070 liquid with bubbles; ginger root emblem.
- distinct: caged-cork fizz bottle: heavy sloping shoulders, a foil-wrapped neck and a wire muselet with a tiny twist; shows rising bubbles, the only bottle with bubble dots.
- parts (back to front):
  1. bottle body: rrect x16..48, y22..57 (r8) with sloping shoulders, glass #c8dde4
  2. neck: rect x27..37, y10..24, glass
  3. liquid: rrect x18..46, y28..55, #e8c070, darker #c89040 crescent
  4. bubbles: five 1px dots #fbf6e8 at (24,36),(28,32),(36,36),(40,44),(26,48)
  5. foil+cork: rect x26..38, y6..14, cork #c9a96e top y6..10, gold foil #e8a317 y10..14; wire cage: 1px #8b8f96 cross at (32,8)-(32,20), loop 8x2 at y15
  6. label: oval x21..43, y36..52 dark green #2f6a3a with a 1px cream #e8d8b0 rim (redraw-C: a tan root on cream was a low-contrast blob); emblem ginger root 17x9: a knobby pale-tan #e8c080 rhizome with two raised fingers, #f8e6b8 lights, #a8742f ring marks, outlined #4e2a16
- joins: foil crimp at the neck is the seam; no edge stitch on glass.
- face: none.
- notes: pantry food from the Pantry. Ginger x3, sugarcane x1. Bubble dots are #fbf6e8 (never #ffffff); fizzy, not syrupy, so keep the liquid lighter than the cane syrup. Style: no pure #ffffff except one highlight pixel; keep every coordinate within 2..61 (2px edge margin); solid opaque pixels only, no semi-transparent shading; cel shade lower right.
