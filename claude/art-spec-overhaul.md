# Art spec for the overhaul (hand to the art AI)

Style: **Stitched Toy** (Aseprite). READ FIRST: `claude/art-style-guide.md` Part D, then **Part E (scene art addendum: Aseprite rules and black border rules)**. Summary: hard pixels only, no halo, three-tone umber outline on raised objects, one crescent lower right, light from upper left. **Sprites get a 1 px `#000000` border; scenes, maps, banners, interiors and effects get none.** Black is used for that border only. PNG 32-bit RGBA, transparent where noted. Source `.lua` + `.aseprite` go with every PNG.
All files go in new folder `game/assets/img/scenes/` unless stated. Code falls back if a file is missing, so deliver in priority order (P1 first).

## Fixed sizes (native pixels; the game scales by whole numbers 2x/3x)
| Type | Size | Notes |
|---|---|---|
| Stage backdrop | **480 x 270** | opaque. Ground line at y 190 to 215 (sprites stand there). Left third and right third kept calm (characters stand there). Keep the centre readable. |
| Banner | **480 x 120** | opaque. Wide header. Key subject centred, edges can crop. |
| World map | **640 x 360** | opaque, one image. |
| Region map | **480 x 270** | opaque, one per region. |
| Sprites | existing sizes | Stage characters are **toy miniatures** (guide Part E, Toy miniatures): gnome/crew/villager **64x80**, small enemy **56x64**, large enemy **80x80**, boss **112x112**. 3/4 view on a round base, transparent, 1 px black border, facing right (code flips). |
| Drawing grid | half size | Scenes are drawn at 240x135 (banners 240x60, world map 320x180) and exported 2x nearest-neighbour. See Part E table. |

No text in any image. No UI. No characters in backdrops/banners (code adds them), except tiny background life (a bird, a lantern).

## P1. Stage backdrops, 9 landscapes (`scenes/stage-<land>.png`, 480x270)
`grassland`, `forest`, `mountain`, `wetland`, `tundra`, `desert`, `island`, `coast`, `rainforest`.
Each: sky, far layer, mid layer, flat walkable ground strip. Day lighting. Cosy, not scary. (Code adds a dusk tint, so no night versions needed.)

## P1. Trek stage backdrops (`scenes/trek-<chapter>-<scene>.png`, 480x270)
Chapters from `claude/trek-chapter1.md`, `2`, `3`, `3b`. For each chapter: `path` (walking), `fight` (open flat area), `camp` (fire clearing, flat ground, space for 4 figures), `boss` (the chapter's big place). Names: `trek-1-path`, `trek-2-camp`, `trek-3-boss`, `trek-3b-fight`... = 4 chapters x 4 = **16 images**. Match the mood in each chapter doc (Ch II weeping clay, Ch III humming deep cosy-eerie rock).

## P1. World map (`scenes/map-world.png`, 640x360)
Illustrated map of the Hollow with **14 regions** as distinct areas, in this layout order (rough): NA, NWE, EE (north); CA, CB, SE, WCA (middle); SA, CSA, ESA (south-west); MENA, EA, SEA, OC (east/islands). Each region reads as its own place (own colour family and landmark). Leave a small flat spot (about 24x24) in each region centre for a pin. Also deliver `map-world-regions.png`: same size, each region filled with one flat unique colour, no edges softened (code uses it for hover/click hit-testing).

## P1. Region maps, 14 (`scenes/map-<code>.png`, 480x270)
Codes: `NA CA CB SA NWE SE EE MENA WCA ESA CSA EA SEA OC`. Each region has **4 zones** (gentle starter, 2 medium, hard outer), so draw 4 visibly different bands/areas in a clear path progression from a market village (start) outward. Space for about 8 to 10 pins of 20x20. Roads/mycelium paths between areas. No pins or labels drawn.

## P2. Banners, 480x120 (`scenes/banner-<key>.png`)
- Landscapes (9): same keys as above, `banner-forest.png`, etc.
- Regions (14): `banner-NA.png` ... `banner-OC.png`.
- Places: `banner-village`, `banner-haven`, `banner-wonder`, `banner-delve`, `banner-lair`, `banner-market`.

## P2. Interiors, stage size 480x270 (`scenes/home-<key>.png`, `scenes/shop-<key>.png`)
Villagers' homes. The villager (an 80x100 bust, border, bottom cut off) stands left-centre, so **every interior has a counter, half-wall or table across the bottom 55 px (y 215 to 270) on the left** to hide the cut bottom. Warm lit back wall:
`home-cottage`, `home-burrow`, `home-treehouse`, `home-hut`, `home-stone`, `home-boat` (6).
Shops (counter on the right, empty behind it, same bottom counter rule): `shop-general`, `shop-seeds`, `shop-bakery`, `shop-herbs`, `shop-craft` (5).
Rest stops (match existing 48px stop icons in `assets/img/stops/`): `stop-camp`, `stop-ferry`, `stop-herb`, `stop-inn`, `stop-jetty`, `stop-market`, `stop-mill`, `stop-orchard`, `stop-shrine`, `stop-spring` (10).

## P2. Villager silhouette
`game/assets/img/ph/npc-unknown.png`, 80x100 bust, 1 px black border, flat dark umber silhouette of a gnome with a "?" shape cut out. Used for villagers not yet met.

## P3. Fight effects (`game/assets/img/fx/`, transparent, NO black border, max 8 colours)
- `fx-hit.png` 4 frames in a 4x1 sheet, each 48x48 (impact spark)
- `fx-heal.png` 4 frames, 48x48 (rising green sparkles)
- `fx-ko.png` 1 frame 48x48 (circling stars)
- `fx-shield.png` 1 frame 96x96 (translucent bubble)
- `fx-snack.png` 4 frames 48x48 (a thrown snack arc puff)
- `fx-ground-shadow.png` 64x16 (umber ellipse, hard-stepped, no transparency blend)

## P1. Toy miniatures (`game/assets/img/mini/<slug>.png`)
Quasi-3D by hand, or voxel/3D render finished in Aseprite (Part E rules; a raw render is rejected). Same camera for all.
- **Party** (P1): `mini-gnome-body/face/beard/hat` are NOT used; deliver the gnome as layered parts on one 64x80 canvas each in the order of the existing `assets/img/gnome/` files (`gnome-body`, `-face`, `-beard`, hat tinted by code), so skins and tints keep working. Plus the Trek crew: one `mini-crew-<key>.png` per crew member (keys in `includes/trek_data.php`).
- **Villagers on stage** (P3): `mini-npc-<slug>.png` for each existing `npc-*` bust (69), done last.
- **Enemies** (P2): `mini-<creature-slug>.png`. Do the 15 most common first (list supplied from `adventure_data.php` by level), then the rest in batches. Missing ones fall back to the sticker on a code-drawn base.
- **Bosses** (P2): one per lair and per Trek chapter boss (112x112).
- Extras only if asked: `-hit` and `-ko` strips.

## Optional (only if time)
- 2-frame `-idle` strips for the 10 most common miniatures.
- Night versions of the 9 stage backdrops.

## Counts
Stage 9, Trek 16, World 2, Region 14, Banners 29, Interiors 21, Silhouette 1, FX 6 = **98 files**, plus miniatures: gnome parts + crew (about 10), enemies (72, in batches), bosses (about 20), villagers (69, last).

## Delivery
Run the Part E checklist on every file. Zip with exact folder paths, like `upload-zips/`. Also put source `.aseprite` in `aseprite-source/final/aseprite/scenes/`.
