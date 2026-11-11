# Puzzle Combat fight screen: layout spec v2 (for the code AI)

Files here: `mockup.html` (live), `mockup-phone.png`, `mockup-wide.png`, `board-demo.png/.json` (2D board art + piece/socket data), `tray-demo-*.png`, `inspect-demo.png`.
Regenerate: `python3 make_board_demo.py && python3 make_mockup.py > mockup.html`.
RED outline = placeholder art that is not drawn yet. RED circle = an open socket marker (attach point). Solid = real delivered art.
All art is native pixel art shown at 2x with `image-rendering: pixelated`. Phone = 412 css px = 206 art px.

## Idea (updated)
The fight plays on top of the map where it began (map = full-screen background). Player on one side, creature on the other, a **shared 2D jigsaw board** in the middle. Players attach pieces **one at a time**: a piece is placed so one of its knobs or holes meets a matching open socket on a piece already on the board. Pieces can branch in any of four directions, so chains and shapes grow across the board. **When a piece connects, its chain (if any) activates**: the effect depends on where and to what it connects. A history bar across the top logs every connection.

## Screen zones (numbers match the mockup)
1. **Map background**: map screen where the fight began, cropped, behind everything, with a dark scrim.
2. **History bar** (top, overlays the map): scrolling chips, newest at the right. A chip = YOU (cream border) or FOE (dashed border) + the type icons of the chain that fired (`ico-<type>-s.png` 20x20) + result text.
3. **Creature** (64x64 sprite, name plate). 4. **Intent bubble** (28x24) with the type icon of what it will do next.
5. **Shared resolve bar** (96x12 frame, fills 92x8 from both ends: Hurt slashes, Charm flowers).
6. **Just-placed piece**: glow ring (FX) on the piece that was attached this turn while its chain plays out.
7. **Board**: the 2D puzzle. Open sockets (red circles) show where the selected piece could attach; show them only for sockets the selected piece fits.
8. **Player** (gnome avatar). 9. **Combo stamp** (32x32) pops when a named combo fires.
10. **Hand tray**: pieces at board size (strip, 2x), swipe sideways. The selected piece has a gold selection ring.
11. **Inspect card**: tap a hand piece to see it at hand size (`piece` at 96x68 body) with name, number, chain text (all printed by code).
Buttons (code): Undo, End turn.

## Piece art model (important for code)
Each piece = a body (type colour + pattern + icon + number plate) with up to four **edges**: `L R T B`, each one of `flat`, `knob:<family>`, `hole:<family>`. Families: body (round tab), mind (keyhole), craft (triangle). A knob fits a hole of the same family; flat is wild.
- Silhouettes are real jigsaw cutouts (holes are transparent), so a piece cannot be a fixed rectangle with overlays.
- There are too many combinations to ship as files (7 types x 7^4 edge states). Two ways:
  A. **Runtime render (recommended)**: port `aseprite-source/pfight/gen_shapes.py` (`shape_mask` + `paint`, plain integer pixel maths, about 100 lines) to a JS canvas, cache per (type, edges, owner, size). Output is identical to the PNGs.
  B. Ask the art side for a **parts atlas** (bodies per type + knob/hole cutters per family) if canvas drawing is not wanted.
- Sizes: body 96x68 (hand) / 56x40 (strip). Tab depth 18 / 9 on the left and right, 12 / 6 on top and bottom (shallower so the icon is not cut). A piece image is body + tab depth on every side: strip 74x52, hand 132x92. Place pieces on a grid at body pitch (56x40 strip, 96x68 hand) so a knob sits exactly in the neighbour's hole.
- Owner: mine = cream piping with gold stitches; creature's = dark thorn rim with rust accent (`owner='foe'` in `paint`).
- The icon (`ico-<type>-s.png` 20x20 at body offset (21,14); hand `ico-<type>.png` 32x32 at (37,9)) and number plate (strip 12x10 at (13,2); hand 14x12 at (21,3)) are baked into the piece image by `paint(..., icon_dir)`. Code prints a cream number over the dark plate.
- `board-demo.json`: example data: cells, owners, edge definitions and the list of open sockets (cell, side, kind, family). Use it as the data shape.

## Rules the art assumes (please confirm, they drive the code)
- A piece attaches only where a knob meets a hole of the same family (flat fits anything). The first piece goes in the centre.
- "Chain" = the connected group that the new connection joins. The effect depends on the connection (which type touches which, how many edges match). Show it by running the glow along the connected pieces in order and adding a chip to the history bar.
- The creature uses the same board and rules, its pieces appear with the foe rim.
- Do both players share one board? (the mockup assumes yes.)

## Not drawn yet (red)
creature sprites, player avatar (existing gnome art), map crop, `bar-frame`, `bar-fill-hurt`, `bar-fill-charm`, `intent-bubble`, combo stamps, chain-fire glow FX, open-socket marker (art version of the red circle), history chip frame, gold selection ring (CSS in mockup). The old `strip-rail` and `open-end` are replaced by the 2D board and the socket markers.

## Open questions for the code AI
1. Board size cap: the mockup shows 3x3 cells at 2x on a phone (372x264 css). Larger boards need panning or a smaller scale. Preferred: fixed small grid or pan.
2. Phone hand tray: strip-size pieces at 2x (3 per row) so what you hold is what you place; hand-size art only on the inspect card.
3. Wide breakpoint (suggest 760 css px).
4. Port `gen_shapes.py` to JS (A) or request the parts atlas (B)?
