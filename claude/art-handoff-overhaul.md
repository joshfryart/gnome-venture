# Art handoff: scene overhaul (read this first)

For the art AI. Josh Fry, Gnome Venture. Date 2026-10-23. Game version **2.0.46**, branch `ccr-2c29e6c4-nssqf5`.

## What you are making
Pictures for a new set of screens: a **stage** (your party standing on a scene, foes opposite), **place banners**, **home and shop interiors**, **toy miniatures** for the characters, a **hoop map** kit, and a few fight effects. The code is built and live. **Every picture is optional**: a missing file falls back to plain colour bands or the old sticker, so deliver in small batches and nothing breaks.

## Read in this order
1. `claude/art-style-guide.md` **Part D** (Stitched Toy, Aseprite) then **Part E** (scene art addendum: Aseprite rules, black border rules, toy miniatures). Part E wins where it differs.
2. `claude/art-spec-overhaul.md` the full file list, sizes and counts (98 files plus miniatures).
3. This page: how the game uses the files, and the test run.

## Five rules that matter most (details in Part E)
1. **Aseprite only.** Lua script with `gvlib`, or by hand. No 3D tools, no renders, no imported or AI-generated images. Keep the `.lua` and `.aseprite` with each PNG (`aseprite-source/final/aseprite/scenes/` or the matching existing folder).
2. **Hard pixels**: alpha 0 or 255, no blends, gradients, dither, blur. Palette from Part A and Part D only. Max colours per file type are in the Part E table.
3. **Black border (1 px `#000000`)** on sprites only: miniatures, creatures, busts, the pin and landmark icons. **No border** on backdrops, banners, maps, interiors, effects. Black is used for nothing else.
4. **Scenes are drawn small and exported 2x nearest-neighbour** (backdrop 240x135 -> 480x270, banner 240x60 -> 480x120). Do not draw the outline at export size.
5. **Sprites face right.** The game flips them for foes. Feet on the bottom row, centred.

## How the game uses your files (so you can draw for it)
- **Stage backdrop 480x270.** Shown 1:1, 2x on a wide screen. On phones and on the Trek and Adventure pages it is **cropped to the band y 60 to 230**, so keep the figures and the ground line inside it. Ground line at y 190 to 215. Left third and right third calm (party left, foes right). Keep the centre readable.
- **Slots:** party stands left (x about 60, then 20, 120, 80), foes right (mirror). Each slot is 80 x 100 px, feet at y 215 for the front row, y 195 for the back row. Back-row figures are drawn behind and above, so leave some floor visible.
- **Miniatures keep their own size** (64x80, 56x64, 80x80, 112x112) and sit on their own round base. No separate shadow is drawn for them.
- **Banners 480x120** sit under a page title, full width, 2 px umber frame added by CSS.
- **Interiors:** the villager (80x100 bust, cut off at the bottom) stands left-centre, so **put a counter or half-wall across y 215 to 270 on the left** to hide the cut. Your gnome stands on the left, the villager on the right slot.
- **Hit flash, lunge, KO tilt, floating numbers and HP bars are done in code.** You do not need to draw poses or bars.
- Dusk and night are not drawn: day lighting only.

## Where files go (exact names)
| What | Path |
|---|---|
| Stage backdrops (9 lands) | `game/assets/img/scenes/stage-<land>.png` land = grassland forest mountain wetland tundra desert island coast rainforest |
| Trek backdrops | `game/assets/img/scenes/trek-<chapter>-<scene>.png` chapter 1, 2, 3 (3b uses 3); scene = path, fight, camp (boss later) |
| Banners | `game/assets/img/scenes/banner-<key>.png` key = village haven wonder delve lair market, or a region code NA CA CB SA NWE SE EE MENA WCA ESA CSA EA SEA OC, or a land |
| Home interiors | `game/assets/img/scenes/home-<cottage|burrow|treehouse|hut|stone|boat>.png` |
| Shop interiors | `game/assets/img/scenes/shop-general.png` first, then `shop-<type>.png` (types listed once the shop types are confirmed) |
| Rest stop interiors | `game/assets/img/scenes/stop-<camp|ferry|herb|inn|jetty|market|mill|orchard|shrine|spring>.png` (not wired yet) |
| Maps | `game/assets/img/scenes/map-world.png`, `map-world-regions.png`, `map-<REGION>.png` (not wired yet) |
| Miniatures: creatures | `game/assets/img/mini/mini-<creature-slug>.png` slugs match `game/assets/img/animals/<slug>.png` and the creatures table |
| Miniatures: Trek crew | `game/assets/img/mini/mini-crew-<crewkey>.png` keys from `game/includes/trek_data.php` |
| Miniatures: villagers | `game/assets/img/mini/mini-npc-<slug>.png` slug = the `npc-<slug>` bust name |
| Unknown villager | `game/assets/img/ph/npc-unknown.png` (80x100 silhouette) |
| Hoop map kit | `game/assets/img/map/hoop.png` (240x240), `pin.png` (16), `landmark-medium|hard|wild|deep.png` (16) |
| Fight effects | `game/assets/img/fx/` (not wired yet) |
The player's own gnome is not a file: the code draws their customised gnome (hat, beard colour). Do not draw the gnome as one picture.

## TEST ART RUN (do this first, 9 files, then stop for review)
Goal: prove the whole pipeline (Aseprite -> export -> naming -> in game) before the big batch. Deliver exactly these, in one zip with the real folder paths:
1. `scenes/stage-grassland.png` backdrop 480x270 (the most-seen scene).
2. `scenes/stage-forest.png` backdrop 480x270 (a second land, to check they read as a family).
3. `scenes/banner-market.png` 480x120 (Town Square header).
4. `scenes/home-cottage.png` 480x270 with the counter strip bottom-left.
5. `scenes/shop-general.png` 480x120.
6. `mini/mini-aphid-swarm.png` a **small enemy miniature** 56x64 on its round soil base (the Trek and Adventure test fight uses this creature).
7. `map/pin.png` 16x16 gold stitched button.
8. `map/landmark-wild.png` 16x16 red skull flag, 1 px black border.
9. `ph/npc-unknown.png` 80x100 villager silhouette.
Check each with the Part E checklist (size exact, alpha, colours under the cap, black only on the sprite border, `.lua` and `.aseprite` saved).

**What Josh/Claude does with the test run:**
- Copy the files into `game/assets/img/...` and run `tests/trekshell.sh`, `tests/adventure.sh` and `tests/scenes.sh` with `SHOT=<dir>` (needs playwright) to get screenshots of the stage, the Town Square banner, the shop, the home scene and a fight. Look at: does the backdrop read at 1x and cropped on a phone, do figures stand on the ground line, does the miniature's base match the ground, is the black border visible on the dark theme, do the two backdrops feel like one world.
- Feedback goes back as a short list of changes. **Only then** start the full batch.

## Full batch order after the test run
1. The remaining 7 stage backdrops, then Trek 1-path, 1-fight, 1-camp (then chapters 2 and 3).
2. Party: Trek crew miniatures (crew keys from `trek_data.php`).
3. Top 15 enemy miniatures (list from Claude on request), bosses after.
4. Banners (kinds, then regions), homes, shops, rest stops.
5. Hoop kit leftovers, fight effects, maps (the maps need a Claude step first: pins and region mask hit-testing are not built).
6. Villager miniatures last.

## Known gaps (not your problem, so you do not wonder)
- World and region maps, rest stop interiors, camp and boss scenes and fight effects are not wired into the game yet. Draw them after the test run if asked; they will not show until Claude wires them.
- Shop types: only `shop-general` is requested until the list of shop types is confirmed.
- Hoop map: the game already reads `map/landmark-<tier>.png`. It does **not** yet read `hoop.png`, `pin.png` or felt textures (code draws those for now). Tell Claude when they exist and it will wire them.

## Contacts and process
- Questions go to Josh. Do not push to the repo; deliver zips. Claude merges and tests.
- If a rule here and Part E disagree, Part E wins. If Part E and Part D disagree, Part E wins for these files.
