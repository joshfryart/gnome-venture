# Sleep-days: the game moves forward when the player sleeps (design, 2026-11-07)

Status: **DESIGN ONLY. No code, data or version change.** Decided by Josh in Q&A (2026-11-07, 2026-11-08). The code audit is done (sections 10 and 12). The decision log of the 2026-11-08 session is at the end (decisions 1-28); where it differs from sections 1-9, **the later decisions win** (e.g. personal game clock, sleep places, inn). Next step: build, starting with section 13 and a garden-growth prototype.

## 1. The change in one paragraph

Energy stays, but stops regenerating by the minute. The player chooses when a **day** passes by sleeping in the gnome hovel. Sleep gives a full energy refill and advances the player's own calendar. Garden plants, pantry jars, pal jobs, NPC visits and festivals now run on these game-days instead of minutes and hours. Shared systems (contests, community goals, visits, market bucket drain, minigame Petal caps) stay on the real clock.

## 2. Rules

**Sleep**
- Sleep is in the hovel. Unlimited. No cooldown, no daily cap, no global brake. Josh: "treat as sandbox" (no monetization, small player base).
- Sleep = full energy refill + the player's game-day counter +1.
- Sleep cost is **opportunity cost only**: NPC "move on" windows and festivals pass by (sections 4, 5). Nothing is charged.

**Energy**
- Remove the timed regen (`energy_tick()`, `refresh_energy()`, settings `energy_regen_amount` / `energy_regen_seconds`).
- Other energy sources stay: food and snacks (uncapped, Josh: convenience), resting at acts, game-room minigames (capped per **real** day, as the minigame Petal caps already are).

## 3. Clocks: who runs on what

| System | Clock | Note |
|---|---|---|
| Garden plant growth | game-days | N sleeps per crop. Retune every seed, hybrid, animal |
| Pantry jars | game-days | was real timers ("2.5 days", "5 h", "12 min" in `site.js`) |
| Pal jobs, pal delves | game-days | **fewer slots, longer jobs** (rate lowered, not capped) |
| Cat Fish weekly Petal cap + milestones | game-week = 7 sleeps | cap resets on sleep, so it is effectively soft |
| NPC chat and gifts (once a day each) | game-days | NPCs "move on" (section 4) |
| Festivals, events | per-player calendar | you can miss yours by sleeping past it |
| Season and weather seen by the player | per-player calendar | needs a per-player date (section 7) |
| Minigame Petals and energy from minigames | **real day** | unchanged cap |
| Community goals, Garden of the Month, visiting | **real** | shared |
| Market sell-bucket drain | **real** | section 6 |

Only the **personal** calendar can be missed. Anything shared cannot be missed by sleeping.

## 4. NPCs move on (this is the sleep cost)

Code today: `includes/stop_folk.php` lets you chat once a day and gift once a day per villager, keyed on `hollow_date('Y-m-d')`, and offers errands per day. Under this design those become game-day keyed, so sleeping refreshes them. That alone would make friendship a sleep faucet, so each NPC also **moves on**: their mood, location and wanted gifts change by game-day, so skipping days skips specific dialogue and gift windows. `stop_chat.txt` already picks lines by time, season, weather and personality, so the authoring format exists. **Content debt:** schedules and lines for every villager.

## 5. Festivals

Per-player calendar. Each player meets their own festival days as they sleep through them. Sleep too fast and you skip one. The day-count of a festival window is fixed in game-days.

## 6. Market: price brake on the NPC shop only

- The player market (`market.php`) is already player to player: stalls with your own price (5% fee), gifts (items and coins), trade offers, saplings. **Leave it alone.** Supply and demand set stall prices.
- The brake sits on **NPC shop sell-back** (`shop.php`).
- **Per-player**, never shared: one sleep-abuser must not move prices for everyone.
- Mechanism: a **leaky bucket per crop per player**. Each unit sold fills it. It drains on **real time** (if it drained per sleep, spam-sleep would reset it and it would do nothing).
- Bucket size = base x the player's bed count (late gardens are not punished; monoculture sleep-farming is).
- Past the threshold, the price steps down: 100% -> 75% -> 50% -> 25% floor (never zero). Thresholds, not per-sale drops, so normal players never see it.
- Show a "market is full of tomatoes" meter. Never a hidden penalty. Selling is never blocked.
- Sinks (cooking, pantry, pal food, gifts) keep full value, so surplus stays useful.
- Tuning target: a full garden harvested once per real day sits just under the first step. Base x beds is easy to game (beds are cheap), so tune against bed cost.

## 7. Per-player calendar: the technical seam

`includes/hollow_clock.php` ("the Hollow clock") makes season and weather from a date and says it is "the same for every player" and "a pure function of the date (+ region)". But `hollow_season()`, `hollow_season_day()`, `hollow_weather()` and `hollow_forecast()` already take a `$date`. The seam: give each user a game date (their day counter mapped to a `Y-m-d`) and pass it in wherever the page is about **that player's** world. Pages about shared things keep passing real `hollow_date()`.

`hollow_date()` is used in about 59 files. Each call is one of: personal (switch to the player's game date), shared (keep), or an anti-abuse stamp such as a daily cap (keep, real). That sort is the audit in section 9.

## 8. Accepted risks (Josh chose to accept each)

1. Pals, Cat Fish and NPC friendship have no ceiling per real hour. Crops are only braked at the NPC shop.
2. Alt accounts can bypass the bucket: farm, gift to an alt, sell in the alt's fresh bucket.
3. Players are out of phase: different seasons, weather, festivals. Visits and trades cross calendars.
4. Content debt: NPC schedules and lines, festival calendar.
5. Every seed, hybrid and animal needs retuning from minutes/hours to sleeps.
6. Bucket size (base x beds) needs balancing.

## 9. Code audit to do before building

- `refresh_energy()` (`garden_logic.php:292`) and `energy_tick()` (`functions.php:316`), `bootstrap.php` boot step `energy_regen_seconds`, header and status-strip energy pills (`hubscene.js`), regen note text.
- Every `hollow_date(` call (about 59 files): personal / shared / cap, list in a table.
- `hollow_season`, `hollow_weather`, `season_chip`, `season_fold_html` callers.
- Plant growth timestamps (`garden_logic.php`, `garden.php`, `gardens.php`), watering, wilt.
- Pantry jar timers (`site.js` "Pantry jars (v0.9.8)"), `pal_jobs.php`, `paljobs.js` clock display.
- Cat Fish weekly cap (`catfish.php`, setting `catfish_pe...`).
- Daily caps that stay real: `puzzle_games.php` daily Petals, `daily.php`, `welcome_back.php`, `games.php`, `pest.php`, `letters.php`, `mushroom.php`, `spit.php`.
- `shop.php` sell path for the bucket. A new table is needed: `sell_bucket (user_id, item_id, units, updated_at)`.
- Scheduled reminder emails and nudges (`nudge_settings`, "crops ready" approximation) that assume real-time growth.

## 10. Migration

Convert running timers by remaining time to the nearest whole number of sleeps, **rounded up**. Plants, jars and pal jobs. One migration script, no windfall, nothing lost.

## 11. Build order (suggested)

1. Audit (section 9).
2. Per-player game date + sleep action, behind a flag (default off).
3. Garden growth on game-days. Prototype and balance here first.
4. Remove regen, wire sleep refill.
5. Pantry, pal jobs, Cat Fish cap.
6. NPC move-on content and festival calendar.
7. NPC shop sell-bucket and meter.
8. Migration script, then flip the flag.

## 12. Decision log (Q&A, 2026-11-07)

- Sleep cost: opportunity cost (things you miss), not a charge.
- Energy: regen removed, sleep = full refill, plus food, snacks, rests, minigames (real-day cap).
- Sleep limit: **none** (sandbox), though a per-real-day cap, cooldown or diminishing refill were offered and declined.
- Per-source caps: minigame Petals real-day; crop sales bucket at the NPC shop; pals "fewer slots, longer jobs"; Cat Fish cap game-week.
- NPCs: game-day with "move on". Festivals: per-player calendar. Shared: real-time.
- Market: per-player (not shared), thresholds, leaky bucket, real-time drain, scales with beds, NPC shop only.
- Food energy: uncapped. Pantry: game-days. Migration: convert by remaining time.

## 10. `hollow_date()` audit, first pass (2026-11-08)

Method: grep of `hollow_date(` plus the enclosing function, judged by name and design sections 3-5. **Not every call was read in context.** `?` = must read before deciding. Counts: 144 calls, 59 files in `game/` (129 calls) + 9 files in `tests/` (15 calls). The earlier "about 59 files" was `game/` only.

Key: **P** personal (switch to the player's game date) · **S** shared (keep real) · **C** cap or anti-abuse stamp (keep real) · **?** read first.

### Wrappers (sorted by their callers, not here)
`hollow_today()` (`hollow_clock.php:78`), `hollow_now()` (`:288`), `hollow_hour()`, `hollow_dow()` (`functions.php:1052-3`). About 40 more call sites use them: `hollow_clock.php` 11, `garden_fx.php` 6, `npc_life.php` 5, `garden_critters.php` 4, `animals120.php` 4, `world.php`, `place_ui.php`, `here_view.php`, `garden_logic.php`, `friends.php`, `garden.php` 2 each, plus 6 files with 1. **Second audit pass needed.** Note: a game date has no hour. Decide what time of day means for a personal calendar (real hour, or fixed).

### Personal (P)
| File:function | What |
|---|---|
| `garden.php:540-542` picker_html | rain barrel and plot free-water per day |
| `garden_logic.php` garden_claim_free_water | free water per day |
| `gardens.php` turn_compost | compost turn per day |
| `garden_fx.php` garden_grow_gain, garden_wind_weeds, garden_pest_pass | weather per day on a plot; **walks timestamps to dates, so needs a rewrite to game-days, not a swap** |
| `flowers.php:247` arrange_ctx | season and month |
| `stop_folk.php` stop_chat_line, stop_chat, stop_gift, stop_errands_expire, stop_errand_givers, stop_errand_offer, stop_errand_accept | once-a-day chat, gift, errands (design section 4) |
| `friends.php` npc_talk, npc_gift | once-a-day chat and gift |
| `local.php` local_folk_card, stop_folk_panel | "talked today" |
| `residential.php:101` door_view | gift once a day |
| `npc_life.php` npc_birthday_today, teahouse_rumours (279) | NPC calendar |
| `festival.php` festival_active, festival_next, festival_last, festival_flag_today, festival_find_flag | festivals (section 5) |
| `catfish.php:501,513` catfish_today, catfish_week | weekly Petal cap becomes game-week = 7 sleeps |

### Shared (S)
`gourmand.php` (page + all 7 in `includes/gourmand.php`, monthly tour) · `hollow_goals.php` hollow_goal_week, hollow_pulse_build · `fair.php:52` · `contests.php:228-229` · `gotm.php:45` · `yard.php:1100` gotm_month · `market100.php:863` cache key · `race.php:56` · `catfish.php:976` shelter rotation · `profile.php:37`, `book.php:360` (display of real dates) · `admin/livingstops.php`, `admin/xp.php`, `admin/gourmand.php`.

### Cap or stamp (C), stay real
| File:function | What |
|---|---|
| `welcome_back.php` daily_card, daily_tick | daily login |
| `gnome.php:239` add_xp | daily XP cap |
| `trek_fight.php` trek_petals_capped, trek_item_allowed, trek_friend_fight_won | Petal and item daily caps (same rule as minigame caps) |
| `social169.php` water_used, water_html, water, counts | watering other players' plots per day (alt and spam guard) |
| `pals.php` pal_stamp, pal_stamped_today, pal_gift_sent_today, pal_gift | player-to-player stamps and gifts |
| `trade.php` saplings_left_today, raise_sapling | daily sapling limit |
| `admin/treks.php:41` | Petals found today (display of the cap) |

### Needs a read (?)
| File:function | Question |
|---|---|
| `here.php:27`, `town.php:100` | "It's 14:00 in the Hollow, Tuesday" clock line. Real, or personal? |
| `visit.php:81` | compost turn check on someone else's plot: stamp or garden process? |
| `mentors120.php:329`, `mentor.php:52` | mentor share per day |
| `puzzle_pals.php:845` ppal_spawn_refresh | minigame (C) or world (P)? |
| `flowers.php:19,24` | daily flower count: cap or growth? |
| `jobs.php:23-25` job_period_key | daily/weekly/monthly job keys: Petal board (C) or pal jobs (P)? |
| `rebuild.php:432,480` | repair per day |
| `tools.php:340,426,479`, `shelves.php:61` | free mends per day (lean P) |
| `quests_view.php:122` | order deadlines in days (lean P) |
| `events.php:62,68` random_event_roll | random garden events (lean P) |
| `stop_adopt.php:334,411`, `place_ui.php:320`, `stop_living.php` (9 calls), `stops.php` (7 calls) | town stop perks, meters, threads, happenings (lean P, section 4) |
| `town.php` town_festival, upcoming_festivals, spot_closed, town_day, `landmarks.php:45` landmark_day | town calendar: shared by town or per player? Ties to festivals |
| `road_life.php:555,556,675` | road travellers per day (lean P) |
| `villagers.php:106` | villager panel (lean P) |
| `first_week.php:61,69` | onboarding by days since start: game-days would let sleep skip it |
| `social.php:200` | start date of something, unknown |
| `sinks.php:59,69` curio_week | weekly curio rotation (lean S) |
| `catfish_pets.php:520`, `npc_life.php:303` | cosmetic line pick, either is fine |

### Tests
9 files in `tests/` (`trek_*`, `stops100`, `gourmand`, `clock`, `puzzle_pals_map`) use `hollow_date()` to compute expected values. They must follow whichever clock their subject moves to.

### Next
1. Read the `?` rows, decide, move each into P/S/C.
2. Second pass: callers of `hollow_today/now/hour/dow`.
3. Add the player-game-date helper (section 7) and wire P rows one system at a time, garden first.

### Decisions on the `?` rows (Josh, 2026-11-08)
1. **Time of day:** real Halifax hour, shared. Only date, season and weather are personal. `hollow_hour()` and the "It's 14:00 in the Hollow" lines stay real; the weekday word in those lines should come from the player's game date.
2. **Town calendar** (`town.php` festivals, closed spots, `town_day`, `landmark_day`): per player, same as festivals.
3. **First-week onboarding** (`first_week.php`): real days.
4. **Free mends and order deadlines** (`tools.php`, `shelves.php`, `quests_view.php`): game-days. Sleeping can expire an order.
5. **Town stops** (`stops.php`, `stop_living.php`, `stop_adopt.php`, `place_ui.php`, `road_life.php`, `villagers.php`): game-days, perks and threads included.

Still `?` (need a code read, not a decision): `visit.php:81`, `mentors120.php`, `mentor.php`, `puzzle_pals.php:845`, `flowers.php:19,24`, `jobs.php` period keys, `rebuild.php`, `events.php`, `social.php:200`, `sinks.php` curio_week.

### Sort of the code-read rows (2026-11-08)
| Row | Result | Why |
|---|---|---|
| `visit.php:81` compost turn on another's plot | **C** | visitor gives owner +1 scrap, self +3 XP; spam-sleep would farm it |
| `mentors120.php:329` mentor XP share | **C** | `pmentor_daily_cap`, an XP cap |
| `mentor.php:52` | **P** | "already chatted today" with a calling mentor, same as `npc_talk` |
| `rebuild.php:432,480` landmark repair | **P** | one work-day per day, costs energy; sleeping speeds repairs on purpose |
| `events.php:62,68` random events | **C** | `event_daily_max` cap on per-page-load rolls |
| `social.php:200` | **S** | one-time setup writes the festival start settings |
| `sinks.php:59,69` curio_week | **S** | weekly rotation of one shared shop |
| `flowers.php:19,24` florist shifts, seed packets | **P**, see decision 6 | `florist_shifts_day`, `packets_per_day` |
| `puzzle_pals.php:845` | **?** open | one pal spawn per day; is it a faucet? |
| `jobs.php:23-25` job board | **?** open | daily/weekly/monthly offers; period keys are strings, `job_period_span` uses real midnights |

### More decisions (Josh, 2026-11-08)
6. **Florist shifts and packets:** game-days, but a shift **takes half or a full day** of the player's time. Josh: commit the gnome for x hours or minutes and move the player's game clock up by that amount; do the same for travel (each path section about 10 min). Weigh good and bad per system as it comes up.
7. **Full per-player game clock (hours and minutes).** Actions and travel spend game minutes. **This supersedes decision 1** (real shared hour): `hollow_hour()` and the "It's 14:00 in the Hollow" line become personal. The shared real clock stays for caps, market bucket drain and shared systems.

### Open design questions from decision 7
- What happens when the day's hours run out (forced sleep, tired penalty, or locked actions)?
- Do energy and time both exist (two budgets), or does time replace energy?
- How long is a game day in game-hours, and what time does the day start after sleep?
- Does sleep cost time (sleep until morning) or is it a jump?
- Which actions cost time, and how much (travel 10 min per section; shift half or full day)?
- Time-of-day content (NPC schedules, shop hours, day/night art) all read the personal clock.
- Money-making cost: with time as a budget, do the sleep brakes (bucket, fewer slots) become less needed?

### Decisions 8-11: the game clock (Josh, 2026-11-08)
8. **Energy and time are two separate budgets.** Energy limits effort and is refilled by sleep (and food). Time limits the day; actions spend game minutes.
9. **Day end is a gentle nudge, never a lock.** Past bedtime the gnome is tired (extra energy or time cost; shops and NPCs closed or asleep) but can still act. Sleep is always one tap.
10. **Day length: 16 waking hours, 06:00 to 22:00.** Wake at 06:00. Tired after 22:00.
11. **Sleep jumps to 06:00 the next day.** Unused hours are lost, energy refills, day +1. Plus a **nap**: spends a short time (about 2 h, to tune) for partial energy and does not end the day.

Still to define: the time-cost table (which action costs how many minutes), nap numbers, what "tired" costs, whether crops grow by game-days or game-minutes, how this feeds the `hollow_hour()` callers.

### Decisions 12-14 and the audit is now fully sorted (Josh, 2026-11-08)
12. **Crops, jars, plants grow by game-days only** (N sleeps). Time spent within a day does not change growth.
13. **Job board** (`jobs.php`): game calendar. Daily offers per sleep, weekly per 7 sleeps, monthly per game month. `job_period_span` uses real midnights and must be rewritten. Rewards may need retuning.
14. **Puzzle pal spawn** (`puzzle_pals.php:845`): game-day. Note: this makes pal collection faster with sleep. It is a deliberate choice, not a cap.

The `?` list is empty. Every `hollow_date()` call in `game/` has a class. What remains is the second pass on the wrappers `hollow_today/now/hour/dow` (about 40 sites). Under decision 7, `hollow_hour()` and `hollow_dow()` callers must be sorted into personal clock vs real clock.

## 11. Time-cost table, DRAFT v1 (2026-11-08, not decided)

Built from the 23 `spend_energy()` call sites plus the existing timers. A game day is 06:00 to 22:00 = **960 min**. Every number is a first guess to tune.

**Rule of thumb:** only things that commit the gnome for 10 minutes or more spend time. Taps under that (water, plant, harvest, chat, gift, buy, sell) are free, so the UI is not nagged by clock ticks.

| Action (code) | Energy today | Time (draft) | Note |
|---|---|---|---|
| Travel, one trail section (`adventure.php`, `trail_tiles.php`; 1-6 sections per route) | by route | **10 min/section** | your number; a route is 10-60 min |
| Wander off the path (`explore.php:172`) | 1 | 20 min | |
| Gather (`gathering.php:182`) | 1 | 15 min | |
| Garden taps (`garden_logic.php garden_action`) | 0 | free | |
| Pest pick (`garden_fx.php pest_pick`) | setting | 5 min, free under the rule | |
| Water another's plot (`social169.php:152`) | setting | 10 min | cap stays real (class C) |
| Craft, per unit (`crafting.php:260`) | per recipe | 15 min | |
| Cook pot (`crafting.php:440`) | per recipe | **free to start; the pot finishes after its minutes pass on the gnome's own clock** (tiers 3 / 15 / 45 min today) | see question A |
| Pantry jar (`pantry.php:174`) | per recipe | free to start; ready after N game-days (decision 12) | |
| Arrange flowers (`flowers.php:301`) | per bouquet | 20 min | |
| Seed packet (`flowers.php`) | 0 | 10 min each | |
| Florist shift (`flowers.php:620`) | per shift | **half day = 8 h** (a full-day shift = 16 h) | your decision 6 |
| Raise sapling (`trade.php:385`) | setting | 15 min | |
| Tend a pal or a community plot (`player_jobs.php:270`, `community.php:275`) | 1 | 10 min | |
| Landmark repair, one work-day (`rebuild.php:440`) | per stage | **half day = 8 h** | |
| Lair (`landmarks.php:427`) | 2 | 2 h | |
| Landmark visits (`landmarks.php:304,328`) | 1 | 20 min | |
| Trek, enter (`trek.php:464,536`) | setting | 2 h | long fights may cost more, see question B |
| Town stop action (`stops.php:853`) | per action | 15 min | |
| NPC chat, gift | 0 | free | once per game-day |
| Pal jobs and delves | n/a | no time; run on game-days | |
| Minigames (game room, puzzle) | n/a | free; kept outside the clock, real caps | |
| **Nap** | gives partial energy | **2 h** | to tune |
| **Sleep** | full refill | jump to 06:00, unused hours lost | decision 11 |

**Tired (after 22:00), draft:** every action's energy cost +50%, shops and NPC stops show "closed/asleep", no hard block.

**Sample day (960 min):** water and tend 5, gather 3 times 45, craft 4 items 60, one trail of 4 sections 40, a 2 h trek 120, cook and chat 10, a repair day 8 h would take half the day by itself. So a full day fits about one big thing plus a few small ones. That matches "commit your gnome".

### Review (my own, before you read)
- **Good:** the free-under-10-min rule avoids a clock tick on every tap. The big commitments (shift, repair) are 8 h, so only about two fit a day. That is a natural brake on sleep-farming: you cannot do three shifts a day.
- **Risk 1:** two budgets (energy and time) double the tuning. Easy to end up with one that never binds. Keep an eye on this in the prototype.
- **Risk 2:** an 8 h repair or shift can't fit if you start at 15:00. Rule needed: allowed past 22:00 as "tired", or blocked until tomorrow?
- **Risk 3:** a half-day action means your cook pots and any 45 min timers all finish during it. Fine, but it makes cooking nearly free of time. Is that wanted?
- **Risk 4:** treks and fights are long and interactive. A flat 2 h cost per trek may feel wrong; charge per fight round instead.
- **Risk 5:** offline gnomes: `last_tick`-style catch-up (pal HP regrow "1 per 6 min", `PJ_EQUIP_XP_MAX` hours) is on the real clock. Those stay real, but the plan should say so.
- **Risk 6:** every place showing "ready in 3 min" (cook pots, trail) now shows game time on a personal clock. Two clocks on screen; the UI must label which.

### Questions to settle
- **A.** Cook pots: do they run on the game clock (finish as you spend time) or stay on the real clock?
- **B.** Treks: flat cost to enter, or time per fight round?
- **C.** Doing a long action late in the day (Risk 2): allow as tired, or block until tomorrow?

### Decisions 15-18 on the time-cost table (Josh, 2026-11-08)
15. **Craft mastery.** The more you craft, the less time it takes. Josh's scale: reductions per thousands crafted. Code check: `crafting.php` has no craft counter or skill today (only `calling_perk` hooks such as `cook_time_pct`, `extra_pot`, `extra_dish_pct`), so this needs a **new per-player craft count**. Draft to tune: count per craft category (not per recipe), -5% time for each 1,000 crafted in it, floor -40%. Open: per recipe or per category; does cooking share it; does it also lower energy.
16. **Late-day long actions (question C):** allowed after 22:00 (an 8 h action may run past the day's end). The **tired surcharge** (+50% energy, draft) applies and must be **shown before the player confirms**.
17. **Closing times override 16.** If the action is at a place that closes (a shop, a stop), **no overtime once it is closed**. Needs a closing hour on each shop or stop and a check against the player's clock plus the action's duration.
18. **Cooking is game time (question A).** Cook pots run on the gnome's own clock and finish as game minutes pass. Treks (question B): **ignored for now**, left out of the first build.

Still open: mastery scale and scope (15), where closing hours are stored (17), the late-start rule for actions that are not at a place (a craft at home has no closing hour, so it is always allowed as tired).

### Decision 19: two-tier craft mastery (Josh, 2026-11-08)
Mastery exists **per recipe and per category**, and the two give **different boons**. The boon types Josh named: time reduction, buffs, bigger amount made, and fewer materials needed (reduced down to a base floor). Replaces the single-scale draft in decision 15.

Draft split to tune (not decided):
| Tier | Counts | Boons |
|---|---|---|
| Per recipe | times that one recipe was made | time -5% per 1,000 (floor -40%); materials -1 unit at milestones, **never below a floor** (e.g. 50% of the base, min 1) |
| Per category | all crafts in the category | yield bonus (+1 made at milestones, or % chance of a bonus unit); energy cost reduction; unlocks a buff on the product |

Needs: two counters (a per-user per-recipe table and a per-user per-category table), milestone thresholds, and a display of progress on the recipe card.

Risks to watch:
- **Faucet:** fewer materials plus more yield makes goods cheaper to produce. Floors on both. Check against the NPC shop bucket (section 6) and player market prices.
- **Grind lock-in:** per-recipe counts at 1,000 per step reward repeating one recipe. Keep per-category the main reward for variety.
- **Cooking:** cook pots use the same counters (decision 18), so `calling_perk` boons (`cook_time_pct`, `extra_pot`, `extra_dish_pct`) must stack with mastery without double-counting. Decide the stack rule before building.

Open: milestone numbers, the floor, which products get a buff and what it is.

## 12. Second audit pass: callers of `hollow_today/now/hour/dow` (2026-11-08)

Read from code, with the enclosing function. About 49 call sites in `game/` (plus `tests/garden100.php`, `market100.php`, `clock.php`). Under decision 7 the **date** and the **hour** are both personal, so each call is classed by what it needs:
- **P-date**: needs the player's game date (season, weather, daily keys).
- **P-hour**: needs the player's game hour or weekday (NPC schedule, daypart, greeting).
- **S**: stays real.

### P-date (switch to the player's game date)
| File:line | What |
|---|---|
| `garden.php:427,483` | season chip, in-season seed toggle |
| `garden_logic.php:785,1209` | `garden_day_fx` speed, planting stamp (`pest_check`) |
| `garden_fx.php:59,69,180,195,412` | season state, pest check stamps, region weather |
| `garden_fx.php:325` | pest pass over yesterday and today: **rewrite to game-days** (already flagged) |
| `place_ui.php:111,650`, `layout.php:369` | header chip, seasons fold, right rail |
| `garden_critters.php:501,514,535` | garden visitor of the day (`garden_visitors.day`), keyed on the **plot owner's** game date |
| `animals120.php:174,186,207,255` | same, visitor trades per plot per day |

### P-hour (personal game hour and weekday)
| File:line | What |
|---|---|
| `gnome.php:116` | "Good morning/afternoon/evening" |
| `here.php:27`, `town.php:100` | "It's 14:00 in the Hollow, Tuesday" (decision 1 note) |
| `world.php:219-220` staff_on_duty | which NPC works the shop now; ties to **closing hours** (decision 17) |
| `includes/town.php:229` | spot closed by hour; same tie |
| `npc_life.php:126-127,181-182,216` | where an NPC is by hour and weekday |
| `friends.php:93-94`, `today_view.php:59`, `here_view.php:504-505` | NPC position / Today page by hour |
| `garden_critters.php:461` | frog pond visitor at dusk and night |
| `gathering.php:267` | gather scene art by hour |

### Inside `hollow_clock.php` (the engine)
| Line | Result |
|---|---|
| 78 `hollow_today($ts)` | keep as the **real** date; add a new `hollow_game_date($user)` for the player |
| 235-240 `hollow_weather` | checks `$date === $today` to apply `weather_force` (admin override). With a personal date the override would never hit. **Decide:** does admin force apply to everyone's game day, or only to players whose game date is today? |
| 268 `hollow_daypart($hour)` | takes an hour already; only the default (`hollow_hour()`) must become personal |
| 287-290 `hollow_now($region, $ts)` | derives date **and** hour from a real timestamp. **Signature change:** it must take a personal state (game date + game minute), not a timestamp |
| 310 `hollow_forecast`, 324 `hollow_next_season` | personal: forecast from the player's game date; "season day / next season" in **game-days** |
| 351,358,369 `hollow_line/chip/rail_section` | personal, via `hollow_now` |
| 389 `upgrade_100_clock` | S (one-time `season_epoch` setup) |

### New findings
1. **Season length is in real days** (Almanac text: "a set number of real days"). A personal calendar makes it **game-days**; players will see a season pass in N sleeps. Almanac text and `season_length` settings must be retuned.
2. **`season_epoch` mapping:** the helper maps the player's day counter to a `Y-m-d` from `season_epoch` (plan section 7), so `hollow_season_calc` keeps working unchanged.
3. **Weather is "same for everyone" by date plus region** (a pure function). It stays a pure function of the personal date, so two players on the same game date see the same weather. Good for visits (crossing calendars).
4. **`hollow_now` is the main seam.** It is called from the header, the Today page, the right rail, gardens and the seasons fold. One change to its inputs reaches all of them; everything in the P-date and P-hour tables funnels through it.
5. **Garden visitors** are the one place a wrapper (`hollow_today`) feeds a **database key** per plot. Use the owner's game date, and a visiting player must not make a visitor trade twice by sleeping (the row is the owner's).

### Tests
`garden100.php` (~60 uses, `garden_day_fx(…, hollow_today())` and pest stamps), `market100.php` (3), `clock.php` (about 8). Tests of the P rows must pass a game date; tests of `hollow_now` need the new signature.

### Audit result
`hollow_date(`: 144 calls sorted (section 10). Wrapper callers: sorted above. **Audit done.** Next in the build order: define the player game-date and game-clock state (day counter, minute of day), then `hollow_game_date($user)` and the new `hollow_now` signature.

### Question for Josh
Admin force of weather and season (`weather_force`, `season_force`): apply to every player's game date, or only to players currently on the real date? Draft: every player, since it is a debug tool.

### Decision 20 (Josh, 2026-11-08)
20. **Admin force of weather and season** (`weather_force`, `season_force`) applies to every player's game date. Josh is the only player right now, so no migration or compatibility concerns for existing players: the build can change data and schemas freely.

## 13. Spec: player game state (DESIGN ONLY, 2026-11-08)

Goal: the one thing every personal system reads. Built from decisions 7-11, 16-18, 20 and the audit (sections 10 and 12). Names are proposals.

### 13.1 Stored state (on `users`)
| Column | Type | Meaning |
|---|---|---|
| `game_day` | INT, default 0 | the day counter. +1 per sleep |
| `game_minute` | SMALLINT, default 360 | minutes since 00:00 of the current game day. 360 = 06:00 wake. **May exceed 1440** when a long action runs past midnight; the day only rolls on sleep |
| `energy_updated_at` | existing | no longer used once regen is removed; leave the column |

Derived, never stored:
- `game_date` = `hollow_date_add(<game epoch>, game_day)`. Epoch = `season_epoch` setting (fallback `HOLLOW_EPOCH_FALLBACK`). Weekday comes from this date, so `hollow_season_calc`, weather, festivals and the weekday-based NPC schedules keep working on a plain `Y-m-d`.
- `game_tick` = `game_day * 1440 + game_minute`. One monotonic number. **Cook pots and anything on the game clock store `ready_tick`**, and are ready when `game_tick >= ready_tick`. Sleep jumps the tick forward, so pots finish across a sleep. Jars and plants store a day (`ready_day`, `planted_day`), per decision 12.
- `game_hour` = `intdiv(game_minute, 60) % 24`.

**One-time start (single player, decision 20):** set `game_day` = days from epoch to today so the personal calendar begins where the shared one is now. No other migration.

### 13.2 Functions (new file `includes/game_clock.php`)
| Function | Does |
|---|---|
| `game_state(array $u): array` | `['day','minute','tick','date','hour','dow','tired']` |
| `hollow_game_date(array $u): string` | the `Y-m-d` personal systems pass to `hollow_season/weather/forecast` |
| `game_can_spend(array $u, int $minutes, ?int $closesAt = null): array` | `[ok, reason, tired_after, surcharge_pct]`. Fails when `$closesAt` is set and `game_minute + $minutes > $closesAt` (decision 17). Never fails for being tired (decision 9) |
| `game_spend(int $uid, int $minutes, ?int $closesAt = null): array` | atomic: `UPDATE users SET game_minute = game_minute + ? WHERE id = ? AND game_day = ? AND game_minute = ?` (reread on 0 rows, like the other two-tab guards). Returns the new state |
| `game_sleep(int $uid): array` | only in the hovel. `game_day + 1`, `game_minute = 360`, `energy = max_energy`. Fires `game_new_day($uid)` |
| `game_nap(int $uid): array` | `game_spend(nap_minutes)` plus `energy += nap_energy_pct% of max`. Does not change the day |
| `game_is_tired(array $u): bool` | `game_minute >= 1320` |
| `game_energy_cost(array $u, int $base): int` | base, +`tired_energy_pct` when tired. **Every energy cost goes through this** (all 23 `spend_energy` sites) |
| `game_time_cost(string $key): int` | the cost table (section 11) read from settings, so Josh can tune it in admin |

`game_new_day($uid)` is the only hook; daily limits don't need one because they are keyed on `game_date`.

### 13.3 Changes to existing code (for the build, not now)
- `hollow_now(?string $region, ?array $state)`: `null` = real clock (guests, shared pages, admin). A state gives the personal date **and** hour. The current `$ts` argument stays for tests.
- `hollow_hour()`, `hollow_dow()`: unchanged (real). Personal callers (section 12 P-hour table) take `game_state($u)['hour'/'dow']` instead.
- Energy: delete regen (`energy_tick`, `refresh_energy`, settings `energy_regen_*`). Keep `max_energy`, food and snacks.
- Season mode: set `season_mode` to the epoch mode (not `real`). In `real` mode seasons follow calendar months, so a personal date would walk through spring in months of sleeps. In epoch mode `season_length` is in game-days.
- Closing hours: add `opens`/`closes` (minutes) to shops and stops, or a lookup, so `game_can_spend` has a `$closesAt`. `npc_schedules` already has `start_hour`/`end_hour` for staff.

### 13.4 Settings (admin, with defaults)
`game_day_start` 360 · `game_day_end` 1320 · `nap_minutes` 120 · `nap_energy_pct` 50 · `tired_energy_pct` 50 · plus one `time_<action>` per row of section 11.

### 13.5 What stays on the real clock
Daily caps and stamps (class C), market bucket drain, community goals, contests, Garden of the Month, pal HP regrowth, offline catch-up. **No game time passes while a player is away.** The clock only moves when they act or sleep.

### 13.6 Open before building
- A long action that passes 06:00 of the next calendar day (for example 8 h shift started at 21:00): allow, with growing tired cost? Draft: allowed, no cap; the tired surcharge is flat.
- Where can you nap? Draft: anywhere that is not a closed place. Sleep: hovel only.
- Does `game_spend` advance the clock for failed or cancelled actions? Draft: no, spend only on success.
- Guests and logged-out pages show the real clock.

### 13.7 Tests to write first
`game_sleep` (day, minute, energy), `game_nap` (day unchanged, partial energy), `game_spend` (two-tab race), `game_can_spend` with a closing time (blocks, allows), tired surcharge on `game_energy_cost`, `game_tick` ordering across a sleep (a cook pot with `ready_tick` finishes), `hollow_game_date` feeding `hollow_season/weather` identically for two players on the same date.

### 13.8 Spec check against the code (2026-11-08) — corrections to 13.1-13.7
Checked each claim in section 13 against the repo. Four were wrong or incomplete; the rest held.

**Corrections**
1. **Season mode names.** There is no "epoch mode". `season_mode` is `game` (default: seasons last `season_days`, counted from `season_epoch`) or `real` (calendar months). The default is already `game`, so 13.3 should read: *keep `season_mode=game`; `season_days` becomes game-days.* Only a `real` setting would break.
2. **Energy cost has one choke point.** `spend_energy(int $uid, int $n)` (`garden_logic.php:317`) is the one function behind all 23 call sites. Apply the tired surcharge **inside it** (SQL can do it: read `game_minute >= 1320` and multiply), not at each site. Display text ("costs 3 energy") is computed by callers before the spend, so those labels need `game_energy_cost($u, $base)` too. That is the part that touches many files.
3. **There is no "hovel" in the code.** A search for `hovel` finds nothing. The rule "sleep in the hovel" needs a **place to sleep**: a home/hovel page or button, plus a rule for where it shows. Add this to the build list. Open: does it need to be at home only, or at any inn/bed too?
4. **Removing regen touches more than 13.3 listed:** `refresh_energy()` (called from 29 places), `current_energy($u)` and the regen-countdown pill in `layout.php:290-304` (read `energy_updated_at`), `fresh_start.php:25` and `schema.php:48` (the column), and the `energy_scale` migration in `functions.php` (~1026, one-off, leave). Plan: turn `refresh_energy` into a no-op first, delete callers after.

**Held (verified)**
- `hollow_date_add()`, `hollow_season_epoch()`, `hollow_season_length()` exist as assumed.
- `spend_energy` call sites: 23, matches section 11.
- `npc_schedules` has `start_hour`/`end_hour` (staff hours), so closing hours for staff-run shops have a base.
- `HOLLOW_EPOCH_FALLBACK` exists for the epoch.

**Added to 13.6 open list:** the place to sleep (item 3) and whether a nap needs a bed.

### Decision 21: where a gnome can sleep (Josh, 2026-11-08)
21. Sleep is allowed at: **home** (the hovel), an **inn**, **in town**, or **on the road with camping gear (one use per sleep)**. Replaces the "hovel only" rule in section 2.

Code check: a search for camping, tent, bedroll and inn finds nothing, so **the hovel, inns and camping gear are all new content**. Build list adds:
- A sleep action on the home page.
- Inns (a place type with a bed and a closing rule). Open: free, or coins?
- A camping gear item, consumed on use, sold or crafted somewhere. Open: price, and does it also work as a nap?
- "In town": taken as a bed or bench in towns. Open: confirm what Josh means and whether it costs anything.
- Open: the nap rule (does a nap need any of these, or work anywhere?). The earlier draft said anywhere that is not closed.

### Decisions 22-23: inn and town sleep (Josh, 2026-11-08)
22. **Inn:** costs a **small Petal fee**, or the player **helps around the property for x time** instead. So the inn can be paid in Petals or in game minutes (chores). Overrides the 'free inn' draft. Open: the fee, the chore time x, what the chores are (a small timed task that spends game minutes).
23. **Sleep in town offers all three, player's choice:** a public bench or park (free, weaker rest, small chance of a bad event), a rented room (same as an inn), or staying with a friendly NPC (free, gated by friendship). Open: how weak the bench rest is, the friendship level for a villager's house.

### Decisions 24-25: camping gear and naps (Josh, 2026-11-08)
24. **Camping gear:** buyable at a shop **or** craftable; crafting is cheaper. One use per sleep, then consumed. Fits the craft mastery system (decision 19). Open: recipe materials, shop price (markup over crafting).
25. **Naps need a seat or bed.** Allowed at home, an inn, a town bench or park, or camp. Not mid-trail, and not inside a closed place. Overrides the 'anywhere' draft in 13.6. Open: does a nap on the road need camping gear? (Draft: no, a roadside rest stop counts as a seat only where the trail has one.)

### Decision 26 (Josh, 2026-11-08)
26. **Inn fee: 110 Petals per night** (the alternative is chores for x time, decision 22). Store it as an admin setting (`inn_fee_petals`, default 110) so it can be tuned. Still open: chore time x, so the chore option is priced fairly against 110 Petals.

### Decision 27 (Josh, 2026-11-08)
27. **Inn chores take 4 game hours** (240 min), as the alternative to the 110 Petal fee. Admin setting `inn_chore_minutes`, default 240. Open: what the chores are (a short scripted task or a simple tap-through) and whether tired-surcharge energy applies during them.

### Decision 28 (Josh, 2026-11-08)
28. **Inn chores are a plain timer for the first build:** pay 240 game minutes, then sleep. No scene, no reward. A scripted or choice-based version is later content.

### Decision 29 (Josh, 2026-11-08)
29. **Bench sleep restores 30% energy, no bad-event chance.** Free. Admin setting `bench_sleep_energy_pct`, default 30. Closes open Q1 from decision 23 (bad-event part dropped).

### Decision 30 (Josh, 2026-11-08)
30. **Villager's house unlocks at friendship level 3.** Free stay. Admin setting `villager_sleep_friend_level`, default 3. Closes open Q2 from decision 23.

### Decision 31 (Josh, 2026-11-08)
31. **Camping gear: shop price 100 Petals, craft cost about 60 Petals of materials (60% of shop).** One use. Admin setting `camping_gear_price`, default 100. Still open: exact recipe materials (pick from existing items, check data before writing).

### Decision 32 (Josh, 2026-11-08)
32. **Camping gear on the road gives a choice: nap (partial) or full sleep.** With gear in use, the player may also **start one cook pot that is ready when they wake** (one pot per camp). Replaces the "rest stop only" draft for road naps; closes open Q4. Open: does a nap use up the gear or only a full sleep? Which recipes can be cooked at camp?

### Decision 33 (Josh, 2026-11-08)
33. **Camping gear has 2 charges for naps; a full sleep uses it up.** Gear = 2 naps, or 1 full sleep (full sleep consumes the whole item). Camp pot (decision 32) allowed on full sleep; open whether it is allowed on a nap. Admin setting `camping_gear_nap_charges`, default 2.

### Decision 34 (Josh, 2026-11-08)
34. **Tired surcharge grows: +10% energy cost per game hour past 22:00** (inside `spend_energy()`). Admin setting `tired_surcharge_pct_per_hour`, default 10. Closes open Q5. Open: cap? (Draft: none needed, since an action past midnight still ends at 06:00 wrap.)

### Decision 35 (Josh, 2026-11-08)
35. **Per-recipe mastery tiers at 10 / 50 / 200 crafts.** Admin setting `mastery_tiers` default `10,50,200`. Open (rest of Q6): materials floor per tier, which products get a buff, stack rule with `calling_perk` boons, category-mastery thresholds.

### Decision 36 (Josh, 2026-11-08)
36. **Mastery material floor 50% of base.** Per-recipe tiers cut materials: T1 -10%, T2 -25%, T3 -50%, each ingredient min 1. Admin setting `mastery_material_cuts` default `10,25,50`. Open (rest of Q6): which products get a buff, stack rule with `calling_perk` boons, category-mastery thresholds.

### Decision 37 (Josh, 2026-11-08)
37. **Category-mastery buff bonus applies to food and potions only.** Other categories get yield/energy gains only. Open (rest of Q6): stack rule with `calling_perk` boons, category-mastery thresholds.

### Decision 38 (Josh, 2026-11-08)
38. **Mastery bonuses add to `calling_perk` boons, total capped at +50%.** Admin setting `mastery_perk_cap_pct`, default 50. Open (rest of Q6): category-mastery thresholds.

### Decision 39 (Josh, 2026-11-08)
39. **Category mastery tiers at 100 / 500 / 2000 total crafts in the category.** Each tier: +5% yield, -5% energy, +5% buff (buff on food and potions only, decision 37). Admin setting `category_mastery_tiers` default `100,500,2000`. Closes Q6. (Per-tier +5% values are my default; change if Josh says.)

### Decision 40 (Josh, 2026-11-08)
40. **NPC shop sell-bucket (section 6) is kept at the same size**, real-time drain as before. Closes Q7.

### Decision 41 (Josh, 2026-11-08)
41. **Closing hours live per place in data** (shops, stops, inns): `open_minute` and `close_minute` fields. Blank = default 06:00-22:00 (360-1320). Inns are open all night. Admin settings `default_open_minute` 360, `default_close_minute` 1320. Closes Q8.

### Decision 42 (Josh, 2026-11-08)
42. **Nap: 2 game hours, restores 40% energy.** Admin settings `nap_minutes` 120, `nap_energy_pct` 40. Tired surcharge in the section 11 draft (+50% flat) is replaced by decision 34 (+10%/hour past 22:00). Open: rest of Q9, row by row.

### Decision 43 (Josh, 2026-11-08)
43. **Long actions (shift, repair, 8 h) may start late and split across days:** hours left at 22:00 carry to the next morning (after sleep, 06:00). No block, no tired surcharge on the carried part. Closes risk 2. Open: does the carried work need the player to stay put, or can they sleep elsewhere? Is the unfinished action locked (cannot start another) until done?
