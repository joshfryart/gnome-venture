# Gourmand: decisions from Josh (override proposal-gourmand.md where they differ)
1. Keep Pomeroy Crumbworth, dormouse, with the `round-door` call-back.
2. Calendar split: feasts and events happen at ONE fixed location (the camp / Long Table / festival spot). The QUEST LINE is NOT tied to a visit window: he is accessible at all times in every region (no 2-day window gating the questline). Festival days stay as event bonuses only.
3. (not answered) default: camp at a town spot per region for feasts/events.
4. Reach: anywhere in the region.
5. Yes: add `cook_pots.score` (dish quality).
6. Rewards: ACCEPT claude/review-gourmand-rewards.md: keep 14 treasure seeds and Golden at 1 seed; NO Petal doubling on festival day; festival day doubles friendship with Pomeroy (+5 -> +10) and optionally tip XP (8 -> 16); tip stays 25 Petals.
7. Finale plays at the next meeting (not a dated Long Table).
8. Art: OK (placeholders first, cost estimate before art at scale).
9. CUT the Long Table board entirely (supersedes 'public names'). The day-1 Long Table event itself may stay as a simple late-plate serve with no board.
10. Wayside Bite (stop-hopping): DROP.
11. Version numbering: hold off, do not bump or name a version yet.
12. YES: fix give_item so bought/traded goods cannot inherit harvest quality (item_quality.n must shrink), so the 'plain quality' guard really works. Needs its own test.
13. YES: adopt the integration review's simplifications (claude/review-gourmand.md): npcs.active kept in step with the setting, traveller_deals as once-per-tour claim (no gourmand_plates), drop gourmand_teach / Almanac chapter / Wayside Bite / board, 2 settings, second-spoon via existing decor list, score>0 guard on cook_pots.score.

14. Plan items (final): festival friendship bonus does NOT require being at the camp; tip XP doubles on festival day (8 -> 16); Long Table is seat-only (no board); proportional give_item fix OK; second-spoon via the non-tradable reward-decor pattern (festival.php:40-46), overriding 13's wording; add a How-to page; jar bar stays 62 (hummus-jar, pickled-okra stay hard); version numbering on hold.
15. P1/P2 follow-ups ACCEPTED as built: Home Plate reward 200 Petals + 40 XP + 10 friendship; Grand pays only grandpay; How-to stays a tab on gourmand.php; golden-table 690 Petal spike OK; dish scoring runs for everyone even while the feature is off; CHANGELOG/news wait until a version is named. P3 approved.
16. Quick-jar bars: jars whose recipe `cook_minutes` <= 1440 (plum, raspberry, lingonberry and guava jam, passion-fruit curd) use spoon bars 42/49/55; longer jars keep 45/52/62. `pantry_quality` is untouched (the Fair and prices use it). hummus-jar and pickled-okra stay hard by design at exactly 62.
