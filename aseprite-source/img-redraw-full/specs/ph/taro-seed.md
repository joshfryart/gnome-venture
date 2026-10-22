# ph/taro-seed
- canvas: 64x64, mode sticker, 1x. Original look ignored on purpose.
- subject: A flat paper seed packet with a folded flap, a lavender taro corm drawn on its front with two green leaves.
- must-read-at-16px: a flat rectangular packet with a triangular folded flap across the top.
- distinct: flat paper packet with a triangle flap pointing down over the front, lavender drop-shaped corm on a framed label (wide and flat, no lid or knot).
- parts:
  1. packet body: rect x 16..48, y 14..54 (r 2), base #f1ece0 (paper, pale)
  2. folded flap: triangle (16,14),(48,14),(32,28), base #d9a660 lit edge, 1px inner contour
  3. label panel: rrect x 21..43, y 31..50 (r 3), base #f4f0e0, 2px lavender border #c3b2ea
  4. taro corm: drop shape x 26..38, y 35..50 tapering to a point at the bottom, base #c3b2ea
  5. corm marks: two 2px dashes (28,40..42) and (33,44..46), #2a1a10
  6. two leaves: beans from (32,35), up-left x 26..31, y 31..36 and up-right x 33..38, y 31..36, base #7ab55c
- joins: gold seam 2 on/1 off along the two flap fold edges (16,14)->(32,28) and (48,14)->(32,28).
- face: none.
- notes: pale lavender corm needs an umber outline; pale paper cream-safe. Seed item, no text.
