# Explore / road / world review (v1.9.2, Treks excluded)

Read-only review. No game files touched. Refs are `game/...` paths.

## 1. Verdict in 5 lines

- The road and the wilds draw from the **same four small pools**, filtered only by landscape (9 lands). Region identity (15 regions) never shows up on a walk.
- **Zero** use of season, weather, daypart, festival, NPC, other players, Hollow Goals, garden animals or Almanac state on the road/explore/landmark screens (grep: 0 hits in adventure.php, explore.php, landmarks.php, roads.php, gathering.php, destination.php, seek.php, world.php).
- **No anti-repeat anywhere.** Every pick is `array_rand` / `random_int` (adventure.php:341,346,356,364; explore.php:282,299).
- Rest stops (stops.php, stop_*.php) are the good model already: cond engine `dp=/se=/we=`, 12 types x 4 ambience lines, 55 activities, villagers. The road does not borrow any of it.
- UI is half old: fight and problem use `.choice` rows; off-path choices, step/explore/delve buttons, landmark buttons still use old `.btn` forms.

## 2. What a player sees, step by step

### Road walk (adventure.php + adventure.php `next_step`)
1. World page: pick a gocard. Walk = 4 legs per road (town, 3 villages, town), `ROAD_STEPS = 3` per leg (roads.php:19), 6 min per leg, 1 energy per leg.
2. Adventure page: title `X -> Y`, map, static `h3` "The thread glows on ahead..." (adventure.php:~247), one button "Move to the next space".
3. Each space rolls once (adventure.php:415-436): **40% creature, 30% problem, 30% find**. Nothing else exists on the road. No narration, no choice cards, no quiet beats.
4. Creature: log line "A Garden Snail blocks your way!" then fight card (good, new UI).
5. Problem: one of 20 d20 puzzles, resolved as 3 `.choice` rows.
6. Find: `give_find` (adventure.php:379): 60% try gather (needs tool) else 35% local seed / 35% one of **2** landscape items / else Petals.
7. Arrive: "You arrive at X", Almanac page, XP. Redirect to town.php.
8. A full road = ~12 spaces = ~5 fights, ~3.6 problems, ~3.6 finds. All from the pools below.

### Wander (explore.php)
Per step (explore.php:~250-310): creature 27, problem 13, choice 22, hidden place 12-16, sight ~7-11, find ~15. Choices (14), sights (12) and hidden-place text are the only variety beyond the road. Reward for returning is once per stop per day (`xbonus`, explore.php:~365).

### Landmarks (landmarks.php, landmark.php, panel on world.php)
| Kind | Count | What happens | Variety problem |
|---|---|---|---|
| Haven | 18 | Rest +4 energy (1/day), stay 20 Petals for a 2h buff, 3-4 pantry items | Same text everywhere. Pantry is random seed/food/find, not the "maple syrup", "cocoa house" the descriptions promise (landmarks.txt header says "special shop"; not implemented). |
| Wonder | 35 | 3 stat approaches, 1/day, Petals + uncommon/rare + 25% seed | Success/fail text is **one string for all 35** (landmarks.php:~190-199). Message says "it changes with the days" (landmarks.php:180) but approaches and DCs are fixed by name hash. |
| Delve | 14 | 5 rooms: creature / problem / 2 finds, chest | Rooms have **no text** beyond "Room 3 of 5". Same pools as the road. Chest text identical. |
| Lair | 14 | Own boss per lair (good: `ensure_lair_bosses`) | One intro line, no win/lose story. |

### Rest stop / town
- Rest stops: good. Ambience per daypart, 3 villagers each, 55 activities with time/season/weather gates, chat lines, errands, passport, adopt tiers.
- Weak spot in stops: `stop_chat.txt` has only 32 lines; 4 of 12 personalities (Warm, Eager, Fussy, Dreamy) have **no own lines**; no line is per stop type or region; chat line is fixed per gnome/folk/day/daypart (stop_folk.php:144).
- Towns (towns.txt): 30 spots, 30 actions, 45 lore lines for 15 regions (2 spots each). Region flavour exists here and nowhere on the road.

## 3. Counts (variety)

| Pool | Total | Per landscape | Specific to a region? | File |
|---|---|---|---|---|
| Creatures (non-boss) | 88 | forest 25, grass 22, mountain 20, wetland 20, coast 19, rain 19, desert 18, island 15, **tundra 11** | none | creatures.txt |
| Bosses | 9 template + 14 per-lair | 1 per land | per lair only | creatures.txt, landmarks.php:375 |
| Problems | 20 | island 5, tundra 6, coast 7, desert 7, wetland 7, grass 9, mount 9, rain 9, forest 10 | none | problems.txt |
| Landscape finds | **18** (2 per land) | 2 | none | adventure_data.php:29 |
| Gatherables | 69 | 8-16 | none; need a tool | gatherables.txt |
| Off-path choices | 14 | all lands | none | explore.php:179 |
| Off-path sights | 12 | all lands | none | explore.php:159 |
| Page-view random events | 49 (41 instant) | all | none; 1 in 150 views, 3/day, 2h apart (functions.php:331-333) | events.txt |
| Road-specific flavour lines | **0** | | | |
| Village descriptions | 9 texts for 146 generated villages | | | adventure_data.php:~125 (`LANDSCAPES[$land][2]`) |

Creature pool the player actually rolls from (level-6..level+2, one landscape), by gnome level:

| Level | forest | grass | coast | mount | desert | rain | wet | tundra | island |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 4 | 3 | 4 | 4 | 5 | **2** | 3 |
| 5 | 8 | 8 | 6 | 5 | 6 | 7 | 9 | **4** | 5 |
| 12 | 5 | 7 | 5 | 4 | 5 | 4 | 4 | **2** | 3 |

So 3-5 distinct creatures per land per level band is normal, tundra 2. With ~5 fights per road you see the same creature twice per walk.

### Where repetition comes from
1. Small pools (above), landscape is the only filter.
2. No memory: independent rolls each step (pure `array_rand`). Birthday-paradox repeats within one leg.
3. No time/weather/season filter: problems "Night falls..." (problems.txt:21), "Fog rolls in..." (:18), "The tide is coming in" (:13), "The sun beats down" (:23) fire at any time and weather. This is a visible logic bug, not just dullness.
4. Static copy: title h3, button, Latest line format identical every step.
5. Same pools reused for road, wilds, delves (delve_next:228-262). Delves feel like a longer road.
6. Region only matters for local seed drops and a climate "rich finds" %.
7. Choices (the best variety, 14 of them) are not on the road at all.

## 4. World signals that exist and are unused on the road

| Signal | Where it lives | Used on road/explore/landmark? |
|---|---|---|
| Daypart | `hollow_daypart()`, `stop_now()` | no (stops yes) |
| Season | `hollow_season()` | no |
| Weather per region | `hollow_weather($code)`, 9 types, region leanings | no |
| Festivals | `festival_active()`, `town_festival()` | town only |
| Hollow Goals / jar | hollow_goals.php; road already feeds it via `calling_event('walk','arrive')` | feeds, never shows |
| NPC lives | `npc_now()`, `traveller_stop()` (3 travellers, 12h per town) | town only |
| Stop villagers (3 per stop, friendship) | stop_folk.php | stop only |
| Other players | `stop_log`, stamps, adopter plaque, `hollow_pulse` (names, opt-in) | stop only |
| Calling | `calling_perk()` | only numeric perks (spot_pct, wonder_bonus, free_walks) |
| Almanac progress | `user_encyclopedia` | only "new page" log lines after the fact |
| Garden animals | garden_critters / animals tables | no |
| Friends (pals) | pals.php | no |
| Level | `outlevel_percent` | yes (good) |
| Stop type ambience | `stop_types.ambience` 12 x 4 lines | stop page only |

## 5. Gaps vs newer systems

| New system | Old explore equivalent | Gap |
|---|---|---|
| Trail events with `trek_event_pct` + `trek_event_gap`, one pending, not same as last (trek_events.php:152,169) | Fixed 40/30/30 roll | No gap/percent knobs, no "not twice in a row". Trek's anti-repeat is only "not the last one": copy it, but make it 3-8 deep. |
| Crew moments (once per recruit per run) | none | No companion/villager beats on the road. |
| Riddle stone, stuck cart, mushroom camp (hand-placed spots) | none on road | Roads have no fixed "places", only rolls. |
| Draft-text system (`trek_texts`, status draft, admin editor, fallbacks) | Texts hard-coded in PHP consts (explore.php:159-222) and txt files | Joshua cannot edit road text in admin. Trek editor is tied to chapters (admin/trek_text.php filters). |
| `.choice` rows + odds badges | Off-path choices still `<form class="option"><button class="btn">` + help span (adventure.php:~168-176); step/deeper/delve/landmark buttons plain `.btn` | UI looks a generation older than the fight card. |
| Fight log / replay | Works on all kinds (good) | none |
| `<dialog>` (chest, picker, trek plan) | Never used on the road | Not needed everywhere (see section 7). |

Test constraint: `tests/explore.sh` greps `value="choose"`, `value="solve"`, `value="attack"`, `value="auto"`. Keep those hidden `do` fields when restyling.

## 6. Proposals, ranked (vibrancy / cost)

Shared helper idea (used by 1, 2, 3, 4): `road_pick(array $rows, string $kind, array $ctx)` in a new `includes/road_life.php`. It applies the recent ring, cond weights, and region tags. All existing pickers call it.

| # | Proposal | Effort |
|---|---|---|
| 1 | Anti-repeat memory | S |
| 2 | Time/weather/season conds on problems, creatures, gatherables | S |
| 3 | Ambient lines (road + arrival) | S-M |
| 4 | Choice cards on the road + region packs | M |
| 5 | Wandering travellers and stop villagers met on roads | M |
| 6 | Traces of other players | S-M |
| 7 | Landmark flavour and honest "changes with the days" | M |
| 8 | Chained mini-stories ("Tales") | M-L |
| 9 | Festival / Hollow Goal / Almanac chips | S |
| 10 | UI parity (`.choice` rows, result card) | S-M |
| 11 | Calling and companion lines | S |
| 12 | Delve rooms with text and themes | M |

### 1. Anti-repeat memory (S)
- **What:** keep the last ~8 picks per kind (creature slug, problem slug, choice id, sight id, ambient line id, find item). Weight 0 for the last 3, x0.3 for the next 5, else 1. Fallback to full pool if everything is filtered.
- **Player sees:** no snail twice in a leg, a different puzzle each space.
- **Files:** new `includes/road_life.php` (helper); `adventure.php` pick_creature/pick_problem/give_find; `explore.php` choice/sight picks; `schema.php` one column `users.road_recent TEXT NULL` (alter list near schema.php:1388).
- **Data:** 0 lines.
- **Risk:** none for balance. Race: write happens inside the existing `beginTransaction` + user row lock (adventure.php:40-44), so safe. Keep tiny JSON (<300 bytes). Also cache `SELECT * FROM creatures` per request (it is reloaded on every pick, adventure.php:~333).

### 2. Cond tags using the existing stop engine (S)
- **What:** reuse `stop_cond_ok()` / `stop_now()` (stops.php:297-324). Add an optional last column `cond` to problems.txt, creatures.txt and gatherables.txt. Hard filter for story-wrong ones (night, fog, tide, heat); x3 weight for matches (rain: mushrooms, snails, frogs; night: moths, owls, foxes; winter: frost hare).
- **Player sees:** fog problem only in fog, mushrooms bias after rain, moths at dusk. Weather becomes visible without any new reward.
- **Files:** adventure_data.php import_problems (line ~221), import_creatures_txt, ensure_gatherables; one upgrade step to set cond on existing rows (importer skips existing slugs, so an upgrade_NNN like upgrade170.php is needed); pick_problem, pick_creature, gather_candidates.
- **Data:** tag ~6 problems, ~20 creatures, ~15 gatherables. Add ~8 new weather/season problems (frozen puddle, mud after rain, heat shimmer, falling leaves, snow drift, storm shelter, dew-web, windy hat).
- **Risk:** low. Do not hard-require weather for rewards; bias only. Region weather via `hollow_weather($code)` already deterministic.

### 3. Ambient lines + stop ambience on arrival (S-M)
- **What:** new `data/road_lines.txt`, format `cond|lands|region|text`, same cond syntax as stop_chat.txt. One line per space, shown in the "Latest" slot and the log, before the encounter. Replaces the static "The thread glows on ahead..." with a picked line. On arrival, also log the destination stop type's **existing** ambience line for the current daypart (`stop_types.ambience`, 48 lines already written, stops.php:35).
- **Player sees:** "Rain drums on the mushroom caps. The path smells of wet bark." / "A far-off kettle whistles from the next stop." Every step reads differently.
- **Files:** road_life.php (loader, copy `stops_file_rows`), adventure.php next_step + h3, explore.php explore_deeper, adventure.php arrive().
- **Data:** ~120 lines to start: 9 lands x (4 dayparts + 3 weather) = 63 base, plus 20 seasonal, plus 15 region lines, plus 20 "quiet" lines for find steps. Use Claude drafts, Joshua edits.
- **Risk:** zero rewards. Keep each under ~120 chars.

### 4. Choice cards on the road + region event packs (M)
- **What:** move `OFFPATH_CHOICES` from a PHP const to `data/road_events.txt` (same tuple shape, so `explore_choose` stays). Add fields: `region` (or any), `cond`, `where` (road/wild/both), `chain` (see 8). Let `next_step` roll a choice card instead of ~15 of the 30 problem points: new split e.g. fight 35, problem 20, choice 15, find 30. Region packs: 4-5 per region (Maplewold sugar-bush bucket, Dunewhisper mint-tent, Monsoon Tangle floating market, Mistmoor stone-wall sheep...), using the real-world flavour in regions.txt.
- **Player sees:** a different little scene on a road, with a stat roll and an odds badge, set in the region they are walking through.
- **Files:** explore.php (const -> loader), adventure.php next_step + adventure.php choice branch already exists in the POST handler (`explore_choose` is reused), new data file.
- **Data:** keep 14 generic + ~60 region (15 x 4) + ~15 season/weather = ~90 events. Start with 3 regions (the starter ones) = ~25.
- **Risk:** reward faucet. Rules: on the road choices pay xp / small Petals / buffs / heal, items only with `@chance` <= 20% and common/uncommon; reuse `outlevel_fx` so outgrown areas pay less; energy is already the brake (1 per leg). Keep `pay:` events (checked first, no free money). Race: `explore_choose` already runs under the user lock.

### 5. Wandering travellers and villagers met on the road (M)
- **What:** pure function of the clock, no DB movement, like `traveller_stop()` (npc_life.php:146).
  - **Travellers (3):** if a traveller's current or next town is one end of this road, ~20% of find-steps become "You pass Lyra Fiddlewing on the road" with 1 line + a tiny perk (Lyra: charm +1 for 30 min via `tbuff`; Tobias: tells today's rare seed town; Wren: hints at a gatherable you have not found, using seek). 10 lines.
  - **Stop villagers:** `stop_pick_folk` + hash(day, hour/3, folk id) decides if folk F of stop S is "on the road toward the next stop". Meeting = the same line engine as `stop_chat_line`. Counts as that day's chat for that villager (same claim key), so it is **not** an extra friendship faucet.
- **Player sees:** "Pip Thistledown from Mossgrove Mill is hauling flour to the next village. 'Tell them I am coming!'" Then the same Pip is in a different place later. At the stop: "You passed Pip on the road."
- **Files:** road_life.php, stop_folk.php (reuse), adventure.php next_step.
- **Data:** ~30 pass-by lines (3 travellers x 3 + 12 stop-type "carrying X" lines + generic).
- **Risk:** friendship fp: tie to the existing once-a-day claim. Traveller buff: reuse `tbuff` slot (does not stack with random events).

### 6. Traces of other players, no typing (S-M)
- **What (tiers, do the cheap one first):**
  1. **Counts from existing tables:** at each road space, "Fresh bootprints here: 3 gnomes passed today" from `COUNT(DISTINCT user_id)` on `stop_log` + `stop_stamps` for the destination/origin stop today (no names, no blocks issue). Adopted stop: "The bench built by [adopter] is ahead" (plaque already exists, respects `stop_gnome_label`).
  2. **Hollow Goal jar line** on the road: "The Hollow is 63% of the way to this week's goal" from `hollow_goals_active()`. Already feeds on walks, never shows.
  3. **Cairn (optional):** one tap per stop per day to add a pebble. New tiny table `stop_cairn (loc_id, day, n)`; shows "Cairn of 41 pebbles". Preset only, no text.
- **Player sees:** the road feels travelled by real people.
- **Files:** road_life.php, stop_pass.php (read), hollow_goals.php (read), new table for tier 3.
- **Data:** ~12 lines (bootprint, ashes warm, kettle still warm, new rope, etc.).
- **Risk:** privacy: counts only, never names unless opt-in `pulse_show` + `garden_public` and not blocked (copy `hollow_pulse_build` filter). No Petal reward for the pebble.

### 7. Landmark flavour + make "changes with the days" true (M)
- **What:** optional columns on landmarks.txt rows: `win`, `lose`, `intro` per landmark. Wonders: fall back to a stat-based pool if blank (6 stats x 3 = 18 lines). Rotate the two non-own approaches by `crc32(name|day)`; own stays easiest. Add a daily mood line (cond-based: dusk, rain). Havens: honour the description via an optional `special` item slug (maple syrup, cocoa...) added as the pantry's 4th slot. Lairs: `intro`/`win`/`lose` lines.
- **Player sees:** each of 35 wonders reads like a place, not a die roll.
- **Files:** landmarks.php (wonder_try, wonder_approaches, haven_pantry, lair_start/victory), landmarks.txt importer in adventure_data.php:~110 (new columns + upgrade step to backfill).
- **Data:** wonders 35 x 2 = 70 lines (start with 10 + 18 fallbacks), havens 18 x 1, lairs 14 x 3 = 42. Do it in batches.
- **Risk:** none (no reward change). Fix the false claim at landmarks.php:180 first if rotation is not built.

### 8. Chained mini-stories ("Tales") (M-L)
- **What:** 6-8 short stories of 3 beats across consecutive legs/stops. Example "The Lost Mitten": beat 1 on the road (find a mitten; keep or ask around), beat 2 at a rest stop (a villager recognises it), beat 3 on the next road (return it, small reward + Almanac "Tales" page). State: one JSON column `users.road_story` {id, beat, day}; one story active at a time; max 1 beat per leg; **1 completion per day**; reward = Petals/XP scaled to level + a collectible Almanac page (`unlock_entries('tale:slug')`). Reuse `stop_errands` (stops.php:90) for the stop-side beat if its columns fit.
- **Player sees:** a thread that carries across screens, a reason to keep walking.
- **Files:** road_life.php, road_events.txt (`chain` field), stop_folk.php hook, encyclopedia entries.
- **Data:** 8 stories x 3 beats x ~60 words = ~1,500 words. Use the **draft-text pattern** (status draft/written, Claude suggests, Joshua rewrites). Cheapest: reuse the `trek_texts` table with keys `road.tale.<id>.<beat>` and a chapter-0 tab, instead of a new editor. Note the editor filters by chapter (admin/trek_text.php:15-18), so it needs a small "Road" tab.
- **Risk:** reward faucet: the daily cap above. Abandon rule: story expires after 3 Hollow days. Race: beat advance inside the existing transaction.

### 9. Festival, Almanac and Goal chips (S)
- **What:** one-line chips on the adventure page, same style as `seek_chip` (seek.php:137): `hollow_chip($regionCode)` (season, weather, daypart, already exists, hollow_clock.php:356); "Bunting ahead: the Pumpkin Festival is on in X today" if `town_festival(dest town)` or `festival_active()`; "New to your Almanac" tag on an unseen creature title (check `user_encyclopedia` for `creature:slug` before the fight, adventure.php fight card).
- **Player sees:** the world's state at a glance, and a quiet nudge to meet new creatures.
- **Files:** adventure.php (header block), seek.php pattern.
- **Data:** ~6 templates.
- **Risk:** none. Do not make festivals cost more energy to reach.

### 10. UI parity (S-M)
- **What:** (a) off-path choices -> `act_choice` / `choice_row` with the odds badge (adventure.php:~168 replaces the old `.option` + help span); (b) deeper / roam / back / return / next-space / delve buttons -> `.choice` rows with sub-lines ("Go deeper . 1 energy . Hard . danger 9"); (c) turn the last non-fight outcome into a small result card with icon and title (reuse `prize()`, functions.php:106) instead of only a log line.
- **Player sees:** the wander screen looks like the fight screen.
- **Files:** adventure.php only (+ a few CSS lines). Keep the hidden `do` names (tests grep them).
- **Risk:** none. Mobile: `.choice` already tested.

### 11. Calling and companion lines (S)
- **What:** add optional `ca=<calling>` and `an=<animal>` tokens to the cond syntax of road_lines.txt and road_events.txt. Wayfinder spots tracks, Rootwarden pats a trunk; a gnome with a frog gets "Your frog would love this puddle." Check ownership with the garden animals table.
- **Data:** ~20 lines. **Risk:** none.

### 12. Delve rooms with text and themes (M)
- **What:** per-landscape room blurb pool (9 lands x 5-6 lines = ~50) shown on "Room N", plus a mid-delve alcove at room 3 (free heal or a choice). Use #4's choice engine for traps instead of the 20 road problems.
- **Risk:** keep the chest as is. Rooms stay lantern-gated.

### Suggested build order
1 + 2 + 3 first (about one version, no schema beyond one column, big feel change). Then 9 + 10 (UI, cheap). Then 4 with 3 starter regions, then 5 and 6. Then 7. Then 8 last (needs the text pipeline and the most writing).

## 7. What NOT to do (and why)

- **Do not give every region its own creature roster.** 15 x ~20 creatures is 300 stat rows to balance. Region identity comes cheaper from text packs (#4) and ambient lines (#3).
- **Do not simulate NPC movement in the DB.** Per-minute writes and cron are exactly what `traveller_stop()` avoids. Use hash-of-clock functions.
- **Do not add a second random-event layer with its own rewards.** The 49 page-view events (events.txt) already fire on any GET incl. the adventure page (layout.php:36). Fold new content into the one effect language (`apply_event_effect`) and the existing caps.
- **Do not add player-typed anything on roads** (messages, notes). Moderation cost. Presets and counts only.
- **Do not make every outcome a `<dialog>`.** Walks are many quick taps. Use a dialog only for a story beat or a hidden-place discovery. Cards and chips otherwise.
- **Do not gate rewards behind weather/season.** Bias and flavour only; hard gates only where the text would be wrong (fog, night).
- **Do not raise encounter rates to look busier.** Road space cost is energy per leg, not per space; more fights means more XP/loot per energy.
- **Do not copy trek's single "not the last one" anti-repeat.** It is too shallow for pools of 5.
- **Do not touch trek*.php.** Share only the pattern (gap/pct settings, draft status).

## 8. Reward / faucet rules for anything new

1. Road spaces cost 1 energy per 3 spaces, wander 1 per step. A new event that replaces an existing slot (problem, find) keeps the same ceiling.
2. Anything that adds a **new repeatable reward** needs `landmark_once`-style daily claims (landmark_uses, UNIQUE user+id+action+day) or the shared Trek-style Petal cap.
3. Items from events: `@chance` <= 20%, common/uncommon only, via `outlevel_fx` so outgrown areas pay less.
4. Friendship, stamps, goals: attach to the existing claim, do not add a second source.
5. All writes inside the existing `begin/commit` and the user-row lock (adventure.php:40-44, v1.2.2). Do not write the recent ring outside it.
6. Admin: every new text/event row should be editable (cond + draft status), or Joshua cannot tune it without Claude.

## 9. Broken, dead or misleading things found

| # | Finding | Ref |
|---|---|---|
| a | Time/weather problems fire in the wrong conditions (night, fog, tide, heat) | problems.txt:13,18,21,23 |
| b | "It changes with the days" is false: wonder DCs and approaches are fixed | landmarks.php:180, wonder_approaches:156-170 |
| c | Haven descriptions promise a special shop / syrup / cocoa; pantry is generic random | landmarks.txt header + descriptions, haven_pantry:87 |
| d | 146 generated villages share 9 descriptions | adventure_data.php:~125 |
| e | Only 2 landscape finds per land (18 items): finds feel identical after a day | adventure_data.php:29 |
| f | `OFFPATH_CHOICES` / `OFFPATH_SIGHTS` hard-coded; not editable in admin, unlike events, stops, treks | explore.php:159-222 |
| g | Choices only appear off-path; the road never has them | adventure.php next_step |
| h | Tundra has the thinnest roster (11 creatures, 2 at low levels, 6 problems) | creatures.txt |
| i | 4 of 12 stop personalities have no chat lines; chat is not per stop type | stop_chat.txt |
| j | `pick_creature` reloads all creatures each call; `pick_problem` all problems each call | adventure.php:333,360 |
| k | hollow_clock header says "No gameplay effects live here" but stops use it; keep roads consistent (bias only) | hollow_clock.php:17 |
| l | Not dead: events.txt works on every GET incl. road pages; the explore fallthrough to sights when no hidden place remains is fine | layout.php:36, explore.php:~290 |

Nothing found that corrupts data or races. The road code is solid; it is thin, not broken.

## 10. Test notes

- Extend `tests/explore.sh` and `tests/events.sh` for: recent ring never repeats within 3 picks; cond filter (force `weather_force`/`stop_daypart_force` settings, both exist); choice on road resolves via `do=choose`.
- Add `road_lines.txt` lint to the existing data-file tests (every line has 4 fields, cond parses, no line > 140 chars).
