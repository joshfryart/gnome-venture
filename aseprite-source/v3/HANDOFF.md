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
- Items: `items/batch1` (18), `items/batch2` (9 crops+9 seeds), and **rollout run 1: 406 items in `items/final/<folder>/<name>.lua/.png/.aseprite`** (games/*, ico/ico-*, ph/acai .. ph/borer-plate). All 406 verified to have Opus art. Total items with Opus art: 585 (445 + 140 from run 2 part 1).
- Before/after PDF (all completed items, 13 pages): `aseprite-source/Hearth-Pop-Before-After.pdf` (rebuilt after run 1 completed). Live artifact sheet (older, examples only): https://claude.ai/artifact/6qFSyvbzNAW5YydtqdPKhM. Welcome artifact: https://claude.ai/artifact/TeeGQUndu848qZ1yn89tmy. Welbi application PDF was removed from the repo at Josh's request (still in git history).

## Run 2 status (verified by grepping each .lua for an Opus helper `_aB1`, 2026-11-04)
- **Part 1 (B1) is DONE: 140 of 140 have Opus art, 0 draft-only**, `check.py` 0 missing 0 bad. Finished by the `B1r` re-run (49 items, 13 agents, 0 errors, ~1.5M subagent tokens, ~32 min).
- Weakest per the artists (fix later, ask Josh first): candied-chestnuts (low-contrast glaze), carnation-seed (small dark seeds), carob (bite quirk barely shows), cashew-seed (reads as hollow rings), cattleya-seed (muddled sprout base), champak-seed (muddy shell), cherry-seed (noisy leaf edge), chestnut (grub quirk faint).
- **Part 2 (B2) DONE: 140/140 Opus, 0 draft-only** (`ph/chestnut-seed` .. `ph/elderberry-seed`, grep `_aB2`; last 5 via `B2r`). **Part 3 (B3) DONE: 140/140 Opus, 0 draft-only** (`ph/ember-shell` .. `ph/grapefruit`, grep `_aB3`). **Run 2 is complete: 420/420.** Next: runs 3 and 4.
- **Run 3 part 2 (C2) DONE on branch `c2-01Qem`: 140/140 Opus (97 first pass `_aC2`, 43 via `C2r`), 0 draft-only** (`ph/lemon-cordial` .. `ph/nav-together`). Not yet merged into this branch; see `rollout/RUN3-PART2-NOTE.md`.

## What is NEXT (in order)
1. **Run 3 part 1 (C1) DONE 140/140 Opus (grep `_aC1`). **Run 3 part 3 (C3) DONE 140/140 Opus (grep `_aC3`).** Run 3 part 2 (C2) assigned to another AI on its own branch; run 4 (D1-D3) open.** **Runs 3 and 4 are split** (2026-11-04): `rollout/run3-part1|2|3.json` (140 each, `ph/grapefruit-marmalade` .. `ph/poi`, tags C1-C3) and `rollout/run4-part1|2|3.json` (139/139/138, `ph/poinsettia-seed` .. `ph/zinnia-seed`, tags D1-D3), ready args `rollout/runN-partM.args.json`. Launch each with the Workflow tool (scriptPath `aseprite-source/v3/rollout/items-run.js`, args = file contents), ~9M tokens each, ~50M total. Run 2 is DONE.
2. Remaining static ph items = run3 (420) + run4 (416) = 836; after that every static 64x64 item is done.
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
