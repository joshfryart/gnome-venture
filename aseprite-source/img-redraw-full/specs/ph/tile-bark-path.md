# ph/tile-bark-path
- canvas: 64x64, mode scene (seamless tile, full-bleed, no halo, no outline), 1x.
- subject: A seamless floor tile of mulch bark chips: scattered small rounded wood chips on warm brown ground.
- must-read-at-16px: warm brown ground with scattered lighter and darker chip flecks.
- distinct: about 20 chips in four tones scattered at varied angles, no grid; edges must tile.
- parts (back to front):
  1. ground fill full 64x64, #a5663a (wood #a8582f/#b07a45)
  2. dark chips: 4x2 to 6x3 rounded bars #44281c (wood deep #5e2f1e) at (39,3),(40,5),(19,30),(50,38),(11,27)
  3. mid chips: #8c4a1a (wood shade #8a4f2a) at (18,15),(20,16),(7,54),(3,40),(41,30),(47,21)
  4. light chips: #dcb06a (wood rim #d9a660) at (39,53),(27,21),(49,34),(4,46),(15,6),(22,10)
  5. ground-colour chips #a5663a with 1px darker edge at (51,23),(10,52),(25,56),(44,50),(54,39)
  6. tiny 1px crack lines #5e2f1e at (12,20),(44,8),(26,46),(52,38),(8,56),(36,28)
- joins: wrap-around; chips crossing an edge continue on the opposite edge.
- face: none.
- notes: chips 2-3 px thick, mostly horizontal-ish with a few 30-40 degree tilts; light chips get a 1px #ecc58a top pixel; no outline, no gloss comma.
