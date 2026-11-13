# v47 puzzle pieces: 56x47 jigsaw, new Aseprite pixel art
Hard pixels, no alpha blends (check.py verifies). Nothing outside this folder was changed.

## Sizes (piece image = body + tab on all four sides; pitch = body size)
| | body | tab | image | body at | pitch | corner r | glyph (with 1 px outline) |
|---|---|---|---|---|---|---|---|
| strip | 56x47 | 13 | 82x73 | (13,13) | 56x47 | 5 | 18x19 at body (19,14), centre (27.5, 23) |
| hand | 96x80 | 22 | 140x124 | (22,22) | 96x80 | 8 | 32x32 at body (32,24), centre (47.5, 39.5) |
Hand body is even x even, so its glyph and all tabs are even (an odd glyph cannot be centred on 80). Strip: top/bottom tabs are even
wide (12/16/18 px), left/right tabs odd (11/17/17), each centred on its side. Tabs end 1 px short of the glyph row (rim included).
Slots left empty for the game (body coords, strip): plate 16x12 at (3,3), owner badge 11x11 at (42,3), star/flip 11x11 at (42,33), pips from (4,40).

## Files (strip/ and hand/, each .aseprite + .png)
tile-<size>-<hurt|guard|heal|charm|soothe|trick|item> (layers base, grain, shade, light, stitch, glyph, rim; 5-tone ramp hi/light/base/shade/deep, rim tinted by type) | sock-<size>-<body|mind|craft>-<knob|hole>
frame-<size>-<me|foe|env> | overlay-<size>-<picked|faded|now> | badge-<size>-<lock|star|flip|eye|land> (11x11 / 18x18).
Also: scripts/ (Lua, run.sh, check.py, make_sheet.py, check-output.txt), contact-sheet.html (+ sheet/), compare-today-vs-new.html,
board-cluster-strip.png, board-cluster-hand.png, history/ (pass0-jigsaw, pass1-puzzle, pass2-rich, compare sheet PNGs).
Pass 3 polish sheet = history/pass3-polish.png. Grain: sparse 1 px dots, 2.4% of body pixels, never near glyph, plate, badges, pips, stitch.
Sock files hold all four sides in one image (layers top/right/bottom/left); crop one side with the rectangles in scripts/pv47.py `region()`.
Knob = pixels to stamp (dark outline + family fill + the junction row on the body edge). Hole = ring pixels (1 px dark, 1 px family colour)
plus the cut-out marked with pure magenta #ff00ff (= ERASE: set transparent). Stamp order: tile, frame, socks. `pv47.piece()` does exactly this.
Tab shapes: Body = neck + round head (red), Mind = keyhole (purple), Craft = blunt wedge (gold). A knob fills the hole exactly (verified).
Overlays: picked = hue-shifted gold gradient ring (3 px strip, 4 px hand) + dark edge, draw UNDER the piece; now = glow ring + sparkles, UNDER; faded = 50% stipple veil
(no semi-transparency is allowed), OVER the piece; desaturate the tile in code. Env body: map type base/light/shade to greys (see pv47.piece).

## Run
`SC=<dir containing ase.sh> scripts/run.sh` = draw all (Aseprite batch), build sheets, run check.py.

## What the game code needs (not done here)
- atlas.json / gen_parts.py: new sizes (piece 82x73 and 140x124, body at 13 / 22, pitch 56x47 / 96x80), tab depth 13 / 22 on all sides.
- Replace the single index-sheet pipeline: tiles are final colours, not role indices; compose = tile, frame (foe/env), socks, then draw plate, number,
  pips and badges at the slots above. Types no longer use pattern masks (patterns-*.png and the icon strips are unused).
- Sockets: keys become side:knob|hole:body|mind|craft with the sock crops; edge widths differ top/bottom vs left/right.
- Recolour for env and faded in code; picked/now rings are overlays drawn under the piece; ghost outline rule is unchanged.
- Foe thorns only sit on the top/bottom edge, outside the socket mouths.
