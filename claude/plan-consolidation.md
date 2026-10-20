# Gnome Venture: consolidation plan (2026-10-17)

From the overlap review (Sonnet, 2026-10-17).
Rule: one job = one place. Never remove access to a page without a link from its hub.

## Done
- 1.7.0: stamps+reactions merge, "Guestbook" rename, one visitor notice/day, duplicate menu links, Getting started link, garden "Need help?" panel.
- 1.7.1 (Phase A): Today Home one jar/Pulse row; admin settings labels prefixed + grouped; unlinked pages audit (no orphans).
- 1.7.2 (Phase B, done early because few players yet = little disruption):
  - jobs.php = "📋 Tasks", tabs ?t=jobs|quests|orders|errands (sub-tab ?p=daily|weekly|monthly|post). Helpers in includes/quests_view.php (tasks_counts/quests/orders/errands/order_post). town.php?view=quests → jobs.php?t=orders (POST too); jobs.php?s=quests → t=quests. Order + favour POSTs handled in jobs.php. journey.php `back` now also accepts jobs.php?… (Journey hand-in buttons on Quests tab not built yet).
  - community.php = "🌻 Together", tabs ?t=garden|jar|about; hollow.php redirects to ?t=jar. Jar tier settle runs on jar tab + Today.
  - Names: "Gnome friends" (players), "Villagers" (NPC folk; rest-stop tab, world map, gnome page, Almanac heading). Almanac chapter key "Folk" unchanged. mentor.php = "Calling mentor", pals.php?tab=mentor = "Gnome mentor" (two different features, both kept).
  - games.php?tab=contests = hub cards (Show, Fair, GotM, Pumpkin Carving) with status + entered + one button (contests_hub_html in includes/contests.php); entry pages have "← Contests".
  - Menu: Together / Tasks / Gnome friends / Villagers; Hollow tile gone; bottom bar "Tasks".
  - Tests updated: social100.sh, mentors120.sh (Together URLs, tab label), games2.sh (counts `box ccard`).

## Phase C (code tidy, no player change)
- `gate_can_interact()` for every visitor action (started 1.7.0).
- Fold social169 into the social module; small dispatch table in visit.php.
- One shared roll-up notice helper for repeat notices (friend requests, gifts, visitors).
- One event hook for "did X today" (daily card, First Week, Hollow Goals, callings).
- Tasks menu badge: use tasks_counts() total (cache per session; it queries DB).
- Journey hand-in buttons directly on Tasks → Quests.
- Remaining "Folk"/"Hollow page" wording in includes/almanac_notes.php (148, 183, 184).

## 2026-10-20 review (Sonnet audit + positive/negative/critique agents, v2.0.2) — supersedes "Phase C" event-hook idea
Verdict: no big merges. Data + cuts + delve map. Map = delves/lairs only. Details: scratchpad final.md summarized below.

### Phase 0 (measure, free)
- Count live rows: player_jobs, garden_hires, npc_favours, stop_errands, stop_friend, game_scores per game. Every cut gated on this.
- Joshua plays Ch II-a on phone, notes map bugs (todo.md:38).
- Rule: new system must delete one. Park caravans/mines/postcards.

### Phase 1 (cheap, no schema)
- Open Treks once text approved (check trek_ms / trek_flag_set MySQL watch).
- Data fill: road_events for 11 empty regions, delve room lines, more finds per land (2 now), 4 missing stop chat personalities.
- Admin editor for road_lines/events/problems/creatures/wonder_text (reuse trek_text editor, key prefixes).
- "Villagers" = one meaning. Settings search box + advanced flag (no key deletions).
- Drop Daily card. Cut weakest mini-games ONLY if game_scores says so.
- Fold Seasons, Passport, Villagers into Town/World (menu 19 -> ~14).

### Phase 2 (pays back)
- give_petals()/give_xp() wrapper (coins touched in 38 files); migrate lazily.
- Merge 3 shops (region shop, Trading Post, Market Day) onto shop_tile+dialog BEFORE picture-tile restyle.
- combat_math.php extract right before delve maps; trek tests = net.

### Phase 3 (map adventuring, optional view, phone-first)
- 3a tilemap core: NEW module + new table walk_scene. Do NOT edit trek_walk/trek_runs in place. After Ch I/II text settles.
- 3b delve/lair maps first: 11x11 seeded, cave art, 1v1 combat from a tile, 3-4 hand-built showpieces, 5-room fallback. Fix phone map bugs first.
- 3c garden visits: no walking (already a grid).
- 3d roads: keep single Move button default; optional read-only strip later; forks (safe/long vs risky/short) would add agency, defer.
- Gate after 3b: delve completion + taps/session decide more.

### Dropped
- Reward event bus (double-count risk), Requests merge (Orders+Errands+Favours), contests single engine, NPC system unify (labels only), town maps (146 villages), tile wander, full menu fold, deleting settings keys/live tables.

### Order
P0 > P1 > shops+wrapper > combat_math > 3a > 3b > gate. One zip per step.
