# Places pals plan: 81 Places x 6 = 486 pals (2.0.88 to 2.0.90, Joshua 2026-10-28)
Extends `claude/plan-puzzle-pals.md`. Pals for the 14 gallery pictures are done or in progress (rosters in `puzzle_pals.txt`, art by Opus via `aseprite-source/pals/`). This covers the 81 Places pictures (`game/assets/img/jigsaw/places/`, 360x240 file px, Advanced piece 30x30 file px).

## 0. Facts
| Kind | Count | Style (`PPAL_KIND_STYLE`) |
|---|---|---|
| haven | 18 | hearth folk, round knobs |
| wonder | 35 | sprites, keyhole knobs |
| delve | 14 | cave beasts |
| lair | 14 | the villain's leftovers, hooks/horns |
- Today a Places roster is **generated** (`ppal_place_roster()`: crc32 draw of "<first> <epithet>" from 40+30 names per kind, blurb "A rare Puzzle Pal that fell out of X"). Distinct per place but generic: no place motif, 4 name banks only, blurb is boilerplate. An authored row for a place slug overrides it.
- Art gate: a roster releases nothing until all 6 PNGs exist and are not placeholders (`ppal_art_ready`). So Places pals ship place by place as art lands.
- Places pictures unlock on a player's first visit; pals only matter once that picture is Advanced-solved.

## 1. Decision: author all 81 rosters (do not ship generated names)
Generated names would repeat shapes of speech across 81 places and have no motif for Opus to draw from. Author every roster from the place itself. The generator stays as the fallback for admin uploads only.
- **Source per place**: its title, kind, region, and scene description from the Places data/scene script (props, creatures, palette). Pull the 3 to 5 motif words automatically (`tools/pal_briefs.py --brief <slug>` to write `claude/art-briefs/pals/<slug>.md`).
- **Drafting**: 1 Haiku agent per kind (4 agents) writes rows in the existing 14-column `puzzle_pals.txt` format, using the roster recipe (3 common = corner/edge/plain inner, 2 uncommon = two of Plus/Ring/TTBB, 1 rare = whimsy piece cut to the place's subject), knob from kind mood, `piece` = a cell that suits the idea, one-line blurb with the place's own props. Keys `pl-<short>-n`.
- **Dedupe**: new `tools/dedupe_puzzle_pals.py` (model: `tools/dedupe_stop_acts.py`): no two pals share a name, an epithet, or a core idea across ALL pictures (gallery + places), no NPC names (`--npcs`). Lint (`tools/lint_puzzle_pals.py`) must pass.
- **Review**: Opus reads each kind's draft once (names, motifs, silly vs cute, rare piece really suits the place), fixes, then Joshua gets a review artifact per kind before art starts (art is the costly step).

## 2. Art: Opus, one agent per place, 4 at a time
Same recipe as the 3 finished pictures (`aseprite-source/pals/palib.py`, one `pals_pl_<slug>.py` per place, outputs `game/assets/img/puzzles/pals/<key>.png`, contact sheet, max 3 loops).
- **Cell fill**: a Places Advanced cell is only 15x15 art px, so the "its own cell" fill is nearly flat. Accept it: upscale the cell, take its 3 dominant colours, calm tones, as Opus already does. The place still shows in palette + accessory.
- **Accessory/shape library**: first wave of each kind builds reusable parts in `aseprite-source/pals/kit_<kind>.py` (haven: teacup, lantern, loaf, scarf; wonder: wisp, star, petal, mushroom; delve: pickaxe lamp, gem, moss; lair: horn, fang, ember) so later places only compose and tint. This is the cost saver.
- **Cost**: 35k to 55k tokens per place with the kit (65k without) = 81 x ~45k = about 3.6M tokens, 21 batches of 4. Pilot one place per kind first (4 agents, 4 contact sheets to Joshua), then the kit is frozen and the rest run.
- **Order**: lair (14, most distinct art) > delve (14) > haven (18) > wonder (35, last, most repetitive: sprites). Joshua can stop after any kind: unfinished places simply release no pals.

## 3. Rollout
| Step | Work | Who |
|---|---|---|
| P1 | `pal_briefs.py --brief` + `dedupe_puzzle_pals.py` + kit scaffolding | Sonnet |
| P2 | Draft rosters, 4 kinds | Haiku, then Opus review, Joshua artifact |
| P3 | Pilot art: 1 place per kind + contact sheets | Opus x4 |
| P4 | Art waves by kind, 4 agents at a time, commit per wave, sheets to Joshua | Opus |
| P5 | Admin > Jigsaw > Pals tab shows per-place art-ready status; CI lint covers all | Sonnet |
Release gating: each wave commits its PNGs; a place goes live for pals automatically when its 6 are present. Version bump + zip per 2.0.8x release, never mid-wave.

## 4. Risks / calls for Joshua
1. 486 authored pals is a lot of names: dedupe tool is mandatory, review artifact before any art.
2. Cost about 3.6M tokens for all art (about 0.9M per kind except wonder 1.6M). Stop-and-go per kind is fine.
3. Uploads: admin-uploaded pictures keep generated rosters (art 0, so they release nothing until art exists). Decide later whether uploads need pals at all.
4. Calls (defaults in bold): order **lair > delve > haven > wonder**; rare piece per place **whimsy shape matching the place subject**; ship **per kind release**, not all at the end; keep generator fallback **yes**.
