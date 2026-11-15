# Family: tundra (2.7.01)
Built
- UI: `includes/trail_fam_tundra.php` + CSS "Tundra family" block. "Aurora overlay": shown when a mark slug starts `tundra-`. Winter night = 3 CSS drifting ribbons (no JS, reduced-motion safe), brightness 1-4 from the moon (new moon brightest, full faintest; words "Aurora blazing/bright/soft/faint"). Day / out of winter: says it is asleep or winter-only. Moon icon + day of 28 shown. Under it: 3 warm huts, warmth chain lamps (hut-warmth tally), up to 2 Ferrin/villager chips.
- Game "Warm Hut Relay": huts = snow-fort, lone-fir, star-chart-stones got `tally=hut-warmth,buff=hardiness:1:90,title=Warm Hand?tn=hut-warmth:3`. Aurora rise got a bonus ribbon `?se=winter/dp=night/mo=new;waxing-crescent;waning-crescent`.
- Quest "Ferrin's Long Night" (`trail_sight_quests_fam_tundra.txt`): fort (npc Ferrin, snow), fir (snow), stream (npc Ferrin, snow), star stones (winter night), aurora rise (npc Ferrin, `se=winter/dp=night`). Folk rows in `trail_sight_folk_fam_tundra.txt`.
- Test: `tests/trail_fam_tundra.php/.sh`.
Open
- Tally is lifetime: "chain 3 huts without freezing" is a count of 3 huts ever (title once), not a timed chain; no freeze penalty. Needs an engine token for a window.
- Warmth is `buff=hardiness` (no "warmth" buff kind exists). No frost-on-tiles art (UI only the strip).
- Finale `we=sun,cloud` from the proposal not used (brief says se/dp only). Stones also host Wren's Star-Wheel quest at night.
- `trail_sights_lint` fails on `haven-guestbook` (not mine).
