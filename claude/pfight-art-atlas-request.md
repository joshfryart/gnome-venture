# Request to the art AI: parts atlas for the four-sided board pieces

Code side decision: **we want option B, a parts atlas** (not a port of `gen4.py`; it is 865 lines of numpy and the output must stay identical to your PNGs).
The board pieces are drawn by the browser (canvas) from parts, so every type/edge/owner combination works without shipping thousands of files.

## What we need
All PNGs transparent, hard pixels, strip size (body 56x40, tab depth 9 left/right and 6 top/bottom, so an assembled piece is 74x52 with the body at (9,6)), plus the same at hand size (body 96x68, tabs 18/12, piece 132x92) for the inspect card.
Per **owner** (`me`, `foe`) and size:
1. `body-<type>.png`: the body of each of the 7 types (hurt guard heal charm soothe trick item) as a full rectangle WITHOUT any sockets, with pattern, number plate and the owner rim, drawn so that a socket can be cut or added on any side. Icon baked in or separate `ico-<type>-s.png` (say which).
2. `cut-<family>-<side>.png`: a mask the exact shape of a HOLE for family body/mind/craft on each side L R T B, to be erased from the body (destination-out), including the rim/ring around the hole.
3. `knob-<family>-<side>.png`: the KNOB for each family and side (the shape that sticks out), drawn in the owner's rim style with the body colour inside, to be drawn over the neighbouring margin.
4. `flat-<side>.png` if a flat edge needs its own rim piece (or tell us a flat edge is just the plain body).
5. A JSON `atlas.json` listing each file, its size and the draw offset (x, y) relative to the body origin per side, plus the draw ORDER (body, then cut holes, then knobs, then icon, then number plate).
6. One worked example: a PNG of a hurt/me piece with edges L=hole:body, R=knob:mind, T=flat, B=hole:craft, built from your parts by following atlas.json, so we can check our canvas output pixel for pixel against it.

## Rules the code uses (from claude/plan-puzzle-board.md)
Edges per piece are `flat`, `knob:<family>` or `hole:<family>`, families body (round), mind (keyhole), craft (triangle). Pieces sit on a grid at body pitch so a knob lands in the neighbour hole. Both owners' pieces appear on one board; owner is shown by rim shape (cream stitched vs thorny), never by tint alone. Hand-size art is only used on the inspect card; the hand itself shows strip-size pieces at 2x.

## Also still wanted (from the layout brief)
resolve bar frame and fills, intent bubble, combo stamps, chain glow FX, open-socket marker, history chip frame, deck and discard icons (`ico-deck.png`, `ico-discard.png` 32x32; the code already looks for these names and falls back to emoji).
