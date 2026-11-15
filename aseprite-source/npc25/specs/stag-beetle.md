# NPC 2.5D spec: stag-beetle

Stage 1 (haiku spec). Source look: `game/assets/img/sprite/npc-bracken-spurwing.png` (the NPC of this species, 4 frames 64x96; no folk art exists for stag-beetle, so colours are the NPC's). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/stag-beetle/stag-beetle-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
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
- Max width: 40 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 8 to 71.

## 3. Palette (look 1 = as drawn; sampled from the NPC sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Shell ramp: hi `#9a5f36`, base `#9a5f36`, shade `#64394a`, deep `#3d2438`.
- Jaw-antlers `#7cc35a` base, `#3f9150` shade.
- Shield `#e8493b` base, `#b52e3f` shade, rim `#aaa9b8`.
- Eyes cream `#fff4d6` with ink pupil.
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#9a5f36`, accents as listed above.
- Look 2: derived (no folk art): shell `#4a6e7a`, shade `#2a4450`, antlers `#c8a040`.
- Look 3: derived (no folk art): shell `#7a4a8a`, shade `#4a2a58`, antlers `#7cc35a`.
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - two jaw-antlers curving up from the head (green, 1 px ink edge)
  - chest plate with a centre line; two front legs with claws
  - shield on the chest (see quirk); eyes cream
- back:
  - shell dome with a split line; antler-jaws behind the head
  - two leg tips at the shell edge
  - no shield
- side (right-facing):
  - jaws forward on the right; head and eye on top
  - shell profile; one near leg, one far leg in shade
  - shield edge on the near side
- Quirk (all views): tiny shield: a 3x4 px red shield (`#e8493b`, shade `#b52e3f`, rim `#aaa9b8`, cream glint) carried on the near arm; in back view it is hidden. It follows body y on each frame and sways on x with the walk (section 5).

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
- [ ] three files: `stag-beetle-front.png`, `stag-beetle-back.png`, `stag-beetle-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 8, frame 2 at y 7, no frame above y 7
- [ ] width at idle frame 1 is 40 px or less in each view
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] quirk visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a stag-beetle at 16 px.
