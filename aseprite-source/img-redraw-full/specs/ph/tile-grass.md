# ph/tile-grass
- canvas: 64x64, mode scene (tile), 1x, full-bleed, no halo, no outline.
- subject: A seamless flat grass ground tile, fresh meadow green with small scattered tufts and a few darker specks.
- must-read-at-16px: flat mid green with small darker tufts, no strong pattern.
- distinct: tuft-only meadow with a soft lighter patch in the upper right; plain and restful, no flowers.
- parts:
  1. base fill: rect 0..64 x 0..64, #7ab55c
  2. light patch: pixel-stepped blob near (46,18), r about 12, lighter green #a4b86a, 2-3 steps only
  3. tufts: 8 small three-blade tufts, 5 px tall, #4a8a3e, base points (33,36),(20,13),(50,22),(14,43),(35,19),(38,14),(27,53),(38,38)
  4. dark specks: 6 horizontal 3-4 px dashes #2f5a2a at (12,20),(44,8),(26,46),(52,38),(8,56),(36,28)
- joins: tile edges must wrap; keep tufts at least 3 px from the border.
- face: none.
- notes: no dithering; every pixel a palette colour; moss family (#7ab55c base, #4a8a3e shade, #2f5a2a deep).
