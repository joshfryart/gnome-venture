# Cat Fish grey template: SIDE RUN v2 (80x64, 10 frames) spec

Replaces the 64x64 pilot `cf_run.lua` (8 frames). What was wrong with the pilot: the body is a 30x17 blob, the head is idle A's front face moved over, the tail only points up, the legs are 4-5 px stubs that read as sitting, and frame 5 is a lump with no gaps between legs.
Script: `cf_run80.lua` (a copy of the gvlib template block in `cf_run.lua`: `coat/coatHi/coatDk/pawDk`, `edgeStitch`, `paw`, `tailTip`, `rell`, `catEye`). Mode `sticker`. Coordinates are absolute canvas pixels, origin top-left, +y down. Facing right.

## 1. Canvas and anchors
- Canvas 80x64. The felt (before outline) must stay inside x 6..72, y 6..56, so the sticker outline (umber ol + `#000000` 1 px border, about 3 px) keeps a margin of 3 or more.
- **BX = 34**: the body capsule's centre column. It never moves. Every frame aligns on it. The game moves the sprite at **5 px per frame at 1x** (= 71 px/s at 70 ms), which matches how fast planted paws slide back.
- **Ground**: planted paw centre y = 53 (the same as idle A). The lowest felt row of a planted paw is 55. Bottom outline row is about 58 in every contact frame.
- Head size: profile skull 25x20 plus jaw and muzzle, about 29x22 overall (idle head is 31x22). Head width / body length = 29/34, about 5/6. Chibi stays.

## 2. Parts in paint order (back to front)
Ramps: `g=coat(GREY)` near felt, `h=coatHi(GREY)` head, `dk=coatDk(GREY)` far parts, `pawDk` far paws. Tones: shade #57516f, base #8a859b, light #cdc9d3, gloss #f1ebe3. Fixed accents: PINK #e8909e, PINKS #c66a80, umber/ol tones, gold thread. Notation per frame (table in section 3): BY = body centre y, L = body length (even), `rear = 34-L/2`, `front = 34+L/2`, ts = tilt sign (+1 if tilt >= +3, -1 if <= -3, else 0). S = near shoulder, H = near hip. Far shoulder Sf = S+(-1,-1), far hip Hf = H+(1,-1).

1. **Far ear tip** (dk, cres 2, no gloss): triangle (hx-1,hy-7) (hx+3+ex, hy-13+ey) (hx+5,hy-6), grow 1. Only the tip should show above the skull.
2. **Far fore leg** (dk): 2-bone line, shoulder Sf to elbow 7, elbow to paw 7. Width 4 for the upper bone, 3 for the lower. The elbow bends backward (-x).
3. **Far hind leg** (dk): hip Hf to knee 7, knee to hock 6 (2-bone IK, knee bends forward +x), then hock to paw. Shank and metatarsal are width 3.
4. **Tail** (g, cres 2): `c:line` through P0..P4, width 5 for P0-P2 and width 4 for P3-P4. Root R = (rear+5, BY-6). Base offsets from R: P0 (0,0), P1 (-4,-1), P2 (-8,-2), P3 (-11,-4), P4 (-12,-7). Add the per-frame dy for P2/P3/P4 from the table. Tip: `tailTip` (base becomes light) in a 7x7 box around P4, seam 2 px below it. This tail streams back and only curls up at the tip.
5. **Body** (g, gloss at (rear+8, BY-4)): a capsule drawn as a width-15 polyline through A=(rear+7, BY-2ts), M=(34, BY+arch), B=(front-7, BY+2ts). It is 15 px tall and L px long. `arch` < 0 humps the back up.
6. **Chest** (g): ellipse centred (S.x+1, S.y-5), rx 6, ry 6.5. It joins the body to the head.
7. **Near hind leg** (g): from the knee (IK from H) draw shank knee to hock (width 4), then metatarsal hock to paw (width 4).
8. **Haunch** (g, cres 2): ellipse centred (H.x, H.y-3), rx 7, ry 7.5, painted over the top of the near hind leg. It reads as the thigh.
9. **Near fore leg** (g): S to elbow 7 (width 5), elbow to paw 7 (width 4). The elbow bends backward.
10. **Near ear** (g, cres 2): triangle (hx-8,hy-5) (hx-5+ex, hy-13+ey) (hx+1,hy-7), grow 1.
11. **Head** (h, gloss at (hx-5,hy-5)): skull ellipse (hx,hy) rx 12, ry 9.5, joined with a jaw ellipse (hx+2,hy+4) rx 11, ry 6, and a muzzle ellipse (hx+11,hy+4) rx 3.5, ry 3.5. The front felt column is hx+14, 71 or less.
12. **Paws**: far paws first (`pawDk`, rx 3.5, ry 2.5, toes in shade), then near hind, then near fore (coatHi, rx 4, ry 2.5, toes `s.s` in base). Paw centre = the leg end point.
13. **Edge stitch**: `edgeStitch` on body, haunch and head, `lit = 3` (lit half only), the same as idle.
14. **Face** (after the stitch):
    - Near-ear pink: triangle (hx-6,hy-7) (hx-5+ex, hy-11+ey) (hx-1,hy-7), `:cut(head)`.
    - One eye: `catEye(c, hx+4, hy-3)`. The ring sits at x hx+3..hx+9.
    - Nose: PINK 2x2 at (hx+13,hy+1) (hx+14,hy+1) (hx+13,hy+2) (hx+14,hy+2), with a PINKS dot at (hx+13,hy+3).
    - Muzzle gloss: ellipse (hx+11,hy+5) rx 2, ry 1.
    - Mouth: ol2 at (hx+12,hy+6) (hx+13,hy+6).
    - Whisker pips: shade at (hx+9,hy+4) (hx+10,hy+6) (hx+8,hy+6).

IK rule: paw positions in the table are authoritative. Solve the mid joint (elbow or knee) with 2-bone IK and round it. If the distance is longer than the 2 bones combined, straighten the leg. Bone lengths may vary by ±1 after rounding.

## 3. Ten-frame cycle (transverse gallop, near = lead), 70 ms per frame, loop 700 ms

| F | key | BY | L | arch | tilt | S | H | head hx,hy | ear ex,ey | tail dy P2/P3/P4 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | fore contact (far) | 38 | 36 | 0 | +4 | 47,43 | 21,41 | 56,23 | -1,0 | -1/-2/-3 |
| 2 | fore contact (near) | 39 | 34 | 0 | +3 | 46,44 | 22,42 | 55,24 | -1,0 | -1/-2/-3 |
| 3 | fore push | 38 | 32 | -2 | 0 | 45,42 | 23,42 | 55,25 | -1,0 | 0/0/0 |
| 4 | **flight gathered** | 36 | 30 | -3 | -2 | 44,40 | 24,40 | 54,24 | 0,-1 | +2/+3/+5 |
| 5 | hind contact (far) | 37 | 32 | -2 | -4 | 45,40 | 23,42 | 55,22 | 0,0 | +1/+1/+2 |
| 6 | hind contact (near) | 38 | 32 | -1 | -4 | 45,41 | 23,43 | 55,23 | -1,0 | -1/-2/-3 |
| 7 | hind push | 37 | 34 | 0 | -2 | 46,41 | 22,41 | 56,24 | -1,0 | 0/0/0 |
| 8 | **flight extended** | 35 | 36 | +1 | 0 | 47,39 | 21,39 | 57,23 | -2,+1 | +2/+3/+5 |
| 9 | extended, descending | 36 | 36 | 0 | +2 | 47,40 | 21,40 | 57,21 | -2,+1 | +1/+1/+2 |
| 10 | pre-contact | 37 | 36 | 0 | +4 | 47,42 | 21,40 | 56,22 | -1,0 | -1/-2/-3 |

How the columns were worked out:
- Head bob lags the body by 1 frame: hy = 24 + (BY[f-1]-38).
- Tail lags the body by 2 frames: dy_i = round(k_i x (BY[f-2]-BY[f])) with k = 0.5, 1, 1.5, rounding halves away from 0.
- The head does not rotate.

Paw (and hind hock) positions, absolute:

| F | near fore paw | far fore paw | near hind hock / paw | far hind hock / paw |
|---|---|---|---|---|
| 1 | 57,51 | **52,53** | 24,48 / 23,50 | 25,47 / 26,49 |
| 2 | **54,53** | **47,53** | 26,47 / 28,49 | 28,46 / 30,48 |
| 3 | **49,53** | 42,51 | 28,46 / 31,48 | 29,45 / 33,47 |
| 4 | 43,50 | 38,48 | 29,45 / 33,47 | 31,45 / 35,48 |
| 5 | 40,46 | 39,45 | 29,46 / 32,50 | 30,48 / **33,53** |
| 6 | 45,47 | 43,46 | 28,48 / **31,53** | 25,49 / **28,53** |
| 7 | 51,46 | 49,45 | 24,49 / **26,53** | 18,47 / 15,51 |
| 8 | 58,45 | 55,46 | 14,47 / 11,50 | 17,45 / 13,48 |
| 9 | 59,47 | 55,49 | 17,47 / 14,51 | 19,46 / 16,49 |
| 10 | 58,49 | 54,52 | 20,48 / 18,51 | 22,47 / 21,50 |

Bold = planted (y 53). Between consecutive planted frames, each planted paw moves -5 px in x, so nothing slides. Order of footfalls: far fore (F1-2), near fore (F2-3), all airborne and gathered (F4), far hind (F5-6), near hind (F6-7), extended flight (F8-9), descent (F10), then the loop returns to F1.

F10 to F1 changes are 2 px or less on every joint and on the body, so the loop is seamless.

## 4. Keeping the frames recolourable (tools/catfish_recolor.py)
- Use only the 4 grey tones plus the fixed accents. No new hexes. The dk ramp reuses the same 4 tones.
- Export `cf-cat-grey-run01..run10.png` (2-digit index). The recolour script then palette-swaps them by name to all 8 coats.
- In the `.aseprite` file, keep the separable layers: `tail`, `ears`, `head+face`, `body` (body, chest, haunch), `legs-far`, `legs-near`.
- Also export `cf-ears-mask-run0N` and `cf-tail-mask-run0N` (white #ffffff over the ear and tail felt) so folded-ear and bobtail parts still compose. Folded-ear and bobtail run parts themselves are later work.
- Pattern overlays (`cf-pat-<pattern>-grey-run0N`) use the roles in `tones_overlays.json` (`mark_dark` etc.). They are clipped to the felt mask of body, head, tail and legs. They never cover the eye, nose, pink, stitch or outline.
- **Key frames F1, F4, F8** are hand-checked. In the other 7 frames the Lua generates the pattern in part-local coordinates (relative to BX, BY, L, hx, hy and the tail points), so it moves with the parts and does not flicker between frames.
- Tabby stripes and spots are anchored to the capsule's local x-axis. Pointed and tuxedo regions are anchored to the head, paws and tail tip.

## 5. Acceptance checks (review renders: sheet 800x64, 4x view, 0.5x view, red line at y 55)
1. At 0.5x (40x32), F4 shows 4 separate paws under the belly with gaps between them. F8 shows the fore paws ahead and the hind paws behind with daylight under the belly. The head reads as a profile: a nose bump at the right and one eye.
2. Planted paws sit at felt bottom row 55 exactly. The body column x=34 is identical in all frames. Total vertical body travel is 4 px (BY 35..39).
3. Loop F10 to F1 at 70 ms shows no pop. Joint deltas between neighbouring frames are 7 px or less.
4. Colours: 16 or fewer including transparent. Expect 14.
5. Alpha values are only 0 or 255 (`t.semi == 0`).
6. Transparent margin is 3 or more on all four sides (`t.margin >= 3`). Felt limits: ear tips at y 7 or more, nose at x 72 or less, tail tip centre at x 9 or more, hind paw centre at x 10 or more (so felt stays at x 6 or more).
7. The pilot's faults are gone:
   - the head is never frontal;
   - the tail is never vertical (P4 is at least 9 px left of R);
   - every planted leg measures 10 px or more from root to paw centre;
   - F5 has a visible gap between the far fore paw and the hind paws.
8. The stitch appears only on the lit (top-left) half. Far parts are darker than near parts.

## 6. Later work (not in this pass)
- **Run toward (front view, 64x64 or 80x64)**:
  - Idle A's front head bobs 2 px.
  - Fore paws alternate in a 2-beat with foreshortened ellipses that grow 1 px when lifted toward the viewer.
  - Hind paws peek out on both sides.
  - Tail is hidden or a 3 px tip waving above the back.
  - 8 frames.
- **Run away (back view)**:
  - New back-of-head part: ears from behind with no pink, plus a nape stitch.
  - Rump is a round ellipse showing the hind soles as pads (pink toe beans in PINK).
  - Tail up and swaying ±3 px at the tip.
  - Fore paws flick out at the sides.
  - 8 frames.
  - Needs its own pattern overlay keys, because the back markings differ (tabby saddle, tuxedo back).
- Both need the same baseline (y 53), the same recolour export rules, and a mirrored left-facing side run (flip horizontally in the game, with no separate art).
