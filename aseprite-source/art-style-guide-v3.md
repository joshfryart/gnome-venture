# Gnome Venture art guide v3: "Hearth Pop"

Version 2, 2026-11-03. Replaces Part D "Stitched Toy" (`art-style-guide.md`, deprecated). Parts A (colour families), B (inline icons) and C (UI sheet) of the old guide still apply to UI and icon naming. This file rules every Aseprite picture.
Tooling: Aseprite 1.3.18 CLI + Lua, PNG and `.aseprite` out. Canvas sizes and file names stay as they are, so no game code moves.

Words: **clean, crisp, quirky, cute, clear.** Plus, since v2: **slim, material, real-ish.**
A one-page human version is `Gnome-Venture-Art-Guide-v3.pdf` (same folder).

## 1. What changed since draft 1
- Colour is **not capped**. The palette is a starting kit. Use as many tones as the material needs.
- Items are **slimmer** and carry **material realism** (6-tone ramps, specular, bounce light, grain, weave, bevel).
- Faces get **designed noses**. A nose reads at 100% and 50%.
- Regions are **full, dense and textured** like the old jigsaw art, in the new style.
- The gnome is a **10-layer recolourable rig**.
- Backdrop discs on portraits get a 1 px outline in their own darker tone.

## 2. Inventory (PNG, JPG, GIF; SVG twins not counted; 2026-11-03)

| # | Section | Files | Made of |
|---|---|---|---|
| 1 | **Items and icons** | **1,864** | ph item art 1,409 (seeds, crops, goods, tools, `broken-*`, `stage-*`, hats, nav) · `ico` 286 · `gather` 38 · `flowers` 19 · `flowers-pixel` 46 · `items` 21 · `craftmap` 14 · `games` 11 · `fx` 6 · `roadkinds` 5 · `steps` 5 · `ui` 4 |
| 2 | **NPC portraits** | **93 now + 22 missing = 115** | `ph/npc-*` 82 (80x100) · `folk` 11 (64x64 icons) · 22 species portraits missing for minor-stop villagers |
| 3 | **NPC / player models** | **1,675 now + new set** | `acts` 1,667 (144x108 action poses) · `gnome` 8 layers · new 3/4 world models (player rig + species) |
| 4 | **Banners, regions, homes, scenes** | **599** | `scenes` 171 · `jigsaw` 109 · `wonders` 81 · `stoptiers` 48 · `trek` 46 · `ph` banner 14, guide 14, land 9 · `stops` 24 · `town` 24 · `landing` 19 · `route` 15 · `journal` 14 · `map` 11 |
| | Outside the four (later) | 2,439 | creatures 137 · `mini` 201 · `animals` 36 · `catfish` 1,414 · `puzzles` 651 |
| | Root files | 10 | |
| | **Total** | **6,680** | |

The 22 species for stop folk: Hedgehog, Field Mouse, Wood Mouse, Mouse, Shrew, Mole, Hare, Cricket, Grasshopper, Ladybird, Bumblebee, Beetle, Wren, Moth, Butterfly, Firefly, Dragonfly, Snail, Tortoise, Frog, Toad, Gecko. One portrait per species, personality accessories as separate overlays later.

## 3. The look in 10 rules
1. **Silhouette first.** One bold shape that reads at 16 px. Chunky head, tiny limbs for characters; **slim, elegant proportions for objects** (thin shafts, stems and handles, air between parts). If the black-filled silhouette is not recognisable, redraw.
2. **One outline.** 1 px warm ink `#2b1c26`, outside the whole object only. No black border, no halo. Inside, parts separate by a 1 px line in the darker neighbour tone of that part, only where similar colours touch.
3. **Tones.** Characters, scenes and simple icons: 4 tones (`hi base shade deep`). **Items: 5 to 6 tones per material** so shapes look round and solid. Light from the upper left. One clear shade side on the lower right. `deep` is for the underside and where parts meet.
4. **Material cues** (the realism). Wood: grain lines and a paler end grain. Metal: bevel, a bright edge, a specular streak, a darker eye or hole. Fruit: waxy bloom, one bright specular, a faint cool reflected light on the shade side. Leaf: midrib and veins. Cloth: diagonal weave or fold lines. Rope or thread: twist. Glass: a bright rim and a pale core. Add **ambient shading** (a dark row) where parts meet and a **contact shadow** under overlapping parts. Keep everything hard-pixel.
5. **Pop and glint.** One bright specular or 2x1 `hi` mark per object, plus at most one cream sparkle. More are fine only on glossy material (berries, glass, polished metal).
6. **Colour.** Clean and happy: saturated bases, cool-violet shadows, warm-yellow lights. **No colour cap.** The palette in section 4 is the default kit; step outside it whenever the piece looks better. Always hard pixels: no dither, no gradients, no semi-transparent pixels. Avoid pure black and white.
7. **Faces.** Portraits (80x100) use the locked eye: 5x5 cream disc with cut corners, 3x3 ink pupil, 1 px cream glint upper-left. Sprites 64 px and below use a 2x3 ink pill with a 1 px glint. Cheeks (2x1 petal) allowed. **Every face has a designed nose**: human = rounded nose with a lit tip, a dark underside row and nostril shadow, in a slightly warmer tone than the cheeks; animal = a distinct snout or muzzle with a nose tip (ink with a cream glint); insects = a button nose or a clear mouth. Never an unmarked gap.
8. **Quirk.** Every asset carries one odd, charming tell (snail on the chimney, thread unravelling on the handle, a hat on the cat). Written in the spec line `quirk:`. Not a repeated gag.
9. **Stitch is a spice.** Gold dashed stitch (2 on, 1 off) only on real cloth seams or hems. Max one per asset. A gold button only on cloth garments.
10. **Clear at size.** Check 100%, 50% and 25%. Colour, eyes and silhouette must survive.

## 4. Palette: Hearth Pop 50 (default kit, not a cage)
`ink #2b1c26` · `cream #fff4d6`. For anything else use this recipe: base saturated; hi = hue 10 degrees toward yellow (45), lightness +30% of the headroom; shade = hue 8 degrees toward violet (270), lightness x0.8, saturation x0.8; deep = hue 20 degrees toward violet, lightness x0.55, saturation x0.6.

| ramp | hi | base | shade | deep | use |
|---|---|---|---|---|---|
| ember | `#ff8a5c` | `#e8493b` | `#b52e3f` | `#6e2038` | red, fire, berries, hats |
| gold | `#ffe38a` | `#f5b82e` | `#d98322` | `#8f4a1f` | honey, thread, grain, buttons |
| moss | `#c4e07a` | `#7cc35a` | `#3f9150` | `#24544a` | leaf, grass, herbs |
| sea | `#b6f0e0` | `#5fc4c8` | `#3a86b0` | `#2a4a7a` | water, ice, glass |
| dusk | `#c9b2f0` | `#8a6fd0` | `#5a459e` | `#35295f` | night, plum, wizard |
| petal | `#ffc4d8` | `#f5809f` | `#c94f84` | `#7d2c5e` | flowers, cheeks, candy |
| wood | `#e8b982` | `#b97a4a` | `#864c33` | `#51302b` | wood, soil, bread, fur |
| stone | `#e2e0e6` | `#aaa9b8` | `#74758c` | `#444663` | rock, metal, fog |
| sky | `#e4f6ff` | `#b9e2f5` | `#8bc4ea` | `#5f9ad0` | skies, clouds |
| skin A | `#ffe0bd` | `#f0b98d` | `#c98462` | `#7a4036` | faces |
| skin B | `#d9a070` | `#b57850` | `#8a5638` | `#55332a` | faces |
| skin C | `#a8704a` | `#84523a` | `#5e3a2e` | `#3a2420` | faces |

Machine copy: `v3/lib/palette.lua`, `v3/lib/hearth-pop-50.gpl`.

## 5. Per section

### 5.1 Items and icons (64x64; `ico` and `nav` 64x64)
- Object fills 40-52 px of the canvas, 5 px margin, centred. Slim: stems, handles, shafts 3-4 px wide. Berries and round things leave 1-3 px of air between them.
- Light per pixel from a normal field, snapped to a 6-tone ramp, via `v3/lib/hpx.lua` (specular, reflected light, contact shadow). Hand-fix after.
- Ground shadow only under plates, jars, pots and anything that stands (2-tone, 3 px tall).
- Food: warm, glossy, with one bite, steam curl or drip as the quirk.
- `broken-*`: the same drawing plus a real gap or crack, a flying chip, a splinter. Colours unchanged.
- `stage-*` and numbered tiers: same subject; grow one visible feature per step.
- Seeds: a seed on a leaf scrap, tint from the plant.
- Icons (`ico`): bolder than items, 3 px minimum parts, 4 to 5 tones, must read at 16 px.
- The ink outline stays on every item so it works on light and dark themes.

### 5.2 NPC portraits (80x100, bleed off the bottom)
- Head and shoulders, head 38-44 px wide. Locked eyes. **Designed nose** (rule 7).
- **Backdrop disc** 62 px in the villager's colour with a 2 px shade crescent lower-right and a 1 px outline in its own darker tone (never ink). Outside the disc is transparent.
- Hair and fur: strands or tufts with a lit top, a mid tone and a dark underside. Fabric: fold lines and a hem or trim.
- One prop or companion in frame is the quirk.
- Species must differ at a glance (spiky crown, pink snout, shell swirl, wings).
- Stop-folk: one portrait per species in a neutral outfit; personality accessories are separate 80x100 overlay PNGs.

### 5.3 NPC and player 2.5D models
- **3/4 top-down view**: you see the top of the head and part of the front. Cell **64x80**, feet baseline y=70, figure about 48 px tall, head about 55%. 28x8 two-tone stone ground shadow.
- Frames: `idle` 2 (1 px breathe), `walk` 4 (front foot drops 2 px, back foot lifts, body shifts 1 px, arms swing 2 px). Horizontal strip, 64 px per frame, tagged in the `.aseprite`.
- **Recolourable gnome rig** (`v3/models/rig/`): 10 layers (shadow, outline, boots, tunic, scarf, skin, beard, face, hat, trim), each a 384x80 strip. Tintable layers use exactly four marker greys `#f0f0f0 #b4b4b4 #787878 #3c3c3c`, recoloured by **palette mapping** (each grey becomes the hi/base/shade/deep of the chosen colour, built by the recipe in section 4). Fixed layers (ink outline, eyes, cheeks) keep their colours. Use `recolor.py` or `recolor.js`; `rig.json` lists 12 presets per role.
- Rig limits: eye contrast is low on the darkest skin tones; keep beard and skin contrasting; layers cannot be hidden (no hair under the hat).
- New species models follow the same cell and frames; if a species needs tinting, build it as a rig the same way.
- `acts/act-*` (144x108): redraw after world models are final, reusing the head and body.

### 5.4 Banners, regions, homes and scenes
- Draw small and scale up with nearest neighbour: banners 240x60 x2; homes, stages, wonders 240x135 x2; **region art 300x200 x6 (1800x1200)** with a 450x300 thumb; ph banners 120x40 x2; stoptiers 48x48 x2.
- **Three or four depth planes**: sky (4 flat bands, sun, puff clouds, geese), far hills (low contrast), mid ground, big foreground. Landscapes have no ink outline; foreground objects and hero objects get a 1 px dark edge.
- **Region art = full and dense**, like the old jigsaw art:
  - No empty ground. Ground has a job: ploughed rows, a stone path, terraces, water with ripples and reflections, leaf litter.
  - 3 to 5 **big hero landmarks** (huge tree, cottage, windmill) and 15+ small vignettes: gnomes doing different jobs (3 to 5 gnomes), animals, mushrooms, barrels, a scarecrow, a boat.
  - Speckled leaf texture on trees, tile courses on roofs, bark grain on trunks.
  - Jigsaw rule: every cell of the 6x4 grid has its own features, at least 12 distinct colours per cell, neighbouring cells vary in hue, no long straight horizontals, no text. Check with `HP.cells`.
- Every scene has one tiny storyline (the quirk). Banner hem: gold dashes along the bottom edge.
- Weather stages: same composition; swap sky bands and add one weather element.

## 6. Pipeline
1. **Sonnet writes Lua** (library, first working script from a one-paragraph spec).
2. **Opus draws, two passes.**
   - **Pass A (form):** proportions, silhouette, material, colour, quirk.
   - **Pass B (substantial polish):** re-cut the silhouette, remove stray pixels, push material contrast, fix the weakest area. Output differs from pass A by clearly more than 8% of pixels. Keep `<name>.pA.lua/png` and the final `<name>.lua/png/aseprite`.
3. Review at 100, 50 and 25% on grey and dark. Build a contact sheet with `python3 v3/lib/contact.py --compare --p1`.
4. Run: `squashfs-root/AppRun -b --script-param out=<dir>/ --script <asset>.lua` (extract the AppImage once with `--appimage-extract`).
5. Library: `v3/lib/hp.lua` (canvas, masks, parts, outline, eyes, stitch, sheets, scene helpers), `v3/lib/hpx.lua` (per-pixel lighting, specular, reflected light, contact shadow), `v3/lib/README.md`.

Folders: `aseprite-source/v3/{lib,items,portraits,models,scenes,review}`.

## 7. Checks (every file)
- Hard pixels only: zero semi-transparent pixels, no pure black or white.
- 1 px ink outline outside only (items, portraits, models); no halo.
- Light from the upper left, one shade side, one clear specular.
- Item proportions slim, material cues present, no blob.
- Faces: locked or small eyes, designed nose, readable mouth.
- Exactly one quirk, named in the spec.
- Canvas size and file name identical to the original.
- Reads at 100, 50 and 25%.
- Scenes: depth planes, no empty areas, jigsaw cell check, hem on banners.
- Every asset visually unique. No recolour templates. Batch of at most 3 similar assets per agent.

## 8. Rollout order
1. **Items** (section 1), in family batches: food and crops, seeds, goods, tools and `broken-*`, `stage-*`, hats, flowers, `ico` and `nav`, gather, small UI.
2. Portraits: redo the 82 existing, draw the 22 species.
3. World models, the species rigs, then `acts`.
4. Banners, homes, regions and the jigsaw set, wonders, stages, tiers, trek tiles, landing.
5. Creatures, mini, catfish, puzzles.

## 9. Examples (in `v3/`)
Items: acai, broken-hatchet, ico-key. Portraits: npc-abuela-quilla, npc-bramble-mossfoot, folk-bumblebee. Models: gnome-player (+ rig), npc-hedgehog, folk-frog. Scenes: banner-CA, home-cottage, region-maplewold. Live sheet: `v3/review/sheet.html`.
