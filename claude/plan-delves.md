# Delve redo plan: route menu + tile-map floors, unique floor pool per delve (brainstorm, 2026-10-31)
Status: **not built.** Joshua picked mockup 1 (tile map) for the floors, with the route-map menu (mockup 3) to choose the path. Mockups + screenshots: branch `ccr-5e82e48d-1d6u8o`, `claude/delve-mockups/` (1-tilemap, 2-dig-down, 3-route-map, 4-diorama, gallery); published gallery: https://claude.ai/artifact/TWQYNTxPecKASSqhSsx6ye. Mockups only; no game code changed.

## Decided (Joshua)
- Floors are tile maps (fog, torch, pickups, party strip). Between floors a route menu picks the next stage (typed nodes, risk and reward icons, `?` for unseen).
- A stage is at most 5 min, often less. Not as long as a trek level.
- Each delve location has its **own floors** to draw from (not shared layouts).
- Pals join: the party strip shows gnome + 2 pals (HP, level). Pal jobs can re-run cleared delves (see `plan-pal-jobs` notes in the 2.3.0 block of `todo.md`; code in `includes/pal_jobs.php`).

## Shape
- Route menu: about 9 nodes, one path of 4 or 5 picks from the top to the boss. Floor nodes (fight, treasure, mystery, puzzle) open a tile floor (1 to 5 min). Quick nodes (shrine, mole merchant) are a card (10 to 20 s). Boss node = one floor, guardian, then the chest. A delve is about 4 stages, 5 to 12 min in short bites, each ending at the menu.
- Floor sizes set the time: small 9x9 (~1 min), standard 13x13 (~2 to 3), large 15x15 (~4 to 5, rare: treasure and boss only).
- Torch is the timer: a floor starts with fuel for about 40 to 60 steps; at 0 the light shrinks to 1 tile (no fail, slower and riskier). Tap-to-walk + one context button, about 30 to 60 taps a floor. Fewer than 7 finds a floor (the 7 dots are the progress bar).
- Floor state saved in `walk_scene` (leave and resume). Climbing out keeps everything (today's rule).
- Delve moods change a floor rule, one line each: Grotto (glowcaps light tiles), Flooded (water costs torch), Mine (rails fast travel, cave-ins), lair-adjacent (a roaming guardian to sneak past).
- Pal skills show on the floor: Grotto Glim spots traps, Lantern Lark +1 light (reuse `ppal_skills`).

## Unique floors per delve (14 delves, one per region)
- Today: 44 shared hand-built 11x11 layouts (`data/delve_maps.txt`), picked by hash; landscape only recolours. New: `data/delve_floors.txt` keyed by delve slug.
- 12 floors per delve (168 total): 5 small, 5 standard, 2 large/boss. A run draws a path, a tier per node, then a floor of that tier from the delve's own pool, never repeating a floor in one run. The first clear uses at least one signature floor.
- Each floor is unique to its delve: its own landmark layout (Beaverdam Tunnels: dam wall, flooded side, lodge; Salt Mine Galleries: rails, cave-ins), hand-placed objects (shrine, key and door, hazards, chests), a one-line rule, its own name, signature creature and loot (1 to 2 items that drop only there, to be decided).
- Format like today's file: `@slug/name`, tier, rule line, ASCII rows (S, digits, K/D, W for hazard). Lint script: solvable, pickups reachable, key before door, fits the time budget (path length x torch cost).
- Authoring: draft the 12 floors per delve from name + landscape + rule list, lint, hand-polish the 14 signature and 14 boss floors. No pool yet = fall back to the generator and shared layouts (partial rollout works).

## What already exists
`tilemap.php`, `delve_map.php`, `delve_maps.txt`, `walk_scene` (tile map + seed generator for delves and lairs), `delve_rooms.txt` (room lines by landscape), `landmark_clears`, `landmark_at()` (level from the side road). Work is mostly torch, fog on floor items, floor modifiers, the route layer, the per-delve pool.

## Build order
1. Floor format + parser + lint. 2. Route generator (nodes, tiers, draw per delve). 3. M first step: the existing 5 rooms as tile floors with torch + fog, route menu with 2 branches, pal strip. 4. Author 3 delves fully as the pattern. 5. Moods and size tiers. 6. Other 11 delves in waves of about 4. 7. Pal job re-runs use the same route headlessly (Wayfinder takes the safe branch, Thornblade fights).

## Questions for Joshua
1. Runs per day: keep once per delve per day, or several at 1 energy each?
2. Length: 3 stages for a quick delve, or always 4 to 5?
3. Knocked out: lose nothing (today), or lose the current floor's loot?
4. Pool size: 12 per delve, or start with 8?
5. Delve-only loot: 1 to 2 items per delve?
6. Route: fixed per gnome per day (friends compare) or random each run?
7. Floors hand-built for all 14 delves, or generated from the seed for some (cheaper, less memorable)?

## Build plan v2 (2026-10-31, from the code + mockup 1 and 3 READMEs)
Grounded in today's code: a delve is one `expeditions` row (kind `delve`, `depth` = rooms done, `DELVE_ROOMS` 5), `delve_start` / `delve_next` / `delve_chest` in `includes/landmarks.php`, map + walking in `includes/delve_map.php` (`walk_scene`: `map_key` `h:<name>` or `g11:..`, `state` JSON `{c:[room codes]}`, `seen`), grid helpers in `includes/tilemap.php` (`tm_parse`, `tm_gen`, `tm_validate`, `tm_reveal`). Pal re-runs: `pj_roll_delve` (5 fights from a seed).

### Rules for the build
- **Flag it.** New setting `delve_v2` (default 0). Off = today's delve, untouched. A delve already running keeps its rules: `map_key` prefix tells (`f:` = new floor, `h:`/`g..` = old).
- **No schema change.** Route + floor state live in `walk_scene.state` JSON: `{v:2, route:{seed, nodes, path, at}, floor:{torch, found, picks, hp}, c:[]}`. Verify `map_key` column width fits `f:<slug>/<floor>` first.
- **One expedition per delve, as now.** A stage is not a new row. `depth` counts stages cleared, so level scaling (`level .. level+DELVE_ROOMS+1`), the chest and the clear count (`landmark_clears`) keep working. Map `depth` to stage count (3 to 5) and keep chest value near today's so balance holds.
- **Energy.** Enter = 1 (as now). The per-room energy goes away; torch fuel replaces it. Lantern tool = more fuel (instead of free rooms).
- **Server walks.** Floor walking validated like `dm_walk` (BFS, torch cost per step, stop at trap/pickup). No client trust.
- Roles: Sonnet codes, Haiku drafts floors, Opus reviews the 28 signature + boss floors (project rule).

### Steps (each ends shippable, flag off)
1. **Format + lint (S).** `data/delve_floors.txt`: `@slug/name`, `tier:` small|standard|large, `rule:` one line, `sig:` yes|no, rows (`# . , S` as now, `0-9` pickups, `K` key, `D` door, `W` hazard, `T` trap, `C` chest, `B` boss, `M` shrine). `dm_floors()` parser. `tools/lint_delve_floors.php`: size by tier, one S, solvable (BFS with key before door), all pickups reachable, `<7` finds, steps to clear within the torch budget x 1.3. `tests/delvefloors.sh`. Gate: 3 sample floors pass, bad ones fail.
2. **Route generator (S).** `dv_route(seed, slug)`: 9 nodes in 4 to 5 rows, one path of 4 to 5 picks, typed (fight, treasure, mystery, puzzle, shrine, mole, boss), tier per node (large only treasure + boss), `?` hides unseen type. Draw a floor of that tier from the delve's pool, no repeats, one signature on the first clear, fall back to `tm_gen` if the pool is empty. Pure function, unit tested. Seed = per gnome per delve per day (Q6).
3. **M slice (M, the first real play).** Existing 5 rooms become 5 tile floors on the old `tm_gen` layouts: torch + fog + LOS (`tm_reveal` with bands), pickups on the floor (find card), tap-to-walk, party strip (gnome + 2 pals, read-only), route menu with 2 branches between floors, state saved so leave/resume works. Fights stay today's fight screen (`combat`); trap/find/problem rooms become floor objects. Gate: Joshua plays one delve on phone (Firefox Android, dark).
4. **Author 3 delves fully (M, pattern setter).** Pick Beaverdam Tunnels (flooded), Salt Mine Galleries (mine), Firefly Caves (grotto): one per mood. 12 floors each (5 small, 5 standard, 2 large/boss), signature + boss hand-polished by Opus, the rest Haiku draft + lint. Delve-only loot 1 to 2 items each. Gate: Joshua approves names + a screenshot of each.
5. **Moods + sizes + pal skills (M).** Grotto glowcaps, Flooded water cost, Mine rails + cave-ins, lair-adjacent roamer. Grotto Glim spots traps, Lantern Lark +1 light via `ppal_skills`. Torch-at-0 = light shrinks to 1 (no fail).
6. **Other 11 delves in waves of about 4 (L, mostly authoring).** Same pipeline. Partial rollout is fine (empty pool = generator).
7. **Pal re-runs (S).** `pj_roll_delve` walks the same `dv_route` headlessly: Wayfinder takes the safe branch, Thornblade fights, pal never fights the guardian. Payout stays about 60% of a clear.

### Tests to add
`delvefloors.sh` (parser + lint on the real file), `delveroute.php` (determinism, no repeats, tier rules, fallback), extend `tests/delvemap.php` and `tests/paljobs.sh`; golden combat replay unchanged (fights reuse `gnome_combat`). Run suites one at a time (shared /tmp).

### Risks
- Authoring volume: 168 floors. Mitigate with waves + lint; ship with 8 per delve if Q4 says so.
- Torch vs energy economy needs a sim (like `claude/catfish-sim.php`): steps per floor, finds per floor, loot per minute vs today's 5 rooms.
- 15x15 under 400 px: 7-column viewport that scrolls with the gnome; test on phone first.
- Once-a-day rule vs a longer run: keep run resumable across the day.

### Suggested defaults (answer only if you disagree)
Q1 once per delve per day. Q2 always 4 stages, 3 for delves under danger level 3. Q3 knocked out keeps what you carried except the current floor's pickups. Q4 start 8 floors per delve, grow to 12. Q5 yes, 1 delve-only item each. Q6 fixed per gnome per day (friends compare). Q7 hand-built signature + boss floors for all 14, generated-from-seed fill for the rest.
