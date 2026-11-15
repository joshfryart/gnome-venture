# NPC 2.5D stage 3 batches (Opus)

Stage 2 scaffold is done: every species has a draft that passes `check.py`. Stage 3 replaces the draft with real art.

## What Opus replaces
Per species, in `aseprite-source/npc25/lib/species_<name>.lua`, replace **only** the function

```lua
function S.draw_figure(img, view, frame, species) ... end
```

It currently just calls the blocky draft `D.<plan>(img, view, frame, species)` (body-plan helper in `lib/draft_common.lua`). Keep the tables above it (`S.ramps`, `S.palette_list`, `S.idle`, `S.walk`, `S.c`, `S.quirk`, `S.T`, `S.W`) unless a spec is wrong. Do not edit `lib/npc25.lua`, `gen_draft.lua` or `check.py` rules.

Per species: `bash aseprite-source/npc25/run.sh <species>` generates `<species>/<species>-{front,back,side}.png` + `.aseprite` and runs `check.py` (must end `RESULT PASS`).

## Body-plan helpers (lib/draft_common.lua)
| plan | helper | species |
|---|---|---|
| biped (mammal) | `D.draw` | field-mouse, wood-mouse, shrew, mole, dormouse, gecko |
| hopper | `D.hopper` | cricket, frog, grasshopper, hare, toad |
| six-legged | `D.sixleg` | beetle, ladybird, stag-beetle, stick-insect |
| crawler | `D.crawler` | snail |
| flyer | `D.flyer` | bumblebee, butterfly, dragonfly, firefly, moth, wren, bat |

All helpers read the offsets with `N.offsets(species, frame)` = `{body, head, footL, footR, armL, armR}` (arms column = wing spread for flyers, front-leg shift for six-legged, eyestalk lean for the crawler). Reuse that, do not hard-code frames.

## Batches (function to replace: `S.draw_figure` in `lib/species_<name>.lua`)
1. Batch 1 (biped, `D.draw`): field-mouse, wood-mouse, shrew
2. Batch 2 (biped, `D.draw`): mole, dormouse, gecko
3. Batch 3 (hopper, `D.hopper`): cricket, frog, grasshopper
4. Batch 4 (hopper, `D.hopper`): hare, toad
5. Batch 5 (six-legged, `D.sixleg`): beetle, ladybird, stag-beetle
6. Batch 6 (six-legged `D.sixleg` + crawler `D.crawler`): stick-insect, snail
7. Batch 7 (flyer, `D.flyer`): bumblebee, butterfly, dragonfly
8. Batch 8 (flyer, `D.flyer`): firefly, moth, wren, bat

Files per batch, e.g. batch 3: `lib/species_cricket.lua`, `lib/species_frog.lua`, `lib/species_grasshopper.lua`.

## Rules the checker now enforces (read before drawing)
- 512x80, alpha 0/255 only, no `#000000`/`#ffffff`, outline `#2b1c26` present.
- Lowest opaque row 71 in all 8 frames (hoppers, six-legged and the snail keep the `#aaa9b8`/`#74758c` shadow; flyers hold row 71 with the dangling left foot).
- Head top (outline row included): idle f1 = T, f2 = T-1, never above T-1; hopper and flyer may reach T-3 on walk frames 4-6.
- Idle-1 width <= W; frames 1/2 differ; walk frames 3-8 pairwise differ; front/back/side differ.
- Non-legacy species only: every opaque colour must be in the species' `S.palette_list` (which already includes the outline and, where used, the two shadow tones; add a hex there if the art needs one the spec lists); every non-outline opaque pixel must have all four neighbours opaque (outline on every edge); the quirk's first colour (`S.quirk.hex`) must appear in every frame of every view (stag-beetle back is exempt, the shield is hidden).
