# Pass 3 (texture): lure, wand cast, shadows, dust, streaks

Review images are in `out_props/_view/review/`:
- `p3_{near,mid,far,wand,fx,sh}_{8,4,1,0.5}x.png` show the current files.
- `p3_sim_lure_*`, `p3_sim_wand_*` show items 1-5, simulated in PIL on the current PNGs. They read at 1x and 0.5x with no speckle.

Current flaws:
- Near body: a flat `#dd3a2a` field of about 100 px.
- Ear: flat tan with no form.
- Wand: the grip, shaft and sleeve are single-tone slabs. cf-rod has wrap bands on its grip (rows 40/44) and banding on its sleeve.

All items use existing ramp hexes, except one new ear step. All edits go in `cf_props_room2.lua` unless a line says otherwise. Here `c:get(x,y)` returns the hex string; if it does not, compare through `c:image()`.

## Changes, highest priority first

1. **Near body felt nap.** In `buildLure`, right after `c:build{...}` and before the `if S.gloss` block, for near only (`S.gloss ~= nil`):
   ```lua
   local cx, cy = rnd(bcx + tx), rnd(bcy + ty)
   local nap = {}
   for y = cy - 4, cy + 2, 2 do for x = 0, S.W - 1 do
     local dx, dy = x - cx, y - cy
     if (dx + (dy // 2) * 3) % 6 < 2 and c:get(x,y) == RED.base
        and c:get(x+1,y) == RED.base and c:get(x-1,y) == RED.base
        and c:get(x,y+1) == RED.base and c:get(x,y-1) == RED.base then nap[#nap+1] = {x,y} end
   end end
   for _, q in ipairs(nap) do c:px(q[1], q[2], RED.shade) end
   ```
   - Rows are cy-4, cy-2, cy and cy+2 (15/17/19/21 when cy = 19), with 2-px ticks every 6 px, staggered by 3 per row.
   - Ticks are anchored to the body centre, so they move with the hop instead of swimming.
   - Collect first and paint after, so a tick does not fail its neighbour's test.
   - Expected ticks per frame: 12, 4, 11, 12, 12, 14 (±2).
   - Do not add nap to mid: the simulation gave only 1-3 px, which is speckle.

2. **Ear fold crescent (near and mid).** Add `EARR.shade = "#c98a68"` as a new hue-shifted step, but leave `EARR` in the build call unchanged. At the end of `buildLure`, after the eye:
   ```lua
   p.ear.m:each(function(x,y)
     local r, d = c:get(x+1,y), c:get(x,y+1)
     if c:get(x,y) == "#e9b98a" and ((r ~= "#e9b98a" and r ~= PINK) or (d ~= "#e9b98a" and d ~= PINK)) then c:px(x,y,"#c98a68") end
   end)
   ```
   - This gives a lower-right crescent of 8-11 px on near and 5-7 px on mid.
   - The colour count goes from 15 to 16 and must not exceed 16.

3. **Near feather barbs.** In `buildLure`, after the quill loop, near only:
   ```lua
   p.fth.m:each(function(x,y) if y % 3 == 0 and c:get(x,y) == FEATH.rim and c:get(x,y-1) == FEATH.rim then c:px(x,y,FEATH.base) end end)
   ```
   This makes a 2-on 1-off notch rhythm on the lit vane edge, 1-4 px per frame.

4. **Wand grip cord wrap.** In `wandFrame`, after the bead loop, add this helper. Use it for items 4-6, and collect pixels before painting them.
   ```lua
   local function axis(x,y) return ((x-tx)*ux + (y-ty)*uy) / f, (x-tx)*nx + (y-ty)*ny end
   ```
   Paint each grip pixel where `c:get == RODRED.base` and `math.floor(t) % 3 == 0` with `RODRED.shade` (`#ac1c27`).
   - This gives 2-on 1-off wrap bands, matching cf-rod rows 40-46.
   - Expected count per frame 1..6: 17/6/8/16/9/19 px.
   - The grip gloss px (`#ff9158`) stays because it is not base.

5. **Wand shaft wood grain.** For each pixel where `c:get == RODWOOD.base`:
   - Paint `RODWOOD.shade` (`#8a4f2a`) if `floor(t) % 9` is 0, 1 or 2 and `rnd(s) == 0`.
   - Also paint it if `floor(t) % 9` is 5 or 6 and `rnd(s) == 1`.

   This gives staggered 3-px and 2-px grain dashes. Expected count per frame: 15/9/13/11/15/11.

6. **Wand sleeve ribs.** Paint each pixel where `c:get == RODWATER.base` and `math.floor(t)` is 6 or 9 with `RODWATER.shade` (`#305e86`).
   - This gives 2 rubber rings, 6-11 px per frame.
   - The glint at t = 5 stays.
   - None of items 4-6 adds a colour.

7. **Streak-1 tail breakup.** In `fx()`, after `dust[4] = DUST4`:
   ```lua
   streak[1][4] = streak[1][4]:sub(1,4) .. "hh.h" .. streak[1][4]:sub(9)     -- y=3, x4..7
   streak[1][5] = streak[1][5]:sub(1,10) .. "c.cc.c" .. streak[1][5]:sub(17) -- y=4, x10..15
   ```
   This feathers the tail 2-on 1-off. The head stays solid. Streak-2/3 are unchanged.

8. **Leave unchanged:**
   - The far lure: there is no room at 12 px; a texture px would be salt.
   - Shadows: they stay flat `#2a1a10`.
   - Dust-1..4: the puffs are already 3-tone lobes.
   - `cf-wand-cast.json`.

9. **`make_view_props.py`.** Add `_view/review/p3_after_{8,1,0.5}x.png`: near and mid 1-6, wand 1-6 and streak-1 on `(120,140,110)`.

## Acceptance checks
- Lua prints `ALL OK`. Alpha is 0/255 only, and there is no `#ffffff`.
- Colour counts:
  - Lures: 16 or fewer each.
  - Wand: 21 or fewer. The colour set is unchanged and is a subset of cf-rod.
  - Dust/streak: 4 or fewer.
- Near 1-6:
  - `#b8452f` px that are not 4-adjacent to the outline: at least 4 in frame 2 and at least 10 in each of frames 1 and 3-6.
  - No two nap ticks are 4-adjacent across rows.
  - No nap px touches the eye box, the gloss or the seam.
- Near and mid: at least 4 `#c98a68` px, all with x ≥ ear centre x or y ≥ ear centre y.
- Near feather: at least 1 `#3f8fb0` px with `#8fcbd8` directly above it, in each frame.
- Wand 1-6:
  - Grip: at least 6 `#ac1c27` px in non-outline grip rows. In frame 1, rows y = 1, 4, 7 and 10 are banded and the rows in between are not (±1 row).
  - Shaft: 9-16 `#8a4f2a` px inside the shaft interior, besides the right shade column.
  - Sleeve: 2 rings, each at least 2 px.
- Streak-1: row 3 x6 and row 4 x11/x14 are transparent. All other rows are byte-identical.
- These files stay byte-identical: lure-far-1..6, shadow-1..4, dust-1..4, streak-2/3, the JSON.
- View `p3_after_0.5x.png` (not just 4x): the nap must read as a soft mottle, not dots. If it reads as dots, change the period from 6 to 8.
