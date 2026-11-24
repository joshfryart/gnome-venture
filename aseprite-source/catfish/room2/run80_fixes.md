# Run80 fixes (art director)

## Verdict
The footfall order reads as a gallop, and planted paws slide a steady -5 px. Three things break it:
- **Hind teleport:** the hind paws jump 13-15 px on F6->F7->F8.
- **Loop seam:** the hind paws jump 5 px on F10->F1, and the tail tip pops 5 px on F9->F10.
- **Rigid body:** the torso does not flex, and the stitched haunch reads as a wheel.

**10 frames cannot fix this.** With a 2-frame plant at -5 and steps of 7 px or less, the F8 hind paw can only reach x 17 or more, which is behind a hip at x 21. That is no visible extension. **Use 12 frames at 60 ms** (720 ms loop; game speed 83 px/s). Each paw is planted for 3 frames.

## Fixes in cf_run80.lua
1. **Frame count:** set `FRAMEMS` from 70 to 60. Change every `1,10` loop to `1,12`, and `f % 10` to `f % 12`. Then replace `POSE` and `LEGS` with the tables below.
2. **Hind path:** use the `nh` and `fh` columns below. The largest step is 6 px, the seam is 2 px, and the paws reach x 10-11 in F10-F11.
3. **Fore path:** use the `nf` and `ff` columns below. In F5 the fore paws tuck to x 41-43, which leaves at least 12 px between fore and hind paws.
4. **Spine flex:** `arch` runs from -5 (F5) to +2 (F10); it was -3..+1. `L` runs 28..36. Set `S.x = front-5` and `H.x = rear+5`.
5. **Tail:**
   - `TAIL_OFF` becomes `{0,0},{-4,-2},{-8,-2},{-11,-1},{-13,-4}` (a soft S) and `R` becomes `(rear+6, BY-6)`. The tip stays at x 9 or more.
   - Change the P2-P4 width from 4 to 3.
   - Replace the BY-driven `tdy` with the one-wave-per-stride values in the table. The tip moves 2 px or less per frame, and P2 and P3 lead it by 2 and 1 frames.
6. **Head tone:** the run head is 85% light, against 69% in idle A, because the profile has no lower band. After `build`, add `tint(c, head:clip(c:rect(hx-12,hy+3,hx+8,hy+10)), GREY.light, GREY.base)` and keep the muzzle light.
7. **Far ear:**
   - Shape: triangle `(hx+1,hy-7)`, `(hx+5+exF,hy-13+eyF)`, `(hx+8,hy-6)`. This shows about 5 px of ear instead of about 3.
   - Ramp: change `dk` to `coat(GREY)` (cres 2, no gloss). The `dk` shade base merges into the umber outline.
   - Lag: set `exF,eyF = ear[f-1]` so the far ear flicks a frame behind.
8. **Ear flick:** use the `ear` values in the table. The ears go back and down one frame after each landing (F3, F8) and up in flight.
9. **Legs:**
   - Near fore upper bone: width 5 -> 6.
   - Near hind: shank 4 -> 5, metatarsal 4 -> 3.
   - Far upper bones: 4 -> 5.
   - `BONE.hind2`: 6 -> 7, so the extended leg does not lock straight.
10. **Haunch:**
    - Remove its `edgeStitch`.
    - Ellipse becomes `(H.x-1,H.y-4)`, rx 7.5, ry 7.
    - Add `c:line({H,nhK},6)` so the thigh tapers into the knee.
    - Set `cres` to 1.
11. **Head:** set `hx = S.x+9` so the head surges with the shoulders. Keep the 1-frame lag rule for `hy`.
12. **Self-check:** also test that hip-to-hock distance is between 4 and 13 (no IK fold). The tables measure 4.5 to 12.8.

## Pose table (60 ms)
| F | key | BY | L | arch | tilt | S | H | head | ear | tdy P2/P3/P4 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | far fore down | 38 | 36 | 0 | 4 | 47,43 | 21,41 | 56,23 | -1,0 | -2/-2/-2 |
| 2 | both fore | 39 | 34 | 0 | 3 | 46,44 | 22,42 | 55,24 | -1,0 | -2/-3/-3 |
| 3 | fore push | 38 | 32 | -2 | 1 | 45,42 | 23,42 | 54,25 | -2,1 | -1/-2/-4 |
| 4 | push-off | 37 | 30 | -3 | 0 | 44,41 | 24,41 | 53,24 | -1,0 | 0/-2/-3 |
| 5 | gathered | 36 | 28 | -5 | -2 | 43,40 | 25,40 | 52,23 | 0,-1 | 1/0/-2 |
| 6 | far hind down | 37 | 30 | -3 | -4 | 44,40 | 24,42 | 53,22 | 0,-1 | 2/2/0 |
| 7 | both hind | 38 | 32 | -2 | -4 | 45,41 | 23,43 | 54,23 | -1,0 | 2/2/2 |
| 8 | hind push | 37 | 34 | -1 | -3 | 46,41 | 22,42 | 55,24 | -2,1 | 2/3/3 |
| 9 | push-off | 36 | 36 | 0 | -2 | 47,40 | 21,40 | 56,23 | -1,0 | 1/2/4 |
| 10 | extended | 35 | 36 | 2 | 0 | 47,39 | 21,39 | 56,22 | 0,-1 | 0/2/3 |
| 11 | descending | 36 | 36 | 1 | 2 | 47,40 | 21,40 | 56,21 | 0,-1 | -1/0/2 |
| 12 | pre-contact | 37 | 36 | 0 | 4 | 47,42 | 21,40 | 56,22 | -1,0 | -2/-2/0 |

## Leg paths (hock / paw; **bold = planted**)
| F | nh | fh | nf | ff |
|---|---|---|---|---|
| 1 | 13,46 / 15,48 | 13,45 / 15,47 | 57,51 | **52,53** |
| 2 | 18,46 / 20,48 | 17,45 / 19,47 | **55,53** | **47,53** |
| 3 | 21,46 / 24,48 | 20,45 / 23,47 | **50,53** | **42,53** |
| 4 | 24,46 / 27,48 | 23,46 / 26,48 | **45,53** | 40,49 |
| 5 | 26,46 / 29,49 | 25,46 / 28,50 | 43,48 | 41,46 |
| 6 | 28,46 / 30,50 | 25,49 / **28,53** | 44,46 | 43,45 |
| 7 | 26,49 / **29,53** | 21,49 / **23,53** | 48,45 | 46,45 |
| 8 | 22,49 / **24,53** | 17,49 / **18,53** | 52,45 | 50,45 |
| 9 | 18,49 / **19,53** | 15,47 / 12,50 | 56,45 | 54,46 |
| 10 | 16,47 / 13,50 | 12,46 / 10,49 | 58,46 | 56,46 |
| 11 | 13,45 / 11,48 | 12,46 / 11,48 | 59,47 | 57,47 |
| 12 | 14,46 / 13,48 | 12,45 / 13,47 | 58,49 | 54,51 |

Script-checked:
- Steps between frames are 6 px or less (6 only at push-off F8-F10).
- The F12->F1 seam is 2 px or less.
- Every plant slides -5 px per frame.
- Planted legs measure 11 to 13 px.
- The felt stays inside x 6..72.

The swing eases out of the rear-most position (F10-F12, 1-3 px per frame), then whips forward on F1-F4 (3-5 px per frame).
