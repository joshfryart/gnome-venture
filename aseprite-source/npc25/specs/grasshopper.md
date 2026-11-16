# NPC 2.5D spec: grasshopper

Stage 1 (haiku spec). Source look: `game/assets/img/folk/sprite/folk-grasshopper-1.png` (64x96 cell, frame 1 idle; looks 2 and 3 from folk-grasshopper-2 and -3). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/grasshopper/grasshopper-{front,back,side}.png`. Stage 4 copies to `game/assets/img/npc25/`.
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
- Head top: y 7 (frame 1), y 6 on frame 2 (breathe). Antenna, ear or eyestalk tips count as the head top; nothing goes above y 6 (apex of the walk may reach y 4, section 6).
- Max width: 38 px on idle frame 1 in every view, wings, ears and antennae included.
- Figure height: y 7 to 71.

## 3. Palette (look 1 = as drawn; sampled from the folk sprite)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Body ramp: hi `#9ad55c`, base `#78bf48`, shade `#3f8a52`, deep `#3a3e6e`.
- Overalls blue `#6e8cc8` hi, `#4e62a0` base, `#3a3e6e` deep.
- Straw hat `#e4bc62` base, `#b98a48` shade.
- Wing-case stripe `#c08a4a`.
- Tint markers (for the scaffold): paint the body in rig marker greys `#f0f0f0` hi, `#b4b4b4` base, `#787878` shade, `#3c3c3c` deep. Accents keep their look-1 hexes. Map to a look at export.

### Looks (tint swaps)
- Look 1 (as drawn): body base `#78bf48`, accents as listed above.
- Look 2: folk-2 sampled `#c48e4c` (body), `#8e5e48`, `#8a4e8a` (accent), `#3eae9e`.
- Look 3: folk-3 sampled `#e888a6` (body), `#ac5a88`, `#e6dcc8`, `#ecb440` (hat).
- Ramps for each look: build hi/shade/deep from the base by the art guide section 4 recipe.

## 4. Per-view features (must be visible)
- front:
  - two long antennae (1 px) to y T; big eyes; hat with band
  - blue overall bib with two straps
  - long hind legs folded at the sides with knees out
- back:
  - green wing-case with a leaf shape at the centre
  - hat back with band; overall straps
  - hind leg tips at the sides
- side (right-facing):
  - big hind leg with the knee up; head forward on the right
  - one antenna; hat brim profile
  - overall front; one far leg in shade tone
- Quirk (all views): satchel: a 4x3 px satchel (`#c08a4a` base, `#7a5240` shade) with a 1 px strap across the chest; in side view it hangs off the far hip. It follows body y on each frame and sways on x with the walk (section 5).

## 5. Animation tables
Offsets are in px. Body y: negative = up. Feet: 0 = sole on row 71, -2 = sole on row 69. Arms: + = forward, - = back (flyers: wing spread, + = wider).
Stage 2 reads each row as `{body, head, footL, footR, armL, armR}` (`N.offsets`).

### Idle (frames 1-2)
| frame | body y | head y | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base pose, head top y 7 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe, head top y 6 |

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
- [ ] three files: `grasshopper-front.png`, `grasshopper-back.png`, `grasshopper-side.png`
- [ ] each is 512x80, RGBA, 8 frames of 64x80
- [ ] alpha only 0 or 255
- [ ] no `#000000`, no `#ffffff`
- [ ] outline `#2b1c26` present on every silhouette edge
- [ ] feet line: lowest opaque row = 71 in all 8 frames
- [ ] head top: idle frame 1 at y 7, frame 2 at y 6; walk frames 4-6 (launch, apex, descend; frame 5 is the apex) may reach y 4, nothing higher
- [ ] width at idle frame 1 is 38 px or less in each view
- [ ] each view non-empty in every frame
- [ ] frames 1 and 2 differ; frames 3-8 differ pairwise
- [ ] quirk visible in every view
- [ ] only palette colours from section 3 (look 1); other looks follow section 3 looks

## 7. Style rules (from `aseprite-source/art-style-guide-v3.md`)
- Hard pixels, no dither, no gradients, no semi-transparent pixels.
- 1 px outline `#2b1c26` outside only.
- Light from the upper left, one shade side (lower right).
- Keep the silhouette recognisable as a grasshopper at 16 px.
