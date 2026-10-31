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
