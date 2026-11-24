# Pass 3 TEXTURE: zoomies sprint (cf_zoom.lua, zoom_coats.py, make_view_zoom.py)

Review images are in `out_zoom/_view/review/p3/`:
- `grey_4x.png`, `grey_half_x4.png` and `z1..z6_8x.png` (red grid every 5 px) show the current frames.
- `house_4x.png` shows the house idleA, jump and stretch.
- `sim_before/after_4x.png`, `sim_after_half_x4.png` and `sim_z3_ba_8x.png` / `sim_z5_ba_8x.png` simulate items 1-4 on the current PNGs.

**Verdict.** The house art and this sprint are flat felt plus gold seams. The largest flat areas are:
- the mid-body base `#8a859b`, about 14x8 px
- the haunch, about 12x10 px
- the head light `#cdc9d3`, about 15x9 px
- the straight underside shade band (Z3 rows 42-43)

In the simulation, swept-back 3 px ticks, toothed terminators and tail-rim notches read as fur at 4x and 8x and disappear at 0.5x. Orphan counts stay at 9-12 and no new colours are added, so the count stays at 13.

Tick shape `TICK` (anchor = top-left; swept back for a rightward dash, root at front-top):
```
.ss
s..
```
Cells: `(ax+1,ay) (ax+2,ay) (ax,ay+1)`.

## Changes (priority order)

1. **New helper `furTex(c, p, list, from, to, ownset)`** in cf_zoom.lua, placed after `despeckle`.
   - For each anchor `{ax,ay}` in `list`, it paints `to` on the 3 TICK cells only when all of these hold:
     - every cell is `from` and `c.own[k]` is in `ownset`
     - no cell is in `c.gl.s`
     - every 8-neighbour of every cell (except the tick's own cells) is `from`, or `to` for the body ticks
   - Otherwise it skips the anchor. It returns the count painted.
   - Call it in `frame()` after `despeckle(...)` and before `info[f]=`.

2. **Body and haunch ticks** (in `GREY.shade` on `GREY.base`, ownset = {body, chest, haunch}). The anchors are relative to `(rear, BY)`. They were verified against all 6 frames: valid in at least 5, auto-skipped otherwise.
```
{rear+2,BY-4}  {rear+5,BY+1}   -- haunch
{rear+14,BY-2} {rear+20,BY+0}  -- mid body
```
   - Expect 3-4 ticks per frame (sim: Z1 4, Z2 4, Z3 4, Z4 3, Z5 3, Z6 4).
   - Anchoring to rear/BY moves the ticks with the body, so they do not boil.

3. **Head ticks** (in `GREY.base` on `GREY.light`, ownset = {head}). The anchors are relative to `(hx, hy)`:
```
{hx-9,hy-2}  {hx-2,hy-4}
```
   - Drop the sim's third tick `{hx-5,hy+1}`. At 0.5x it leaves a lone grey dot on the cheek in Z3/Z5.
   - Expect 2 per frame, never touching the eye ring, the gloss `{hx-5,hy-5}` or the seam on row hy+4.

4. **Terminator teeth (underside band).**
   - Candidates: base pixels owned by body, chest or haunch, with `y > BY`, the pixel below being `GREY.shade` (same ownset), and all 8 neighbours being felt.
   - Sort the candidates by `(x, y)`. Paint `GREY.shade` where `(i-1)%4 < 2` (Lua, 1-based). This gives 2-on 2-off teeth.
   - Sim counts per frame: Z1 6, Z2 8, Z3 10, Z4 10, Z5 7, Z6 8. The straight Z3 band on rows 42-43 becomes:
```
before  bbbbbbbbbbbb      after  ssbbssbbssbb
        ssssssssssss             ssssssssssss
```

5. **Tail rim fuzz notches.** Let `tx0` = the tail-mask bbox x0. For each column with `(x-tx0)%4 == 1`, take the topmost tail-owned pixel at `(x,y)` where all of these hold:
   - its colour is `GREY.light`
   - `(x,y-1)` is not felt
   - `(x,y+1)` is `GREY.base`
   - `(x±1,y)` are `GREY.light`

   Recolour that pixel to `GREY.base`.
   - Expect 1-2 per frame.
   - The `y+1 == base` rule means a notch can never become an orphan.
```
before  KKKKKKKKK     after  KKKKKKKKK
        lllllllll            lblllblll
        bbbbbbbbb            bbbbbbbbb
```

6. **Order and ownership.** Run items 2-5 after `despeckle`, so despeckle cannot eat the teeth. Despeckle's pass 2 would not touch them anyway, because each has a same-colour neighbour. Print `texture px Zn = N` per frame. The expected range is 20-35 (sim 26-33, less 3 after item 3's cut).

7. **Stitches are already 2-on 1-off** (`edgeStitch` on=2 off=1, gold `#f5cf6a`/`#e8a317`). No change is needed. Add a check that no tick or tooth pixel touches gold, `#f1ebe3` or an umber pixel (4-neighbour).

8. **The Z5 `#000000` check is still unreachable.** Pass 2 left this. Replace `chk(blk == 0, "Z5 no #000000 ...")` with `chk(best >= 4, "Z5 notch run row 50 >= 4")`. The notch is already open at the bottom, run 4, holes 0, and the black there is the correct sticker border. Reason: there is a single standing FAIL and the art is right.

9. **zoom_coats.py: no code change.** Re-run it after the Lua.
   - The ticks are grey-ramp pixels, so `catfish_recolor` maps them per coat. On black/brown coats they become a deep step on the shade step; on white, `#bab0c0` on `#e6dfd2`.
   - Pattern overlays are computed from geometry, so the jumps must stay identical: calico 5.7, tuxedo 6.9, tabby 5.8. The loop pairs stay at 8% or less, and spotted Z5>Z6 stays the documented exception.

10. **make_view_zoom.py:** add `_view/z3_8x.png` and `_view/z5_8x.png`. Each is the frame on cream, 640x512 NEAREST, with a 5 px grid line at alpha 90. Reason: tick rhythm can only be judged at 8x.

## Not changing
Poses, LEGS, masks, layers, gloss, seams, colour set (13), tail geometry and coat overlays stay as they are. Paws, pink, eyes, muzzle and ears get no texture, because they are too small and would become salt-and-pepper at 0.5x.

## Acceptance checks
- cf_zoom.lua prints ALL CHECKS PASS. Colours max 13, semi 0, holes 0, joint steps max 12.
- Orphans (non-face) are at most 9 per frame. Orphans including face marks are at most 12 (sim 9-12).
- Per frame, body+haunch ticks are 3-4, head ticks are 2, teeth are 6-10, tail notches are 1-2, and texture px are 20-35.
- Every tick is the exact 3-cell TICK shape. No textured pixel 4-touches gold, gloss, umber or `#000000`.
- Z3 at 8x: the underside band shows at least 2 teeth pairs with 2 px gaps, and the mid-body shows 2 ticks with 3 or more px between them.
- `strip_half_x4`: the silhouettes and seams read the same as in pass 2. No head pixel at 0.5x is `#8a859b` with 4 neighbours of `#cdc9d3` (no head speckle).
- GIF Z2>Z3>Z4>Z5: each tick moves by the same dx,dy as `rear`/`BY` (head ticks by hx/hy). There is no boiling.
- zoom_coats.py: the PROBLEM list is empty, and the jump values match pass 2 within 0.2%.
