# Prompt for the next AI: sleep-days (paste this to start)

You are continuing the **sleep-days** build for Gnome Venture (repo `joshfryart/gnome-venture`, PHP game in `game/`). The design is finished (decisions 1-57 in the plan). **Thirty build steps are done and merged to `main` (the Step 14-30 lines in the plan list what was added since the first 13; the "not built yet" list below is out of date: see claude/todo.md section 4 OPEN for what is left), all behind one setting `game_clock_on` (default off).** With the flag off the game behaves exactly as before. **UPDATE: flag is ON by default since 2.6.09 (start step runs once on upgrade, pal jobs on game time only).** See claude/todo.md for what is open.

## Read first, in this order
1. `claude/plan-sleep-days.md`: sections 1-9 (original rules), 10-13 (audit, time-cost table, wrapper audit, spec), then the **decision log at the end (decisions 1-57) and the "Step N" build log lines. Later text overrides earlier text.**
2. `game/includes/game_clock.php` (all new clock code: state, spend, sleep, nap, rest places, growth, pots, jars, new-day hook, time costs, camping).
3. `tests/game_clock.sh` + `tests/game_clock.php`: the test for everything built. Run it after every change: `bash tests/game_clock.sh` (about 1 min; prints `all ok`). Also run `bash tests/garden100.sh` (expects `all ok`).
4. `claude/todo.md` sections 3-4 and `claude/handoff.md` top block.

## What is built (all behind `game_clock_on`)
- Personal clock: `users.game_day`, `game_minute`, `carry_minutes`, `camp_naps`. Functions `gclock_state`, `hollow_game_date`, `game_spend`, `game_sleep($uid, $energyPct)`, `game_nap`, `game_energy_cost`, tired surcharge +10% per game hour from 22:00. Note `game_state()` already existed in `games.php`, so ours is `gclock_state()`.
- `hollow_now($region, $ts, $state)` takes a game-clock state.
- Garden growth in sleeps (`gclock_tile_grow`, tiers 1-6 = 1/2/3/5/7/10 sleeps, watered-that-day or rain, dry days are owed and paid back). Columns `plot_tiles.grow_day`, `water_day`, `owed_days`. All 5 watering writers stamp `water_day`.
- Energy: `refresh_energy` no-op, no regen, `spend_energy($uid, $n, $timeKey, $units)` adds the tired surcharge and charges game time.
- Rest page `hovel.php`: hovel (home), inn (110 Petals or 240 min chores), bench (30% energy), nap, villager's house (Best friend), camp (camping gear: 2 naps or 1 sleep, plus one camp meal pot ready at wake). Camping gear item, parts and recipes in `data/crafts.txt`, sold in `decor` shops.
- Cook pots (`cook_pots.ready_tick`, 4x time), pantry jars (`pantry_jars.ready_day`), pal jobs (`game_new_day` moves their clocks 8 h per sleep; real time still counts too), job board (`job_board_key`, week = 7 sleeps, month = 28).
- Time costs (`GCLOCK_TIME_DEFAULTS`, section 11 table; arrange 10, sapling 10), long shifts/repairs split across days and lock the gnome until sleep (`carry_minutes`).

## What is NOT built yet (do in this order, ask Josh only when a choice is really his)
1. **Garden leftovers: DONE (step 14).** Open: no-till `bed_tick` and `season_chip` still real time.
2. **Closing hours: DONE (step 15).** Open: admin fields for open/close, other shop paths (`sinks.php`).
3. **Other personal systems: DONE (steps 16-17).** Open: `festival_active()["left"]` real seconds; `arrange_ctx` month; NPC "move on" mood/wants by game day (beyond the schedule hour) not built.
4. **Labels and UI:** "costs N energy" labels need `game_energy_cost()`; the header energy pill still shows regen text; label game time vs real time; a visitor's view of a kitchen (`gardens.php:567`) still reads `ready_at`; reward for a split shift/repair is still paid at the start.
5. **Gaps noted in time costs:** actions with 0 energy cost skip the time charge; seed packet and treks not wired; inn nap not offered.
6. **Equip XP + pal HP: DONE (step 21).** Player HP (`health.php`) still real time.
7. **Final:** one-time start value (`game_day = game_clock_days_from_epoch()` for the existing player), tests that need a `walk.sh` install (`cook.sh`, `craft.sh`, `paljobs.php`, `events.sh`, `help.sh`: they cannot run standalone here, run them before flipping the flag), admin settings page for the new settings, then ask Josh about flipping the flag and the version bump (`APP_VERSION` in `game/includes/bootstrap.php`, currently 2.6.08).

## Josh
Single player right now, so data and schemas can change freely. Prefers super short caveman replies, exact descriptions. **Ask questions one at a time** with AskUserQuestion (2 to 4 distinct options, recommended first). Record each answer in the decision log of the plan, commit and push to the session branch after each step. He said to continue without asking until an answer is really needed, and to expect pauses for usage: commit small and often so nothing is lost.

## Rules
- Work on the designated session branch, commit, push. Merge to `main` only when Josh says so (he did at the end of the last session; ask again).
- Check claims against the code before writing them down (an earlier spec had four errors from memory).
- Keep the plan, `claude/todo.md` and `claude/handoff.md` in step.
- Every behaviour change must be behind `gclock_on()` and covered in `tests/game_clock.php` with a flag-off check.
- Beware of test pitfalls found so far: SQLite compares bound strings to ints as text (use `CAST(? AS INTEGER)`), `tests/game_clock.sh` runs one shared database so reset any user fields you change, and never put `cat >> /dev/null` in a command (it hangs on stdin).
