# HANDOFF: Gnome Venture "Hearth Pop" art rework (read this first)

Branch: `ccr-c4d6c653-u81tm0` (repo `joshfryart/gnome-venture`). Never push to main, no PRs unless Josh asks. Commit and push often (a stop hook demands it). Josh wants short, direct replies, exact facts, cost awareness, confirm before big spends.

## Who and how
- Josh Fry (joshfry.art). Judges art by eye. Opus draws, Sonnet writes Lua/support. Art tool: Aseprite 1.3.18 CLI + Lua.
- Style guide: `aseprite-source/art-style-guide-v3.md` (full), `aseprite-source/Gnome-Venture-Art-Guide-v3.pdf` (1 page-ish human version). Old Stitched Toy guide is deprecated.
- **Colour is NOT capped** (palette is a starting kit). Hard pixels, no semi-transparent, no pure black/white. 1px ink outline `#2b1c26`. Items slim (Josh said first pass was "thicc"), 5-6 tone ramps, material cues, one quirk each, every asset visually unique.
- **No fix round** from run 2 on (cost cut). Single Opus pass.

## What is DONE (all in `aseprite-source/v3/`)
- Lib: `lib/hp.lua`, `lib/hpx.lua` (per-pixel lighting), `lib/palette.lua`, `lib/contact.py`, `lib/README.md`.
- Examples (3 per section) + review sheets in `review/`: items, portraits (noses fixed), models (`models/`, gnome 10-layer recolour rig in `models/rig/`: `recolor.py`/`recolor.js`), scenes (`scenes/region-maplewold` rich redo, cottage, banner).
- Welcome flow: 11 assets in `welcome/`, `welcome-handoff.zip` (art, mockups, implementation brief for another dev/AI; already delivered), `review/welcome-art.html`.
- Items: `items/batch1` (18), `items/batch2` (9 crops+9 seeds), and **rollout run 1: 406 items in `items/final/<folder>/<name>.lua/.png/.aseprite`** (games/*, ico/ico-*, ph/acai .. ph/borer-plate). All 406 verified to have Opus art. Total items with Opus art: 536 (445 + 91 from run 2 part 1; see Run 2 status).
- Before/after PDF (all completed items, 13 pages): `aseprite-source/Hearth-Pop-Before-After.pdf` (rebuilt after run 1 completed). Live artifact sheet (older, examples only): https://claude.ai/artifact/6qFSyvbzNAW5YydtqdPKhM. Welcome artifact: https://claude.ai/artifact/TeeGQUndu848qZ1yn89tmy. Welbi application PDF was removed from the repo at Josh's request (still in git history).

## Run 2 status (verified by grepping each .lua for an Opus helper `_aB1`, 2026-11-03)
- **Part 1 (B1) is NOT finished: 91 of 140 have Opus art, 49 still hold only the Sonnet draft** (files exist, `check.py` passes, so existence proves nothing). The 49 are `ph/camellia-seed` through `ph/chestnut` (the tail of the list). The first run was stopped by Josh mid-way (run `wf_1b3cf197-7fc`) and committed as partial (`3d30faab`).
- **To finish:** Workflow, `scriptPath` `aseprite-source/v3/rollout/items-run.js`, args = `rollout/run2-part1-remaining.args.json` (tag `B1r`, `skipDraft: true`, 49 items, drafts already exist). Do not relaunch the full B1 args (it would redo the 91 finished items).
- A scheduled message (trigger `trig_014PhEg4fEWtRyUKeaZK5jBD`, 03:31 UTC Nov 4) is set to resume B1 with `resumeFromRunId`. If the container was reclaimed that cache is gone: use the remaining-args file instead. Delete the trigger if someone else finishes part 1 first.
- Parts 2 (B2) and 3 (B3) not started.

## What is NEXT (in order)
1. **Run 2, three parts** (part 1 is 91/140 done, see Run 2 status): `rollout/run2-part1.json|2|3` (140 each) with ready args `rollout/run2-partN.args.json` (tags B1,B2,B3). Launch with the Workflow tool: `scriptPath` = `aseprite-source/v3/rollout/items-run.js`, `args` = the file contents. Josh will assign parts to AIs; different parts can run in parallel (shared agent concurrency ~16). Sonnet drafts first (per 24-item chunk), then Opus in groups of 4, single pass, no fix round. Verify: `python3 aseprite-source/v3/rollout/check.py run2-part1.json` checks existence and size only; to prove Opus finished an item, grep its `.lua` for an Opus helper (`_aB...`; draft helpers are `_dB...`).
2. Runs 3 and 4: `rollout/run3.json` (420), `run4.json` (416); not split yet, same script.
3. Left out on purpose: `flowers/*` heads (tintable rig needed), `-anim` strips, odd-size UI (`items/`, `fx/`, `steps/`, `roadkinds/`, `ui/`), gather and craftmap scenes, creatures, mini, catfish, puzzles, the 82 portraits redo + 22 species portraits, `acts`, 13 regions, banners/homes/wonders/stages/tiers/trek tiles/landing.
4. Rebuild the before/after PDF and update the artifact sheet after each batch.
5. Game code is NOT changed anywhere. Wiring PNGs (and the welcome flow) into `game/` is separate; see `../../handoff-codechangesforart.md` and `welcome-handoff.zip`.

## How to run Aseprite
`/tmp/aseq/squashfs-root/AppRun -b --script-param out=<dir>/ --script file.lua`. If `/tmp/aseq` is missing (container restart): `mkdir -p /tmp/aseq && cp aseprite-source/Aseprite_1.3.18.6-x64.AppImage /tmp/aseq/ && cd /tmp/aseq && chmod +x *.AppImage && ./Aseprite_1.3.18.6-x64.AppImage --appimage-extract`.

## Cost and limits (measured)
- Batch 1 about 58k tokens/item (two passes), batch 2 about 71k/item (single pass with a fix round), run 1 about 70k/item. Remaining ~1,230 static items at 50-70k each = 60-85M tokens. Josh approved the rollout; still report cost per run.
- There is a 5-hour usage window. Run 1 hit it and 38 art groups failed (resumed later). Check failures in the workflow result (`failures`), never assume all agents finished. A container restart also kills background workflows; relaunch only the unfinished items (compute them, do not rerun everything).

## Pitfalls
- Workflow scripts cannot read files or `import`; pass item lists through `args`.
- Agents share the scratchpad: use own subfolders. One agent once ran `rm -f *.pA.aseprite` on a shared folder; tell agents never to delete shared files.
- Do not claim items are finished from file existence alone (drafts exist for all items before Opus runs).
- Commit even half-done work; the stop hook insists, and `git add -A aseprite-source`.

## Known weak spots (fix later, ask Josh first)
Seeds at 16 px read as blobs; ginseng seed leaf looks like cannabis; badger claw reads as a horn; hedgehog model reads like a messy-haired kid; gnome rig loses eye contrast on dark skin tones; before/after sheet compares different scenes for cottage/banner (old art differed).

## State files
`ROLLOUT-STATE.md` (run details), `specs.md` (original 12 example specs), `rollout/` (lists, script, checker).
