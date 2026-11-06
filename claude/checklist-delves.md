# Delve redo checklist (2026-10-31). Plan: `claude/plan-delves.md` (Build plan v2)
Rules: Haiku = grunt (floor drafts, text, data, lint runs). Sonnet = code, tests, review of Haiku's work. **No Opus. No art by agents: Joshua draws all art.** Missing art = placeholder (red border + THIS IS PLACEHOLDER). Flag `delve_v2` stays 0 until Joshua flips it. One suite at a time. Push to the session branch only; never main. Terse reports.
Tag: [S] Sonnet, [H] Haiku, [J] Joshua.

## 0. Before
- [x] [J] Accepted the 7 suggested defaults by saying Go (2026-10-31).
- [x] [S] `walk_scene.map_key` is VARCHAR(60): fits. NOTE `state` is VARCHAR(2000), `seen` VARCHAR(500): keep route + floor state under 2000 chars (compact JSON, store route seed not nodes).
- [x] [S] Setting `delve_v2` (0) in `dm_settings()`, `dv_on()` in delve_map.php.

## 1. Floor format + lint
- [x] [S] `dv_floor_parse()` / `dv_floors()` (includes/delve_floors.php) parser for `data/delve_floors.txt` (`@slug/name`, `tier:`, `rule:`, `sig:`, rows).
- [x] [S] `tools/lint_delve_floors.php`: size by tier, one S, solvable (key before door), pickups reachable, <7 finds, steps within torch budget x1.3.
- [x] [S] `tests/delvefloors.sh` with 3 good + bad sample floors.
- [x] [S] Gate: tests pass; commit.

## 2. Route generator
- [x] [S] `dv_route(seed, slug, stages)` (includes/delve_route.php): 6 to 12 nodes (3, 4 or 5 rows; default 4 = 9 nodes), one path of 4 to 5 picks, typed nodes, `?` for unseen, tier per node (large = treasure + boss only).
- [x] [S] Floor draw per node: from the delve's pool, no repeat, one signature on first clear, fallback `tm_gen` when pool empty.
- [x] [S] Seed = gnome + delve + day.
- [x] [S] `tests/delveroute.php`: deterministic, no repeats, tier rules, fallback. Commit.

## 3. M slice (old 5 rooms as tile floors)
- [x] [S] State in `walk_scene.state` `{v:2, route, floor:{torch,found,picks,hp}, c}`; `map_key` prefix `f:`. Old delves untouched.
- [x] [S] Torch fuel (40 to 60 steps), light shrinks to 1 at 0, lantern tool = more fuel. Enter = 1 energy, no per-room energy.
- [x] [S] Fog + line of sight (`tm_reveal` bands), server-validated walk (like `dm_walk`), stop at trap/pickup.
- [x] [S] Floor pickups + find card; chest; key/door; shrine. Fights reuse the current fight screen.
- [x] [S] Party strip (gnome + 2 pals, HP, Lv, read-only).
- [x] [S] Route menu with 2 branches between floors; resume after leaving; climb out keeps loot.
- [x] [S] `depth` = stages cleared; chest and `landmark_clears` still fire once.
- [x] [S] Phone layout: 7-column view under 400 px scrolls with the gnome. Screenshot light + dark.
- [x] [S] `tests/delve2.sh` (+ `delve2.php` unit/helpers) added; `delvemap.sh` still passes. NOT run: other CI suites, golden combat replay (fights reuse `gnome_combat` unchanged).
- [x] [S] Balance sim `claude/delve-sim.php` (generated floors, 4 stages): fights 2.35 (old 2.83), traps 1.37 (0.98), finds 4.9 (2.4), about 65 torch steps of 192 fuel, about 3 min. First guess: torch never runs out on generated floors, so lower `DV_TORCH` or lean on authored floors. Tune after Joshua's playtest.
- [x] [S] Torch tuned (2026-10-31) by `claude/delve-torch-sim.php`: `DV_TORCH` 30/45/50 (was 40/55/70, never ran out). A thorough player in fog runs dark on about 11% small / 16% standard / 10% large floors; lantern 1 cuts that to 2-4%. Hazard torch effects come on top (sim does not count them).
- [ ] [J] Plays one delve on phone (Firefox Android, dark). Fix list from him.

## 3b. Chamber stamper (added 2026-10-31, instead of drawing 168 full grids)
- [x] [S] `includes/delve_stamp.php` (chambers 3/5/6, 2x2 stamp, doorways, objects), `tools/lint_delve_chambers.php`, `tests/delvestamp.sh`, data `includes/data/delve_chambers.txt`.
- [x] [H] 25 Beaverdam chambers (6 of 3x3, 14 of 5x5, 5 of 6x6) in the data file. Generated delve floors for Beaverdam now use them (any other delve still uses tm_gen).
- [ ] [H] Chambers for the other 13 delves (about 25 each), Sonnet lints + reviews, Joshua approves the look. Wave 1 DONE (Jaguar Root Caves, Mangrove Root Maze, Salt Mine Galleries, Firefly Caves; 125 chambers total in the data file). Wave 2 DONE (the other 9 delves; 350 chambers, 14 delves x 25; 11 near-copies fixed by hand; per-delve wet caps in `DS_WET_CAP`). Joshua still to review the look and approve.
- [x] [S] Per-delve hazard for W (2026-10-31): `DV_HAZARD` (emoji placeholder, name, ground tint) + `DV_HAZARD_FX` (health or torch a tile, log + flash; health never below 1) in delve_floors.php; W drawn as tinted ground with a small icon (`haz` in `tm_render_svg`), legend + tile label say the effect. Torch bar now an SVG (the old `style=` width was blocked by CSP).
- [x] [S] Wandering creatures while walking a floor (2026-10-31): `dv2_enc_step` in delve_v2.php, settings `dv_enc_steps` 6 / `dv_enc_chance` 25 / `dv_enc_cap` 2; level between stage and gnome (stage-2..stage+3), creature from the delve's landscape pool, never back to back, none next to S/E/M, none on the guardian's floor.
- [ ] [J] Art for the 14 hazard icons and any wandering-creature marker: NOT drawn (Joshua's call); emoji placeholders in `DV_HAZARD`.
- [ ] [S] Maybe: more doorway/shape variety, signature set pieces (dam wall, lodge) as full 13x13 authored floors in the pool.

## 4. Author 3 delves (Beaverdam Tunnels, Salt Mine Galleries, Firefly Caves)
- [x] (2026-10-31) 26 floors in `delve_floors.txt`, lint clean: Beaverdam 10 (Haiku draft, dam_wall + log_jam redrawn), Salt Mine 8, Firefly 8 (Opus, draft copy in `claude/drafts/delve_floors_salt_firefly.txt`). Names, titles, rule lines are DRAFT. The floor title + rule now go in the log when an authored floor opens. Delve-only loot not wired.
- [ ] [H] Per delve: draft 8 floors (4 small, 3 standard, 1 large/boss) from name + landscape + rule list. Names, rule lines, signature creature, 1 delve-only item name.
- [ ] [S] Lint all; reject and send back failures to Haiku; Sonnet hand-fixes signature + boss floors; check uniqueness (no copied layouts, names unique).
- [ ] [S] Wire delve-only loot (item rows with placeholder icon).
- [ ] [J] Approves floor names + loot names. Draws art (floor tiles, loot icons, creatures).
- [ ] [S] Screenshot each delve for Joshua; commit.

## 5. Moods, sizes, pal skills
- [ ] [S] Grotto (glowcaps light tiles), Flooded (water costs torch), Mine (rails fast travel, cave-ins), lair-adjacent roamer.
- [ ] [S] Grotto Glim spots traps; Lantern Lark +1 light via `ppal_skills`.
- [ ] [H] One-line mood text for all 14 delves.
- [ ] [S] Tests per mood.

## 6. Other 11 delves, waves of about 4
- [ ] [H] Draft floors per wave (8 per delve, grow to 12 later).
- [ ] [S] Lint + fix + unique check.
- [ ] [J] Approves names per wave, draws art.
- [ ] [S] Commit per wave. Empty pool = generator fallback, so partial is safe.

## 7. Pal re-runs
- [x] [S] `pj_roll_delve_route` walks today's `dv_route` headlessly when `delve_v2` is on (Wayfinder safe branch, Thornblade fights, never the guardian); payout ~60%; collect names the way taken.
- [x] [S] `tests/paljobs.php` route section.

## 8. Ship
- [ ] [S] `tools/check_versions.sh`, lint all php, full CI list one suite at a time, upgrade check.
- [ ] [S] Version bump, CHANGELOG + news (only if flag goes on), manifest + slim zip via `tests/build_update.sh`.
- [ ] [S] Update `claude/handoff.md` + `claude/todo.md`.
- [ ] [J] Uploads zip, flips `delve_v2`.

## Always
- [ ] Commit small, push to branch after each step. Note failures honestly. Check Haiku output before trusting it.
