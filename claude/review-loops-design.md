# Loop review (design pass, 2026-11-02)

Data caveat: 6 signups, one player makes 99.95% of XP. Treat the CSV as "no one else is reaching the helper cards", not as balance truth. All fixes below are tweaks: numbers, rules, order. Paths are under `game/`.

## Core diagnosis
The first session works (5 of 6 finish the tour). Nothing after it gives a new player a reason to come back tomorrow, and the two helper cards meant to do that were never used. The loops are well built but not joined: the garden makes things that wait, but nothing waiting is surfaced as "come back at X".

## Ranked findings

**1. First Week stalls on social tasks a solo newcomer cannot finish.**
Problem: Today shows only the first unclaimed card. Day 5 needs a friend request plus a guestbook stamp; day 6 needs the Hollow jar plus a contest. With ~0 friends online these block the card, and every later card behind them.
Evidence: `includes/first_week.php:34-35,38`; `first_week_today_card` (:171) returns first unclaimed; `claims` = 0.
Tweak: make each day's second task optional, so the card is "done" at 1 of 2 (reward unchanged). Swap day 5 "pal" for "visit any garden" and day 6 "contest" for "enter the Village Show or cook one dish".
Effort S. Risk: low, old claims untouched.

**2. The Today card never ticks itself.**
Problem: `daily_ticks` is written only by the "Enough for today" button. Doing the suggested thing does nothing, so the card reads as chore text and the button as dismissal. Zero rows means nobody pressed it.
Evidence: `includes/welcome_back.php:121`, `daily.php:9`; only caller.
Tweak: in `daily_card()` treat the pick's own condition as done (talk: `last_talk = today`; stamp: `garden_stamps` today; job: active daily exists) and show the closer. Keep the button.
Effort S. Risk: low.

**3. Day 1 return reason is missing: no "your crop is ready at HH:MM".**
Problem: D1 20%. At L1 max energy is 10 (about 3 squares), the radish takes 15 min, and the tour ends with an energy explainer, not a promise. Nothing says when to come back.
Evidence: `includes/gnome.php:199`, `includes/tour.php:112,119`; the Today garden card shows counts only (`index.php:104-110`).
Tweak: on Today, when nothing is ready, show "Next harvest in 2h 10m" (min of tile ready times) and "Energy full at 7:40 pm". Add it to the tour-end prize lines. No push, so this is the only hook.
Effort S. Risk: low.

**4. No-stakes loop: nothing is lost, so nothing is urgent.**
Problem: crops pause when thirsty and never wilt; water lasts 6 to 24 hours; missed days cost nothing. Principles forbid punishment, but pure no-stakes removes the pull to open the game.
Evidence: `includes/garden_logic.php:702-767` (no death), no-till 14-day loss (:129-217) is invisible to newcomers.
Tweak, positive only: a "ripe bonus" that lapses softly. Crops harvested within 24h of ripe give full yield; after that, yield eases to 90% (never lower, no death). Show "ripe 3h" chips. Or give a small +1 Soil Care star for any day with a watered bed.
Effort M. Risk: medium, touches yields; keep the floor at 90%.

**5. XP cliff L15 to L28: cost per level grows 3.6x, action XP grows 1.9x.**
Problem: L16 costs 5,400 XP, L28 costs 19,440. Action XP scale is `1+0.05*over` (L28 = 1.9x). Net grind per level roughly doubles, while +5 energy per level is the same, so the late game slows with no new unlock until L25 and L28.
Evidence: `includes/gnome.php:215-221` (steep 20%), `includes/progression.php:148-153` (scale 5%), `includes/functions.php:519-522`.
Tweak: `xp_action_scale_percent` 5 to 9 (L28 = 2.6x) and `xp_steep_percent` 20 to 15. Add a minor unlock at L20 (e.g. calling II bonus perk or a free bed pair) to break L15 to L25.
Effort S. Risk: medium, retunes XP for the one active player; settings only, easy revert.

**6. Fights are 22% of XP, yet farming is the identity.**
Problem: fight XP is a flat creature value, not tied to energy spent, and it scales with level through the same action multiplier. Winning at the same stop repeats for XP with no per-day cap, unlike rest stops (soft cap at 100 things).
Evidence: `includes/adventure.php:773-782` (`add_action_xp` Fighting), outlevel cut only at `adventure.php:35-40`.
Tweak: apply the outlevel curve harder (`outlevel_step_percent` up, grace 3 to 2) and halve Fighting XP past the first 20 wins a day (reuse the "tired" rule from `includes/local.php:443`).
Effort S. Risk: low to medium, may feel nerfed to the one player; talk about it in the changelog.

**7. Explore payout is once per stop per day, but step energy rewards walking far, not the garden link.**
Problem: leaving the road costs 1 and each step 1, return is free, so the cheapest XP/Petals is a short walk from a rest stop; the payout `10*(depth-4)` is trivial compared to a 3-energy treasure harvest. Delve chests (`20+5L`) beat both.
Evidence: facts section 6 and 9; `includes/explore.php` payout.
Tweak: pay explore return in an ingredient or seed (feeds the garden and cooking) instead of Petals, once per stop per day. Same cap, same energy.
Effort S. Risk: low.

**8. Pal Jobs (L10) spend no energy and give delve coins 0.6x; pal crafts do not count for Job Board or calling quests.**
Problem: free output makes pals strictly better than the player once unlocked, and the known bug (`todo.md:35`) means passive work never feeds the active loops.
Evidence: `todo.md:35`, facts section 10.
Tweak: count pal crafts for jobs and callings (fix the known bug), and cap Pal Jobs at 6 runs but pay half XP past 3.
Effort M. Risk: medium; check job_event hooks (`includes/jobs.php`).

**9. Petals have no sink between L5 and L15, and a strong sink wall after.**
Problem: faucets are shop sales (60%), dailies and weekly/monthly jobs; sinks are +4 beds (200 and rising 50%) and hired help. A newcomer hits the first sink quickly, then has little to buy until land deeds (5,000).
Evidence: `includes/functions.php:323-325`, facts section 7.
Tweak: keep the bed price, but add a cheap L5 to L12 step: a second garden-tool tier or a seed packet vendor at 100 to 400 Petals; or lower `bed_add_growth_pct` 50 to 35.
Effort S. Risk: low.

**10. Helper cards compete for one slot; welcome-back wins and hides First Week.**
Problem: `back > fw > daily > fest` shows one card. A returning newcomer sees only "Welcome back", then the next load shows First Week; a player with a festival never sees it until the other cards are done.
Evidence: `includes/tour.php:80-93` (`helper_slot`).
Tweak: show First Week and the daily card together (small second line) while the week is unlocked; leave welcome-back first. Show "Day N of 7" progress dots on Today.
Effort S. Risk: low; one extra row on a phone, fold it into the garden card.

## Quick order
Ship 1, 2, 3, 10 together (retention, all S). Then 5 and 9 (settings). Then 6 and 7. Leave 4 and 8 for a considered release.

## Not changed
Energy regen, mulch/no-till rules and rest-stop caps look sound. Social loops (orders, favours, stalls, trades) show 0 rows only because the sample is tiny; do not tune them yet.
