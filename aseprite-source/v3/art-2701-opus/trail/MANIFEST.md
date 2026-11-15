# Trail event / hotspot markers 32x32, Opus pass (not exported to game/)
Same 8 subjects as the Sonnet pass in `../../art-2701/trail/`, redrawn from scratch. Native 32x32, 1px ink outline (c:finish), HP.assertClean passes on all. Shared helper: `_trail.lua` (loads `lib/hp.lua`). Rebuild: `AppRun -b --script-param out=<this dir>/ --script <name>.lua`.
Data: road_kinds.txt (ferry tunnel pass toll), trail_camps.json (camp), trail_sights*.txt (sight), folk (villager), creatures (fight).

| name | design | quirk | weak spots |
|---|---|---|---|
| camp | red A-frame tent in 3/4 (lit side roof, door, flaps, hem stitch) + tall campfire on logs | marshmallow toasting on a stick | log pile is plain |
| ferry | plank ferry with cream cabin, red gable roof, porthole, on a lens of blue water | yellow duck rides the bow | porthole is square at this size |
| tunnel | boulder-heap hill with mossy cap, timber-framed mouth, receding inner walls, road running in, hanging lantern | two yellow eyes in the dark | none major |
| pass | two snow-capped slate peaks, zig-zag path to the saddle, flag stands in the open V of sky | flag is a striped scarf on a crooked walking staff | near-peak lit face is a big flat plane |
| toll | plank booth with coin plate, fat striped barrier arm on a forked rest post, dirt road | pink snail sneaking under without paying | none major |
| sight | brass spyglass (3 sections, violet leather grip, blue lens) on a wooden tripod, lens glint | ladybird riding the top of the barrel | ladybird head is only 2px |
| villager | gnome bust: floppy red hat, pill eyes, designed nose, cheeks, moustache, cream beard, blue tunic | puffing a pipe that blows a smoke ring | nose is subtle at 1x |
| fight | round plank shield (iron rim, rivets, gold boss) over a steel sword with gold guard | a scalloped bite taken out of the shield rim | bite reads best at 2x |

## Installed (2.7.01, `tools/install_art_2701.py`)
All 8 copied to `game/assets/img/trail/mark/<name>.png` (32x32, unchanged). Wired on the Trail map (`game/includes/trail_art.php`, `TRAIL_MARKS` / `trail_mark_file()`, authored sections with a baked ground picture):
- `fight` replaces the ⚔️ token tile (fixed fight / extra mini-boss), `camp` replaces the 🏕️ camp-spot tile.
Still emoji / not placed (no map token for them yet):
- `ferry`, `tunnel`, `pass`, `toll`: road kinds are a whole-route property; they show as text + emoji on the route card (`place_ui.php`) and the Trail strip (`trail_strip_html()` in `trail_tiles.php`: "🪙 A toll road", the "🪙 Pay" button). A route-card chip image would be the next place.
- `sight`: a ready Sight is the gold "!" circle over the landmark sprite (`trail_art.php`, class `tmsight`); kept, because it says "ready", not "a Sight".
- `villager`: villagers at a Sight are drawn with their own folk sprite (`tmfolk`), so no marker is needed.
- The fallback look (`tm_render_svg()` in `tilemap.php`, sections with no baked picture) still draws ⚔️ / 🏕️ as text; it is shared with the delve maps, so it was left alone. The 🚪 way-on, 🔒 / 🔓 gate marks have no drawn marker.
