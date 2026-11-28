# Sim: Standing and Petals in the Maplewold (with a Maizehollow spot check)

Date 2026-11-27. Model of `PROPOSAL-HOLLOW-MASTER.md` sections 3, 4, 7, 8, 14 and the M1-M7 chapters of `proposal-story-2-quests.md`. No game code changed.
Script: `python3 claude/tools_sim_standing.py --runs 400 --bar-runs 300 --seed 7` (about 90 s). It prints `claude/sim-standing-out/printout.txt` and writes the CSVs in `claude/sim-standing-out/` (`crops_na.csv`, `stop_act_econ.csv`, `bar_pace.csv`, `runs.csv`, `standing_by_day.csv`, `petals_by_level.csv`). Seeded, so a re-run gives the same numbers.

## Summary

| # | Question | Verdict | Key numbers (median, p10-p90) | Recommended change |
|---|---|---|---|---|
| 0 | (found on the way) XP table in master 2.1 | **WRONG** | `users.xp` is a running total and `xp_for_level(15)` = **18,375**. 75,650 is the sum of the thresholds Lv 2 to 15. The same mistake is in every band: Lv 25 is 97,500 (not 626k), Lv 35 283k (not 2.5M), Lv 45 619k (not 7.0M), Lv 55 1.15M (not 16M) | Fix master 2.1 and the bands doc. Re-base every "35% of the band's XP" in story-2 1.4 on these totals |
| 1 | Petals: can the Stops row (3,600 + 32 stone, 34 planks, 3 rope) be paid without stalling? | **PASS** (CONCERN early) | Gross Petals a game day: Lv 1 55, Lv 5 200, Lv 10 470, Lv 14 800. Cumulative gross: **day 20 5,000** (4,640-5,450), **day 35 14,700** (13,400-15,800). Petals left after seeds, stage Petals and meals reach 3,600 on **day 26** (25-27). The whole row is paid in every run. The 7th lamp is lit on day 28 (27-29). Petal waits: 4 step-days a run (p90 6), mostly the M1-M3 stage Petals and the M3 stall (400), not the lamps (0.4) | No change. The waits are in Lv 1-6, when stop acts pay 8 Petals each. Paying M1 and M2 400 Petals each changed nothing (the waits are about when in the day the Petals arrive). The materials cost more than the Petals: about 218 energy and 1.9 game days of gathering and crafting |
| 2 | Standing slack, non-fighter vs fighter | **CONCERN** | Days to 80% = days to finish the main line, because M7 is the last step: non-fighter **34** (32-36), fighter **32** (31-34), planner 30, a 16-bed gardener 40 (36-45). Master range 20-35. Standing when the main line is done: non-fighter who does some side content 87.2 (85.2-87.7), all runs at 80 or more. **Non-fighter who does only the main line: 80.2, 91% at 80 or more, 0.2 points of slack.** Without the Owl's evenings: 75.2, 0% | Keep 80. Give the main line a second helper errand (M2 or M5) and let the errands row need **3 errands, not 5**. Then a main-line-only non-fighter has 82.5 (2.5 slack). Or lower the Seal to **78**: 100% of main-line-only runs pass, with 2.2 slack |
| 3 | XP: does the Maplewold pay about 85% of the XP to Lv 15? | **CONCERN** (the target is right, the number behind it is not) | Against the real 18,375: non-fighter earns **14,860 XP (81%)** by the Seal and reaches Lv 14. Fighter earns 18,800 (102%), Lv 15. Main-line-only non-fighter earns 14,600 (79%). Sources for the non-fighter: chapters 6,430, harvests 6,050, stop acts 1,790, errands 270, everything else under 450. Sized on the doc's 75,650, the chapters alone pay 26,480 and the gnome is **Lv 18-19 at the Seal** | Chapter pool = **40% of the real band XP**: 7,350 for M1-M7 (about 1,225 a zone chapter and 410 for M7). That puts the non-fighter at about 86%. Do not raise harvest XP: it is already 41% and grows with beds |
| 4 | Bar pace: 6 to 10 visit-days? | **PASS** (depends on the answer acts) | 5 acts a visit, top of the list: one bar takes **7 visit-days** (5-8), all three bars at a stop take **8** (7-8). 98% of the 54 bars are in 6-10. Latching all 54 Maplewold marks with perfect routing at 3-4 stops a day takes **41 game days** (39-42); master says 34-51. With best-bar picks: 35. With 3 acts a visit: 16.5 visit-days (worst stop 42) and 91 game days for all 54. Without the four answer acts: 13.5 (worst 61) | Keep the answer acts on "bar not full" (perks doc 2). Say in the UI that 5 acts a visit is the pace. Watch Repairs at orchards (Honeythorpe: 42 visit-days at 3 acts) |
| 5 | Maizehollow (Lv 15-25) spot check | **PASS** with one CONCERN | Bars: 8 visit-days (7-9), 12 stops latch in 26 game days. Petals: stop acts pay **33.5 each** (Maplewold 8.1), so with 36 beds a gnome makes **1,170-1,420 Petals a game day**. The area's Stops row (N = 10: 6 lit, 2 stalls) costs about 3,500, plus 1,100 for the stages, which is **3-4 days of income**. XP: Lv 15 to 25 is 79,125. Chapters at 35% pay 27,700, and the rest comes in at 760-1,230 XP a day: **42-68 game days** for both areas side by side (master: 39-65) | From tier 2 on, Petals never hold anything back. If the Stops row is meant to cost effort in bands 2-5, scale its Petals with the stop level (pay rises 4x from band 1 to 2) or rely on materials. Standing was not simulated for Maizehollow |

## 1. Method

One gnome, day by day for up to 90 game days, 400 runs for each variant. Each game day:

1. Energy: `max_energy` (10 + 5 a level) × 1.4 for one nap. Garden harvests run first. Up to half the energy goes on planting.
2. Chapter steps in order (M1-M7 as written, master section 6). Each stage takes 480 game minutes. Materials cost energy and time (below). Lamps, the stall and stages are paid when the Petals are there; a short day counts as a stall-day.
3. Touring: 3 or 4 stops (one choice per run, master A1). Chapter stops come first (Regular targets, the paddy, Aurora Camp for the Owl, the town for the Friend, threads under way), then the stops with the fewest full bars. Each stop gets 5 acts. The offer is built the way `stop_pool` builds it (specials, answer acts, thread, 3 core, extras) from the real act files. Pay follows `stop_rewards` at the stop's level, which is the region's band floor (`stop_level` = `location_min_level`). Bar points follow master 7.3.
4. Side quests (story-2 3.1 with their triggers), optional crops, flowers and places. The gnome does a random share of them (25-100%), and all of them once M6 is done and M7 is under way (it reads Wren's meter). The "main-line-only" variant does none until the main line is done.
5. Planting with what energy is left. A shortfall is eaten as home-cooked meals: 5 crops for 10 net energy. There is no cap on eating in the code.
6. Spare crops are sold at `floor(base × 60%) × rarity mult`. Spare beds rotate over the 7 buyable Maplewold crops.

**Taken from the game data and code:** `xp_for_level` and the action-XP scaling; crop tier, rarity, price, seed price, XP and sleeps (`catalog.php` rules on `crops.txt` / `region_crops.txt` / `flowers.txt`); regrowth at 75% yield and 60% XP; perennial life and the yield drop to 80%; garden energy costs; bed price growth; 500 starting Petals; all 860 stop acts with their pay, energy, dice and conditions; the 1,511 act-to-bar rows of `proposal-stop-act-bars.txt`; the tier costs (`stop_tiers.txt`), the 300 fee, tier XP (+20 a tier) and the adopter's welcome; thread pay (`stop_threads.txt`); passport sets (`stop_sets.txt`); creature XP and Petals (`adventure_data.php`, creature SPEC 5.2); job pay (`jobs.txt`); meal energy (11) and cook XP.

**From the proposal:** chapter steps, stage costs, errand pay (story-2 3.1); chapter Petals 150 rising to 600 (story-2 1.4, read as a straight line); bed hand-ins 3/5/8; 6 beds on wild rice; Standing weights and formulas (master 4).

**Assumptions** (all in `ASSUME` in the script; change one and re-run): stat modifier +1 on checks; craft acts doable half the time; 70% gathering success, so a stone costs 4.7 energy and 32 min and a plank 2.0 energy and 16 min; rope and beeswax bought at twice their base price; a find takes 90 min, an escort 90, an errand 60-150; the Friend takes 6-12 chat days; a chapter opens when the one before has no work left and the level is within 2 of the zone floor; beds can be bought up to 16 / 20 / 24 / 28 / 32 at Lv 1 / 5 / 8 / 11 / 13 (the garden-level gate is not modelled); "places found" counts 24 places (12 villages and 12 off-road places, plus any secret found); the pages row is the mean of the places, crops and folk shares; a fighter meets about 2 fights a touring day, clears the Tunnels at Lv 9 and beats the Owl at Lv 14.

## 2. Q1: Petals

**Income by level** (gross a game day, non-fighter, jobs off; `petals_by_level.csv`)

| Lv | Gross | Stop acts | Crop sales | Chapters | Errands + threads | Passport + welcome |
|---|---|---|---|---|---|---|
| 1 | 55 | 53 | 2 | 0 | 0 | 0 |
| 2 | 91 | 48 | 37 | 0 | 5 | 0 |
| 5 | 203 | 12 | 54 | 135 | 0 | 1 |
| 6 | 233 | 101 | 90 | 1 | 15 | 26 |
| 7 | 302 | 111 | 170 | 0 | 18 | 3 |
| 8 | 311 | 118 | 180 | 0 | 12 | 0 |
| 10 | 469 | 84 | 234 | 115 | 36 | 1 |
| 12 | 717 | 123 | 273 | 247 | 34 | 40 |
| 14 | 796 | 136 | 526 | 56 | 36 | 42 |

(Lv 3 is low and Lv 4 is missing because M1's chapter XP jumps the gnome from Lv 3 to Lv 5.) Across all days: crop sales 255, stop acts 95, chapters 66, passport 16, threads 13, errands 10. The fighter adds about 15 a day from fights. The job board, which follows game days with the clock on (`jobs.php:34`), would add about 116 a day (70% / 60% / 40% of daily, weekly and monthly offers done, 30% of the pay handed back as crops); it is reported apart.

**Cumulative Petals and the Stops row**

| Variant | Gross by day 20 | by day 35 | Free* reaches 3,600 | Petal waits (step-days) | 7th lamp |
|---|---|---|---|---|---|
| non-fighter | 5,020 (4,640-5,450) | 14,690 | day 26 (25-27) | 4 (p90 6) | 28 |
| fighter | 5,370 | 16,140 | day 24 | 3 | 27 |
| non-fighter, job board on | 7,000 | 20,460 | day 19 | 1 | 26 |
| non-fighter, 16 beds only | 4,900 | 12,100 | day 25 | 3 | 27 |
| planner (sows chapter crops on day 1, 3 stops a day) | 5,020 | 14,050 | day 24 | 6 (lamps 2.8) | 27 |

\* Free = gross minus seeds, stage Petals, stop buys, food bought for meals and bought rope or beeswax.

Petal waits by cause (non-fighter, mean a run): chapter stage Petals 2.3, M3 stall (400) 1.6, lamps 4-7 0.4, M1/M2/M4 lamps 0.0. A wait is counted when the morning check is short, so most of them clear later the same day or the next. Paying M1 and M2 400 Petals instead of 150 and 225 left the waits at 6 for the planner: they are not about the total. The planner is the one case where the lamps themselves hold things back (2.8 step-days): A8's warning holds only for a gnome who rushes.

**Materials, not Petals, are the real cost of the row.** 32 stone and 34 planks are about 218 energy and 1,570 game minutes (1.9 game days) of gathering and crafting. With the stages added (41 stone, 44 planks, 12 rope, 6 beeswax, 7 flint) it is about 281 energy and 2.4 game days.

**Why the Maplewold is poor in stop Petals:** `stop_level` is the region's floor, and the Maplewold is band floor 1, so `c=8:3` pays 11 Petals at every Maplewold stop. That is 8.1 a done act on average, against 33.5 at Maizehollow stops. The garden carries band 1.

## 3. Q2: Standing slack

**Standing on the day the main line is done** (M1-M6 and M7 steps 1-4)

| Variant | Day (p10/p50/p90) | Standing p10 / p50 | Share at 80 or more | Rows below full (median) |
|---|---|---|---|---|
| non-fighter (some side content, reads the meter late) | 32 / 34 / 36 | 85.2 / 87.2 | 100% | raised 6.7, hearth 2, delve 0; flower 2 at p10 |
| fighter | 31 / 32 / 34 | 90.7 / 92.7 | 100% | raised, hearth |
| **non-fighter, main line only** | 32 / 33 / 35 | **80.2 / 80.2** | **91%** | errands 1 (dam debt only), flower 2, places 9.2, pages 4.4 |
| fighter, main line only | 30 / 32 / 34 | 85.2 / 85.7 | 100% | as above, plus delve 5 and lair 5 |
| planner | 30 / 30 / 31 | 85.2 / 87.2 | 100% | |
| 16 beds | 36 / 40 / 45 | 85.7 / 87.7 | 100% | |

The Seal comes when the main line is done in every variant; none needed more than a day after it. The Owl's three evenings are an M7 step, so every Seal run has them. The ceiling for a non-fighter (7 lit, Hearth tier 2, every other row full) is 87.7, as in master 4.

Median Standing by game day (non-fighter): day 10 19, day 15 33, day 20 48, day 25 62, day 30 79, day 35 88 (`standing_by_day.csv`). Chapter done days (median): M1 7, M2 17, M3 18, M4 26, M5 27, M6 34. M6 waits on wild-rice hand-in 3 and on the level hint (Lv 10). The 13 stages, at 480 min each, are about 7.4 full game days of the gnome's time.

**What-ifs** (Standing recomputed on the main-line-done day)

| Rule | Base non-fighter: p50, share at the line | Main-line-only non-fighter: p50, share at the line |
|---|---|---|
| as proposed (80) | 87.2, 100% | 80.2, 91% (slack 0.2) |
| as proposed, Owl not done | 82.2, 98% | 75.2, 0% |
| threshold 78 | slack 9.2 | 80.2, 100% (slack 2.2) |
| threshold 75 | slack 12.2 | 80.2, 100% (slack 5.2); without the Owl 75.2, 91% |
| errands row needs 3, not 5 | 87.2, 100% | 80.9, 99% |
| errands row needs 3 and a second main-line helper errand (arithmetic: 2 of 3 = 3.3 points instead of 1) | 87.2 | about 82.5, 100% (slack 2.5); without the Owl 77.5 |

Reading: master 4's "2.7 slack" holds for a gnome who does the side quests (82.2 without the Owl here). A gnome who plays only the chapters has no slack: errands (1 of 5), flowers (one native flower, 2 of 4), and the places and pages shares are where the points go. Places and pages have no defined count in the proposal. With 30 places instead of 24, the main-line-only gnome loses about 1.9 more and drops under 80.

## 4. Q3: XP

| Variant | XP by the Seal | Share of 18,375 (real Lv 15) | Share of 75,650 (doc) | Lv at the Seal |
|---|---|---|---|---|
| non-fighter, chapters 35% of 18,375 | 14,860 | 81% | 20% | 14 |
| non-fighter, main line only | 14,600 | 79% | 19% | 14 |
| fighter | 18,800 | 102% | 25% | 15 |
| non-fighter, chapters 35% of 75,650 (as the doc says) | 37,040 | 202% | 49% | **18** |
| fighter, same | 44,090 | 240% | 58% | **19** |

Sources (non-fighter, real-based chapters, mean a run): chapters 6,432 (43%), harvests 6,051 (41%), stop acts 1,793 (12%), errands 268, stop tiers 180, threads 122, cooking 82, passport 40. The fighter adds 3,950 from fights.

Gap to 85% for the non-fighter: about 760 XP. Raise the **chapters**, which are the only source the proposal sizes: 40% of 18,375 is 7,350 (M1-M4 and M6 about 1,225 each, M5 815, M7 410). Errands pay only 40-80 XP in band 1: doubling them adds about 270, which is too little to matter. Harvest XP depends on bed count (16 beds gives the same total because the run is longer), so it is not a lever for the target.

## 5. Q4: Bar pace

Visit-days to fill bars at a tier 0 stop, one visit a game day (`bar_pace.csv` has every stop and bar):

| Case | One bar, median (range of stop medians) | All three bars at a stop | All 54 Maplewold marks, 3-4 stops a day, perfect routing |
|---|---|---|---|
| 5 acts, top of the list | 7 (5-8) | 8 (7-8) | 41 (39-42) |
| 5 acts, best bar points | 6 (4-7) | 7 (6-7) | 35 (33-36) |
| 3 acts, top of the list | 12 (7-42) | 16.5 (10-42) | 91 (85-99) |
| 5 acts, no answer acts | 8.5 (5-61) | 13.5 (8-61) | not run |
| Maizehollow, 5 acts | 7 (6-9) | 8 (7-9) | 12 stops: 26 (25-28) |

By type, the slowest bar at 5 acts is Larder at the ferry, jetty, tower and spring (8 visit-days). Repairs at the workshop is fastest (5). Every stop type falls in 7-8 for all three bars. The 6-10 rule holds because the answer acts appear first in the offer, pay 12 × 1.5 + 2 = 20, and each one feeds an unfilled bar. In the full Maplewold runs the gnome tours for the chapters, not for marks, and has 16 of 54 marks (12-20) latched when the main line is done.

## 6. Q5: Maizehollow spot check (steady state)

| Lv | Stop acts (3-4 stops × 5 acts) | Garden, 36 beds (basket of CA crops to all avocado) | Petals a game day | XP a game day | Energy needed / held |
|---|---|---|---|---|---|
| 15 | 573 P, 256 XP | 592-829 P, 503-621 XP | 1,165-1,402 | 759-877 | 55 / 112 |
| 18 | 591 P, 261 XP | 592-829 P, 592-734 XP | 1,183-1,420 | 853-995 | 55 / 133 |
| 21 | 589 P, 259 XP | 592-829 P, 689-848 XP | 1,181-1,418 | 948-1,107 | 55 / 154 |
| 24 | 595 P, 261 XP | 592-829 P, 780-967 XP | 1,187-1,425 | 1,041-1,228 | 55 / 175 |

- Stops row, Maizehollow (N = 10, lit full at 6, two tier 2 stalls in C2 and C4): 6 × 200 + 5 × 300 (first adoption free) + 2 × 400 = **3,500 Petals**, plus 1,100 of stage Petals. That is 3-4 days of income, so Petals never hold anything back here.
- XP Lv 15 to 25 = 79,125. Chapters at 35% (C1-C4 and N1-N4) = 27,690. The remaining 51,430 at 760-1,230 a day is **42-68 game days** with both areas played side by side, in line with master's 39-65 to the band top.
- Bars: as in Q4, 8 visit-days a stop and 26 game days for the 12 stops.
- Not modelled here: Maizehollow Standing, chapter pacing, and Mistmoor.

## 7. What this model cannot say

- **Undefined counts:** the places row (which places count), the pages row (which pages count), and the garden "grown" row (taken as the 4 staples and 4 uncommons). The Standing slack depends on the first two (see Q2).
- **Not in the model:** geography (every walk between stops is 30 min, no route graph), weather, pests, the garden-level gate on beds, gathering success by tool, player-market prices for rope and beeswax, delve and lair fight outcomes (a fighter is assumed to win), threads being offered at every stop to a Regular (`any` threads exist, but how `stop_thread_offer` picks is not modelled), festival ×2 days, and the perks themselves (no mark gives a bonus in the sim).
- **Real behaviour:** no playtest data on income exists. `docs/playtest-data` holds fight playtests only. The activity split (3-4 stops, 5 acts, garden first, food eaten for energy) is a model choice, not a measurement.
- A "stall-day" is counted at the morning check, so the Petal-wait numbers are an upper bound.

## 8. Recommended number changes (not applied)

1. Master 2.1 and the bands doc: total XP at the band top is **18.4k / 97.5k / 283k / 619k / 1.15M** (Lv 15/25/35/45/55), not 75.7k / 626k / 2.5M / 7.0M / 16M.
2. Story-2 1.4: chapters pay **40%** of the band's real XP (Maplewold 7,350; M1-M4 and M6 about 1,225 each, M5 815, M7 410). With 35% of the doc's number they would push the gnome to Lv 18-19 by the Seal.
3. Standing: errands row = **3 errands**, and add one more main-line helper errand (M2 or M5). Or set the Seal at **78**. Either one gives a main-line-only non-fighter 2.2-2.5 points of slack instead of 0.2.
4. Petals in band 1: no change; the row is paid by day 26-28 with short waits. For bands 2-5, scale the Stops-row Petals with the stop level (pay rises 4x by band 2) if the row is meant to cost Petals there.
5. Bars: keep the four answer acts on "bar not full". The 6-10 visit-day pace depends on them and on 5 acts a visit.
