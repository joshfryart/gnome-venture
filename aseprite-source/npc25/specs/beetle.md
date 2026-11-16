# NPC 2.5D spec: beetle

Stage 1 (haiku spec). Source look: `game/assets/img/folk/sprite/folk-beetle-1.png` (64x96 cell, frame 1 idle; looks 2 and 3 from folk-beetle-2 and -3). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/beetle/beetle-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
Body plan: **six-legged**. Helper: none (`M.draw` is biped only): stage 2 writes this plan's `draw_figure` from section 5.

## 1. Canvas
- Views: `front`, `back`, `side`. Side faces right; left-facing is a flip (see PATHWAY.md).
- Each file: 512x80 PNG, RGBA, 8 frames of 64x80, left to right.
- Frames 1-2: idle (2-frame breathe). Frames 3-8: walk (6-frame cycle, section 5).
- Background fully transparent. No backdrop disc.
- Hard pixels only (section 7).

## 2. Ground line and size (matches gnome25)
- Feet line: lowest opaque row = **y 71** in all 8 frames.
- Ground shadow: rows y 65-71, x 18-46, 2 tones `#aaa9b8` (light) and `#74758c` (shade), as `gnome25/front-shadow.png`. It keeps row 71 opaque, so airborne frames still pass.
- Head top: y 8 (frame 1), y 7 on frame 2 (breathe). Antenna, ear or eyestalk tips count as the head top; nothing goes above y 7.
- Max width: 36 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 8 to 71.

## 3. Palette (look 1 = as drawn; sampled from the folk sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Shell ramp: hi `#4fae5a`, base `#4e7a5c`, shade `#36564f`, deep `#2c3646`.
- Hat straw `#e2b654` base, `#cfc278` hi, leaf band `#4fae5a`.
- Neckerchief `#e0584e` base, `#a83a4e` shade.
- Underside and legs `#b07c44` base, `#655c56` shade.
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#4e7a5c`, accents as listed above.
- Look 2: folk-2 sampled `#74484c`, `#4e9e8a`, `#c8743c`, `#d4a676`: shell and neckerchief as the folk-2 image.
- Look 3: folk-3 sampled `#5a4c86`, `#8a54b8` hi, `#e2627a`, cream `#eadab6`: shell violet, accent pink, hat cream.
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - two leaf-tip antennae (1 px stalk, leaf tip 3 px) rising from the head top
  - straw hat with leaf band; neckerchief under the chin
  - domed shell with centre line; two front legs with 1 px ink claws at the sides
- back:
  - full shell dome with centre line and two dark spots; no face
  - hat back with band; neckerchief tails at the nape
  - four leg tips visible at the shell edge
- side (right-facing):
  - head forward on the right with one antenna; shell profile
  - one near leg, one far leg (shade tone); neckerchief tail at the back
  - hat brim profile with leaf band
- Quirk (all views): tiny parcel: a 4x3 px wrapped brown parcel (`#b07c44` base, `#e0584e` ribbon) carried on the shell back; in front view it sits at the viewer's right shoulder. It follows body y on each frame and sways on x with the walk (section 5).

## 5. Animation tables
Offsets are in px. Body y: negative = up. Feet: 0 = sole on row 71, -2 = sole on row 69. Arms: + = forward, - = back (flyers: wing spread, + = wider).
Stage 2 reads each row as `{body, head, footL, footR, armL, armR}` (`N.offsets`).

### Idle (frames 1-2)
| frame | body y | head y | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base pose, head top y 8 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe, head top y 7 |

### Walk (frames 3-8, loops to 3)
Tripod gait: the legs move in two alternating tripods. Arms column = the two front legs.

| frame | body y | head y | feet L/R | arms L/R | step |
|---|---|---|---|---|---|
| 3 | 0 | 0 | 0 / -2 | 1 / -1 | tripod A planted, R front leg lifts |
| 4 | -1 | -1 | -1 / -1 | 0 / 0 | both tripods mid-stride, body lifts |
| 5 | -1 | -1 | -2 / 0 | -1 / 1 | L front leg lifts, R front plants |
| 6 | 0 | 0 | -1 / -1 | -1 / -1 | tripod B back-stroke, arms back |
| 7 | -1 | -1 | 0 / -2 | 0 / 0 | R front leg lifts, body rises |
| 8 | -1 | -1 | 0 / 0 | 1 / -1 | tripod B planted, L front reaches forward |

- Quirk follows body y on each frame.
- Every walk frame differs from every other walk frame and from both idle frames.

## 6. Acceptance checklist (stage 4 verifies)
- [ ] three files: `beetle-front.png`, `beetle-back.png`, `beetle-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 8, frame 2 at y 7, no frame above y 7
- [ ] width at idle frame 1 is 36 px or less in each view
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] quirk visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a beetle at 16 px.
