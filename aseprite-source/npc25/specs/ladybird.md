# NPC 2.5D spec: ladybird

Stage 1 (haiku spec). Source look: `game/assets/img/folk/sprite/folk-ladybird-1.png` (64x96 cell, frame 1 idle; looks 2 and 3 from folk-ladybird-2 and -3). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/ladybird/ladybird-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
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
- Head top: y 9 (frame 1), y 8 on frame 2 (breathe). Antenna, ear or eyestalk tips count as the head top; nothing goes above y 8.
- Max width: 40 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 9 to 71.

## 3. Palette (look 1 = as drawn; sampled from the folk sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Wing-case ramp: hi `#e8584a`, base `#d93a30`, shade `#a52638`, deep `#7a2030`.
- Head `#4f4164` base, `#3d3150` shade, `#3a2c48` deep.
- Straw hat `#f0cc6a` base, `#c99a48` shade, band `#6aa84a`.
- Spots `#3d3150`; cream `#f4e2bc`.
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#d93a30`, accents as listed above.
- Look 2: folk-2 sampled `#5a78d0` (wing-cases), `#4f4164` (head), `#f2cf38` (hat), `#36b0a4`.
- Look 3: folk-3 sampled `#ec7a30` (wing-cases), `#3d3150` (head), `#a87cd8`, `#d6bfa0` (hat).
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - round head with two antennae with knobs; ink eyes
  - straw hat with green band; wing-cases split at a centre seam with spots
  - two front legs with 1 px claws
- back:
  - wing-case dome with centre seam and five spots per side
  - hat back with band; head edge at the top
  - two leg tips at the shell edge
- side (right-facing):
  - head forward on the right; one antenna with knob
  - wing-case profile with two spots
  - one near leg, one far leg in shade
- Quirk (all views): spotted umbrella bag: a 3x4 px red bag (`#d93a30`, spots `#3d3150`) with a 1 px handle, held by the far arm; in back view it hangs from the viewer's left shoulder. It follows body y on each frame and sways on x with the walk (section 5).

## 5. Animation tables
Offsets are in px. Body y: negative = up. Feet: 0 = sole on row 71, -2 = sole on row 69. Arms: + = forward, - = back (flyers: wing spread, + = wider).
Stage 2 reads each row as `{body, head, footL, footR, armL, armR}` (`N.offsets`).

### Idle (frames 1-2)
| frame | body y | head y | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base pose, head top y 9 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe, head top y 8 |

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
- [ ] three files: `ladybird-front.png`, `ladybird-back.png`, `ladybird-side.png`
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
- Keep the silhouette recognisable as a ladybird at 16 px.

## Redraw 2026-11-17
Stage 3 art redrawn (Opus) in `lib/species_ladybird.lua` (`S.draw_figure`); old version in `ladybird/before/`. New palette hexes added in `S.palette_list` for this redraw.
- Body: round red wing-case shell with dark spots, small dark rounded head, thin grey legs on a shadow ellipse, straw hat with green band.
- Front: head under the hat with two antennae, red shell wider than the head on both sides, legs and feet below, quirk (red) held at the side.
- Side (right-facing): large domed red shell on the left with spots, head with hat and antenna on the right, grey legs under.
- Back: split red wing cases with centre seam and spots, dark head under the hat, leg stubs at the sides.
- Palette hexes now used (`S.palette_list`): `#2b1c26`, `#e8584a`, `#d93a30`, `#a52638`, `#7a2030` (red ramp), `#4f4164`, `#3d3150`, `#3a2c48` (head and spots), `#f0cc6a`, `#c99a48` (straw), `#6aa84a` (hat band), `#f4e2bc` (cream), `#aaa9b8`, `#74758c` (shadow), `#6e6488`, `#9a90b4` (grey leg highlights).
- Quirk: red `#d93a30` 3x4 item at the hand anchor (`S.quirk.hex`), visible in every frame.
- Remaining weaknesses: the back-view head is a flat dark blob.
- Stage 2 results: tables S.ramps, S.palette_list, S.idle, S.walk, S.c, S.quirk present; S.T = 9 and S.W = 40 present in the `local S = {...}` header. Palette check: PASS, all 16 PNG colours in `S.palette_list`, none missing. `check.py ladybird`: RESULT PASS.
