# Handoff: route map bends (state 2026-11-07, main = 020289e4 + this note)

Plan and decisions: `claude/plan-route-map-bends.md`, `claude/todo.md` ("Route map bends"). Read those first.

## What exists (all on main)
- **Rules, generator, lint, preview:** `tools/bend_rules.py`, `gen_bendy_trail_proto.py`, `lint_trail_bends.py`, `preview_bend_proto.py`. `--variety` adds land stamps (`tools/bend_stamps.py`), ponds and streams from region water (`tools/bend_water.py`). Output: `claude/bend-prototype/` (plain) and `claude/bend-prototype-v2/` (variety, all 246 routes, lint 0 problems, README there).
- **Water ways, all 14 regions, hand-drawn:** Maplewold `tools/maplewold_waterways.py`; the other 13 `tools/region_waterways.py` (lines drawn over `game/assets/img/scenes/map-<CODE>.png`; `python3 tools/bend_water.py --write` -> `claude/bend-prototype-v2/waterways.json`).
- **16 hand-tuned Maplewold routes:** `claude/maplewold-bendy-maps/` (README there). Built by `python3 tools/build_maplewold_bendy.py <ids>` from `tools/maplewold_bendy_specs.py` (road turtle strings, stamps, hints); deterministic; edit the specs, not the JSON. Lint: `python3 tools/lint_trail_bends.py claude/maplewold-bendy-maps/route-*.json` and `python3 tools/lint_maplewold_extras.py ...` (both 0 problems). Pictures: `tools/preview_maplewold_water.py` (water, gates, extra mini-bosses).
- **Gates** (data, field `gates`): tool type + tier from `game/includes/tools.php` (Worn 1, Sturdy 2, Fine 3, Masterwork 4); rule min tier = region level + 1 (Maplewold = 2). 313 tunnel mouth lantern (lock), 315 slope axe (lock), 315 bridge pick (lock), 314 causeway staff (shortcut). **Extra mini-boss spots** (field `extra_minibosses`, data only): 312 Bramble Wolf 22, 314 Clam Lurker 23, 310 Wolverine 21, 309 Arctic Fox 17; 228/232/236/311/316 stay fight-free.
- **Engine (source only, NO version bump, not released):** `game/includes/trail_art.php` (`trail_authored_valid` any size, `9` on any edge, `entry` key for sections without S, gates validated, `trail_gates_closed`), `trail_tiles.php` (`trail_gate`, `trail_gate_message`, gate check in `trail_go`). Tests: `php tests/trail_bendy.php`, `php tests/trail_authored.php`; live suites `bash tests/ci_suites.sh trail_back fight_scene_trail` passed. Data for the engine: `python3 tools/bendy_to_trail_maps.py` -> `claude/maplewold-bendy-maps/trail_maps_maplewold_30x18.json` (not in `game/includes/data`).
- **Mockup:** a private artifact (six sections painted from the data, walker tries the gates); procedural art, not the baked pictures.

## Next, in order
1. **Art bake:** `tools/bake_trail_art.py` is still 22 x 7 with `9` on the east edge (its `--check` too). Teach it 30 x 18 and any-edge entry/exit, bake ground pictures for the 41 Maplewold sections under a NEW version (rule: delete `game/assets/img/trail/obj/lm-*.png` before re-baking sprites; never rebuild art under the same version), then copy the 30 x 18 json into `game/includes/data/trail_maps/` and extend `tests/trail_authored.php` (it still asserts 7 rows, entry on the left edge for the shipped data).
2. **Engine:** read `extra_minibosses` (a fixed fight on a middle section; now only `E` on the last section of delve/lair routes is fixed), a visible gate mark on the tile picture, a live browser walk of a bendy route on a phone, release (version bump, `CHANGELOG.md`, zips per the release rules in `claude/handoff.md`).
3. **Generator:** fold `--variety`, water, gates into `tools/gen_trail_maps.py` (shared SETS, captions, `--all`); wire both lints into `tests/`; gates and extra mini-bosses for the other regions (use the same tier rule, +1 per region level, cap 4).
4. Landmark names and sprites for new rows; side-trail heading rule and region-map art sync (plan items 8 and 9); phone check.

## Open for Josh
- Rope is not a tool type (315 slope uses an axe: add a rope tool type?). N/S sections are 18 tall: how should a vertical section be paced? The hand-drawn water lines for CSA, ESA and OC have no drawn water to follow: check them against the art.

## Rules to keep
Square tiles, 8 headings, road runs <= 6 (one <= 10 per section), no shortcut under 80%, thicket 12 to 45%, `E` only on the last section of 313 and 315 (on the road, 4 steps before the exit), no new tile characters. Do not edit `tools/bend_rules.py` or the lints to make a map pass. Owner rules: terse replies; push main only on Josh's word.
