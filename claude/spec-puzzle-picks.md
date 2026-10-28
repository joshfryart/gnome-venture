# Puzzle picks spec (2026-10-28)

Builds on `claude/plan-puzzle-games.md`. Everything below uses its shared layer: `includes/puzzle_games.php` registry `PUZZLE_GAMES`, per-game gate `pz_<game>_open` (default 0), daily seed `crc32("pz|game|".game_day())` via PHP mulberry32, tables `puzzle_daily`, `puzzle_runs`, `puzzle_wins`, generic start/finish API, Jeff host, Wizard hint (+20s), Ffej lines. Do NOT reuse `puzzle_attempts`.

Trust rule for all: server builds puzzle, client never gets the answer (except where the client must simulate: noted per game). Finish = client sends moves, server replays and re-checks, own clock, min-time reject.

Picks: Simple S1 Lantern Lights Out, S2 Gnome Slide, S3 Word Scramble, S4 Hat Shuffle. Advanced A1 Sokoban Mines, A2 Gear Train, A3 Laser Mirrors, A4 Circuit Logic, A5 Chess + Checkers, A6 Cipher Vault. Site feature F1 Alchemy Mixing.

Sizes: S = small, M = medium, L = large. Suggested build order at end.

---

## Common per-game contract

Registry entry: `key, title, icon, blurb, kind (daily|practice|both), modes, gen(seed,level) -> puzzle, check(puzzle,moves) -> ok/score`.
- Daily: one puzzle, same for all, ranked by server time + hint penalty. One reward per game per day (first insert into `puzzle_wins` wins).
- Practice: random seed, unranked, no reward.
- Difficulty: `easy | normal | hard` per game, daily is `normal`; `hard` has its own daily.
- Hub card: replaces a "Coming soon" card when `pz_<game>_open=1`.
- Generator must prove solvability (and uniqueness where stated). Suite `tests/puzzles_<game>.sh` runs 200 seeds per level through gen + check, plus the shared trust tests from the plan.
- Phone first: tap targets >= 44px, no hover-only info, light + dark art, no inline script (CSP).
- Undo + reset on every game. Undo does not reduce score. Reset keeps the clock running.

---

## S1. Lantern Lights Out (S)

Grid of lanterns. Tap one: it and its 4 orthogonal neighbours flip. Goal: all dark.
- Sizes: easy 4x4, normal 5x5, hard 6x6 (6x6 and 7x7 have fewer solvable states; generate by scrambling from solved).
- Gen: start all-off, apply N random taps (N = 6 / 10 / 16), record as hidden solution, present result. Always solvable.
- Check: server XORs submitted tap list over the start grid via GF(2); must reach all-off. Order irrelevant, so client sends the tap set.
- Score: time + 5s per hint. Move count shown, not scored.
- Hint (Wizard): reveal one cell of a minimal solution (lowest-index tap still needed, computed server side by Gaussian elimination mod 2).
- Art: lantern on/off sprite pair, glow ring. Tap flips neighbours with a 120ms pulse.
- Edge: if grid has multiple solutions pick the one with fewest taps for hints.

## S2. Gnome Slide (S)

Sliding tile picture puzzle using a gnome image (reuse puzzle pic art; a static still, not the GIF).
- Sizes: easy 3x3, normal 4x4, hard 5x5. Optional "numbers on" toggle for accessibility.
- Gen: start solved, make 80 / 200 / 400 random legal blank moves, reject if solved or if inverse parity is wrong. Daily picks the picture from the seed too.
- Check: client sends the move list (blank direction per move), server replays from the start state and confirms solved. Cap list at 2000 moves.
- Score: time. Moves shown as secondary. Hint penalty +10s: highlight the next tile to move toward the goal (simple Manhattan-greedy step, not optimal).
- Controls: tap a tile next to the blank; swipe a row of tiles to slide several at once (counts as N moves).
- Edge: picture needs a visible blank corner marker; last tile slides in with a pop when solved.

## S3. Word Scramble (S)

Unscramble garden words.
- Word bank: file `includes/data/pz_words.txt`, one per line, `word|category|hint`. Draw from crops, flowers, tools, critters, regions already in game data plus a short common list. Lengths 4-8. Only words you would show a player; no obscure ones. Min 300 words at launch.
- Level: easy 4-5 letters, normal 5-6, hard 7-8. Round = 5 words; timer is total.
- Gen: pick 5 by seed, shuffle letters, re-shuffle if equal to the answer. Anagram issue: if scramble equals another valid bank word, accept either.
- Check: server compares typed answer (case-insensitive, trimmed) against the word and anagram set. Answer never sent to client; hash only used for nothing. Client sends guesses, server replies right/wrong per word via a call per word (round trip per word is fine; word list can be large).
- Hints: first letter reveal (+5s), category reveal (free, shown as a chip). Wizard hint reveals the next unknown letter (+10s).
- Score: round time + 3s per wrong guess + hints.
- Edge: rate-limit wrong guesses (shared `pzapi` limiter already exists); no dictionary brute-force path.

## S4. Hat Shuffle (S)

Follow the coin under the cups (hats).
- Rounds: easy 3 hats / 5 swaps, normal 4 / 8 / faster, hard 5 / 12 / fastest. Daily = 5 rounds, rising speed.
- Gen: server produces the full swap sequence per round up front from the seed. The coin start position and final answer are NOT sent. The client gets only the swap list and animates it.
- Cheat problem: the client animation reveals nothing if it never knows which hat has the coin. Show the coin lifted at the start via a one-off `reveal` token: client calls `reveal` -> server returns the starting hat index and stores that reveal time. Then the swap list animates locally. Client sends the final pick; server derives the answer from start + swaps. Reject any pick sooner than the animation length.
- Score: rounds correct first, then total time. Wrong pick ends the run (daily) or loses the round (practice).
- No timer pressure in the animation itself; speed is the difficulty.
- Accessibility: reduced-motion setting uses hat glow instead of fast motion, and doubles swap duration.

---

## A1. Sokoban Mines (M)

Push crates onto goal pads in a mine. Gnome pushes, never pulls. Extras: ore carts on rails (a cart on a rail tile only moves along it), one-way tracks, walls.
- Levels: curated pack file `includes/data/sokoban_levels.txt`, ASCII format (`#` wall, `.` goal, `$` crate, `@` gnome, `>` one-way east, `=` rail). Start with 30 levels sorted by par moves. Daily picks level by seed from a "daily-eligible" tag. Generation (random Sokoban) is not in v1: unsolvable levels are too easy to ship by accident.
- Level data is not secret (no answer stored, player solves it). Solvability proven offline by `tools/sokoban_solve.php` (BFS/IDA*) and the test asserts every level has a stored solution <= its par x 3.
- Check: client sends move string (`UDLR`), server replays and confirms all goals filled. Cap length 5000.
- Score: moves first, then time. Par shown; bronze/silver/gold at par x1.5 / x1.2 / x1.0.
- Controls: arrows / swipe / d-pad on phone. Undo unlimited. Level select shows stars.
- Edge: deadlock detector is a hint only (corner crate warning toggle, off in hard).
- Hint: reveal next 3 moves from the stored solution (+15s penalty).

## A2. Gear Train (M)

Place gears on pegs to carry power from a crank to a goal wheel at the required speed/direction.
- Model: pegs on a grid (fixed positions). A gear has a tooth count (e.g. 8, 12, 16, 24). Two gears on adjacent pegs mesh if center distance == (teeth_a + teeth_b) x module; meshed gears turn opposite directions with ratio teeth_a / teeth_b. A compound pair (two gears on the same peg) shares rotation.
- Goal: goal wheel turns at target RPM and direction while crank turns at 1 RPM. Some pegs blocked by rocks.
- Gen: build a chain on the grid from the seed (random walk of meshing gears), compute resulting ratio, hide chain, give the player a limited parts tray (the chain's gears plus 1-2 decoys) and the target ratio. Uniqueness NOT required; any valid train wins. Check is "does a valid train exist from crank to goal with the right ratio and no overlap", not "matches my chain".
- Check: server rebuilds the layout from the submitted placements, validates positions/meshing/no overlap, and computes ratio exactly using fractions (integers only, no floats). Reject non-integer positions.
- Score: time; bonus for fewer gears used (shown, not scored).
- Preview: client runs the simulation to animate; it is cosmetic. Server is the judge.
- Hint: place one correct gear from the hidden chain.
- Edge: jammed trains (odd cycle meshing directions) must be detected as impossible and flagged in the UI.

## A3. Laser Mirrors (M)

Redirect a beam to hit all crystals using mirrors, splitters, prisms.
- Pieces: `/` and `\` mirror, splitter (passes + 90-degree split), color filter, blocker. Beam colors red/green/blue: crystals need a specific color; splitters keep color; filters change/restrict.
- Board: 7x7 easy, 9x9 normal, 11x11 hard. Fixed emitters, fixed crystals, fixed walls. Player has a limited tray of pieces and places them on free cells.
- Gen: place emitter + crystals, then random-walk the beam placing mirrors to bend it through all crystals; record placed pieces as the hidden solution; give the tray = those pieces (shuffled) + 1 decoy at normal+. Reject if the beam loops infinitely or a piece is never touched.
- Check: server traces the submitted layout (grid walk, step cap 4x cells, detect loops) and confirms every crystal hit with its color. Any valid layout wins.
- Score: time + 5s per hint. Hint places one real piece.
- Art: beam drawn as a tinted line, crystal glows when lit.
- Edge: two beams crossing add color (red+green = yellow) is NOT in v1.

## A4. Circuit Logic (M)

Wire AND/OR/NOT (+ XOR at hard) gates so that the door lamp lights for the required input table.
- Setup: N input switches (2-4), a fixed truth-table target shown ("lamp on for these input combos"), a gate palette with limited counts, a grid with wire placement. Simplest v1: gate-node graph editor (drag gate, connect output to input), not a free-form wire grid.
- Gen: pick a random small circuit (depth 2-4), compute its truth table = the goal, give a palette sufficient to rebuild it (+ decoys). Many valid circuits per table.
- Check: server evaluates the submitted graph over all 2^N inputs and compares to the target table. Reject cycles. Reject unconnected inputs.
- Score: time; gate count shown; "minimal" badge if gates <= generator's circuit.
- Hint: place one gate from a known circuit.
- Levels: tutorial ladder of 6 hand-made intros (NOT, AND, OR, NAND, XOR, 3-input) before daily unlocks, tracked per user.

## A5. Chess + Checkers (L)

Two board games vs a computer, plus later vs another player. Not "puzzles" in the daily sense; shipped as two parts.

Part A: Tactics puzzles (puzzle section)
- Chess: "mate in N" and "win a piece" puzzles from a curated, offline-verified list (`includes/data/chess_tactics.txt`: `FEN | solution moves | theme | level`). Pieces use gnome art or standard glyphs. Start 150 puzzles (mate in 1, 2, 3; forks; pins).
- Checkers (English draughts, 8x8, forced capture, men + kings): "win in N" tactics, same file idea.
- Daily picks one tactic by seed. Check: server holds the line, client sends each move, server validates legality and replies with the opponent's scripted reply or "wrong". Any alternate mate-in-1 is also accepted for mate puzzles (server runs a legal-move search at depth <= N).
- Score: time + 10s per wrong move.

Part B: Full game vs AI
- Rules engine in PHP `includes/chess_rules.php` and `includes/checkers_rules.php`, pure functions on board arrays: `legal_moves($pos)`, `apply($pos,$move)`, `status($pos)`. Chess: all rules including castling, en passant, promotion, threefold, 50-move, stalemate. Checkers: forced capture, multi-jump, king promotion.
- AI: server side, no external engine. Levels: Easy (random + prefer captures), Normal (minimax depth 3 with alpha-beta, material + position), Hard (depth 5, iterative deepening, time cap 1.5s). Run in PHP per move request; cap CPU with a node limit.
- State: table `board_games(id,user,game,mode,fen,moves,status,created_at,updated_at)`. Server holds the position; client sends only a move; no client-side authority.
- Async only in v1. One active game per user per game type. Resign, offer draw (AI always declines unless lost), takeback (one per game, practice only).
- Reward: win vs Normal pays game_petals(10) once per day; Hard pays once per day extra. No energy cost.
- Vs player (later): invite a pal from `pals.php`, async turns, 3-day move timer, no ranking v1.
- Edge: the AI must never receive a position the rules engine thinks illegal; fuzz test: 1000 random-move playouts per game with `status()` asserts, plus known perft numbers for chess (depth 3 = 8902, depth 4 = 197281).
- Art: board and pieces in the felt/pixel style; light/dark board colors; last move highlight; legal-move dots on tap.

## A6. Cipher Vault (M)

Crack a coded message to open a vault.
- Ciphers by level: easy Caesar (shift 1-25), normal Atbash / simple substitution with 8 letters revealed, hard Vigenere (key 3-5 letters) with a crib (known word given).
- Plaintext: short gnome-flavored sentences from `includes/data/pz_cipher_lines.txt` (min 200). Daily picks by seed. Ciphertext sent to client; plaintext and key are NOT.
- Tools: frequency chart, letter-swap grid, "try shift" slider for Caesar. These are client-only helpers; no server cost.
- Check: client submits the full plaintext guess; server compares normalized (A-Z only, case/space/punct stripped). Wrong guess: server returns count of correct letters (not positions), limited to 10 guesses per run at hard.
- Score: time + 15s per hint. Hint reveals one plaintext word (position random).
- Scatter clue variant (later, not v1): clues scattered across the world map. Out of scope until a world-clue hook exists.

---

## F1. Alchemy Mixing: SITE FEATURE, NOT a puzzle-section game

Place: a new tab in the Satchel Craft area (`inventory.php?tab=craft&c=alchemy`) beside cooking/pantry/tools/garden, since recipes and ingredients already live there. Not under `puzzles.php`.

Idea: discover recipes by experiment. Combine 2-3 ingredients; known combos give a potion/dish/item, unknown combos teach a hint. A discovered recipe goes into the player's book and becomes repeatable through the normal craft flow.

Data
- `includes/data/alchemy.txt`: `slug | name | ingredients (item:qty, sorted) | makes (item:qty) | energy | tier | hint1 | hint2 | notes`. Ingredients reuse existing item slugs (crops, gatherables, creatures' drops). 60-80 recipes at launch; key = sorted ingredient multiset.
- `ensure_alchemy()` seeds table `alchemy_recipes` the same way `ensure_crafts()` does for `crafts.txt`. Edit text file, reload.
- `alchemy_known(user_id, recipe_id, first_at)`: discovered recipes.
- `alchemy_tries(user_id, combo_hash, count)`: log of failed combos so repeats are free and hints can escalate.

Flow
1. Player picks up to 3 ingredients from their stock (only items they have).
2. "Mix" costs energy (flat 2) and consumes the ingredients ONLY on success (a failed mix returns them, so experiments do not bankrupt a player). Failure still costs the energy so spam is limited.
3. Success: item(s) granted via `give_item`, recipe marked known, first time gives a one-off XP/petal reward and a milestone check. Repeats appear in the normal Craft tab with qty buttons.
4. Failure: server answers with one of: "nothing happens", "fizzles (close)", "one ingredient is right". The second and third are returned from comparing the combo with real recipes (overlap size), never the recipe itself.
5. Hints: after 3 failed mixes on a near recipe the Almanac adds a vague line (hint1), after 8 a second (hint2). Wizard sells an exact hint for petals.

Rules
- All mixing is server side. Client never receives the recipe table. Almanac shows only known entries plus silhouetted unknown slots (count visible, names hidden).
- Rate limit like the puzzle API (shared limiter).
- Recipes are deterministic. No randomness in outcomes in v1.
- Admin: `admin/alchemy.php` list/edit via existing `crud.php` pattern.
- Existing systems touched: `crafting.php` list, `almanac.php` (new section), `inventory.php` tab, `check_milestones`.

Tests: `tests/alchemy.sh` - known combo works and returns ingredients on fail, order of ingredients irrelevant, no duplicate rewards on repeat, stock check, energy check, near-miss feedback never leaks the answer, seed file has no duplicate keys and every ingredient slug exists.

---

## Build order (suggested)

1. 2.0.71 shared layer + S1 Lantern Lights Out (smallest rules, proves the daily/run/token flow; replaces Rain Barrel as first, or ships beside it).
2. S2 Gnome Slide, S3 Word Scramble, S4 Hat Shuffle (one release each or two together).
3. A1 Sokoban Mines (level pack + offline solver tool).
4. A3 Laser Mirrors, then A2 Gear Train, then A4 Circuit Logic (share a "piece tray on a grid" UI component).
5. A6 Cipher Vault.
6. A5 Chess/Checkers tactics, then full AI games (largest; own plan doc when started).
7. F1 Alchemy Mixing as its own release, independent of the puzzle work.

## Open questions for Joshua

- Rain Barrel / Gnome Beds / Snail Trail from the earlier plan: keep them ahead of these, or replace?
- Chess art: gnome-themed pieces (needs Aseprite pass) or standard glyphs first?
- Alchemy: should failed mixes cost energy (spec) or be free?
- Hat Shuffle: ranked daily with a one-miss end, or forgiving three-lives?
