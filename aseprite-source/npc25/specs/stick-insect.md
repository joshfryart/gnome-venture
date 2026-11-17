# NPC 2.5D spec: stick-insect

Stage 1 (haiku spec). Source look: `game/assets/img/sprite/npc-old-twigg.png` (the NPC of this species, 4 frames 64x96; no folk art exists for stick-insect, so colours are the NPC's). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/stick-insect/stick-insect-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
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
- Head top: y 7 (frame 1), y 6 on frame 2 (breathe). Antenna, ear or eyestalk tips count as the head top; nothing goes above y 6.
- Max width: 34 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 7 to 71.

## 3. Palette (look 1 = as drawn; sampled from the NPC sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Body ramp: hi `#a88ae0`, base `#7f5cc4`, shade `#5c4196`, deep `#3f2c6a`.
- Face and hands `#9a6e48`.
- Bow and collar `#d9668a` base, `#a8496e` shade.
- Twig `#6e4a44`, leaves `#7cc35a`.
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#7f5cc4`, accents as listed above.
- Look 2: derived (no folk art): body `#5fae6a`, shade `#3f8050`, face `#9a6e48`.
- Look 3: derived (no folk art): body `#c8a040`, shade `#8a6a30`, face `#9a6e48`.
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - two long antennae (1 px) to y T; small ink eyes on a brown face
  - pink bow at the collar; long thin legs, two front pairs visible
  - no hat: the twig is worn on the head (see quirk)
- back:
  - long body segments as 1 px lines; twig-hat on the head top
  - pink bow between the shoulders
  - two leg tips at the feet line
- side (right-facing):
  - thin body; head forward on the right with an antenna
  - one near leg, one far leg in shade
  - twig held in front of the head
- Quirk (all views): twig-hat: a 5x3 px twig (`#6e4a44`) with two 2x1 px leaves (`#7cc35a`) set on the head top, in all views. It follows body y on each frame and sways on x with the walk (section 5).

## 5. Animation tables
Offsets are in px. Body y: negative = up. Feet: 0 = sole on row 71, -2 = sole on row 69. Arms: + = forward, - = back (flyers: wing spread, + = wider).
Stage 2 reads each row as `{body, head, footL, footR, armL, armR}` (`N.offsets`).

### Idle (frames 1-2)
| frame | body y | head y | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base pose, head top y 7 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe, head top y 6 |

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
- [ ] three files: `stick-insect-front.png`, `stick-insect-back.png`, `stick-insect-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 7, frame 2 at y 6, no frame above y 6
- [ ] width at idle frame 1 is 34 px or less in each view
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] quirk visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a stick-insect at 16 px.

## Redraw 2026-11-17
Stage 3 art redrawn (Opus) in `lib/species_stick-insect.lua` (`S.draw_figure`); old version in `stick-insect/before/`. New palette hexes added in `S.palette_list` for this redraw.
- Body: bright lilac slender body with a dashed dorsal stripe; sturdy 2 px limbs with knee knobs; clear hooded head with two antennae; shadow ellipse at the feet line.
- Front: tall narrow body, head and antennae at the top, forelegs folded down across the middle legs, legs splayed to the feet line.
- Side (right-facing): head forward on the right, body leaning with long bent legs under it, twig hat on the crown.
- Back: narrow tapering abdomen with dashed stripe, legs splayed either side, head and antennae on top.
- Palette hexes now used (`S.palette_list`): `#2b1c26`, `#c9b6f2`, `#a88ae0`, `#7f5cc4`, `#5c4196`, `#3f2c6a` (lilac ramp, light to deep), `#9a6e48` (face), `#d9668a`, `#a8496e` (pink accent), `#6e4a44` (bark), `#7cc35a` (leaf), `#aaa9b8`, `#74758c` (shadow).
- Quirk: twig hat on the crown, `S.quirk.hex` `#6e4a44`, 5x3, follows body y.
- Remaining weaknesses: thorax is busy where the forelegs cross the middle legs; the dashed stripe vanishes at 1x.
- Stage 2 results: tables S.ramps, S.palette_list, S.idle, S.walk, S.c, S.quirk present; S.T = 7 and S.W = 34 present in the `local S = {...}` header. Palette check: PASS, all 13 PNG colours in `S.palette_list`, none missing. `check.py stick-insect`: RESULT PASS.

## Round 2 plan
Fixes for the four weaknesses (first-pass implemented in `S.draw_figure`; before-state in `stick-insect/before-r2/`).
- Busy thorax (front/back): forelegs no longer fold across the middle legs. Shoulder (cx-3, y31) goes out to an elbow at (cx-8, y28) above the middle knee, then down-out to a short hand at (cx-11, y36) with a 2 px bark tip. Forelegs sit outside the body column and above the middle legs; nothing crosses the thorax.
- Boxed-in legs: knees tucked in, feet splayed. Middle pair hip (cx-3, y42), knee (cx-9, y38), foot cx-13. Rear pair hip y47, knee (cx-6, y43), foot cx-10. Lower legs slant about 4 px over 30 rows, giving an A-shaped stance. Side view: near middle foot x46 (knee +5), near rear foot x24 (knee -5), so lower legs slant fore and aft.
- Square knee knobs: knob is now 2 px on top (top-left pixel dropped) over 3 px, a rounded dome instead of a 3x2 block.
- Vanishing stripe: dashes are 3 on, 1 off, 2 px wide in `#3f2c6a` (deep) on the lilac body, front and back (down to y56); side uses `#5c4196` dashes 3 on, 2 off one column in from the back edge. Back view wing-case centre line shortened to a 3 px dark dash.
