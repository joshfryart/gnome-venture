# Pass 3 TEXTURE: side run 80x64 (art director)

Reviewed: `out80/_view/review/p3/` (grey_4x, half_x6, f01/f05/f10_10x, coats_3x) against `house_idleA_6x.png`.

**Now:** 12-13 colours. Flat fields: the largest 4-connected base region is 154-179 px (barrel), and the head light region is 161 px every frame. Isolated felt px at 0.5x per frame: 17,22,17,21,21,20,16,29,18,19,20,17. There are 1 px gold singletons at F3 (13,20), F5 (15,20) and F6 (14,23). These come from the tail-tip `c:seam`, which edgeStitch's cleanup does not cover.

**Texture approach:** add no new hex and no free-floating dots. Use **serration**: 2 px wide teeth that push one tone across an existing terminator. A tooth always touches its own tone, so at 0.5x it merges and never makes salt-and-pepper. Teeth phases are anchored to BX, H or the tail root, so they ride with their part and do not crawl.

**Python mirror:** none. Tones only change, so classify, pattern counts and the 8% rule are unaffected.

## Changes (priority order)

`LIGHT/BASE/SHADE` = `GREY.light/base/shade`. `H`, `S`, `tp` are the Lua tables in `frame()`: `[1]` is x, `[2]` is y. Lua `%` is a floored modulo, so negative x is fine.

1. **New helper `serrate(c, part, edge, into, dx, dy, keep)`** in `cf_run80.lua`, after `despeckle`.
   - Read from a copy of `c.pix`.
   - For each pixel q with `c.own[q]==part` and colour `into`: let `b = (x-dx, y-dy)`. If b is owned by `part` with colour `edge`, then `d = keep(x,y)` (0, 1 or 2).
   - `d>=1`: recolour q to `edge`.
   - `d==2` and `(x+dx,y+dy)` is the same part with colour `into` (in the copy): recolour that pixel to `edge` too.

2. **Back rim fur.** Light teeth drop into the base. Call this after `despeckle(c,p)`, restricted to `x` in `H[1]+5 .. S[1]-4`:
   `serrate(c, p.body, LIGHT, BASE, 0, 1, fn)`, where `m=(x-BX)%6` and fn is `m==3 -> 1`, `m==4 -> 2`, else 0.
   Tile per 6 cols (row 0 = last rim row):
   ```
   r0  LLLLLL
   r1  ...LL.
   r2  ....L.
   ```

3. **Belly fringe.** Shade teeth rise into the base on the belly-band top. Use the same x range. Call `serrate(c, p.body, SHADE, BASE, 0, -1, fn)`, where `m=(x-BX)%6` and fn is `m==0 -> 2`, `m==1 -> 1`, else 0:
   ```
   r-2 s.....
   r-1 ss....
   r0  ssssss   (band top)
   ```

4. **Haunch fur flow.** Crescent teeth move left into the base. Call `serrate(c, p.haunch, SHADE, BASE, -1, 0, fn)`, where `m=(y-H[2])%4` and fn is `m==0 or m==1 -> 1`, else 0. This makes 2-tall teeth every 4 rows.

5. **Chest ruff.** Same as item 4, but use `p.chest` with `m=(y-S[2])%3`, fn `m<=1 -> 1`. This makes 2-on 1-off teeth on the chest crescent under the jaw.

6. **Tail clumps.** Light teeth drop into the base. Call `serrate(c, p.tail, LIGHT, BASE, 0, 1, fn)`, where `m=(x-tp[1][1])%5` and fn is `m==0 or m==1 -> 1`. Run it **before** `tailTip`, so the light tip stays solid.

7. **Head terminator teeth.** In the jaw-tint `head:each`:
   - Old: `2*(y-hy)+(x-hx) >= 8`.
   - New: `2*(y-hy)+(x-hx) + (((x-hx)%4<=1) and 2 or 0) >= 8`.
   This adds 2-wide, 1-row base teeth every 4 cols along the diagonal. Muzzle rule `x<=hx+8` is unchanged.

8. **Cheek fluff.** After item 7, for `x` in `{hx-10, hx-9, hx-7, hx-6}`:
   - Let `yb` = the lowest head-owned `LIGHT` pixel in that column. Set `(x,yb)` to `BASE`.
   - For `x` in `{hx-9, hx-6}` only, also set `(x,yb-1)` to `BASE` if it is light.
   Result (bottom of cheek, cols hx-10..hx-5):
   ```
   yb-1  .b..b.
   yb    bb.bb.
   ```

9. **Flank clumps** (the only interior marks). Here `sp(x)` is `spineY` from the belly block; hoist it out of the `do` block.
   - For `(u,v)` in `{(-1,1),(5,1),(2,3)}`: set `(BX+u, round(sp)+v)` and `(BX+u+1, round(sp)+v)` to `SHADE`, only if both are body-owned `BASE`.
   - Each clump is a horizontal 2 px dash `ss`. It is hidden by the haunch or chest when L is short (that is correct occlusion).

10. **Gold singleton on the tail seam.**
    - Change `tailTip` to return the painted keys, using the same `prev`/`alone` restore as `edgeStitch`. A seam pixel with no gold 8-neighbour reverts to its prior colour.
    - Expected: F3/F5/F6 lose (13,20)/(15,20)/(14,23).

11. **Order in `frame()`:** belly block → `despeckle` → items 2, 3, 4, 5, 9 → paws → edgeStitch ×2 → face.
    - Item 6 goes before `tailTip`.
    - Items 7-8 go in the head tint, which runs before `tailTip`.
    - Serration must run after `despeckle`: despeckle would erase the 1-row tooth tips.

12. **Review views.** In `make_view80.py`, add:
    - `review/p3_grey_4x.png`: 6×2 grid, 4x, on cream.
    - `review/p3_half_x6.png`: 40×32 nearest, then x6.
    - `review/p3_f01_10x.png`, `p3_f05_10x.png`, `p3_f10_10x.png`.
    - `review/p3_tex_diff.png`: per frame, pixels that differ from a saved pre-p3 copy (`out80/_view/review/p2_ref/`, copy the current PNGs there first), painted red on grey at 4x.

## Not to change

- Paws: the toe beans already carry their texture.
- Far legs (dk ramp): too small for texture.
- Ears: leave as they are.
- Stitch rhythm is already 2-on 1-off.

## Acceptance

- Lua: ALL CHECKS PASS. Colours per frame unchanged (12-13, no new hex). Semi 0. Margin ≥3.
- Flat fields:
  - Largest 4-connected `#8a859b` region ≤140 px in every frame (now up to 179).
  - Largest `#cdc9d3` head region ≤150 px (now 161).
- Teeth present:
  - Body rim teeth ≥2 per frame (F5 ≥1).
  - Belly teeth ≥2 per frame.
  - Head terminator teeth ≥2.
  - Cheek fluff 6 px changed in every frame.
- No orphans from texture: every pixel changed by items 2-9 has a same-colour 4-neighbour.
- Stability: for any tooth fully visible in neighbouring frames, its offset from BX (body), H (haunch) or the tail root is identical between those frames.
- 0.5x: isolated felt px per frame ≤ baseline+2. Baseline is 17,22,17,21,21,20,16,29,18,19,20,17.
- Gold: every 8-connected gold group is 2-3 px in all 12 frames (0 singletons).
- `python3 -I run80_coats.py`, then `python3 -I check_patterns.py`: `ok`. All 5 patterns max jump ≤8%. Tabby/spotted body features present in F4-F6.
- coats_3x: on the white and cream coats, teeth are visible but are not mistaken for stripes. No tooth longer than 2 px horizontally.
