# NPC 2.5D spec: frog

Stage 1 (haiku spec). Source look: `game/assets/img/folk/sprite/folk-frog-1.png` (64x96 cell, frame 1 idle; looks 2 and 3 from folk-frog-2 and -3). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/frog/frog-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
Body plan: **hopper**. Helper: none (`M.draw` is biped only): stage 2 writes this plan's `draw_figure` from section 5.

## 1. Canvas
- Views: `front`, `back`, `side`. Side faces right; left-facing is a flip (see PATHWAY.md).
- Each file: 512x80 PNG, RGBA, 8 frames of 64x80, left to right.
- Frames 1-2: idle (2-frame breathe). Frames 3-8: walk (6-frame cycle, section 5).
- Background fully transparent. No backdrop disc.
- Hard pixels only (section 7).

## 2. Ground line and size (matches gnome25)
- Feet line: lowest opaque row = **y 71** in all 8 frames.
- Ground shadow: rows y 65-71, x 18-46, 2 tones `#aaa9b8` (light) and `#74758c` (shade), as `gnome25/front-shadow.png`. It keeps row 71 opaque, so airborne frames still pass.
- Head top: y 9 (frame 1), y 8 on frame 2 (breathe). Antenna, ear or eyestalk tips count as the head top; nothing goes above y 8 (apex of the walk may reach y 6, section 6).
- Max width: 36 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 9 to 71.

## 3. Palette (look 1 = as drawn; sampled from the folk sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Skin ramp: hi `#b6d861`, base `#6fae3e`, shade `#3f7a4a`, deep `#2f4a4c`.
- Overalls `#c2573c` base, `#8a3a46` shade, `#5a2a3e` deep.
- Belly `#e6d38a`.
- Eyes cream `#fff4d6`, ink pupil.
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#6fae3e`, accents as listed above.
- Look 2: folk-2 sampled `#4fb0a8` (skin), `#9a7048` (overall accent), `#c8483e`, `#cfd8b8` (belly).
- Look 3: folk-3 sampled `#f07a3a` (skin), `#e4dcc8` (belly), `#b84a3e` (overalls), `#6a7ad0`.
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - wide mouth line, two round eyes on top of the head (bulge outline)
  - lily-pad hat on the head top (flat ellipse) with a pink petal
  - red overall bib; two front feet with three toes
- back:
  - back of the head and shoulders; overall straps
  - lily-pad back edge at the crown
  - two folded hind legs at the sides
- side (right-facing):
  - large hind leg folded up on the near side; head forward on the right
  - throat bulge; one eye bulge on top
  - lily-pad profile on the crown
- Quirk (all views): lily-pad hat: a 5x2 px green pad (`#b6d861` hi, `#3f7a4a` shade) with a 2x2 px pink petal (`#f5809f`) on the crown; sits on the crown in all views. It follows body y on each frame and sways on x with the walk (section 5).

## 5. Animation tables
Offsets are in px. Body y: negative = up. Feet: 0 = sole on row 71, -2 = sole on row 69. Arms: + = forward, - = back (flyers: wing spread, + = wider).
Stage 2 reads each row as `{body, head, footL, footR, armL, armR}` (`N.offsets`).

### Idle (frames 1-2)
| frame | body y | head y | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base pose, head top y 9 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe, head top y 8 |

### Walk (frames 3-8, loops to 3)
Hop cycle: crouch, launch, apex, descend, land, settle. Feet leave the ground in frames 4-6; the shadow keeps row 71 opaque.

| frame | body y | head y | feet L/R | arms L/R | step |
|---|---|---|---|---|---|
| 3 | 1 | 1 | 0 / 0 | -1 / -1 | crouch, load the hind legs |
| 4 | -2 | -2 | -2 / -2 | 1 / 1 | launch, feet leave the ground |
| 5 | -3 | -3 | -3 / -3 | 2 / 2 | apex, arms out |
| 6 | -1 | -1 | -1 / -1 | 1 / 1 | descend, feet reach for the ground |
| 7 | 0 | 0 | 0 / 0 | -2 / -2 | land, arms swing back |
| 8 | 0 | -1 | 0 / 0 | -1 / -1 | settle, head bobs |

- Quirk follows body y on each frame.
- Every walk frame differs from every other walk frame and from both idle frames.

## 6. Acceptance checklist (stage 4 verifies)
- [ ] three files: `frog-front.png`, `frog-back.png`, `frog-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 9, frame 2 at y 8; walk frame 5 (apex or hover rise) may reach y 6, nothing higher
- [ ] width at idle frame 1 is 36 px or less in each view
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] quirk visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a frog at 16 px.
