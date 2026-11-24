# Pass 2 (polish): zoomies sprint, notes for the coder

Review views are in `out_zoom/_view/review/`: `p2_grey_a_4x.png`, `p2_grey_b_4x.png`, `p2_half_x4.png` and `p2_z1/z3/z5_8x.png` (8x, red grid every 5 px).

What I found:
- Colours are 13 per frame and semi-transparent pixels are 0, both fine.
- The Lua self-check FAILs on joint steps (16).
- Orphan pixels: 16-19 per frame. About 7 of these are intended face marks.
- Z1 has an enclosed hole at (12,38), a tail notch.
- The far ear is a 4 px stub, so its outline makes a spike at (hx-5..hx-3, hy-12..hy-13).
- The tail's 3-wide segment is 1 rim row plus 2 shade rows, and its outline is ol1 brown, so at 0.5x the tail reads brown.
- In Z1 and Z5 the space under the belly is solid `#2a1a10`.
- The body gloss sits on the haunch contour.

Keep the `POSE`/`LEGS` line format: zoom_coats.py and make_view_zoom.py parse it with a regex.

## Changes (priority order)

1. **Joint-step FAIL and the Z5 blob.** In cf_zoom.lua `LEGS`:
```
Z5 nf={49,49}->{51,48}  ff={46,48}->{48,47}  nh={{28,50},{27,53}}->{{26,50},{25,53}}  fh={{31,50},{31,53}}->{{29,50},{29,53}}
Z6 nf={65,53}->{63,53}  ff={61,53}->{60,53}   (nh, fh unchanged)
```
   - Steps after the change: Z4>Z5 10, Z5>Z2 7, Z5>Z6 12.
   - The gap between the hind and fore paws in Z5 grows from about 3 px to 10 px, which removes the black-bordered pin holes at (36-37, 45-47).

2. **Z1 crouch daylight.** In `POSE`, Z1 `BY=43, ... hy=39` becomes `BY=42, ... hy=38`.
   - Belly felt bottom moves 49 -> 48, so at least 2 rows of transparent pixels open at x 33-42, rows 53-55.
   - The head bottom moves up 1 px, clear of the fore paws.

3. **Far ear: fix the spike, make it read.** In `frame()`, `earF`:
   - Old: `{hx,hy-8},{hx-4,hy-9},{hx-11,hy-11}`
   - New: `{hx-1,hy-8},{hx-12,hy-11},{hx-8,hy-7}` (keep `:grow(1)`)
   - The top edge is now one straight line, slope 3/11. There is no middle peak, and a 1-2 row `dk` strip shows above earN. Target head-top silhouette at Z3 (cols hx-15..hx-1, rows hy-13..hy-7; `o` = outline, `d` = far felt, `#` = near felt):
```
...ooooooo.....
.oooddddddoo...
oodddddddddooo.
o###########o..
.o#########oo..
..oooooooooo###
```
   - Add a check: far-ear owned pixels >= 8. Also, the ear-top silhouette row (topmost non-transparent y per column, x hx-14..hx) must never go up again after it starts going down from left to right (no local peak).

4. **Tail felt.** In both cf_zoom.lua `frame()` and zoom_coats.py:
   - Tail widths: `c:line({tp[1],tp[2],tp[3]},5)` -> `6`, and `c:line({tp[3],tp[4],tp[5]},3)` -> `4`.
   - In `c:build`, the tail `cres = 2` -> `1`.
   - The thin segment then shades rim, base, shade instead of rim, shade, shade. This also removes the shade cap at the left end (Z3 x 7-10, y 26-28).
   - The tail mask goes from about 61 px (Z3) to about 80 px.

5. **Tail notch and hole.**
   - `POSE` Z1 `tdy={1,1,2}` -> `{1,1,1}`.
   - In `frame()`, after the tail mask is built: `tail = tail:closed(1)`. This fills the 1 px V notches under P4 (Z1 (12-13,37), Z5 (14,32)).
   - Add a check: enclosed transparent holes = 0 in every frame.

6. **Body gloss moves off the haunch contour.** In `c:build`, body `gloss = { rear + 8, BY - 4 }` -> `{ rear + 14, BY - 4 }`. The haunch reaches x rear+11, so the gloss comma then sits on clean base felt.

7. **Felt despeckle.** Add `despeckle(c)` in cf_zoom.lua, called after the face paint and before `c:save`:
   - Apply it to pixels owned by body, chest, haunch, head and tail only.
   - Recolour a felt pixel (`#57516f`, `#8a859b`, `#cdc9d3`) when none of its 4 neighbours has its colour and at least 3 of its 4 neighbours share one felt colour. Recolour it to that shared colour.
   - Skip gold, `#f1ebe3`, pink, eye pixels and the whisker dots (hx+9,hy+4), (hx+10,hy+6), (hx+8,hy+6).
   - This targets the cheek speckle (hx+10,hy-5) and (hx+11,hy-4), and the chin-tint edge (hx-12,hy+3).

8. **1-px stitch dashes.** In `edgeStitch`, collect each dash of `on` pixels and drop the dash when fewer than 2 of its pixels pass the tests. Current singles: Z3 (27,42) and (32,43), Z5 (43,29) and (26,30).

9. **zoom_coats.py folded far ear** to match item 3:
   - `FAR = {(0,0): grid(-1, {...})}` -> `FAR = {(0,0): grid(-12, {-11: '.DDDDDD....', -10: 'DSSSSSSSSSD', -9: '.SSSSSSSS..'})}`
   - `NEAR` is unchanged.

10. **Pattern jump.** After items 1-5, re-run zoom_coats.py.
    - If spotted Z5>Z6 is still above 8%, leave it as a documented exception (Z6 is a one-shot skid, not in the loop).
    - The loop pairs Z2>Z3>Z4>Z5>Z2 must all be <= 8% for calico, tuxedo, tabby and spotted.

11. **make_view_zoom.py.** Add `_view/strip_half_x4.png`: the 0.5x strip upscaled x4 with NEAREST, on cream, so the reviewer reads 0.5x at a visible size.

## Acceptance checks
- `cf_zoom.lua` prints ALL CHECKS PASS, including joint steps max <= 12 (Z5>Z6 = 12), the new hole check (0) and the far-ear check.
- Per frame: colours <= 15, semi 0, margin >= 3, felt inside x 6..72 and y 6..56.
- Orphan pixels (a pixel whose colour matches none of its 8 neighbours) <= 9 per frame. The 7 intended face marks are allowed.
- Z1: transparent pixels exist at rows 53-55 for some x in 33..42.
- Z5: a transparent run of at least 3 px on row 50 between x 33 and 46. No `#000000` pixel inside x 34..44, y 44..49.
- Tail mask >= 70 px (Z1-Z5) and >= 55 px (Z6).
- At 0.5x the tail shows at least 2 grey (non-umber) pixels per column for the 4 columns behind the rump.
- Ear-top silhouette has no local peak. There is no umber pixel above row hy-13 in any frame.
- Body gloss pixels are all >= 2 px right of the haunch contour.
- zoom_coats.py: PROBLEM list empty. Loop jumps <= 8% (calico, tuxedo, tabby, spotted).
- Previews rebuilt: `strip_4x`, `strip_half_x4`, `zoom.gif`, `zoom_fx.gif`, `compare_run_zoom.png`.
