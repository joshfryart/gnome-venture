# Pass 3 TEXTURE: run-toward / run-away (cf_run_fb.lua, make_view_fb.py)

Review images are in `out_fb/_view/review/p3/`. I simulated items 1-4 on the current PNGs: `sim2_*_4x.png`, `sim2_*_F1_before_after_8x.png` and `sim2_*_05x_view4.png`.

**Verdict.** Both cycles are flat fills plus seams, which matches the house `cf-cat-grey-idleA` (it also has no fur texture). The biggest flat areas are the away head dome (about 24x10 px of #8a859b) and the rump, and the toward chest. In the simulation, short 3 px shade ticks anchored to each part read as fur clumps at 4x and 8x and disappear quietly at 0.5x, with no salt-and-pepper. Use no new colours. The caps stay at toward 13 and away 12.

## 1. New helper `furTex(c, m, P, ramp, o)`
Put it right after `edgeStitch`. Set `FUR = {GREY.light, GREY.base, GREY.shade}`. Let `x0,y0,x1,y1 = m:bbox()`.

Only pixels at key `k` that pass all of these are eligible:
- `c.own[k]==P`
- `not c.gl.s[k]`
- inside `m:shrink(2)`
- `y` within `o.ymin..o.ymax` (the defaults are `y0..y1`)
- all 8 neighbours have a `c.pix` value in `FUR`

**a) Terminator teeth** (`o.teeth ~= false`). The candidates are eligible pixels whose colour is `ramp.base` and that have a 4-neighbour right, below or above whose colour is `ramp.shade`. Sort the candidates by `math.atan(y-cy, x-cx)`, where `cx,cy` is the bbox centre. Paint `ramp.shade` where `(i-1)%4 < 2`. This gives 2-on 2-off fur teeth along the light/shadow edge.

**b) Clumps** (`o.clumps = N`, the maximum count). Split the bbox into cells 7 wide and 6 tall. For cell row `j = 0,1,...` (starting at `y0`), the cells start at `x0 + (j%2==1 and 3 or 0)`, stepping by 7. In each cell, scan `ay = cy0+1..cy0+4` and then `ax = cx0+1..cx0+5`, and take the first anchor where all 3 tick cells pass these tests:
- each cell is eligible, with colour `ramp.base`
- each cell's 8-neighbours (other than the tick's own cells) are `ramp.base` or `ramp.shade`

Paint the tick in `ramp.shade`. Stop after N ticks. The tick shape, with the anchor at the top-left, is:
```
s.
s.
.s
```
Reason: anchoring to the part bbox means the ticks move with the part, so they do not boil between frames.

## 2. TOWARD: calls in `toward()`
Place them after `c:build(list)` (step 7) and before `edgeStitch(head...)`:
```
furTex(c, ch, p.chest, g, { clumps = 3 })
furTex(c, p.legFL.m, p.legFL, g, { clumps = 1 })
furTex(c, p.legFR.m, p.legFR, g, { clumps = 1 })
furTex(c, tail, p.tail, g, { clumps = 0 })
```
Do not add it to the flanks or belly (`coatDk` has no terminator) or to the paws (they are flat).

## 3. AWAY: calls in `away()`
- Inside `haunch()`, before its `edgeStitch`: `furTex(c, m, P, g, { clumps = 2 })`.
- After step 10 (tail), before the head `edgeStitch`, add:
```
furTex(c, backM, p.back, g, { clumps = 2 })
furTex(c, rump,  p.rump, g, { clumps = 3 })
furTex(c, head,  p.head, g, { clumps = 4, teeth = false, ymin = oy + 8, ymax = oy + 24 })
furTex(c, tail,  p.tail, h, { clumps = 0 })
```
Reason: the away head dome is the flattest area in the set. The tail teeth (shade #8a859b on the #cdc9d3 core) break up the strap look noted in p1/p2.

## 4. TOWARD: inner-ear fuzz tufts (in `catFaceOpen`, after the 2 pink fills)
Apply this to each ear separately. Use the pink pixel rows `r0..r1` of that ear and let `rm = floor((r0+r1)/2)`.
- Left ear: on rows `rm` and `rm+1`, change the pink pixel whose left neighbour is not PINK to `GREY.light`.
- Right ear: the same, using the pink pixel whose right neighbour is not PINK.

That is 2 px per ear, a 1x2 vertical tuft. On F1 they land at (22,19),(22,20) and (42,19),(42,20).
```
row17  p...        ...p
row19  hppp  ->    pppph   (outer edge of the inner ear)
row20  hp          ph
```
Do this only for `catFaceOpen` (toward). The away ears show their backs and have no pink.

## 5. TOWARD: forehead fur ticks
After step 9, with `hx = 25 + ox`, paint `GREY.base` at `(hx-3, oy+16)`, `(hx-3, oy+17)`, `(hx, oy+15)`, `(hx, oy+16)`, `(hx+3, oy+16)`, `(hx+3, oy+17)`. Paint a pixel only if its current colour is `GREY.light`. That gives 3 ticks of 1x2, with the middle one 1 px higher:
```
...g...
g..g..g
g.....g
```
On F1 this covers x 29/32/35, rows 21-23 (row 20 is the gold seam, so nothing collides). Reason: the toward head is about 20x8 px of flat #cdc9d3 and is the largest area in the toward view.

## 6. Self-checks (Lua, at the end of each view)
- Count the px where the post-texture colour differs from the pre-texture colour (save `c.pix` before the texture calls). The expected range per frame is toward 14-40 and away 24-60. Print the counts.
- `chk(colours unchanged)`: toward max 13, away max 12.
- Keep `chk(holes==0 and spurs==0)`. The texture never touches alpha.
- Isolated-dot check: no added shade px has 0 added-shade 8-neighbours, except the forehead and ear tufts, which are whitelisted by coordinate.

## 7. `make_view_fb.py`
Add `%s_F1_8x.png`: F1 on cream, resized to 512x512 with NEAREST. Reason: the ticks are judged at 8x and at 0.5x, and the 4x strip is too small to check rhythm.

## Not changing
- The poses, masks, seams, gloss, colours and layer order stay the same.
- No texture goes on the paws, pink pads, eyes or muzzle.

## Acceptance
- ALL CHECKS PASS. Alpha is only 0/255. Colour counts are unchanged.
- Clump count per frame (see the sim):
  - toward body 1-4
  - away body 3-8
  - away head 2-4
- Toward F1 at 8x:
  - 3 forehead ticks and 2 ear tufts per ear.
  - The chest terminator below the chin row (BY-8) is toothed 2-on 2-off and is no longer a straight line.
- Away F1 at 8x:
  - The head dome shows 4 ticks, none of them touching the gold arc or the gloss.
  - The tail core shows at least 3 shade teeth along its length.
- Every frame: every tick is the same 3 px shape, with no tick touching an umber, gold or #f1ebe3 px.
- 0.5x (`*_strip_0.5x_view4`): the silhouettes and seams read the same as before, and no grey speckle shows on the toward head or the paws.
- Flipping F1 to F2 in the GIF: a tick moves by the same dx,dy as its part (no boiling).
