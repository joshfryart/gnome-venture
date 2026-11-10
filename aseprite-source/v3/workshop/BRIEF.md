# Workshop picture redo: shared brief (3 mockups: a, b, c)

Game page: workshop.php. One 480 x 270 pixel-art picture, 7 tappable crafting sections on it. The current picture is
`game/assets/img/scenes/craft-workshop.png` (source `aseprite-source/v3/finish/a/workshop.lua`). Josh: it "needs richness and quality".

## Tool
Aseprite 1.3.18 CLI + Lua, Hearth Pop v3 lib. Run: `/tmp/aseq/squashfs-root/AppRun -b --script <file>.lua` (0-based px).
If `/tmp/aseq/squashfs-root/AppRun` is missing: `mkdir -p /tmp/aseq && cp aseprite-source/Aseprite_1.3.18.6-x64.AppImage /tmp/aseq/ && cd /tmp/aseq && chmod +x *.AppImage && ./Aseprite_1.3.18.6-x64.AppImage --appimage-extract`.
Read ONLY: this brief, `aseprite-source/v3/finish/a/workshop.lua` (how a scene script is built: HP.canvas, `tree-yard/common.lua` helpers S.obj / S.planks / S.glow / ramps, c:rect / c:poly / c:ellipse / c:rim / c:put / c:save), `aseprite-source/v3/tree-yard/common.lua`, and `aseprite-source/v3/lib/hpx.lua` if you want per-pixel lighting. Do not read the style guides or other scene scripts.

## Look rules (Hearth Pop v3, scenes)
- 480 x 270 native, full bleed. Hard pixels only: no anti-aliasing, no semi-transparent pixels in the base picture, no pure black or white, no dither noise carpets.
- 1 px dark edge on objects in their own darker tone or ink `#2b1c26`. 5-6 tone ramps per material, hue-shifted: warm yellow light, cool violet shade.
- HERO SCALE: the 7 stations are big, chunky and readable (each roughly 70-120 px wide), 10+ px air between them, no station hiding another. A phone shows this picture about 360 px wide, so details under 2 px vanish.
- Clear light story: where the light comes from, what glows, what falls into shade. Depth: a back wall layer, the stations, a few foreground props. Contact shadows under everything.
- Material cues: wood grain, stone blocks, glass rim and pale core, metal bevel, cloth weave, ceramic gloss.
- NO text or letters, NO people, NO animals (the old picture's cat goes), NO circles drawn as UI. 4-6 small charming quirks, big enough to see.
- Keep the bottom-right 100 x 40 px plain floor (round nav buttons sit there). Keep 14 px clear at the top right of every station (a "!" badge is drawn there by the game).
- Dark theme is a tint the game adds: paint one daytime-readable picture, not too dark.

## The 7 sections (key: what it is; it must read at a glance)
- cooking: a hearth or stove with pots (cooking meals)
- pantry: shelves of jars and preserves
- tools: a tool bench with vice, hammer, saw (making tools)
- garden: a potting bench: pots, seed trays, compost, watering can (compost, mulch)
- potions: a cauldron or still with bottles (tonics)
- building: timber, stone blocks, bricks, rope (repair materials)
- decor: a loom or paint and craft table (yard decor)

## Deliverables (in YOUR folder `aseprite-source/v3/workshop/<letter>/`)
1. `workshop.lua` -> `craft-workshop.png` (480 x 270) and `craft-workshop.aseprite`.
2. `layout.json`: `{"w":480,"h":270,"spots":[{"k":"cooking","name":"Cooking","x":..,"y":..,"box":[x0,y0,x1,y1]}, ...7...],"anim":[...]}`. x,y = the centre of the station; box = the painted station's bounds (boxes must not overlap each other and must stay out of the bottom-right 100 x 40).
3. "Something is ready" animation layers, one or two per section. The game already has this system: a small transparent PNG drawn over the picture at x,y with one CSS effect. Effects (pick per layer): `sway` (rotates +-2 degrees about its bottom centre, 4 s), `bob` (3 px up and down, 3 s), `twinkle` (opacity 1 to .35, 2.5 s), `drift` (+-12 px sideways, 12 s), `flicker` (opacity 1 / .8 / .95 / .7, 1.2 s), `pulse` (scale 1.06 about its centre, 3 s).
   Files `craft-anim-<k>.png` (second layer `craft-anim-<k>2.png`), hard pixels on transparency, each listed in layout.json `anim`: `{"k":"cooking","for":"cooking","fx":"flicker","x":..,"y":..,"w":..,"h":..}` (`for` = the section it belongs to; x,y = top-left on the picture).
   They are shown ONLY while that section has a "!" (something ready to make or collect), so the base picture must look complete without them, and each layer must read as "this station is busy/ready": e.g. taller flames + steam (flicker / bob), glints on jars (twinkle), a raised hammer or sparks (bob / twinkle), a nodding sprout (sway), rising bubbles and a glow (bob / pulse), sawdust or a swinging rope (sway), a sliding shuttle or fluttering cloth (drift / sway). Design the motion so the moving part does not uncover a hole: paint what is behind it in the base.
4. `notes.md`: 6-10 lines: the idea, light story, the quirks, weak spots you see.

## Working rules
- One self-contained script (you may add a second script for the anim layers). Deterministic (hash noise, no os.time).
- Check your work by eye: make a 2x nearest-neighbour PNG with PIL and Read it. At most 3 look-and-fix rounds for the picture, 1 for the anim layers (composite them on the picture to check placement). Then stop.
- Verify with PIL before you finish: the picture is exactly 480 x 270, has no pixel with alpha < 255, no pure #000000 / #ffffff; every anim PNG has only alpha 0 or 255 and fits inside the picture at its x,y.
- Work only inside your own folder. Do not touch `game/`, other letters' folders, or git. Do not delete shared files.
- Final reply: 5 lines max: what you made, checks passed or not, weak spots.
