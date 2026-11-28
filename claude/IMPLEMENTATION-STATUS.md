# The Hollow: implementation status (2.8.86, 2026-11-28)

Source of truth: `PROPOSAL-HOLLOW-MASTER.md` (sections 14 to 16 are the decisions). Every piece below is in the code and **switched off**: each has its own setting, default 0. With all of them off the game plays as 2.8.84; the one live change is the Puzzle Pal access filter. Nothing is pushed; 2.8.86 is the version that carries it.

## Per piece

| Piece | Setting | Code and data | Built | Tested | Stubbed / left out |
|---|---|---|---|---|---|
| Puzzle Pal access filter (build plan 0) | none (live) | `progression.php` `accessible_regions()`, `puzzle_pals.php` `ppal_spawn_nodes`, `ppal_spawn_prune` | yes | `tests/puzzle_pals_map.php` (in `puzzle_pals.sh`) | narrows further through `region_gate_open()` once `seals_open` is on |
| Seals and Expedition Standing (plan 6, 11) | `seals_open`, `seal_threshold` 78 | `seals.php`, `region_gate_open()`, tables `region_seals`, `region_standing_best`; gates in road walks, fast travel, route lists; Standing card on Wren's Journey; Almanac line | yes | `tests/seals_standing.sh` | Seed Bed row 0; N = road villages until off-road adoption; Errands row = rest stop villager errands only; no folk Almanac pages; lair peaceful act not counted |
| Lasting marks (plan 2, 3) | `stop_marks_open`, `perk_old_retired`, `mark_*` (11) | `stop_marks.php`, `stop_is_place()`, tables `stop_marks`, `stop_mark_use`; `data/stop_perks.txt` (540), `data/stop_act_bars.txt`; Lasting marks card, stamps, plaque lines | yes | `tests/stop_marks.sh` | Admin perk pickers; world-map view; village stop types are the world's own (`stop_assign_all`), which differ from the catalogue for most villages |
| Perk hooks part 1 | (with `stop_marks_open`) | `stop_mark_hooks.php`: families F01-F23 and A4 coins at shops, travel, walks, kitchen, garden, gathering, friends, stops, health, delves; old 7-day perk vs mark: the larger only | yes | `tests/stop_marks_hooks1.sh` | none known |
| Perk hooks part 2 | (with `stop_marks_open`) | place-scoped perks with the stack ceiling (cap + 4, XP + 2); daily charges A1-A3 `stop_mark_charges.php`; A5/A6 flag strips; catalogue column `hook` (site / page / todo) | yes | `tests/stop_marks_hooks2.sh` | 6 `todo` charges never fire (list below); flag strips are text, the per-flag detail art is not drawn |
| World data v2 (plan 4, 9 world part, 13) | `world_v2_open` | `world_v2.php` (one-time boot `world_v2_done`): band levels (never lowered), roads CB-WCA and SA-ESA, Beaverdam Fens and Cairnback Ridge with Cattailmere and Granitegate, Fen Path, Cairnback Climb, Aurora Road, Northern Rim Pass, Tide Track; lairs at band top; `route_danger` to Lv 57; `data/world_v2_places.txt`, `zones.txt` rows tagged `world_v2` | yes | `tests/world_v2.sh` | trail map art for the new zones and paths (art brief); **one-way**: switching it off again does not lower levels or remove roads |
| Creatures 38-55 (plan 14) | (with `world_v2_open`) | `creatures_v2.php` (boot `creatures_v2_done`), `data/creatures_v2.txt` (60), `data/pf_creatures_v2.txt`, `data/creatures_v2_lairs.txt` (7 tier 4-5 lair guardians); 5 new items | yes | `tests/creatures_v2.sh` | the 5 items have placeholder art (`assets/img/ph/`) |
| Journey engine (plan 7) | `journey_v2_open` | `journey_v2.php`, table `user_quest_steps`; step kinds adopt, raise, regular, plant, deliver, escort, defeat, help, puzzle, seal (latching, alts); wired into Wren's page, events, `ppal_on_solve`, the Seal step | yes | `tests/journey_v2.sh` | `plant bed:K` counts as done (no Seed Beds); `help errand:id` latches only through `journey_v2_errand_done()` (no errands engine); a place missing from a world without `world_v2_open` counts as done |
| Map v2 (lit floor region maps, delve-down world map; `claude/proposal-map-v2-code.md`) | `map_v2_open` (needs `world_v2_open`) | `map_v2.php` (gates, spread loader, roots, roles, world positions and drawing, region widget), `assets/mapv2.js`, `data/region_spread.json` (from the region plans, `tools/map_v2/spread_build.php`), `data/village_roles.txt`, `data/world_v2_layout.json`; hooks in `maps.php`, `region_layout.php` (`$v2` argument), `here_view.php`, `world.php`, `place_ui.php`, `layout.php`; `tools/map_v2/status.php` | yes | `tests/map_v2.sh` (golden hashes `tests/fixtures/map_v2_off.json`) | 13 of the 14 `map2-<CODE>.png` were not drawn yet when it was built (only NA): those regions keep the old map until their picture lands; manual phone pass not done; side-quest errand links (`quest` column) not built |
| Chapters and quest data (plan 9, 10, 12, 15 data) | (with `journey_v2_open`) | `data/journey_chapters.txt` (28 chapters, XP 40% of each band), `journey_errands.txt` (63 errands, 14 happening acts, 2 helpers), `stop_threads_v2.txt` (37), `journey_extras.txt`, `stop_state.txt`, `stop_band_lines.txt`; loaders `quest_data.php`; lint `claude/tools_lint_quest_data.py` | data yes, engine partly | `tests/quest_data.sh` | errands engine (offer, extras, lines), titles by Seal count, `journey_letters.txt` (letters sit in chapter rows) |

## Switching on: settings and a safe order

Do each step on the private test site first (`docs/TEST-SITE-SETUP.md`), play it for a few game days, then on the live site. Give each step its own release and news post (decision 8: the perk step-down is a news post only).

1. **`stop_marks_open` = 1.** Stands alone and can be switched off again (bars and marks are kept, the meters and 7-day perks come back). The old 7-day perks keep running to their end date; no new ones start.
2. **`perk_old_retired` = 1**, one release after step 1, with the news post about the step-down.
3. **`world_v2_open` = 1.** One-way: raises region levels, adds the roads, zones, villages and creatures on the next page load (boot steps). Take a database backup first. Cattailmere and Granitegate get their 6 perks matched by name once they exist.
4. **`journey_v2_open` = 1.** After step 3, because M4 and M6 send the gnome to Cattailmere and Granitegate (without world v2 those steps count as done). Switching it off brings the old chapters back; latched steps stay in `user_quest_steps`.
5. **`seals_open` = 1** last: gates the tier 3 to 5 doors and awards Seals. Gnomes keep every region they have been to (grandfathered by `region_visits`); home and gardens are never gated. Check `seal_threshold` (78) against real Standing on the test site first. Tier 3 to 5 areas open one per release (build plan 15), and roads CB-WCA and SA-ESA must exist (step 3) before a tier 4 gate means anything.

## Known TODO

- **Seed Beds** (build plan 8): Standing's Seed Bed row scores 0 (`STANDING_TODO_ROWS` in `seals.php`, shown "coming later"); journey `plant bed:K` steps count as done until `seed_bed_handins()` exists. The Maplewold bed is the Cattailmere paddy.
- **Errands engine** (build plan 10): data is in, nothing offers errands yet; Standing's Errands row counts only `stop_errands`; `help errand:id` steps need `journey_v2_errand_done()` to be called.
- **Off-road adoption in Standing** (build plan 5): drop `on_road`, cap off-road villages at tier 2, first adoption in an area free. Until then Standing's N is the road villages (seals.php TODO), not the Maplewold's 12.
- **Six `todo` charge perks** never fire: `bakers_peel` (no crop in its scope), `cedar_shaving_broom` (stop crafts cannot fail), `supper_on_a_banana_leaf` (no stop fire), `fire_watch_basket` and `lamp_at_the_caravan_gate` (torch step in a named delve), `trued_boomerang` (empty walk find). Each needs a game site or a new perk text.
- Flag perks A5/A6: the per-flag detail (a leaf on never-owned items, a visiting bee...) is not drawn; Admin perk pickers and a world-map marks view are not built.
- Village stop types: the world's (`stop_assign_all`) differ from the perk catalogue for most villages; decide which wins before marks go live.
- Standing: folk Almanac pages, a lair's peaceful act.
- Titles by Seal count; `journey_letters.txt`.
- Art: the 5 new items (placeholders), trail maps for the Fens, the Ridge and the new paths.
- Game-day tests listed in master section 11 ("Game-day points to test") are covered only in part by the piece suites; nothing was added to `tests/game_time.php` / `tests/game_clock.php`.
- Tier 4 upkeep still turns on the real UTC month (conflict 10; kept on purpose).
- Rerun the perk impact model on the corrected XP totals before locking XP-based perks (master section 15).

## What to playtest

- **All off (now):** a fresh gnome and an old one play as before; Puzzle Pals only turn up in regions the gnome has been to, and a first walk into a region tops them up.
- **Marks:** bars fill at about 7 visit-days each; a full bar latches and stays after many sleeps; five sleeps in an hour give five days of acts and charges (no real-day cap, decision 4); town and havens act as stops; an old 7-day perk and a mark on the same number never stack.
- **World v2:** levels never drop; the new roads and the Fens / Ridge villages work for walks, fast travel and the world map; Lv 38-55 creatures and the lair guardians fight fairly in puzzle combat.
- **Journey v2:** M1-M7 for a fresh gnome and for one who built the Sugar Shack; latching (a step done once stays done); the second way to finish each step; XP lands near Lv 15 at the Maplewold Seal.
- **Seals:** a non-fighter reaches 78 in about 34 game days, a fighter about 32 (sim); the Warden lists what is missing at a closed door; nobody is shut out of a region they already reached.

## Test results at this commit

Run locally on 2026-11-28 (PHP 8.3, SQLite, `tests/ci_suites.sh` over the 167 CI suites plus the 9 new ones, 4 shards):
- 176 suites, 166 ok. The 10 that failed were rerun one at a time on this build and on the commit before the Hollow work (`fdb0498c`): 9 fail the same way on both (`beds`, `security190` trek pages, `puzzles`, `puzzles_daily`, `jigsaw` hub cards, `pf_golive`, `pfboard_v1_page`, `pfv1_charm`, `toast_cover`: pre-existing, not from this work); `pfboard` failed once and passed on rerun (flaky).
- All new suites pass: `seals_standing`, `stop_marks`, `stop_marks_hooks1`, `stop_marks_hooks2`, `world_v2`, `creatures_v2`, `journey_v2`, `quest_data`, `sso_lockdown`, and `puzzle_pals` (with `puzzle_pals_map.php`).
- Fresh-install walk (`tests/walk.sh`) passes with every new setting at its default (all 0, `seal_threshold` 78, no `world_v2_done`).
- `php -l` clean on every PHP file changed since `0ebd9483^`; `tools/check_versions.sh` OK at 2.8.86.
