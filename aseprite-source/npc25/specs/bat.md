# NPC 2.5D spec: bat

Stage 1 (haiku spec). Source look: `game/assets/img/sprite/npc-gloam.png` (the NPC of this species, 4 frames 64x96; no folk art exists for bat, so colours are the NPC's). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/bat/bat-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
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
- Head top: y 7 (frame 1), y 6 on frame 2 (breathe). Antenna, ear or eyestalk tips count as the head top; nothing goes above y 6 (apex of the walk may reach y 4, section 6).
- Max width: 44 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 7 to 71.

## 3. Palette (look 1 = as drawn; sampled from the NPC sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Fur and wing ramp: hi `#c9b2f0`, base `#8a6fd0`, shade `#5a459e`, deep `#35295f`.
- Belly and pants `#f5b82e` base, `#d98322` shade.
- Cheeks `#f5809f`; wing membrane `#5a459e` with `#35295f` edge.
- Umbrella `#d98322`, shade `#8f4a1f`, handle `#aaa9b8`.
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#8a6fd0`, accents as listed above.
- Look 2: derived (no folk art): fur `#3f7a7a`, membrane `#2a4e56`, belly `#f0c060`.
- Look 3: derived (no folk art): fur `#a06a48`, membrane `#5a3c3c`, belly `#f5e0b0`.
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - two tall ears with ink outline and a lighter inner
  - wing membranes folded to both sides, scalloped edge
  - round face with two ink eyes and pink cheeks; yellow belly
- back:
  - ears from behind; folded wings as dark lobes
  - umbrella canopy over the shoulder, handle at the hand
  - two small feet at the bottom
- side (right-facing):
  - ear profile; wing edge swept back
  - umbrella carried forward in the near hand
  - one near foot, one far foot in shade
- Quirk (all views): umbrella: a closed 5x4 px umbrella (`#d98322` canopy, `#8f4a1f` shade, `#aaa9b8` handle) carried in the near hand; in back view it rests over the shoulder. It follows body y on each frame.

## 5. Animation tables
Offsets are in px. Body y: negative = up. Feet: 0 = sole on row 71, -2 = sole on row 69. Arms: + = forward, - = back (flyers: wing spread, + = wider).
Stage 2 reads each row as `{body, head, footL, footR, armL, armR}` (`N.offsets`).

### Idle (frames 1-2)
| frame | body y | head y | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base pose, head top y 7 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe, head top y 6 |

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
- [ ] three files: `bat-front.png`, `bat-back.png`, `bat-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 7, frame 2 at y 6; walk frame 5 (apex or hover rise) may reach y 4, nothing higher
- [ ] width at idle frame 1 is 44 px or less in each view
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] quirk visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a bat at 16 px.
