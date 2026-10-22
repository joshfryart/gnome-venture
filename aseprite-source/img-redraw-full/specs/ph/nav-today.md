# ph/nav-today
- canvas: 64x64, mode icon, 1x.
- subject: A cosy little cottage seen front-on, the navigation icon for "Today" (home); warm and welcoming.
- must-read-at-16px: a red triangular roof over a cream block with a chimney stub on the right.
- distinct: front-facing gabled house with chimney at upper right and a split-tone roof (lit left half, darker right half), unlike any tool or plant icon.
- parts:
  1. chimney: rect x 42..49, y 12..24, #c4925f, drawn behind the roof
  2. walls: rect x 12..52, y 28..56, base #f1ece0 (pale)
  3. roof: triangle (5,31),(32,7),(59,31), base #d6322b; left half lighter #e0501f
  4. door: rect x 26..37, y 40..56, #8c4a1a wood
  5. doorknob: 2x2 at (34,48) #e8a317
  6. windows: two 8x8 squares at (15,34) and (41,34), #a9d6ea
- joins: seam along the roof eave y 31 from x 8..56 (thread gold); 4x4 button at the roof peak (30,14).
- face: none.
- notes: pale walls need umber outline on all sides. Windows min 3 px. Roof overhangs walls 3 px each side.
