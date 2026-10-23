# Art delivery report: scene overhaul (2026-10-23)

Everything in `claude/art-spec-overhaul.md` is drawn, except Trek crew extras and optional night/idle sets. All PNGs are in `game/assets/img/` at the spec paths. **Not yet run in game** (no `tests/trekshell.sh`, `adventure.sh`, `scenes.sh` screenshots yet): do that next and send a short change list.

## What is there
| Group | Files | Notes |
|---|---|---|
| Stage backdrops | 9 (`scenes/stage-<land>`) | grassland and forest from the approved test run; 7 new lands share the same ground band |
| Trek backdrops | 16 (`scenes/trek-<1,2,3,3b>-<path,fight,camp,boss>`) | 3b has its own palette (violet, gold seam gate) |
| Banners | 29 (9 lands, 14 regions, village haven wonder delve lair market) | generated from one table, hem stitch top and bottom |
| Interiors | 21 (6 homes, 5 shops, 10 rest stops) | every one has a bottom-left cover over y215 to 270 |
| Maps | 16 (`map-world`, `map-world-regions` mask, 14 `map-<code>`) | pin spots left flat (24x24 world, 20x20 region); mask is raw flat colours |
| Hoop kit | `map/hoop`, `pin`, 4 `landmark-*`, 5 `felt-*` | felt tiles tile seamlessly (period-4 weave) |
| Fight effects | 6 (`fx/fx-*`) | hit, heal, snack are 4-frame strips |
| Miniatures | 201 (`mini/`) | 91 creatures + Trek creatures and bosses, 7 `mini-crew-<key>`, 69 `mini-npc-<slug>`, gnome layers `mini-gnome-<shadow,body,face,beard,hat,band,star>` |
| Villager silhouette | `ph/npc-unknown` | |

## Deviations and things to check
- **Medium enemies** use the 56x64 small-enemy canvas (Part E has no medium size). Large 80x80, bosses 112x112.
- **Gnome layers** are 64x80 each. The 1 px black border and umber outline are in the `shadow` layer under everything, so beard and hat tint filters keep working. Check the stack order matches `gnome_avatar()`.
- **Shop interiors:** `shop-general` is 480x120 (handoff), the other four shops are 480x270 (spec).
- **Region mask** uses a dark `#101010` sea, not black.
- **Second pass done** on the 7 new stage backdrops, `banner-desert/SA/ESA/CSA` and the 16 Trek backdrops (more layers, props, depth). Third pass: every banner got a far treeline or roofline, tufts, corner framing props and a second tier of props (wells, boats, fences, llamas, lamps and so on); Trek camp, fight, path and boss scenes got set dressing; rest stops got clouds, barrels, bushes and flowers. Fourth pass: the 5 homes and 4 shops got wall art, furniture, hanging bundles and rugs; the 14 region maps got a river with bridges, a lake, stitched zone borders, grass texture, a bigger market village, stone outcrops and more landscape glyphs. (enemy bugs and quadrupeds got a second pass, then a third: every figure is now auto-scaled to fill its canvas, with thick horns and antlers, a new moth, tidier golem and wisp, a lean long-legged heron, and a plain apron; first pass: ant, beetle, wasp and moth bodies; canid, feline, rodent, bear, ungulate and hare builds; far-side legs, enamel gloss, base details, hands and noses on folk).
- **Checks:** every file is the exact size, alpha 0/255, under its colour cap, and scenes have no black. The sprite check reports `badBlack=1` on about 100 miniatures: one black border pixel sits in a 1 px gap inside the silhouette (it is a border round a hole, as Part E asks). Harmless.
- **`.aseprite` files:** `opus-test-run/aseprite/` (layered: sky, far, ground, objects, detail, fx, border). Scripts: `opus-test-run/scripts/` (test set), `scripts/batch/` (stages, banners, Trek, interiors, maps, hoop kit and fx), `scripts/minis/` (all miniatures). Rebuild with Aseprite 1.3.18 headless: `GV_ROOT=<repo>/ aseprite -b --script <script>.lua`, then `sh opus-test-run/scripts/batch/deploy.sh` copies PNGs to the game paths.
- **Not wired in game yet** (as the handoff says): world and region maps, rest stop interiors, camp and boss scenes, fx, `hoop`, `pin`, `felt-*`.
