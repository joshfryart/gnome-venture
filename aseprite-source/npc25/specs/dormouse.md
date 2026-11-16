# NPC 2.5D spec: dormouse

Stage 1 (haiku spec). Source look: `game/assets/img/sprite/npc-pomeroy-crumbworth.png` (the NPC of this species, 4 frames 64x96; no folk art exists for dormouse, so colours are the NPC's). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/dormouse/dormouse-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
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
- Max width: 38 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 9 to 71.

## 3. Palette (look 1 = as drawn; sampled from the NPC sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Fur ramp: hi `#c98a5c`, base `#b97a4a`, shade `#864c33`, deep `#51302b`.
- Waistcoat `#f5b82e` base, `#d98322` shade.
- Napkin and cream bib `#f3e2bf`.
- Cheeks `#f5809f`; nightcap `#c94f84` (quirk).
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#b97a4a`, accents as listed above.
- Look 2: derived (no folk art): fur `#8a8aa0`, waistcoat `#5ea8c0`, bib `#f3e2bf`.
- Look 3: derived (no folk art): fur `#b08060`, waistcoat `#9c84ca`, bib `#f3e2bf`.
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - round ears with pink inner; two ink eyes; pink cheeks
  - cream napkin tucked in at the collar; yellow waistcoat
  - two front feet with two toes each
- back:
  - round ears under the nightcap; no face
  - waistcoat straps across the shoulders
  - two heel rows of feet
- side (right-facing):
  - snout forward on the right; one ear; one eye
  - long tail trailing left, tip darker
  - waistcoat front; one near leg, one far leg in shade
- Quirk (all views): nightcap: a 4x4 px pink cap (`#c94f84` base, `#7d2c5e` shade) with a 2x2 px cream pompom (`#f3e2bf`) at the tip, sits on the ears in all views, tip falls to the viewer's right in front view. It follows body y on each frame and sways on x with the walk (section 5).

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
- [ ] three files: `dormouse-front.png`, `dormouse-back.png`, `dormouse-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 9, frame 2 at y 8, no frame above y 8
- [ ] width at idle frame 1 is 38 px or less in each view
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] quirk visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a dormouse at 16 px.
