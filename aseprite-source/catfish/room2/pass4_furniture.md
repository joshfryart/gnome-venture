# Pass 4: final polish notes for room A furniture (P3)

Review images are in `out_furn/_view/review/p4/`: `scene_1x/2x/half2x.png` and `scene_{left,right,shelf,rug}_4x.png` / `_half8x.png`. They show the plates, all current furniture and cats. Note that `out_room/cf-room2-scene-preview-2x.png` is stale: it was built 36 s before the pass-3 regen and shows the old flat rug. All coordinates below are on the half grid.

## Changes, highest priority first

1. **Outline tone per stacked part (cattree, scratch, plant).** gvlib picks the outline tone from s = (x-cx)+(y-cy) about the canvas centre. On tall sprites, everything below mid-height comes out #2a1a10 plus the extra olx ring, on the lit left side too. For example, cattree base slab rows 44-55 have 2-3 px of #2a1a10 at x0-2, and the scratch post's left outline goes `0 -> a -> b` from y20 down. This is the "heavy outline" flaw from pass 1.
   In `make()`, inside `if not meta.noline`, before `c:outline(sil, { keep = true })`, add:
   ```lua
   for _, b in ipairs(meta.olbands or {}) do          -- {y0, y1, cy}: re-centre the tone per part
     c.cy = b[3]
     local g1, g2 = sil:grow(c.ol), sil:grow(c.ol + c.olx)
     for k in pairs(g2.s) do
       local x, y = c:xy(k)
       if y >= b[1] and y <= b[2] and not sil.s[k] and c:inside(x, y) and not c.pix[k]
          and (g1.s[k] or c:s(x, y) > c.tx) then c.pix[k] = c:tone(x, y) end
     end
   end
   c.cy = S.h / 2
   ```
   Meta values:
   - cattree `olbands = {{0,12,9},{13,25,19},{26,33,29},{34,43,38},{44,55,49}}`
   - scratch `olbands = {{0,9,5},{10,29,19},{30,37,33}}`
   - plant `olbands = {{0,18,9},{19,29,24}}`
2. **cattree: delete the felt-nap loop** (the `for _, y in ipairs({47, 49, 28})` block, lines 239-241). At 4x in the scene its `abba` dashes read as dark holes in the slabs.
3. **cushion: delete the nap.** Remove both `top:each` blocks (lines 99-104) and `local NAP`. After the lone-px cleanup, only two 2-px ticks were left, at row 5 x3-4 and x31-32. They read as stray marks. The sprite goes from 12 to 11 colours.
4. **bowl: replace the kibble lattice.** `(x+2y)%3` still reads as a waffle at 4x. In `open:each`, replace the `else` branch with:
   ```lua
   else
     local dy, col = y - oy0, WOOD.base
     if dy == 1 and x % 5 < 2 then col = WOOD.rim
     elseif dy == 2 and (x + 2) % 5 < 2 then col = WOOD.rim
     elseif dy >= 3 then col = WOOD.shade end
     c:px(x, y, col)
   end
   ```
   Then add `open:each(function(x,y) if c:get(x,y)==WOOD.rim and c:get(x-1,y)~=WOOD.rim and c:get(x+1,y)~=WOOD.rim then c:px(x,y,WOOD.base) end end)`. This makes 2-px lit nuggets on rows 3 and 4 and a shaded heap underside on row 5. The sprite goes from 11 to 12 colours.
5. **bowl-plain: same treatment.** `rows[3]` -> `".RRSkkKKKkkKKKSRB."` and `rows[4]` -> `".RRSKKKkkKKKkkSRB."` (18 chars each, S = TERRA.shade = #8a4f2a, which is already in the sprite).
   ```
   y3  .RRSkkKKKkkKKKSRB.
   y4  .RRSKKKkkKKKkkSRB.
   ```
6. **cattree top bed: add the gold seam** the other two slabs and the cushion have. After the `c:paint` bed block, add `c:seam({ { 5, 11 }, { 20, 11 } }, { gap = PINK.shade })`. Row 11 x5..20 is all PINK.shade now. There are no new colours (the gold is already in the sprite).
7. **make_view_furn.py `review()`: add a live scene composite** so stale room previews stop misleading reviews. Write `_view/review/scene_2x.png` and `scene_half2x.png`:
   - Stack the `out_room` plates `p0-sky, p1-wall, p2-floor, p5-sunbeam, window`.
   - Add every furniture sprite except `bowl-plain` and `petbell` (covered or same slot), sorted by `z - 1000*under_cats`.
   - Add grey idleA cats at (u, d) = (.5, .05), (.5, .5) and (.45, .85), scaled with `round(s*16)/16` and anchored at foot (33, 60).
   - Add `p4-front` last, pasted at (-4, 0).
   - Save at 2x and 0.5x nearest.
8. **make_view_furn.py `checks()`: add check (f), outline side.** On the half grid, check these pixels:

   | Sprite | Pixel (x, y) | Expected |
   |---|---|---|
   | cattree | (0, 48) | #74462a |
   | cattree | (25, 49) | #2a1a10 |
   | scratch | (0, 31) | #74462a |
   | scratch | (13, 31) | #2a1a10 |
   | plant | (2, 24) | #74462a |

   On failure, append `"outline side"`.
9. **make_view_furn.py check (e): tighten the caps after 2-5.** Set cushion 45 -> 30, bowl 30 -> 12, bowl-plain 12 -> 10, cattree 20 -> 12. If a measured count beats a cap, set that cap to the new count + 2 and report it.
10. **(Optional, new sprite) `yarnpatch-rug`.** The yarn sits at (154, 204), which is inside the rug (x≈119..361 at that row). Its #9a6b3f floor shadow then shows as a brown block on green (`scene_rug_4x.png`). Copy the `yarnpatch` make() as `make("yarnpatch-rug", 40, 20, {…same…, upgrade = "rug", covers = "yarnpatch"}, …)`, with the shadow hex `"#3f7a3a"` (GREEN.shade) in place of SHADOW. This follows the existing `bowl` / `covers = "bowl-plain"` convention, and furniture.json gains an 18th entry. Skip this if the game code cannot take a new key. If you skip it, report it as a flaw.

Not changed on purpose: the rug weft and fringe read as fine woven lines at 2x and 0.5x. The sisal tiles read as wound rope at 1x. The bell, books, bookstack, petframe, catflap and pets are clean next to the house art and the cats.

## Acceptance
- `cf_room_a_furn.lua`: GV prints ALL OK. `make_view_furn.py` exits 0 with checks (a)-(f).
- Colours: cushion 11, bowl 12, bowl-plain 9, cattree <= 16, every sprite <= 16. Alpha is only 0 or 255. No #000000 or #ffffff.
- Cattree half grid:
  - rows 44-53 contain no `#2a1a10` at x <= 1 except on rows 52-55.
  - row 11 shows alternating gold/PINK.shade at x5..20.
  - no GREEN.shade px inside the slab tops at rows 28, 47 or 49 between x2..8 and x17..23, apart from the ellipse crescent.
- The cushion has no #cf5886 anywhere.
- bowl half-grid rows 3-4: every WOOD.rim run is exactly 2 px long, and row 5's open px are all #8a4f2a.
- Speckle counts: cushion <= 30, bowl <= 12, bowl-plain <= 10.
- In `review/scene_2x.png`, the cattree base, scratch base and plant pot show light-brown left outlines that match the cushion's and the cats' left edges.
- Anchors and origins are unchanged (check a). The rug sides are still within 1.5 px of the VP lines (check b).
