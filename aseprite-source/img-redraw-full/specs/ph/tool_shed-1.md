# ph/tool_shed-1
- canvas: 64x64, mode sticker, 1x.
- subject: Level-1 tool shed: a small plank hut with a grey pitched roof, a crossed-brace door and two garden tools hanging on the outer walls. Tidy, sturdy.
- must-read-at-16px: wide grey roof trapezoid sitting on a brown box with a dark square door.
- distinct: roof is a wide trapezoid overhanging the walls with a darker eave strip; door has an X brace; tool heads hang on both outer walls.
- parts (back to front):
  1. walls: rect x9..55, y26..50, wood #a5663a (wood #a8582f/#b07a45); two plank lines y33 and y41, #5e2f1e
  2. roof: trapezoid (5,29)->(13,14)->(51,14)->(59,29), stone #968f96 (stone #8b8f96)
  3. eave strip: rrect x5..59, y28..31, #6a6070 (stone shade)
  4. door: rect x24..40, y34..50, #8c4a1a (wood shade); X brace + centre post #44281c
  5. left tool: handle line (14,50)->(12,32) 2px #2a1a10, head rect x9..14, y29..33 #968f96
  6. right tool: handle (49,50)->(52,30) 2px #2a1a10, head tri (49,32),(54,30),(53,35) #968f96
- joins: seam along eave strip y29 x7..57 (hem); optional 4x4 button at door top (30,35).
- face: none.
- notes: gloss on roof upper-left; shed fills x4..60; no edge stitch on wood; ground shadow under walls.
