# Pass 2 (polish): lure, wand cast, shadows, dust, streaks

I reviewed `out_props/_view/review/p2_{near,mid,far,wand,shst,dust}_{4,1,0.5}x.png` and pixel dumps, and compared them with `cf-rod.png`. I tested items 1-5, 7 and 8 on a scratch copy of the Lua. It prints ALL OK, and the eyes, loop and cap read at 1x.

Main flaws:
- Near-5: the eye pupil at (22-23,18-19) touches the 2-px `#2a1a10` snout outline, so the eye is lost.
- Mid-5: the eye 2x2 at (14,10) lands entirely on outline pixels, so the mid lure has no eye.
- Mid: the ear covers the loop, which leaves a tan box with a gold lid.
- Near: a 1-px notch at (13,8) between the loop and the ear holds a black spike.
- Near: the feather quill zig-zags x5 -> x7 because it is drawn as one straight segment over a bent feather.
- Far: the feather is 1 px of blue against an umber column, and the eye (9,6) merges with the ear outline.
- Wand: the cap is flat gold, with rim on both its left and right edges and no lower-right shade.
- Wand: a 3 px dark ring plus the K border surrounds the cap.
- Dust-4: the outline leaks at row 12. Dust-3 has a highlight at its lower right.

All edits go in `cf_props_room2.lua` unless a line says otherwise.

## Priority list

1. **Near eye onto felt.** `SZ.near.eye {21,17,3} -> {18,17,3}`. Result: cream at x18-20 y17 and x18 y17-19, pupil at x19-20 y18-19, and felt at x21-23 on row 18.

2. **Mid eye: use the small house eye.** `SZ.mid.eye {14,10,2} -> {10,9,3}`. The `e[3]==3` branch already calls `c:eye(ex,ey,true)`. Result: cream at x10-12 y9, pupil at x11-12 y10-11, and felt at x13.

3. **Near loop/ear notch.** `SZ.near.anchor {11,10} -> {12,10}`. The loop becomes x11-13, which butts onto the ear. Row 7 outline becomes one continuous run `KKKKKK` from x11 to x16, with no K pixel at (13,8).

4. **Mid loop beside the ear, not under it.** `SZ.mid.ear {9,7,2} -> {11,7,2}`, `SZ.mid.anchor {9,5} -> {8,6}`. Mid-5 rows 5-7 x7-9 then show the gold loop (`hhh/hp/hp`) left of the tan ear at x10-13.

5. **Far: 2-px feather, eye off the outline.** In `lureFar`, `G` rows 3-7 (0-based) change as below. Add `q = "#2f6290"` to `COL`. The region rules are unchanged.
```
row3  KbwoK...KK..  ->  KwbbK...KK..
row4  .KboKK.KnnK.  ->  .KbqKK.KnnK.
row5  .KboyoKonnoK  ->  .KbqyoKonnoK
row6  KobogrrrreoK  ->  KobqgrrrrroK
row7  KorrrrrrrrpK  ->  KorrrrrrerpK
```
The eye moves (9,6) -> (8,7), with red on all 4 sides. The feather becomes 2 blue columns plus a 2-px `w` tip. This makes 12 colours.

6. **Quill follows the feather polyline.** In `buildLure`, replace the single `q0 -> q1` loop with one pass per segment `fp[i] -> fp[i+1]`:
   - Use `s = max(|dx|,|dy|)` steps.
   - Skip t=0 on the first segment and the last 1 px of the final segment.
   - Plot `rnd(x),rnd(y)` only when `onF`, and dedupe by key.
   - For mid (`k<1`), keep the 0.9 length factor on the last segment only.

   Target near-5: the quill is 1 px per row, 8-connected, and changes x only at the bend point `fp[2]` (5,11).

7. **Wand outline weight.** In `wandFrame`, change `GV.canvas{ w=48, h=64, mode="sticker", margin=1 }` to `{ ..., margin=1, ol=1 }`. The sticker default is `ol=2`. Because canvas centre (24,32) puts the whole cap in the `s>tx` zone, `olx` stays 1. Result: 2 dark px plus K beside the cap instead of 3 plus K, which matches cf-rod's end ball (rows 49-56).

8. **Wand cap shaded like cf-rod's ball.** In `c:build`, change the cap opts from `{ flat = true }` to `{ cres = 1, deep = 0, gloss = false, bounce = false }`. This keeps `RODGOLD`, the `#fff1c8` gloss px at (tx-1,ty-1) and the holes. Frame 1 result:
```
row50 ...nqqqn...     n=#f5cf6a rim  q=#e8a317
row51 ..nqwqqqp..     p=#b8661a shade  w=#fff1c8  t=#8a4a1c
row53 ..nqtqtpp..
row55 ....ppp....
```

9. **Dust-4 outline leak.** In the `DUST4` table, change the 13th string (y=12) as follows. This closes the holes under the highlight pixels (5,11), (16,11) and (17,11).
```
".ohho.ooo....ooo..ohho.."  ->  ".ohhooooo....oooooohho.."
```

10. **Dust-3 lower-right highlight.** In `fx()`, after the spec grids are read, add `dust[3][12] = dust[3][12]:sub(1,20) .. "s" .. dust[3][12]:sub(22)`. Pixel (20,11) changes from `h #fff3c8` to `s #c9a96e`. Light comes from the upper left. Dust-1, dust-2 and the spec file stay untouched.

11. **The anchor test must see the loop, not the quill.** In mid-3 the fallback gold test passes on feather-quill pixels. Change `buildLure` to `return c, {ax,ay}, p`. In `lureFrame`, the fallback should accept a neighbour only when `c.own[c:key(xx,yy)] == p.loop`. Also require at least 3 loop-owned pixels in the final image in every near and mid frame.

12. **No other changes:** shadows, streaks and the wand JSON stay as they are. The shadow row profiles are already within 1 px of the true ellipse, and the streaks are clean.

13. **`make_view_props.py`.** Add `_view/review/p2_after_{4,0.5}x.png`, which shows near/mid/far rows 1-6 and wand 1-6 on the `(120,140,110)` background, for the next pass.

## Acceptance checks
- Lua prints `ALL OK`. Every PNG has alpha 0/255, no `#ffffff`, and at most 16 colours per lure. The wand stays at 21 or fewer.
- Near-1..6 and mid-1..6: no 4-neighbour of a pupil pixel (`#2a1a10` inside the eye box) is an outline-tone pixel (`#74462a`, `#4a2c1a` or `#2a1a10` outside the eye box). There are at least 2 felt pixels between the pupil and the right outline on the pupil's lower row (frames 1, 4, 5, 6).
- Near-5: row 7 has no `K` pixel between x11 and x16 that has transparency on both its left and its right.
- Mid-1..6: at least 3 `#f5cf6a`/`#e8a317` pixels are owned by `loop`.
- Far-1..6: there are at least 4 blue pixels (`#3f8fb0`/`#2f6290`). The `e` eye pixel has no `#4a2c1a`/`#2a1a10` 4-neighbour in frames 1, 4, 5 and 6. The anchor is `#f5cf6a`.
- Wand-1..6: the cap has at least 2 `#b8661a` pixels at its lower right and no `#f5cf6a` pixel with x > tx+1 and y > ty. The maximum dark run (`#2a1a10`/`#4a2c1a`/`#74462a`) left of the cap on row ty is 2 or less. The JSON is byte-identical.
- Dust-4 row 12 matches item 9. Every `h`/`c` pixel has a non-transparent 4-neighbour below it or is followed by `o`. Dust-3 (20,11) = `#c9a96e`.
- Dust-1, dust-2, streak-1..3 and shadow-1..4 are byte-identical to the current files.
