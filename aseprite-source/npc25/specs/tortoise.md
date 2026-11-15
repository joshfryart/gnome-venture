# NPC 2.5D spec: tortoise

Stage 1 (haiku spec). Source look: `game/assets/img/folk/sprite/folk-tortoise-1.png` (64x96 cell, frame 1 idle). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/tortoise/tortoise-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.

## 1. Canvas
- Views: `front`, `back`, `side`. Side faces right; left-facing is a flip (see PATHWAY.md).
- Each file: 512x80 PNG, RGBA, 8 frames of 64x80, left to right.
- Frames 1-2: idle (2-frame breathe). Frames 3-8: walk (6-frame cycle, section 5).
- Background fully transparent. No backdrop disc.
- Hard pixels only (section 7).

## 2. Ground line and size (matches gnome25)
- Feet line: lowest opaque row of the feet = **y 71** in all 8 frames.
- Ground shadow: rows y 65-72, x 18-46, 2 tones `#aaa9b8` and `#74758c` (same as `gnome25/front-shadow.png`).
- Head top: y 10 (frame 1), y 9 on frame 2 (breathe). Hat brim is the highest point of the head.
- Max width: 44 px (x 10-53) on idle frame 1, shell included. The shell is the widest part.
- Figure height: y 9 to 71 (63 px).

## 3. Palette (look 1 = as drawn; sampled from the folk sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Skin ramp (head, arms, legs): hi `#78b04e`, base `#93a666`, shade `#667a52`, deep `#434d4a`.
- Shell ramp: hi `#b28c4e`, base `#c07d3c`, shade `#8a5236`, deep `#57343c`. Scute lines in shade; rim band in deep.
- Straw hat: hi `#e4c26c`, base `#dcbc72`. Hat band: `#78b04e`, leaf sprig `#6a9a48`.
- Overalls: base `#6188bc`, shade `#465c92`, deep `#323c66`. Bib strap: `#dcbc72`.
- Eyes: cream `#fff4d6` with 1 px ink pupil. Mouth: 1 px ink line.
- Cheeks: 2x1 petal `#f5809f`.
- Flowerpot (quirk): base `#d6693e`, shade `#8a5236`, deep `#57343c`. Sprout `#78b04e`, petal `#f5809f`.
- Tint markers (for the scaffold): paint skin in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Shell gets its own markers, separate from skin. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): skin base `#93a666`, shell base `#c07d3c`, overalls `#6188bc`, hat `#dcbc72`.
- Look 2: skin base `#86a096`, shell base `#8e64a4` (ramps from the art guide recipe), accent `#cc4a4c` (bib and hat band), hat `#c8b884`, overalls `#5b7272` (derived).
- Look 3: skin base `#c4a068`, shell base `#d6693e`, shell shade `#8f6e50`, accent `#ece0c4` (cream), overall deep `#432e34`. Role of `#c4a068` and `#ece0c4` is unverified (check by eye).
- Skin and eyes stay the same in all looks, except the skin base swap.

## 4. Per-view features (must be visible)
- front:
  - face: 2 cream eyes, mouth line, 2 petal cheeks
  - shell edges visible beside the arms and above the shoulders
  - straw hat with leaf band
  - overall bib and both straps
  - 4 short legs (2 visible per side), claws as 1 px ink
- back:
  - full shell dome, scute grid (1 centre scute, 4 ring scutes), deep rim band
  - hat back with band and leaf sprig
  - overall straps across the shoulders
  - 2 rear legs, feet pointing outward
- side (right-facing):
  - shell profile with the dome and rim band
  - head forward on the right, one eye, mouth line, one cheek
  - hat brim profile with leaf band
  - bib strap, one near leg, one far leg (far leg in shade tone)
- Quirk (all views): a tiny terracotta flowerpot with a sprout, 4x4 px including outline, sitting on top of the shell. In front view it peeks above the shoulder. In side and back views it sits on the dome. It sways with body y.

## 5. Animation tables
Offsets are in px. Body y: negative = up. Foot y: 0 = sole on row 71, -2 = sole on row 69. Arm x: + = forward, - = back. The flowerpot follows body y.

### Idle (frames 1-2)
| frame | body y | head y | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base pose, head top y 10 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | shell and head rise 1 px, head top y 9 |

### Walk (frames 3-8, loops to 3)
A tortoise walks slower than the hedgehog. Keep the same six frames, but with small arm swing.

| frame | body y | feet L/R | arms L/R | step |
|---|---|---|---|---|
| 3 | 0 | 0 / -2 | +1 / -1 | L contact, R swings forward |
| 4 | -1 | 0 / -1 | 0 / 0 | L loaded, R lifting |
| 5 | -1 | -1 / 0 | -1 / +1 | L swings, R planted |
| 6 | 0 | -2 / 0 | -1 / +1 | R contact, L swings forward |
| 7 | -1 | 0 / -1 | 0 / 0 | R loaded, L lifting |
| 8 | -1 | -1 / 0 | +1 / -1 | R swings, L planted |

- Shell and flowerpot follow body y on each frame, with the sprout sway of 1 px on x on frame 5 and frame 8.
- Every walk frame must differ from every other walk frame and from both idle frames.

## 6. Acceptance checklist (stage 4 verifies)
- [ ] three files: `tortoise-front.png`, `tortoise-back.png`, `tortoise-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 10, frame 2 at y 9, no frame above y 9 except the flowerpot sprout (y 7 max)
- [ ] width at idle frame 1 is 44 px or less
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] flowerpot visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a tortoise at 16 px (the dome is the cue).
