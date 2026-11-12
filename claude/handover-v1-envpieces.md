# v1 environment pieces, stage E1 handover (2.6.75 build; engine, data, sims; no UI)

Stage E1 replaced the v1 fight's ground cells and forecast events with ENVIRONMENT PIECES (Josh's decision after testing 2.6.74: `claude/design-board-strategy.md`, last DECIDED block). Behind the admin setting `pfight_v1` as before. Not done here (stage E2): the page UI (`pfboardv1.js`, `pfv1.css`, help texts), version bump, changelog, zip. Version is still 2.6.74 + the 2.6.75 UI fixes.

Rules text, numbers and red flags: `claude/design-board-strategy.md`, "Sim 5: environment pieces". Earlier stages: `handover-v1-stageA.md` (board rules), `-stageB.md` (data, decks), `-stageC.md` (UI).

## The marker: which fights have environment pieces
- A fight's rule numbers live in `$s['v1']`. **`$s['v1']['env']` = 1** means environment pieces. `pfb_v1_cfg` now defaults to `env 1, ground 0, events 0`.
- **A fight started under 2.6.74** has `$s['v1']` without `env` (and with `ground 1, events 1`): it keeps its ground cells, its forecast and its terrain turn to the end, with the creature numbers stored in its state. All the 2.6.74 code paths are still there (`pfb_seed_ground`, `pfb_forecast`, `pfb_env_turn`, mud and sunny checks) and are only reached by such a fight. Tested: `tests/pfboard_v1.php` sections 2, 3, 11 and 13 (a state with exactly the 2.6.74 keys plays to its end), parity mode `v1old` in `tests/pfengine_js.sh`.
- To start a 2.6.74-style fight on purpose (tests): `pfb_new(..., ['v1' => ['env' => 0, 'ground' => 1, 'events' => 1]])`. Harness: `php tests/pf_play.php new STATE SLUG LEVEL SEED v1old`.
- Flag off: nothing changed (no new state keys; `pfb_new` without `v1` never touches the new code). `PFB_SRC` gained `'env'` (a list only read for v1 tiles).

## Rules as built (`game/includes/pfboard.php`, mirrored in `tools/pfengine.js`)
1. **Third player.** Round order: you, the creature, the environment. On its turn (`pfb_env_place`, called from `pfb_end_round`) the environment puts its face-up piece on the board and turns its next piece face up. Nothing fires on its turn. Then the creature's poison works, old pieces expire, both sides draw, the creature picks its aim (so the aim always knows the new piece).
2. **Where it places.** Any free cell where every touching edge fits (the normal rule, `pfb_check`). If some of those cells LINK (knob in a matching hole), only those are candidates. One is drawn by the fight's seeded roll. No cell fits: it passes and keeps the same piece face up.
3. **Its deck** (`pfb_env_deck`): the copies of `data/pf_env.txt` for the creature's size, plus the region's lean; shuffled at the start; when it runs out the discard is shuffled back in; when every piece is on the board it passes. One piece a round (`envn`, by size in `PFB_ENV_N`, all 1).
4. **Environment pieces are pieces** (`by` = `'env'`, tile `t` = `'env'`, `src` = `'env'`, value 0): edges, life, they link and fire in chains started by you or the creature, they count for the chain length, and a chain of 3 or more uses them up like any piece (they go to the environment's discard). They are not limited to 2 firings (that is the creature's fire budget). Their life counts from the round after they are placed (`born` = round + 1), so "2 rounds" = two of your turns.
5. **The effect goes to the side that started the chain** (`pfb_env_fire`, `$rb` in `pfb_fire`), also when the chain reached the piece through the other side's pieces:

| Piece | Effect | Number |
|---|---|---|
| Sun | Every piece of the firing side in that chain counts double (all types; once, however many Suns). Pieces of the other side in the chain are not doubled | `sun` 2.0 |
| Bramble | The OTHER side loses a share of its maximum (your health; the creature's bar). Guard does not help | `bramble` 0.10 (`br_foe` 1.0 on the creature) |
| Rain | Guard for the firing side: a share of its maximum (your health; the creature's bar) | `rain` 0.15 |
| Wind | The piece next to it on its arrow's side slides one cell further along the arrow, if that cell is on the board and free. Otherwise nothing moves. The blank never moves. The pushed piece still fires in this chain if it was linked when the chain started. The arrow is set when the piece is placed: a side where a piece stands with a free cell behind it if there is one (seeded roll among them), else any side | tile `dir` L R T B |
| Mud | Flat on all four sides: any piece fits against it, nothing links to it, so no chain runs into or through it; it never fires and is never used up; it leaves when its life is over | |
| Thornburst | The firing side loses a share of its maximum | `thorn` 0.10 (`th_foe` 1.0 on the creature) |

6. **Combos and Teamwork.** No combo runs through an environment piece (it has another owner). Teamwork is unchanged: environment pieces are not a source and do not break it.
7. **Edges** (authored in the data file): every firing piece has two knobs, two holes and all three families; the four core pieces link to each of them from 2 sides or more (linted). Mud is flat.
8. **The creature** uses them through its normal one-move search (the effects are in the state it scores). It has no special plan for them.

## Data: `game/includes/data/pf_env.txt` (new)
`key|name|kind|edges L,R,T,B|life|copies small/medium/large/boss|blurb` and region rows `=CODE|kind+N,...`. Edges: `hb km kc ...` = hole / knob of body / mind / craft, `f` flat, `w` wild. Read by `pfb_env_table()` (cached; no file = no environment pieces, the environment passes). Linted in `tests/pfboard_v1_env.php`. **The JS engine carries a copy** (`PFB_ENV_ROWS`, `PFB_ENV_REGIONS` in `tools/pfengine.js`); `tests/pfengine_js.sh` fails when the two differ.

| Piece | Edges L, R, T, B | Life | Copies small / medium / large / boss |
|---|---|---|---|
| Sun | hole body, knob mind, knob craft, hole craft | 2 | 2 / 2 / 2 / 2 |
| Bramble | hole mind, knob craft, knob body, hole body | 3 | 1 / 2 / 2 / 3 |
| Rain | hole craft, knob body, knob mind, hole mind | 2 | 2 / 2 / 2 / 2 |
| Wind | hole body, knob craft, hole mind, knob mind | 2 | 1 / 1 / 1 / 1 |
| Mud | flat x4 | 3 | 1 / 1 / 1 / 1 |
| Thornburst | hole mind, knob body, hole craft, knob craft | 3 | 1 / 2 / 2 / 2 |

Decks: 8 / 10 / 10 / 11 pieces. Regions (one more copy): NA wind, CA sun, CB sun, SA rain, NWE rain, SE sun, EE bramble, MENA wind, WCA bramble, ESA thorn, CSA mud, EA rain, SEA rain and mud, OC wind. The region is the creature row's `region` (set by `pfd_foe_row`, as for the creature's region piece).

## Constants
New: `PFB_ENV_KINDS`, `PFB_ENV_N` (1 for every size), `PFB_RAIN` 0.15, `PFB_THORN_FOE` 1.0, `PFB_ENV_EDGE`. Reused: `PFB_SUN_MULT` 2.0, `PFB_BRAMBLE` 0.10, `PFB_BRAMBLE_FOE` 1.0, `PFB_THORN` 0.10, `PFB_USEUP` 3.
**Retuned:** `PFB_V1_FOE_MULT` 1.0 / 0.70 / 0.53 / 0.66 (was 0.76 / 0.56 / 0.42 / 0.53), `PFB_V1_BAR_MULT` 0.75 / 0.92 / 1.05 / 0.66 (was 1.0 / 1.3 / 1.6 / 1.0). Without ground nothing wears the creature down for free, so the bars are shorter and its pieces hit harder.
`$s['v1']` gained `env`, `envn`, `rain`, `th_foe` (overridable through `pfb_v1_cfg`, e.g. `['envn' => 2]`). `ground`, `events` and their numbers are still there (0 by default).

## State fields (a fight with `$s['v1']['env']`)
- `$s['env']` = `['draw' => [tiles], 'discard' => [tiles], 'next' => tile | null]`. `next` is the face-up piece: the one the environment places at the end of this round. A tile: `k` (`e:sun`...), `n`, `t` `'env'`, `v` 0, `r` null, `tag` '', `m` '', `src` `'env'`, `env` (the kind), `life`, `ed` (four edges), and on the board `dir` (Wind only).
- Pieces: `$s['pcs'][id]['by']` = `'env'`; `born` = the round after it was placed.
- `$s['ter']` = `[]` and `$s['envs']` = `[]` always. `$s['envlog']` = the notes of the last environment turn (below).
- `$s['gone'][]` entries may have `by` `'env'` (expired, or `used` = whose chain used it up).

## View (`pfb_view`; the page copies `v1`, `round`, `ter`, `envs`, `envlog`, `aim`, `reaim`, `flip`, `status`, `wear` and now **`env`** into `#pf-data`)
- `v1`: plus `env` (bool), `envn`, `rain`, `th_foe`; `ground` and `events` are false.
- **`env`** = `['next' => ['k', 'n', 'kind', 'life', 'e' => edges] | null, 'deck' => pieces waiting, 'used' => pieces in its discard, 'n' => pieces it places a round]`.
- `pcs[]`: an environment piece has `by` `'env'`, `t` `'env'`, `v` 0, **`kind`** (sun, bramble, rain, wind, mud, thorn), **`dir`** (Wind's arrow, else null), `life`, `left`, `e`, `age`, `src` `'env'`, `fl` null. `gone[]` likewise `by` `'env'`.
- `ter` is `{}`, `envs` is `[]`.
- `prev` in the page data (the state before the last turn, for the replay) gained `env` (the same shape: what lay face up before the turn = the piece the turn's `place` event puts down).
- Lit-cell numbers (`pfb_cell_preview`): `n` counts environment pieces in the chain, `hp` includes what a Thornburst costs you, `dmg` includes Bramble and the Sun's doubling, `sun` = how many of your pieces a Sun doubles, `used` as before.

## Events (`pfb_play` / `pfb_pass`), and the replay entries
Every event still has `ta` (`me`, `foe`, `env`). Events with an **`env`** key:

| `env` | When | `by` / `ta` | Fields |
|---|---|---|---|
| `fire` | an environment piece fires inside a chain | `env` / `me` or `foe` (whose turn) | `id`, `root` false, `k`, `n`, `t` `'env'`, **`kind`**, **`for`** (`me` / `foe`: the side that gets the effect), `x`, `y`, `me` (health you lost), `foe` (bar points the creature lost), `guard` and `v` (Rain), `dir` and `moved` `{id, by, n, x, y}` (Wind; `moved` only when a piece moved; x, y = its new cell), `barnow`, `fhnow`, `hpnow`, `gnow` |
| `place` | the environment's turn | `env` / `env` | `id`, `kind`, `n`, `x`, `y`, `dir` (Wind) |
| `pass` | the environment's turn, nothing placed | `env` / `env` | `kind`, `n` when it holds a piece that fits nowhere; neither when it has no piece |
| `expire` | the environment's turn, after old pieces left | `env` / `env` | `ids` (the environment pieces that expired; they are in `gone` too) |
| `poison` | as before | `env` / `env` | `me` |

- Pieces doubled by a Sun carry `sun` = 1 (the same flag the sunny cell used). `used` on a chain's first event lists environment pieces too. `pfb_fx` (the chain glow) includes them.
- Order in one turn's event list: your chain, the creature's chain(s), then `place` (or `pass`), `poison`, `expire`.
- **Replay entries** (`$enc['replay']`, in `#pf-data.replay`): as before `id, by, ta, ln, bar, fh, hp, g, n, t`, and for `env` events `env, x, y, dir, moved, ids, me, foe` plus the new **`kind`, `for`, `guard`**. A `fire` entry has `id` = the environment piece and `ta` = the chain's turn. A `place` entry has `id` = the new piece (it is in `pcs`, at `x`, `y`) and `ta` `env`; `pass`, `expire` and `poison` have `id` null.
- Lines: `pfb_env_line` (through `pfight_line`): "Sun: your pieces in this chain count double.", "Bramble: the Owl loses 9.", "Rain: you get 7 guard.", "Wind: the Owl's Snap is pushed one cell." / "Wind: nothing moves.", "Thornburst: you lose 5 health.", "The environment places Sun.", "The environment finds no place for Sun.", "An environment piece fades.".
- History chips (`pfight_chip_event`): `by` `'env'`, `tags` = `[kind]` (or the event name), `id` = the piece for `fire`. `pfight_chips_board` skips them as before.

## What E2 has to build (the page knows none of this yet)
1. Draw `by: 'env'` pieces as a third kind of piece (own colour, the kind's icon, life pips, Wind's arrow from `dir`); today `pfboardv1.js` treats every piece that is not yours as the creature's.
2. Show `env.next` (the face-up piece, with its edges) next to the turn order; a popover with the piece's text (below).
3. Replay: the environment's turn banner, then `place` (the piece grows in at `x`, `y`), `pass`, `expire`; inside chains a `fire` step (flash the piece, show `for`, the cost or guard, move the pushed piece for `moved`).
4. Remove ground cells, legend chips, forecast marks and forecast chips for fights with `v1.env` (keep them for fights without it: a 2.6.74 fight under way still sends `ter` and `envs`).
5. Help text and popovers: the player-facing texts in "Sim 5".
6. `tests/pbox_v1.sh` and `tests/pbox_v1_shots.js` assert ground cells, forecast marks and `prev.ter`: **they fail now (6 checks)** and need the new screens. Everything else in the suite passes, including flag-off parity.

## Tests
| Test | What |
|---|---|
| `bash tests/pfboard_v1.sh` | 180 checks. Sections 2 and 3 now run on a 2.6.74-style fight. Section 11: 198 whole fights (every creature twice with environment pieces, one in a region; every fourth creature once more with the 2.6.74 terrain and exactly the 2.6.74 state keys) with invariants (no environment piece lost or doubled, none in a player's deck, arrows only on the board, no ground in new fights, no environment piece in old ones). Section 13 (`tests/pfboard_v1_env.php`, 71 checks): data lint, deck, face-up piece, the environment's turn, each effect for both sides, Wind's cases, Mud, life, expiry, lines, chips, lit-cell numbers, a 2.6.74 save. Any PHP warning fails the run. 17 engine mutations were run; each fails at least one check |
| `bash tests/pfengine_js.sh` | JS = PHP over 660 fights, 21417 actions (v1 fights now have environment pieces, half of them in a region; new mode `v1old` = 44 fights with the 2.6.74 terrain; `v1chaos` mixes both and odd numbers), plus the env table and five env decks |
| `bash tests/pfboard_v1_page.sh` | plus: the face-up piece in the page data, `place` and `fire` entries in the replay, no 2.6.74 terrain event in a new fight |
| Passing, unchanged | `pfdeck_v1`, `pfboard_fixes`, `pfboard_sim`, `pfboard`, `pfboard_js`, `pfight`, `pfight_sim`, `pfight_js`, `pfmap`; `php -l` on every changed file |
| Failing, for E2 | `pbox_v1` (6 checks, all about ground and forecast on the page) |

Harness: `php tests/pf_play.php new STATE SLUG LEVEL SEED v1 [REGION]` shows E pieces on the grid, the ENVIRONMENT NEXT line, the rules line, arrows, and "ENVIRONMENT PIECE (chain, for you)" / "ENVIRONMENT TURN" under WHAT HAPPENED.
Sims: `php tests/pfboard_tune_v1.php BOT OFFSETS MULT [i/n json]`, `php tests/pfboard_tune_v1.php agg < json lines`; env `BLIND=1` adds "best move changes with env hidden"; `V1='{"envn":2}'` and the like override rule numbers.

## Known gaps
1. **No UI** (above). With the flag on, an admin can play: environment pieces appear as pieces in `pcs` and their events reach the replay, but the page draws them like creature pieces and shows no face-up piece.
2. **The environment passes about once in five turns** (no cell fits its piece: the board holds about 3 pieces). The same piece stays face up.
3. **The creature seldom uses the environment well** (0.2-0.6 firings a fight for a careless player, 0.6-1.3 against a planner, and most of those are Thornbursts it was forced into). It has no plan for them; it only scores its one move.
4. **The bots see where the environment will place** (they simulate the round with the fight's seed). A player only sees which piece. This flatters `look` and `smart` a little.
5. `tools/pfdemo_v1/` (the design demo) and `tools/pfsim/v1bundle/` (the PHP sim copy of 2.6.67) were NOT changed: the demo is built from the pre-port engine (stage A, gap 7) and shares no code with `tools/pfengine.js`; the sims now run on the real engine (`tests/pfboard_tune_v1.php`). `claude/mockups/pf-demo-v1.html` still shows ground and forecast.
6. Region variants of the pieces (other names, other numbers) are not authored; a region only changes the copies.
7. Mud is weak (it only takes a cell). See the questions in "Sim 5".
8. MySQL, a phone, a human session and full CI were not run; only the puzzle-fight suites.
