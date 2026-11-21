# Creature piece icons (GLM draft, 2026-11-21)

One 32x32 icon (plus 20x20 `-s`) per CREATURE piece in `game/includes/data/pf_creature_pieces.txt`, drawn as shape lists by `glm-5.3-flash:cloud` (Ollama), rendered by Aseprite. 246 of 264 done. NOT wired into the game; art is a draft (see `all_final.png`, `before_after.png`).

Files
- `out/ico-<slug>-<piece-name>.png / -s.png / .aseprite` (246 each). Key = creature slug + piece name, lowercased, dashes.
- `icons.jsonl` = final shape lists (after the thinking revise); `icons_v1.jsonl` = first try. Line: `{"key","motif","parts":[{shape rect|line|circle|tri,x,y,w,h,color}]}`.
- `input.txt` = what the model was asked (`key|piece|type|tag|creature|description`). `rejects.txt` = the 18 pieces with no icon (21 parts, bad coords, bad JSON, off-palette colour).
- `make_icons.lua` (`aseprite -b --script make_icons.lua`, reads `icons.jsonl`, writes `out/`; the 20px copy is the parts scaled 0.625 and rounded), `gen_icons.py [limit] [model]`, `revise.py [model]`, `run_all.sh` (whole pipeline).

Re-run
1. Copy `game/includes/data/creatures.txt` and `pf_creature_pieces.txt` next to the scripts (the scripts read them from the current folder). Needs Ollama running with `glm-5.3-flash:cloud` (signed in) and Python with Pillow.
2. `bash run_all.sh` (about 90 minutes: 4 parallel calls, thinking on for the revise).

Known weak spots: no 1px ink outline on many; type corner cue is inconsistent; some scattered shapes. 49 icons kept their first try (the revise failed validation 3 times).

## Opus hand-drawn pass (2026-11-21) — replaces the GLM drafts
All 264 pieces redrawn by hand as pixel grids (`mockup-opus/`). Final PNGs: `mockup-opus/all/ico-<slug>.png` (32px) and `-s.png` (20px), 528 files, sizes checked. Overview: `all_opus.png`. Per batch (`bNN/`): `grids/<slug>-32|20.txt` (one char per pixel), `make.py`, `sheet.png`; `batches/bNN.txt` are the input rows; `BRIEF.md` is the agent brief. Rebuild a batch: `cd mockup-opus/bNN && python3 make.py`. The 5 approved mockups sit in `mockup-opus/` itself (`mockup.py`). No `.aseprite` files (no Aseprite binary in the cloud env); convert with `aseprite -b in.png --save-as out.aseprite`. NOT wired into the game. The GLM `out/` is superseded.
Known weak spots (agents' own notes): hyena/monitor/sidewinder open-jaw heads read as dinosaur; several pieces lack a tag cue (evade/thorns/trip); a few 20px details get coarse (eyes, thin limbs).
