# Handoff: 2.4.90 to 2.4.93 (2026-11-03)

Branch `ccr-7fffb36a-izdaey`, merged to main. Slim zips in `releases/` (each needs 2.4.71+). Source of truth for what changed: CHANGELOG.md 2.4.90 to 2.4.93.

## How this was planned
Three passes (survey, proposals, final plan) produced `scratchpad` notes that are not in the repo. Final plan, tiers and decisions:
- **Tier 1 (2.4.90):** T1.1 bed curve (`bed_add_cost($plot, $n)`, 20% growth, 6x cap, per-bed pricing; full 144 beds about 31.6k Petals and 320 planks); T1.2 quiet weeks (fewer than `fair_min_entries` = 3 entrants: everyone gets 100 Petals + 10 XP, no ribbon; Guess the Weight jackpot cap 10,000, growth 500); T1.3 tour 100 XP, First Week XP 40/40/50/50/30/30/60; T1.4 streak copy; T1.5 First Week day 5 asks `talk2`.
- **Tier 2 (2.4.90):** T2.1 one Show page (Arrangements is its second class), 3-class Fair (Produce, Flowers, Preserves; old keys in `FAIR_CATS_OLD`, `upg249_faircats` merges this month's rows); T2.2 Tasks tabs Jobs / Journey / Requests, `JOB_PERIODS` 3/3/2.
- **Tier 3 cancelled:** Joshua plays the whole site; puzzles, Jigsaw, Puzzle Pals, Pal Jobs, Treks and delve v2 are live. Nothing frozen or cut.
- **Do not touch:** the games energy cap (removed on purpose in v1.6.2, `includes/upgrade140.php:27`).

## What else shipped
- 2.4.91: Potions box removed from My Gnome (potions are used from the Satchel); Petal icon (`ico-petal`); Petals once on desktop (hidden in the menu status line from 721px); Satchel tiles crisper; Journey tab rename; docs and help text fixed.
- 2.4.92: `gnome.php` is home: shared header, then TODAY (default) and MY GNOME tabs. Today rendering is in `includes/today_view.php`. `index.php` and `?today=1` redirect. Another gnome's view is `profile.php` (no tabs); `gnome.php?id=` redirects there. Menu has one "Home" entry. Tour step 7 ticks on MY GNOME only. New `tests/redirects.sh`.
- 2.4.93: Calling card shows "Not started: visit <Trainer> in <Region>"; free trip button (`do=trip` on `mentor.php`, `travel_blocked()`, fires no travel, arrive or walk event); home header wraps instead of overflowing; `explore_come_back()` sends the depth event.

## Gotchas
- Upgrade steps in `includes/upgrade249.php` run once `APP_VERSION` is bumped; they rewrite a setting only while it holds the old default.
- Event calling tasks count from the moment a chapter is taken; state tasks read the game as it is.
- `tests/beds.sh` has 5 older kitchen-pot failures. `tests/emoji_icons.php` has 1 older failure.
- craft.sh, polish_audit.js, MySQL and upgrade_check.sh were not run in the build container.

## Next
Phone check, then see the OPEN list in `claude/todo.md`.
