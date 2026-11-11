# Puzzle Combat: the 2D board (rules, v1)

Replaces the strip with a shared jigsaw board. Engine: `game/includes/pfboard.php` (pure PHP, reuses tiles, decks, effects and RNG from `pfight.php`). Tests/sim: `tests/pfboard_sim.php`.
Status: engine, sim, page wiring and a working screen are done (setting `pfight_mode` = board; default stays chain). Pieces are drawn with CSS marks until the four-sided piece art lands.

## Rules (from Josh, plus defaults marked *)
- You click or drag each piece you want to play onto the board. **The board starts with one or two of the creature's pieces out** (one piece; two only for bosses*; the gentlest, non-Hurt ones*).
- A piece goes next to a piece already on the board. Each touching edge must fit: **knob into hole of the same family**, or a **flat** edge (fits anything). All four edges of a piece are used (L, R, T, B).
- **When a piece connects, its chain fires newest first**: the piece you just placed plays, then the pieces linked to it, each one for its owner, until the chain ends.
- **A flat side breaks the chain and any combo across it.** (A joint is "linked" only when both edges are knob/hole.)
- Chain order with branches*: depth first from the new piece, newest piece first at each fork; each piece fires once per placement.
- A piece's combo needs the piece before it in the chain to be the same owner's*. A piece of the creature's that gets linked to still fires for the creature (so linking onto its Hurt can hurt you, and a flat side avoids it).
- **One action a turn** (changed from up to 4 pieces): place one hand piece, OR place the group you set aside, OR **Connect**: set two hand pieces aside joined (a knob in a matching hole; they must link so the chain runs), no effect that turn. Next turn you may add ONE more piece to the group (max 3; a group of three takes no more), play a single piece, or play the group. A placed 3-piece group plays at x1.25 (`PFB_GROUP_MULT`). The group's newest piece starts the chain. One group at a time. The creature puts down exactly 1 piece a turn (only the chain that piece makes fires); Trip/Lull make it skip.
- Board is a 7x5 lattice drawn as one open play area (no grid; only legal spots show)*; pieces expire after 3 rounds (`PFB_LIFE`)*. An empty board takes the next piece in the centre*.
- Resolve bar x0.7 and creature piece values x0.62 in board mode (sim, one action a turn: small 3.2, medium 4.1, large 4.5, boss 6.1 turns; defeats about 1%; a bot that builds groups is a little faster than one that never does).

## Built
- `pfight_mode` setting; one POST per turn (`pfb_play` with moves "handIndex,x,y;..."), `pfb_pass` when nothing fits; stale/nonce/bad-move checks.
- `assets/pfboard.js`: click a piece then a lit cell, or drag; Undo; ghost pieces count for later placements; heavy ends the turn; legality matches PHP (`tests/pfboard_js.sh`, 400 random boards).
- Page test `tests/pfboard.sh` (plays whole fights over HTTP), browser checks `tests/pfmap.js` (via `tests/pfmap.sh`).

## Also built (since)
- Real piece art from the art kit (`assets/img/pfight/parts/`): `assets/pfparts.js` composes pieces on canvas (base + side stamps, type colours, icon, number), per-creature rim tint, tag variant icons, joint marks, ghost spots, chain glow, chain-length stamps, expiring (hourglass) cue. Missing files fall back to CSS tiles.
- Layout C (status bar, one-line history, big zoomable board, fanned hand), fight drawn on the route map (`.advgrid.pfover`), zoom/pan (wheel, pinch, buttons).
- Tests: `tests/pfmap.sh` (random route + random creature, board and strip, phone and wide, plays until a chain shows glow and stamp).

## Replay and info (2.6.55)
- After a turn the page plays it back one scored piece at a time: the piece lights up and its card opens, its line is listed, the resolve bar and your health move to what they were after it (`enc['replay']`, `enc['replay0']`; Skip ends it; once per browser session per turn).
- Tap any piece on the board for its card: name, owner, value, tag and upgrade text, and how many rounds it has left.

## Also built (latest)
- Live effect preview: `pfb_preview` (read only dry run of the planned placements via `pfb_play(..., $dry)`), lines + resolve bar projection under the board; checked by `tests/pfboard.sh` (no state change, no draw pile or seed in the answer).
- The creature's new pieces land one by one (reduced motion: no animation); upgrade glyph badges on pieces; touch pinch/pan tested with real touch events in `tests/pfmap.js`.
- Gentle creatures: `PF_GENTLE_HM` = 0.8 (Hurt counts 80% on their bar, Charm 100%). A Hurt-only box against gentle creatures took ~17 turns at 0.5 and stalled; at 0.8 it is ~9-10 turns with no stalls, while a Charm box still wins in 2-4. (Sim: Hurt-only bots lose more often than mixed boxes against any creature; that is the bot, not the temper.)

## Changed since (2.6.58 to 2.6.60)
- **Connect rule:** a placement must make a linked joint (knob in a matching hole) unless nothing in hand/group can; the creature follows it (`pfb_must_link`).
- **Two goals:** Hurt lowers the creature's health (`$s['fh']`, red bar); the pink bar (`$s['bar']`) is Charm only; bosses have no charm bar (`cm` = 0). Chips read `-N hp` / `+N charm`.
- **Turn order on screen:** the creature's piece enters after yours resolves; each side's whole chain resolves before the other's turn (events carry `ta`, replay groups by it); turn banner shows, holds, fades, then play. The creature's pieces placed this turn are flagged `fnew` and held back until the replay reaches them.
- Guard resets at the start of your turn (`pfb_end_round`); creature starts with one piece (boss two).
- Set-aside group is a row under the board; the info pop-up piece is smaller; no stage banner or About fold above/below the panel.
- Shareable demo: `tools/pfengine.js` (JS port, parity test `tests/pfengine_js.sh`), `tools/build_pf_artifact.py`, `tools/pfartifact/`.

## Still to build
1. Upgrade marks and rarity trim art (glyph badges stand in).
2. Balance with real players; creature pieces' edges per species; foes have no tactics of their own.
3. Treks still use the old fight.
