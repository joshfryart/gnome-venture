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

## Changed in 2.6.63 (from the 2.6.60 playtest, `docs/puzzle-board-playtest-2.6.60.md`)
- **Creature start piece** is never Hurt: when its whole hand is Hurt, the top non-Hurt piece of its draw pile is swapped in (`pfb_anchor_pick`). It used to put a Hurt out (3% of starts, 50 creatures) and it fired in your first chain.
- **Multipliers:** hostile creatures take Charm x`PF_HOSTILE_CM` = 0.6 (was 0.4); gentle creatures take Hurt x`PF_GENTLE_HM` = 0.8, Charm x1. A boss's pieces count x`PFB_BOSS_MULT` = 1.2; a placed 3-piece group plays x1.5 (was 1.25). Charm wins also roll the species' seed and Gardening Guide drops (they used to skip them).
- **Blank-centre start (opt-in, harness only, `pfb_new(..., ['blank' => true])` + `pfb_start`):** a blank wild piece sits in the centre: a piece may connect to it (it fits every edge) but it fires nothing and **a chain never runs through it** (2.6.63, per Josh: before this a piece placed beside the blank chained across it into the other side's start piece); both sides put a start piece on one of its four sides, hidden; if they collide yours stays and the creature takes the next free side; the blank vanishes at the end of round 1 and its cell is an open site, start pieces keep nothing. The creature's pieces count x`PFB_BLANK_FOE_MULT` = 1.2 in this variant (a free start piece made it about half as costly as classic).
- **State notes** the engine now keeps for the replay and harness: `reshuf` (a draw pile was refilled from its discard), `cut` (linked pieces that did not fire because the fight ended mid-chain). `pfb_pass` refuses in the start phase.
- **Not done:** start pieces keeping their links after the blank leaves (you decided they become open sites); per-creature tuning of the slow outliers and the ~15 duplicate-deck groups (content authoring, listed in the playtest report).
- Tests: `tests/pfboard_fixes.php` (each fix watched failing on the 2.6.60 engine, passing now), `tests/pfboard_tune.php` (win / turns / HP lost by size, at the creature's level and 8 below, classic and blank).

## Fire budget (2.6.63, Josh's idea; prototype data in `docs/puzzle-board-proposals.md` P9)
- Every piece counts its firings (`f`; the placement is the first). A **creature** piece falls away (to the creature's discard) once it has fired `PFB_FOE_FIRES` = 2 times, after the chain that fired it has finished (never mid-chain, so a chain keeps its shape). Your pieces are not limited, they only expire after 3 rounds; the blank and start pieces (0 fires) are unaffected. The 3-round expiry still applies to everything. A chain visits each piece once, so a piece gains at most one firing per chain.
- To keep difficulty about where it was for good players the creature's piece values count `PFB_FOE_FIRE_MULT` = 1.15 more (weaker players gain a little: fewer re-fire cascades).
- Page: a creature piece on its last firing wears a small "x1" badge; the tap-info card says how many firings are left; pieces that fell away leave with the same animation as expired ones (`gone` entries carry `fell`). View field `fl` = firings left (null for your pieces). Harness: "fires left N" per creature piece and a FELL AWAY note.
- Tuning (`php tests/pfboard_tune.php 3`): at the creature's level HP lost medium/large 31%/29% to 24%/25%, turns +0.7; 8 levels under about +5 points. Tests: `tests/pfboard_fixes.php` (falls away after the 2nd firing, not mid-chain, goes to discard, your pieces unlimited, view `fl`).
- Knobs for "some stick longer" (not built): a per-tile or per-boss extra firing, e.g. creature guard/Hold pieces and boss pieces at 3.

## Changed in 2.6.66
- **Blank-centre opening is the live default** for new board fights (setting `pfight_blank`, default on; `0` = the classic opening). Page: the board shows the blank in the middle, the four lit spots are its sides, the button reads "Confirm start", no preview, no set-aside. `pfight_do` turns a posted `i,x,y` next to the blank into `pfb_start` (any other spot is refused); the history bar shows a note of what each side put down. `PFB_BLANK_FOE_MULT` = 1.0 (was 1.2).
- **Set aside braces you:** join/add gives guard = the value of the piece just set aside (`PFB_SETASIDE_GUARD` = 1.0); a placed 3-piece group plays x2.0 (`PFB_GROUP_MULT[3]`).
- **Numbers on lit spots** (proposal P1 A4): `pfb_cell_preview($s, $handIdx|'c')` plays each legal cell on a copy and returns damage, charm, own-chain health cost, pieces that fire, the creature's reply and whether the fight ends; POST `pfb_cells` (nonce, turn, `i`) answers JSON; the page decorates lit cells (`.pfb-num`, red when it costs health); `tests/pf_play.php show` prints `(d.. c.. h-.. n.. r-..)` per cell.
- Not built: P1 A3 (creature Hurt fired by your chain at x0.5), P5, P7 clarity items, JS-port cell numbers (demo shows no numbers).
