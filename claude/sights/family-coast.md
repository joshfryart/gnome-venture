# Family: coast (2.7.01)
Built
- UI: `includes/trail_fam_coast.php` + CSS block "Coast family" at end of style.css. "Tide strip": shown when the section has a mark whose slug starts `coast-` (Maplewold routes with a coast mark too; any hour). Inline SVG arc (24 h, two highs H and two lows L, a notch for now) with title and aria-label, headline in words ("Low tide in 3 h", "Low tide now, turning in 2 h", state word shown too). Under it: the pool Sights (open / under water), the Tide Reader tally, up to 2 villager chips from npc_cw_sight_lines. No JS.
- Tide = pure function of the game clock (`trail_fam_coast_tide(hour, dayIndex)`): 12 h wave, highs 0:30/12:30, lows 6:30/18:30, shifted -1/0/+1 h by dayIndex mod 3. Low = within about 2 h of the low.
- Game "Tide Table": 4 pool Sights (kelp-line, tide-pool-steps, barnacle-wall, sandbar-causeway) got `when=dp=dawn,dusk` + `tally=tide-pools`, `item=sea-glass:1?tn=tide-pools:5`, `title=Tide Reader?tn=tide-pools:12`. APPROXIMATION: a `when` cannot say an hour, so "low tide" = dawn (5-7) and dusk (18-21), which is where the lows fall (+-1 h of shift). The strip's "open" label uses the row's own `when`, so it can disagree with the arc by up to an hour at the edges.
- Fisher bonus: `trail_sight_folk_fam_coast.txt`: Nettle Teaspoon (Angler) at steps dusk, Tuck Puddlefoot (Net-mender) at barnacle wall dawn, both `nocheck`.
- Edited rows in trail_sight_folk_shared.txt (coast Sights only): Rook Rushworth at the steps `dp=day` -> `dp=dawn,dusk` (pools shut by day); Alder Puddlefoot at the sea-stack gap `se=summer` -> `dp=dusk` (so he is there all year for the quest).
- Quest "The Message in the Bottle" (`trail_sight_quests_fam_coast.txt`, giver Keeper Loamwick, 5 beats seq): bottle post; rope-and-net rack (npc Sorrel Dewdrop); kelp line at dawn/dusk (low tide); sea-stack gap (npc Alder Puddlefoot); lighthouse shadow at dawn (npc Keeper Loamwick, new folk row `dp=dawn`, chance 100).
- Test: `tests/trail_fam_coast.php/.sh`.
Open
- "Bottle moves one Sight per game day" is story only (no per-day gate token). Order is fixed, not daily.
- Keeper Loamwick is a post villager (no clockwork): a miss at the finale just does not count (needs dawn); no "next at" text for him.
- Tide-pool Sight `coast-the-shell-heap` lives in base file trail_sights.txt (not my set), so it is NOT gated to low tide and has no tally. Lead may add `dp=dawn,dusk` + tally there.
- Tally is lifetime (see family-forest.md): the 5 and 12 milestones are one-time gifts.
- Art/new items: none (sea-glass exists).
