# bend-prototype-v2: all 246 routes with landscape variety

`python3 tools/gen_bendy_trail_proto.py --all --variety` (same roads, joins and rules as `claude/bend-prototype/`, which is unchanged). Added by `--variety`:
- **Stamps by land** (`tools/bend_stamps.py`, shared with `tools/build_maplewold_bendy.py`): 2 to 3 per section, 4+ tiles off the road: grassland (grove, orchard, hedged field, drift, marsh), forest (log, clearing, grove, marsh), coast (dune, rock stack, tide pool), tundra (ice lake, pines, drift), desert (dune, rock stack, drift), mountain (rock stack, pines, drift), wetland (marsh, grove, tide pool), rainforest (grove, log, clearing, marsh), island (dune, tide pool, grove, rock stack).
- **Ponds from the region picture** (`tools/bend_water.py`): blue water blobs of `game/assets/img/scenes/map-<CODE>.png`, filtered by shape, put into the section nearest to them (within 14 region units), on the side they lie.
- Lint: `python3 tools/lint_trail_bends.py claude/bend-prototype-v2/route-*.json` -> 0 problems for all 246.

Not done here: streams (only Maplewold's are hand-derived, `tools/maplewold_waterways.py`), gates and extra mini-bosses (Maplewold only, by hand). The 16 Maplewold routes in this folder are generated, not the hand-tuned ones in `claude/maplewold-bendy-maps/`.
