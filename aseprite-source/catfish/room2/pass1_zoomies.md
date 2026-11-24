# Pass 1 (perspective): zoomies sprint, notes for the coder

Review views: `out_zoom/_view/review/grey_4x.png`, `grey_half_x4.png`, `run80_3x.png`.
Found: tail 13-27 px, hidden inside the haunch (Z1-Z5). Head floats 10 px above the back, so it reads as the run. Pinned ears form a lump on the skull. Z1/Z5 paws all under the belly. `zoom_fx.gif` never built (wrong fx filenames).

Keep the line format of `POSE`/`LEGS` exactly as it is: `zoom_coats.parse_lua` reads them with a regex.

## Changes (priority order)

1. **cf_zoom.lua `BX` 33 -> 35; zoom_coats.py line 25 `BX = 33` -> `35`.** This gives the tail room behind the rump without moving the nose (the front edges stay at 51-53).

2. **cf_zoom.lua `POSE`** (new BY / L / arch / tilt / hy / tdy):
```
Z1 { BY=43, L=34, arch=-2, tilt=3,  hy=39, tdy={1,1,2} }
Z2 { BY=40, L=34, arch=0,  tilt=3,  hy=35, tdy={0,-1,-1} }
Z3 { BY=38, L=36, arch=0,  tilt=3,  hy=33, tdy={1,0,-1} }
Z4 { BY=40, L=34, arch=0,  tilt=3,  hy=35, tdy={1,1,0} }
Z5 { BY=37, L=32, arch=-4, tilt=0,  hy=33, tdy={0,1,1} }
Z6 { BY=41, L=34, arch=-1, tilt=-4, hy=34, tdy=nil, up=true }
```
Reasons:
- tilt +3 gives ts=1, so the rump sits 2 px up and the shoulders 2 px down: a constant forward speed lean.
- hy = BY-5 (it was BY-8/-9) puts the head low and forward, which is the main silhouette difference from the run.
- Z5 BY 39 -> 37 and arch -4 open daylight under the gathered legs.
- L now spans 32..36 (it was 30..40). That also cuts the pattern jumps.
- The tdy values make a wave that travels down the tail, P2 -> P4, over Z2 to Z5 (follow-through).

3. **cf_zoom.lua `LEGS`.** Hind x moves with the new rear. Z1 and Z5 fore paws move forward to un-blob them.
```
Z1 nf={57,53} ff={54,53} nh={{20,50},{23,53}} fh={{22,49},{26,53}}
Z2 nf={58,48} ff={54,49} nh={{22,49},{20,53}} fh={{25,49},{24,53}}
Z3 nf={67,46} ff={60,47} nh={{19,46},{15,47}} fh={{21,45},{22,46}}
Z4 nf={61,53} ff={57,53} nh={{25,46},{22,48}} fh={{27,45},{25,47}}
Z5 nf={49,49} ff={46,48} nh={{28,50},{27,53}} fh={{31,50},{31,53}}
Z6 nf={65,53} ff={61,53} nh={{26,50},{26,53}} fh={{29,50},{30,53}}
```
Z4 -> Z5 nf now steps 12 (it was 15), so it passes the joint-step check.

4. **Tail root and curve**, in cf_zoom.lua `frame()` and in zoom_coats.py `geometry()` (`R0`):
   - `R = {rear+6, BY-5}` -> `R = {rear+3, BY-6-2*ts}`. The root now follows the leaned rump.
   - `TAIL_OFF` -> `{0,0},{-3,-3},{-6,-4},{-9,-4},{-12,-3}` in both files. It rises 3-4 px above the rump, then droops back at the tip: a gentle S.

   At Z3 the tail runs x 20 -> 8, y 30 -> 27, about 6 px clear of the haunch and 3 px above the back line.
   - `TAIL_UP` (Z6) stays the same, but it now hangs from the new R.
   - The tail stays width 5 at P1-P3 and 3 at P3-P5. Keep the tip tint.

5. **Ears flattened and swept back** (cf_zoom.lua `frame()`; both keep `:grow(1)`):
   - earN: `(hx-2,hy-9)(hx-7,hy-7)(hx-13,hy-10)` -> `(hx-3,hy-8)(hx-7,hy-6)(hx-13,hy-8)`
   - earF: `(hx+1,hy-9)(hx-3,hy-9)(hx-9,hy-12)` -> `(hx,hy-8)(hx-4,hy-9)(hx-11,hy-11)`
   - In `c:build`, earF ramp `g` -> `dk` so the far ear sits back in depth.

   Target head-top silhouette, Z3 (hx=57, hy=33; `#` = felt, `o` = outline, cols hx-15..hx-1, rows hy-12..hy-6):
```
...ooo.........
..oddoo........
.oddddoooooo...
o#####dddddoo..
.o#########o###
..oo#######o###
....oooo#######
```
   The ear tips must point back past the skull's rear edge, not up.

6. **Far-leg depth.** The far paws `pawFF` and `pawHF` stay `pawDk`. Change the far leg line widths from `5/3` to `4/3` for both far legs (`legFF` first segment, `legHF` first segment). They then read as thinner and further away, 1 px narrower than the near legs.

7. **Self-check updates** (cf_zoom.lua SELF-CHECK):
   - `I.tp[5][1] < 9` -> `< 8`
   - `I.R[2] - I.tp[i][2] > 3` -> `> 6`
   - Add `FAIL` if `ey0 < hy-12` or the ear bbox x1 is greater than `hx+1`.
   - Add tail-mask pixel count `>= 34` per frame (Z6 `>= 45`).

8. **zoom_coats.py calico/tuxedo jump.**
   - In `classify`, change `t=(x-(g['rear']+12))/max(1,g['L']-22)` to `t=(x-(g['rear']+12))/12.0`.
   - In `calico_body` and `bx`, change `n = max(1, d['L'] - 22)` to `n = 12`.

   The patches then keep a fixed pixel size and only move with the rump. If tuxedo is still above 8%, change `white_mask` body `d['rk'] >= 0.6` to `>= 0.62`.

9. **zoom_coats.py folded ears** `NEAR`/`FAR` grids. Move every row 1 px down (`-11..-8` -> `-10..-7`) and `NEAR` lx0 `-12` -> `-13`, to match item 5.

10. **make_view_zoom.py fx composite** (the GIF was silently skipped):
    - Filenames: `cf-fx-dust-%d.png` -> `cf-dust-%d.png`, and `cf-fx-streak-%d.png` -> `cf-streak-%d.png` (also in the `exists` test).
    - Dust pivot: paste at `(x-19, 55-14)`, so the pivot (19,14) lands on the paw's bottom felt row 55. It was `(x-19+4, y-14)`.
    - `planted` becomes:
      - `{1:[(57,53),(54,53),(23,53),(26,53)], 2:[(20,53),(24,53)], 4:[(61,53),(57,53)], 5:[(27,53),(31,53)], 6:[(65,53),(61,53)]}`
      - Better still, parse it from the Lua as zoom_coats does.
    - Streaks: x `0`/`4` -> `rear-30` clamped to ≥0. Body band y `BY-6` and `BY+2`.

11. **make_view_zoom.py**: add `_view/compare_run_zoom.png` (run80 f06 and zoom Z3 at 4x, red ground line at y 55).

## Acceptance checks
- `cf_zoom.lua` prints ALL CHECKS PASS: joint steps ≤ 12, felt x 6..72, margin ≥ 3, semi 0, colours ≤ 15.
- Tail mask, every frame: ≥ 34 px, with ≥ 16 px left of the haunch bbox. Its top row is 2-4 px above the body's top row at the same x (Z1-Z5).
- Head top (hy-8.5) is ≤ 9 px above the body top row at x = front-7. In the run80 frames it is ≥ 12.
- Ear felt never rises above y hy-12. The ear bbox x1 is ≤ hx+1.
- 0.5x Z3: four separate paw blobs, a tail stroke visible behind the rump, ≥ 2 px daylight under the belly.
- 0.5x Z1/Z5: the fore legs show as a diagonal stroke and do not merge with the hind paws.
- `zoom_coats.py`: calico and tuxedo neighbour jumps ≤ 8%, PROBLEM list empty.
- `zoom_fx.gif` exists. The dust sits behind the paws, and its bottom row is at y 55.
