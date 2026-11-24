# Pass 3: texture notes for room A furniture (P3)

Review images: `out_furn/_view/review/p3/` (`<key>_8x.png` or `_4x.png`, `<key>_half4x.png` = the 0.5x view, `<key>.txt` = half-grid ascii).
All coordinates are on the half grid (canvas = export / 2), so the half grid is exactly what survives at 0.5x. "base", "rim" and "shade" are ramp fields. Add each texture after the part fill and before `c:stitch`, `c:seam`, `c:button` and `c:gloss`, so the gold and the gloss stay on top. Paint a texture px only where `c:get(x,y) == <ramp>.base`, unless a note says otherwise.

## Changes, highest priority first

1. **bowl-plain + bowl: remove the kibble checker** (it is dither: 24 and 57 isolated px).
   - bowl-plain `rows[3]` -> `".RRSKKkKKkKKkKSRB."` (18 chars, x4..13 = `KKkKKkKKkK`). `rows[4]` -> `".RRKkKKkKKkKKkKRB."` (18 chars). These make 2 px nuggets, each with 1 lit `k` nub, on a diagonal stagger.
   - bowl `open:each`: `((x + y) % 2 == 0)` -> `((x + 2 * y) % 3 == 0)`.
2. **rug: woven weft rows** (the 120 x 20 field is flat). Add the new colour `local WEFT = "#4f8c41"` (between GREEN.base and GREEN.shade). After `c:fill(band, ...)`:
   ```lua
   for i, y in ipairs({6, 8, 10, 12, 15, 18, 21, 24}) do      -- spacing grows toward the viewer
     for x = 0, 138 do
       if (x + 2 * i) % 4 < 2 and c:get(x, y) == GREEN.base then c:px(x, y, WEFT) end
     end
   end
   ```
   This gives 2-on 2-off dashes that shift 2 px per row (a twill). The tufts are skipped by the base test. The sprite goes to 8 colours.
3. **rug: front fringe.** After the lip loop, add `for x = 0, 138 do if m:has(x, 30) and x % 3 == 0 then c:px(x, 30, "#e8d0a0") end end` (tassels 1-on 2-off on the dark lip).
4. **cattree `post()` and scratch post: twisted sisal** (now it reads as ladder rungs). Replace the stripe loop with a 3-row tile, `x0` = 10 (cattree) or 4 (scratch), 6 px wide:
   ```
   t0  RRRBBS
   t1  BRRRBS
   t2  SSSSSS
   ```
   ```lua
   local T = {"RRRBBS", "BRRRBS", "SSSSSS"}
   for y = y0 + 1, y1 - 1 do c:paint({T[(y - y0 - 1) % 3 + 1]}, x0, y, {R = SISAL.rim, B = SISAL.base, S = SISAL.shade}) end
   ```
   The range y0+1..y1-1 is the same as the old loop, so the slab rows are not touched. For scratch use `y0, y1 = 7, 31`. The lit strand steps 1 px right per row, which reads as a rope twist. No new colours (cattree stays at 16).
5. **cushion: fabric nap.** Add `local NAP = "#cf5886"`. After `c:fill(inner, ...)` and the two dip fills:
   ```lua
   top:each(function(x, y)
     if y % 2 == 1 and (x + (y // 2) * 3) % 6 < 2 and c:get(x, y) == PINK.base and not inner:grow(1):has(x, y) then c:px(x, y, NAP) end
   end)
   ```
   This gives 2 px ticks on rows 3, 5, 7, 9 and 11, staggered by 3. The sprite goes to 12 colours.
6. **cattree slabs: felt nap with no new colour.** At the end of the function, before the two seams:
   ```lua
   for _, y in ipairs({47, 49, 28}) do for x = 2, 23 do
     if (x < 9 or x > 16) and (x + y) % 5 < 2 and c:get(x, y) == GREEN.base then c:px(x, y, GREEN.shade) end
   end end
   ```
7. **toybox: wood grain on the front face** (rows 9 and 13 are flat WOOD.base). After `c:button`:
   - `c:fill(c:rect(6,9,8,9), WOOD.shade)`
   - `c:fill(c:rect(14,9,17,9), WOOD.shade)`
   - `c:fill(c:rect(2,13,20,13), WOOD.base)`
   - `c:fill(c:rect(4,13,7,13), WOOD.shade)`
   - `c:fill(c:rect(13,13,15,13), WOOD.shade)`
   - knot: `c:px(16,13, WOOD.shade); c:px(17,13, WOOD.rim)`

   No new colours (the sprite stays at 16).
8. **plant: folded leaves** (three flat slabs). After the `c:px` rim ticks, paint a midrib column in MOSS.shade, which leaves the right half of each leaf in shade:
   - `c:fill(c:rect(8,5,8,16), MOSS.shade)`
   - `c:fill(c:rect(3,10,3,16), MOSS.shade)`
   - `c:fill(c:rect(13,10,13,16), MOSS.shade)`

   Only paint px that are MOSS.base or MOSS.rim. Do not touch the outline.
9. **plant pot: clay rings.** `c:fill(c:rect(4,26,11,26), TERRA.base)` and `c:fill(c:rect(5,23,8,23), TERRA.rim)` add a throwing ring and a lit lip on the body (rows 22..27).
10. **books: spine bands.** In the book loop, add `c:fill(c:rect(b[1], 5, b[2], 5), b[4].rim)` (a raised cloth band). The rim colours are already in the sprite, so there are no new colours.
11. **bookstack: page-block lines.** `c:paint({"pp"}, 13, 4, {p = CREAM})` and `c:paint({"pp"}, 14, 6, {p = CREAM})` replace the single CREAM px, so the page edges read 2 px wide.
12. **petframe: mitre joints.** `c:px(2,2,"#8a4f2a"); c:px(9,12,"#8a4f2a")`, plus grain `c:fill(c:rect(4,1,6,1), "#b07a45")` on the lit top rail.
13. **catflap: grain on the top rail.** `c:fill(c:rect(3,1,5,1), WOOD.base)`.
14. **make_view_furn.py `checks()`: add check (e), a speckle cap.** On the half grid, count opaque px whose 4 neighbours are all opaque and all a different colour. Fail when the count is over `LIMIT = {"cushion":45, "bowl-plain":12, "bowl":30, "rug":60, "toybox":24, "cattree":20, "scratch":16, "plant":10}`, or over 8 for any other key. The current counts are cushion 39, bowl-plain 24, bowl 57, rug 43, toybox 16, cattree 7, scratch 8, plant 4.

## Acceptance
- GV report ALL OK. Checks (a)-(e) pass.
- Colours: cushion 12, rug 8, cattree <= 16, toybox <= 16, books 12, every sprite <= 16. Alpha is only 0 or 255. No #000000 or #ffffff.
- bowl-plain half-grid rows 2-3 contain no `kKkK` alternation, and the bowl singleton count falls below 30.
- The cattree half grid shows the upper post (visible rows y13..y25) cycling `RRRBBS / BRRRBS / SSSSSS` at x10..15.
- In `rug_half4x.png`, the weft rows read as fine horizontal lines (not noise). Row spacing is 2 at the back and 3 at the front.
- No texture px lands on outline tones (#2a1a10, #4a2c1a, #74462a) or on any gold stitch px.
