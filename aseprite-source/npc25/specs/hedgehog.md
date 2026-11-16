# NPC 2.5D spec: hedgehog

Stage 1 (haiku spec). Source look: `game/assets/img/folk/sprite/folk-hedgehog-1.png` (64x96 cell, frame 1 idle). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/hedgehog/hedgehog-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.

## 1. Canvas
- Views: `front`, `back`, `side`. Side faces right; left-facing is a flip (see PATHWAY.md).
- Each file: 512x80 PNG, RGBA, 8 frames of 64x80, left to right.
- Frames 1-2: idle (2-frame breathe). Frames 3-8: walk (6-frame cycle, section 5).
- Background fully transparent. No backdrop disc, no shadow outside the drawn ground shadow.
- Hard pixels only (section 7).

## 2. Ground line and size (matches gnome25)
- Feet line: lowest opaque row of the feet = **y 71** in all 8 frames (gnome outline bbox bottom is 72, exclusive).
- Ground shadow: rows y 65-72, x 18-46, 2 tones `#aaa9b8` (light) and `#74758c` (shade). Same as `gnome25/front-shadow.png`.
- Head top: y 9 (frame 1), y 8 on frame 2 (breathe). Spines may reach y 8 in any frame, never higher.
- Max width: 40 px (x 12-51) on idle frame 1, spines included.
- Figure height: y 9 to 71 (63 px).

## 3. Palette (look 1 = as drawn; sampled from the folk sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Fur ramp (spines): hi `#d89a5c`, base `#8f5f3a`, shade `#5e3a35`, deep `#3d2532`.
- Skin ramp (face, belly, ears, pads): hi `#f0d8a8`, base `#e0b986`, shade `#b38469`, deep `#7d5763`.
- Straw hat: hi `#ffe38a`, base `#e0b453`, shade `#d89a5c`. Hat band: `#6188bc`.
- Vest: base `#6a9a48`, shade `#46704a`, deep `#2f4a42`.
- Lantern: gold base `#f5b82e`, hi `#ffe38a`, metal `#aaa9b8`. Flame: cream `#fff4d6`.
- Nose tip: `#3d2532`, 1 px cream glint `#fff4d6`. Eye: 2x3 ink pill with 1 px cream glint.
- Cheek (optional): 2x1 petal `#f5809f`.
- Tint markers (for the scaffold): paint fur, vest and hat in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): fur base `#8f5f3a`, vest `#6a9a48`, hat `#e0b453`, band `#6188bc`.
- Look 2: fur base `#54465a`, fur shade `#372c40`, fur deep `#241a2a` (derived), vest base `#5d74a8`, accent `#3f9e9c`, hat `#cdb07e`.
- Look 3: fur hi `#d69c3a`, fur base `#a06a48`, fur shade `#6a3f2e`, fur deep `#46283a`, vest base `#d0503e`, hat `#ecdcb8`.
- Skin is the same in all looks. Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - face: 2 eye pills, nose tip centred, 2 skin ears at the head sides
  - spine fringe on head top and sides
  - hat with band
  - vest straps and bib
  - two front feet with 2 toes each
  - lantern on the belt, viewer's right
- back:
  - full spine dome, no face
  - hat back with band
  - vest straps across the shoulders
  - two heel rows of feet
  - lantern on the belt, viewer's left
- side (right-facing):
  - snout pointing right with nose tip, one eye, one ear
  - spine line from neck to rump (3-4 spine bumps on the back edge)
  - hat brim profile
  - vest and one near leg, one far leg (far leg in shade tone)
  - lantern on the belt, near side
- Quirk (all views): a tiny gold lantern on the belt, 3x4 px including outline, one cream flame pixel. It sways with the walk (section 5).

## 5. Animation tables
Offsets are in px. Body y: negative = up. Foot y: 0 = sole on row 71, -2 = sole on row 69. Arm x: + = forward (hand moves toward the facing direction), - = back. Lantern follows body y and sways on x by the same sign as the arm on its side.

### Idle (frames 1-2)
| frame | body y | head y | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base pose, head top y 9 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | chest up, head top y 8, spines lift 1 px |

### Walk (frames 3-8, loops to 3)
| frame | body y | feet L/R | arms L/R | step |
|---|---|---|---|---|
| 3 | 0 | 0 / -2 | +2 / -2 | L contact, R swings forward |
| 4 | -1 | 0 / -1 | +1 / -1 | L loaded, R lifting |
| 5 | -1 | -1 / 0 | 0 / 0 | L swings, R planted |
| 6 | 0 | -2 / 0 | -2 / +2 | R contact, L swings forward |
| 7 | -1 | -1 / 0 | -1 / +1 | R loaded, L lifting |
| 8 | -1 | 0 / -1 | 0 / 0 | R swings, L planted |

- Spines and lantern follow body y on each frame.
- Every walk frame must differ from every other walk frame and from both idle frames.

## 6. Acceptance checklist (stage 4 verifies)
- [ ] three files: `hedgehog-front.png`, `hedgehog-back.png`, `hedgehog-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 9, frame 2 at y 8, no frame above y 8
- [ ] width at idle frame 1 is 40 px or less
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] lantern visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a hedgehog at 16 px.
