# Sleep-days: the game moves forward when the player sleeps (design, 2026-11-07)

Status: **DESIGN ONLY. No code, data or version change.** Decided by Josh in a Q&A brainstorm (2026-11-07). Next step: code audit (section 9), then a prototype of garden growth only.

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
