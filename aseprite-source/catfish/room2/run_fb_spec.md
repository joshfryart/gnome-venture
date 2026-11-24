# Cat Fish grey template: RUN-AWAY / RUN-TOWARD (64x64, 8 frames each) spec

Script to write: `cf_run_fb.lua`. Copy the gvlib template block from `cf_run80.lua` + `cf_frames_s4.lua` (`coat/coatHi/coatDk/pawDk`, `edgeStitch`, `paw`, `tailTip`, `catHead`, `catFace`). Mode `sticker`, absolute pixels, +y down. Output `out_fb/cf-cat-grey-run{away,toward}01..08.png`.

## 1. Canvas, anchors, timing
- 64x64. Felt inside x 6..57, y 6..57 (outline + 1 px `#000000` leaves margin >= 3).
- **CX = 32**, fixed. Mirror: `x' = 64 - x`.
- **Head** = idle A `catHead` mask at `ox = 7+dx`, `oy = 3+dy` (idle centre 25,20.5 -> 32,23.5). Ear tips stay at felt y >= 7.
- **Ground** (= idle A): near-pair planted paw centre y 53, felt bottom row 55. Far pair plants higher: toward hind y 50, away fore y 49.
- 70 ms/frame, loop 560 ms. Bounding gallop, near pair lands with a 1-frame stagger, screen-left first: `R[f] = mirror(L[f-1])`.

## 2. Shared pose table
BY = body centre y. sq: chest/rump `rx += sq`, `ry -= sq`. Head dy lags BY 1 frame (`BY[f-1]-44`). eL/eR = idle `catHead` ear offsets: up in flight, out/down the frame after landing, ±1 tilt asymmetry.

| F | key | BY | sq | head dx,dy | eL | eR |
|---|---|---|---|---|---|---|
| 1 | fore contact | 44 | 0 | 0,-2 | 0,0 | 0,0 |
| 2 | fore compress | 45 | +1 | +1,0 | 0,1 | 0,-1 |
| 3 | fore push | 44 | 0 | +1,+1 | -1,2 | 1,0 |
| 4 | **flight gathered** | 43 | -1 | 0,0 | 0,-1 | 0,-1 |
| 5 | hind contact | 44 | 0 | 0,-1 | 0,0 | 0,0 |
| 6 | hind compress | 45 | +1 | -1,0 | 0,-1 | 0,1 |
| 7 | hind push | 43 | 0 | -1,+1 | -1,0 | 1,2 |
| 8 | **flight extended** | 42 | -1 | 0,-1 | 0,-1 | 0,-1 |

Body travel 3 px. No head rotation: tilt = dx + ear asymmetry.

## 3. RUN-TOWARD (front)
Paint order:
1. **Tail tip** (g, cres 2): line width 4, (42,BY-5) -> (46+tx/2,BY-8) -> T=(48+tx,BY-12+ty); `tailTip` light 7x7 at T. Peeks between head and right shoulder.
2. **Hind legs/paws** (far): `coatDk` width 4 from hip (32∓8,BY); `pawDk`, toes shade.
3. **Shoulders** (g, `body`): ellipse (32,BY-5) rx 13 ry 5.
4. **Chest** (g, `body`, gloss (27,BY-3)): ellipse (32,BY) rx 11+sq ry 7-sq.
5. **Forelegs** (g): width 6, (32∓6,BY+1) -> (px,py-1).
6. **Fore paws** (coatHi, toes `s.s` base).
7. **Ears, head** (idle `catHead`, gloss (14+ox,15+oy)).
8. **Stitch** `lit=3` on chest, shoulders, head.
9. **Face**: idle `catFace(...,"open",eL,eR,"orig")` unchanged.

Paws (x,y rx×ry; **bold** planted):

| F | fore L | hind L | tail tx,ty |
|---|---|---|---|
| 1 | **25,53 4.5×2.5** | 18,46 3×2 | -1,-1 |
| 2 | **25,53 4.5×2.5** | 18,46 3×2 | 0,-2 |
| 3 | 26,51 4×2 | 18,47 3.5×2 | 1,0 |
| 4 | 27,49 4×2 | 18,49 3.5×2 | 2,1 |
| 5 | 26,49 4×2 | **18,50 3.5×2** | 2,0 |
| 6 | 25,50 4.5×3 | **18,50 3.5×2** | 1,-1 |
| 7 | 25,50 5×3 | 18,48 3×2 | 0,1 |
| 8 | 24,51 5×3 | 18,46 3×2 | -1,2 |

R by mirror rule (fore R planted F2-F3, hind R F6-F7). Fore paws grow to 5×3 reaching at the camera (F6-F8). Fore-paw gap >= 5 px.

## 4. RUN-AWAY (back)
Paint order:
1. **Fore legs/paws** (far): `coatDk` width 4 from (32∓9,BY-6); `pawDk` 3.5×2; flick out beside the rump.
2. **Hind paws marked u** (tucked under, painted before the rump, mostly hidden).
3. **Ears** (g, cres 2, no gloss, NO pink), idle triangles and offsets.
4. **Back of head** (coatHi, same mask, no face). Tint rows >= hy+4 light->base (nape band). Nape stitch lit half.
5. **Back** (g, `body`): ellipse (32,BY-8) rx 9 ry 6; hides the head's lower middle.
6. **Rump** (g, gloss (25,BY-6)): ellipse (32,BY-1) rx 12.5+sq ry 8.5-sq.
7. **Haunches** (g, cres 1, no stitch): ellipses (32∓7,BY+1+hd) rx 6 ry 6; hd = +1 on the pushing side (L F7-F8, R F8-F1).
8. **Hind legs** (g): width 5, (32∓7,BY+3) -> paw, only when not u.
9. **Hind paws** (near, coatHi). Heel view: no toes. **Pad view (p)**: PINK 3×2 at (cx-1..cx+1, cy..cy+1), PINKS row below, toe beans PINK at (cx-2,cy-2) (cx,cy-3) (cx+2,cy-2).
10. **Tail** (g, cres 2): width 5 P0-P2, 4 P3-P4. P0 = (32,BY-7). Offsets P1 (1,-6), P2 (4+s2,-11), P3 (8+s3,-14+ty), P4 (12+s4,-16+ty). `tailTip` light 7×7 at P4. The question-mark hook crosses the back of the head, and the tip breaks the silhouette right when s4 >= 2.
11. **Stitch** `lit=3` on rump, back, head.

| F | hind L | fore L | s2/s3/s4 | ty |
|---|---|---|---|---|
| 1 | 24,50 4.5×3 p | **18,49** | -1/-2/-2 | -1 |
| 2 | 25,48 4×2.5 u | **18,49** | 0/-1/-3 | -3 |
| 3 | 26,47 4×2 u | 19,47 | 1/0/-2 | 0 |
| 4 | 25,50 4×2.5 | 21,46 | 1/1/0 | 2 |
| 5 | **24,53 4.5×2.5** | 20,45 | 1/2/2 | 0 |
| 6 | **24,53 4.5×2.5** | 18,45 | 0/1/3 | -2 |
| 7 | 24,52 4.5×3 p | 17,46 | -1/0/2 | 1 |
| 8 | 23,51 5×3.5 p | 17,48 | -1/-1/0 | 3 |

Sway: P2 ±1 (lag 1), P3 ±2 (lag 2), tip ±3 (lag 3), one swing per stride, tip <= 2 px/frame, tip felt top y >= 14. R by mirror rule, so pads show on L at F7/F8/F1 and on R at F8/F1/F2.

## 5. Recolour, patterns, masks
- Only the 4 greys + fixed accents (PINK, PINKS, umber ol, gold, `#000000`, eye cream). dk ramps reuse the greys, so `catfish_recolor.py` swaps by name.
- `.aseprite` layers: `outline`, `legs-far`, `tail`, `body`, `legs-near`, `ears`, `head+face`.
- Export per frame `cf-ears-mask-run{away,toward}0N` and `cf-tail-mask-...` (white over felt). A copy of `run80_coats.py` (NF 8, W 64) builds `cf-ears-clear-*` / `cf-tail-clear-*` (mask + changed outline px). Compose: body, erase clear, part, pattern, eyes.
  - Folded ears: idle A flaps at (ox,oy). Away omits the crease.
  - Bobtail: toward draws no tip; away draws ellipse (32,BY-8) 4×3.5.
- Eyes `cf-eyes-<colour>-runtoward0N`: idle boxes (14,19)/(32,19) + (ox,oy). Away has none.
- Patterns `cf-pat-<pattern>-grey-run{away,toward}0N`, clipped to felt (never eye, nose, pink, stitch, outline). **Key frames F1, F4, F8** are hand-checked; the rest are generated part-locally:
  - head: from (ox,oy); toward reuses idle A's head overlay shifted.
  - chest/rump: ((x-32)/rx, (y-BY)/ry), so squash scales marks.
  - haunch/paw: from the part centre.
  - tail/legs: arc length.
- New back markings: tabby = 3 rump saddle bands + 2 arcs on the back of the head; tuxedo away = dark except heels/pads, toward = white bib, muzzle, paws; pointed = ears, tail, paws (+ face mask toward).
- Asymmetric (calico) patches: the cat's left is screen-right toward and screen-left away.

## 6. Acceptance (sheet 512x64, 4x view, 0.5x view, red line y 55)
1. Colours <= 16 incl. transparent (expect toward 14, away 12). Alpha 0/255 only.
2. `t.margin >= 3`; felt bbox in x 6..57, y 6..57.
3. Bold near paws: felt bottom row 55. Far plants: row 52 (toward hind), 51 (away fore). Body-mask centre x = 32 every frame.
4. Loop F8->F1 <= 2 px on every paw, head, ear and tail point; neighbours <= 3 px.
5. 0.5x (32x32):
   - toward: 2 ears, 2 eyes, 2 separate fore paws (gap >= 2 px).
   - away: 2 ears, no face, round rump, tail tip outside the head on F5-F7, pad dots on F8/F1.
6. Stitch lit half only; far parts darker than near parts.
7. No part thinner than 4 px at 1x (paws >= 3 px tall).

## 7. Game use
- Toward = down-screen at the camera; away = up into the room. The game applies the depth scale ladder 1.0..0.42, anchored at bottom-centre (32,55), so the baseline stays on the floor.
- Planted paws are fixed in-frame. Keep game y-speed <= ~1.5 px/frame × scale (≈21 px/s at 70 ms) or the paws slip.
- At 0.42: head 33 px -> 14, paws 9 -> 4, tail 5 -> 2. Hence chunky: ears 11 px, paw gaps >= 5, tail >= 4. Pads and stitch may vanish when small; the silhouette must not need them.
- Switch to and from the side run on F1 (fore contact) so the stride phase carries over. Left-facing side run = game h-flip.
