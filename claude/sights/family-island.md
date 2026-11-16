# Family: island (2.7.01)
Built
- UI: `includes/trail_fam_island.php` + CSS block "Island family" (style.css). "Ferry strip": shown when a mark slug starts `island-`. Inline SVG lane (24 h, two dock windows, boat dot for now, title + aria-label), words ("Ferry at the dock, leaves in 2 h" / "Ferry away, back in 6 h"), palms open / no boat, crossings tally, up to 2 villager chips. No JS.
- Ferry = pure function of the clock `trail_fam_island_ferry(hour, dayIndex)`: 12 h rhythm, docks 6:00 and 18:00 for 2 h, away between. Day index unused (same every day).
- Game "Ferry Timetable": hammock palms row `when` = `dp=dawn,dusk` (APPROXIMATION of the two docked windows; dawn is 5-7, dusk 18-21, so row and strip can differ by an hour at the edges), `tally=crossings`, `item=cowrie-shell:1?tn=crossings:5`, `title=Ferry Regular?tn=crossings:12`. Pinchwell's shared folk row changed `dp=day` -> `dp=dawn,dusk` (he is only there when the boat is).
- Quest "Pinchwell's Postcards" (`trail_sight_quests_fam_island.txt`, 5 beats seq): sand spit (npc Tansy Thistledown, dawn), tide cave (npc Willa Thistledown, dawn), shell-bell tree (dusk), lagoon edge (npc Fennel Mossgrove, dawn), finale hammock palms on `gd=7:0` at a crossing. Folk rows in `trail_sight_folk_fam_island.txt`.
- Test: `tests/trail_fam_island.php/.sh`.
Open
- "Right crossing" is dawn-or-dusk (both open the palms); no per-day alternation (a `when` cannot OR across keys).
- The ferry strip ignores the moon; the tide cave could use `ti=` / `mo=` later. Postcard order per beat is by the seq line, not carried items.
- Lyra Fiddlewing and Wren Thimblewick are not free villagers (no clockwork), so no npc= beat for them.
- Tally is lifetime; the 5 and 12 gifts are one-time.
