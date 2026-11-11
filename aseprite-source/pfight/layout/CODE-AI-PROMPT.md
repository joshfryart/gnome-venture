# Prompt for the code AI: Puzzle Combat fight screen, new layout and art

Repo `joshfryart/gnome-venture`, branch `ccr-dea0abf9-eaakqa`. Base URL for links: https://github.com/joshfryart/gnome-venture/blob/ccr-dea0abf9-eaakqa/

You own the PHP/JS/CSS. The art side (me) only delivers PNGs and mockups. Please rebuild the Puzzle Combat fight screen to match the mockup below and wire in the new art. Missing art files must fall back to what exists today (emoji / CSS), never break the screen.

## Look at these first
- Layout mockup (Josh's own sketch): `aseprite-source/pfight/layout/mockup2-wide.png` (landscape) and `mockup2-phone.png` (phone portrait). Live HTML: `aseprite-source/pfight/layout/mockup2.html`. Red outlines = art not drawn yet (size is printed in the box). Red circles = open sockets. Numbers match the list below.
- Piece art sheet (felt style, final): `aseprite-source/pfight/layout/felt/sheet.png` (+ `sheet-gray.png`, `sheet-cb.png` colour-blind checks).
- Board data shape and pieces: `aseprite-source/pfight/layout/felt/board-demo.png` + `board-demo.json`, `tray-demo-0..3.png`, `inspect-demo.png`.
- Piece renderer: `aseprite-source/pfight/layout/felt/gen4.py` (`render(type, size, edges, owner)`). Older full spec: `aseprite-source/pfight/layout/SPEC.md` (v2, rules section still applies; zone numbering below replaces it).
- Existing delivered art: `game/assets/img/pfight/` (`ico-<type>.png` 32x32, `ico-<type>-s.png` 20x20 etc., README.md).

## What changed in the design
The board is now a **shared 2D jigsaw**. Players attach pieces **one at a time** to an open edge of a piece already on the board (knob meets hole of the same family; flat edge fits anything). Pieces can branch in all four directions. **When a piece connects, its chain (if any) activates**; the effect depends on where and to what it connects. The creature plays on the same board with the same rules. Every connection adds a chip to the history bar. Old 1D strip (left hole, right knob) is gone.

## Screen zones (numbers from Josh's sketch)
1. **Route map**: the map screen where the fight began, full-screen background behind everything (dark scrim for readability).
2. **Player**: 2.5D sprite, left side, with name.
3. **Enemy**: sprite, right side, with name and an intent bubble (28x24, type icon of its next move).
4. **Play board**: large centre area, the 2D puzzle. Show open-socket markers only for sockets the selected piece fits. Newly placed piece gets a glow while its chain resolves.
5. **History bar**: top, overlays the map, horizontally scrolling chips (YOU solid border, FOE dashed), each with the type icons (`ico-<type>-s.png`) of the chain that fired and the result text. Newest at the right.
6. **Hand**: bottom centre, pieces at board (strip) size, 2x, swipe sideways, selected piece ringed. Tap to inspect (hand-size card, `inspect-demo.png` shows it).
7. **Discard**: bottom right, small (about 80x80 landscape, 52x52 phone), icon + count.
8. **Puzzle book (deck)**: bottom left, small, same size as discard, icon + count.
Added by me, not in the sketch (remove if unwanted): shared resolve bar (96x12 frame, Hurt/Charm fills from both ends), Undo and End turn buttons, intent bubble, combo stamp pop (32x32).

Landscape (about 960x620 css) is as sketched. Phone portrait (412 wide) stacks: history, player | enemy, board, buttons, then deck | hand | discard. Suggested breakpoint 760 css px.

## Piece art: how to draw pieces (important)
- A piece = a type body with four edges `L R T B`; each edge is `flat`, `knob:<family>` or `hole:<family>`. Families: `body` (round tab), `mind` (keyhole), `craft` (triangle). Holes are transparent cutouts, so pieces cannot be fixed rectangles.
- Too many combinations to ship as files (7 types x 7^4 edges x owner x size). **Render at runtime**: port `felt/gen4.py` (`render`) to a JS canvas, cache per (type, edges, owner, size), draw with `image-rendering: pixelated` at integer scale 2x. Output is pixel-identical to the PNGs in `felt/`. If porting is not wanted, tell me and I will deliver a parts atlas.
- Sizes: strip piece image 74x52 (body 56x40, tabs 9 left/right, 6 top/bottom, body at (9,6)); hand piece image 132x92 (body 96x68, tabs 18 / 12, body at (18,12)). Place on a grid at body pitch (56x40 strip, 96x68 hand) so a knob sits in the neighbour hole; snapped seams show a 2px ink line (one from each piece).
- Owner `me` = cream piping with gold stitches; owner `foe` = dark thorn rim with rust. Never tint-only, shape differs too.
- Icon (strip 20x20 at body offset (21,14)+body origin; hand 32x32 at (37,13)) and number plate (strip 12x10 at (5,2); hand 14x12 at (21,3)) are baked into the piece. The code prints the number over the plate in **dark ink**. Hand-size name ribbon area at (24,46) 58x9: code prints the name.
- Data example: `board-demo.json` (`pitch`, `pad_x`, `pad_y`, `cells`, `open_sockets`).

## Colour-blind rule
Type = colour + fill pattern + icon; family = shape; mine vs foe = rim shape. Do not add colour-only cues.

## Please confirm or decide
1. Do both players share one board (assumed yes)? Is the first piece placed in the centre?
2. Chain rule: what exactly counts as "its chain" when a piece connects, and how is the effect decided? I need the final rules to finish the glow and the history chip text.
3. Board size cap: mockup shows 3x3 cells (372x264 css at 2x). Larger boards need pan/zoom or a smaller scale.
4. Port `gen4.py` to JS, or do you want a parts atlas?
5. Hand piece on phone shows at strip size; hand-size art only on the inspect card. OK?

## Not drawn yet (red in the mockup)
creature sprites, player 2.5D sprite (existing gnome art may be reused), route-map crop, resolve bar frame and fills, intent bubble, combo stamps, chain glow FX, open-socket marker art, deck and discard icons, history chip frame.
