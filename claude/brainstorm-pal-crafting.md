# Brainstorm: pals working crafting stations

Read-only on game code. Facts cite file:line. "Proposal" = my design, not in code.

## 1. Existing model (facts)
- Job kinds: garden, trip, delve (pal_jobs.php:4). Column `kind` is VARCHAR(8) (puzzle_pals.php:87). `station` fits.
- Send gate `pj_can_send` (pal_jobs.php:220-233): level, settle, pal home, HP >= 1, not on party, `pj_max_away`. Claim = one conditional UPDATE (214-217).
- Caps: `pj_max_away` = 3 counts ALL active + ready jobs (pal_jobs.php:46, 230-231). `pj_runs_per_day` = 6 counts ONLY trip + delve (47, 192-195).
- Settle `pj_settle` (pal_jobs.php:201-211): active -> ready by conditional UPDATE. Non-garden: pal home with HP from `result.hp` (line 209).
- Collect `pj_collect` (pal_jobs.php:615-646): ready -> done claim (line 621). Items loop reads `result.items` as [item_id, qty, name] (line 632). Receipt title (line 625) falls to "the wilds" for a non-trip target.
- Home pill `pj_home_count` (pal_jobs.php:652-656) counts kind IN (trip, delve) only.
- Pal skills: `g_xp`, `a_xp` columns on ppal_found (puzzle_pals.php:102-103). Level from PJ_XP, 1-10 (pal_jobs.php:20, 51-56).
- `pj_add_xp($uid, $key, $g, $a)` (91-95). `pj_pals()` exposes g, a, gxp, axp (113-131). Equipped pals earn 1 of each per hour, cap 24 (26, 98-107).
- HP: `12 + 4*hardiness + 3*(A-1)` (65-68). A station pal does not fight, so HP stays put.
- Pal `calling` exists (PPAL_CALLINGS, puzzle_pals.php:15). `brewroot` maps to perk `gather` (puzzle_pals.php:18).
- Migration: `ppal_ensure()` ALTERs any column listed in `ppal_schema()` $c that is missing (puzzle_pals.php:122-124). Fresh installs use the same list (puzzle_pals.php:47). So a new column = one row in $c. No version gate.

## 2. Crafting-side facts
- 7 areas (crafting.php:12-20). Scenes: 5 tagged objects each, so 35 slots (includes/data/craft_scenes.php).
- Tags are fnmatch globs (`craft_tag_match`, craft_map.php:18-22). One recipe can sit on several objects: `*-tea` is on Stove, Watering can, Seed trays (craft_scenes.php:9, 28, 31).
- `craft_stations()` (crafting.php:94-102): plot id for kitchen and tool_shed, -1 for no building (garden, potions, building, decor), 0 missing. So plot_id is NULL for 4 areas. The slot key must be target text "area:object".
- Known recipe = a user_recipes row (crafting.php:217). `craft_recipes()` learns when all ingredients were seen (crafting.php:105-144).
- `craft()` gates: station (221-225), feast needs Kitchen III (227-229), pantry branch (230), cooking branch (231-242).
- Energy `craft_energy_cost` (crafting.php:172-179). Cooking energy by tier (snack 0, meal 1, feast 2 by default).
- Ingredients: `craft_stock` (150-169), `craft_fit` (182-189), `craft_short_text` (192-204).
- Instant areas: one transaction, energy and ingredients taken, output at once (crafting.php:257-270). XP 15 per tools make, else 5 (line 273).
- Pots: `cook_start` (353) writes cook_pots rows. `cook_pot_limit` (293-302), `cook_pots_busy` (305-308). Default '2,3,4' (functions.php:540).
- Jars: PANTRY_KINDS (pantry.php:37), 1 to 14 real days. `pantry_start` (152-158) checks the room's free jars.
- Quality hooks: `gourmand_dish_score` (crafting.php:382) and `market_note_quality` (market100.php:373).
- Popover: `craft_pop_html` (craft_map.php:142-178), tabs Can craft / Missing / Unknown. Row actions (line 171) come from `sh_craft_entries` (shelves.php:160-200), built per RECIPE. A per-object "let a pal cook" button needs per-object actions.

## 3. Options
### A. Pot Hand (send-time only)
- Sets: object, one recipe or all, hours (pal's walk only).
- Ingredients: taken at send through existing craft(), cook_start(), pantry_start().
- Output: the gnome's own pot or jar. The pal makes nothing itself.
- Energy: normal craft cost.
- Pots/jars: real ones, used up.
- Pros: almost no code, no new collect path. Cons: the pal does nothing while away. Crafting skill has no effect.
- Exploits: none new.

### B. Reserved Shift (recommended)
- Sets: area + object, mode "all" or "chosen" (up to 5 known recipes), hours 1/3/8 (PJ_TRIP_HOURS, pal_jobs.php:23).
- Ingredients: reserved at send in one transaction, like craft() (crafting.php:257-270). Plan uses ONE in-memory ledger, since recipes share items.
- Output: rolled at send, stored in result.items, given by pj_collect's existing loop (line 632).
- Energy: gnome pays craft energy per make at send. No night discount.
- Pots: cooking shifts count in `cook_pots_busy` (one added COUNT at crafting.php:307). The pal cannot beat the pot limit. Pantry out of v1.
- Pros: reuses trip settle and collect. Ingredients cannot vanish mid-shift. "Why it stopped" is decided at send.
- Cons: fixed batch, no top-up mid-shift.
- Exploits: duplicate blocked by the collect claim (line 621). Recipe bypass blocked by user_recipes (217). Building and feast blocked by craft_stations and Kitchen III (221, 227). Night cooking still costs energy. No recall refund (a refund would be an exploit).
- Levers: makes per shift, capped by hours and Crafting level (proposal: 1 make per 30 min at C1, 1 per 10 min at C10). Extra-output chance 4 x (C-1) % (like pj_garden_extra_pct, pal_jobs.php:19-23, cap 36). Per-day station cap (new setting, like pj_runs_per_day). Petal fee per shift (take_petals, rewards.php:29). Rarity scale (pj_rare_mult, pal_jobs.php:71-74).

### C. Standing Order (live draw)
- Sets: object, mode, hours. Pal refills pots and jars each time one frees, until hours end or stock runs out.
- Ingredients: drawn live from the satchel each cycle.
- Output: the gnome's own pots and jars.
- Needs a settle tick like garden stays (pj_garden_finish, pal_jobs.php:71-87). Loops cook_start inside pj_settle (line 201).
- Pros: pal works all shift. Cons: drains the satchel and spends energy while the gnome is away. Many writes. A half-run must explain itself each time.
- Exploits: stock drained while asleep. Race between gnome and pal on the same pot (cook_start checks pots at crafting.php:359-361 before its transaction).
- Levers: keep-N thresholds, pal reserve %.

### D. Permanent Post
- Pal stays on an object with no end. Makes up to a daily cap. Gnome stops it.
- Pros: strongest fantasy, least UI. Cons: largest exploit surface (energy, stock, settle timing). No ends_at, so it breaks the job model. Not for v1.

## 4. Rules for every option
1. Known recipes only: user_recipes row for each plan item (crafting.php:217).
2. Station must exist: craft_stations()[cat] != 0 (crafting.php:221-225). Feasts need Kitchen III (227-229). Pantry needs a free jar (pantry.php:158).
3. One pal per object per gnome: check target "area:obj" in active or ready. Copy the garden check (pal_jobs.php:289-302) but key on target, not plot_id.
4. Recipes tagged to that object only: craft_tag_match with the object's globs (craft_map.php:18).
5. Ingredients present at send. One ledger, so recipes that share an item cannot both spend it.
6. Stop and report: say why (craft_short_text, crafting.php:192) and "only N fit" (crafting.php:241, 280).
7. No refund on recall. Output given once, via the ready -> done claim (pal_jobs.php:621).

## 5. UI sketch (words)
- Jobs board: a 4th post "🍳 Cook at a station". Add a row to $posts (paljobs.php:143-147). Board loop paljobs.php:265-334.
- Form: object select grouped by area. Mode radios: "Everything it can make" / "Only these", then a checkbox list of that object's known recipes. Hours via $seg (paljobs.php:162-166).
- Preview line: "Bread oven: 3 known, 2 ready, 1 missing Wheat".
- Pal list ranked by Crafting, the same way as today (paljobs.php:36 sort key).
- Ledger: "Bramble · Bread oven · 3 h · 4 makes". Add a case to jobLine (paljobs.php:132-137) and kindTxt (line 131).
- Pal Book chips: add "🍳 Crafting N" next to 🪴 and 🧭 (paljobs.php:246-247).
- Popover: header button "Post a pal here" (craft_map.php:156). When one is out: "Bramble is here · 2 h left".
- Can craft rows: "Let a pal cook this" beside Make (craft_map.php:171, shelves.php:198).
- Hotspot: small 🧩 badge on a posted object (pattern of craft_map.php:128-130).

## 6. Test plan and migration
- Migration: add ['ppal_found', 'c_xp', 'INT NOT NULL DEFAULT 0'] to $c (puzzle_pals.php:101-104). ppal_ensure adds it to old databases. No new table. Existing idx_ppal_jobs_user covers the state filter.
- tests/paljobs.sh, new block after line 104: seed user_items, a kitchen garden_buildings row, a user_recipes row. Then POST send_station and check: ingredients and energy taken; second send to the same object refused; unknown recipe refused; no-kitchen refused; collect gives items once; second collect refused; c_xp grows; no inline style attribute.
- tests/craft_tags.php: existing check (every tagged recipe lands on an object) still holds. Add: each object has at least one recipe.
- claude/paljobs-sim.php: a station section. Plan per Crafting level and hours. Value uses the sim's worth() and 62% price rule (sim lines 15-17, 25).
- Plan function pal_jobs.php: pure given a stock map, so unit-testable (shared-ingredient ledger case).
- MySQL not run before (handoff). Run the sqlite and MySQL paths both.

## 7. Recommendation: Option B
Build steps:
1. [S] M: pal_jobs.php. Add c_xp plumbing (pj_add_xp 91-95, pj_pals 113-131). Add pj_station_plan, pj_station_send, a pj_collect branch (625, 639), and kind 'station' in pj_home_count (652-656).
2. [S] S: puzzle_pals.php. Add the c_xp row to $c (101-104).
3. [S] S: crafting.php cook_pots_busy (305-308). Count active station cooking jobs too.
4. [S] M: paljobs.php. Whitelist send_station (line 29), match case (66-74), $posts (143-147), $blocked (148-158), option form (pjopts 311-328), Crafting chip (246-247).
5. [S] M: shelves.php sh_craft_entries (160-200) per-object actions. craft_map.php popover button and header (142-178).
6. [H] S: functions.php settings rows next to pj_runs_per_day (line 415): per-day station cap, petal fee.
7. [H] S: tests/paljobs.sh block; craft_tags.php object check.
8. [H] S: claude/paljobs-sim.php station section.
9. [H] S: handoff note, version bump, check_versions.sh.

## 8. Open questions
1. Pantry in v1, or later? Real-day jar timers do not fit a 1 to 8 hour shift.
2. Masterwork tools by pal: allowed, or keep for the player?
3. Do pal shifts count toward pj_runs_per_day (6), or get their own cap?
4. Pal cooking uses the gnome's pots (default here) or its own slots?
5. Do pal crafts count for the Job Board and calling questlines (job_event, crafting.php:272), and for gnome Crafting XP?
