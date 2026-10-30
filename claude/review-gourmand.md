# Review: proposal-gourmand.md (fit with the existing game systems) (2026-10-30)

Checked against the code at `b197c33f` and a fresh SQLite install made with walk.sh in a scratch copy. The proposal and game code were not edited.

## 1. Verdict

1. The plan mostly fits the game. Every data slug, spot slug, line number and function name it cites exists, and the schedule rule (built on `TOWN_FESTIVALS` and the traveller hooks) slots in cleanly.
2. Three things break as written: the off switch leaks Pomeroy into at least 7 NPC queries that `travellers_active()` doesn't cover; the alt guard ("bought goods never pass") is false, because `item_quality.n` never shrinks; and pots cooking during the upgrade would record quality 0.
3. About 30–40% of the new code can go. Reuse `traveller_deals` as the per-tour claim and `npcs.active` as the off switch. Drop the board, the Wayside Bite, `gourmand_teach` and the encyclopedia chapter.

## 2. Claims checked

| Claim | File:line | Correct? | Fix |
|---|---|---|---|
| `TOWN_FESTIVALS` in includes/town.php, days 1,3,…,27,28 | town.php:36-52 | Yes | — |
| Windows are "00:00–23:59 Halifax time", 48 h | functions.php:343,970 | Partly | Uses the `game_timezone` setting (default Halifax). A window that spans a DST change lasts 47 or 49 h. |
| Festival is on "the second day of each stay" | town.php:51 | No, for OC and Mossbottom | OC's festival (day 28) is day 1 of its stay. Mossbottom's stay is 1 day long. |
| `traveller_stop()` is a pure function of time | npc_life.php:146 | Yes | It uses UTC 12 h slots. `gourmand_stop` has to use `hollow_date`. |
| `road_meet_candidates()` derives `$started` from `ends - TRAVEL_STOP_HOURS` | road_life.php:566 | Yes | The proposed `starts ??` fix is right. "in" reads `traveller_stop($t, $started-1)` (line 572), which works with `gourmand_stop`. |
| `ROAD_TRAVEL_WINDOW` = 2 h | road_life.php:510 | Yes | — |
| `npcs_at_spot()` can show him at the camp | npc_life.php:122-137 | Needs more work | Travellers are only scanned when `kind === 'green'`, so the camp needs a new branch outside that `if`. |
| `npc_now`/`npc_routine` need branches | npc_life.php:157,220 | Yes | — |
| Teahouse rumours "already work" | npc_life.php:266-269 | No | The text says "Over on the Green." Needs a branch. |
| `traveller_offer` / `traveller_deal` hooks | npc_life.php:286,310 | Yes | — |
| folk.php ~81 shows the deal button | folk.php:81-84 | Yes | — |
| (missing) villagers.php also renders the offer as a POST `do=deal` form | includes/villagers.php:144-148 | **Missed** | Needs the same `kind==='link'` branch. |
| town.php lines 231 and 301 | town.php:231,301 | Yes | Line 306 hardcodes "here, on the Green!": change the wording. |
| `friends.php npc_here()` | friends.php:85-91 | Yes | It goes through `traveller_stop`, so the dispatch covers it. |
| `npc_icon` maps "mouse" (Dormouse) | npc_life.php:30 | Yes | — |
| `round-door` dormouse at road_events.txt line 54 | data/road_events.txt:53-54 | Yes | — |
| All 15 camp slugs exist and are always open | town_spots (install) | Yes | `ss-brewhouse` comes from `ensure_calling_mentors` (calling_quests.php:85,92). Teahouse slugs are `<code>-tea`. |
| 14 plate crops, tiers, `-seed` items, 14 treasure seeds | region_crops.txt / items | Yes | All verified in the DB. |
| All Pot/Jar/Grand slugs and the jar days/kinds | recipes table | Yes | 8 regional feasts exist. SA, WCA, ESA, EA, SEA and OC have none. |
| 3-spoon jar table (≥62 at Kitchen III) | pantry.php:113-120 | Yes | Hummus and pickled okra land exactly on 62, so a −3 wobble drops them to 59. |
| `pantry_quality` formula | pantry.php:113 | Yes (exact) | — |
| "1-day single-fruit jam tops out at ~52" | pantry.php:119 | Roughly | 52 is the base. With luck and wobble it can reach 59. |
| Jar bar words via `fair_word` (62 = "Splendid") | fair.php:44-47 | No | `fair_word(62)` = "Fine" (Splendid starts at 65). Use spoon words of its own. |
| `fair_quality` `_native` +5 | fair.php:65-77 | Yes | — |
| `market_stack_q`, `MARKET_PLAIN_Q`=35, `market_note_quality` | market100.php:18,362,373 | Yes | — |
| "Bought/traded goods never pass" (alt guard) | market100.php:362-389, inventory.php:14-17 | **No** | `n` never decreases and the row outlives `user_items`. Verified: harvest 3 at q70, sell all, buy 3 → `market_stack_q` = 70. |
| "Serving leaves the stack average unchanged" | market100.php:367 | No | Removal keeps `n`, so the remainder counts as tracked. The average goes up. |
| `cook_start`/`cook_collect_one` and the hook point | crafting.php:345,417,445 | Yes | market100.php is already loaded in bootstrap.php:56, so no `require` is needed. |
| "Dishes cooked before the upgrade stay untracked" | schema `$c` default 0 | **No** | A pot started before the upgrade and collected after it writes quality **0**. Skip the note when the score is 0. |
| `kitchen_best` | — | No such function | Use `user_building_bonus($uid,'kitchen')['best']` (gardens.php:89). |
| `eff_mod`, `is_guest_uid`, `fresh_hold`, `profile_link`, `prize`, `friend_add`, `give_item` | gnome.php:194,589; functions.php:704,710,116; friends.php:56; inventory.php:11 | Yes | — |
| Pantry costs 600 Petals and 4 planks | functions.php:517-518 | Yes | — |
| `can_reach` lets everyone reach the hub | world.php:260 | Yes | — |
| `ROAD_PAIRS` counts (2 roads for CB/SE/EE/WCA/ESA/OC, 5 for CSA) | roads.php:14-18 | Yes | — |
| `stops.txt` has 12 types; `stop_snack()` returns [item, price] | data/stops.txt; stops.php:970 | Yes | — |
| Haven reveal feeds the `places` calling task | calling_quests.php:302 | Yes | — |
| `CALLING_EVENT_KINDS` | calling_quests.php:24 | Yes | — |
| "Hollow goals hear `serve` for free" | hollow_goals.php:134-141 | **No** | `hollow_goal_adds` only counts kinds in the pool. Emit through `job_event` (jobs.php:311) as the repo convention says. |
| `calling_titles`/`stop_titles` merge in book.php at 22 and 248 | book.php:22,248 | Yes | — |
| New Almanac chapter "just added" | book.php:56-64 | Incomplete | Needs an `ALMANAC_SECTIONS` edit. It also raises every player's page total (almanac.php:8), even while the feature is off. |
| `recipes.txt` columns; `ensure_crafts`→`import_recipes` adds missing slugs | recipes.txt:1; crafting.php:31 | Yes | — |
| `gourmand_teach` is needed so the dish shows early | crafting.php:122-131 | Redundant | Recipes are learned automatically once all ingredients have been seen. |
| `second-spoon` made in `ensure_gourmand` | yard.php:114-122 | Off-pattern | Add it to a decor const read by `ensure_decor_items`. |
| `gourmand_schema` merged like `trek_schema` | schema.php:1466-1476 | Yes | Use `$ID` for `user_id`/`item_id` and inline `UNIQUE(...)`, as `traveller_deals` (schema.php:697) and `item_quality` do. |
| `cook_pots.score` added through `$c` | schema.php:1305; db.php:112 | Yes | It runs when `db_version` changes (bootstrap.php:86). |
| `boot_step` in bootstrap **and** seed.php | bootstrap.php:69; seed.php:178 | Yes | `ensure_npc_lives` already creates every `TRAVELLERS` entry, with **active=1**. |
| `gourmand_open()` like `catfish_open()` | catfish.php:419; functions.php:355 | Yes | The catfish setting is an inline line in functions.php, not a merged `*_settings()`. |
| `gourmand_settings()` merged into `settings_schema()` | functions.php:282-284,615 | Works but heavy | functions.php would have to `require` the feature file on every request. |
| `hollow_season_forced` as the force-setting precedent | hollow_clock.php:143 | Name | The setting is `season_force`. The proposed `gourmand_force_date` is global, so it moves him for every player. |
| `FRESH_USER_TABLES` | fresh_start.php:41 | Yes | — |
| `AJAX_PAGES` / Out & about nav | layout.php:10,653 | Yes | — |
| Test URL `town.php?spot=<camp>` | town.php:80 | No | `spot` takes a numeric id. |
| "Add gourmand to tests/ci_suites.sh" | ci_suites.sh:7; .github/workflows/ci.yml DEFAULT_SUITES | Incomplete | gourmand.sh installs itself, so add it to `SELF_INSTALLING` **and** to ci.yml `DEFAULT_SUITES`. |
| Version 2.2.0 | bootstrap.php:5 (2.1.14) | Yes | Only bootstrap.php needs the bump (install.php reads it). Then run `tools/check_versions.sh` and `build_update.sh … all` for the full zips, and commit `tests/manifests/2.2.0.txt`. |

## 3. Integration risks (ranked)

1. **Off-switch leak (high).** Every `active = 1` query that `travellers_active()` doesn't touch would show Pomeroy while he is "closed":
   - Job Board giver names (jobs.php:113)
   - Contest roster (townsfolk.php:39)
   - Almanac Folk counts (book.php:111,114,216)
   - gnome.php:255
   - The NPC count in place_ui.php:198
   - villagers.php:14 and folk_list.php:23

   `ensure_npc_lives` also creates him with active=1 on upgrade. **Fix:** create him with `active = (gourmand_open setting)` and add one line in admin/settings.php next to the `guide_price` hook (line 64): `if (isset($changes['gourmand_open'])) gourmand_sync_active();`. Admins preview through `gourmand.php`. This also removes the need for the `travellers_active()` refactor.
2. **Alt guard is broken (high, verified).** `item_quality.n` is never reduced. A gnome who once harvested good stock can sell it and serve shop-bought units at the old quality. The same cause is why `orders_food_quality` was turned off in v1.7.6.
   - Minimal fix: when `give_item(<0)` removes units, scale `n` down in proportion, with one UPDATE (`n = n*after/before`).
   - Alternative: only clear the row when qty reaches 0 (a partial fix).

   Either way it touches give_item, the hot path, so it needs Joshua's OK.
3. **Pot quality 0 after the upgrade (medium).** `cook_pots.score DEFAULT 0` plus the unconditional `market_note_quality` gives quality 0, below plain (35). **Guard:** only call it when `score > 0`.
4. **Missed UI sites (medium).**
   - villagers.php:144 would show "Serve a course" as a deal POST, which `traveller_deal` then refuses.
   - Text that assumes the Green: rumours (npc_life.php:268), npc_now (161), npc_routine (223) and the town fold (town.php:306).
   - `npcs_at_spot` needs a branch for a non-green spot.
5. **Existing tests that break.**
   - tests/roadlife.php:380: `$allWho` rejects who=`gourmand`, so the road_meet.txt lint FAILs. Add `gourmand` to that list.
   - Optional Phase 2 feasts break sinks097.sh:163 and 170 (feast count = 15).
   - No other tests hard-code recipe, NPC or setting counts. pantry.sh counts preserves from the data, and eggs110 counts only hen-egg recipes, which the new rows don't use.
6. **Almanac side effects (medium).** Adding 14 Taste pages, beats and hints raises everyone's page total and shows locked pages in Almanac search (book.php:142), even while he is off. It also needs an `ALMANAC_SECTIONS` slot.
7. **Payout conventions.** handoff.md:113 says new Petals go through `give_petals()`/`give_xp()` (rewards.php), and that every repeatable Petal source needs a daily cap or an energy cost. The tip is capped per tour, which is acceptable if Joshua agrees. Name the helpers in the spec.
8. **Claims are over-built.** The proposal stacks three race patterns: (b) UNIQUE insert, (c) user lock + re-read, and (a) a conditional UPDATE on `paid`. Inside (c), pattern (a) adds nothing. Keep (c), with the UNIQUE claim as a backstop.
9. **Settings and admin.** Twelve settings plus a `settings_schema` merge means functions.php loads gourmand.php on every request. admin/settings.php `$sectionOf` (line 75) has no `gourmand_` prefix, so the settings land in "Gardens & economy".
10. **Clock and schedule details.** Use `hollow_date`/`game_timezone` for the windows. The "festival day pays twice" rule falls on day 1 of the OC stay. `gourmand_force_date` is global: fine for tests, but it affects every player.
11. **Schema path.** Tables only come from schema.php, so `schema_compare.php` (fresh vs upgrade) passes as long as the UNIQUEs are inline from the first ship (`db_migrate` never alters an existing table). The column types work on both SQLite and MySQL (`at` and `day` are already used as column names).

## 4. Simplifications (less new code)

| Drop / replace | With (existing) | Saves |
|---|---|---|
| `travellers_active()` refactor of 5 sites, plus `gourmand_open` guards | `npcs.active` kept in sync with the setting (risk 1) | 1 helper, 6 edits, and it closes the leak |
| `gourmand_plates` table and its indexes | `traveller_deals` (UNIQUE `user_id, npc_id, stop`; `stop` VARCHAR(20) holds `2026-10\|MENA\|plate` = 18 chars). Late plates use the previous tour's key on day 1. | 1 table, 2 indexes, the fresh-start row |
| Long Table board, `idx_gourmand_tour`, the privacy open question (Q9) | Nothing in v1. The Harvest Fair already judges monthly bests (`fair_best`) with names shown publicly. Keep the Long Table as the day-1 late-plates stop and the finale. | Board query, UI, tests |
| `gourmand_wander` and Wayside Bite (Phase 3) | Drop it (it's Q10 anyway) | 1 table, 12 pages, the location logic |
| `gourmand_teach` / recipe cards | Auto-learning in `craft_recipes` (crafting.php:122) | 1 function |
| A new encyclopedia chapter with 14 + 6 pages and their unlocks | A Journal tab on gourmand.php built from `gourmand_ledger` (the Pal Book special-chapter precedent, book.php:114), plus one "The Gourmand" How-to page | No page-total or search side effects, no `ALMANAC_SECTIONS` edit |
| The camp panel included on town.php spot pages | Serving only on gourmand.php. The 🐭 on the spot comes from `npcs_at_spot`; "Today at a glance" and the fold work through the `traveller_stop` dispatch. | town.php partial |
| R rows with arrival and leaving lines in gourmand.txt | road_meet.txt rows with who=`gourmand` (and the existing `@trav-in/out`) | Parser fields |
| 12 settings in a merged `gourmand_settings()` | 2 inline settings (`gourmand_open`, `gourmand_force_date`). Bars, pay and tips as consts in gourmand.php. | Settings plumbing |
| `second-spoon` made by hand | A decor const entry plus `ensure_decor_items` | Ad hoc item code |
| `calling_event('serve')` | `job_event($uid,'serve',…)` in Phase 3 (feeds callings, jobs and goals) | Consistency |

What stays new: gourmand.txt (M and B rows), includes/gourmand.php (stop, menu, spoons, serve, journal, titles), `gourmand_ledger`, `cook_pots.score`, the gourmand.php page, and the hooks in npc_life, road_life, folk, villagers and crafting.

## 5. Trimmed phase plan

- **P0 (S):**
  - gourmand.txt (M and B rows only).
  - `gourmand_stop`/`menu`/`spoons` on `hollow_date`.
  - tests/gourmand.php: schedule with DST-aware windows, the lint, the 62 bar.
  - Add `gourmand` to the roadlife.php:380 whitelist.
- **P1 (M, off by default):**
  - NPC created inactive, plus the sync line in admin/settings.php.
  - `traveller_stop` dispatch and wording branches: npc_now, npc_routine, rumours, town.php:306, `npcs_at_spot`.
  - `link` offer in folk.php:81 **and** villagers.php:144; `traveller_deal` refuses him.
  - gourmand.php tabs: Now, Journal, Menu, Rules.
  - Serve, all under one user-row lock:
    - claim in `traveller_deals`
    - `give_item(-qty)`
    - ledger upsert
    - `give_petals`/`give_xp`/`friend_add`
  - Late plates on day 1.
  - `cook_pots.score` with the `>0` guard.
  - **Decision for Joshua:** the proportional `item_quality.n` fix in give_item.
  - Titles at book.php:22 and 248; decor `second-spoon`; `FRESH_USER_TABLES += gourmand_ledger`.
  - tests/gourmand.sh, which goes in `SELF_INSTALLING` and ci.yml `DEFAULT_SUITES`. It covers:
    - HTTP 200s, spot by **id**
    - wrong region, guest, a race of two POSTs
    - fresh start
    - road meet at `starts+1h` and not at `+3h`
  - Plus one check in cook.sh.
  - Release: version 2.2.0 in bootstrap.php, news, `check_versions.sh`, the full CI list, the upgrade check and the MySQL job.
- **P2 (S, data only):**
  - 14 new Pot recipes plus `chicha`/`poi` in recipes.txt; v2 variants in gourmand.txt.
  - Grand course for the 8 regions that have a feast; Home Plate beat.
  - Any new feasts must update sinks097.sh:163 and 170.
- **P3 (optional):** `job_event('serve')` and Brewroot task rows; an admin read-only schedule preview. No Wayside Bite and no board unless Joshua asks.
