# Family: forest (2.7.01)
Built
- UI: `includes/trail_fam_forest.php` + CSS block "Forest family" at end of style.css. Dusk/night only ('' by dawn/day, '' for sections with no `forest-` mark). Lantern row: one per forest Sight, lit (🏮 + word "lit") = used this cooldown, unlit (🕯️) = ready. Relay Sights get a dashed border. CSS fireflies + chip ("Alder Thistledown at X: here now until 8 pm / tomorrow ...") from npc_cw_sight_lines. prefers-reduced-motion stops glow and fireflies. No JS.
- Game "Lantern Relay": 4 lantern-ish Sights (lantern-branch, glow-moss-grotto, woodcutter stump, mushroom ring) got `tally=lanterns-lit`, `c=5:1?tl=lanterns-lit:3/dp=dusk;night`, `title=Lantern Runner?tn=lanterns-lit:12`.
- Quest "Who Lit the Wood?" (`trail_sight_quests_fam_forest.txt`, giver Willa Marrowby): stair (plain), then 4 beats `npc=Alder Thistledown` at lantern branch (dusk), owl bough (night), glow-moss grotto (night), lantern branch again (dusk). He is 3 different Sights.
- Folk: `trail_sight_folk_fam_forest.txt`: Alder (free Storyteller, Windburrow, not a mentor) at grotto + bough, dp=night. Edited his lantern-branch row in trail_sight_folk_shared.txt: dropped `tl=wicks-trimmed:2` from `when` (moved onto the lantern item token) so he is a plain dusk appointment.
- Forecast: checked from 4 start days, all 3 Sights get a window within 14 days (he cycles 2 of his 3 rows a week). Dusk 6-8 pm, night 9-11 pm.
- Test: `tests/trail_fam_forest.php/.sh`.
Open
- Tally has NO daily reset and `cd` cannot reset it (cd only resets uses of a Sight). So "light 3 in one game day" is not enforced: the tally is lifetime, the bonus pays on every lantern use after the 3rd lit ever (dusk/night only). Needs an engine token (e.g. `tally=key@day`) to be a real daily relay. Each Sight's cd (5.5 days) already limits repeats.
- "Under 90 game min before the lamplighter passes" from the proposal not done (no timing token).
- The relay line on the strip says "lit this round" = used this cooldown.
- trail_sights.php's generic "quest runs to the end" fails today for other families' npc= quests (opening-day-parade, message-in-the-bottle: it runs with the clockwork off and their folk rows have conditions); mine passes.
- No art/new items needed.
