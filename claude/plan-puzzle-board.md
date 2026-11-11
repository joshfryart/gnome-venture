# Puzzle Combat: the 2D board (rules, v1)

Replaces the strip with a shared jigsaw board. Engine: `game/includes/pfboard.php` (pure PHP, reuses tiles, decks, effects and RNG from `pfight.php`). Tests/sim: `tests/pfboard_sim.php`.
Status: engine and sim done. The screen (click/drag placement), the piece renderer and the page wiring are not yet.

## Rules (from Josh, plus defaults marked *)
- You click or drag each piece you want to play onto the board. **The board starts with one or two of the creature's pieces out** (one for small and medium, two for large and boss*; the gentlest, non-Hurt ones*).
- A piece goes next to a piece already on the board. Each touching edge must fit: **knob into hole of the same family**, or a **flat** edge (fits anything). All four edges of a piece are used (L, R, T, B).
- **When a piece connects, its chain fires newest first**: the piece you just placed plays, then the pieces linked to it, each one for its owner, until the chain ends.
- **A flat side breaks the chain and any combo across it.** (A joint is "linked" only when both edges are knob/hole.)
- Chain order with branches*: depth first from the new piece, newest piece first at each fork; each piece fires once per placement.
- A piece's combo needs the piece before it in the chain to be the same owner's*. A piece of the creature's that gets linked to still fires for the creature (so linking onto its Hurt can hurt you, and a flat side avoids it).
- You place up to 4 pieces a turn* (heavy pieces last); then the creature places 1 to 3*. Fit bonus is gone (every link fits); combos, upgrades and tactics (quick, pierce, poison, ...) work as before. Draw/steal/Lucky effects fire only for the piece just placed*.
- Board is 5x5*; pieces expire 2 rounds after they are placed* (back to the owner's discard). An empty board takes the next piece in the centre*.
- Resolve bar, Hurt/Charm, HP, Run, stall cap: unchanged. Resolve bar is x2.0 and creature piece values x0.8 in board mode (sim-tuned: small 3.0, medium 3.6, large 4.0, boss 7.2 turns; greedy bot defeat 1 to 5%).

## Still to build
1. Page wiring: setting `pfight_mode` (chain | board), `pfboard_do` POST (one POST per turn: a list of [hand index, x, y]), board view.
2. Screen: board grid, click-or-drag placement, ghost preview of legal cells, Undo (plans are local until End turn), End turn.
3. Piece renderer for four-sided pieces (art side: parts atlas, or port of `aseprite-source/pfight/layout/felt/gen4.py`).
4. Foe placement animation and per-chain history chips.
