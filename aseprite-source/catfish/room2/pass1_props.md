# Pass 1 (perspective): lure, wand cast, shadows, dust, streaks

Reviewed: `out_props/_view/review/{near,midfar,wand,wandrod,shst,dust}_{4,1,0.5}x.png` and `cf-rod.png`.
Main findings: near snout and eye sit inside a 3 px umber/`#2a1a10` band (ol 2 + olx 1 drawn around the ear and the snout); the feather is 6-8 px of umber with a 1-2 px blue core, so it reads as a brown ear; the far lure is 6x4 red with two spikes that read as cat ears; wand widths are constant, so it has no depth; the wand's gold shade is `#e8a317` and the grip is flat red, but cf-rod uses `#b8661a`, `#ff9158` and a gold bead.

All edits go in `cf_props_room2.lua` unless a line says otherwise. Do not edit `props_zoomie_spec.md`, because it is shared.

## Priority list

1. **Near outline weight.** In `buildLure`, `SZ.near`: `ol = 2 -> 1`, `olx = 1 -> 1`, `cres = 2 -> 2`. The outline becomes 1 px on the lit side and 2 px on the lower right, which gives back about 30% of the felt area.

2. **Near body, seen from floor level** (wider, lower, flat contact). `SZ.near`: `bx 14 -> 13`, `by 19 -> 19`, `rx 8 -> 9`, `ry 6 -> 6`. Then intersect the body mask with `c:rect(0,0,31,24)`, which leaves a flat bottom chord about 10 px wide on row 24. Keep `floorRow = 25`. Rotated frames (2 and 3) skip the clip.

3. **Near snout and face, uncrowded.** `nose {20,15},{26,20},{20,24} -> {20,14},{27,21},{19,24}`. `pinkNose {24,19,2} -> {25,20,2}`. `eye {20,16,3} -> {21,17,3}`, so all 9 eye pixels land on felt and not on outline. `gloss {11,15} -> {8,15}`, plus one extra pixel at (8,16) to make the enamel comma.

4. **Near ear behind the head (3D).** `ear {17,13,3} -> {15,12,3}`. In `c:build`, move `{"ear",...}` before `{"body",...}` so the body overlaps the ear's lower half and the inner contour separates them. Pink 2x2 at ear centre -1, which gives (14,11)-(15,12).

5. **Near feather readable.** `fth {8,17},{6,10},{7,5} -> {8,17},{5,11},{5,5}` and `fw {4,3,2} -> {5,4,3}`. The feather part keeps `cres=1`. Target: at least 3 blue columns at the widest row.

6. **Near belly seam follows the volume.** `seam {9,24},{19,24} -> {6,21},{9,23},{17,23},{20,21}`. Pass every point to `c:seam` (the code currently uses only `[1]` and `[2]`).

7. **Mid, same perspective.** `SZ.mid`: `bx 9 -> 9`, `by 11.5 -> 11.5`, `rx 5 -> 6`, `ry 3.5 -> 3.5`, and clip the body to rows <= 14. `nose -> {13,9},{17,13},{13,14}`. `pinkNose {14,11,1} -> {16,12,1}`. `eye {13,10,2} -> {14,10,2}`. `ear {11,7,2} -> {9,7,2}`, built before body. `fth {5,10},{4,4} -> {5,11},{3,4}` and `fw {3,2} -> {3,3}`.

8. **Far: a new bold silhouette** (side view, dome, feather up, round ear, snout). Replace `G` in `lureFar` with the grid below and add `n = "#e9b98a"` to `COL`. The border is regenerated from the art. The gold anchor is (4,5).
```
............
.KK.........
KwwK........
KbwoK...KK..
.KboKK.KnnK.
.KboyoKonnoK
KobogrrrreoK
KorrrrrrrrpK
KorrrrrrrssK
.Kossssss1K.
..K111111K..
...KKKKKK...
```
New regions are `fth` = x<=3 and y<=5; `ear` = x>=7 and y<=5; `loop` = (4,5); `body` = the rest. The anchor test changes from `c[1]==7 and c[2]==3` to `(4,5)`. Frame rules (dx,dy):

| F | rule |
|---|---|
| 1 | fth, ear, loop dy +1 (squash) |
| 2 | all dy -1; body x>=9 another -1; fth +1 |
| 3 | all dy -1; body x>=9 +1 |
| 4 | fth y<=2 dx +1 |
| 5 | rest |
| 6 | ear dy +1; fth y<=2 dx +1 |

9. **Wand perspective taper.** The grip is nearest the camera and the tip is on the floor. Change `band(t0,t1,w)` to `band(t0,t1,w0,w1)` with a linear width. Parts: sleeve `(3,13, 7,8)`, shaft `(11,42, 4,5)`, grip `(40,200, 8,11)`. Per-frame width multiplier `WS = {1, 1.15, 1, 0.9, 1, 1}` (frame 2 is lifted toward the camera, frame 4 reaches farthest). Use `cap r` = `{3,4,3,3,3,3}`, unchanged.

10. **Wand colours = cf-rod.** `RODGOLD.shade/deep/bounce #e8a317 -> #b8661a`. Button holes `#8a4f2a -> #8a4a1c`. Grip: one `#ff9158` gloss pixel at band t=48, on the left edge (-nx*(w/2-1)). Sleeve: one `#c8ecdc` glint at t=5 on the left edge. Replace the gold stitch band at T-44 with cf-rod's gold bead: `band(40,43, 7,7)` filled `#f5cf6a`, with lower-right pixels `#b8661a` (part `RODGOLD`, built after grip). Result: every wand colour is a subset of the cf-rod palette (21 hexes).

11. **Shadows flatter with distance.** Keep the canvases, edit `SHADOWS` rows:
    - s1 `20 32 38 42 44 44 42 38 32 20` (unchanged, ratio .23)
    - s2 `16 26 32 34 34 32 26 16 -> 18 28 32 34 32 28 18` (34x7, .21)
    - s3 `12 20 22 22 20 12 -> 14 20 20 14` (22x4, .18)
    - s4 `12 18 18 12 -> 12 18 12` (18x3, .17)

12. **Dust F4 becomes a perspective floor ring.** Add a local `DUST4` table in the Lua and use it instead of the spec's F4. F1-F3 stay as they are.
```
........................
........................
.........oooo...........
........ohhhho..........
....oo..occcco..........
...ohho..oooo...oo......
...osso........ohho.....
....oo.........osso.....
................oo......
........................
....ooooo....oooooo.....
..oohhhhho..ohhhhhhoo...
.ohho.ooo....ooo..ohho..
.occo..............occo.
..occcccco....occcccco..
...oooooooo..oooooooo...
```

13. **Streaks: angle 0°, no change.** The run is parallel to the picture plane, so the current grids are correct. Confirm only.

14. **`make_view_props.py`.** Add `_view/review/lures_cmp_{4,0.5}x.png`, which puts the old `out_props/_view/lures_1x.png` rows above the new near/mid/far rows. Also add `wand_vs_rod_4x.png`.

## Acceptance checks
- Script prints `ALL OK`. Every PNG has alpha 0/255 and no `#ffffff`.
- Near-5: eye 3x3 fully over felt; at least 3 blue pixels in the feather's widest row; at least 2 felt pixels between the eye and the right outline; felt bottom row 24 has at least 9 pixels.
- Far-1..6 at 0.5x (6x6) still show red plus one blue pixel. The anchor (4,5)+offset is `#f5cf6a` in every frame.
- Wand: grip width at row 0 is greater than at the shaft end, and the shaft end is greater than the sleeve. Colours ⊆ cf-rod.png. Cap inside x 4..43. JSON attach unchanged.
- Shadow widths match item 11 exactly; 1 colour; mirror-symmetric.
- Dust-4 matches the grid pixel for pixel. Dust-1..3 and streak-1..3 are byte-identical to before.
