# Handoff for AI-1: art packages P1, P2, P3 (2026-11-05)

Repo: joshfryart/gnome-venture. Art lives in `aseprite-source/v3/`. Plan: `claude/plan-art-AB.md`. Another AI (AI-2) does P4 and P7 (gather scenes, big pictures) in parallel: do not touch those. Catfish is excluded.

## Read first (in this order)
1. `aseprite-source/v3/HANDOFF.md`
2. `aseprite-source/v3/ROLLOUT-STATE.md`
3. `aseprite-source/art-style-guide-v3.md`
4. `aseprite-source/v3/lib/CHEATSHEET.md` and `lib/README.md`
5. `claude/todo-art-v3.md`

## Setup
Aseprite 1.3.18 CLI + Lua. If `/tmp/aseq` is missing:
`mkdir -p /tmp/aseq && cp aseprite-source/Aseprite_1.3.18.6-x64.AppImage /tmp/aseq/ && cd /tmp/aseq && chmod +x *.AppImage && ./Aseprite_1.3.18.6-x64.AppImage --appimage-extract`
Run: `/tmp/aseq/squashfs-root/AppRun -b --script-param out=<dir>/ --script file.lua`

## Style rules
Hard pixels, no semi-transparent pixels, no pure black or white. 1 px ink outline `#2b1c26`. Colour is not capped. Items slim, 5-6 tone ramps, material cues, one quirk each, every image visually unique. No human villagers anywhere. Single pass, no fix round. Model: Sonnet at medium effort.

## P1: redo 179 weak items + Ginseng Seed (180)
- List: `aseprite-source/v3/rollout/weak.txt` (one `folder/name` per line). Includes tiny/near-invisible seeds, look-alikes (tangelo~tangor, yerba-mate~yuzu), stage-* series, stone-wall-*, muddy materials. Each look-alike pair must differ at a glance.
- Ginseng Seed: leaf reads as cannabis. Redraw (e.g. forked three-prong root-crown leaf, rounded leaflets, red berry cluster). It has never been exported; old picture stays live until you do.
- Seeds: `rollout/items-seed.js` (hybrid, params only for `items/seedgen/seedgen.lua`, about 10k tokens each, groups of 12).
- Other 64x64: `rollout/items-lean.js` (no draft step, cheat sheet `lib/CHEATSHEET.md`, about 22-25k each, groups of 6).
- Do NOT use `items-run.js` with a draft step (45k per item).
- Workflow scripts cannot read files or import: pass item lists through `args`. Launch with the Workflow tool, only if Josh allows it. Otherwise use subagents in groups.
- When an item is fixed, remove its line from `weak.txt`.

## P2: flower heads (19 files)
12 shapes x 3 layers: `-petals` (neutral grey, to be tinted in game), `-centre`, full. Plus vase, jar, basket (back and front) and a packet. Needs the tintable rig: read `handoff-codechangesforart.md` section 4 first. It may need a small code change in `game/`. Keep it minimal and say exactly what you changed. Check how existing `game/assets/img/flowers/` files are named and sized, and match them.

## P3: odd-size UI (41)
`items/` 21, `fx/` 6, `steps/` 5, `roadkinds/` 5, `ui/` 4 under `game/assets/img/`. Keep each file's CURRENT pixel size and name. Check each size before drawing (`file` or PIL). Same style rules.

## Delivery for each package
1. Outputs in `aseprite-source/v3/...` as `.lua`, `.png`, `.aseprite`.
2. From `aseprite-source/v3`: `python3 rollout/export_game.py` (copies into `game/assets/img/...`; weak ones get a pink #ff2bd6 2 px border via `weak.txt`).
3. Do not claim an item is done from file existence alone: check that its Lua has the Opus/Sonnet marker and its PNG changed.
4. Put every new or changed PNG in a NEW zip in `upload-zips/` named `gnome-venture-images-v3-<package>-<date>.zip`, flat `<slug>.png` entries. Admin uploads (`uploads/items/<slug>.png`) beat `assets/img/ph/`, so the zip is how the art reaches the live site.
5. Add a CHANGELOG.md entry (list changed files or counts) and update `claude/todo-art-v3.md`.

## Rules
- Branch: new branch off main. Do not push to main. No PR unless Josh asks.
- Commit and push often. `git add -A aseprite-source` plus the game files you changed.
- Never delete shared files. Agents share the scratchpad: use your own subfolders.
- Report cost per package (tokens) and what failed. A container restart kills background workflows; relaunch only the unfinished items (compute them).
- Ask Josh before any big spend.
