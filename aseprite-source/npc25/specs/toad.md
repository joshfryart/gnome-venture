# NPC 2.5D spec: toad

Stage 1 (haiku spec). Source look: `game/assets/img/folk/sprite/folk-toad-1.png` (64x96 cell, frame 1 idle; looks 2 and 3 from folk-toad-2 and -3). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/toad/toad-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
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
- Max width: 38 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 9 to 71.

## 3. Palette (look 1 = as drawn; sampled from the folk sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Skin ramp: hi `#a3b85a`, base `#7f9a40`, shade `#566e44`, deep `#383c4e`.
- Overalls `#6c8aba` hi, `#4c5a8c` base, `#34365e` deep.
- Straw hat `#deb658` base, `#a87e44` shade.
- Warts `#c45230`; belly `#dcc47c`.
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#7f9a40`, accents as listed above.
- Look 2: folk-2 sampled `#b2884e` (skin), `#e0cc94` (belly), `#5c60aa` (overalls), `#b24c64`.
- Look 3: folk-3 sampled `#bc5e44` (skin), `#eedcb8` (belly), `#e8ba34` (accent), `#542a46`.
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - two gold eye bumps on the head top; wide mouth line; warts as 1 px dots
  - blue overall bib; straw hat with band
  - two front feet with three toes; throat bulge
- back:
  - back of the head with wart dots; overall straps
  - hat back with band
  - two folded hind legs at the sides
- side (right-facing):
  - big throat bulge on the right; one eye bump on top of the head
  - hind leg folded with the foot to the left
  - overall front; one far leg in shade
- Quirk (all views): mossy hat: a 5x3 px mound of moss (`#566e44` base, `#7f9a40` hi, two 1 px `#a87e44` pebbles) sitting on the head, in all views. It follows body y on each frame and sways on x with the walk (section 5).

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
- [ ] three files: `toad-front.png`, `toad-back.png`, `toad-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 9, frame 2 at y 8; walk frame 5 (apex or hover rise) may reach y 6, nothing higher
- [ ] width at idle frame 1 is 38 px or less in each view
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] quirk visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a toad at 16 px.
