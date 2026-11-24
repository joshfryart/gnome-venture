# Pass 2 POLISH: side run 80x64 (art director)

Reviewed: `out80/_view/review/p2_*` (4x, 10x grid, 14x heads, 0.5x) and `house_idleA_6x.png`.

**Status now:**
- Colours 12-13 per frame, semi 0. Both fine.
- 21-32 orphan felt pixels per frame.
- 1 px gold stitch singletons in F3, F5, F6, F8 and F10.
- Far-ear felt is only 4/8/8/4/8/13/13/8/4/8/13/13 px (F1-F12), so it flickers.
- From F6 to F12 the tail is an outline-brown lump behind the haunch.
- The jaw tint draws a dead-straight horizontal light/base line, 20 px long, across the head at `hy+3`.

**Mirror rule:** only item 3 changes geometry that Python must copy.

## Changes (priority order)

1. **Far ear: steady and readable.** In `frame()`:
   - `earF` becomes `c:poly({{hx+1,hy-6},{hx+4+exF,hy-13+math.min(eyF,0)},{hx+8,hy-5}}):grow(1)`. The far ear only flicks up and never sinks into the crown. The +1 values in F4 and F9 caused the 4 px frames.
   - **Delete** the far inner-wedge line `c:fill(c:poly({{hx+2,hy-6},{hx+4+exF,hy-10+eyF},{hx+5,hy-6}}):cut(head), GREY.shade)`. On roughly 5 px of felt it makes a 1 px shade stripe between the rim and the crescent, which looks muddy.
   - Keep ramp `g`; run80_fixes #7 rejected `dk`.

2. **Jaw terminator follows the light.** Replace `tint(c, head:clip(c:rect(hx-12,hy+3,hx+8,hy+10)), GREY.light, GREY.base)` with a per-pixel loop over `head`. Tint light to base where `2*(y-hy) + (x-hx) >= 8 and x <= hx+8`.
   This gives a 2-px-step diagonal, high at the right and low at the left, so lower-right is dark. The muzzle (x > hx+8) stays light. Target rows (`L` light, `b` base), columns hx-4..hx+8:
   ```
   hy+2  LLLLLLLLLLbbb
   hy+3  LLLLLLLLbbbbb
   hy+4  LLLLLLbbbbbbb
   hy+5  LLLLbbbbbbbbb
   hy+6  LLbbbbbbbbbbb
   ```

3. **Tail lifted clear of the haunch.**
   - `TAIL_OFF` `{0,0},{-4,-2},{-8,-2},{-11,-1},{-13,-4}` -> `{0,0},{-4,-3},{-8,-5},{-11,-7},{-13,-10}`. Copy the same values into `run80_coats.py` `geometry()` `off = [...]` (line 118).
   - Thin segment `c:line({tp[3],tp[4],tp[5]},3)` -> `4`.
   - Then `tail = tail:closed(1)`. This fills the 1 px `ol1` notch at the segment joint (F1 (12,26)) and matches zoomies #4/#5.
   - Tip y becomes BY-16+tdy3: F1 20, F3 18, F5 18, F9 24, F10 22. The tip x is unchanged (>= 9).

4. **Despeckle body felt.** Add `despeckle(c, p)` after the belly-shadow block and before the paws.
   - Scope: pixels owned by `body`, `haunch`, `chest`, `legFN`, `legHN`, `legFF`, `legHF`.
   - Felt set: `#57516f`, `#8a859b`, `#cdc9d3`.
   - Condition: the pixel is felt, none of its 4 neighbours has its colour, its **up and left neighbours are both felt** (this protects rims), and every felt 4-neighbour shares one colour A.
   - Action: recolour the pixel to A. One pass, read from a copy.
   - Fixes: the 'sb' wobble on the haunch crescent, e.g. F1 (27,39) and (26,41) b -> s.

5. **No 1 px stitch dashes.** In `edgeStitch`:
   - Before writing each gold pixel, store `prev[k] = c.pix[k]`.
   - After the loop, restore `prev[k]` for any painted k with no painted 8-neighbour.

6. **Gloss commas.**
   - Body: `gloss = { rear + 8, BY - 4 }` -> `{ rear + 15, BY - 6 }`. The haunch reaches rear+12 and currently buries the comma, leaving 1-2 px remnants at F1 (26-27,31) and F8 (27,32).
   - Chest: build entry `{ "chest", chest, g }` -> `{ "chest", chest, g, { gloss = false } }`. Its `www` blob at F1 (45-47,35) sits under the chin and competes with the head gloss.

7. **Far paws without toe marks.** Change the `pawFF` and `pawHF` calls from `true` to `false` for toes. On a 7 px base paw the shade toes make a `bsbsbs` dither row (F1 row 54, x 45-50).

8. **Review views.** In `make_view80.py`:
   - Add `review/p2_half_x6.png`: 12 frames, each nearest-resized to 40x32, laid out 6 per row, then x6.
   - Add `review/p2_heads_14x.png`: crop (hx-14, hy-16, hx+16, hy+8) at 14x for F1, F5 and F10.

## Not to change

- **Eye at 0.5x.** It reads as an X or dash in F2/4/6/8/10-12 (nearest sampling of the locked pupil). A ±1 px per-frame shift would wobble it at 1x, so leave it.
- Paw rims in `#f1ebe3` match house idle A.

## Acceptance

- `cf_run80.lua`: ALL CHECKS PASS, colours <= 15, semi 0, margin >= 3, felt inside x 6..72 / y 6..56, tail tip x >= 9.
- Far ear: pixels in `cf-ears-mask-runNN` with x >= hx+1 number 9..14 in every frame. Neighbouring frames differ by <= 3 px.
- Head:
  - No head-owned row has a light/base boundary run longer than 3 px horizontally between hx-12 and hx+8.
  - Muzzle pixels at x > hx+8 keep their colours.
- Tail:
  - The visible tail-mask px count (min/max over frames) is >= 0.8.
  - Visible tail felt is >= 30 px in every frame, including F6-F12.
- Orphans: 0 orphan felt px whose up and left neighbours are felt, on body/haunch/chest/legs. Ear rims and face marks are exempt. Total per frame <= 18.
- Gold: every 8-connected gold group is 2-3 px. 7-9 dashes per frame.
- Gloss:
  - 3-6 `#f1ebe3` px owned by body in every frame, all at x >= rear+13.
  - 0 chest-owned gloss px.
- Far paws: no row contains `#8a859b #57516f #8a859b #57516f` in a row.
- `python3 -I run80_coats.py`, then `python3 -I check_patterns.py`: `ok`, all 5 patterns max jump <= 8%, tabby and spotted body features present in F4-F6.
- Bobtail and `cf-tail-clear` regenerate with the new tail mask.
- At 0.5x (`p2_half_x6.png`) the tail is a raised stroke and the far ear a second point in all 12 frames.
