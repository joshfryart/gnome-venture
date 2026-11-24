# Pass 1 PERSPECTIVE: side run 80x64 (art director)

Reviewed: `out80/_view/review/grey_4x_a|b.png` (red line = y55), `f01|f05|f10_8x.png`, `ladder_2x.png` (rungs 1 .875 .75 .625 .5 .42), `house_idleA_6x.png`.
Verdict: the gait reads. The 3/4 depth does not. The far limbs sit 1 px behind the near ones, so at .5/.42 F4-F8 show 2 paws, not 4. Both ears are the same size, the head is flat profile, and the belly gets the same light as the back. Gold stitch on the jaw underside and the lower belly contradicts the upper-left light.

**Mirror rule:** any geometry change in `cf_run80.lua` must be copied into `run80_coats.py` `geometry()`/`classify()`. If you skip this, the pattern overlays drift.

## Changes (priority order)

1. **Far side 1 px higher (depth offset).** `frame()`:
   - `Sf = {S[1]-1, S[2]-1}` -> `{S[1]-1, S[2]-2}`
   - `Hf = {H[1]+1, H[2]-1}` -> `{H[1]+1, H[2]-2}`

   In the same function, change `LEGS` `ff`, `fh[1]` and `fh[2]`: every y -1. New far columns:

   | F | ff | fh hock | fh paw |
   |---|---|---|---|
   | 1 | 52,52 | 13,44 | 15,46 |
   | 2 | 47,52 | 17,44 | 19,46 |
   | 3 | 42,52 | 20,44 | 23,46 |
   | 4 | 40,48 | 23,45 | 26,47 |
   | 5 | **40**,45 | 25,45 | **31,48** |
   | 6 | 43,44 | 25,48 | 28,52 |
   | 7 | 46,44 | 21,48 | 23,52 |
   | 8 | 50,44 | 17,48 | 18,52 |
   | 9 | 54,45 | 15,46 | 12,49 |
   | 10 | 56,45 | 12,45 | 10,48 |
   | 11 | 57,46 | 12,45 | 11,47 |
   | 12 | 54,50 | 12,44 | 13,46 |

   Planted far paws now land at y 52, so their bottom felt row is 54 (near stays at 55). This is the ground plane seen from above.
   F5 (bold) also gets new x values. The far fore paw goes 41 -> 40. The far hind paw goes 28 -> 31, so it peeks in front of the near hind paw and the gathered frame shows 4 paws.
   Python `geometry()`: `Sf=(S[0]-1,S[1]-2)`, `Hf=(H[0]+1,H[1]-2)`.
   Self-check updates:
   - Lines 307/309/333: `{H[1]+1,H[2]-1}` -> `{H[1]+1,H[2]-2}`, `{S[1]-1,S[2]-1}` -> `{S[1]-1,S[2]-2}`.
   - Planted test: treat a far paw at `GROUND-1` as planted and expect `y1 == 54`.
   - Legs >=10 test: change `q[2][2]==GROUND` to `q[2][2]>=GROUND-1`.

2. **Far paws one value step darker.** In `pawDk`, change `gloss/dot/rim` from `t.light` to `t.base`. Far paws are then base+shade and near paws light+base, so the two pairs separate at .42.

3. **Near eye back 2 px; far-eye sliver (head turned 3/4 to camera).**
   - `catEye(c, hx+4, hy-3)` -> `catEye(c, hx+2, hy-3)`. The ring now covers hx+1..hx+7.
   - Add `c:eye(hx+9, hy-3, true)`. That paints a 3x3 halo with a 2x2 ol3 pupil in its lower-right, so it looks forward:
     ```
     x: hx+9 10 11
     hy-3   h  h  h
     hy-2   h  o  o
     hy-1   h  o  o
     ```
   - In `run80_coats.py`:
     - `classify` eye rect `(hx+3,hx+9,hy-4,hy+2)` -> `(hx+1,hx+11,hy-4,hy+2)`
     - eye-overlay loop `range(hx+3,hx+10)` -> `range(hx+1,hx+12)`, so both eyes recolour.

4. **Far ear smaller, set into the crown.**
   - `earF` poly -> `{hx+1,hy-6},{hx+4+exF,hy-12+eyF},{hx+7,hy-5}`, still `grow(1)`. The far ear sits 1 px lower and 1 px nearer the near ear.
   - After the near-ear pink, paint the far ear's inner face edge-on: `c:fill(c:poly({{hx+2,hy-6},{hx+4+exF,hy-10+eyF},{hx+5,hy-6}}):cut(head), GREY.shade)`.
   - Near ear unchanged. It is already at the y 6 felt limit in F11.

5. **Belly shadow.** After `build`, before stitching, tint body-owned pixels from `GREY.base` to `GREY.shade` where `y >= spineY(x)+5` and `H[1]+5 <= x <= S[1]-4`. `spineY` is the same 3-point piecewise line used for `body` (rear+7, BX, front-7), as in Python `spine_y`. This gives 2-3 shade rows under the barrel, so the torso reads as a cylinder.

6. **Stitch only on lit planes.** Pass `ymax` to `edgeStitch`:
   - body: `{lit=LIT, ymax=BY-3}`
   - head: `{lit=LIT, ymax=hy+1}`

   This removes the "collar" dashes under the jaw and the belly dashes near the hip seen in F1/F10, and matches idle A, where the stitch is upper-left only.

7. **Chest forward and down (chest turn).** `chest = c:ellipse(S[1]+1, S[2]-5, 6, 6.5)` -> `c:ellipse(S[1]+2, S[2]-3, 6, 6.5)`. The breast now bulges in front of the fore leg instead of hiding under the jaw. Python `classify` chest test: centre `(S[0]+1,S[1]-5)` -> `(S[0]+2,S[1]-3)`.

8. **Haunch reads nearer than chest.** Haunch ellipse `rx 7.5, ry 7` -> `rx 8, ry 7.5`, same centre. Mirror it in Python `classify` (`/7.5`, `/7.0` -> `/8.0`, `/7.5`).

9. **Ground-shadow review in `make_view80.py`.**
   - Add `_view/review/ladder_shadow.png`. For each rung s in `[1,.875,.75,.625,.5,.42]`, nearest-resize the frame. Under it, draw the shadow that matches the scale (s=1: `cf-shadow-1`, .875/.75: `-2`, .625/.5: `-3`, .42: `-4`), pre-blended #2a1a10 at .35 over bg `#c8bea8`, with its ellipse centre at `(round(35*s), round(54.5*s))`.
   - Also overlay the red y=55 line at 4x.

   Game anchor: the shadow-1 canvas top-left goes at sprite (11,48).

## Acceptance

- `cf_run80.lua` prints ALL CHECKS PASS, with colours <=15 (the far eye and inner ear add no new hex), semi 0, margin >=3, and felt inside x6..72 / y6..56.
- Near planted paws have bottom felt row 55 and far planted paws 54, in every planted frame.
- `python3 -I run80_coats.py`, then `python3 -I check_patterns.py`: `ok`, all 5 patterns max jump <=8%, tabby/spotted body features present in F4-F6.
- 0.5x (`ladder_2x`, rung .5):
  - F5 shows 4 paws: the far fore paw peeks top-left of the near fore paw, and the far hind paw sits right of the near hind paw.
  - F10 shows the far hind paw above-left of the near hind paw, darker.
- 4x:
  - Two eyes are visible, the far one 3 px wide and 1 px from the near ring.
  - The far ear is 1 px lower than the near ear, with a shade inner wedge and no pink.
  - No gold stitch below `BY-3` on the body or `hy+1` on the head.
  - A 2-3 row shade band under the belly in all 12 frames.
- `ladder_shadow.png`: in every planted frame, the planted paws sit inside the shadow ellipse's top half, and the shadow's centre x is within ±2 of the midpoint of the planted paws.
- Eye overlays `cf-eyes-*-runNN` contain both eyes.
