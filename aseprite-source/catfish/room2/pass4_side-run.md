# Pass 4 FINAL POLISH: side run 80x64 (art director)

I reviewed `out80/_view/review/p4/`: grey_4x, half_x6, f01/f04/f07/f10_8x, and coats_3x (8 coats, plus the 5 patterns, folded ears, eyes and bobtail composited). I compared them with the house `cf-cat-grey-idleA.png` and `out_room/cf-room2-scene-preview-2x.png`.

**Diagnosis.** The house body is a flat base field with a light rim, a 4 px gloss streak, a shade crescent and a gold seam. It has no interior marks. The run cat has drifted busier:
- 140-184 interior `#2a1a10` px per frame.
- 9 flank dashes and 3 haunch dashes.
- 31 gold px (house: 22).
- The body gloss changes every frame: 6,7,5,5,**0**,6,6,5,5,**3**,5,7 px, with x moving 29→37. It touches gold in 10/12 frames.
- In F1/F2/F3/F11/F12 the far hind paw sits 2 px directly above the near hind paw. That makes a stack of umber strips (F1 rows 43-46, x 8-20).

All edits are in `cf_run80.lua` unless noted.

## 1. Remove the flank clumps (line 286)
Delete the whole `for _, uv in ipairs{ {-1,1},{5,1},{2,3},{9,3},{-5,3},{11,1},{1,-4},{7,-2},{-3,-2} }` loop (lines 286-290).
**Reason:** these are the 2 px dashes scattered on the barrel. At 0.5x they read as tabby stripes and freckles, and they clash with the tabby/spotted overlays. The house barrel has none. Keep `spineY` hoisted, because item 4 uses it.

## 2. Remove the haunch dashes and the haunch light teeth
- Delete lines 278-284 (the `{-4,-6,1},{-1,-2,1},{-6,-1,0}` loop).
- Delete line 277: `serrate(c, p.haunch, GREY.light, GREY.base, 1, 0, ...)`. It was not in the p3 spec.
- Keep line 276 (haunch shade teeth).

## 3. Soften the chest contour
Line 231: `{ gloss = false }` → `{ gloss = false, contour = GREY.shade }`.
**Reason:** today the chest draws a 1 px `#2a1a10` vertical line at x = S[1]-4 (F1: x=43, rows 35-44), across the shoulder. The ruff is fur, not a limb. A shade contour still separates it. Expect about 10-14 fewer interior umber px per frame.

## 4. Fixed body gloss comma
- Line 230: `{ gloss = { rear + 15, BY - 6 } }` → `{ gloss = false }`.
- After the chest `serrate` (line 285), paint this, with `y0 = round(spineY(BX)) - 4`:
  ```
  x:   BX-1 BX BX+1 BX+2
  y0    W    W   W    .
  y0+1  .    .   W    W
  ```
  `W = GREY.gloss`. Write a pixel only if it is body-owned and currently `GREY.base` or `GREY.light`.
- **Reason:** it is the same 5 px comma in all 12 frames, 2 rows below the stitch (the stitch is on row sp-6), so it never touches gold. It is clear of the rim teeth (`(x-BX)%6` = 3, 4) and of the F5 haunch (right edge x=32).

## 5. Head stitch: crown arc only
Line 296: `ymax = hy + 1` → `ymax = hy - 5`.
**Reason:** this drops the back-of-head column at x≈hx-11 (F1: x=45, rows 19-24), where gold sits next to the near-white `#f1ebe3` rim and the light head. At that contrast it reads as flecks at 0.5x. It also matches toward/away pass 4 item 5 (crown seam only).

## 6. No gold on the tail tip
- In `tailTip`: `c:seam(seam)` → `if seam then c:seam(seam) end`.
- Line 253: drop the 4th argument (pass `nil`).
- **Reason:** it is a lone 2 px gold dash on the tail tip (F1: (9-10,22)). It is the one gold group off the body seams.

## 7. Lighter belly band
Line 264: `y >= spineY(x) + 5` → `y >= spineY(x) + 6`.
**Reason:** the run cat's shade:base ratio is 0.38 (220:581 on F1), against 0.30 for the house. F7 rows 44-47 merge into a dark bag.

## 8. Stagger the far hind paw behind the near paw (`LEGS` table, `fh` only)
| F | old `fh` | new `fh` |
|---|---|---|
| 1 | `{{13,44},{15,46}}` | `{{12,44},{12,46}}` |
| 2 | `{{17,44},{19,46}}` | `{{16,44},{16,46}}` |
| 3 | `{{20,44},{23,46}}` | `{{19,44},{20,46}}` |
| 11 | `{{12,45},{11,47}}` | `{{12,45},{9,47}}` |
| 12 | `{{12,44},{13,46}}` | `{{11,44},{10,46}}` |

- Keep the exact `{ nf={..}, ff={..}, nh={{..},{..}}, fh={{..},{..}} }` spacing. `run80_coats.py` parses it with the regex on line 88.
- **Reason:** the dark far pad (rx 3.5) now peeks 3 px out behind the near pad (rx 4), instead of leaving a 1-row sliver between outlines.
- Checks I computed: hip-hock 11.2 / 7.6 / 6.4 / 12.2 / 12.5 (≤13). Neighbour deltas ≤6. F12→F1 = 2. F10→F11 = 1.

## Not to change
- Rim and belly serration teeth (edge fur).
- Haunch shade teeth.
- Cheek fluff, tail clumps, eyes, nose and ears.
- POSE.
- The 8-coat palette.

## Acceptance
1. `AppRun -b --script cf_run80.lua` prints ALL CHECKS PASS: colours ≤13, semi 0, margin ≥3, planted rows 55/54, body column constant, travel 4, joint deltas ≤7, F12→F1 ≤2.
2. Gold px per frame: 20-26 (now 27-33). 0 gold px at y > hy-5 on the head. 0 gold px in the tail. Every 8-connected gold group is 2-3 px.
3. Body gloss (`#f1ebe3`, body-owned): exactly 5 px in all 12 frames, at the same offset from (BX, round(spineY(BX))). 0 of those px 8-adjacent to gold.
4. Interior `#2a1a10` (3 px inside the silhouette) ≤ old − 8 in every frame. Old: 143,164,151,147,145,152,184,140,123,126,125,146.
5. No body-owned 2 px horizontal shade dash with base above and below it, away from the belly band (the clumps are gone).
6. Shade:base ratio on F1 ≤0.34.
7. F1, F2, F3, F11 and F12 at 8x: the far hind pad shows ≥3 px wide to the left of the near pad. No row in x 8-20, y 43-47 is >50% umber.
8. Drop the p3 "largest base region ≤140" target: the house field is ~400 px. A new limit applies: largest region ≤200.
9. `python3 -I run80_coats.py` then `python3 -I check_patterns.py`: ok. All 5 patterns max jump ≤8.0%. If calico goes above 8.0%, nudge only its smallest patch by 1 px in `run80_coats.py`.
10. Rebuild `make_view80.py` views. Then check that half_x6 shows no barrel freckles and that the run cat's gold density at 0.5x is ≈ house idle.
