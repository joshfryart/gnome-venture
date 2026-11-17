# NPC 2.5D spec: snail

Stage 1 (haiku spec). Source look: `game/assets/img/folk/sprite/folk-snail-1.png` (64x96 cell, frame 1 idle; looks 2 and 3 from folk-snail-2 and -3). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/snail/snail-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
Body plan: **crawler**. Helper: none (`M.draw` is biped only): stage 2 writes this plan's `draw_figure` from section 5.

## 1. Canvas
- Views: `front`, `back`, `side`. Side faces right; left-facing is a flip (see PATHWAY.md).
- Each file: 512x80 PNG, RGBA, 8 frames of 64x80, left to right.
- Frames 1-2: idle (2-frame breathe). Frames 3-8: walk (6-frame cycle, section 5).
- Background fully transparent. No backdrop disc.
- Hard pixels only (section 7).

## 2. Ground line and size (matches gnome25)
- Feet line: lowest opaque row = **y 71** in all 8 frames.
- Ground shadow: rows y 65-71, x 16-48, 2 tones `#aaa9b8` (light) and `#74758c` (shade), as `gnome25/front-shadow.png`. It keeps row 71 opaque, so airborne frames still pass.
- Head top: y 8 (frame 1), y 7 on frame 2 (breathe). Antenna, ear or eyestalk tips count as the head top; nothing goes above y 7.
- Max width: 44 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 8 to 71.

## 3. Palette (look 1 = as drawn; sampled from the folk sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Skin ramp: hi `#d2cb94`, base `#a09e6e`, shade `#726c60`, deep `#4a4256`.
- Shell `#d48e3e` base, `#9e5c3c` shade, `#5e3446` deep (spiral).
- Straw hat `#dab65c` base, scarf `#5ca24c`.
- Eyestalk tips ink with cream glint.
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#a09e6e`, accents as listed above.
- Look 2: folk-2 sampled `#aa98aa` (skin), `#aa6a40` (shell), `#d84c3c` (accent), `#efbe9c`.
- Look 3: folk-3 sampled `#dca272` (skin), `#a8705e` (shell), `#3caa90` (scarf), `#ecdab2`.
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - two eyestalks with ink eye tips, rising above the hat
  - shell spiral visible at the left edge; straw hat; green scarf
  - wide foot base at the feet line; no legs
- back:
  - shell dome with spiral line; satchel strap across it
  - hat back with band; scarf tails
  - wide foot base at the feet line
- side (right-facing):
  - shell spiral on the back (left), head with eyestalks forward on the right
  - foot underside long and flat at the feet line
  - scarf tail at the neck
- Quirk (all views): mail satchel: a 4x4 px brown satchel (`#9e5c3c` base, `#5e3446` shade, cream letter `#ecdab2`) on the shell with a 1 px strap; it moves with the shell. It follows body y on each frame and sways on x with the walk (section 5).

## 5. Animation tables
Offsets are in px. Body y: negative = up. Feet: 0 = sole on row 71, -2 = sole on row 69. Arms: + = forward, - = back (flyers: wing spread, + = wider).
Stage 2 reads each row as `{body, head, footL, footR, armL, armR}` (`N.offsets`).

### Idle (frames 1-2)
| frame | body y | head y | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base pose, head top y 8 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe, head top y 7 |

### Walk (frames 3-8, loops to 3)
Slow glide, no legs: the body squashes (body y +1) and stretches (body y 0). Feet stay 0/0 (one foot base). Arms column = eyestalk lean.

| frame | body y | head y | feet L/R | arms L/R | step |
|---|---|---|---|---|---|
| 3 | 0 | -1 | 0 / 0 | 1 / 0 | stretch, eyestalks lean forward |
| 4 | 1 | 0 | 0 / 0 | 0 / 0 | squash, body drops 1 px |
| 5 | 0 | -1 | 0 / 0 | -1 / 0 | stretch, eyestalks lean back |
| 6 | 1 | 0 | 0 / 0 | -1 / 1 | squash, eyestalks lean apart |
| 7 | 0 | -1 | 0 / 0 | 0 / 0 | stretch, eyestalks upright |
| 8 | 1 | 0 | 0 / 0 | 0 / 1 | squash, eyestalks lean the other way |

- Quirk follows body y on each frame.
- Every walk frame differs from every other walk frame and from both idle frames.

## 6. Acceptance checklist (stage 4 verifies)
- [ ] three files: `snail-front.png`, `snail-back.png`, `snail-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 8, frame 2 at y 7, no frame above y 7
- [ ] width at idle frame 1 is 44 px or less in each view
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] quirk visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a snail at 16 px.

## Redraw 2026-11-17
Stage 3 art redrawn (Opus) in `lib/species_snail.lua` (`S.draw_figure`); old version in `snail/before/`.
- Body: soft slug body on a frilled foot, flat wide base on the feet line; big spiral shell on the back.
- Front: shell spiral shows at the left edge, head with two eyestalks (ink tips, cream glint) rising above a straw hat with green scarf; satchel on the shell. Frame 1 face is small.
- Side (right-facing): large orange spiral shell on the back (left), head and eyestalk forward on the right, long flat foot, satchel strap and satchel on the shell, scarf tail at the neck.
- Back: round shell dome with spiral, two eyestalks above it, hat back and scarf tails, wide foot base.
- Palette hexes now used (`S.palette_list`, unchanged): `#2b1c26`, `#d2cb94`, `#a09e6e`, `#726c60`, `#4a4256`, `#d48e3e`, `#9e5c3c`, `#5e3446`, `#dab65c`, `#5ca24c`, `#ecdab2`, `#aaa9b8`, `#74758c` (`#aaa9b8` is listed but not used in the PNGs).
- Quirk: mail satchel, `S.quirk.hex` `#9e5c3c`, 4x4 on the shell, follows body y and sways with the walk.
- Remaining weaknesses: front face is small; hat brims are small at 1x.
- Stage 2 results: tables S.ramps, S.palette_list, S.idle, S.walk, S.c, S.quirk present; S.T = 8 and S.W = 44 present in the `local S = {...}` header. Palette check (all opaque PNG colours in `S.palette_list`): PASS, 12 of 13 listed colours used, none missing. `check.py snail`: RESULT PASS.

## Round 2 plan
Weaknesses: small front face, hard dark right edge on the front body mound, small hat brims at 1x.
- front face: head blob 10.5x7 -> 11.5x8 with soft shading; cream muzzle ellipse 4.2x2.2 -> 6.2x3.4 plus a 7 px cream highlight row; two nostril pixels (deep plum) and one chin dot instead of one nose; smile widened to 9 px (curl up at both ends); 2-px-tall rosy cheek patches at x +-7..9 so face fills the head.
- front body mound: `blob(..., soft=true)` - no `#4a4256` deep band, shade starts at light-dot 0.62 (was 0.5), light weights 0.7/0.55 (was 0.95/0.3) so the right edge is a base-to-shade gradient, not a dark wall. Same on the back view mound.
- hat brims: front brim rx 9.5 -> 13, crown 7 -> 8 wide, lifted 1 px; back brim 9.5 -> 12.5, crown 8; side brim 7.5 -> 9 (crown 7). Side kept at 9 because idle-1 width must stay <= 44.
- side face: unchanged this round (width budget); candidate for round 3.
- Status: first-pass code in `S.draw_figure`, `check.py snail` RESULT PASS. Backup in `snail/before-r2/`.

## Round 2 result (Opus)
- Front face: head 12x8.5, muzzle 6.6x3.9; cream glint upper left, 3 px plum nose, open 9 px smile with plum inside, cheeks at +-7..8. Head and face no longer crowd.
- Front/back body: stepped neck + mound replaced by one smooth bell (cylinder shading, shade band only, no deep wall); ground shadow narrowed to rx 16.5 (stray pixel gone).
- Hats: plum (`#5e3446`) contour behind brim and crown; brims front 14, back 13, side 9 (width budget 44). Front strap now runs across the chest to the satchel at the lower left.
- Still weak: side face small; front bell lower half is plain.
- `check.py snail`: RESULT PASS. PNGs copied to `game/assets/img/npc25/`.
