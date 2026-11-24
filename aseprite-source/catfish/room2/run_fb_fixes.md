# RUN-TOWARD / RUN-AWAY: fixes for pass 2 (art director)

I reviewed `out_fb/_view/review/{toward,away}_4x.png` and `compare_3x.png` (idle A, toward F1, away F5, side run). All the reported faults are there. The joint check fails on the **ears** (F7->F8 eR jumps 5 px, F2->F3 eL 4 px) and on the tail tip following BY. The tables below give **max 3 px everywhere** and loop seam <= 2. I checked them with a Python copy of `dmax`, so the 3 px limit stays and does not need relaxing.

## 0. Shared changes
**Head scale.** Add `k` to `catHead` and `catFaceOpen`. Every idle-space point maps to `(25+(x-25)*k+ox, 21+(y-21)*k+oy)` and every radius becomes `r*k`. Keep the ear `grow(1)`. The eye centres use `ke=0.9` around x=25 (eyes stay 7x7). Nose and mouth are mapped and rounded. **Toward k=0.85, oy=5+dy. Away k=0.80, oy=4+dy.**

SH (old -> new):

| F | BY | sq | hd | eL | eR |
|---|---|---|---|---|---|
|1|44->45|0|0,-2 -> 0,-1|0,0|0,0|
|2|45->46|1->2|1,0|0,1|0,-1 -> 0,0|
|3|44->45|0->1|1,1|-1,2 -> -1,1|1,0|
|4|43|-1|0,0|0,-1|0,-1|
|5|44->45|0|0,-1|0,0|0,0|
|6|45->46|1->2|-1,0|0,-1 -> 0,0|0,1|
|7|43->44|0->1|-1,1 -> -1,0|-1,0|1,2 -> 1,1|
|8|42|-1->-2|0,-1|0,-1|0,-1|

Travel 4 px; sq ±2 makes squash/stretch visible.

## 1. TOWARD
- **Shoulders**: ellipse (32,BY-6) rx 13->**16** ry 5.
- **Chest**: (32,BY) rx 11+sq -> **15+sq**, ry 7-sq -> **6-sq**. F2/F6 come out 17x4 (squash) and F8 13x8 (stretch).
- **Forelegs**: width 6->**7**, from (32∓6,BY+1) -> **(32∓7,BY+2)**.
- **Hind legs**: from (32∓8,BY) -> **(32∓11,BY+1)**, width 4->**5**, `coatDk`. Hind paws are `pawDk` ellipse **rx 4 ry 2.5** (was 3/3.5x2)., outside the chest edge (x 17).
- **Tail** moves beside the right haunch, behind everything. It replaces the stub over the head: `line({{44,BY},{49,BY-4},{52+tx,BY-11+ty}},5)`, tailTip at the end. The tip is at x 51..54, clear of the head edge (x 45).
- **Fore paws** are new ASCII masks, not ellipses, so they are no longer boxy. Each paw's bottom row is cy+2 and it sits at x0=cx-floor(w/2). Use part `h`, `flat`, and toe slits GREY.base 1 px wide at cols w/2-2 and w/2+2 in the bottom 2 rows (L: 3 rows), which gives 3 beans.
```
S 9x5        M 11x6         L 13x7
.#######.    ..#######..    ..#########..
#########    .#########.    .###########.
#########    ###########    #############
#########    ###########    #############
.#######.    ###########    #############
             .#########.    #############
                            .###########.
```
Fore paws grow toward the camera: S when gathered, L when reaching. The fore gap is now 9 px, about 4 px at 0.42x.

TW (fore L `{x,y,size}`, hind L `{x,y}`, tail tx,ty):

| F | fore old -> new | hind old -> new | tx,ty old -> new |
|---|---|---|---|
|1|25,53 -> **22,53 M**|18,46 -> 13,47|-1,-1 -> 0,0|
|2|25,53 -> **22,53 M**|18,46 -> 13,46|0,-2 -> -1,0|
|3|26,51 -> 23,51 M|18,47 -> 14,46|1,0 -> -1,1|
|4|27,49 -> 24,48 S|18,49 -> 14,48|2,1 -> 0,2|
|5|26,49 -> 23,47 M|18,50 -> **14,50**|2,0 -> 1,0|
|6|25,50 -> 22,49 L|18,50 -> **14,50**|1,-1 -> 2,0|
|7|25,50 -> 21,51 L|18,48 -> 13,49|0,1 -> 2,1|
|8|24,51 -> 21,52 L|18,46 -> 13,48|-1,2 -> 1,2|

The ty values cancel the BY bob, so the tip drifts 33..35.

## 2. AWAY
- **Back of head**: k=0.80 and ramp **`g`, not `h`**. The pale dome goes, and the head now reads as part of the coat. The gloss moves to (12+ox,15+oy) and gives only the top rim. Drop the nape `tint`. The ears keep `g` with no pink, and the SH ear asymmetry gives the tilt.
- **Back**: ellipse (32,BY-8) rx 9->**10** ry 6. It now hides the lower 1/3 of the head.
- **Haunches**: replace the ellipses with this 13x13 mask at (32∓7-6, BY+1+hd-6), `g`, cres 2, gloss at (cx-2,cy-3). Add the edgeStitch `lit=3` on each haunch and drop the rump stitch below BY. This removes the hexagon.
```
....#####....
..#########..
.###########.
.###########.
#############
#############
#############
#############
#############
.###########.
.###########.
..#########..
...#######...
```
- **Tail** goes on the right side as a question-mark hook. It is painted after the rump and does not cross the head. Width 5 for P0-P2, 4 for P2-P4:
  `P0=(33,BY-6) P1=(40,BY-7) P2=(46,BY-10) P3=(50+s3,BY-14+ty) P4=(48+s4,BY-19+ty)`, tailTip at P4. P4 curls back inward and stays at x >= 47, which clears the head (max x 44).
- **Pads flick** high (F7-F1, y 50->46) instead of dragging near the ground.

AW (hind L `{x,y,rx,ry,mode}`, fore far L, tail):

| F | hind old -> new | fore old -> new | s3 / s4 / ty new |
|---|---|---|---|
|1|24,50 4.5x3 p -> **20,46 5x3.5 p**|18,49 -> **17,49**|0 / 0 / 0|
|2|25,48 u -> 23,46 4x2.5 u|18,49 -> **17,49**|0 / 1 / -1|
|3|26,47 u -> 25,47 4x2 u|19,47 -> 18,47|1 / 2 / -1|
|4|25,50 h -> 25,50 4x2.5 h|21,46 -> 20,46|2 / 3 / 1|
|5|**24,53** h (keep)|20,45 -> 19,45|2 / 4 / -1|
|6|**24,53** h (keep)|18,45 -> 17,45|2 / 3 / -1|
|7|24,52 p -> 22,50 4.5x3 p|17,46 -> 16,46|1 / 2 / 1|
|8|23,51 p -> 21,48 5x3.5 p|17,48 -> 16,48|0 / 1 / 2|

Drop `s2`. Hind legs: width 5 from **(32∓8,BY+4)**. Pad pink stays as specced.

## 3. Checks for the coder
- Update `I.tip`, `catHead(...,k)`, and `plant`. Toward fore planted when y==53 (bottom 55). The hind planted check stays at 50/52.
- The `edgeStitch` head ellipse must use the scaled mask.
- Away tail top is now about y 21, so the >= 14 check holds.
- Rebuild `_view` and check 0.42x: toward must show 2 ears, 2 eyes, 4 paw blobs and a tail beside the right hip. Away must show 2 ears, a dark head, 2 round haunches and the tail hook on the right.
- Expected joint deltas: toward max 3 (seam 1), away max 3 (seam 2).
