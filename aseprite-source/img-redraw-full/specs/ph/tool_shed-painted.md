# ph/tool_shed-painted
- canvas: 64x64, mode sticker, 1x.
- subject: A small painted garden tool shed with a pink pitched roof, pale-blue walls, a brown cross-braced door and tools hanging at the sides; cute and proud.
- must-read-at-16px: a pink pitched roof wider than a pale-blue box with a brown door in the middle.
- distinct: pink roof with a dark eave band, plus two hanging tools (spade at right, trowel at left) on the wall edges.
- parts:
  1. walls: rect x 9..55, y 26..50, base #a9d6ea (water pale), plank lines at y 33 and 41 #2a1a10
  2. roof: trapezoid (4,29),(13,14),(51,14),(60,29), base #e46a9b (petal)
  3. eave band: rect x 4..60, y 28..31, #6a6070 (stone-violet)
  4. door: rect x 24..40, y 34..50, base #8c4a1a (wood), X braces and centre plank #44281c
  5. right tool: handle 2px (49,50)->(52,30) #2a1a10, blade triangle (49,31),(54,30),(53,36) #968f96
  6. left tool: handle (14,50)->(12,32), blade (9,29),(15,29),(14,33) #968f96
- joins: gold seam along the eave lower edge y31, x 8..56; 4x4 gold button at door top centre (30,35).
- face: none.
- notes: door braces stay visible as 1px lines. Tools hug the walls, min 2px.
