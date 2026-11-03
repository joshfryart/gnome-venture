# Item rollout: state and how to resume (written 2026-11-03)

Guide: `../art-style-guide-v3.md`. Approved by Josh: rework all static 64x64 items (1,676 files), single Opus pass + one self-review fix round, Sonnet drafts the Lua first.

## Correction (2026-11-03 21:10 UTC)
Run 1 hit the 5-hour usage limit: 38 Opus groups (150 items, list in `rollout/run1-failed.json`) kept only their Sonnet DRAFT art (files exist but are draft quality). The before/after PDF `../Hearth-Pop-Before-After.pdf` shows those drafts as if final, so rebuild it after the re-run. A re-run (tag R, `skipDraft: true`, items from run1-failed.json) was started at 21:10 UTC. When it finishes, verify, commit, and rebuild the PDF. Beware: `check.py` only proves a file exists, not that Opus finished it.

## Done
- Examples and batches: `items/` (3), `items/batch1` (18, two passes), `items/batch2` (18 crops+seeds, single pass), `portraits/`, `models/` (+ `models/rig/`), `scenes/`, `welcome/` (11 assets), PDFs and review sheets.
- Rollout run 1 (406 items: `games/*`, `ico/*` up to ico-worm, `ph/acai` .. `ph/borer-plate`): files in `items/final/<folder>/<name>.lua/.png/.aseprite`. Check with `python3 rollout/check.py run1.json`.

## Not done (in order)
1. Verify run 1 (check.py, contact sheet, spot-check, fix failures by re-running single items).
2. Runs 2, 3, 4 = `rollout/run2.json` (420), `run3.json` (420), `run4.json` (416). Each file is a list of `{folder,name}`.
3. Left out on purpose, do later: `flowers/*` heads (need a tintable rig), `-anim` icon strips, odd-sized UI (`items/`, `fx/`, `steps/`, `roadkinds/`, `ui/`), gather and craftmap scenes, creatures, mini, catfish, puzzles, portraits (82+22), `acts`, banners/regions.
4. Update `review/sheet.html` and the artifact (https://claude.ai/artifact/6qFSyvbzNAW5YydtqdPKhM) with batches 1, 2 and the rollout.
5. Welcome flow: hand-off zip `welcome-handoff.zip` was delivered; artifact https://claude.ai/artifact/TeeGQUndu848qZ1yn89tmy.

## How to launch a run
Workflow tool, `scriptPath` = `aseprite-source/v3/rollout/items-run.js`, args `{"tag":"B","items":["ico/ico-x","ph/y", ...]}` (items = `folder/name` strings taken from the run JSON; use a new tag per run: B, C, D). Script (args.skipDraft=true skips the Sonnet stage when drafts already exist): Sonnet drafts per 24-item chunk, Opus finishes in groups of 4. Needs `/tmp/aseq/squashfs-root/AppRun` (extract `aseprite-source/Aseprite_1.3.18.6-x64.AppImage` with `--appimage-extract` into /tmp/aseq if /tmp was wiped). Concurrency about 16 agents; ~420 items per run is several hours. Resume a stopped run with `resumeFromRunId`.

## Measured cost
Batch 1: about 58k tokens per item (two passes). Batch 2: about 71k per item (single pass, seeds heavy). Full 1,676-item rollout is likely 90M+ tokens; run in the 5 hour windows and commit after each.

## Known weak spots to fix later
Seeds at 16 px reduce to a blob; ginseng seed leaf looks like cannabis; badger claw reads as a horn; hedgehog model looks like messy-haired kid; recolour rig loses eye contrast on dark skin.
