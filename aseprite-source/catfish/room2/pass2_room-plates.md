# Pass 2 POLISH: room A plates (cf_room_a.lua, make_view_room.py)

Reviewed: plates, `cf-room2-preview*.png`, 4x and 0.5x crops in `out_room/_view/review/`, `out_furn/cf-room2-plant.png`, and house `cf-room.png`. Grid = export/2. Rerun the Lua, then `python3 -I make_view_room.py`.

## 1. Remove the P1 plant (it is drawn twice)
`out_furn/furniture.json` already has a P3 `plant` at origin (400,50), 32x60. The P1 plant (lines 255-298) spans gx196..221. Its leaves stick out 4-10 px on both sides of the P3 plant (see `review/plant_overlap.png`).
Delete the whole `do ... end` block at lines 256-298. Keep JSON `slots.plant`. This also drops P1 to 17 colours (terra, leafD and green go; leafL stays in the picture frame).

## 2. Sunbeam: stop drawing a ring round every pane
Lines 472-489. `inner(beam,...)` treats the bars as edges, so each pane gets its own 2 px ring. The panes break into triangles and the beam looks muddy at 0.5x.
- In the `polyE` callback, add `quad[gy*1000+gx]=true` for every pixel (`local quad={}` before it).
- Mullion: `math.abs(xc-xm) < 2.5` gives 2 or 3 px per row. Replace it with `local g0 = fl(xm/2 - .5); local bar = (gx==g0 or gx==g0+1) or (ye>=157 and ye<=160)`. That makes the bar exactly 2 grid px wide.
- Line 488: `inner(beam, gx, gy, 2)` -> `inner(quad, gx, gy, 2)`.

## 3. Doorway has no umber outline (every other raised trim has one)
After line 180, still inside the doorway block, outline only the outer frame:
`rectG(P1,23,11,23,54,K.umber); rectG(P1,23,11,53,11,K.umber); rectG(P1,53,11,53,54,K.umber)`.
Leave the bottom open, because it is the floor line.

## 4. Doorway lintel notch
Line 166, second call `rectE(P1, 50, 30, 53, 31, K.crownS)`: this 2x1 dark stub on the left jamb face (gx25..26, gy15) reads as a hole. Delete it.

## 5. Sconce: four orphan pixels
Pixels (12,26), (9,27), (10,29) and (9,30) are orphans. Replace lines 305-311, the cup and plate, with this grid at x0=8, y0=25. The candle (lines 304) stays. Use `pt` for every non-dot cell. Legend: r rim, c crown, s crownS.
```
rrrrr   gy25
rcccs   gy26
rccs.   gy27
.rcs.   gy28
.rs..   gy29
```
The lit edge on the left steps down at one cell per row and the shade on the right is a continuous diagonal. No run is 1 px except the tip.

## 6. Chair apron and stretcher end in 1 px steps
P4 has orphans at (18,85) and (14,117).
- Line 450: `fl(3*(gx-1)/17)` -> `fl(3*(gx-1)/18)`. That gives runs gx1-6, 7-12 and 13-18, each 6 px.
- Line 454: `fl(2*(gx-6)/8)` -> `fl(2*(gx-6)/9)`. That gives runs gx6-10 and 11-14.

## 7. Night moon is a notched square
Lines 408 (`rectG 159..162,17..20` plus the two n1 psets): replace with an `ascii` of P0n at (159,17) with X = K.cream.
```
.XX.
XX..
XX..
.XX.
```
This makes a crescent lit on the left, which matches the light direction. The colour count is unchanged.

## 8. Floor grain is speckle at the back and at 0.5x
Lines 378-381: change `for i = 1, 300` to `for i = 1, 200`, and `gy = 58 + rnd(GH - 58)` to `gy = 70 + rnd(GH - 70)`. Delete `if gy < 75 then len = 2 end`, because it no longer applies. Behind gy70 the boards are 11 grid px or narrower, and 2 px dashes there read as noise.

## 9. Vignette orphan on the wallpaper
At (180,3), `#e8cc98` sits alone between `#e9d9b0` on the left and below and `#dcbc88` on the right. After `vignette(P1)` at line 314, add a despeckle step. For gy 3..38 and gx 21..218, a wallpaper pixel whose left, right and below neighbours all differ from it takes the colour of the pixel below.

## 10. Stale scene preview
`cf-room2-scene-preview-2x.png` (14:28) predates the pass-1 plates: it has no mullion, no reveal and an old window. In make_view_room.py, after `plain`, build `scene`:
- Start from a copy of `room()` without P4.
- Load `../out_furn/furniture.json`, sort `sprites` by `z`, and `alpha_composite` each `file` at `origin` (skip a file if it is missing).
- Add the three cats of `three`, then P4 at x -4.
- Save it at 960x540 NEAREST over `cf-room2-scene-preview-2x.png`.

## 11. Colour cap self-check matches the spec
Line 669 warns at `n <= 28`. Change it to `n <= 30`, which leaves 2 for cushion and plain bowl (spec cap 32). Line 540: P1 cap stays 20. Print the actual P1 count (expect 17 after #1).

## Acceptance
1. The orphan scan (4-neighbour, same colour) reports 0 in P4, 0 wallpaper-tone orphans in P1, and 0 in the sconce box gx7..13, gy21..31.
2. P1 has no pixel in gx196..221, gy20..55 other than wall bands, the window outline at gx≤199 and the corner crease.
3. In the P5 dump, the mullion bar is exactly 2 grid px on every row from gy69 to gy89. There is no UP1 pixel inside the quad more than 2 px from its outer edge.
4. P1 is umber at (23,30), (38,11) and (53,30), and (25,15) is `#b07a45` (the notch is gone).
5. P0n at gx159..162, gy17..20 matches the crescent grid.
6. P1 has 17 colours or fewer; P4 has 3; P5 has 8 or fewer; semi 0; the Lua prints `ROOM A SELF-CHECK: PASS`.
7. The scene preview has a newer timestamp than the P1 plate and shows the mullion at x345.
8. At 0.5x (`review/half.png` regenerated), the sunbeam reads as two pale panes split by a dark cross.
