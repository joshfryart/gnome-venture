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
3. **Corner pieces.** Where a route turns more than about 45 degrees inside one section, use a corner section (entry W, exit N, and so on) instead of bending the straight one.
4. **Matching ends.** Section N's exit tile row/column must equal section N+1's entry, and the first/last sections must meet the stop's own scene. Add a lint step (like `tools/lint_delve_floors.php`) that checks the join tiles line up.
5. **Landmarks and set pieces.** Objects (`objs`) sit at fixed tile positions; after the road moves they can land on the path or leave it. Re-place or re-check each.
6. **Ground pictures.** Baked pictures (`trail/ground`, `ART_LAND` stand-ins) are drawn for the current road shape. Re-bake after edits. Do not rebuild under the same version (release rule).
7. **Camera.** The 7 x 7 view must scroll vertically as well as along the route. The 2.6.05 clamp (`tm_window_clamped`) needs a vertical test.
8. **Side trails and branches.** Stop-to-place trails are straight lines in the layout; give each a heading rule (bow left or right) so its first section turns the right way.
9. **Region map art.** If roads on the region map picture change, the layout data and the pictures (`map-<CODE>.png`) must stay in sync (`tools/map_layout.php`).

10. **Wiggle rule.** Generator adds seeded gentle wander to the path in every section (cap on straight run length, e.g. no more than about 8 tiles in a row without a turn; exact cap to pick). Wander must keep entry and exit tiles fixed so joins (item 4) still match. Lint flags any section whose path is too straight.

## Open choices
- Bend by drawing corner sections, or by making sections bigger and letting the road wander inside them.
- Fixed headings (8 compass directions) or free angles.
- Hand-edit Maplewold first (16 routes), generator for the other 230.

## Order
1. Pick the shape rule (corners or wandering road).
2. Update the generator and lint; try on one Maplewold route.
3. Hand-edit the other Maplewold routes.
4. Regenerate the other regions, one ring at a time.
5. Re-bake ground pictures, re-place landmarks, phone check.

## Master map: what it shows and how it is built
- Data: `tools/map_layout.php` (region layouts: roads, stops, exits) + `game/includes/data/trail_maps.json` (routes, sections) + ground pictures. Routes are matched to regions by their stop pairs, because village names repeat across regions (Maplewold comes out at 22 routes).
- A route's curve is a Catmull-Rom through its road's own points, so it leaves a stop the way the road arrives. Side trails (stop to place) bow to one side. These are the paths a bend edit has to match.
- Each section is drawn as a 22 x 7 picture (today's size, upright) inside a red band of about 30 x 18 (proposed size). Sections sit in a bent band, so a sharp bend leaves a small wedge gap beside the rectangle.
- Findings from it: near hubs (Maplewold Market, Poppyburrow, Honeybrook, Cloverholt) many routes leave in a fan and their extended bands overlap, so extended maps need room or a rule for crossing. Route lengths on the region frame are short (about 30 to 60 units), so sections need the region frame scaled up or the extra size treated as its own space.
- Rebuild: `tools/route_map_mockup/gen.py` (reads the layout dump and route data, writes `data.json`), templates `route_board.tpl.html` and `master.tpl.html` (replace `__DATA__`). Scripts expect `layout.json` from `php tools/map_layout.php` and Pillow; paths inside are the session scratchpad and need changing.
- Not in the mockup: delve and lair maps, treks, town maps, cross-region road continuity beyond the exit edge.
