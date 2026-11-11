# Puzzle Combat fight screen: layout spec (for the code AI)

Files: `mockup.html` (live), `mockup-phone.png`, `mockup-wide.png`. Regenerate with `python3 make_mockup.py > mockup.html`.
Red outline in the mockup = placeholder art not drawn yet (size given). Solid = real art in `game/assets/img/pfight/`.
All art is native pixel art shown at 2x with `image-rendering: pixelated`. Phone = 412 css px wide = 206 art px.

## Idea
The fight is played ON TOP of the world map screen the player was on when the fight started. The map is the background of the whole fight screen. Player on one side, creature on the other, a shared board in the middle where tiles (jigsaw pieces) snap together in a chain, and a history bar across the top that keeps the log of past turns. Phone portrait: creature top-right, board middle, player bottom-left, hand tray at the bottom. Wide screen: player left, creature right, board middle, hand under the board.

## Layers, bottom to top (z-order)
1. **Map background** (1): the map view where the fight began, cropped to the screen. Static, no interaction. Needs a dark scrim so UI is readable (CSS, solid, not drawn art).
2. **Creature** (3) with name plate, **intent bubble** (4) showing the type icon `ico-<type>-s.png` (20x20) of what it will do next. **Player avatar** (8) with name.
3. **Shared resolve bar** (5): `bar-frame.png` 96x12 with two fills growing from both sides: Hurt (slashes) from one end, Charm (flowers) from the other. Fills `bar-fill-hurt.png` and `bar-fill-charm.png` are 92x8.
4. **Board** (7): one horizontal rail `strip-rail.png` (24 high, tiles horizontally). Played pieces sit on it as strip pieces at 2x (pitch 112 css px). Mine have the cream stitched edge, the creature's the dark thorn edge. The rail scrolls horizontally and auto-scrolls to the **open end** (6): `open-end.png` 24x24 marker where the next piece goes. A chain is 1 to 4 pieces per side.
5. **Combo stamp** (9): `combo-<name>.png` 32x32 pops over the board when a combo fires, then fades.
6. **Hand tray** (10): hand pieces at 2x, horizontally scrollable. One selected piece is "picked" (raised): draw `frame-picked-hand.png` behind it and lift it. Value number is printed by code over the dark plate; name is printed by code on the line near the bottom.
7. **History bar** (2): fixed at top, overlays the map. Horizontally scrollable chips, newest at the right, auto-scroll to newest. Each chip = who (YOU solid cream border, FOE dashed border) + the type icons played (`ico-<type>-s.png`, 20x20) + the result text. Tapping a chip may open a details popover.
8. **Buttons**: Play chain, Undo last tile, Pass (code, CSS).

## How a piece is assembled (already delivered)
- Strip piece (board): `piece-strip-<type>-<holefam>-<knobfam>.png` (65x40) + `ico-<type>-s.png` at (21,14) + `edge-strip-<me|foe>-<holefam>-<knobfam>.png`.
- Hand piece: `piece-hand-<type>-<holefam>-<knobfam>.png` (114x68) + `ico-<type>.png` at (37,9) + `edge-hand-me-...` ; number at (21,3) 14x12 on the dark plate, cream text.
- Families: body, mind, craft, flat (wild). Hole is on the left, knob on the right. Snap pitch: next strip piece x + 56, hand piece x + 96 (art px). A knob fits a hole of the same family; flat fits anything.
- The code must draw pieces with `image-rendering: pixelated` and integer scale.

## Real jigsaw shapes (art pass)
`game/assets/img/pfight/shapes-assembled-<hand|strip>.png` and `shapes-exploded-<hand|strip>.png` show true four-sided pieces (tab or blank on every edge, corners and edges flat). The current game only needs left hole and right knob. If the board ever grows into a 2D puzzle, these shapes are ready: generator `aseprite-source/pfight/gen_shapes.py` can write any `L/R/T/B` combination.

## Not drawn yet (red in the mockup)
creature sprites, player avatar (existing gnome art), map crop, `strip-rail`, `open-end`, `intent-bubble`, `bar-frame`, `bar-fill-hurt`, `bar-fill-charm`, combo stamps, history chips (CSS in the mockup; may want a small drawn chip frame).

## Open questions for the code AI
1. Phone hand tray: two 2x hand pieces do not fit side by side (each 228 css px with its knob). Horizontal scroll (shown) or 1.5x? Prefer integer scaling.
2. Board: horizontal scroll rail (shown) versus wrapping onto two rows. Wrapping breaks the snap read, so scroll is preferred.
3. History bar height 60 css px; should it collapse while the player is placing tiles?
4. Wide layout breakpoint (suggest 760 css px).
