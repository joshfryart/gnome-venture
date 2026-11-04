# Start prompt: background changes for clickable object art (copy into a new AI session, hand back when done)

Repo `joshfryart/gnome-venture`, own new branch from `main`, commit and push often, never push to `main`, no PRs, do not change `APP_VERSION` or `CHANGELOG.md`. Josh wants short, exact replies.

## What changes and why
The picture pages (Here, Workshop, Treehouse, Pal Yard, Residential, Door) have tap spots (hotspots) at named x,y points. Today a round emoji or plaque sits on the scene. New plan: each spot becomes a **clickable art piece of the thing itself** (market stall, cottage, campfire, cave mouth, signpost...), 64x64 PNG, drawn by another session, drawn over the scene at the spot.
Examples (not final): `aseprite-source/v3/hotspots/scene/hsx-shops.png`, `hsx-homes.png`, `hsx-fire.png`; sketch of the drop-in is in the chat history as `scene-example.png`.

**Problem:** the scene PNGs already paint those objects (stall, houses, fire, board, cave, signposts...), so the overlay doubles up and looks messy.

## Your job: edit the background scenes
For every scene listed below, **remove the painted object at each spot and leave plain matching ground (or the natural scenery that would be there) so a 64x64 piece can sit on it.** Do not move anything else.

Rules:
- Scene files: `game/assets/img/scenes/here-<key>.png` (and `craft`, `tree`, `yard` pages if they have art; look in `game/assets/img/scenes/`). Keep the exact pixel size (layout `w` x `h`, 480x270 today; read `game/includes/data/here_layouts.json`).
- Per spot, the clear area is a box **64 wide x 64 high, x-32..x+32, y-56..y+8** (the art's feet land at spot y + 8). Objects in the scene that belong to that spot (stall, house, sign, fire pit, ring of stones, board, barrel...) are painted out inside and just around that box. Fill with the surrounding ground colour and texture; no blur, no semi-transparency, hard pixels, same pixel style and palette as the rest of the scene (light upper left, cool-violet shadow, warm light).
- Keep paths and the 8 exit stubs intact (the exit circles are r 26 and stay clear). Keep sky, far scenery, trees, fences and decoration that are NOT the spot object.
- Spots that are a whole building row in the picture (town `homes`) only clear the one house at the dot; other background houses can stay as scenery.
- No people or animals. No text.
- Keep the old file as `here-<key>.old.png` in `aseprite-source/v3/hotspots/scene/backup/` (not in `game/`), so Josh can compare.
- Do not change layouts, game code or tests. If a spot looks wrong for the object, report it, do not move the spot.

## Spots per layout (name (x,y)); source of truth is the JSON
- `generic` (480x270): do (240,166), people (330,156), garden (150,156), wild (440,126), homes (110,176)
- `town` (480x270): green (240,168), shops (344,152), homes (72,150), library (140,150), board (340,186), teahouse (150,186), wild (440,126)
- `village` (480x270): do (240,166), people (340,156), garden (340,186), wild (440,126), homes (140,156)
- `haven` (480x270): fire (240,170), shop (140,156)
- `wonder` (480x270): investigate (240,160)
- `delve` (480x270): mouth (240,160)
- `lair` (480x270): mouth (240,160)
- `stop` (480x270): do (240,166), people (340,156), rest (140,156), wild (440,126), homes (140,156)
- `resid-4` (480x270): back (40,248), prev (30,120), next (450,120)
- `resid-6` (480x270): back (40,248), prev (30,120), next (450,120)
- `resid-8` (480x270): back (40,248), prev (30,120), next (450,120)
- `door` (480x270): knock (240,170), gift (350,206), back (50,244), plate (240,84), light (300,120)
- `workshop` (480x270): cooking (92,150), pantry (190,112), tools (300,158), garden (396,126), potions (142,214), building (282,222), decor (404,212)
- `treehouse` (480x270): parlour (150,150), loft (330,140), cellar (240,226), puzzles (70,214), catfish (410,214), contests (240,110), books (440,100), yard (36,150)
- `yard` (480x270): garden (84,176), trip (392,116), delve (424,196), station (240,150), sick (64,112), board (240,226)

Priority order: town, village, stop, haven, wonder, delve, lair, generic, then workshop, treehouse, yard, door, resid-4/6/8 if they have art (they may only be placeholders: check with `ls game/assets/img/scenes` and say which have none).

## How to work
- Aseprite/PIL both fine. Tool help: `aseprite-source/v3/lib/CHEATSHEET.md`, `aseprite-source/v3/HANDOFF.md` (Aseprite run line is there).
- Draw ground fix by copying nearby ground tiles/dither rows from outside the box; check seams at 4x.
- Make one contact sheet per scene: before and after at 2x with the 64x64 boxes outlined in magenta on the "after" side, and Read it before you finish.
- Run `tests/ci_suites.sh here scenes` and report real results.

## Hand back
Reply with (1) scenes edited and spot boxes cleared per scene, (2) contact sheet paths, (3) any spot where the object could not be cleanly removed (and why), (4) tests run and results, (5) branch name.
