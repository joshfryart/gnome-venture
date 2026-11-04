# Item rollout: state and how to resume (written 2026-11-03)

Guide: `../art-style-guide-v3.md`. Approved by Josh: rework all static 64x64 items (1,676 files), single Opus pass, Sonnet drafts the Lua first. **From run 2 on there is NO fix round** (Josh's cost cut; runs 1 and the batches used one). Run 1 used the old prompt.

## Correction, RESOLVED (2026-11-03)
Run 1 is now fully done: all 406 items have Opus art (verified: every `.lua` references an Opus helper `_aA*`/`_aR*` in `items/final/_helpers/`). The text below is history.

### Original correction (21:10 UTC)
Run 1 hit the 5-hour usage limit: 38 Opus groups (150 items, list in `rollout/run1-failed.json`) kept only their Sonnet DRAFT art (files exist but are draft quality). The before/after PDF `../Hearth-Pop-Before-After.pdf` shows those drafts as if final, so rebuild it after the re-run. A re-run (tag R, `skipDraft: true`, items from run1-failed.json) was started at 21:10 UTC. When it finishes, verify, commit, and rebuild the PDF. Beware: `check.py` only proves a file exists, not that Opus finished it.

## Done
- Examples and batches: `items/` (3), `items/batch1` (18, two passes), `items/batch2` (18 crops+seeds, single pass), `portraits/`, `models/` (+ `models/rig/`), `scenes/`, `welcome/` (11 assets), PDFs and review sheets.
- Rollout run 1 (406 items: `games/*`, `ico/*` up to ico-worm, `ph/acai` .. `ph/borer-plate`): files in `items/final/<folder>/<name>.lua/.png/.aseprite`. Check with `python3 rollout/check.py run1.json`.

## Not done (in order)
1. Verify run 1 (check.py, contact sheet, spot-check, fix failures by re-running single items).
2. Run 2 (see the split below), then run 3 = `rollout/run3.json` (420), run 4 = `run4.json` (416). Run 3 and 4 use the same script and are not yet split. Each file is a list of `{folder,name}`.
3. Left out on purpose, do later: `flowers/*` heads (need a tintable rig), `-anim` icon strips, odd-sized UI (`items/`, `fx/`, `steps/`, `roadkinds/`, `ui/`), gather and craftmap scenes, creatures, mini, catfish, puzzles, portraits (82+22), `acts`, banners/regions.
4. Update `review/sheet.html` and the artifact (https://claude.ai/artifact/6qFSyvbzNAW5YydtqdPKhM) with batches 1, 2 and the rollout.
5. Welcome flow: hand-off zip `welcome-handoff.zip` was delivered; artifact https://claude.ai/artifact/TeeGQUndu848qZ1yn89tmy.

## How to launch a run
Workflow tool, `scriptPath` = `aseprite-source/v3/rollout/items-run.js`, args `{"tag":"B","items":["ico/ico-x","ph/y", ...]}` (items = `folder/name` strings taken from the run JSON; use a new tag per run: B, C, D). Script (args.skipDraft=true skips the Sonnet stage when drafts already exist): Sonnet drafts per 24-item chunk, Opus finishes in groups of 4. Needs `/tmp/aseq/squashfs-root/AppRun` (extract `aseprite-source/Aseprite_1.3.18.6-x64.AppImage` with `--appimage-extract` into /tmp/aseq if /tmp was wiped). Concurrency about 16 agents; ~420 items per run is several hours. Resume a stopped run with `resumeFromRunId`.

## Measured cost
Batch 1: about 58k tokens per item (two passes). Batch 2: about 71k per item (single pass, seeds heavy). Full 1,676-item rollout is likely 90M+ tokens; run in the 5 hour windows and commit after each.

## Known weak spots to fix later
Seeds at 16 px reduce to a blob; ginseng seed leaf looks like cannabis; badger claw reads as a horn; hedgehog model looks like messy-haired kid; recolour rig loses eye contrast on dark skin.

## Run 2 is split in 3 parts (2026-11-03)
`rollout/run2-part1.json`, `part2`, `part3` (140 items each). Ready-to-paste Workflow args: `rollout/run2-part1.args.json` (tag B1), `part2` (B2), `part3` (B3). Launch each with the Workflow tool, `scriptPath` = `aseprite-source/v3/rollout/items-run.js` (single Opus pass, NO fix round, Sonnet drafts first), args = the contents of the args file. Different AIs can take different parts in parallel (they write to different files; they share the concurrency limit). Verify with `python3 rollout/check.py run2-part1.json`.

## Run 2 part 1 status (2026-11-03)
## Run 2 part 1 DONE (2026-11-04)
140/140 Opus (`_aB1`), verified. Parts 2 and 3 also done (below). Run 2 complete: 420/420. See `HANDOFF.md`.

## Run 2 part 2 (B2) status (2026-11-04)
DONE: 140/140 Opus-finished, 0 draft-only (verified by grepping each .lua for `_aB2`; check.py 140 items, 0 missing, 0 bad). Main run (`wf_a33306ba-cfe`) was killed by a container restart with 135 done; the last 5 (egusi-soup, elder-pelt, elderberry, elderberry-cordial, elderberry-seed) were finished by relaunch tag `B2r`, `skipDraft`. Weak: elder-pelt (first render looked like a starfish, legs reshaped), elderberry-seed (seeds read as plain tan lumps, faint wrinkle texture; flat leaf top edge). Seeds at 16 px remain blob-prone.

## Run 2 part 3 (B3) status (2026-11-04)
DONE: 140/140 Opus-finished, 0 draft-only (grep `_aB3`; check.py 140 items, 0 missing, 0 bad). Run `wf_d47b4919-017`, 41 agents, ~5.0M subagent tokens, no failures. `ph/ember-shell` .. `ph/grapefruit`. Weak (agents' own notes): ember-spark (flat facets, faint core), ensete (muddy rings, stem like a leek), feast-dunewhisper-pilaf (rice vs platter hue), feast-egg-pie (small wedge), feast-isles-ackee-pot (pod reads as figure), feast-spicepeak-thali (katoris blend), finger-lime (pale rind), garden-gate-cross (busy), fox-fang (tangled thong), frost-fur (reads as tassel), frog-skin (boxy), ginseng (reads as cross), glory-bower-seed, gerbera-seed, fireweed-seed, flamboyant-seed. Seeds at 16 px still blob-prone.

## Runs 3 and 4 split (2026-11-04)
run3 -> `run3-part1..3` (140 each; tags C1,C2,C3; part1 starts `ph/grapefruit-marmalade`, part3 ends `ph/poi`). run4 -> `run4-part1..3` (139/139/138; tags D1,D2,D3; `ph/poinsettia-seed` .. `ph/zinnia-seed`). Args: `rollout/runN-partM.args.json`. Not started.

## Run 3 part 1 (C1) status (2026-11-04)
DONE: 140/140 Opus-finished, 0 draft-only (grep `_aC1`; check.py 140 items, 0 missing, 0 bad). Run `wf_8e03cf47-d65`, 41 agents, ~5.1M subagent tokens, no failures. `ph/grapefruit-marmalade` .. `ph/lemon`. Weak (agents' notes): gravel-path (busy pebbles), green-bean-seed, grilled-sardines (steam), hat-rootwarden (low contrast, roots like table legs), hazelnut (reads as acorn), hollowheart-tree (hollow reads as dark hole), holly-hedge (boxy), kangaroo-paw-seed (reads as chili), kava-seed, kiwi-seed (quirk blob), lavender-border-cross (wood on wood), leech-slime (leech too faint), lemming-fluff (stiff). Seeds at 16 px still blob-prone.
