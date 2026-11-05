# Art plan: todo-art-v3 sections A + B (catfish excluded). Proposed 2026-11-05

Read first for every package: `aseprite-source/v3/HANDOFF.md`, `ROLLOUT-STATE.md`, `aseprite-source/art-style-guide-v3.md`, `claude/todo-art-v3.md`.
Rules: no human villagers (creatures, or a gnome clearly unlike the player). Scenes = one Opus-medium pass, no fix rounds. Everything else Sonnet medium. Weak images get a pink 2 px border in the live copy (`rollout/weak.txt`, `rollout/export_game.py`).
After any package: run `python3 rollout/export_game.py` from `aseprite-source/v3`, add new/changed PNGs to a NEW upload zip in `upload-zips/` (Admin uploads in `uploads/items/<slug>.png` beat `assets/img/ph/`), list changed files in CHANGELOG.

## Step 0 (me or any AI, before everything): pilot
One big picture, one portrait, one 2.5D model with Sonnet medium. Blind-compare with existing art, record cost and quality in `ROLLOUT-STATE.md`. Decides the method for P5, P6, P7. (`rollout/items-misc.js` is the template.)

## Packages
| # | Package | Count | Method | Needs | Hand to another AI? |
|---|---|---|---|---|---|
| P1 | A: redo weak items + Ginseng Seed (fix leaf so it is not cannabis) | 179 + 1 | seeds: `items-seed.js` (~10k each); others: `items-lean.js` (~22-25k each). Remove line from `weak.txt` when fixed | none | YES, independent |
| P2 | B: flower heads (12 shapes x 3 layers: `-petals` neutral grey to tint, `-centre`, full; vase/jar/basket back+front; packet) | 19 files | new tintable rig | code change in `handoff-codechangesforart.md` section 4 (art + small code) | YES, independent |
| P3 | B: odd-size UI: `items/` 21, `fx/` 6, `steps/` 5, `roadkinds/` 5, `ui/` 4 | 41 | keep each file's current size, Sonnet medium | none | YES, independent |
| P4 | B: gather scenes 38. Craftmap 14: SKIP (replaced by the workshop picture) unless Josh says redraw | 38 | scene engine, one pass | none | YES, independent |
| P5 | A + B: creatures: fix hedgehog model, fix gnome rig eye contrast on dark skin, then `animals/` 36, `folk/` 11, `gnome/` 8, `mini/` 201 | 256 + 2 fixes | models first, then minis from them | Step 0 | Partly: do models first |
| P6 | B: portraits: 82 NPC (80x100) + 22 species. Apply no-human rule: redesign any human-looking one as a creature, keep name and mood | 104 | 3 passes for Opus version; test cost in Step 0 | Step 0 | YES, independent of P5 |
| P7 | B: big pictures: 13 regions (300x200 x6), banners, homes, wonders, stages, tiers, trek tiles, `landing/` 19, `map/` 11, `journal/` 14 | about 100+ (count files first) | scene engine, one pass | Step 0 | YES, split by folder |
| P8 | B: puzzles (12 GIFs, jigsaw sets) and `-anim` strips | 12 + strips | animation plan first | decision | LATER |
| P9 | B: acts (144x108) redraw | 1,667 | batch script | P5 + P6 final | LAST |

## Order
1. Step 0 pilot.
2. Parallel, no dependencies: P1, P2, P3, P4, P6, P7.
3. P5 (models before minis).
4. P8.
5. P9 only after P5 and P6 are final.

## Suggested split between two AIs
- AI-1 (cheap, items): P1, P2, P3.
- AI-2 (pictures): P4, P7.
- Me/other: Step 0, P6, P5, then P8, P9.

## Decisions for Josh
1. Craftmap 14: skip? (recommended)
2. Acts 1,667: redraw all, or only the ones in use?
3. Anim strips: wait for the animation plan?
4. Canvas for pictures: 480x270 still open.

## Rough cost (tokens, from measured numbers)
P1 about 3.5M. P3 about 1M. P2 about 0.5M. P4 about 5M (scenes 110-150k each). Others unmeasured until Step 0.
