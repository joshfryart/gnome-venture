# Prompt for the next AI: sleep-days (paste this to start)

You are continuing the **sleep-days** system change for Gnome Venture (repo `joshfryart/gnome-venture`, PHP game in `game/`). It is **design-only so far: no code, no data, no version change.** Do not write game code or bump the version unless Josh asks.

## Read first, in this order
1. `claude/plan-sleep-days.md`: sections 1-9 (original rules), then 10-13 (audit, time-cost table, wrapper audit, spec and its 13.8 corrections), then the **decision log at the end (decisions 1-28). Later decisions override earlier text.**
2. `claude/todo.md` sections 3 and 4 (the Sleep-days block).
3. `claude/handoff.md`, top block.

## What is decided (short)
- Each player has a personal game clock: `users.game_day` and `users.game_minute` (day 06:00 to 22:00, tired after 22:00, never locked). Sleep jumps to 06:00, full energy, day +1. Nap = about 2 h, partial energy, needs a seat or bed.
- Energy and time are separate budgets. Regen by minute is removed. Actions of 10+ minutes spend game minutes (table in plan section 11). Tired surcharge goes inside `spend_energy()`.
- Personal (game date or clock): garden, pantry jars, cook pots (game clock), pal jobs, job board, puzzle pal spawn, NPC chat and gifts, stops, town calendar, festivals, free mends, order deadlines, Cat Fish weekly cap (game-week = 7 sleeps). Real: caps and stamps, minigame Petals, market bucket drain, shared goals, contests, first-week onboarding.
- Sleep places: home, inn (110 Petals or 4 h of plain-timer chores), town (bench / rented room / villager's house), road with camping gear (buy or craft, one use).
- Craft mastery: per recipe (time, materials down to a floor) and per category (yield, energy, buff). Treks are left out of the first build.
- The audit is done: `hollow_date(` has 144 calls sorted (section 10), wrapper callers sorted (section 12).

## Josh
Single player right now, so data and schemas can change freely. Prefers short, exact replies (caveman style). **Ask questions one at a time** (use AskUserQuestion with 2 to 4 distinct options, recommended one first). Record each answer in the decision log of the plan, commit and push to the session branch after each.

## Open questions to ask (one at a time, in this order)
1. Bench sleep: how weak is the rest (energy %), and is there a small bad-event chance?
2. Villager's house: which friendship level unlocks it?
3. Camping gear: recipe materials, shop price (craft must be cheaper).
4. Road nap: does it need camping gear, or only a trail rest stop?
5. A long action that runs past midnight: flat tired surcharge, or growing?
6. Craft mastery numbers: milestones, materials floor, which products get a buff, stack rule with `calling_perk` boons.
7. With time as a budget, is the NPC shop sell-bucket (plan section 6) still needed, and with what size?
8. Closing hours: where they live (shops, stops, inns) and the default.
9. Time-cost table (section 11): review every row with Josh; set the tired surcharge and nap numbers.

## When the questions are done
Next step is the build, in this order (also in `claude/todo.md`): `includes/game_clock.php` and the two columns; `hollow_now(?string $region, ?array $state)` and `hollow_game_date($u)`; garden growth on game-days behind a flag (default off, rewrite the timestamp walks in `garden_fx.php`); sleep action and hovel page; `refresh_energy()` to a no-op then removal; `spend_energy()` surcharge; pantry, cook pots (`ready_tick`), pal jobs, job board. Write the tests listed in plan section 13.7 first. Ask Josh before starting the build.

## Rules
- Work on the designated session branch, commit, push. Merge to `main` only when Josh says so.
- Check claims against the code before writing them down (section 13.8 found four errors in a spec written from memory).
- Keep the plan, `claude/todo.md` and `claude/handoff.md` in step: update all three when something is decided.
