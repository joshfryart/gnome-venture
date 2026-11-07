# Route maps: edits needed to follow bends (draft 2026-11-07)

Mockups (private artifacts, built from the current data, nothing in the game changed):
- **Route Map Layout** https://claude.ai/artifact/3JMUQX1HxBPy9WgL4WgPPE : one region at a time. Region map with road bands, a route list, and a board that unrolls one route's sections either flat (as played now) or turned along a smooth curve. Red dashed band = extended area.
- **Master Route Map** https://claude.ai/artifact/CtLLV5P2pwhGqsi552Yha6 : all 14 regions on the world map (`map-world.png`, regions at their `REGION_MAP` positions, each region frame 480 x 270 drawn at 0.165 scale), all 246 routes in place along the region roads, with section pictures, red extended bands and grey stop placeholders. Drag to pan, scroll or pinch to zoom, "Go to" a region, layer toggles. Section pictures show from about 3x zoom, stops from 2x.

Goal: a route's map follows the road's heading and curves on the region map, at the larger size (about 30 x 18 tiles a section, up from 22 x 7).

Rule: the road must be bendy, not a straight line all the time. Even where the region road heads one way, the walkable path inside a section wiggles (gentle S-curves, small turns), so no route is a ruler-straight run edge to edge. Straight stretches are allowed, but only short ones.

## Today
- Every route section is a flat 22 x 7 strip (`game/includes/data/trail_maps.json`, ground pictures `game/assets/img/trail/ground/<route>-<section>.png`, 1408 x 488).
- A route always plays left to right, whatever way the road points on the region map (`region_layout.php`, 480 x 270 frame).
- Roads on the region map are polylines town -> stops -> exit. Side trails are straight two-point lines.

## What must change
1. **Each section needs a direction.** Store entry side and exit side per section (W/E/N/S or an angle bucket). Derive from the region road: the first section leaves the "from" stop the way the road does, the last one arrives at the "to" stop.
2. **Maps need bends, so the 22 x 7 strips cannot be reused as they are.** A route that heads north-east, or curves, needs a path that turns inside the section: the walkable road line has to enter on one edge and leave on another. Every existing section (665) has its road drawn from the west edge to the east edge, so each needs the road redrawn or re-generated. Generated maps (`tools/gen_trail_maps.py`) can do this. The 16 hand-drawn Maplewold maps (`claude/maplewold-trail-maps/`) need hand edits.
3. **Corner pieces. DROPPED (wandering road decided; bring back only if a turn proves too sharp for one section).** Where a route turns more than about 45 degrees inside one section, use a corner section (entry W, exit N, and so on) instead of bending the straight one.
4. **Matching ends.** Section N's exit tile row/column must equal section N+1's entry, and the first/last sections must meet the stop's own scene. Add a lint step (like `tools/lint_delve_floors.php`) that checks the join tiles line up.
5. **Landmarks and set pieces.** Objects (`objs`) sit at fixed tile positions; after the road moves they can land on the path or leave it. Re-place or re-check each.
6. **Ground pictures.** Baked pictures (`trail/ground`, `ART_LAND` stand-ins) are drawn for the current road shape. Re-bake after edits. Do not rebuild under the same version (release rule).
7. **Camera.** The 7 x 7 view must scroll vertically as well as along the route. The 2.6.05 clamp (`tm_window_clamped`) needs a vertical test.
8. **Side trails and branches.** Stop-to-place trails are straight lines in the layout; give each a heading rule (bow left or right) so its first section turns the right way.
9. **Region map art.** If roads on the region map picture change, the layout data and the pictures (`map-<CODE>.png`) must stay in sync (`tools/map_layout.php`).

10. **Wiggle rule.** Generator adds seeded gentle wander to the path in every section (cap on straight run length, e.g. no more than about 8 tiles in a row without a turn; exact cap to pick). Wander must keep entry and exit tiles fixed so joins (item 4) still match. Lint flags any section whose path is too straight.

11. **Gated areas (to consider).** Some areas can only be passed with a tool of a given quality (e.g. a better axe to clear a thicket, a rope for a ravine). Questions for the layout:
    - Where does a gate sit: on a section tile, at a section join, or on a side trail only?
    - Gate placement must not break the main road. Keep an open route between every stop pair, with the gated path as a shortcut or a side branch, unless the gate is a deliberate lock.
    - Store per gate: tile(s), tool kind, minimum quality. Lint checks that the tile sits on the path and that a bypass exists where needed.
    - Bendy road (item 10) and gate tiles must agree: wander must not move the gate off the path.
    - Show it on the maps: a mark on the route map and on the master map mockup.
    - No existing tool-quality field found in `game/`, `tools/`, `claude/`; data model and item system need checking first.

12. **Mini-bosses and bosses (to consider).** Engine rule today: a delve route's last section may hold a fixed `E` mini-boss (large creature); a lair route's last section holds a boss; other routes roll normal encounters. Bends must keep the `E` tile on the path and in the last section.
    - Maplewold set already: 313 Beaverdam Tunnels (delve, forest, medium) mini-boss, large forest creature level about 20 to 23 (Moss Golem, Wild Boar, Tufted Lynx); 315 Den of the Great White Owl (lair, tundra, hard) boss Snow Owl Monarch level 30.
    - Optional new mini-boss spots (new data needed): 312 great stump, Bramble Wolf (22); 314 lantern rocks, Clam Lurker (23) or Tide Crab Knight (19); 310 snowdrift pass, Grumpy Wolverine (21); 309 icicle cave mouth, Arctic Fox (17).
    - Keep free of fights: starter routes 228, 232, 236; havens Sugar Shack (311) and Aurora Camp (316).
    - Other region bosses by landscape if lairs are added: forest Old Bramblehorn 30, coast Reef Leviathan 29, grassland Great Hawk 28.
    - Pair with gates (item 11): 315 gates (rope, then pick) lead to the boss; 313 lantern-gated tunnel mouth holds its mini-boss.

## Open choices
- DECIDED: wandering road. Sections are bigger (about 30 x 18) and the road wanders inside them, entering and leaving on any edge. Corner sections (item 3) are dropped unless a turn proves too sharp for one section.
- DECIDED: square tiles stay. Hexagons were considered and deferred (would redo all 665 sections, art, camera, lint, and break joins with delve, lair and town maps). The hex feel can come from the wiggle rule or ground-art texture. A hex trial could be its own later project (pointy-top, one route first).
- DECIDED: fixed headings, 8 compass directions (fits W/E/N/S entry and exit sides; region road angle snaps to nearest of 8).
- DECIDED: straight-run cap 6 tiles; one longer run up to 10 allowed per section. Lint flags a run over 6, or more than one run over 6.
- Hand-edit Maplewold first (16 routes), generator for the other 230.

## Order and todo (updated 2026-11-07)
Decided: square tiles, 8 headings, wandering road in 30 x 18 sections, straight run <= 6 (one up to 10), thickets close in on bends. Master TODO: `claude/todo.md` section 4, "Route map bends".
DONE
- Prototype generator, lint, preview, shared rules: `tools/gen_bendy_trail_proto.py`, `tools/lint_trail_bends.py`, `tools/bend_rules.py`, `tools/preview_bend_proto.py`.
- All 246 routes (665 sections) generated and linted in `claude/bend-prototype/` (PR #6, merged).
- Both mockup pages rebuilt for the new design (`tools/route_map_mockup/build.py`).
OPEN, in order
1. Josh reviews the sample routes and the two mockups; tune look (thicket density, open meadow vs groves, section sizes).
2. Engine: accept 30 x 18 sections with S and 9 on any edge (`trail_authored_valid`, `trail_tiles.php`, `trail_art.php`); vertical camera clamp (`tm_window_clamped`); tests.
3. Bake: `tools/bake_trail_art.py` for 30 x 18 and any-edge entry and exit; new ground pictures under a NEW version (release rule); delete `obj/lm-*.png` before re-baking sprites.
4. Merge the prototype into `tools/gen_trail_maps.py` (shared SETS, captions, `--all`); wire `tools/lint_trail_bends.py` into the tests.
5. Hand-tune the 16 Maplewold routes (first 313 and 315); landmark names and sprites for the new rows.
6. Data for gates (tool kind and minimum quality) and the extra mini-boss spots (item 11 and 12); check the item system first.
7. Side trail heading rule in the layout data (item 8); region map art stays in sync (item 9).
8. Phone check.
Open choices still: how a vertical section is paced (N and S sections are 18 tall, E and W are 30 wide; a tall 18 x 30 section is an option); diagonal exits alternate sides today.

## Master map: what it shows and how it is built
- Data: `tools/map_layout.php` (region layouts: roads, stops, exits) + `game/includes/data/trail_maps.json` (routes, sections) + ground pictures. Routes are matched to regions by their stop pairs, because village names repeat across regions (Maplewold comes out at 22 routes).
- A route's curve is a Catmull-Rom through its road's own points, so it leaves a stop the way the road arrives. Side trails (stop to place) bow to one side. These are the paths a bend edit has to match.
- Each section is drawn as a 22 x 7 picture (today's size, upright) inside a red band of about 30 x 18 (proposed size). Sections sit in a bent band, so a sharp bend leaves a small wedge gap beside the rectangle.
- Findings from it: near hubs (Maplewold Market, Poppyburrow, Honeybrook, Cloverholt) many routes leave in a fan and their extended bands overlap, so extended maps need room or a rule for crossing. Route lengths on the region frame are short (about 30 to 60 units), so sections need the region frame scaled up or the extra size treated as its own space.
- Rebuild: `tools/route_map_mockup/gen.py` (reads the layout dump and route data, writes `data.json`), templates `route_board.tpl.html` and `master.tpl.html` (replace `__DATA__`). Scripts expect `layout.json` from `php tools/map_layout.php` and Pillow; paths inside are the session scratchpad and need changing.
- Not in the mockup: delve and lair maps, treks, town maps, cross-region road continuity beyond the exit edge.

## Prototype status (2026-11-07)
- `tools/gen_bendy_trail_proto.py` + `tools/bend_rules.py` + `tools/lint_trail_bends.py` + `tools/preview_bend_proto.py` make and check bendy 30 x 18 sections. Square tiles, 8 headings, wandering road, runs <= 6 (one up to 10), thickets close in on bends. Game data untouched.
- All 246 routes (665 sections) generated into `claude/bend-prototype/route-<id>.json/.txt`; lint passes on all. Road source: 57 real roads, 170 side trails, 19 cross-border (stop to region exit).
- Not done (also in the todo above): engine (validator wants `9` on the east edge, 22-wide rows, S on the west edge), ground-picture bake at 30 x 18, tool gates and extra mini-boss spots in the data, sprite art for the many landmark names, hand-tuning of Maplewold.
