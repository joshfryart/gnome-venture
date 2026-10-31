# Crafting area scenes: art brief (pilot: Kitchen, Pantry, Alchemy station)

One illustrated scene per crafting area, shown on the Crafting tab where the player taps objects (hotspots). Replaces the plain tile as the main picture of an area. Sample of our scene look: game/assets/img/jigsaw/maplewold-thumb.jpg and the other jigsaw pictures (kit: aseprite-source/scenes-pil/pixlib.py, jigsaw_common.py, jigsaw_maplewold.py). Style rules: claude/art-style-guide.md Parts A and D, claude/jigsaw-art-process.md (spec + passes).

Spec
- 300 x 200 hard-pixel grid, exported 6x nearest = 1800 x 1200 PNG, plus a 450 x 300 thumb. Hard pixels only, three-tone umber outline on raised objects, light from the upper left, warm Stitched Toy look, under ~100 colours, no text, no logo, no frame.
- UNLIKE the jigsaws these must be CLEAN AND CLEAR: a player on a phone must instantly see 4 to 6 distinct, well-spaced, large objects (each at least ~40 x 40 px of the 300 x 200 grid, clear gaps between them, strong silhouettes against a calmer wall/floor). No clutter, no tiny litter, a calm background. A gnome may appear but is secondary.
- Each object is a tap target. Write hotspots to <name>.json: {"scene":"<name>","w":300,"h":200,"hotspots":[{"id":"stove","label":"Stove","x":..,"y":..,"w":..,"h":..},...]} in 300 x 200 grid coordinates (rects around each object, not overlapping, min 44 px on a phone at 360 px wide means >= ~37 grid px each way).
- Light and dark theme: scene must read on both when shown inside a rounded card.

Scenes (dominant colour; subject):
- kitchen (warm red/orange/cream): cosy gnome kitchen. Objects: stove with pot, oven or hearth, worktable with board and bread, hanging pans/utensils rack, a big mixing bowl or barrel of produce.
- pantry (plum/amber/glass): larder shelves. Objects: shelf of jam jars with gingham lids, pickle crock, sauerkraut barrel, cordial bottles, a hanging cloth-wrapped cheese or garlic string.
- alchemy (teal/violet/gold): alchemy station. Objects: bubbling cauldron, shelf of coloured potion flasks, mortar and pestle on a bench, a still/alembic with tubes, a book/scroll stand.
Each scene needs a distinct colour mood so the three differ at a glance. Match the pilot tile pictures in aseprite-source/craftmap/out/ (cooking.png, pantry.png, potions.png) in motifs.
