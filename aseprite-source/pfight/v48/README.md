# v48 puzzle pieces: the beauty pass (faces, glyphs, plate, digits)
Hard pixels, no alpha blends, 1 px ink outline, light from the upper left (art guide v3, "Hearth Pop"). `scripts/check.py` verifies it.
**The edge is v47's and is not redrawn here:** body 56x47 / 96x80, tabs 13 / 22, sockets, badges and overlays are read from `../v47`
(`scripts/lib48.lua` loads `../v47/scripts/lib47.lua`, `scripts/pv48.py` loads `pv47.py`). check.py proves every v48 tile has the v47 silhouette.

## What changed against v47 (and why)
| | v47 | v48 |
|---|---|---|
| my pieces | flat felt, 1 px light, random grain dots (read as dirt on a desktop), a thin stitch | clean face, a bevel (lit top and left, shaded right, a 2-row lip at the bottom), a short glint; no grain, no stitch |
| my glyphs | 16x17, thin | redrawn, up to 20x19 with outline: hurt sword, guard shield, heal cross, charm heart, soothe leaf, trick sparkle, item flask |
| creature pieces | my tile + a red frame; in the game they came out hue-shifted with NO glyph | their own body (ember to plum, teeth along the top and bottom) and a glyph per type in other shapes: hurt claw marks, guard spiked shell, heal drop, charm paw print, soothe moon, trick bolt, item bone |
| environment pieces | a hue-shifted tile, a black disc and a vector icon painted by the page | parchment body, a dashed stitch in the kind's colour, a drawn glyph: sun, bramble, rain cloud, wind, mud, thornburst |
| number | 3x5 figures doubled on a black rectangle, painted by the page | figures drawn at 6x10 (2 px strokes; 9x15 for the hand size) on a drawn plate with cut corners |

Owner is read without colour: mine = type colour and cream glyph; creature = dark body, teeth, eye badge, other glyph shapes; environment = pale body, dashed stitch, no number.

## Files (strip/ and hand/, each .aseprite + .png)
`tile-<size>-<type>` (mine; layers base, bevel, rim, glyph) · `foe-<size>-<type>` (base, bevel, teeth, rim, glyph) · `env-<size>-<kind>` (base, bevel, stitch, rim, glyph) ·
`plate-<size>` · `digits-<size>` (0-9 in one row). Types: hurt guard heal charm soothe trick item. Kinds: sun bramble rain wind mud thorn (wind and mud are no longer dealt, old fights still show them).
The glyph is its own layer: the kit keeps tile and glyph apart (a named piece of mine swaps in its tag icon, `game/assets/img/pfight/ico-*.png`, not redrawn in this pass).
`scripts/layers/glyph-<size>-<me|foe|env>-<name>.png` = the glyph layer alone, piece-size. `sheet/` = contact sheets. `scripts/check-output.txt` = the last check.

## Scripts
`lib48.lua` ramps of the three owners, the shape raster for glyphs (shapes in design units, 4x4 samples per pixel, set at half coverage: hard pixels), the shared body (base, bevel, rim).
`glyphs48.lua` all 20 glyphs as shapes (box W x 17 units; the hand size is the same drawing at 30/17). `tiles48.lua` the three kinds of tile, the plate, the digits.
`build_all.lua` draws everything. `pv48.py` composes pieces as the game does. `make_sheet.py`, `check.py`.

## Run
`SC=<dir with ase.sh> scripts/run.sh` (draw with Aseprite batch, sheets, check), then `ASE=<dir>/ase.sh python3 tools/build_parts48.py` (the runtime kit
`game/assets/img/pfight/parts48/`; `--check` verifies it without Aseprite). ase.sh: unpack `aseprite-source/Aseprite_1.3.18.6-x64.AppImage` with
`--appimage-extract` and call `squashfs-root/AppRun "$@"` (HANDOFF.md).

## In the game
`includes/pfparts_url.php` serves parts48 when it is there (`pfight_jigsaw` = 47 goes back to the v47 art, 0 to the old pieces). The atlas says `"version": 47`
(the edge and sizes the board code knows) and `"art": 48`. `assets/pfparts47.js` `build48()` stamps: tile, socks, glyph or tag icon, plate and digits, eye / marks.
It also redraws every piece canvas for the exact number of screen pixels it is shown at ("crisp"): strip art where one art pixel is a whole number of screen
pixels (a phone: 3), else the nearer of strip and hand art, enlarged by a whole number and brought to size with smoothing. That is what made the desktop look bad before.

## Not done / weak spots
- The 14 tag icons of named pieces (jab, smash, pierce ...) are the old drawings: fine in shape, but some sit on a body of their own colour.
- A creature's named piece shows the creature glyph of its type, not the tag icon. The creature's own colour (tint) is no longer on its pieces.
- The mud glyph is the weakest at strip size. Glyphs touch (never overlap) the rim of a hole in the middle of the top or bottom edge, as in v47.
- The blank centre piece and the lit-spot ghost are still painted by the page. Board pieces between 1.05 x and 1.4 x (a 1280 x 720 window) are strip art enlarged with soft pixel borders: clean, not razor sharp.
