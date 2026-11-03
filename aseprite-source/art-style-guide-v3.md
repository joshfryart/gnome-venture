# Gnome Venture art guide v3: "Hearth Pop"

Status: **draft 1, 2026-11-03.** Replaces Part D "Stitched Toy" (`art-style-guide.md`, now deprecated). Parts A (Hearthlight colour families), B (inline icons) and C (UI sheet) still stand; this file wins for every Aseprite picture.
Tooling is unchanged: Aseprite 1.3.18 CLI, Lua scripts, PNG + `.aseprite` out, canvas sizes unchanged so no game code moves.

Words: **clean, crisp, quirky, cute, clear.**

## 1. Why v3 (what was wrong with Stitched Toy)
- Too many layers per object (3-tone outline, crescent, bounce, rim, comma gloss, contour, contact shade, edge stitch, seam, button, 1 px black border). At 32 px it is mud.
- Outline is thick and dark on everything, so every sticker looks the same weight and busy scenes go heavy.
- Palette is muted and brown-leaning; things look dusty, not cute.
- 2.5D gnome and folk are flat stacked layers with no real 3/4 form, no ground, no weight.
- Scenes are cluttered, flat in depth, and region art used as jigsaws has big dead areas.

## 2. Inventory (PNG, JPG, GIF; SVG twins not counted; counted 2026-11-03)

| # | Section | Files | Made of |
|---|---|---|---|
| 1 | **Items and icons** | **1,864** | ph item art 1,409 (seeds, crops, goods, tools, `broken-*`, `stage-*`, hats, nav) · `ico` 286 · `gather` 38 · `flowers` 19 · `flowers-pixel` 46 · `items` 21 · `craftmap` 14 · `games` 11 · `fx` 6 · `roadkinds` 5 · `steps` 5 · `ui` 4 |
| 2 | **NPC portraits** | **93 now + 22 missing = 115** | `ph/npc-*` 82 (80x100) · `folk` 11 species icons (64x64) · **22 species portraits missing for minor-stop villagers** (they show an emoji today) |
| 3 | **NPC / player 2.5D models** | **1,675 now + new set** | `acts` 1,667 (gnome action poses, 144x108, incl. `-anim` strips) · `gnome` 8 layers (80x100) · **new: 3/4 world models, idle + walk** (player + the 22 species) |
| 4 | **Banners, regions, homes, scenes** | **599** | `scenes` 171 (banners, homes 6, shops 6, stages 95, maps 16, stops 12, treks 16) · `jigsaw` 109 (14 regions x full + thumb, plus 81 `places`) · `wonders` 81 · `stoptiers` 48 · `trek` tiles 46 · `ph` banner 14 + guide 14 + land 9 · `stops` 24 · `town` 24 · `landing` 19 · `route` 15 · `journal` 14 · `map` 11 |
| | Not in your four, listed so nothing is hidden | 2,439 | creatures `ph/creature-*` 137 · `mini` 201 · `animals` 36 · `catfish` 1,414 · `puzzles` 651 (571 are pals). Same style should follow later; not touched yet. |
| | Root files (icons, share card, chest) | 10 | |
| | **All PNG/JPG/GIF under `game/assets/img`** | **6,680** | |

Missing portraits, exact list (stop folk are made from species per biome, `includes/stop_folk.php` `STOP_SPECIES`): Hedgehog, Field Mouse, Wood Mouse, Mouse, Shrew, Mole, Hare, Cricket, Grasshopper, Ladybird, Bumblebee, Beetle, Wren, Moth, Butterfly, Firefly, Dragonfly, Snail, Tortoise, Frog, Toad, Gecko = 22. Plan: one portrait per species, with a 12-personality accessory overlay later (hat, scarf, glasses) so 2-3 folk per stop do not look identical.

## 3. The look in 10 rules
1. **Silhouette first.** One bold rounded shape that reads at 16 px. Chunky, a little squashed (wider than tall), tiny limbs, big head. If the black-filled silhouette is not recognisable, redraw.
2. **One outline.** 1 px, warm ink `#2b1c26`, only around the outside of the whole object. No 3-tone outline, no 1 px pure black border, no cream halo. Inside, separate parts with a 1 px line in the **darker neighbour tone of that part**, only where two similar colours touch.
3. **Four tones per colour, hard pixels.** `hi / base / shade / deep` (palette below). Light is **upper left**. Shade is **one flat band** (at least 2 px wide) on the lower right. `deep` is for outlines inside the object and the underside. No bounce, rim, contact or second crescent.
4. **One pop.** One highlight per object: a 2x1 or 1x2 `hi` mark upper left, plus at most one 1 px `cream` sparkle. That is the whole gloss.
5. **Colour.** Fewer, cleaner, happier. Max 6 ramps per object, max 16 colours per 64 px sprite. Saturated base, cool-violet shadows, warm-yellow lights. No dither, no gradients, no semi-transparent pixels, no pure black or white.
6. **Cute proportions.** Head about 55-60% of the figure. Eyes low and wide. Cheeks (2x1 `petal` base) allowed on characters. Mouths 1-3 px.
7. **Eyes.** Portraits (80x100): the locked v06 eye (5x5 `cream` disc with cut corners, 3x3 `ink` pupil, 1 px `cream` glint upper-left). Sprites 64 px and below: 2 wide x 3 tall `ink` pill with a 1 px `cream` glint. Never anything else.
8. **Quirk tag.** Every asset carries ONE odd, charming tell: a snail riding the hat, a bite out of the biscuit, a patch on the knee, a leaf umbrella, a crooked flag. Chosen per asset, written in its spec line `quirk:`. Not a repeated gag.
9. **Stitch is a spice, not a base.** Gold dashed stitch (2 on, 1 off, `gold.base`) only on real cloth seams or hems (hat band, banner hem, quilt, bag). Max one seam per asset. The 3x3 gold button is allowed on cloth garments only. No edge stitch rings.
10. **Clear at size.** Check every file at 100%, 50% and 25%. The main colour, the eyes and the silhouette must survive.

## 4. Palette: Hearth Pop 50
`ink #2b1c26` · `cream #fff4d6`. Eleven 4-step ramps plus sky. Use only these. If a subject needs another colour, add a ramp by this recipe: base saturated; hi = hue toward yellow, +25% light; shade = hue toward violet, -20% light; deep = hue toward violet, -45% light.

| ramp | hi | base | shade | deep | use |
|---|---|---|---|---|---|
| ember | `#ff8a5c` | `#e8493b` | `#b52e3f` | `#6e2038` | red, fire, berries, hats |
| gold | `#ffe38a` | `#f5b82e` | `#d98322` | `#8f4a1f` | honey, thread, grain, buttons |
| moss | `#c4e07a` | `#7cc35a` | `#3f9150` | `#24544a` | leaf, grass, herbs |
| sea | `#b6f0e0` | `#5fc4c8` | `#3a86b0` | `#2a4a7a` | water, ice, glass |
| dusk | `#c9b2f0` | `#8a6fd0` | `#5a459e` | `#35295f` | night, plum, wizard, shadow |
| petal | `#ffc4d8` | `#f5809f` | `#c94f84` | `#7d2c5e` | flowers, cheeks, candy |
| wood | `#e8b982` | `#b97a4a` | `#864c33` | `#51302b` | wood, soil, bread, fur |
| stone | `#e2e0e6` | `#aaa9b8` | `#74758c` | `#444663` | rock, metal, fog |
| sky | `#e4f6ff` | `#b9e2f5` | `#8bc4ea` | `#5f9ad0` | skies, clouds |
| skin A | `#ffe0bd` | `#f0b98d` | `#c98462` | `#7a4036` | faces |
| skin B | `#d9a070` | `#b57850` | `#8a5638` | `#55332a` | faces |
| skin C | `#a8704a` | `#84523a` | `#5e3a2e` | `#3a2420` | faces |

Machine copy: `v3/lib/palette.lua` (and `v3/lib/hearth-pop-50.gpl` for Aseprite's palette panel).

## 5. Per section

### 5.1 Items and icons (64x64; `ico` 64x64; `nav` 64x64)
- Object fills 44-54 px of the canvas, centred, 5 px margin. Slightly top-down 3/4 angle for containers and plates; side-on for tools.
- Outline 1 px ink outside. 3 tones inside plus the one pop. No ground shadow except plates and jars (a 2-tone `stone` ellipse, 3 px tall).
- One strong colour + one accent colour. Food: warm, glossy, one bite or steam curl as the quirk.
- `broken-*`: same drawing + a zigzag crack (1 px `ink`) + one flying chip. Colours unchanged.
- `stage-*` / numbered tiers: same pot, grow one visible feature per step. Seeds: a tiny packet-free seed on a leaf scrap, label colour = plant colour.
- Dark theme: icons must work on both; the ink outline is what keeps them clear, so never remove it.

### 5.2 NPC portraits (80x100, bleed off the bottom)
- Head and shoulders, head 38-44 px wide, centred, looking slightly toward the viewer's right. Eyes per rule 7 (locked eye).
- **Backdrop disc** behind: a 62 px circle in the villager's mood colour (`base`) with a 2 px `shade` ring lower right, then transparent outside. This replaces the halo.
- Outline 1 px ink outside. Clothes carry the personality colour; one prop in frame (spoon, flute, book) is the quirk.
- Species silhouettes must differ at a glance: hedgehog = spiky crown, mole = pink snout + tiny eyes, snail = shell swirl, etc.
- Stop-folk species portraits use a neutral outfit + a `none` accessory slot; 12 personality accessories are drawn as separate 80x100 overlay PNGs later.

### 5.3 NPC and player 2.5D models
"2.5D" = **3/4 top-down view**: you see the top of the head and a bit of the front. Replaces the flat stacked layers.
- Cell **64 x 80**, feet baseline y=70, figure about 48 px tall including hat. Head about 55% of height.
- Ground shadow: 2-tone `stone` ellipse 28x8, centred under the feet (the one shadow in v3 sprites).
- Rig for the gnome player stays layered for tinting: `body`, `face`, `beard` (neutral grey), `hat` (neutral grey), `scarf`, `band`, `star`, `shadow` — same 64x80 cell, same anchor, so they stack. Hat and beard bases must be **light grey `stone.hi/base/shade`** so multiply tint lands at about 100% of the swatch.
- Frames: `idle` (2-frame breathe, 1 px bob), `walk` (4 frames: contact, pass, contact, pass; 1 px head bob, arms swing 2 px). Sheet = horizontal strip, 64 px per frame, tags in the `.aseprite`.
- Acts (`acts/act-*`, 144x108): a framed scene with the gnome at 3/4 scale doing the job; redrawn after the world model is approved, reusing its head and body.

### 5.4 Banners, regions, homes and scenes
- Draw on a **small grid and scale up with nearest neighbour**: banners 240x60 ->x2 (480x120); homes, stages, wonders 240x135 ->x2 (480x270); region jigsaw art **300x200 ->x6 (1800x1200)**, thumb x1.5 from the same grid; ph banners 120x40 ->x2; stoptiers 48x48 ->x2.
- **Three depth planes**: far (2 low-contrast colours, no ink), mid (hero subject, base + shade), near (full contrast, ink-edged, framing the corners). Sky: max 4 flat bands + a sun or moon disc + 2-3 puff clouds (3 bumps, flat bottom).
- Landscapes have **no black outline**; shape contrast does the work. The hero object gets a 1 px `deep`-tone edge. Homes get the ink outline (they are objects).
- **Quirk**: every scene has one tiny storyline (a gnome waving from a chimney, a goat on the roof, a snail crossing the road).
- **Region art = jigsaw**: put a distinct landmark or colour patch in every cell of a 6x4 grid (no empty 50x50 px area in the 300x200 grid), vary the hue between neighbouring cells, avoid long straight horizontals, no text.
- Banner hem: thread-gold dashes (2 on, 1 off) along the bottom edge only.
- Weather stages (`stage-<biome>-<weather>`): same composition, swap sky band colours and add one weather element (rain streaks 1x3, snow 2x2 cross, fog = two `stone.hi` bars, heat shimmer = alternating row shift).

## 6. Pipeline: who does what
1. **Sonnet writes Lua.** Library (`v3/lib/hp.lua`: palette, canvas, shapes, outline, shade band, pop, eye, cheek, stitch, ground shadow, scale-up, save, `report`) and the first working script for each asset from a one-paragraph spec.
2. **Opus does the art, two passes.**
   - **Pass 1 (form):** read the Sonnet script, redesign shapes, proportions, colour and quirk, re-render, view at 100/50/25%. Keep scripts as `<name>.p1.lua`, PNG `<name>.p1.png`.
   - **Pass 2 (polish, must be substantial):** open pass 1 fresh and change real things. At minimum: re-cut the silhouette, fix every stray or doubled pixel, redistribute shade band, tune colour choices between ramps, add or fix the quirk, rework the weakest quarter of the canvas. Output `<name>.png`, `<name>.lua`, `<name>.aseprite`. A pass 2 that differs from pass 1 by under ~8% of pixels is rejected.
3. Review at 100/50/25% on a mid-grey and a dark background. Then batch.
4. Run (from the repo root): `squashfs-root/AppRun -b --script-param out=<dir>/ --script <asset>.lua` (extract the AppImage once: `./Aseprite_1.3.18.6-x64.AppImage --appimage-extract`).

Folders: `aseprite-source/v3/lib`, `v3/items`, `v3/portraits`, `v3/models`, `v3/scenes` (lua, aseprite, png together), `v3/review` (contact sheets).

## 7. Checks (every file)
- Only palette colours; zero semi-transparent pixels; zero `#000000` / `#ffffff`.
- 1 px ink outline outside only; no halo; no stray single pixels (no isolated pixel unless it is the pop or the sparkle).
- Light upper-left; one shade band; one pop.
- Rule 7 eyes exactly.
- Exactly one quirk, named in the spec.
- Canvas size and file name identical to the original (`<folder>/<name>.png`).
- Reads at 100, 50, 25%.
- Scenes: three planes, no empty 50x50 area (regions), hem on banners.

## 8. Rollout order (after example approval)
1. Palette + lib frozen. 2. Items in family batches (food, tools, seeds, flowers, icons). 3. Portraits: 82 existing + 22 species. 4. World models + gnome rig + acts. 5. Banners, homes, regions + jigsaw regenerate. 6. Wonders, stages, tiers, trek tiles, landing. 7. Creatures, mini, catfish, puzzles.
Rule from earlier work still holds: every asset visually unique, no recolour templates; a batch never has more than 3 similar assets per agent.

## 9. Example set (this round)
12 examples, 3 per section, each in `v3/<section>/` with `.p1` and final versions side by side in `v3/review/sheet.html`. See the section table in the hand-off message for what was drawn.
