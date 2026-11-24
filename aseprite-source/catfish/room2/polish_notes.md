# run80 coats: polish notes (art director)

How to read the grids: lx,ly are offsets from head centre (hx,hy). Tones are grey-space: G gloss, L light, B base, S shade, D deep, '.' leaves the pixel alone. Review renders are in out80/coats/_view/review/.

## 0. Global
- **Body pattern pops in and out (frames 4-6, L=28-30):** the haunch ellipse covers u<=-2 and the chest covers u>=4. Any body feature placed at a fixed `u` gets hidden in those frames. Place body features by fraction instead: `t=(x-(rear+12))/max(1,L-22)`, where t=0 is the haunch edge and t=1 is the chest edge.
- **Rectangles read as blocks.** Every rectangular patch or spot must skip its 4 corner pixels.
- **Folded ears:** `compose` erases the pattern on `eclear`, so a folded ear never gets a pattern. Classify the new fold pixels as `part='ear'` with their own lx,ly. Write `cf-pat-<p>-<coat>-runNN-fold.png`, used in place of the normal overlay when ears are folded.

## 1. Folded ears (a): rewrite `folded_ears`
**What is wrong now:** the top half becomes a flat bar of outline, and the pink inner ear (lx -6..-3, ly -10..-8) stays visible.

**What to match:** the house idleA fold is a flat cap with a light rim on top, base in the middle, a shade crease where it meets the skull, and the tip folded forward.

**Steps:**
1. Build `remove` from three sets, all where ly<=-6:
   - every pixel in the ear mask
   - every pink pixel (R>200, G<190)
   - every outline-coloured pixel inside the head ellipse `(lx/12)^2+(ly/9.5)^2<=1`
2. Put every removed pixel that is inside the ellipse back into `add` as L.
3. Lay the grid for the frame on top of `add`.
4. Pass `remove` and `add` to `reoutline`.

**Which grid each frame uses.** The near ear takes the frame's own offset (`ear`); the far ear takes the previous frame's offset (`pe`).

| Ear offset | Near ear frames | Far ear frames |
|---|---|---|
| (-1,0) | 1, 2, 4, 7, 9, 12 | 1, 2, 3, 5, 8, 10 |
| (-2,1) | 3, 8 | 4, 9 |
| (0,-1) | 5, 6, 10, 11 | 6, 7, 11, 12 |

**Near ear, offset (-1,0):**
```
lx   -8-7-6-5-4-3-2-1 0
-12   . L L L L . . . .
-11   L L B B B L L . .
-10   B B B B B B B L .
 -9   S S S S S S B B S
 -8   . . . . . . S S S
```
**Near ear, offset (-2,1):** squashed and pressed down.
```
lx   -8-7-6-5-4-3-2-1 0
-11   L L L L L . . . .
-10   B B B B B L L . .
 -9   S S S S S B B L .
 -8   . . . . . S S B S
```
**Near ear, offset (0,-1):** lifted.
```
lx   -8-7-6-5-4-3-2-1 0
-12   . . L L L L . . .
-11   L L B B B B L L .
-10   B B B B B B B B S
 -9   S S S S S S S S S
```
**Far ear, offset (-1,0):** one tone darker than the near ear.
```
lx    2 3 4 5 6 7 8
-12   . . B B . . .
-11   . B B B S . .
-10   . B S S S S .
 -9   . D D D S S D
```
**Far ear, other offsets:** derive them from (-1,0) with the same moves as the near ear.
- (-2,1): drop row -12, move row -11 one pixel left, and move the tip pixel (8,-9) down to (8,-8).
- (0,-1): move row -12 one pixel right.

No tone on either ear is lighter than L, which keeps the read with the house set.

## 2. Calico (b)
**Head:** replace `dark_patch` head entirely and delete the cheek rect (-12,1,-8,5). Use the two patches below.

Deep patch over the near-ear root, with a shade trailing edge:
```
lx   -11-10-9-8-7-6-5-4-3
 -9    .  . . . D D D . .
 -8    .  . . D D D D D .
 -7    .  . D D D D D D .
 -6    . D D D D D D . .
 -5    D D D D D S . . .
 -4    D D D D S . . . .
 -3    . D D S . . . . .
 -2    . . S . . . . . .
```
Shade blot on the forehead, kept clear of the eye box:
```
lx    0 1 2 3
 -8   . S S .
 -7   S S S S
 -6   . S S .
```
- **Ears:** near ear (lx<=0) is D. Far ear gets no patch.
- **Head white:** replace the stepped muzzle with the oval `((lx-8)/7)^2+((ly-4)/4.5)^2<=1`.
- **Chest white:** make it a bib with `lx>=-3 and ly>=-1-max(0,lx)//2`. The current straight cut at ly>=-2 reads as a white box on the foreleg top.
- **Body:** the D patch covers `0.05<=t<=0.6`, `-8<=v<=-1`. Make the top edge wobble with v_top -8 at t<0.15, -7 elsewhere and -9 at 0.3-0.45. The S patch covers `0.7<=t<=1`, `-6<=v<=-1`. Drop the corners of both.
- **Haunch, tail, legs:** keep as they are.

## 3. Tabby
- **Head:** delete the `ly==-1` line from lx -10 to 1. It reads as a seam running into the eye.
- **Forehead "M":** three strokes at lx0 = -6, -3, 0, each running ly -9..-6, with the pixel at ly<=-8 shifted to lx0-1 so the strokes lean back. Tone is D at ly<=-8 and S below.
- **Cheeks:** ly=1 at lx -11..-8, and ly=3 at lx -10..-7. Both are S.
- **Body stripes:** place them at t=0.15, 0.5 and 0.85 (replacing u0 -4/1/6). Make them 2px wide when L>=32 and 1px when L<32. This keeps all three visible in frames 4-6. The tabby pixel count currently drops from 176 to 144.
- **Haunch:** keep only the inner ring (4.5<=dd<6.0). The outer ring meets the stripes and makes a muddy area in frames 5-7.

## 4. Spotted
**What is wrong now:** the spots are single-tone 2x2 squares that look like holes, and body spots at u=-5 and u=7 vanish at short L.

Use these two shapes, anchored at their top-left:
```
A: . D D      B: D D .
   D D S         D S D
                 . D .
```
- **Body:** A at t=0.15 v=-5; B at t=0.5 v=-2; A at t=0.85 v=-6.
- **Haunch:** B at (-6,-3), A at (-2,-7), A at (-1,0).
- **Chest:** A at (-2,0).
- **Head:** two 2x1 D specks at (-6,-7) and (-3,-8), plus A at (-10,1).
- **Tail and legs:** keep as they are.

## 5. Tuxedo
- Use the same head-oval and bib fixes as calico (section 2).
- Legs and paws are fine: the socks follow the bone arc, and there is no flicker.

## 6. Pointed
**What is wrong now:** the face mask `lx>=2 and ly>=-4` is a hard vertical edge through the eye.

- **Face mask:** replace it with the oval `((lx-8)/6)^2+((ly-3)/5)^2<=1`.
- **Soft rim:** pixels with 1<val<=1.4 get TONE_DOWN only when their tone is base or shade.
- **Ears:** apply the points to the folded-ear pixels too (see section 0).
- **Body:** the TONE_UP on the body is fine.

## 7. Check after the fix
- Per-frame pattern pixel counts should follow L smoothly, with no frame-to-frame jump over 8%.
- Render `coat-*.png` and step through frames 4 to 6: no stripe or spot may disappear.
