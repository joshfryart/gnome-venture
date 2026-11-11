# Puzzle Combat piece parts (felt style)

Exact: composing from these parts equals the art renderer (`aseprite-source/pfight/layout/felt/gen4.py`) pixel for pixel.
Checked on 10,000 random (type, edges, owner, size) pieces + both board demos. Reference compositor: `felt/gen_parts.py`
(`compose_index` + `recolour`). Stitch phase is now positional, so it never depends on other edges.

## Sizes (final)
| | piece image | body | tabs L/R, T/B | pitch | body at | plate | icon |
|---|---|---|---|---|---|---|---|
| strip | 74x52 | 56x40 | 9, 6 | 56x40 | (9,6) | (14,8) 12x10 | (30,19) 20x20 |
| hand | 132x92 | 96x68 | 18, 12 | 96x68 | (18,12) | (39,15) 14x12 | (55,25) 32x32 |
Offsets above are in PIECE IMAGE coords (origin top-left of the image). Place piece at (col*pitchX, row*pitchY).
Tabs are outside the body. Neighbours overlap by the tab width. Holes are transparent, a knob fills it exactly,
so opaque pixels of two pieces never overlap (checked): draw order does not matter, draw by id.

## Files
- `parts-<size>-<owner>.png` (size strip|hand, owner me|foe): index sheet, 5 cols, cell = piece image size.
  Cell 0 = BASE (body, all four edges flat, incl. rim, thorns, number plate, name ribbon). Cells 1..24 = STAMPS.
  `atlas.json` -> `sheets.<size>-<owner>.stamps["L:hole:body"]` = {col,row,x,y,bbox}. Keys: side L|R|T|B : knob|hole : body|mind|craft. Flat = no stamp.
- `patterns-<size>.png`: 7 cells (order in atlas): R=255 where the type MARK colour goes, else BASE.
- `icons-<size>.png`: 7 cells, real RGBA icons (hand 32x32, strip 20x20), draw at the icon offset above.
- `rim.json`: role ids, exact RGB, palettes `default` and `old`.
- `atlas.json`: sizes, offsets, sheets, type palettes (base/mark/light/shade), erase value.
- `extras.json` + extras PNGs (below). `example/`: worked piece and board demos.

## Index format
Pixel = (R=role id, G=0, B=0, A=255). A=0 = transparent (in BASE) or unchanged (in a stamp).
In a stamp, R=255 = ERASE (set to transparent). That is the hole cutter and the knob in one: a HOLE stamp erases the
body pixels and recolours the rim around the cut; a KNOB stamp adds the knob pixels and rim. Nothing is "subtracted
from alpha": stamps are already final pixels. No separate flat-edge part: flat = the BASE.

## Roles (rim.json has RGB)
1 INK outline (and plate border). 2 RIM_ME cream piping. 3 STITCH_ME gold stitch. 4 RIM_FOE rust ring. 5 BAND_FOE maroon band.
6 STITCH_FOE. 7 THORN_TIP. 8 THORN_BODY. 9 PLATE (cream number plate and ribbon: LEAVE EMPTY, draw the number in INK #2a1a10).
10 PLATE_SHADE. 11 FILL (type: MARK where pattern mask = 1 else BASE). 12 SHADE (type). 13 LIGHT (type). 14 TYPE_BASE (ribbon end caps, always BASE).
Rim roles 1-10 do not depend on type. Tint a creature by changing roles 4-8. "Old": use `palettes.old` (dimmed). Old needs a
second cue in code (counter, dashed ghost): never colour only. Ring checker phase is baked into the stamps.

## Compose a piece (JS)
```
img = copy(BASE[size][owner])                       // Uint8 R-channel + alpha
for side of L,R,T,B: if edge.kind != 'flat': for each stamp px with A>0: R==255 ? clear : img = R
colour: role 11 -> pattern[type][px] ? mark : base; 12 -> shade; 13 -> light; 14 -> base; 1..10 -> rim palette
icon: draw icons-<size> cell at icon offset where the index px is non-zero (alpha>0)
number: print in INK centred on the plate. Name (hand only): print inside the ribbon rect (below)
```
Hand ribbon in piece coords: at (42,58) size 58x9. Cache per (type, size, owner, edges, palette).

## Worked example (`example/`)
`strip-foe-trick-part-*.png` (4x): base + the 4 stamps (L hole mind, R knob body, T hole craft, B hole mind);
`strip-foe-trick-index.png` composed index (R channel), `strip-foe-trick-final.png` final colours (= expected pixels).
`board-demo.png` 3x3 strip board, `board-demo-hand.png` 2x2 hand board, `board-demo-pieces.json` types/owners/edges,
`board-demo.json` open sockets. Diff your canvas against these. Board canvas = cols*pitchX + 2*tabX by rows*pitchY + 2*tabY, piece (c,r) drawn at (c*pitchX, r*pitchY).

## Extras (hard pixels, felt style)
- `deck-book.png`, `discard-bin.png` 32x32.
- `joint-h.png` 22x14 (centre on a vertical seam), `joint-v.png` 14x22 (centre on a horizontal seam). Linked knob/hole joint only; flat contact: draw nothing.
- `chain-glow-h.png` / `-v.png`: 4 frames of 64x8 (8x64), stacked, tile along the long axis, period 8, ~8 fps. Place over the linked seam.
- Ghost (lit legal spot): piece-shaped outline, built in code from the candidate piece alpha. Rule: outline px = opaque px with a 4-neighbour transparent; colour GOLD (#e8a317) if (x+y)%4<2 else CREAM (#f2e4c0). `ghost-demo-strip.png` shows it.
- `resolve-frame.png` 96x12 (transparent window at (3,3) 90x6, centre mark at x=47), `resolve-fill-hurt.png` / `-charm.png` 90x6 (stripes vs dots, clip by width, Hurt anchored left, Charm right).
- `intent-bubble.png` 28x24, draw the 20x20 type icon at (4,1).
- `combo-stamp-small.png` (combo 2-3), `combo-stamp-big.png` (4+), 32x32, number plate (10,11) 12x10 left empty.
- `chip-me.png` / `chip-foe.png` 24x24, 9-slice margin 5 (solid vs dashed border).
- `extras-preview.png` is a 3x preview only.

## Update 2
- `combo-badge-small.png` (pill, 2-3) / `combo-badge-big.png` (swallowtail, 4+): flat 24x14, number plate (6,3) 12x8 empty. Replace the star stamps (kept, deprecated).
- `chain-glow-start-h|v.png` 12x8 / 8x12 = NEWEST end (bead); `chain-glow-end-h|v.png` = OLDEST end (arrowhead). Body `chain-glow-h|v.png` keeps tiling, animation runs start to end.
  Draw left to right (h) or top to bottom (v); mirror in code for the other direction.
- `expiring-badge.png` 10x10 hourglass (shape is the cue), put it on a piece corner.
- Strip plate at 1.5x: non-integer scale breaks hard pixels (uneven 1/2 px). Use 1x or 2x, or draw the number after scaling.
