# Pass 4 FINAL POLISH: zoomies sprint (cf_zoom.lua, zoom_coats.py, make_view_zoom.py)

Review images are in `out_zoom/_view/review/p4/`:
- `grey_4x_a/b`, `half_x4`, `z1..z6_8x` (5 px grid), `coats_2x` and `neigh_3x` (house idleA, house jump, run80 f06, Z3, Z5).
- `sim_seam_ba_*_4x` and `sim_z5_z2_ba_6x` are scratch simulations of items 2-5. The sim's head-seam variant was rejected, see item 1.

**Verdict.** The silhouette, light direction and umber/black border ratio match the house art. Umber `#2a1a10` is 22% here, 22% on house jump and 20% on run80. All current checks pass. What is left is clutter and one latent bug:
- stray gold dashes under the rear belly
- dents from head ticks next to the eye and gloss
- a 1-2 px nub on the skull outline
- the Z5 fore paws tucked into a dark lump

## Changes (priority order)

1. **Latent bug: `head` mask is mutated.** cf_zoom.lua line 242: `Mask:clip` works in place, so `head` and `p.head.m` become the jaw rect. The diag run shows the `p.head.m` bbox as hy+3..hy+10. Make the jaw panel explicit so the output is pixel-identical:
   ```
   local jaw = head:copy():clip(c:rect(hx - 12, hy + 3, hx + 8, hy + 10))
   tint(c, jaw, GREY.light, GREY.base)
   ...
   edgeStitch(c, jaw, p.head, { lit = LIT })   -- was edgeStitch(c, head, ...)
   ```
   Reason: the stitched jaw seam (hy+4, plus steps at hy+6..8) reads as a toy panel. Keep it. A full-head seam (run80 style, `ymax=hy+1`) leaves a hard visor line, see the sim. `p.head.m` must be the full head for checks.

2. **Body stitch: drop the belly strays.** In `frame()`, change `edgeStitch(c, body, p.body, { lit = LIT })` to `{ lit = LIT, ymax = BY - 3 }`. This is the same as run80.
   - It removes these dashes: Z1 (29-30,45) (32-33,46), Z3 (29-30,43), Z6 (20,47) (20,48) (22-23,48).
   - The top seam (y <= BY-5) stays as it is.

3. **Remove head ticks.** Change the `nh` call list `{ {hx-9,hy-2}, {hx-2,hy-4} }` to `{}`.
   - Reason: house heads (idleA, jump) and run80 have clean felt heads. The two ticks read as dents beside the eye and gloss at 4x.
   - Texture px per frame goes from 26,28,30,26,24,26 to 21,22,24,20,18,20.

4. **Skull-outline nub.** There is a 1-2 px black bump at (hx+5..hx+6, hy-12) in Z2, Z3, Z4 and Z6. Add `deSpur(c)` and call it in the main loop right after `local c, p = frame(f)`. `finish()` is idempotent.
   ```lua
   local UMB = { ["#2a1a10"]=true, ["#4a2c1a"]=true, ["#74462a"]=true }
   local function deSpur(c)
     c:finish(); local n = 0
     for y = 1, c.H - 2 do local x = 1
       while x <= c.W - 2 do
         if c:get(x, y) == "#000000" and not c:get(x - 1, y) then
           local x1 = x
           while x1 - x < 2 and c:get(x1 + 1, y) == "#000000" do x1 = x1 + 1 end
           local ok = not c:get(x1 + 1, y) and c:get(x - 1, y + 1) == "#000000" and c:get(x1 + 1, y + 1) == "#000000"
           for i = x, x1 do if c:get(i, y - 1) or not UMB[c:get(i, y + 1) or ""] then ok = false end end
           if ok then for i = x, x1 do c.pix[c:key(i, y)] = nil; c.pix[c:key(i, y + 1)] = "#000000"; n = n + 1 end end
           x = x1 + 1
         else x = x + 1 end
       end
     end
     return n
   end
   ```
   Effect on the skull top (Z3, x 61..65):
   ```
   before  ..K..      after  .....
           KKUKK             KKKKK
   ```
   Expected `despur` per frame: 0,2,1,2,0,1.

5. **Z5 gathered frame: fore paws.** The fore paws are tucked under the chest and make a dark lump.
   - Change `LEGS[5]` `nf={51,48}` to `{53,49}` and `ff={48,47}` to `{50,48}`. Nothing else changes.
   - The fore leg then reads as reaching, with its own paw.
   - Joint steps: Z4>Z5 10 -> 8, Z5>Z2 7 -> 5, Z5>Z6 12 -> 10, max 12 -> 10.
   - Row-50 notch run goes from 4 to 5. The 1 px spur at (36,48) goes away.

6. **Tighten the joint check.** Change `chk(worst <= 12, ...)` to `chk(worst <= 10, ...)`.

7. **Update the texture check.** Change the `tOK` condition so that `T.nh == 0` is required (was 2) and `T.ntex` is 16-30 (was 20-35). Update the message to match.

8. **New checks** (in the read-back loop over the saved PNG):
   - spurs: opaque px with <= 1 opaque 4-neighbour = 0 per frame
   - every opaque px 4-adjacent to a transparent px is `#000000`
   - no gold (`f5cf6a`/`e8a317`) at y > BY-3 with x < hx-12, so the belly is clean
   - `p.head.m` bbox y0 <= hy-8, which proves item 1

9. **Use `p.head.m` in the ear report.** The "skull top y" print now gives hy-8 (it was hy+3). This only fixes the printed value; the gates stay the same.

10. **zoom_coats.py: no code change.** Re-run it after the Lua. The only Z5 change is in the fore legs, so pattern overlays move only there.
    - Loop pairs (Z2>Z3>Z4>Z5>Z2) must be <= 8% for every pattern.
    - Calico, tuxedo and tabby must stay within ±0.5% of 4.1 / 6.2 / 5.8.
    - Spotted Z5>Z6 must be <= 13.8%, the documented exception.
    - The PROBLEM list must be empty.

11. **make_view_zoom.py.**
    - Add `_view/neigh_3x.png`. It is 400x64 on cream at 3x NEAREST and shows: house `cf-cat-grey-idleA` (x0), house `jump` (x68), `out80/cf-cat-grey-run06` (x136), Z3 (x220) and Z5 (x304), all bottom-aligned.
    - Reason: a final cross-group read check.
    - Regenerate every existing view.

## Not changing
Poses Z1-Z4 and Z6, BX, GROUND, tail geometry, ears, body ticks, teeth, tail notches, the colour set (13), gloss and the jaw seam stay as they are. The light/outline ratios already match the house art and run80.

## Acceptance checks
- cf_zoom.lua prints ALL CHECKS PASS, with joint steps max 10, colours 13, semi 0, holes 0 and margin >= 4.
- Orphans (non-face) are <= 6 per frame (sim: 5,4,6,5,6,6).
- Spurs are 0 and edge px that are not black are 0 in all 6 frames.
- Texture: body ticks 3-4, head 0, teeth 6-10, notches 1-2 (Z6 0), px 16-30.
- No gold px below BY-3 outside the jaw. Gold px per frame: 22-34 now goes to 22-30.
- Z5 row-50 notch run is >= 5 and planted hind paw bottoms stay on row 55.
- Pixel diff against the pass-3 PNGs is limited to these places:
  - the belly dashes (item 2)
  - the head tick cells (item 3)
  - the skull nub (item 4)
  - the Z5 fore legs and paws (item 5)

  The Z1/Z3/Z4/Z6 legs, the tail and the jaw seam are unchanged.
- `half_x4`: no gold specks under the haunch, and the skull top is a smooth arc in all frames.
- GIF: the head top profile has no 1-frame bump flicker between Z2/Z3/Z4.
