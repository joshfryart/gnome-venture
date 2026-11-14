# Creature strategy review: puzzle combat v1 (2.6.94, 4x4 board)

All numbers come from a COPY of the engine and harness at
`/tmp/claude-0/-home-user-gnome-venture/61d29fdb-51dd-5c70-9df1-3360659d574b/scratchpad/opus/eng/` (the repo was not edited).
Harness: `tests/pfboard_tune_v1.php` (real engine, the 88 real creatures, layered decks, deck model, env pieces), plus counters for creature turns, aims that broke (and why), set-asides and groups.
Runner: `eng/run.sh`. Raw output: `eng/out/taskA.txt`, `eng/out/taskB.txt`, plus a jsonl file per run.
Sample size: MULT 1 = 207-215 fights per size and offset (smart bot: MULT 0.5 = 104-129). The seeds are the same in every variant, so the comparisons are paired. A win % for one cell has a standard error of about 3 pp, so a gap of 3 pp or less is noise.
Bots: chain = always the longest chain (about a "simple player"), look = best state after the whole round (reads the aim), smart = two turns, uses set-aside.

## Task A: how the creature chooses its move today

Code: `pfb_intent` -> `pfb_search` -> `pfb_score` (game/includes/pfboard.php 880-912, 1042-1048), then `pfb_foe_turn` (939-968).

- **Greedy, one ply, one piece.** `pfb_search` tries every hand piece (3 cards, a boss has 4) in every legal cell on a copy. It fires the chain and scores the state difference:
  - its progress toward winning: -0.8 x (bar + damage taken)
  - minus your health change, x1
  - its guard x0.4, your guard x0.3
  - tag terms (poison waiting on you, trip, evade, thorns, bash, quick)
  - +50 for a kill
  - Ties go to the first move found, so the choice is deterministic.

  There is no lookahead and no model of your reply. Nothing values the board it leaves behind: open cells, pieces of yours it could use up, expiry.
- **When it decides.** The move is chosen at the END of the previous round, before you move (`pfb_intent` runs inside `pfb_end_round`), and it is committed (AIM). On its turn it plays the shown piece on the shown cell, and `aimforce` lets it skip the must-link rule. If that is illegal, it re-runs the same greedy search at full value. There is no fumble.
- **Temperament plays no part in the choice.** `pf_temper` only sets the Hurt/Charm multipliers (`hm`/`cm`) on its bar.
- **Creature kinds.** Every size and class runs the same algorithm. The differences are:
  - a boss holds 4 cards instead of 3, so it has more options;
  - a boss deck is ordered soft, hurt, hurt (`pfd_foe_row`);
  - the value multipliers (`PFB_V1_FOE_MULT`, boss x1.2).

  In v1 every creature plays 1 piece a turn (`pfb_foe_len`), plus 1 more after a Quick piece. The creature never flips.
- **Sun, Mud, Rain, Wind, Thornburst.** It uses them only through the one-ply chain value:
  - Sun in its chain doubles its pieces;
  - firing Bramble hurts you;
  - Rain gives it guard (x0.4);
  - it avoids Thornburst (Thornburst costs the side that fires it);
  - it avoids pieces next to Mud (-25%).

  Wind is worth only whatever the push changes inside that one chain.

  `pfb_env_bias` is dead code under 2.6.75 environment pieces: `$s['envs']` is empty because events = 0. So the creature ignores the face-up NEXT environment pieces.
- **Your linked pieces.** Yes, its chain runs through them. Each of your pieces fires for you (`pf_apply` with the owner), so it avoids linking into your Hurt. A 3+ chain uses up pieces of both sides, but the score gives no value for removing your pieces.
- **Blocking you.** It never blocks on purpose. Nothing in the score looks at your options.

### What the move choice is worth (win % / health lost %, at level d+0)

| Creature policy | chain bot: small, medium, large, boss | look bot: health lost | smart bot: health lost |
|---|---|---|---|
| greedy (today) | 86/45, 76/61, 82/61, 88/63 | 13, 17, 15, 14 (all 100% wins) | 11, 16, 11, 12 |
| random legal move (weaker) | 90/40, 84/55, 88/57, 91/57 | 9, 14, 12, 12 | 8, 12, 10, 11 |
| 2-ply "strong" (top 6 greedy; your best reply to its shown aim; 0.5 realistic + 0.5 worst case) | 84/48, 79/61, 83/62, 90/64 | 13, 17, 15, 15 | 11, 14, 12, 12 |
| greedy, no telegraph (aim 0: it picks after your move) | 82/51, 75/64, 76/65, 86/68 | 12, 18, 15, 14 | 12, 17, 12, 12 |

At 4 under (d-4), chain bot win %, small / medium / large / boss:

| Creature policy | small | medium | large | boss |
|---|---|---|---|---|
| greedy | 72 | 38 | 63 | 76 |
| random | 80 | 46 | 67 | 80 |
| strong | 70 | 38 | 60 | 73 |
| reactive | 75 | 35 | 57 | 69 |

The look bot at d-4 is 93-100% under every policy.

Reading:
- The move choice is worth little. Random instead of greedy gives the simple player only +3 to +8 pp of wins and the good players 1 to 4 pp less health lost.
- A real 2-ply creature gains nothing that can be measured (every cell is within ±3 pp).
- Hiding the telegraph (reactive) costs the simple player 1 to 6 pp.
- The creature's threat lives in its piece values and the use-up and environment rules, not in its decisions. It is neither too dumb nor too strong. Tuning belongs in the values, and smarter AI would be wasted work.
- The old doc's "Aim alone makes fights easier" is still true, but small: 0 to 6 pp.

### The real problem: the telegraph is wrong about 40% of the time

With today's greedy policy, at level, the shown aim did NOT happen on 39-46% of creature turns (chain bot) and on 30-44% (look and smart bots).

Causes per fight, chain bot at level, small / medium / large / boss:

| Cause | small | medium | large | boss |
|---|---|---|---|---|
| aimed cell left touching nothing (a 3+ use-up chain removed its neighbours) | 1.87 | 1.82 | 2.40 | 3.05 |
| an edge you placed does not fit | 0.30 | 0.26 | 0.19 | 0.08 |
| you took the cell | 0.14 | 0.25 | 0.22 | 0.27 |

So most "re-aims" are not your counterplay. `aimforce` lifts the must-link rule but not the must-touch rule in `pfb_check`.

Prototype AIMSTICK: the committed aim lands even when it now touches nothing.
- Broken aims drop to 6-9% of creature turns (chain bot) and 16-24% (look and smart). What is left is mostly your own block.
- Balance moves little:
  - chain d+0: 84/75/81/94 (boss +6, boss health lost -6);
  - chain d-4: 68/34/67/82;
  - look: health lost 12-18, unchanged.
- Recommendation: adopt it. It is a 1-line rule in PHP and in the JS port: "A shown aim always lands unless you take its cell or put a piece whose edge does not fit next to it."

### Should creature kinds act differently?

They do not today, and the data says decision quality buys almost nothing. So give the kinds identity through readable rule quirks, not deeper search. The design doc's idea already does this: a Bird shows two aim cells, a boss shows two turns ahead. Do not give bosses a smarter search: 2-ply measured as no gain, at extra CPU (the full 2-ply run was about 2-3x slower).

## Task B: "Allow creatures to take a turn to combine pieces?"

Prototype in the engine copy (FOECOMB):
- The creature uses the player's own rules: `pfb_connect` join and add, guard = the value of the piece just set aside (`PFB_SETASIDE_GUARD`), groups of up to 3, group values x1.0 for 2 pieces and x2.0 for 3 (`PFB_GROUP_MULT`), and `pfb_place_group`.
- The hand refills to its size at the end of the round, as now.
- Decision rule in `pfb_intent`:
  - it sets aside when COMBK x 0.6 x (best spot value of the 2- or 3-piece group now) > its best single move, and never instead of a kill;
  - it places the group when that beats a single move, and always once the group has 3 pieces.
- The plan is telegraphed and committed like an aim: "sets aside A + B" or "plays group at x,y". A blocked group spot re-picks, the same way a blocked aim does.
- COMBK was swept at 0.7, 1.0 and 1.5.

Results, all creatures, COMBK 1.0, against today's greedy baseline (`eng/out/taskB.txt`):

| Measure | today (greedy) | with combine (COMBK 1.0) |
|---|---|---|
| chain bot d+0, win % (small, medium, large, boss) | 86, 76, 82, 88 | 68, 68, 72, 76 (-8 to -18 pp) |
| chain bot d-4, win % | 72, 38, 63, 76 | 60, 33, 47, 71 |
| chain bot, health lost | about the same | ±5 |
| look bot d+0, health lost (all 99-100% wins) | 13, 17, 15, 14 | 9, 13, 12, 11 (EASIER) |
| look bot d-4, medium win % | 95 | 91 |
| smart bot d+0, health lost | 11, 16, 11, 12 | 4, 10, 8, 9 (EASIER) |
| fight length | | within ±0.5 turn everywhere (for example chain d+0 6.3/7.1/7.9/8.6 -> 5.9/7.2/8.0/8.6) |

Activity per fight:
- set-asides: 1.8-2.4 against chain, 1.6-2.0 against look;
- groups placed: 0.8-1.1 against chain (2.6-3.9 pieces fired in group chains), 0.3-0.5 against look.

COMBK variants:
- COMBK 0.7 is milder: chain d+0 80/73/78/85, set-asides about 1.0.
- COMBK 1.5 behaves like 1.0 with more groups (boss 1.17-1.34 a fight).

Boss only (the boss rows of the same runs; each creature is simulated on its own):
- chain: d+0 88 -> 76, d-4 76 -> 71;
- look: health lost 14 -> 11 (d+0) and 16 -> 14 (d-4);
- smart: health lost 12 -> 9.

Readability:
- A planned group spot failed 0.19-0.26 times a fight against chain (about 40% of planned group placements) and 0.33-0.76 times against look (about 70-80%). Readers block the multi-cell footprint easily.
- Overall "plan broken" falls to 23-34%, but only because set-aside turns cannot break.
- Set-aside turns give a 1-2 turn warning, so the threat itself is more visible. But the group aim is a 2-3 cell shape that moves when you block it.

Verdict: NO for now; at most bosses only, and only after AIMSTICK.
- It does not make the creature smarter. It widens the skill gap:
  - simple players lose 8-18 pp;
  - careful players WIN MORE EASILY, because every set-aside is a creature turn with no attack, and the shown group is easy to block.
- That is the opposite of what a boss mechanic should do.
- If the owner wants it as boss flavour:
  - use COMBK 0.7;
  - limit it to bosses;
  - make a blocked group play at a fallback spot without re-picking a single piece;
  - retune the boss bar or values against the chain target of about 70%.

Risks:
- JS port: `tools/pfengine.js` `intent`/`foeTurn`/`search` gain group logic, and parity tests are needed. `connect` and `placeGroup` are already written for any side.
- `pfb_view` and the UI: the v1 page part has no held-group display; it needs the creature's held group, a multi-cell aim marker, new replay steps and new notes.
- `pfb_must_link` already counts a held group.
- CPU: the decision runs group placements for every pair, about 2x intent time.
- Bot look-ahead and `pfb_cell_preview` dry runs must stay cheap.

Minimal rule text if built: "Instead of placing a piece, the creature may set 2 pieces aside (it gains guard like you do), add a third next turn, and then place the group: 3 pieces play for double. Its banner shows what it set aside and where the group will land. Take a cell under the group's shape to make it choose again."

## What I did not verify

- I made no change to the JS port and ran no parity check. There was no browser or UI check and no human play.
- The policies and the combine heuristic are one implementation each. A better combine planner could do better against readers.
- The strong policy assumes your reply is your best one-ply move (with no flip and no group placement).
- Combine planning and the 2-ply search are skipped inside the bots' hypothetical look-ahead copies. Only the real game state uses them, so the look and smart bots see the real committed plan.
- `mt_srand($seed)` was added for the random policy. The baseline numbers are identical to the unmodified harness (chain 92/44/6.6 small at MULT 0.25 before and after).
- d+0 and d-4 only. There was no d-8 run and no other COMBK values.
