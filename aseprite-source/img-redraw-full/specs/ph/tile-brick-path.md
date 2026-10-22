# ph/tile-brick-path
- canvas: 64x64, mode scene-style tile (full-bleed square, no halo, no outline), 1x.
- subject: A seamless red brick paving tile in running bond with cream mortar.
- must-read-at-16px: red bricks in offset rows on pale mortar.
- distinct: six rows of bricks, every other row shifted half a brick, with a few lighter bricks in a loose diagonal; full-bleed square.
- parts:
  1. mortar fill: rect 0..63, #f4f0e0 (cream, pale)
  2. bricks: 14x9 rounded (r1) at rows y 1, 12, 22, 33, 44, 54; rows 1,3,5 start x 1,17,33,49; rows 2,4,6 start x -7,9,25,41,57 (wrap, clipped); base #a8241f (ember family, shade of #d6322b)
  3. lighter bricks #d6322b at (9,33), (1,44), (17,44), (25,54), (41,54)
  4. 1 px top-left highlight on each brick (#e0501f) and 1 px lower-right shade (#6b1b2c)
  5. tiny dark scuffs: 1x3 #4a2c1a at (12,20),(44,8),(26,46),(52,38),(8,56),(36,28)
- joins: edges must tile (left/right bricks wrap); no stitch.
- face: none.
- notes: full-bleed, no halo. Mortar lines 2 px. Hard pixels, no gradients.
