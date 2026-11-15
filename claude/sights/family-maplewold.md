# Maplewold family (2.7.01)

Built
- UI `game/includes/trail_fam_maplewold.php` (+ `.mwl*` block at the end of style.css). Shows when ctx['maplewold']. Felt strip: N/82 patches (trail_sight_first = first successful use), bar, patches of THIS stretch (lit = ready, words not colour), appointment chips from npc_cw_sight_lines + npc_cw_forecast ("Bramble at The dandelion clocks, Thu 7 am"), Pantry Round today, parade lanterns, folded 82-patch quilt. No JS.
- Pantry Round: `trail_sight_folk_fam_maplewold.txt`: 9 villagers, rows `gd=3:R` + `give=`; each game day (day mod 3) three want one thing; they stand at their Sight by their clockwork. Each has 2 rows in all (both show every week). Items come from Maplewold Sights; chances raised in trail_sights_maplewold.txt (flour@35, honey@45, egg@35, bean@45, blueberry@30, syrup@30).
- Quest "The Opening Day Parade": `trail_sight_quests_fam_maplewold.txt`, seq, gate quest:picnic-list, giver Clover. Dawn hedgerow (npc=Clover) > apple (day) > crossroads (day) > berry patch (dusk) > dandelion clocks (dusk, npc=Bramble). Bramble's dusk row is on 236-dandelions (her Picnic Rise row stays day-only), so the forecast is true.
- Test `tests/trail_fam_maplewold.php/.sh`.

Open
- Engine: npc_cw_forecast ignores a row's `when`, so for `gd=` rows it says "today" on a day they do not ask. The ledger works around it (Pantry block uses the row's gd; chips skip gd rows). A forecast that honours gd/dp of the row would be better.
- Engine: a villager with 3+ rows only shows 2 rows a week (rotation), so keep pantry villagers at 2 rows.
- tests/trail_sights.php generic quest runner cannot place npc= villagers: it fails every line with npc= beats (opening-day-parade, and other families' lines). It should set gv_cw_time from npc_cw_forecast for those beats.
- Pantry delivery has no running count (folk rows cannot `tally=`).
- Art: none needed (emoji only).
