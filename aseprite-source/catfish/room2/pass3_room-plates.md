# Pass 3 TEXTURE: room A plates (cf_room_a.lua, make_view_room.py)

Reviewed: plates, the scene preview, and 4x and 0.5x crops in `out_room/_view/review/p3/`, against house `cf-room.png`. The house floor carries dark dashes and plank ends; ours carries only light dashes on half the boards. The wall, wainscot, frames and fringe are flat fills. All coordinates are grid px (export/2). Use no new colours: the caps stay at P1 17/20, P2 6/8 and P4 3/4.

## 1. Despeckle paints an umber pixel above the door (bug)
P1 (40,10) is `#4a2c1a`. The despeckle at line 288 copied the outline pixel from row 11.
Change the condition so it needs all four neighbours (left, right, above, below) to differ from the pixel. Also require that `pget(gx,gy+1)` is one of `{lit, haze, stripe, farW}`.
This is required for #2: the bottom arm of the motif would otherwise be erased.

## 2. Wallpaper motif: half-drop stitched cross (back wall only)
In the wall loop (line 119), when `b=="wp"`:
`o=(gx-21)%8`, `col=fl((gx-21)/8)`, `ph = col%2==0 and 6 or 10`, `dy=(gy-ph)%8`.
Use `K.stripe` if `(o==5 and (dy==0 or dy==1 or dy==7)) or (dy==0 and (o==4 or o==6))`.
Skip any cross whose centre `gy-dy` (with dy taken in -1..1) is greater than 36.
Each cross centred at `.`-offset 5 of the haze field looks like this:
```
.X.
XXX
.X.
```
Centres: even columns at gy 6, 14, 22, 30; odd columns at gy 10, 18, 26, 34.

## 3. Skirting stitch row, 2-on 1-off
In the wall loop, at gy 52 (skirting crown band), where the colour is `K.crown`: use `K.rim` if `(gx-21)%3 < 2`.

## 4. Wainscot: groove bevel and grain
Line 120. Groove columns are gx = 21+22n.
- Lit face: gx 22+22n, gy 42..49 -> `K.crown`.
- Grain: let `p=fl((gx-21)/22)` and `o=(gx-21)%22`.
  - Dash A: row `44 + p%3`, o from `4+(p*7)%9` to `+3` (4 px).
  - Dash B: row `47 - p%2`, o from `12+(p*5)%6` to `+2` (3 px).
  - Both use `K.seamD`, and only where the current colour is `K.wain`.

## 5. Floor: dark grain on the `fl2` boards
After line 366, add a second loop: seed 11, `i=1,160`, `gy = 70+rnd(GH-70)`, `len = 2+rnd(2)`, same slope `sx`.
- Condition: every dash pixel is `K.fl2`, and so are `gx-2` and `gx+2` on its row.
- Colour: `K.seamL`.
- Skip a dash if any 8-neighbour is already `seamL` from this loop.

## 6. Floor: lit bevel under each butt joint
In the butt-joint loop (line 344), for `2*gy >= 178` only, set row gy+1 over the same `gx` span: `fl1 -> K.rim`, `fl2 -> K.fl1`. Only replace pixels that are fl1 or fl2.

## 7. Floor knots (6)
Board b is the span between `SEAMGX[gy][b-1]` and `SEAMGX[gy][b]`. Let `cx = fl((l+r)/2)`. Stamp at `(cx-1, gy-1)`. Legend: d = seamD, w = wain.
```
.dd.
dwwd
.dd.
```
Positions (b, gy): (3,122) (5,97) (7,108) (10,118) (12,128) (15,104).
Skip the knot if the board is narrower than 10 px at that row, or if any stamp pixel is not fl1 or fl2 before stamping.

## 8. Door frame grain
Draw these in `K.crownS` after line 166:
- Left jamb: gx25 gy18..21; gx26 gy33..36; gx25 gy44..47.
- Right jamb: gx51 gy22..25; gx50 gy38..41.
- Lintel: gy14, gx30..34 and gx41..45.

## 9. Window frame and sill grain
Draw these after line 253:
- Top rail, gy11: gx156..160 and gx179..183, `K.crownS`.
- Bottom rail, gy40: gx168..171 and gx180..183, `K.crownS`. These avoid the sill pots at 151-156, 161-166 and 191-196.
- Sill, gy43: gx152..156, gx171..175 and gx190..193, `K.wain`.

## 10. Hearth-rug fringe: woven binding and ragged tufts
Replace lines 436-443. For gx 150..243, with `m=(gx-150)%3` and `idx=fl((gx-150)/3)`:
- gy131 (binding): `K.legR` if m<2, otherwise `K.umber`.
- Tufts: where m<2, colour `idx%2==0 and legB or umber`. Rows run 132..134, or 132..133 when `idx%3==1`.
- Where m==2, gy132..134 stay transparent.
The pattern repeats every 9 px:
```
RRuRRuRRu   gy131
BB.uu.BB.   gy132
BB.uu.BB.   gy133
BB.....BB   gy134 (pattern; idx%3==1 tufts end at 133)
```

## 11. Chair wood grain (P4)
Draw these in `K.legR`:
- Front leg: gx3, at gy100..102, gy113..115 and gy124..126.
- Rear leg: gx17, at gy99..101 and gy112..114.
- Apron: row 90, gx3..6; row 88, gx13..16. These rows fall inside legB, under tops of 88 and 86.

## 12. make_view_room.py: regenerate the 0.5x view
After `plain`, save `plain.resize((240,135), Image.NEAREST)` to `_view/review/half.png`. Also save `plain.resize((1920,1080), Image.NEAREST)` to `_view/review/plain4x.png`.

## Acceptance
1. P1 (40,10) is wallpaper, not umber. No umber pixel lies in gy3..10 except an outline.
2. Colour counts: P1 17, P2 6, P4 3, P5 ≤ 8; semi 0; `ROOM A SELF-CHECK: PASS`. The calm zone holds only wallpaper colours.
3. P1 (26,6), (25,6), (27,6), (26,5) and (26,7) are `#e8cc98`, before the vignette. The cross count on the back wall is ≥ 80, and every cross keeps all 5 pixels after despeckle.
4. P1 gy52 alternates rim, rim, crown from gx21 wherever the band is visible.
5. Orphan scan (4-neighbour, same colour) over every pixel added in #2-#11 finds 0.
6. P2: ≥ 60 seamL grain dashes on fl2 boards, none touching a seam. All 6 knots are present, or each missing one is logged with its reason.
7. P4 gy131 at gx150..152 is legR, legR, umber.
8. At 0.5x (`half.png`), the wallpaper reads as a faint cross lattice. The floor reads as planks with grain, not grey noise. No single-pixel speckle shows on the wall.
