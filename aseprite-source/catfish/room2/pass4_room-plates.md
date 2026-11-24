# Pass 4 (final polish): room A plates

I reviewed the 15:18 renders at 1x, 2x, 4x and 0.5x, and again with the furniture and cats composited (`out_room/_view/review/p4/*`). The perspective, the sunbeam and the night overlay are all sound. What remains is texture-pass clutter, one cross-group tangency and an inverted fringe. All grid coordinates below are in grid px (export = 2x).

## 1. P1: remove clipped wallpaper crosses (top priority)
The scan finds 13 crosses that are partly covered and show 3 or 4 px. They sit above the door at gx34 and gx50, above the frame at gx82, on the window's left at gx146 (cy 10/18/26/34), on the shelf top at gx58/74/90 (cy30), and against the right corner at gx218. Each stub reads as speckle.

**Change:** in `cf_room_a.lua`, insert this immediately before `vignette(P1)` (line 307):
- For `col = 0..24`, set `cx = 26 + 8*col` and `ph = (col%2==0) and 6 or 10`.
- For `cy = ph, 36, 8`, take the 5 points `(cx,cy) (cx±1,cy) (cx,cy±1)`.
- If any of them is not `K.stripe`, set every one of them that is `K.stripe` to `K.haze`.
- Print `wallpaper crosses removed: n`. Expect n between 10 and 14.

## 2. P1: wainscot grain reads as drawer handles
Each panel has two dark dashes (4 px and 3 px), which look like pulls.

**Change:** replace lines 132-136 with a single longer grain line:
```
if c == K.wain then local a0 = 3 + (p*7)%9
  if gy == 44 + p%3 and o >= a0 and o <= a0+6 then c = K.seamD end end
```
That gives 9 dashes of 7x1, all with o ≤ 17.

## 3. P4: chair apron kisses the scratch-post base (cross-group)
The scratch post covers x8..35 down to y183. The apron top is at y172..176, so the post looks as if it stands on the chair. The spec puts the legs at rows ≥196.

**Change:** shift the chair 8 grid rows down. In the block at lines 515-527:
- Front leg: `gy 94..134` → `102..134`.
- Rear leg: `91..127` → `99..130`. Foot `rectG(P4,14,128,19,128)` → row 131.
- Apron: `top = 88 - fl(3*(gx-1)/18)` → `96 - fl(3*(gx-1)/18)`.
- Stretcher: `top = 118 - …` → `124 - fl(2*(gx-6)/9)`.

Grain (lines 540-542):
- Front leg: `100..102 / 113..115 / 124..126` → `108..110 / 121..123 / 131..133`.
- Rear leg: `99..101 / 112..114` → `107..109 / 120..122`.
- Apron: row 90 → 98 (gx3..6); row 88 → 96 (gx13..16).

The rear leg still overlaps the cushion's left edge (cushion x≥28) by 6 px, which is a clear overlap, not a tangency. The stretcher deviates from spec (232..237 → 246..249) because it follows the legs.

## 4. P4: the fringe is upside down and reads as a barcode
The rug lies off-frame below, so its far-edge fringe should point up, away from the binding. The current legB/umber alternation reads as a barcode.

**Change:** replace lines 528-538. For gx 150..243, with `m=(gx-150)%3` and `idx=fl((gx-150)/3)`:
- gy134 is `K.umber` (rug edge). gy133 is `K.legR` (binding).
- Where m<2, the tuft runs from `top` to 132, with `top = (idx%3==1) and 131 or 130`. The colour is `K.legB` where m==0 and `K.umber` where m==1, so the shade falls on the right as on the chair legs.
- Where m==2, rows 130..132 stay transparent.

```
col     012345678
gy130   Bu....Bu.
gy131   Bu.Bu.Bu.
gy132   Bu.Bu.Bu.
gy133   RRRRRRRRR
gy134   uuuuuuuuu
```
P4 stays at 3 colours.

## 5. P2: light grain is speckle, worst at the vignetted front corners
There are about 60 rim dashes (33 of 3 px, 26 of 2 px), 18 of them in rows 120-134. The vignette darkens the boards but leaves `K.rim` alone, so the dashes in the corners jump out.

**Change:** rewrite the loop at lines 385-393.
- Keep `len = 2 + rnd(2)` for the RNG sequence, then force `len = 3`.
- Every dash pixel `(x,y)` must pass all of these:
  - `pget(x,y)`, `pget(x-2,y)` and `pget(x+2,y)` are all `K.fl1`.
  - No pixel of `mineL` lies in its 3x3.
  - `((2x+1-240)/240)^2 + ((2y+1-135)/135)^2 <= 1.15`.
- Mark the placed pixels in `mineL` and print `floor light grain dashes: n`.
- Target n is 30..55. If n < 30, raise the attempts from 200 to 300.

## 6. make_view_room.py: new review outputs and gap checks
Add these after the `_cats` save:
- Save `_cats.resize((240,135),NEAREST)` to `_view/review/scene_half.png`. Save `_cats.resize((1920,1080),NEAREST)` to `_view/review/scene4x.png`.
- **Chair gap:** in `_big` (P4 at -4), find the minimum opaque y for x 8..35. Print it and assert it is ≥ 188.
- **Fringe:** assert that P4 export rows 266..267 (gy133) are all legR across x 296..483 (gx150..243 at -4). Assert that rows 260..261 at gx 153..155 (idx1) are transparent.
- **Crosses:** on P1 at grid res, take the 4-connected components of `#e8cc98` and of `#dcbc88` inside gx21..218 × gy3..38. Print the number of components of size 1..4. It must be 0.
- **Light grain:** in P2, count the `#d9a660` 8-connected components of size ≤3 whose pixels have an 8-neighbour that is `#9a6b3f` or `#8a4f2a`. It must be 0.

## 7. Regenerate and re-run
Run the Lua, then `python3 -I make_view_room.py`. LOOK at:
- `cf-room2-scene-preview-2x.png`: the post foot should be clear of the chair, and the fringe tufts should point up.
- `_view/review/scene_half.png`: no wall speckle, and the floor should read as planks.
- `plain4x.png`: wainscot panels should show one grain line each.

## Acceptance
1. The Lua prints `ROOM A SELF-CHECK: PASS`. semi is 0 and bw is 0 on every plate. The caps hold: P1 ≤ 20 colours (18 expected), P2 6, P4 3, P5 ≤ 8, P5b ≤ 8. The seam, corner, glass, calm-zone and light-mask lines all say ok.
2. `wallpaper crosses removed` is between 10 and 14. The view check finds 0 cross stubs.
3. P1 wain rows gy41..49 hold exactly 9 `seamD` grain runs, each 7 px and each in gy44..46. The groove columns o==0 are unchanged.
4. The chair-gap minimum y is ≥ 188. P4's first opaque row at x8..35 is 188 (gy94 at gx13..18).
5. P4 (gx3, gy108) is legR. The rear foot row is gy131 (y262..263). P4 has no pixels at gy86..93.
6. The fringe matches the grid in #4 for gx150..158. P4 has 0 single-pixel orphans (4-neighbour, same colour) in gy130..134.
7. Light grain dashes are 30..55, all exactly 3 px. None lies outside e ≤ 1.15 and none touches a seam.
8. At 0.5x, the scene reads as a lattice wall, panelled wainscot, plank floor and a stool in front of the post. No isolated light pixels appear in the corner floor.
