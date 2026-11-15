# NPC 2.5D spec: moth

Stage 1 (haiku spec). Source look: `game/assets/img/folk/sprite/folk-moth-1.png` (64x96 cell, frame 1 idle; looks 2 and 3 from folk-moth-2 and -3). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/moth/moth-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
Body plan: **flyer**. Helper: none (`M.draw` is biped only): stage 2 writes this plan's `draw_figure` from section 5.

## 1. Canvas
- Views: `front`, `back`, `side`. Side faces right; left-facing is a flip (see PATHWAY.md).
- Each file: 512x80 PNG, RGBA, 8 frames of 64x80, left to right.
- Frames 1-2: idle (2-frame breathe). Frames 3-8: walk (6-frame cycle, section 5).
- Background fully transparent. No backdrop disc.
- Hard pixels only (section 7).

## 2. Ground line and size (matches gnome25)
- Feet line: lowest opaque row = **y 71** in all 8 frames.
- Ground shadow: none (shadow-free float). The dangling left foot (fixed at 0) holds row 71 in all 8 frames.
- Head top: y 8 (frame 1), y 7 on frame 2 (breathe). Antenna, ear or eyestalk tips count as the head top; nothing goes above y 7 (apex of the walk may reach y 5, section 6).
- Max width: 42 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 8 to 71.

## 3. Palette (look 1 = as drawn; sampled from the folk sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Wing ramp: hi `#d6e3a2`, base `#bcd694`, shade `#98d69a`, deep `#62a894`.
- Body and overalls `#5c78ac` hi, `#435488` base, `#2f3a62` deep.
- Straw hat `#e2b65e` base, `#b27e4a` shade.
- Head `#ece6bc`; feather antennae `#b27e4a`.
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#bcd694`, accents as listed above.
- Look 2: folk-2 sampled `#f4cc5c` (wings), `#e884a4` (wings), `#73689a` (body), `#44a8a2`.
- Look 3: folk-3 sampled `#c0663e` (body), `#eedcb8` (wings), `#9c84ca`, `#ecc48c`.
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - head with two feather antennae (1 px stalk with 2 px feathers)
  - forewings raised behind the shoulders, pale green with a 1 px edge
  - hat with band; overall bib; two thin front legs
- back:
  - full wing span with a light vein pattern (widest view)
  - hat back with band; body centre line
  - two thin leg tips under the body
- side (right-facing):
  - head forward on the right; one feather antenna
  - one forewing up, hindwing in shade
  - overall front; one near leg
- Quirk (all views): lantern shade: a 4x3 px cream shade (`#ece6bc`, rim `#e2b65e`) on a 1 px wire, carried in the near hand; in front view it hangs at the viewer's left hand. It follows body y on each frame.

## 5. Animation tables
Offsets are in px. Body y: negative = up. Feet: 0 = sole on row 71, -2 = sole on row 69. Arms: + = forward, - = back (flyers: wing spread, + = wider).
Stage 2 reads each row as `{body, head, footL, footR, armL, armR}` (`N.offsets`).

### Idle (frames 1-2)
| frame | body y | head y | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base pose, head top y 8 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe, head top y 7 |

### Walk (frames 3-8, loops to 3)
Wing flap on all six walk frames. Arms column = wing spread (+ wider). Hover bob 1-2 px via body y. Left foot is the dangling foot and stays 0; the right foot sways.

| frame | body y | head y | feet L/R | arms L/R | step |
|---|---|---|---|---|---|
| 3 | 0 | 0 | 0 / 0 | 2 / 2 | wings open, hover level |
| 4 | -1 | -1 | 0 / -1 | 1 / 1 | wings coming down |
| 5 | -2 | -2 | 0 / -1 | -1 / -1 | wings closed, body rises 2 px |
| 6 | -1 | -1 | 0 / -2 | 0 / 0 | wings half open, dangling foot swings |
| 7 | 0 | 0 | 0 / -1 | 2 / 2 | wings open again |
| 8 | -1 | -1 | 0 / 0 | 1 / 1 | wings coming down, body bobs |

- Quirk follows body y on each frame. Wing and dangling-foot rules as above.
- Every walk frame differs from every other walk frame and from both idle frames.

## 6. Acceptance checklist (stage 4 verifies)
- [ ] three files: `moth-front.png`, `moth-back.png`, `moth-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 8, frame 2 at y 7; walk frame 5 (apex or hover rise) may reach y 5, nothing higher
- [ ] width at idle frame 1 is 42 px or less in each view
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] quirk visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a moth at 16 px.
