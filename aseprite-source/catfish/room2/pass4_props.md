# Pass 4 (final polish): lure, wand cast, shadows, dust, streaks

I reviewed `out_props/_view/review/p4_*` (4x, 8x-12x, 1x and 0.5x sheets, plus `p4_scene_{2x,1x,0.5x,crop4x}.png`, which shows the props on `out_room/cf-room2-preview-cats2x.png`) and pixel dumps. Every edit goes in `cf_props_room2.lua` unless the item says otherwise.

## Bugs and inconsistencies found
- **Ear crescent cascades.** The p3 loop paints in place, so each painted px makes its left neighbour qualify. Near ear `#e9b98a` count by frame 1-6: 3/9/0/0/0/1. Mid: 4/1/1/1/1/1. The ears are now flat `#c98a68`.
- **Wand outline tone and width depend on canvas position, not on the wand.** `tone()` and `olx` use canvas-global `s(x,y)`.
  - Frame 5 has 130 `#2a1a10`; frame 3 has 21.
  - In frames 1, 4 and 6, the sleeve and cap get a 2-px `#2a1a10` outline on both sides (wand-1 rows 34-57: `Kkk...kkK`). They read as a dark blob at 1x and 0.5x.
- **Impact frame sinks.** The near/mid felt bottom row by frame 1-6 is 25/21/24/24/24/24 (near) and 15/13/14/14/14/14 (mid), because the clip row moves with `down`. The lure dips 1 px into its shadow on impact. Far does not.
- **Wobble slides.** Near 5→6 changes 233 px and mid 106, because `bodyDx +1` slides the whole body, loop and nap. Far 5→6 changes 18 px (ear and feather only).
- **Mid eye touches the ear contour.** In mid-4, `#2a1a10` at (13,9) and (14,9) sits right above the sclera at (12,9).
- **Near nap is busy.** At 0.5x it reads as speckle. Ticks touch the eye sclera (near-4 row 17, x16-17) and crowd the seam/shade band (row 21).
- **Wand sleeve.** The rib at t=6 (wand-1 row 46) merges with the shade rows 47-48, so the lower sleeve is 3 dark rows.

## Changes, highest priority first

1. **Wand outline: 1 px, tone by local side.**
   - In `wandFrame`: `GV.canvas{ w = 48, h = 64, mode = "sticker", margin = 1, ol = 1 }` → add `olx = 0`.
   - Just before `local t = c:save(...)`, add:
   ```lua
   c:finish()
   local OLT = { ["#74462a"]=1, ["#4a2c1a"]=1, ["#2a1a10"]=1 }
   local re = {}
   for k, h in pairs(c.pix) do
     local x, y = c:xy(k)
     if OLT[h] and not c.sil:has(x, y) then
       local col
       if c.sil:has(x-1, y) or c.sil:has(x, y-1) then col = "#2a1a10"      -- right / bottom side
       elseif c.sil:has(x, y+1) then col = "#74462a"                       -- top side
       elseif c.sil:has(x+1, y) then col = "#4a2c1a"                       -- left side
       else col = c.sil:has(x-1, y-1) and "#2a1a10" or "#4a2c1a" end      -- diagonal corner
       re[#re+1] = { k, col }
     end
   end
   for _, r in ipairs(re) do c.pix[r[1]] = r[2] end
   ```
   - `finish()` is idempotent (`self.done`), so `save()` keeps this recolour, and the black border is unchanged.
   - Do not touch inner contours (px inside `sil`).

2. **Fix the ear crescent cascade.** At the end of `buildLure`, collect the pixels first, then paint:
   ```lua
   local ec = {}
   p.ear.m:each(function(x,y) local r, d = c:get(x+1,y), c:get(x,y+1)
     if c:get(x,y) == "#e9b98a" and ((r ~= "#e9b98a" and r ~= PINK) or (d ~= "#e9b98a" and d ~= PINK)) then ec[#ec+1] = {x,y} end end)
   for _, q in ipairs(ec) do c:px(q[1], q[2], "#c98a68") end
   ```

3. **Keep the impact floor fixed.** In `buildLure`:
   - Change `body:clip(c:rect(0, 0, S.W - 1, S.clip + ty))` → `body:clip(c:rect(0, 0, S.W - 1, S.clip + ty - down))`.
   - Frame 1 then squashes from the top: the near top drops 2 px and the mid top drops 1 px. The floor stays at 24 near and 14 mid.

4. **Wobble without sliding.** Change `POSES[6].bodyDx 1 → 0`. Frame 6 then moves only the ear (+1) and the feather tip (-1), the same as far F[6].

5. **Thin the near nap.** In the nap block, replace `for y = cy - 4, cy + 2, 2 do` and the `% 6` test with:
   ```lua
   local e = S.eye; local ep = xf({ e[1] + 1, e[2] + 1 }); local ex, ey = rnd(ep[1] - 1), rnd(ep[2] - 1)
   local g = xf(S.gloss); local gx, gy = rnd(g[1]), rnd(g[2])
   for ri, y in ipairs({ cy - 4, cy }) do for x = 0, S.W - 1 do
     local dx = x - cx
     local nearEye = x >= ex - 2 and x <= ex + 4 and y >= ey - 1 and y <= ey + 3
     local nearGl  = math.abs(x - gx) <= 2 and math.abs(y - gy) <= 2
     if (dx + ri * 4) % 8 < 2 and not nearEye and not nearGl and (same 5 RED.base tests) then nap[#nap+1] = {x,y} end
   end end
   ```
   This gives 2 rows, a 2-px tick every 8 px, staggered by 4, and no ticks on the seam/shade band or beside the eye or gloss.

6. **Mid eye off the ear contour.** Change `SZ.mid.eye {10,9,3} → {10,10,3}`. That puts a felt row between the ear contour and the sclera.

7. **Sleeve ribs.** In `wandFrame` `scan(p.sleeve.m, ...)`, change `(t == 6 or t == 9)` → `(t == 8 or t == 11)`. Wand-1 ribs move to rows 44 and 41, giving the rhythm lit 40 / rib 41 / lit 42-43 / rib 44 / lit 45-46 / shade 47-48.

8. **`make_view_props.py`.** Add `review/p4_after_{8,1,0.5}x.png` (the same rows as p3_after plus the far row), and add these to the self-check (append to `bad`):
   - Near frames 1, 4, 5, 6: the felt bottom row (max y of `#dd3a2a`/`#b8452f`/`#ff9158`) is 24. Mid: 14.
   - Near frames 1-6: `#e9b98a` ≥ 6. Mid: ≥ 2.
   - Wand: for rows 40-48 of frame 1, the leftmost non-black px is `#4a2c1a`, the rightmost non-black px is `#2a1a10`, and the px right of that is `#000000`.

9. **Leave unchanged (byte-identical):** lure-far-1..6, shadow-1..4, dust-1..4, streak-1..3, `cf-wand-cast.json`. The far lure is ~40% undersized next to back-row cats (lure/cat width: near 0.71, far 0.40). That is a game-side choice of rung, not this group's job.

## Acceptance
- Lua prints `ALL OK`; the view script prints `checks: PASS`. Alpha is 0/255 only and there is no `#ffffff`. Colour limits are lures ≤ 16, wand ≤ 21, fx ≤ 4.
- Wand outline:
  - The `#2a1a10` counts of frames 3 and 5 differ by ≤ 15.
  - Every wand frame has `#4a2c1a` ≥ 20.
  - No row in frames 1-6 has two outline-tone px between the art and the black border on the same side.
- Ear: near `#c98a68` 4-10 per frame. Mid `#c98a68` 2-6 per frame, with `#e9b98a` ≥ 2.
- Near nap: 2-6 ticks per frame (frame 2 may be 0-3). No nap px is within the eye box ±1, and none is on rows ≥ cy+1.
- Diffs:
  - near 5↔6 ≤ 60 px; mid 5↔6 ≤ 30 px.
  - The bottom border row is the same in frames 1, 4, 5, 6: 27 near, 16 mid.
  - The anchor is gold in every frame.
- Mid 1, 4, 5, 6: no `#2a1a10` outside the eye box is 4-adjacent to a `#f2e4c0` sclera px.
- View `p4_after_0.5x.png` and the scene composite: the near body reads as felt, not speckle, and the wand bottom is not a dark blob.
