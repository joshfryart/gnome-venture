# Pass 1 PERSPECTIVE: room A plates (cf_room_a.lua, make_view_room.py)

Contract (VP 240,-83, `persp`, `seamX`, rug quad) unchanged. Grid = export/2.

## 1. Mullion and transom wiped (bug)
`window` block: line 237 (`P1.p[...] = nil` over gx152..193, gy13..38) runs after lines 228-231, so P1 has no mullion and no transom (alpha 0 at x345 and y51), but the sunbeam still paints their bars. Fix: move lines 228-231 below line 237. End the transom at gx191, not 193 (see #2).
P0/P0n loop (line 381): draw only `if not P1.p[gy*GW+gx]`.

## 2. Window depth reveal (window is right of VP, so the RIGHT and BOTTOM inner faces show)
Wall depth f=.027: dx=(387-240)f=4 px, dy=(77+83)f=4 px. Change these after #1, in this order:
- Delete line 234 (top/left `crownS` reveal; it faces away from the eye).
- Right reveal `rectG(P1,192,13,193,36,K.crown)`, with gx192 set to `K.rim` (its lit edge).
- Bottom reveal `rectG(P1,152,37,193,38,K.rim)`, with row 38 set to `K.crown`.
Corner gx188..193, gy34..38 (R crown/rim, B rim, C crown, . glass):
```
....rR
....rR
....rR
BBBBBR
CCCCCC
```
Robin feet (gy38) stand on the inner sill; `feet_y` stays 77. Add JSON `slots.window.reveal = {right={384,26,387,73}, bottom={304,74,387,77}}`.

## 3. Sunbeam wedge must converge (light VP on the horizon)
Edges now hit y=-83 at x 472/442/411; parallel rays need one point. Use light VP L=(490,-83), so the edge from wall-base x0 is `x0 + (y-110)*(x0-490)/193`.
- `BEAM` {{277,138},{343,138},{330,180},{240,180}} -> {{277,138},{372,138},{350,180},{236,180}}
- mullion `xm = 310 + (285-310)*(ye-138)/42` -> `xm = 345.5 - 0.7487*(ye-110)`
- Transom bar rows 157..160 and y range 138..180 stay; they already match glass heights 77/50/26.
Delete line 458 (wall shaft: light cannot fall on the wall below its own window). In the JSON, remove `sunbeam.wall_shaft` and add `sunbeam.light_vp=[490,-83]`. Clear of cattree, rug, yarn.

## 4. Doorway reveal and threshold (door is left of VP, so the LEFT jamb face and the threshold top show)
Same f: dx=5 at x54, dy=-5 at y109. Replace line 166 (`rectE 54,36,55,109`) and line 168 (hall floor):
- Hall floor `rectE(54,98,99,103,K.soil)`.
- Reveal `rectG(27..29, 16..51, K.wain)`.
- Threshold gx27..49:
```
gy  27 28 29 30..49
52   W  W  T  T      (W wain, T rim, C crown)
53   W  T  T  T
54   C  C  C  C
```
Line 167 glint x 54 -> 60. JSON `slots.doorway.reveal_left=[54,32,59,103]`, `threshold=[54,104,99,109]`.

## 5. Side-wall crown must slope to the VP
In `sliver()`, the flat `if ye<4 ... ye<6` test ignores the VP. Replace it with `yb=(ye-83*s)/(1+s)` for every row. Then `yb<0` -> `K.crownS` (the dollhouse cap wedge), `yb<4` -> crown, `yb<6` -> crownS, else `wallBand`. At x=0 the crown sits at y17..24; the wedge is (0,0)(41,0)(0,17), mirrored.

## 6. Inner corner crease runs the full height
Line 157: gy 3..38 -> keep `K.farW` for gy 3..38. Add `K.seamD` for gy 39..54 at gx20 and gx219, so the corner reads to the floor.

## 7. P4 chair: real depth and scale (now 24 px wide, legs float at y196)
Replace lines 429-435 (plate grid; screen x=2gx-4):
- Front leg gx1..5, gy94..134 with no foot (it runs off-frame): gx1 legR, gx2..4 legB, gx5 umber.
- Rear leg (deeper, so higher and thinner) gx15..18, gy91..127: gx15 legR, 16..17 legB, 18 umber. Contact row gy128, gx14..19 umber.
- Side apron gx1..18: `top=88-fl(3*(gx-1)/17)`, 6 rows: legR / legB x4 / umber.
- Stretcher gx6..14: `top=118-fl(2*(gx-6)/8)`, 2 rows: legR / umber.

## 8. Grain follows the boards, not the screen
Lines 360-373: horizontal dashes fight convergence. Do each dash as `len=2+rnd(2)` grid rows, pixel q at `(gx+fl(q*sx+.5), gy-q)` with `sx=(2*gx+1-240)/(2*gy+1+83)`. At gy<75 use len=2. Keep only the `K.rim` on `fl1` case and drop the `seamL` on `fl2` dashes (they read as fake seams). Abort the dash if any pixel is not `fl1`.

## 9. Sconce plate shears with the left wall (wall slope about -0.6)
Lines 291-293, back plate gx9..11 (P plate, r rim, s crownS):
```
gy27 r P s
gy28 P P s
gy29 P P .
gy30 P . .
```

## 10. Plant pot rim seen from above
Line 272: gy45 -> gx202..203 and 212..213 `K.terra`, gx204..211 `K.soil` (the stems overdraw 207..208). Line 274 lit rim moves to gy44 gx203..212, added to S.

## 11. Self-checks and preview (make_view_room.py)
- Glass check (lines 602-607): every glass pixel is in exactly one of P0 or P1, and P0 has no pixel outside gx152..193, gy13..38. This replaces `glassOpen==42*26`.
- In make_view_room.py, add `_view/cf-room2-persp-check.png`: `plain` at 2x with 1-px #ff00ff lines from (240,-83) through the 18 seam fronts, the door reveal corners (54,109) and (99,109), and window (387,77). Add #00ffff lines from (490,-83) through (304,110), (345.5,110) and (387,110).
- Leave the `x`/`s` model alone (drift and back-scale gap are contract).

## Acceptance
1. P1 alpha 255 at (345,40) and (320,51); glass open px = 1092 - mullion - transom - 132 reveal.
2. The persp-check magenta lines pass within 1 px of the reveal back corners (59,104), (383,73) and (387,73). The cyan lines run along the sunbeam edges and mullion bar within 2 px.
3. P5 has no pixel with y<136; the clash check prints "no shared pixel".
4. The crown at x=1 covers rows 17..24; the crease is continuous from y6 to y109.
5. The chair front leg reaches row 269 with no foot; the rear foot ends at y255.
6. All plates: semi=0, bw=0, colour caps hold; the JSON parses and furniture.json anchors are unchanged.
7. 0.5x: door reveal, window cross and beam bars all visible.
