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

## Run 3 part 3 (C3) status (2026-11-04)
DONE: 140/140 Opus-finished, 0 draft-only (grep `_aC3`; check.py 140 items, 0 missing, 0 bad). Run `wf_8f23d088-558`, 41 agents, ~4.9M subagent tokens, no failures. `ph/nav-town` .. `ph/poi`. Weak (agents' notes): nav-villagers (tunic reshaped, not re-viewed), noni (busy skin, ripe patch recoloured unchecked), oak-log (rings faint), okra-seed (blobby leaf), opening-day-bunting (only 32px tall, mushy weave), pea-seed (low contrast), pear (hard blush edge), peanut-toast (butter close to crust), periwinkle-seed (pod reads as a smile), picket-fence-tee (thin zipper-like branch), picket-fence-cross (overlap), pickled-lotus-root (reads as cookies), pigeon-pea (pod thin), pine-log (noisy bark), pluot-jam (22px jar), petunia-seed. Seeds at 16 px still blob-prone.

## Run 4: art step = Sonnet high (2026-11-04)
Josh's decision after the D1t test (3 items, ~215k tokens incl. draft): run 4 uses Sonnet high for the art step. `items-run.js` takes optional args `artModel` / `artEffort` (default opus). `run4-part1..3.args.json` already carry them. Markers: Sonnet-high art shows `_aD1`, `_aD2`, `_aD3` in the .lua just like Opus did, so the model is NOT recorded in the file: run 4 = all Sonnet high. D1 launched run `wf_50515a6a-c74`.
## Run 3 part 2 (C2) — 2026-11-04
Branch `c2-01Qem`. 140/140 Opus-finished (97 in C2, 43 in C2r after the 5-hour limit killed 12 art groups), 0 draft-only. ~4.9M subagent tokens total (3.6M + 1.3M). Note: `run3-part2.json` entries are `{folder,name}` objects. See `rollout/RUN3-PART2-NOTE.md`.
## Run 4 part 2 (D2) — 2026-11-04
Branch `d2-run4`. 139/139 done, 0 missing, 0 bad (`check.py`). Seeds D2s: 24/24 marker "seed D2s" (~130k tokens). Others D2o: 115/115 marker "lean D2o" (~1.64M tokens, 20 agents, 0 errors, ~20 min). Total ~1.77M subagent tokens. Sonnet, lower fidelity.
Weak seeds: snapdragon, snowdrop, strawberry (tiny/barely visible), starfruit (one seed), spring-adonis~spanish-broom and statice~stock (look alike), steppe-peony, sweet-potato (off-scrap, pale sprouts).
Weak others: silverfish-scales, silver-birch, sky-talon, snake-skin, snake-fang, sorrel, spider-silk, spotted-hide, stag-beetle-shell, stage-cover-2/4, stage-grain-1/3/4, stage-herb-3, stage-fruit-1, stage-nut-2/4, stage-spice-1, stage-tree-1/3, stage-tuber-1/2/4, stage-vegetable-2/4, starlight-hammock, starfruit, stone-wall (all stone-wall-* weak: sparse dark stonework), stone-path, stirrup-hoe, strawberry, sundial, sun-dried-tomatoes, stuffed-peppers-goat, tamarind, tamarind-drink, tallow-wax, sprinkler-can.

## Run 4 part 1 (D1) status (2026-11-04)
DONE: 139/139 art-step finished by Sonnet high (grep `_aD1`; check.py 139 items, 0 missing, 0 bad). Run `wf_50515a6a-c74`, 41 agents, 6.27M subagent tokens (~45k/item), no failures, one container restart? no. NOTE: this was MORE expensive than the Opus path (~35k/item): Sonnet high + draft step saved nothing. Cheaper paths measured: lean Sonnet medium no draft (D2o), hybrid seedgen (D2s ~10k/seed; D2 total ~1.77M for 139). Weak per artists: pomato-seed (blobs), pomegranate-seed (mushroom cap), puddle-hat, raccoon-pelt (tail hidden), reindeer-lichen (flat block), rhubarb-chutney (spoon reads as hook), rhododendron-seed, rosemary (soft needles), samphire-salad, salted-eggs, scorpion-plate (potato-like), scarab-shell, shiny-quartz.
## Run 4 part 3 (D3) — 2026-11-04
Branch `d3-run4`. 138/138 done. Seeds D3s 40/40 (~254k tokens), others D3o 98/98 (~1.44M tokens, 17 agents, 0 errors, ~22 min). Total ~1.69M. Sonnet, lower fidelity. Args: `rollout/run4-part3-seeds|others.args.json`.
Weak seeds: thyme, teff, tibetan-gentian, turnip, vanilla, vandaenopsis, wasabi, white-clover, wild-gardenia (tiny/invisible); wild-rice, winter-rye (dark); tangelo~tangor, yerba-mate~yuzu look alike.
Weak others: tomatillo, tomato, white-pelt, wasp-stinger, wind-harp, wing-dust, wing-scale-lantern, wind-chime, yogurt, yuzu, tortoise-scute, triticale, tide-shell, tide-bucket, tile-bark-path, titan-claw, thorn-fang, tool_shed-lantern/-1/-mossy, wild-rice, wild-strawberries, wattle-fence corner/end (charms barely visible).

## Review rule (2026-11-04)
Weak images get a bright pink (#ff2bd6) 2 px border in the live/wired copy only (see HANDOFF.md). Weak list `rollout/weak.txt` and the border step in `rollout/export_game.py` are done (2.4.98).
