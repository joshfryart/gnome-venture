# Maplewold bendy maps (16 routes, 30 x 18)

Made by `tools/build_maplewold_bendy.py` from sketches in `tools/maplewold_bendy_specs.py` (deterministic; run `python3 tools/build_maplewold_bendy.py <id> ...`).
Each sketch gives the road as turns, stamps for the set piece, find hints and landmark hints. The builder fills the rest of the landscape (noise blobs per land), cuts the road,
closes shortcuts, drops unreachable floor, snaps finds and landmarks, and writes `route-<id>.json` + (via `tools/preview_bend_proto.py`) `route-<id>.png`.
Route data, captions, landmark names, entry/exit tiles and sides come from `claude/bend-prototype/`. **No join was changed.** Roads were re-drawn by hand (not the generated ones).

## Per route
| id | set pieces on the map |
|---|---|
| 228 | hay-bale maze of 3 x 2 thicket blocks beside the road, scarecrow field on a rough rise; ford = 5-tile rough gap between two thicket banks, pond with mill; apple tree among hedge lines, two hedge-row lanes with gaps |
| 232 | open beehive meadow with flower patches, berry bushes in a grid; stream with a 2-tile bridge strip, well in the meadow; rough crossroads lane across the road, picnic rise (rough hill) |
| 236 | wildflower and dandelion drifts (rough blobs), open; stream band with stone bridge strip, bean-pole rows of thicket dots; windmill on a rise, hay wagon block |
| 304 | oak-root arch (two pillars with a lintel, road through), hollow trunk; acorn drop and owl oak in tight forest |
| 305 | white-bark tunnel = 3-wide corridor between two thicket walls, birch curtain = row of alternating trunks with gaps; fern hollow, round sunbeam clearing |
| 306 | mossy log (thicket bar), grotto hill; mossy gate = wall with one gap, toadstool steps (rough dots) |
| 307 | long wet-sand tideline above a sea band, barnacle rocks; shell hollow (rock bowl), sandcastle in the shallows |
| 308 | pebble bars (rough strips) above the sea, kelp line; rock pool and tide-pool steps |
| 309 | frozen pond (large rough ice disc), snowman gallery (thicket singles in a row); icicle cave mouth = 3-tile gap in a 2-thick wall, aurora-glass ledge |
| 310 | snowdrift pass between two big drifts, sled tracks (rough lines); snow-comb ridge with teeth, icicle curtain at the exit |
| 311 | maple tap row (tree singles in a line), bucket stacks; Sugar Shack yard on a rough rise, pancake lane |
| 312 | ring-count log (thicket bar), woodpecker tree; toadstool ring, bramble corridor (narrow band between thicket); great stump on rough ground, larder |
| 313 | dam = 2-thick thicket bar with one gap (road), pond water on both sides, mud slide = rough bank; lodge in a pond, stick gate = wall with one gap; glow-cap tunnel = 3-wide corridor through a hill, tunnel mouth at the west end, mini-boss `E` in it |
| 314 | driftwood beach under a sea band, shell pile; stepping rocks, causeway on a strip between rocks and sea; lantern rocks, gull parliament on open sand |
| 315 | snowy gate (wall with one gap), lamp lane; pine slope (diagonal pine ridge), snow fort (ring with a gap); frozen stream (winding water) with icicle bridge strip; giant feather (diagonal ice patch), cairns (thicket singles); owl's doormat (rough patch), den hill around a 3-wide corridor to the exit, boss `E` in it |
| 316 | sky-watch hill with rough top, star stones (singles); aurora camp clearing, kettle tree |

## Notes for Josh
- Set pieces are readable but rough (rect and disc stamps). Forest routes (304, 305, 306, 312, 313) now use the tight forest base (narrow lanes, small clearings; `mockup-forest.png` shows old vs tight for 304 and 313).
- Landmark and find positions are snapped by the builder to the nearest valid tile; sprites for new landmark names are not checked here.
- Pictures: `route-<id>.png` next to each file. Pictures were looked at for all routes except 304 and 305 after the tight-forest rebuild.
- Rules felt tight: a tunnel corridor needs the one long run (10) per section; 314 section 3 and 313 section 3 use it.
- Not done: the optional gate and extra mini-boss proposal. Suggested spots: 313 s3 tunnel mouth (x 19-20, y 10-12); 315 s3 icicle bridge strip (x 14-15, y 8) and s2 pine slope (x 7-12, y 1-4); 314 s2 causeway strip (x 12, y 5-6); extra mini-boss spot at the end of 312 s3 (great stump) on the road.

## Lint
`python3 tools/lint_trail_bends.py claude/maplewold-bendy-maps/route-*.json` -> 0 problems for all 16 files.

## Terrain variety (grassland first)
`tools/build_maplewold_bendy.py` has a stamp library used in the sketches: `pond` (water + rough shore), `marsh` (rough with pools), `grove` (scattered trees), `orchard` (tree grid), `hedgefield` (hedged plot, rough inside, one gap), `drift` (rough ellipse for flowers, snow, dunes), `fence` (posts). Added to the grassland routes 228, 232, 236 and 311; lint 0 problems. Next: coast (dunes, tide pools), tundra (drifts, frozen lakes), forest (logs, clearings).
