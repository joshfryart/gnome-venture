# Family: grassland (2.7.01)
Built
- UI: `includes/trail_fam_grassland.php` + CSS block "Grassland family" (prefix tfg) at end of style.css. "Kite sky strip" for sections with a `grassland-` mark: inline SVG (kite higher in harder wind, arrow pointing where it blows, N mark, text alt), headline in words ("Kite day: the wind is up", weather word, mph, direction). Speed/direction = pure function of true weather (ctx now we) + game day/hour (hollow_unit); wind 22-38 mph, storm = too wild. Lists the 3 kite Sights (pays more today / its usual), Kite String tally, the five Sky Letters (weather icon + word, found/waiting, "today's weather has a letter at X"), Mabel chip from npc_cw_sight_lines. No JS.
- Game "Kite & Wind": data only. Meadow (`xp`, `c=6`, storm-feather 20->40%, sense buff on we=wind), dandelion drift (extra seed on wind), windmill (flour 30->60% and xp on wind). `trail_sights_shared.txt`, my 3 rows only. Folk rows (`trail_sight_folk_fam_grassland.txt`): Mabel Pennywhistle@v-na-1-2 at meadow (we=wind/dp=day, flies a kite, buff), daisy ring and footbridge (dp=day; these make her clockwork appointments).
- Quest "Mabel's Sky Letters" (`trail_sight_quests_fam_grassland.txt`, order any): sun at picnic knoll, cloud at daisy ring (npc Mabel), wind at meadow, rain at footbridge (npc Mabel), fog at shepherd's wall. Beat `when` = `we=`; a wrong weather counts nothing, no penalty. Forecast checked from 4 start days, Mabel gets windows at both Sights.
- Test: `tests/trail_fam_grassland.php/.sh`.
Open
- "Pick wind right for a bonus" not done: a `pick:` check would make wrong picks fail the Sight; wind pay is by `we=wind` instead.
- Mabel's clockwork picks her Sights by schedule only (weather not foretold), so a letter needing her AND its weather can take weeks (wind 5-12%, fog 3-10% by season; rain/cloud common). That is the intended long line.
- Mabel has 2 Maplewold beehive rows too, so she cycles 5 rows: each Sight comes up every ~2 weeks (forecast looks 28 days ahead).
- Base-file rows (clover patch, milestone) are not mine; no art/new items.
- Moon: not used for grassland.
