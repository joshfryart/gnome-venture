# Art wanted for the variety project (2.0.76 on)

Rule: every placeholder is a white square with a red border and the words THIS IS PLACEHOLDER (`tools/gen_placeholder_art.py`). To finish one: draw the real art, save it over the same file name and size, tick the box. Placeholders must never ship as final.

## In the game now as PLACEHOLDER (2.0.76)
Build-stage verb icons, shown at 20px on the repair card (stage list + button). 96x96 placeholders; draw as normal `ico` art (64 grid, house outline/halo rules in `claude/art-style-guide.md`), light and dark if the style needs it.
- [ ] `game/assets/img/steps/stage-haul.png`: hauling building materials (a sack, a block, a plank bundle)
- [ ] `game/assets/img/steps/stage-gather.png`: gathering finds (a basket with shells, ferns, roots)
- [ ] `game/assets/img/steps/stage-feed.png`: feed the crew (a steaming pot or a bowl)
- [ ] `game/assets/img/steps/stage-light.png`: lighting the place (a lantern or a candle)
- [ ] `game/assets/img/steps/stage-clear.png`: clearing (an axe or a spade, or a broom)

## In the game as PLACEHOLDER (2.0.77)
Themed stop upgrade pictures, 96x96 placeholders at `game/assets/img/stoptiers/<kind>-<tier>.png`, shown at 24px beside each upgrade on the adopt panel and the plaque. 12 kinds x 4 tiers. Draw as small `ico`-style art, one per upgrade (name in brackets); replace the file, tick the box.
- [ ] market: 1 striped awning, 2 weighing house, 3 fountain square, 4 market hall
- [ ] mill: 1 sack hoist, 2 mill sluice, 3 flour loft, 4 bakehouse hall
- [ ] inn: 1 hearth bench, 2 stable yard, 3 singing room, 4 grand dining hall
- [ ] shrine: 1 stone lantern path, 2 prayer bell, 3 wishing pool, 4 pilgrims' hall
- [ ] jetty: 1 plank pier, 2 net racks, 3 smokehouse, 4 fish supper hall
- [ ] herb: 1 drying rack, 2 seed shed, 3 hive row, 4 tea house
- [ ] workshop: 1 workbench, 2 forge corner, 3 crane and pulley, 4 makers' hall
- [ ] orchard: 1 picking ladders, 2 cider press, 3 grafting bench, 4 harvest barn
- [ ] ferry: 1 landing steps, 2 toll house, 3 second boat, 4 boatmen's hall
- [ ] tower: 1 sturdy ladder, 2 signal beacon, 3 map room, 4 watchers' hall
- [ ] spring: 1 stone steps and rail, 2 changing house, 3 egg-boiling stones, 4 bathhouse hall
- [ ] camp: 1 log seats, 2 cookfire ring, 3 storytelling stage, 4 great lodge
(The files are named by kind and tier, e.g. `mill-1.png`. Not wired yet, nice to have: a stop header picture that changes as tiers are built.)

## Wanted soon (not made yet: add a placeholder when the verb ships)
Build-stage verbs still to come (one icon each, same folder, `stage-<verb>.png`): carry (a parcel with a road), befriend (two gnomes shaking hands), trial (a small trophy or a target), vigil (a moon and a lantern), wait (an hourglass), decorate (a flag or a flower pot), craft_on_site (a hammer on an anvil), fetch_lore (a scroll).

## Nice to have (larger pieces, ask Joshua)
- [ ] Before/after pictures for the nine pilot places: Market of a Thousand Chilies, The Stepped Seed Temple, Cenote of Echoes, Jaguar Root Caves, Driftwood Tavern, Sunken Gnome Galleon, The Singing Waterfall, Mangrove Root Maze, Turtle Nesting Beach (ruined / mended, to sit on the repair card). Not wired yet.
- [ ] A small "progress" picture for a clear stage (cleared in stages: 1/3, 2/3, 3/3).
- [ ] Road Journal page art (14 regions) for release 2.0.79.
- [ ] New stop act kinds and road card kinds each get one small icon (2.0.78 / 2.0.79).
