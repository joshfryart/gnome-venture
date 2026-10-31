# Delve redo checklist (2026-10-31). Plan: `claude/plan-delves.md` (Build plan v2)
Rules: Haiku = grunt (floor drafts, text, data, lint runs). Sonnet = code, tests, review of Haiku's work. **No Opus. No art by agents: Joshua draws all art.** Missing art = placeholder (red border + THIS IS PLACEHOLDER). Flag `delve_v2` stays 0 until Joshua flips it. One suite at a time. Push to the session branch only; never main. Terse reports.
Tag: [S] Sonnet, [H] Haiku, [J] Joshua.

## 0. Before
- [ ] [J] Answer or accept the 7 suggested defaults (end of plan file).
- [ ] [S] Check `walk_scene.map_key` width fits `f:<slug>/<floor>`; widen additively in `db_migrate` if not.
- [ ] [S] Add setting `delve_v2` (0), admin toggle, `dv_on()` helper.

## 1. Floor format + lint
- [ ] [S] `dm_floors()` parser for `data/delve_floors.txt` (`@slug/name`, `tier:`, `rule:`, `sig:`, rows).
- [ ] [S] `tools/lint_delve_floors.php`: size by tier, one S, solvable (key before door), pickups reachable, <7 finds, steps within torch budget x1.3.
- [ ] [S] `tests/delvefloors.sh` with 3 good + bad sample floors.
- [ ] [S] Gate: tests pass; commit.

## 2. Route generator
- [ ] [S] `dv_route(seed, slug)`: 9 nodes, 4 to 5 rows, one path of 4 to 5 picks, typed nodes, `?` for unseen, tier per node (large = treasure + boss only).
- [ ] [S] Floor draw per node: from the delve's pool, no repeat, one signature on first clear, fallback `tm_gen` when pool empty.
- [ ] [S] Seed = gnome + delve + day.
- [ ] [S] `tests/delveroute.php`: deterministic, no repeats, tier rules, fallback. Commit.

## 3. M slice (old 5 rooms as tile floors)
- [ ] [S] State in `walk_scene.state` `{v:2, route, floor:{torch,found,picks,hp}, c}`; `map_key` prefix `f:`. Old delves untouched.
- [ ] [S] Torch fuel (40 to 60 steps), light shrinks to 1 at 0, lantern tool = more fuel. Enter = 1 energy, no per-room energy.
- [ ] [S] Fog + line of sight (`tm_reveal` bands), server-validated walk (like `dm_walk`), stop at trap/pickup.
- [ ] [S] Floor pickups + find card; chest; key/door; shrine. Fights reuse the current fight screen.
- [ ] [S] Party strip (gnome + 2 pals, HP, Lv, read-only).
- [ ] [S] Route menu with 2 branches between floors; resume after leaving; climb out keeps loot.
- [ ] [S] `depth` = stages cleared; chest and `landmark_clears` still fire once.
- [ ] [S] Phone layout: 7-column view under 400 px scrolls with the gnome. Screenshot light + dark.
- [ ] [S] Extend `tests/delvemap.php`; run `landmarks` / `delve` suites; golden combat replay unchanged.
- [ ] [S] Balance sim (`claude/delve-sim.php`): steps, finds, loot per minute vs old 5 rooms. Tune.
- [ ] [J] Plays one delve on phone (Firefox Android, dark). Fix list from him.

## 4. Author 3 delves (Beaverdam Tunnels, Salt Mine Galleries, Firefly Caves)
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
- [ ] [S] `pj_roll_delve` walks `dv_route` headlessly (Wayfinder safe branch, Thornblade fights, never the guardian); payout ~60%.
- [ ] [S] Update `tests/paljobs.sh`.

## 8. Ship
- [ ] [S] `tools/check_versions.sh`, lint all php, full CI list one suite at a time, upgrade check.
- [ ] [S] Version bump, CHANGELOG + news (only if flag goes on), manifest + slim zip via `tests/build_update.sh`.
- [ ] [S] Update `claude/handoff.md` + `claude/todo.md`.
- [ ] [J] Uploads zip, flips `delve_v2`.

## Always
- [ ] Commit small, push to branch after each step. Note failures honestly. Check Haiku output before trusting it.
