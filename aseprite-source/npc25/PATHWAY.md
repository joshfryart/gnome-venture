# NPC 2.5D pathway

Goal: village NPCs get walk sprites in the same 2.5D format as the player gnome (`game/assets/img/gnome25/`). One species at a time, four stages, each stage a different model.

## 1. Stages
| stage | model | does | writes |
|---|---|---|---|
| 1. spec | haiku | writes the species spec (canvas, ground line, palette, looks, per-view features, quirk, walk and idle tables, checklist) | `aseprite-source/npc25/specs/<species>.md` |
| 2. scaffold | sonnet | writes the shared Lua library, the checker and the generator for a species | `aseprite-source/npc25/lib/npc25.lua`, `aseprite-source/npc25/check.py`, `aseprite-source/npc25/gen/<species>.lua` |
| 3. art | opus | draws the final pixel art from the spec, two passes (form, then polish) | `aseprite-source/npc25/<species>/` |
| 4. check | haiku | runs `check.py` on the finished PNGs and writes the report | `aseprite-source/npc25/<species>/CHECK.md` |

Stage 1 and stage 2 produce text and scripts only. Stage 3 is the only stage that draws pixels.

## 2. File naming
- Spec: `aseprite-source/npc25/specs/<species>.md` (lowercase, hyphenated: `wood-mouse`).
- Source: `aseprite-source/npc25/<species>/<species>-<view>.lua` (generator output), `.aseprite` (the editable file).
- Pass A (form): `<species>-<view>.pA.lua` and `.pA.png`.
- Final: `aseprite-source/npc25/<species>/<species>-<view>.png`, plus `.aseprite`.
- Views: `front`, `back`, `side` (3 files per species).
- Stage 4 output: `aseprite-source/npc25/<species>/CHECK.md` (PASS or FAIL per checklist item, with the failing values).

## 3. Copy to the game (after CHECK.md says PASS)
- Copy each final PNG to `game/assets/img/npc25/<species>-<view>.png`. Example: `game/assets/img/npc25/hedgehog-front.png`.
- Copy only PNGs. Do not copy `.lua`, `.pA.*` or `.aseprite`.
- Do not change `game/` PHP in this pathway. Wiring the strips into the game is a separate task.

## 4. Species order
The 21 species are the names in `game/assets/img/folk/sprite/folk-<species>-<n>.png`. Done first: hedgehog, tortoise. The other 19, in batch order:
1. Batch 1 (small mammals, same body plan as the hedgehog): field-mouse, wood-mouse, shrew, mole
2. Batch 2 (small mammals and amphibians): hare, frog, toad, gecko
3. Batch 3 (insects): beetle, ladybird, cricket, grasshopper
4. Batch 4 (flyers and slow movers): bumblebee, butterfly, moth, dragonfly, firefly, wren, snail

Work one species per stage-1 to stage-4 run. Batch 1 can reuse the stage-2 scripts; re-run stage 2 only if `npc25.lua` needs a change.

## 5. Rules for every stage
- Canvas, frame count and feet line are fixed (512x80, 8 frames of 64x80, feet y 71). See any spec.
- Frames 1-2 idle, 3-8 walk. The same cycle for every species.
- Hard pixels, 1 px `#2b1c26` outline, no pure black or white (`aseprite-source/art-style-guide-v3.md` section 7).
- Each species has one quirk, named in its spec.
