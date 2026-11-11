# Puzzle Combat: the 2D board (rules, v1)

Replaces the strip with a shared jigsaw board. Engine: `game/includes/pfboard.php` (pure PHP, reuses tiles, decks, effects and RNG from `pfight.php`). Tests/sim: `tests/pfboard_sim.php`.
Status: engine, sim, page wiring and a working screen are done (setting `pfight_mode` = board; default stays chain). Pieces are drawn with CSS marks until the four-sided piece art lands.

## Rules (from Josh, plus defaults marked *)
- You click or drag each piece you want to play onto the board. **The board starts with one or two of the creature's pieces out** (one for small and medium, two for large and boss*; the gentlest, non-Hurt ones*).
- A piece goes next to a piece already on the board. Each touching edge must fit: **knob into hole of the same family**, or a **flat** edge (fits anything). All four edges of a piece are used (L, R, T, B).
- **When a piece connects, its chain fires newest first**: the piece you just placed plays, then the pieces linked to it, each one for its owner, until the chain ends.
- **A flat side breaks the chain and any combo across it.** (A joint is "linked" only when both edges are knob/hole.)
- Chain order with branches*: depth first from the new piece, newest piece first at each fork; each piece fires once per placement.
- A piece's combo needs the piece before it in the chain to be the same owner's*. A piece of the creature's that gets linked to still fires for the creature (so linking onto its Hurt can hurt you, and a flat side avoids it).
- You place up to 4 pieces a turn* (heavy pieces last); then the creature places 1 to 3*. Fit bonus is gone (every link fits); combos, upgrades and tactics (quick, pierce, poison, ...) work as before. Draw/steal/Lucky effects fire only for the piece just placed*.
- Board is a 7x5 lattice drawn as one open play area (no grid; only legal spots show)*; pieces expire 2 rounds after they are placed* (back to the owner's discard). An empty board takes the next piece in the centre*.
- Resolve bar, Hurt/Charm, HP, Run, stall cap: unchanged. Resolve bar is x2.0 and creature piece values x0.8 in board mode (sim-tuned: small 3.0, medium 3.6, large 4.0, boss 7.2 turns; greedy bot defeat 1 to 5%).

## Built
- `pfight_mode` setting; one POST per turn (`pfb_play` with moves "handIndex,x,y;..."), `pfb_pass` when nothing fits; stale/nonce/bad-move checks.
- `assets/pfboard.js`: click a piece then a lit cell, or drag; Undo; ghost pieces count for later placements; heavy ends the turn; legality matches PHP (`tests/pfboard_js.sh`, 400 random boards).
- Page test `tests/pfboard.sh` (plays whole fights over HTTP), browser check `tests/pfboardshot.js`.

## Also built (since)
- Real piece art from the art kit (`assets/img/pfight/parts/`): `assets/pfparts.js` composes pieces on canvas (base + side stamps, type colours, icon, number), per-creature rim tint, tag variant icons, joint marks, ghost spots, chain glow, chain-length stamps, expiring (hourglass) cue. Missing files fall back to CSS tiles.
- Layout C (status bar, one-line history, big zoomable board, fanned hand), fight drawn on the route map (`.advgrid.pfover`), zoom/pan (wheel, pinch, buttons).
- Tests: `tests/pfmap.sh` (random route + random creature, board and strip, phone and wide, plays until a chain shows glow and stamp).

## Also built (latest)
- Live effect preview: `pfb_preview` (read only dry run of the planned placements via `pfb_play(..., $dry)`), lines + resolve bar projection under the board; checked by `tests/pfboard.sh` (no state change, no draw pile or seed in the answer).
- The creature's new pieces land one by one (reduced motion: no animation); upgrade glyph badges on pieces; touch pinch/pan tested with real touch events in `tests/pfmap.js`.
- Gentle creatures: `PF_GENTLE_HM` = 0.8 (Hurt counts 80% on their bar, Charm 100%). A Hurt-only box against gentle creatures took ~17 turns at 0.5 and stalled; at 0.8 it is ~9-10 turns with no stalls, while a Charm box still wins in 2-4. (Sim: Hurt-only bots lose more often than mixed boxes against any creature; that is the bot, not the temper.)

## Still to build
1. Upgrade marks and rarity trim art (glyph badges stand in).
2. Balance with real players; creature pieces' edges per species; foes have no tactics of their own.
3. Treks still use the old fight.
