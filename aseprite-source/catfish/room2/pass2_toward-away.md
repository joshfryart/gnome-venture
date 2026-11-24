# Pass 2 POLISH: run-toward / run-away (cf_run_fb.lua)

Review images: `out_fb/_view/review/p2/` (`*_6x.png` for all 8 frames on a grid, `*_F*_12x.png` for key frames, `*_2x_half.png` for 2x and 0.5x). I prototyped items 1-8 in a scratch copy and all self-checks still pass.

**Verdict.** The silhouettes from pass 1 work. The problems are polish. Toward: a 10x8 px solid-umber block between the fore paws, a tail that is 2 px of felt inside umber, a speckled chest stitch and the toe slits on 3x2 paws. Away: 5 stacked dashed arcs and 4 gloss spots, a tail the same grey as the back (it reads as a strap), and pinholes or spurs on every frame.

## TOWARD (`toward()`)
1. **Belly fills the gap between the paws.** Add this first, before `-- 2 hind legs/paws`:
   `p.belly = c:part(c:ellipse(CX, BY + 5, 6, 4), dk, { cres = 2, gloss = false })`
   In `LAYER_OF`, add `belly = "legs-far"`.
   Reason: rows 50-57, x 26-37 are now solid #2a1a10 (umber count is 440 on F1). With the belly, that area becomes a dark-grey underside, and the hind paws on F4/F5 sit on top of it.
2. **Tail: thicker, with clean 45° segments.**
   `c:line({ {40,BY-6},{45,BY-10},{Tx,Ty} }, 4)` -> `c:line({ {41,BY-7},{45,BY-11},{Tx,Ty} }, 5)`.
   Reason: width 4 leaves 2 px of felt (F1 row 29 x49-50). The 5:4 slope also gives a 1 px tip nub at (51,25) on F1/F4. Tip x stays 48..51.
3. **Remove the chest stitch and stop the head stitch at the jaw.**
   `edgeStitch(c, ch, p.chest, {lit=LIT}); edgeStitch(c, head, p.head, {lit=LIT})` -> `edgeStitch(c, head, p.head, { lit = LIT, ymax = oy + 24 })`.
   Reason: these strays go: gold on F1 at (37,37), (25-26,38), (23-24,38..43) and goldS at (22,32), (22,33), (24-25,34), (27,35). Gold per frame drops from 26-39 to 20-22, and that gold is all on the upper-left arc.
4. **Hind paws have no toes.** For `pawHL`/`pawHR`, change the 5th argument `true` -> `false`.
   Reason: s.s slits on a 7x5 paw give the g/s/l speckle on F4 rows 50-53, x 26-31.

## AWAY (`away()`)
5. **The tail gets the pale ramp so it separates from the back.** `p.tail = c:part(tail, g, ...)` -> `c:part(tail, h, ...)`.
   Reason: the tail and the back are both g/s, so at 0.5x the spine tail shows as two umber lines (the "strap" from pass 1). With h it shows as one pale stripe. The tail tip seam stays.
6. **Fewer seams.** Delete `edgeStitch(c, rump, ...)` and `edgeStitch(c, backM, ...)`. Keep the head and haunch stitches.
   Reason: there are now 3 parallel dashed arcs on rows 27-29, 37 and 40-44, plus the head arc, so the back looks quilted. Keeping 3 seams (head and 2 haunches) matches the toward view.
7. **Fewer gloss spots.**
   - `p.back = c:part(backM, g)` -> `c:part(backM, g, { gloss = false })`. This removes the 2x2 white at (26-27,30-31).
   - In `haunch()`: `gloss = { cx-2, cy-3 }` -> `gloss = side == "L" and { cx-2, cy-3 } or false`.
   Reason: the right haunch is on the shadow side. Gloss is kept on 2 parts only: head (15,16 mapped) and the left haunch.
8. **Far fore paws have no toes.** For `pawFFL`/`pawFFR`, change the 5th argument `true` -> `false`. Same reason as item 4.

## BOTH (post-process)
9. **Silhouette cleanup after `c:save`** (pinholes and spurs). Measured on the current PNGs:

| view | holes (transparent, >=3 opaque 4-neighbours) | spurs (opaque, <=1 neighbour) |
|---|---|---|
| toward | F1 (16,48) (17,35) (32,54); F2 (18,36) (32,54); F3 (17,35) (32,54) (49,48); F4 (16,34) (34,56) (51,37); F5 (17,35); F6 (48,27) (51,40); F7 (49,26) (51,38) (51,44); F8 (16,33) (32,54) (50,44) | F1/F4 (51,25), F8 (52,24) |
| away | (44,33) on F1-3, F5, F7; F2 (21,31); F4 (32,12) (45,32) (47,17); F5 (47,17); F6 (32,56) (46,19); F7 (45,34); F8 (32,11) | F4 (46,32) (55,23), F5 (45,33) (55,23), F7 (45,33) (54,24) |

   In the frame loop, add the following right after `local t = c:save(...)`:
   - Re-open the PNG as `Image{fromFile=...}` and run 2 passes:
     - Every transparent px with >=3 opaque 4-neighbours gets `#000000` (alpha 255).
     - Every opaque px with <=1 opaque 4-neighbour gets alpha 0.
   - Save the PNG again.
   - Apply the same edits to `layerSets[f]`: put filled px on the "outline" layer and clear spur px on every layer, so the .aseprite file matches the PNG.
   - Recount `checks[f]` colours, or leave it. The fill adds no new colour.

   Reason: each hole flickers as a 1 px gap in the border at 70 ms. The away (44,33)+(45,33) pair is a notch where the tail hook outline meets the back.
10. **Self-check additions** (Lua, end of each view):
   - `chk(holes==0 and spurs==0, view.." silhouette clean")`, using the same definitions as item 9.
   - Toward only: count px of #2a1a10 in rows 48..57 and x 26..38 on F1, and check it is <= 40. It is 96 now.
11. **`make_view_fb.py`.** Add a `%s_strip_2x.png` (1024x128, NEAREST). Also add a 0.5x strip shown back at 4x (`strip.resize((256,32)).resize((1024,128), NEAREST)`). Reason: the brief requires a 1x/2x/0.5x comparison, and today the 0.5x is only 256 px wide.

## Not changing
- The SH/TW/AW pose tables, the masks and the export layout stay. Neighbour deltas stay <= 3 and the seam stays <= 2.
- The face (muzzle `wwqww`, eyes) stays. It matches the house idle art.

## Acceptance
- Self-check prints ALL CHECKS PASS, including the new silhouette check. Colours: toward 13, away 10-12 (<= 16). Alpha is only 0/255. Margin >= 3.
- Toward F1 at 12x:
  - No gold below row `oy+24`.
  - The tail shows >= 3 px of felt per row on rows 27-34.
  - Rows 50-54 between the paws are dark-grey belly (#57516f / #8a859b), not umber.
- Toward F4 at 12x: the hind paws show >= 3 rows of `pawDk` with no shade dots inside.
- Away every frame:
  - Gold appears only on the head arc and the 2 haunch arcs. Gold px count per frame is <= 50 (now 45-55).
  - #f1ebe3 appears only in the head comma, the left haunch comma and the pad/heel rims.
  - The tail is light (#cdc9d3 core) along the spine.
- 0.5x: the toward strip shows 2 fore paws separated by a dark belly, not a black block. The away strip shows one pale tail stripe over the grey back.
