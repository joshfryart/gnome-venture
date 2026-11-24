# Pass 4 (final polish): toward/away run, notes for the coder

I reviewed `out_fb/_view/review/` (4x strips, 0.5x x4, 10x F1/F5, `neighbours_4x.png` = house idleA | side-run F1 | toward F1 | away F1).
Main faults:
- At 0.5x, away has gold flecks all over it: 42 gold px on F1 vs 26 on the house idle.
- The toward torso is darker than the house and side-run cats: on F1, shade #57516f is 245 px vs base #8a859b at 241. The house has 164 vs 546.
- The away tail is drawn in the light ramp, so `tailTip` has no effect on it (it tints base to light, and there is no base). That is why it reads as a strap.
- The toward tail tip sits in an umber bridge against the head cheek.

All edits are in `cf_run_fb.lua` unless the item says otherwise.

## 1. Away tail ramp (strap fix)
`away()` step 10: `p.tail = c:part(tail, h, ...)` -> `c:part(tail, g, ...)`. Step 10b: `furTex(c, tail, p.tail, h, ...)` -> `g`.
Reason: the tail becomes base fur with a light rim on its left edge, and `tailTip` now paints a light 7x7 tip.

## 2. Away head stitch: top arc only
`away()` step 11: `edgeStitch(c, head, p.head, { lit = LIT })` -> `{ lit = LIT, ymax = oy + 16 }`.
On F1 (oy=1) the stitch keeps rows 16-17, i.e. the crown arc `GGbGGbGG`. This removes the cheek and neck dashes at rows 18-28, including the `gsg` goldS that sits on the shade.

## 3. Away: right haunch gets no stitch
`haunch()`: `edgeStitch(c, m, P, { lit = LIT })` -> `if side == "L" then edgeStitch(c, m, P, { lit = LIT }) end`.
Reason: the right haunch is the shade side, and its stitches add about 8 gold px that turn to noise at 0.5x.

## 4. Away head clumps
Step 10b head: `clumps = 4` -> `clumps = 2`.
Reason: the 4 vertical shade ticks, the stitch and the gloss crowd a 20x14 dome.

## 5. Toward head stitch: forehead arc only
`toward()` step 8: `ymax = oy + 24` -> `ymax = oy + 15`.
On F1 (oy=6) the stitch keeps rows 20-21 (the crown seam). It drops the single dashes down the left cheek at rows 23-29, which run into the eye ring and the ear outline. The side-run and house heads carry no cheek seam.

## 6. Toward torso light
- `p.flankL`: `dk` -> `g`. The left flank is on the lit side, so it gets a base fill with a shade crescent. `flankR` stays `dk`.
- `furTex` chest: `clumps = 3` -> `1`.
- `furTex` legFL/legFR: `clumps = 1` -> `0`. Teeth stay on.

Reason: this matches the house light, where the body is mostly base and the shade only forms a crescent at the lower right.

## 7. Toward hind paws readable
`toward()` step 2:
```
p.pawHL = paw(c, hindL[1], hindL[2], pawDk(GREY), false, 3, 2, GREY.shade)
->        paw(c, hindL[1], hindL[2], h, false, 3.5, 2)
```
Make the same change to `pawHR`. Reason: at 0.5x the hind paws are invisible, and on F5/F6 the belly reads as a dark bag. Light ovals at rows 48-52 give the hind footfall.
Expected F5 result, rows 48-52 around x=28:
```
.#####.
#LLLLL#
#LLLLLL#
#LLLLL#
.#####.
```

## 8. Toward tail out of the head bridge
`toward()` step 1:
- `Tx, Ty = 49 + T.tx, BY - 15 + T.ty` -> `51 + T.tx, BY - 14 + T.ty`
- mid point `{45, BY - 11}` -> `{46, BY - 10}`

Self-check: `t[1] < 48 or t[1] > 51` -> `t[1] < 50 or t[1] > 53`, and change the message to `x50..53`.
Per-frame tip x for F1-F8: 51,50,50,51,52,53,53,52.
Reason: the umber block between the tail and the head is 4-6 px wide on rows 25-29. Moving the tip 2 px right and 1 px down opens a 1-2 px cream notch.

## 9. Texture range check follows items 4 and 6
- Toward: `lo, hi = 14, 40` -> `4, 40`.
- Away: `24, 60` -> `16, 60`.

Print the new counts.

## 10. New gold check (end of each view)
Count px in `{#f5cf6a, #e8a317}` per frame. The check is `chk(max <= cap)` with cap toward 16 and away 30. Print the per-frame counts.

## 11. New light-ratio check (toward)
For each frame, count shade = #57516f and base = #8a859b. Use `chk(shade <= 0.85 * base)`.
If it fails after items 6-7, also change `p.belly` from `dk` to `g`. Do not change the shape.

## 12. `make_view_fb.py`: neighbour sheet
Append the following code:
```
R = here + "/"
nb = [R + "../../../game/assets/img/catfish/cf-cat-grey-idleA.png", R + "out/cf-run-grey-1.png",
      O + "cf-cat-grey-runtoward01.png", O + "cf-cat-grey-runaway01.png"]
s = Image.new("RGBA", (256, 64), CREAM)
for i, p in enumerate(nb): s.alpha_composite(Image.open(p).convert("RGBA"), (i * 64, 0))
s.resize((1024, 256), Image.NEAREST).save(V + "neighbours_4x.png")
s.resize((128, 32), Image.NEAREST).resize((512, 128), Image.NEAREST).save(V + "neighbours_0.5x_view4.png")
```
If the relative path to `game/` fails, use `os.path.normpath(here + "/../../../game/...")`.

## Not changing
- Poses (SH/TW/AW), masks, eyes, face, ear tufts, forehead ticks, fore paws, haunch shapes, layer order and timing stay as they are.
- No other group's files are touched.

## Acceptance
- Lua prints ALL CHECKS PASS. That includes:
  - colours <= 13/12 and alpha 0/255
  - holes = spurs = 0, margin >= 3
  - loop seam <= 2 and neighbours <= 3
  - toward F1 belly umber <= 40
  - planted rows unchanged
  - away tail top >= 14
- Gold per frame: toward <= 16, away <= 30. Away F1 should be about 22-26.
- Toward F1: shade/base <= 0.85.
- Away F1 at 10x: the tail is base grey with a light left rim and a light tip with a gold seam, and no tail px is #cdc9d3 below the tip box. The head stitch ends at row oy+16.
- Toward F5 at 4x: two light hind ovals are visible between the fore paws. The tail tip has at least 1 cream px between it and the head outline on rows 26-30.
- `neighbours_0.5x_view4.png`: the away cat shows gold only on the crown arc, the left haunch and the tail tip. The toward torso tone matches the side-run body.
- Flip through the GIFs F8->F1: no jump in the tail tip greater than 2 px.
