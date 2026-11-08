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
