# Pass 1 PERSPECTIVE: run-toward / run-away (cf_run_fb.lua)

Review files: `out_fb/_view/review/p1_*`.

**Verdict.** Toward reads as a seated toad. The 32 px shoulder bar looks like crossed arms, the chest is wider than the head, and the hind paws splay sideways to x 13/51 like frog legs. Away reads as a seated cat from behind: the head is as wide as the rump, and the tail runs flat across the back like a strap. In priority order; SH, masks and export code stay unchanged.

## TOWARD (`toward()`)
1. **Delete the shoulders part.** Remove `sh`, `p.shoulders` and their `edgeStitch`. Reason: this bar causes both the crossed-arms read and the orange streak at 0.42x.
2. **Add rear flanks** (far body, painted before the chest, right after the hind paws): `c:ellipse(CX∓11, BY-3, 4, 4)`, ramp `dk`, `{cres=2, gloss=false}`, names `flankL`/`flankR` -> layer `body`. They show 4-5 px of darker body each side of the chest, so the torso recedes.
3. **Make the chest a tall oval narrower than the head.** `ellipse(CX, BY, 15+sq, 6-sq)` -> `ellipse(CX, BY-3, 10+sq, 7-sq)`, gloss (27,BY-3) -> (28,BY-6). At BY 45 it spans x 22..42, y 35..49. The head is 26 wide, so the chest reads as a column behind the face.
4. **Lower the head into the chest** (hunched run, not upright sit): `oy = 5+S.hd[2]` -> `7+S.hd[2]`. Ear felt top becomes about 14, still >= 7. The head bottom is about 37 and overlaps the chest top by 2 rows.
5. **Forelegs:** `{CX∓7, BY+2} -> paw`, width 7 -> `{CX∓6, BY-1} -> {fx, fy-1}`, width **6**. They become longer, narrower columns from the chest with a 7 px gap between them.
6. **Hind paws go between the forelegs, small and dark (far = high and small).** Delete `legHL`/`legHR`; the legs are hidden behind the chest. Change `paw(...,4,2.5,...)` to `rx 3, ry 2`. Replace the hind column of TW (R stays the mirror of L[f-1], giving x 36):

| F | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| hind L old | 13,47 | 13,46 | 14,46 | 14,48 | 14,50 | 14,50 | 13,49 | 13,48 |
| hind L new | 28,48 | 28,47 | 28,48 | 29,51 | **28,50** | **28,50** | 27,49 | 27,47 |

   F4 (gathered) shows the hind paws below the belly between the fore paws. F8 (extended) hides them under the chest (bottom 49). The plant check is unchanged (y 50, bottom row 52).
7. **Tail peeks above the right shoulder, thinner because it is farther away:** `line({{44,BY},{49,BY-4},{52+tx,BY-11+ty}},5)` -> `line({{40,BY-6},{45,BY-10},{49+tx,BY-15+ty}},4)`. Keep the tx/ty table. In the self-check, change the toward tip window from `x51..54` to **`x48..51`**.
8. **Fore-paw foreshortening:** keep the S/M/L masks and keep S at F4. Change F5 from `23,47 M` to **`23,47 S`**. The paw shrinks while lifted and grows (M then L) as it reaches at the camera on F6-F8.

## AWAY (`away()`)
9. **Shrink and raise the head (farthest part):** `KA 0.80` -> **0.72**, `oy = 4+dy` -> **`2+dy`**. Head width 31·0.72 = 22, so the rump (25-30) is clearly the biggest mass. Ear felt top is about 12. In `catHead` the away gloss `{12+ox,15+oy}` falls outside the head (left edge x 21). Replace it with `{ M(15,16) }` for all k.
10. **Neck and back taper:** `backM = ellipse(CX, BY-8, 10, 6)` -> **`ellipse(CX, BY-11, 8, 7)`**, which spans y 27..41 at BY 45 and covers the bottom 2 rows of the head. Keep its stitch.
11. **Tail rises from the rump crease up the spine, then hooks right.** Replace `tp`:
   `{33,BY-6},{40,BY-7},{46,BY-10},{50+s3,BY-14+ty},{48+s4,BY-19+ty}` ->
   **`{32,BY-4},{32,BY-10},{35,BY-14},{42+s3,BY-18+ty},{46+s4,BY-23+ty}`**. Keep widths 5 then 4.
   Change the s4 column from `0,1,2,3,4,3,2,1` to **`0,1,2,3,3,3,2,1`**; s3 and ty stay. The root sits in the 1 px gap between the haunches (x 32, top of haunch BY-5). The tip lands at x 46..49, y 18..25. Change the self-check `t[1] < 47` to **`< 46`**.
```
tail shape at BY45 (x 30..50, y 20..41), # = felt
....................####
..................######
.................######.
...............######...
............#######.....
........#######.........
.....######.............
...#####................
..#####.................
..#####.................
..#####.................
```
12. **Push frames show the drive.** Haunch `hd` on the pushing side goes from +1 to **+2** (L F7-F8, R F8-F1), and the other haunch gets **-1** on those frames. The rump then tilts 3 px while the pad flicks.
13. **Far fore paws** (`pawFFL/R`): rx/ry 3.5x2 -> **3x2**. Change the fore x column of AW from `17,17,18,20,19,17,16,16` to **`18,18,19,20,20,18,17,17`**. Planted y stays 49, bottom row 51. They tuck closer to the haunches and read smaller than the near heels.

## Acceptance
- Toward F1/F4/F8 at 6x: chest bbox width (x 22..42 ±sq) < head width. No sideways hind paw outside x 24..40. Hind paws are visible below the chest on F4 and F5 (>= 3 rows) and hidden on F8.
- Toward 0.42x: 2 ears, 2 eyes, 2 big fore paws with a gap >= 2 px, darker paw notches between them on F4, and the tail tip beside the right ear/cheek, not at the hip.
- Away 0.42x: the rump is wider than the head on every frame. The tail is a vertical line on the spine plus a hook on the right, tip clear of the head outline (>= 1 px cream or outline between them). Pad pink is visible on F8/F1.
- Self-check output: colours <= 16, margin >= 3, planted rows (toward fore 55 / hind 52, away hind 55 / fore 51) pass, seam <= 2, neighbours <= 3, toward tip x48..51, away tip x >= 46, away tail top >= 14.
- Nothing reads as sitting: on every frame of both views, at least one near paw is off row 55 or the BY squash is visible.
