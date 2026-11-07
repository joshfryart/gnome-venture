# Prompt for another AI: hand-tune the 16 Maplewold route maps (bendy 30 x 18 design)

You are working in the repo `gnome-venture` (a cosy garden-and-adventure web game). Branch rule: develop on the branch the session gives you, commit, push; do not open a PR unless asked. This task changes **files under `claude/` only**. Do not touch `game/`, do not bump the version, do not bake pictures.

## Why
A route is a path between two places, played as tile **sections**. Today every section is a flat 22 x 7 strip that always runs left to right. The new design (plan: `claude/plan-route-map-bends.md`, read it first) makes sections **30 x 18 tiles**, with a road that **wanders** inside the section and enters and leaves on **any edge**, following the heading of the road on the region map. A generator already made a version of all 246 routes (`claude/bend-prototype/route-<id>.json`, deterministic, lint clean). Those are machine layouts. Your job: turn the **16 Maplewold routes** into hand-tuned maps that read like places, starting with **313** and **315**.

## What to read first (in this order)
1. `claude/plan-route-map-bends.md` (decisions: square tiles, 8 headings, wandering road, straight run <= 6 tiles with one up to 10 per section, thickets close in on bends; gates and mini-boss notes).
2. `tools/bend_rules.py` (the limits), `tools/lint_trail_bends.py` (the checks, top docstring lists every rule), `tools/gen_bendy_trail_proto.py` (how the generated maps are made).
3. `claude/maplewold-trail-maps/maplewold_trail_maps_22wide.json` (today's hand-drawn 22 x 7 maps: each section has a `feature`, a `caption` and a set piece), `claude/maplewold-trail-maps/maplewold_landmarks.json` (landmark names per section), `claude/route-list.md`.
4. Look at a few generated routes: `python3 tools/preview_bend_proto.py claude/bend-prototype/route-313.json` makes `route-313.png` (brown line = road, L = landmark, yellow = find, red = mini-boss or boss spot, blue = start, orange = exit).

## The 16 routes
Section headings and sides come from the region road and are already in the generated files; **keep each section's entry side, exit side, entry tile and exit tile** so joins stay valid unless you have a reason (then change both sides of the join). Columns: id, from to, land, sections, boss, generated headings, section features (from the old maps), landmark names per section (`maplewold_landmarks.json`, shown without the route prefix).

| id | route | land | sec | boss | headings | features | landmarks |
|---|---|---|---|---|---|---|---|
| 228 | The Maplewold Market to Poppyburrow | grassland | 3 | - | S,S,S | the scarecrow field, and the hay-bale maze / the stepping-stone ford, and the old mill pond / the lone apple tree, and the hedge-row lane | haybales,scarecrow | ford,pondmill | apple,hedgerow |
| 232 | The Maplewold Market to Honeybrook | grassland | 3 | - | E,E,E | the beehive meadow, and the berry patch / the hollow log bridge, and the old well / the clover crossroads, and the picnic rise | beehive,berrypatch | logbridge,well | crossroads,picnicrise |
| 236 | The Maplewold Market to Cloverholt | grassland | 3 | - | E,E,SE | the wildflower slope, and the dandelion drift / the little stone bridge, and the beanpole garden / the windmill, and the hay wagon | wildflowers,dandelions | stonebridge,beanpoles | windmill,haywagon |
| 304 | Poppyburrow to Acornby | forest | 2 | - | W,W | the oak-root arch, and the hollow trunk / the acorn drop, and the owl-hole oak | oakarch,hollowtrunk | acorndrop,owloak |
| 305 | Honeybrook to Birchhollow | forest | 2 | - | S,S | the white-bark tunnel, and the birch curtain / the fern hollow, and the sunbeam clearing | birchtunnel,birchcurtain | fernhollow,sunclearing |
| 306 | Cloverholt to Mossgate | forest | 2 | - | SW,SW | the mossy log, and the drip-stone grotto / the mossy gate, and the toadstool steps | mosslog,dripgrotto | mossgate,toadsteps |
| 307 | Poppyburrow to Shellhollow | coast | 2 | - | E,E | the long tideline, and the barnacle rocks / the shell hollow, and the sandcastle shallows | tideline,barnacles | shellhollow,sandcastle |
| 308 | Honeybrook to Pebblestead | coast | 2 | - | NW,NW | the pebble bar, and the kelp line / the rock pool, and the tide-pool steps | pebblebar,kelpline | rockpool,tidesteps |
| 309 | Cloverholt to Iciclecrest | tundra | 2 | - | E,E | the frozen pond, and the snowman gallery / the icicle cave mouth, and the aurora-glass ledge | frozenpond,snowmen | icecave,auroraledge |
| 310 | Poppyburrow to Snowcombe | tundra | 2 | - | NW,NW | the snowdrift pass, and the sled track / the snow-comb ridge, and the icicle curtain | driftpass,sledtrack | combridge,icicurtain |
| 311 | Honeybrook to The Sugar Shack | grassland | 2 | - | SW,SW | the maple tap row, and the bucket stacks / the Sugar Shack yard, and the pancake lane | taprow,bucketstacks | sugarshack,pancakelane |
| 312 | Cloverholt to Thousand Rings Stump | forest | 3 | - | W,W,W | the ring-count log, and the woodpecker tree / the toadstool ring, and the bramble corridor / the great stump, and the squirrel's larder | ringlog,woodpecker | toadring,bramble | greatstump,larder |
| 313 | Poppyburrow to Beaverdam Tunnels | forest | 3 | miniboss | SE,SE,SE | the beaver dam, and the mud slide / the beaver lodge, and the stick gate / the tunnel mouth, and the glow-cap tunnel | beaverdam,mudslide | lodge,stickgate | tunnelmouth,glowtunnel |
| 314 | Honeybrook to Lighthouse of the Lost Lantern | coast | 3 | - | NE,NE,NE | the driftwood beach, and the shell pile / the tidal causeway, and the stepping rocks / the lantern rocks, and the gull parliament | driftwood,shellpile | steppingrocks,causeway | lanternrocks,gullparliament |
| 315 | Cloverholt to Den of the Great White Owl | tundra | 5 | boss | E,E,E,E,E | the snowy gate, and the lamp-post lane / the pine slope, and the snow fort / the frozen stream, and the icicle bridge / the giant feather, and the feather cairns / the owl's den, and the owl's doorstep | gate,lamps | slope,fort | stream,bridge | feather,cairns | doormat,den |
| 316 | Poppyburrow to Aurora Camp | tundra | 2 | - | W,W | the sky-watch hill, and the star-chart stones / the aurora camp, and the kettle tree | skyhill,starstones | auroracamp,kettletree |

Routes 313 (mini-boss at the end, a delve) and 315 (boss at the end, a lair) end at special places. Do 313 first, then 315, then the rest in id order.

## Format
Work on **copies**, never on the generated files (re-running the generator overwrites them). Make the folder `claude/maplewold-bendy-maps/` and save each route as `route-<id>.json`, same shape as `claude/bend-prototype/route-<id>.json`:
- top level: `route_id, from, to, land, w (30), h (18), region, path_kind, boss, sections`.
- per section: `feature, caption` (keep or improve, one cosy sentence), `rows` (exactly 18 strings of exactly 30 characters), `tokens` (list of `[x, y, "F" or "E"]`), `landmarks` (list of `[x, y, name, 0]` with the names from `maplewold_landmarks.json`), `heading`, `entry` and `exit` (`{side, x, y}`), `line` (every tile of the road, in order, from the entry tile to the exit tile, 4-way steps, no gaps), `w`, `h`.
Tile characters: `#` thicket, rock or water you cannot cross; `.` floor; `,` rough floor (walkable, looks different); `S` start (first section only); `9` exit; `F` a find; `E` the mini-boss or boss spot.

## Rules (the lint enforces them: `python3 tools/lint_trail_bends.py claude/maplewold-bendy-maps/route-*.json`, it must print 0 problems for every file)
- The border is `#` except the entry tile and the exit tile (both on an edge, never a corner). Exactly one `9`, on the exit tile. `S` only on section 1.
- The exit tile of section N, moved across the join, is the entry tile of section N+1: same row for east/west joins, same column for north/south joins, opposite sides.
- Road line: floor, connected, no tile twice, no step straight back, **no straight run over 6 tiles** and at most one run up to 10 in a section.
- Landscape off the road: open meadow, rough ground and thickets in soft blobs (thicket 12 to 45% of the inside, some rough ground). **No shortcut:** the shortest walk from entry to exit must be at least 80% of the road line length and have no straight run over 10, so thickets or the set piece must make the bends worth following.
- 1 to 3 `F` per section, reachable, **off the road**, out in the landscape. `E` only on the last section of routes 313 and 315: exactly one, **on the road line, 4 steps before the exit**; none anywhere else.
- Landmarks: on plain floor, off the road, off `F` and `E`, x from 3 to 26, feet row (y) from 3 to 16, 2 to 5 tiles from the road, no two on one tile. A tall sprite hides the walker behind it, so keep it beside the road, not on it.
- Every floor tile must be reachable from the entry.

## What "hand-tuned" means (this is the real job)
For each section read its `feature` and `caption` and the landmark names, and **shape the terrain so the set piece is visible**: a ford is a gap of floor between two thicket banks; a bridge is a narrow floor strip over thicket; a hay-bale maze is a small maze of thicket blocks with the road running past it (the shortest walk must still be long enough); a beehive meadow is open ground; a tunnel (white-bark tunnel, glow-cap tunnel) is a long narrow corridor with the road inside it; a cave mouth is a gap in a thicket wall; a dam is a thicket bar with one gap. Use the land: grassland open with scattered hedges, forest tight with clearings, coast open beach with rock walls, tundra open snow with drifts and ice. Put each landmark where its sprite makes sense for the set piece. Friendly, nothing grim. Two routes must not look alike.

Keep the 8-heading rule: a section's road should still enter and leave on the sides it has now. Bends should be gentle S-curves and a few sharper turns, not a ruler line and not a zigzag.

## Optional, only after all 16 pass lint
Read items 11 and 12 of the plan (tool-quality gates and extra mini-boss spots for Maplewold). You may add a short **proposal** (not data) at the bottom of `claude/maplewold-bendy-maps/README.md`: which tiles on which sections could be gates (313 tunnel mouth, 315 icicle bridge and slope, 314 causeway) and where an extra mini-boss spot would sit. Do not add gate or extra mini-boss tiles to the JSON.

## How to work
1. `mkdir claude/maplewold-bendy-maps`; copy `route-313.json` from `claude/bend-prototype/` and edit it. Hand-editing 30 x 18 grids is easy to get wrong, so you may write a small Python helper in `tools/` that builds a section from a sketch (for example set the road corners, stamp a set piece, fill thickets) and recomputes `line` from the corners; keep it deterministic and commit it.
2. After every route: lint, then `python3 tools/preview_bend_proto.py <file>` and **look at the picture**. Fix what looks wrong before moving on.
3. Commit after each finished route (`Maplewold bendy map: route <id>`), push to your branch.
4. Finish with `claude/maplewold-bendy-maps/README.md`: what you did per route in one line, anything you changed on a join, anything you could not make fit, and the lint output (0 problems for 16 files).

## Do not
- Do not edit `game/`, `claude/bend-prototype/`, `claude/maplewold-trail-maps/`, the tools' rules (`tools/bend_rules.py`) or the lint to make a map pass. If a rule seems wrong for a route, say so in the README instead.
- Do not run `tools/bake_trail_art.py` or touch `game/includes/data/trail_maps.json`. The game cannot load 30 x 18 sections yet (its validator wants 22-wide rows and the `9` on the east edge); that is a later step in the plan.
- Do not invent new landmark names or new tile characters.

## Done when
`python3 tools/lint_trail_bends.py claude/maplewold-bendy-maps/route-*.json` prints `0 problems` for all 16 files, each route has a picture you looked at, and the README is written. Report: the 16 routes, what each set piece looks like on the map, and anything that needs Josh's decision.
