# Family: lair (2.7.01)
Built
- UI: `includes/trail_fam_lair.php` + CSS "Lair family" block. Shows when a mark slug starts `end-lair-`. Footprint tracker: tracks age = days since last full moon (0-5 fresh, 6-13 fading, 14+ old), prints + words; line per mouth (read / not read, track reading), true creature hint (same source as `hint=creature`), Long Looker tally, 2 villager chips. No JS.
- Game: 4 rows with `hint=creature` (1-desert, 1-island, 1-mountain, 2-mountain) are now `pick:3:` track reads with a lose line; right = hint, plus `xp=2:1?mo=full;waning-gibbous` (fresh tracks).
- Quest "Field Notes: Sideways Tracks" (`lair-field-notes`, `trail_sight_quests_fam_lair.txt`): giver Captain Bracken Spurwing (mentor, never a beat); beats: plain ridge, then npc= Basil Barleycorn, Gorse Oakenpot (dawn), Pip Pinchkin (dawn), Dozy Driftmoss.
- Test: `tests/trail_fam_lair.php/.sh`.
Open
- Pick labels are flavour; the engine fixes the right answer per gnome and day, not from the real creature. No "level +/- 2" guess (no token).
- Lumen Mothglow (folk row at 2-forest) has no clockwork window in the test world; not used.
- Folk row `end-lair-2-mountain` still puts Bracken at a Sight (shared file, mentor should not travel): consider removing it.
- Tracks' age is per game day, not per mouth.
