# Handoff: non-puzzle todo cleanup + Josh's decisions (2026-11-14/15)

Branch `ccr-fb812cec-kj1m4j` (pushed, clean; NO PR, NOT on main, no version bump, no zips, no CHANGELOG change: Josh releases). Puzzle combat untouched. Read `claude/todo.md` first (sections 3-6 are current); old text is in `claude/todo-archive.md` ("Moved from todo.md 2026-11-14").

## Done (commit)
- todo.md cleaned: 224 to ~95 lines; non-puzzle blocks archived verbatim, open items shortened (f43c97d5, 703c3150).
- Villagers with no `dp=` get default hours by role (718701a5, 86343d14): travellers (merchant, minstrel, naturalist, gourmand) follow their circuit, on a region's Trail ~4 days a week (3 stops before to 4 after); shop-hours roles DAY ONLY; inn/watch/light/signal any time; pedlar/pilgrim/wanderer/scout/porter/sack-carrier dawn+day. Code `trail_sight_extras.php`, rule in `claude/sights/GRAMMAR.md`, tests `tests/trail_sights.php`.
- Almanac Sights pages stay out of counts: already true + tested. No rope tool: docs fixed (6ab3a5dc).
- `upload-zips/gnome-venture-trail-ground-*.zip` (55, 310 MB) git-rm'd (66c30480). Zips rebuilt only at release.
- Gates review of 230 routes: `claude/reviews-2026-11-14/trail-gates-review.md` (24 locks, 14 short cuts, 52 mini-bosses; no lock on 327 CA, 448 EA). Tables show state BEFORE the tier change.
- Early-region gates now tier 2 (Sturdy): NA CA NWE CB SE SA EE (17 gates moved); MENA EA CSA SEA WCA ESA OC stay tier 3 (16ded02d). Rule in `lint_maplewold_extras.gate_tier`; data-only, no re-bake.
- `decor` field (ef9a6cec, 7d88c81c): all 665 sections carry looks/kinds/zones/prop hints (`tools/trail_decor.py --write|--check`; `trail_decor()`/`trail_decor_at()` in `trail_art.php`). Engine draws a coloured tile FALLBACK only where the ground picture is missing; look with pictures unchanged. Plan `claude/plan-trail-decor.md`.
- 15 weak Sights items redrawn (6d27d2f8) by new `tools/gen_sight_item_art_f.py` (PIL, like gens a-e); before/after `claude/reviews-2026-11-14/sights-items-redraw-before-after.png`. Weakest still: vine twine (coil reads as a turtle). An admin upload `uploads/items/<slug>.png` hides new art.
- Almanac data calls (7c7fc2a5): Lotus, Banana, Cannonball Tree text (region unchanged, Spicepeak), Mossbottom 5 shops, 4 bare lairs, 146 distinct village pages. Upgrade step `ensure_almanac_fixes_1114` (marker `almanac1114fix`, exact-text replace). Shell Meal P and tortoise greens deliberately left.
- Lair levels: Silverback Spider = Lv 20 (route 18-22; boot step `silverback_lair_level_1114`, 8e2d61a2). Late medium-zone lairs = region level + 4, route level -2..+2: CSA 27, SEA 30, ESA 36, OC 39 (`LAIR_LEVEL_1115` in `roads.php`, boot step `medium_lair_levels_1115`, e21c8d65). Boot steps run on the next release (`db_version != APP_VERSION`).

## Tests run (each alone)
trail_sights, trail_sights_lint, trail_mini, trail_back, trail_bendy, trail_authored, village_desc, almanac_pages (fresh + simulated upgrade), adventure, landmarks, fight_scene_trail: pass. `health.sh` fails 4 checks, same on code before these changes: add to the known-failing list (stops100, stopkinds, here, pantry, css_lint, here_bang, animals120, calling, contest, market100, delvemap, flowers, sinks097).
NOT run: full CI, MySQL, a browser check (new item art, fallback look, gates), a real phone.

## Still open
- Josh: tune Sights rewards after play; pacing of vertical N/S route sections (18 tall).
- Josh: hard-zone lairs sit at Lv 30 in early regions (CA 4, NWE 6, CB 8, SE 10, EE 14, MENA 17, EA 20): deliberate? Den of the Great White Owl (NA) Lv 10 vs region 1. OC keeper Lv 39 exceeds every creature in data (max 37).
- Decor next slices (need Josh's word): Admin editing, baking from decor, exact prop spots, decor in tile labels. Do NOT re-bake ground pictures (bake is not bit-for-bit repeatable).
- Other todo.md non-puzzle items not decided: Sights engine gaps, Trek content, road kinds, art list (section 5).
- Nav chrome only on Here/stops; craft-map canvas 480x270 final (recorded, no work).

## Rules to keep
Update todo.md after every change. Commit footers: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>` + `Claude-Session: https://claude.ai/code/session_01PZZqg7jpRpSANvaVSCNSdA`. Push only to this branch; "Cannot update this protected ref" can be noise, check `git status -sb`. Repo is 3 GB: no extra worktrees.
