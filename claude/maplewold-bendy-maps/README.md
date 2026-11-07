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
- Gates and extra mini-boss spots are now in the data (section below); they were a proposal before.

## Lint
`python3 tools/lint_trail_bends.py claude/maplewold-bendy-maps/route-*.json` -> 0 problems for all 16 files.

## Terrain variety (grassland first)
`tools/build_maplewold_bendy.py` has a stamp library used in the sketches: `pond` (water + rough shore), `marsh` (rough with pools), `grove` (scattered trees), `orchard` (tree grid), `hedgefield` (hedged plot, rough inside, one gap), `drift` (rough ellipse for flowers, snow, dunes), `fence` (posts). Added to the grassland routes 228, 232, 236 and 311; lint 0 problems. Next: coast (dunes, tide pools), tundra (drifts, frozen lakes), forest (logs, clearings).

## Water ways (from the region map)
`tools/maplewold_waterways.py` -> `waterways.json` (region NA, 480 x 270 frame, streams listed upstream to downstream). `tools/build_maplewold_bendy.py` turns every place where a route's region curve crosses water into a stream through the road tile at that point, along the stream's own direction (region axes = grid axes), with a rough ford where the road crosses. Each section stores `water` (name, flow direction, tiles). Pictures with water in blue and a flow arrow: `tools/preview_maplewold_water.py` -> `route-<id>-water.png`.
- **Read from the picture** (map-NA.png): the lake (bottom right), the two ponds (west, middle), Bridge Brook (comes down from the top edge under the wooden bridge on the Mistmoor road) and a short slanted brook.
- **Derived by rule** (everything drains to the lake): Hub River runs from the Market area down to the lake; West River (from the west pond), Hub Brook, South Brook and Pond Brook (into the middle pond) feed it; the middle pond has an outlet to Bridge Brook. Invented parts are marked `derived` in the json.
- **Where it shows:** 228 s2 (West River ford), 232 s2 and 236 s2 (Hub Brook), 304 s2, 306 s2, 307 s1, 312 s1-s2, 313 s2, 315 s3 and 309 s2 (Pond Brook into the middle pond), 316 s2, a pond in 305 s2 and 310 s2.
- **Replaced:** the hand-drawn streams (228 ford, 232 log bridge, 236 stone bridge, 315 frozen stream) are now the derived streams; hand ponds in grassland became marshes (no source on the map).
- **Not backed by the map:** 313 s1 dam and pond (no water near that road): kept as a spring-fed beaver pond. Bridge Brook and the lake do not reach any of the 16 routes (they lie east of x 330).
- **Limits:** crossing points are clamped to 15%..85% of a section so streams stay inside it; a stream stops at the section border (the next section does not continue it).
- **Crossing tile:** the builder moves each crossing along the road (within 8 tiles) to where the stream meets the road most squarely. Where the stream runs the same way as the road (306 s2 South Brook, 313 s2 South Brook) the road still wades along it for 6 to 11 tiles; that is a ford path, not a mistake.
- **Shallows:** each stream also gets one rough 1-tile shallow away from the road so the two banks stay connected.
- **Water is applied after the hand stamps**, so a set piece cannot erase a stream; the shortcut closing may still wall over a stream tile (then it is thicket, not water).

## Terrain variety, all lands
More stamps in the library: `dune`, `rockstack`, `tidepool` (coast), `icelake`, `pines` (tundra), `log`, `clearing` (forest). Added to every coast, tundra and forest route (`more(...)` at the bottom of `tools/maplewold_bendy_specs.py`).

## Gates (data only: no new tile character, ground tiles are unchanged)
Per section field `gates`: `tiles` (3 tiles across the chokepoint, centred on the road), `road_index`, `tool` (item slug from crafts.txt), `min_quality`, `kind`, `label`. The builder walls the whole section across the road at that tile, open only at the gate tiles.
- **Locks** (blocking the tiles cuts entry from exit): 313 s3 tunnel mouth `miner-s-lantern`; 315 s2 pine slope `rope`; 315 s3 icicle bridge `prospector-s-pick`. All lie before the boss/mini-boss `E`.
- **Shortcut:** 314 s2 tidal causeway `hiking-staff`; a second opening 5 tiles away (`bypass`) gives the long way round (at least 6 steps longer).
- **Quality rule (decided):** `min_quality` = region tier + 1, one tier above the base tier. Maplewold is tier 1, so every gate here needs quality 2; later regions go up by one per region tier. The game has no tool-quality field yet (crafts.txt has tools but no quality), so this is data for when it exists. Lantern, rope and pick confirmed. The 314 causeway stays a shortcut.

## Extra mini-boss spots (data only, not `E`)
Per section field `extra_minibosses` (`x`, `y` on the road, `creature` slug, `level`, `label`), one per section, 5+ steps from the entry and 7+ from the exit:
- 312 s3 great stump: Bramble Wolf (22); 314 s3 lantern rocks: Clam Lurker (23); 310 s1 snowdrift pass: Grumpy Wolverine (21); 309 s2 icicle cave mouth: Arctic Fox (17).
- Kept free of fights: 228, 232, 236 (starters), 311 (Sugar Shack), 316 (Aurora Camp). 313 and 315 keep their `E`.

Check: `python3 tools/lint_maplewold_extras.py claude/maplewold-bendy-maps/route-*.json` (gate and mini-boss rules) next to `tools/lint_trail_bends.py`. Pictures show gates in magenta, the bypass in green and extra mini-bosses as orange dots (`route-<id>-water.png`).
