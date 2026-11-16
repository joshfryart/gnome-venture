# NPC Clockwork (2.7.01, source only, not released)

Josh 2026-11-15: every NPC gets a set route and when they walk it; not all go far, not all leave town; a shopkeeper's shift is covered by another local NPC; rest-stop villagers wander too; 2-3 "things they do" a game week, scattered; NEEDED NPCs (mentors) never travel. Missed appointments: try again on the next game days (no penalty).

## Built
- `game/includes/npc_clockwork.php`: pure functions, no new tables. Key `s<id>` (stop villager) / `n<id>` (town NPC). Travellers keep their circuit.
  - Modes: `fixed` (calling mentors + `fixed|Name` in `data/npc_clockwork.txt`: never leave), `post` (innkeeper, keeper, watcher ...: stay at post, old Sight rules), `free`.
  - Free: 2 doings (40% get a 3rd), reach rolled once: local 45% (stroll / sit with neighbours / tend a patch), near 40% (walk to the next stop on the road, or another town spot), far 15% (market in the road's town). Villagers named in Sight folk rows get 1-2 `sight` doings (they cycle their Sights week by week; arrival matches the row's `dp=`).
  - Doings: set days, set hour, 1 h per leg, `dwell` h at the stop, home before midnight. Scattered by seed over days and 6 start slots.
  - Shop: a keeper's doings dodge the shift when possible; else `npc_cw_shop_cover` picks a free local NPC (`staff_on_duty` swaps them in; `npc_now` says "minding X").
  - Forecast: `npc_cw_forecast` (true schedule, 14 days), `npc_cw_sight_card_html` (strip of today + next appointment on the Sights card).
  - Hooks: `trail_sight_folk_here` (Sight presence), `npc_now`, `stop_folk_of(presentOnly)` (away from stop), stop Villagers tab "Right now", quest beat needs `npc=Name`.
- Setting `npc_clockwork` (1 on). Test: `tests/npc_clockwork.sh`. Test hooks: `$GLOBALS['gv_cw_time']=[dow,hour,dayIndex]`, `gv_cw_out`.
- Trail families hook: `trail_families.php` (+ `trail_fam_<name>.php` per family). Built first: Maplewold, Coast, Forest (notes in `claude/sights/family-*.md`). Brief for the other 11: `claude/sights/FAMILY-BRIEF.md`.
- Art: `aseprite-source/npc25/` pathway (haiku spec -> sonnet scaffold/checker -> opus draw -> haiku check). Hedgehog and tortoise first. Walk strips not wired to the map yet (map still shows the idle folk sprite).

## Open
- Wire npc25 walk strips into the Trail map (`trail_sight_folk_pic`) + draw walkers moving along sections.
- Town NPCs only get `stroll/gossip/tend/errand` to a town spot; the Sight doings use the same rows. No hand-authored routes yet (`doing|` lines in data/npc_clockwork.txt are not parsed).
- Mentor rows in the Sight folk files are ignored (never travel): quest lines naming them as Sight beats still use `@friend`.
- 11 more families, 19 more species.
