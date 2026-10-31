# Sections

Generated from graphify-out/graph.json (9438 nodes, 24775 edges). Every source file belongs to exactly one section; tests, tools and content drafts live with the domain they exercise. Machine-readable twin: `sections.json`; node overlay: `graph.sections.json`.

**Dependency shape:** `Core` and `Player & Progression` are shared hubs (q/q_val/q_one/setting/db/db_insert/now/url/e live in `Core`; add_xp/eff_mod/calling_perk/give_petals/tool_tier/hollow_today in `Player & Progression`). Dependencies on them are one-way and need no connector agents. All Core edges are INFERRED (name-resolved calls), so INFERRED dominates every cross-section count (cross-section total: 183 EXTRACTED vs 5514 INFERRED). Note `random_int()` (stub node in tests/combat_math_golden.php) is a PHP builtin mis-attached to a file; it is counted as Core and ignored in bridges.

| Section | Files | Nodes |
|---|---|---|
| Core | 49 | 468 |
| Player & Progression | 21 | 314 |
| Trek | 101 | 2305 |
| Roads & Expeditions | 54 | 615 |
| Garden & Almanac | 51 | 745 |
| Catfish | 13 | 355 |
| Delve & Pal Boons | 79 | 424 |
| Puzzles & Pals | 65 | 683 |
| Economy & Crafting | 47 | 639 |
| World & Social | 85 | 826 |
| Admin | 30 | 136 |
| Live Browser Tooling | 57 | 831 |
| Tests & Build Tooling | 66 | 747 |
| Docs & Design | 71 | 350 |

## Core
- **Purpose:** Shared platform: DB layer (q/q_val/q_one/db_insert/now), helpers (setting/e/url/money), bootstrap, schema, layout/theme, auth/account pages, inventory/items, updater and upgrade steps. Every other section depends on it one-way.
- **Owns:** game/includes (29), game (19), game/includes/data (1)
- **Files / nodes:** 49 / 468
- **Entry points:** game/account.php, game/index.php, game/guide.php; top symbols: q() (i/db.php), q_val() (i/db.php), setting() (i/functions.php)
- **Outbound (depends on):** Player & Progression (49), Roads & Expeditions (48), World & Social (47)
- **Inbound (depended on by):** World & Social (901), Garden & Almanac (759), Economy & Crafting (617)
- **Communities:** 26 (e.g. Adventure Import & Equip, Bootstrap & Boot Steps, Community 42)
- **Notes:** Hub sink: 4,169 cross-section edges in, 266 out. Change signatures here only with all-section review. `game/includes/functions.php` and `db.php` carry the god nodes.

## Player & Progression
- **Purpose:** Second-tier shared hub: the player's gnome, XP/callings/perks, rewards (petals), tools/equipment tiers, hollow clock and goals. Called by almost all gameplay sections.
- **Owns:** game/includes (10), tests (7), game (3), game/includes/data (1)
- **Files / nodes:** 21 / 314
- **Entry points:** game/book.php, game/gnome.php, game/hollow.php; top symbols: add_xp() (i/gnome.php), tool_tier() (i/tools.php), eff_mod() (i/gnome.php)
- **Outbound (depends on):** Core (274), World & Social (22), Economy & Crafting (16)
- **Inbound (depended on by):** World & Social (94), Garden & Almanac (89), Roads & Expeditions (75)
- **Communities:** 14 (e.g. Community 48, Community 76, Community 101)
- **Notes:** Treat like Core for dependency purposes; its callers (Garden 96, World 116, Roads 90 edges) do not each need a connector.

## Trek
- **Purpose:** Chapter-based Trek game: camps, fights, levels, knacks, events, old camp, chapter 1-3b data and text passes. Most self-contained gameplay section.
- **Owns:** game/includes/data (44), tests (40), game/includes (16), game (1)
- **Files / nodes:** 101 / 2305
- **Entry points:** game/trek.php; top symbols: trek_party_stats() (i/trek.php), trek_flag_set() (i/trek.php), trek_spots() (i/trek_data.php)
- **Outbound (depends on):** Core (392), Roads & Expeditions (20), Player & Progression (9)
- **Inbound (depended on by):** Core (25), Roads & Expeditions (14), Tests & Build Tooling (3)
- **Communities:** 55 (e.g. Trek Camps & Chapters, Trek Entry & Gates, Trek Acts & Trading)
- **Notes:** Only 34 edges to Roads (via combat_math/adventure.php combat) and <10 to others; tests (1,644 nodes) dominate its node count.

## Roads & Expeditions
- **Purpose:** Roads, stops, exploring and the adventure/expedition engine (adventure.php, explore, destination, journey, road life, stop acts and text).
- **Owns:** tests (20), game/includes (15), game/includes/data (9), game (5)
- **Files / nodes:** 54 / 615
- **Entry points:** game/adventure.php, game/back.php, game/journey.php; top symbols: stop_do() (i/stops.php), local_panel() (i/local.php), exp_log() (i/adventure.php)
- **Outbound (depends on):** Core (495), Player & Progression (75), World & Social (35)
- **Inbound (depended on by):** World & Social (73), Core (48), Delve & Pal Boons (22)
- **Communities:** 36 (e.g. Easy Roads & Exp Log, First Week & Festival, Pal Boons Sim)
- **Notes:** adventure.php is the shared expedition engine also used by Delve (delve_v2) and Trek combat. Highest peer coupling is with World (landmarks/maps/npc_life).

## Garden & Almanac
- **Purpose:** Garden, yard, flowers, almanac, pests, critters/animals, breeding, gathering, climate and crop data.
- **Owns:** game/includes (18), tests (15), game/includes/data (11), game (7)
- **Files / nodes:** 51 / 745
- **Entry points:** game/garden.php, game/tend.php, game/yard.php; top symbols: garden_action() (i/garden_logic.php), do_harvest() (i/garden_logic.php), ts() (i/garden_logic.php)
- **Outbound (depends on):** Core (759), Player & Progression (89), World & Social (22)
- **Inbound (depended on by):** Economy & Crafting (42), Core (37), World & Social (32)
- **Communities:** 34 (e.g. Admin Gourmand & Alchemy, Community Bed Almanac, Almanac Growing Box)
- **Notes:** garden_logic.php (ts, spend_energy, load_plot) is the main outward-facing API.

## Catfish
- **Purpose:** Catfish game and pet shops: catfish.php engine, pets, API, art/recolor tools and sims.
- **Owns:** tests (5), game (2), tools (2), game/includes (2)
- **Files / nodes:** 13 / 355
- **Entry points:** game/catfish_api.php, game/catfish.php; top symbols: catfish_yarn_spend() (i/catfish.php), petshop_page_html() (i/catfish_pets.php), catfish_state() (i/catfish.php)
- **Outbound (depends on):** Core (114), Tests & Build Tooling (30), Puzzles & Pals (8)
- **Inbound (depended on by):** Core (5), Player & Progression (3), Puzzles & Pals (2)
- **Communities:** 15 (e.g. Catfish Game Design, Catfish Sim Scripts, Community 56)
- **Notes:** Very self-contained: 119 edges to Core, few to peers. Tools import shared helpers from Tests & Build Tooling (EXTRACTED imports).

## Delve & Pal Boons
- **Purpose:** Delves (floors, chambers, maps, routes, stamps, v2), pal boons and their data, lint tools, sims and content drafts.
- **Owns:** claude/drafts (47), tests (10), tools (7), game/includes (6)
- **Files / nodes:** 79 / 424
- **Entry points:** n/a; top symbols: dv2_walk() (i/delve_v2.php), dv2_floor_html() (i/delve_v2.php), dv2_pick() (i/delve_v2.php)
- **Outbound (depends on):** Core (35), Tests & Build Tooling (29), Roads & Expeditions (22)
- **Inbound (depended on by):** Puzzles & Pals (12), World & Social (10), Docs & Design (7)
- **Communities:** 23 (e.g. Boons Docs & Lint, Community 73, Community 88)
- **Notes:** Reuses adventure.php (Roads) for scenes/logs. Content drafts under claude/drafts/ are owned here, not by Docs.

## Puzzles & Pals
- **Purpose:** Puzzle games, jigsaw, puzzle pals, pal jobs, player jobs, mini games and pal rosters.
- **Owns:** tests (26), game (20), game/includes (11), tools (4)
- **Files / nodes:** 65 / 683
- **Entry points:** game/paljobs.php, game/gotm.php, game/carve.php; top symbols: job_period_key() (i/jobs.php), ppal_spawn_refresh() (i/puzzle_pals.php), ppal_ensure() (i/puzzle_pals.php)
- **Outbound (depends on):** Core (504), Player & Progression (34), Tests & Build Tooling (30)
- **Inbound (depended on by):** World & Social (37), Garden & Almanac (20), Core (16)
- **Communities:** 50 (e.g. Mini Games, Community 40, Community 50)
- **Notes:** Pal jobs/jobs.php link into Garden (tend_action) and Economy (contests, alchemy). puzzle_pal_boons.txt is owned by Delve & Pal Boons.

## Economy & Crafting
- **Purpose:** Markets, crafting, pantry, gourmand, alchemy, trade, sinks, fairs/festivals, contests, shelves and shop data.
- **Owns:** game/includes (17), tests (17), game (8), game/includes/data (5)
- **Files / nodes:** 47 / 639
- **Entry points:** game/gourmand.php, game/market.php, game/fair.php; top symbols: notify() (i/trade.php), gourmand_serve() (i/gourmand.php), gourmand_serve_home() (i/gourmand.php)
- **Outbound (depends on):** Core (617), Player & Progression (59), Garden & Almanac (42)
- **Inbound (depended on by):** World & Social (39), Core (34), Puzzles & Pals (18)
- **Communities:** 29 (e.g. Craft Map, Market 100 & Baskets, Community 49)
- **Notes:** tools tier logic lives in Player; trade.php notify() is a cross-section bridge used by World and Puzzles.

## World & Social
- **Purpose:** Towns, townsfolk/villagers, world and region maps, landmarks, social/friends/community, letters, onboarding, mentors, moderation and region data.
- **Owns:** game/includes (29), tests (24), game (19), game/includes/data (9)
- **Files / nodes:** 85 / 826
- **Entry points:** game/welcome.php, game/world.php, game/community.php; top symbols: landmark_panel() (i/landmarks.php), apply_event_effect() (i/events.php), world_map_svg() (i/maps.php)
- **Outbound (depends on):** Core (901), Player & Progression (94), Roads & Expeditions (73)
- **Inbound (depended on by):** Core (47), Economy & Crafting (38), Roads & Expeditions (35)
- **Communities:** 55 (e.g. Account & Harvest, Callings & Password Reset, Admin Road Text)
- **Notes:** landmarks.php and maps.php call into Roads/Delve; world.php/town.php are called by Economy and Garden.

## Admin
- **Purpose:** Admin console pages (CRUD, jigsaw, road/trek text, settings, retention, usage) and admin helper/menu includes.
- **Owns:** game/admin (25), game/includes (5)
- **Files / nodes:** 30 / 136
- **Entry points:** game/admin/index.php; top symbols: art_progress() (i/art_upload.php), admin_puzzle_ui_detail() (i/admin_puzzle_ui.php), admin_nav_sheet() (i/admin_menu.php)
- **Outbound (depends on):** Core (68), Puzzles & Pals (12), Trek (2)
- **Inbound (depended on by):** Core (1)
- **Communities:** 23 (e.g. Community 119, Community 149, Community 187)
- **Notes:** 69 edges to Core; light coupling to Puzzles (admin_puzzle_ui, jigsaw). No connector needed.

## Live Browser Tooling
- **Purpose:** Impeccable live-browser skill: live-browser.js, DOM/session scripts, reference docs, plus .github agents. Independent of the game.
- **Owns:** .github/skills/impeccable (53), .github/agents (4)
- **Files / nodes:** 57 / 831
- **Entry points:** .github/skills/impeccable/scripts/live-browser.js; top symbols: connectSSE() (.github/skills/impeccable/scripts/live-browser.js), setLiveState() (.github/skills/impeccable/scripts/live-browser.js), resumeSession() (.github/skills/impeccable/scripts/live-browser.js)
- **Outbound (depends on):** 
- **Inbound (depended on by):** Core (2), Garden & Almanac (1)
- **Communities:** 36 (e.g. Live Browser UI, Live Params Panel, Live Editing Tools)
- **Notes:** Effectively isolated (only a few stub-induced edges to game code); 817 of its nodes come from impeccable scripts/reference.

## Tests & Build Tooling
- **Purpose:** CI workflow, cross-cutting tests (security, health, updater, shots, schema), art-generation scripts (gen_ico_*, gen_ph_*, hearth) and build helpers.
- **Owns:** tests (61), tools (2), tests/guide_src (2), .github/workflows (1)
- **Files / nodes:** 66 / 747
- **Entry points:** .github/workflows/ci.yml; top symbols: spec() (tests/gen_ph_folk.py), q() (tests/hearth.py), ci() (tests/gen_ph_folk.py)
- **Outbound (depends on):** Core (10), Puzzles & Pals (4), Trek (3)
- **Inbound (depended on by):** Puzzles & Pals (30), Catfish (30), Delve & Pal Boons (29)
- **Communities:** 57 (e.g. Python Script Imports, Community 43, Community 47)
- **Notes:** Provides gen_*/ico helpers imported by Catfish/Puzzles/Delve tools (EXTRACTED imports, 94 edges), a one-way library role.

## Docs & Design
- **Purpose:** Planning docs, specs, art briefs, handoffs, todo, changelog, README, mock HTML and draft content under claude/ and docs/.
- **Owns:** claude (63), docs (2), CHANGELOG.md (1), claude/gnome-mobile (1)
- **Files / nodes:** 71 / 350
- **Entry points:** README.md; top symbols: jigsaw_common.py save_pic() (claude/jigsaw-art-process.md)
- **Outbound (depends on):** Player & Progression (8), Delve & Pal Boons (7), Economy & Crafting (6)
- **Inbound (depended on by):** Catfish (4), Delve & Pal Boons (4), Economy & Crafting (1)
- **Communities:** 41 (e.g. Community 52, Community 118, Community 140)

- **Notes:** Low code coupling (mostly rationale/references edges to Delve, Economy, Catfish).

## Connectors

Threshold: a connector is proposed for a pair of peer domain sections (Core, Player & Progression, Admin, Docs, Live and Tests/Tooling excluded as one-way hubs or isolated) when they share at least 30 cross edges, well above the peer-pair median of 24 (19 peer pairs, 10 at or above 30 including the Delve exception), and where both directions occur. One exception: Delve <> Roads is below threshold (24) but 18 of its edges hit one file (adventure.php), making it a single critical contract. Pairs below 30 are left to Core-style one-way calls. Edge counts are E (EXTRACTED) / I (INFERRED).

| # | Sections | Edges (E/I) | Direction | Top bridging symbols | Contract |
|---|---|---|---|---|---|
| 1 | Roads & Expeditions <> World & Social | 108 (1/107) | World and Social->Roads and Expeditions: 73; Roads and Expeditions->World and Social: 35 | player_node() (i/adventure.php); npc_icon() (i/npc_life.php); apply_event_effect() (i/events.php); place_known() (i/roads.php); exp_log() (i/adventure.php) | World supplies maps/landmarks/npc_icon/place_known/events APIs and Roads supplies exp_log/player_node/active_expedition state; agree on the node/place slug schema and event-effect payload. |
| 2 | Economy & Crafting <> World & Social | 77 (2/75) | Economy and Crafting->World and Social: 38; World and Social->Economy and Crafting: 39 | notify() (i/trade.php); order_deliver() (i/market100.php); town_orders_html() (i/place_ui.php); {closure#28}() (tests/gourmand.php); can_reach() (i/world.php) | Economy calls world.php can_reach/place_ui town orders and trade.php notify(); both sides share the town/place slug and the order_deliver/notify signatures. |
| 3 | Puzzles & Pals <> World & Social | 65 (2/63) | World and Social->Puzzles and Pals: 37; Puzzles and Pals->World and Social: 28 | landmark_day() (i/landmarks.php); Per-place pal rosters (haven, wonder, delve, lair) (i/data/puzzle_pals.txt); job_period_key() (i/jobs.php); game_day() (i/games.php); pal_blocked() (i/pals.php) | Puzzle pals/games depend on landmark_day/landmark_scene_slug and region/place rosters (puzzle_pals.txt vs landmarks.txt); contract is place slugs and pal-roster format. |
| 4 | Economy & Crafting <> Garden & Almanac | 58 (4/54) | Garden and Almanac->Economy and Crafting: 16; Economy and Crafting->Garden and Almanac: 42 | user_building_bonus() (i/gardens.php); sh_bag_entries() (i/shelves.php); show_measure() (i/contests.php); spend_energy() (i/garden_logic.php); fair_quality() (i/fair.php) | Economy reads garden building/bonus and shelf/bag state (user_building_bonus, sh_bag_entries) and Garden spends energy and judges quality for contests/fairs; contract is the building-bonus and item-quality functions. |
| 5 | Garden & Almanac <> World & Social | 54 (2/52) | Garden and Almanac->World and Social: 22; World and Social->Garden and Almanac: 32 | ts() (i/garden_logic.php); spend_energy() (i/garden_logic.php); social169_water() (i/social169.php); region_by_slug() (i/world.php); almanac_place_notes() (i/almanac_notes.php) | Garden code (garden_logic ts/spend_energy) is called by community/social169 and Garden reads region_by_slug and place notes from world.php; contract is region slugs and the energy/time helpers. |
| 6 | Garden & Almanac <> Puzzles & Pals | 47 (0/47) | Puzzles and Pals->Garden and Almanac: 27; Garden and Almanac->Puzzles and Pals: 20 | tend_action() (i/player_jobs.php); ts() (i/garden_logic.php); pest_finish() (i/pest.php); load_plot() (i/garden_logic.php); job_event() (i/jobs.php) | player_jobs/jobs tend_action drive garden_logic plots and pest.php finishes via games.php; contract is the plot-load/tend/harvest function signatures and job_event payload. |
| 7 | Roads & Expeditions <> Trek | 34 (0/34) | Roads and Expeditions->Trek: 14; Trek->Roads and Expeditions: 20 | combat_turn() (i/adventure.php); fight_snacks() (i/adventure.php); gnome_combat() (i/adventure.php); snack_limit() (i/adventure.php); d() (i/combat_math.php) | adventure.php combat (combat_turn, gnome_combat, fight_snacks) uses Trek's combat_math.php and trek_fight.php; contract is the combat_math function set and fight result shape. |
| 8 | Economy & Crafting <> Puzzles & Pals | 33 (1/32) | Economy and Crafting->Puzzles and Pals: 15; Puzzles and Pals->Economy and Crafting: 18 | notify() (i/trade.php); job_period_key() (i/jobs.php); job_event() (i/jobs.php); contests_hub_rows() (i/contests.php); settle_shows() (i/contests.php) | jobs.php/pal_jobs.php rewards flow into contests/fair/alchemy and trade notify(); contract is job_period_key/job_event and the notify() signature. |
| 9 | Garden & Almanac <> Roads & Expeditions | 33 (1/32) | Roads and Expeditions->Garden and Almanac: 21; Garden and Almanac->Roads and Expeditions: 12 | ts() (i/garden_logic.php); spend_energy() (i/garden_logic.php); gather_on_walk() (i/gathering.php); start_expedition() (i/adventure.php); nice_time() (i/garden_logic.php) | explore/journey call garden_logic time/energy helpers and gathering.gather_on_walk, and adventure.php calls almanac milestones; contract is spend_energy/ts and gather_on_walk. |
| 10 | Delve & Pal Boons <> Roads & Expeditions | 24 (2/22) | Delve and Pal Boons->Roads and Expeditions: 22; Roads and Expeditions->Delve and Pal Boons: 2 | exp_scene() (i/adventure.php); exp_log() (i/adventure.php); give_find() (i/adventure.php); dv2_touch() (i/delve_v2.php); dv2_fight() (i/delve_v2.php) | delve_v2.php reuses adventure.php scene/log/find functions (exp_scene, exp_log, give_find); contract is the adventure scene and loot API. |

Not connectors: pairs with Core/Player & Progression (hub dependency), Tests & Build Tooling <> Catfish/Puzzles/Delve (library imports, handled inside the tooling owner), Admin <> Puzzles (12 edges).

## Unassigned / partially read

- **Unassigned nodes:** 0. 79 nodes have no source_file (external/builtin stubs such as Throwable, PDOStatement, Closure, RuntimeException); each inherited the majority section of its neighbours (the overlay's `section` field carries that inherited value). Most-common labels: Throwable x33, Closure x2, ref_child_process x1, pathlib x1, os x1.
- **Builtin mis-attachment:** `random_int()` in tests/combat_math_golden.php (72 cross-section edges) is a stub; counted as Core.
- **Partially read files (graph incomplete; assignment by path/name only):**
  - `claude/paljobs-final.html` (12 nodes) -> Docs & Design
  - `game/includes/data/puzzle_pal_boons.txt` (0 nodes; absent from graph) -> Delve & Pal Boons
  - `game/includes/data/road_events.txt` (0 nodes; absent from graph) -> Roads & Expeditions
  - `game/includes/data/stop_acts_regional.txt` (0 nodes; absent from graph) -> Roads & Expeditions
  - `docs/ui-consolidation-plan.pdf` (4 nodes) -> Docs & Design
  - `.github/skills/impeccable/reference/degraded/documenter.md` (1 nodes) -> Live Browser Tooling
- **Mixed communities:** 34 communities with >=10 nodes have no section holding 70% of their nodes (e.g. Account & Harvest, Bootstrap & Boot Steps, Admin Gourmand & Alchemy); `sections.json` lists each under its majority section only. Use file ownership, not community id, as authority.
