# NPC 2.5D spec: field-mouse

Stage 1 (haiku spec). Source look: `game/assets/img/folk/sprite/folk-field-mouse-1.png` (64x96 cell, frame 1 idle; looks 2 and 3 from folk-field-mouse-2 and -3). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/field-mouse/field-mouse-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
Body plan: **biped (mammal)**. Helper: `draft_common.lua` `M.draw` (generic biped draft, the only helper in that file that fits).

## 1. Canvas
- Views: `front`, `back`, `side`. Side faces right; left-facing is a flip (see PATHWAY.md).
- Each file: 512x80 PNG, RGBA, 8 frames of 64x80, left to right.
- Frames 1-2: idle (2-frame breathe). Frames 3-8: walk (6-frame cycle, section 5).
- Background fully transparent. No backdrop disc.
- Hard pixels only (section 7).

## 2. Ground line and size (matches gnome25)
- Feet line: lowest opaque row = **y 71** in all 8 frames.
- Ground shadow: rows y 65-71, x 18-46, 2 tones `#aaa9b8` (light) and `#74758c` (shade), as `gnome25/front-shadow.png`. It keeps row 71 opaque, so airborne frames still pass.
- Head top: y 9 (frame 1), y 8 on frame 2 (breathe). Antenna, ear or eyestalk tips count as the head top; nothing goes above y 8.
- Max width: 40 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 9 to 71.

## 3. Palette (look 1 = as drawn; sampled from the folk sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Fur ramp: hi `#e0a46c`, base `#cf9450`, shade `#946048`, deep `#705446`.
- Overalls `#78b04c` hi, `#4a7c4c` base, `#2e4e46` deep.
- Straw hat `#e8c262` base, `#b48a4c` shade.
- Ears and nose `#e8a898`, belly cream `#f2dcba`.
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#cf9450`, accents as listed above.
- Look 2: folk-2 sampled `#a48a74` (fur), `#f2dcba` (belly), `#3e9ea0` (overalls), `#d4503e` (accent).
- Look 3: folk-3 sampled `#bf6c48` (fur), `#a88ad4` (overalls, lavender), `#f0dcc0`, `#f0b84a` (hat).
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - round ears with pink inner, two ink eyes, pink nose
  - straw hat with band; overall bib and straps
  - two front feet with two toes each; belly cream panel
- back:
  - round ears and tail base; no face
  - hat back with band; overall straps across the shoulders
  - two heel rows of feet
- side (right-facing):
  - snout forward on the right with nose tip; one ear, one eye
  - long tail trailing to the left, tip cream
  - overall front panel, one near leg, one far leg in shade
- Quirk (all views): wheat stalk: a 1x6 px stalk (`#b48a4c`) with a 3x3 px grain head (`#e8c262`), held in the near hand; in front view in the viewer's right hand. It follows body y on each frame and sways on x with the walk (section 5).

## 5. Animation tables
Offsets are in px. Body y: negative = up. Feet: 0 = sole on row 71, -2 = sole on row 69. Arms: + = forward, - = back (flyers: wing spread, + = wider).
Stage 2 reads each row as `{body, head, footL, footR, armL, armR}` (`N.offsets`).

### Idle (frames 1-2)
| frame | body y | head y | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base pose, head top y 9 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe, head top y 8 |

### Walk (frames 3-8, loops to 3)
Same six-frame biped cycle as the hedgehog.

| frame | body y | head y | feet L/R | arms L/R | step |
|---|---|---|---|---|---|
| 3 | 0 | 0 | 0 / -2 | 2 / -2 | L contact, R swings forward |
| 4 | -1 | -1 | 0 / -1 | 1 / -1 | L loaded, R lifting |
| 5 | -1 | -1 | -1 / 0 | 0 / 0 | L swings, R planted |
| 6 | 0 | 0 | -2 / 0 | -2 / 2 | R contact, L swings forward |
| 7 | -1 | -1 | -1 / 0 | -1 / 1 | R loaded, L lifting |
| 8 | -1 | -1 | 0 / -1 | 0 / 0 | R swings, L planted |

- Quirk follows body y on each frame.
- Every walk frame differs from every other walk frame and from both idle frames.

## 6. Acceptance checklist (stage 4 verifies)
- [ ] three files: `field-mouse-front.png`, `field-mouse-back.png`, `field-mouse-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 9, frame 2 at y 8, no frame above y 8
- [ ] width at idle frame 1 is 40 px or less in each view
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] quirk visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a field-mouse at 16 px.
