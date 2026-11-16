# Real-choice metric: why 14-20%, and what to do (2.7.01)

2026-11-15. Driver: `tools/sims/realchoice_2701.php`. No game rule changed.

## The metric
From `tests/pfboard_tune_v1.php` `tv_real` (careful `look` bot): take the top 6 moves by 1-ply value, score each 2-ply. a1 = the best move, a2 = the best move with a **different hand piece**. A turn is a **real choice** when the spread of the six is at least 0.02 and a2 is within 10% of that spread from a1. Target (plan-week1-2.md): about 50%.

## Verdict
- **Base: 16.2% real.** Every other turn type is measured below. The loss is not "nothing to choose" (8%) and not "one piece only" (5%). It is **one piece clearly best: 70% of turns.** The median gap from the best piece to the best other piece is **half the spread** (0.51).
- **No rule lever measured reaches 25%.** The best single lever is the use-up length (`limit` 4 or 5): 21%. Best combination: hand 6 + `limit` 4: 22%.
- **Not even equal piece values fix it.** With every piece in the deck at the same value: 19.6%. The dominance comes from where a piece can go (edges, links, the aim cell), not from piece strength.
- **Recommendation: do not change rules for this metric.** 50% is out of reach by tuning. Either (a) change the target to what the game can deliver and measure it per fight, or (b) accept the metric as a diagnostic, not a gate. Details at the end.

## Breakdown of every turn (look bot, gnome at the creature's level, 252 fights each, about 1,700 turns)

| variant | win % | turns | none | one piece | flat | dominated | **REAL** | real at 20% | real at 30% | moves | pieces | median gap |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| base (today) | 100 | 6.86 | 0.2 | 5.4 | 8.1 | 70.1 | **16.2** | 25.0 | 31.2 | 15.6 | 4.13 | 0.51 |
| gnome 4 levels under | 100 | 7.88 | 0.6 | 5.6 | 8.3 | 69.4 | **16.1** | 25.1 | 32.4 | 15.2 | 4.07 | 0.47 |
| hand kept between rounds (`redraw` 0) | 100 | 7.42 | 0.5 | 5.1 | 9.6 | 66.8 | **17.9** | 24.8 | 31.5 | 15.1 | 4.08 | 0.47 |
| use-up at 4 (`limit` 4) | 100 | 5.98 | 0.4 | 5.8 | 6.6 | 66.2 | **21.0** | 30.7 | 36.7 | 15.4 | 4.07 | 0.41 |
| use-up at 5 (`limit` 5) | 100 | 5.31 | 0.3 | 5.5 | 6.1 | 67.0 | **21.1** | 30.8 | 37.5 | 15.1 | 4.03 | 0.40 |
| `limit` 4, bar x1.2 | 100 | 7.09 | 0.3 | 5.7 | 7.9 | 66.7 | **19.4** | 29.1 | 35.7 | 15.3 | 4.08 | 0.41 |
| creature pieces x1.3 | 99.2 | 7.39 | 0.2 | 5.1 | 7.8 | 70.3 | **16.7** | 24.9 | 30.9 | 15.2 | 4.11 | 0.51 |
| bar x1.5 (longer fights) | 99.6 | 10.15 | 0.3 | 5.2 | 10.2 | 68.9 | **15.4** | 22.8 | 29.4 | 15.2 | 4.13 | 0.52 |
| no class rules (`kinds` 0) | 100 | 6.89 | 0.3 | 5.5 | 7.4 | 70.8 | **15.9** | 25.4 | 31.8 | 15.2 | 4.09 | 0.50 |
| hand 4 (scratch engine) | 100 | 7.29 | 0.5 | 7.4 | 6.6 | 70.3 | **15.1** | 24.5 | 30.1 | 12.0 | 3.26 | 0.52 |
| hand 6 (scratch engine) | 100 | 6.60 | 0.1 | 3.4 | 9.7 | 68.8 | **18.0** | 26.2 | 33.7 | 18.8 | 4.93 | 0.47 |
| hand 6 + `limit` 4 (scratch) | 100 | 5.79 | 0.3 | 3.5 | 7.7 | 66.4 | **22.1** | 30.1 | 37.1 | 18.7 | 4.91 | 0.42 |
| every piece the same value (scratch, diagnostic) | 100 | 7.16 | 0.4 | 5.3 | 10.0 | 64.8 | **19.6** | 25.3 | 31.0 | 15.2 | 4.08 | 0.49 |

Columns (% of turns): none = no move; one piece = only one hand piece among the top 6; flat = spread under 0.02 (nothing matters much); dominated = another piece exists but is more than 10% of the spread behind; REAL as defined. moves = legal moves a turn; pieces = distinct hand pieces with a legal move; median gap = (a1 - a2) / spread over the non-flat turns.

- Noise: about 1.5 points on REAL at about 1,700 turns.
- `envn` 1 and `aimtot` 0 were also run: identical to base (2.6.98 already places one environment piece a round; the `look` bot reads the creature's real reply, not the shown aim).
- Hand size is a constant (`PF_HAND_CAP` 5); the hand runs used a scratch copy of the engine.

## What the levers cost (careless `chain` bot, gnome at level, tuner, n = 52-86 a size)

| variant | small | medium | large | boss | turns small / medium / large / boss |
|---|---|---|---|---|---|
| base | 87 | 96 | 95 | 93 | 5.2 / 6.2 / 7.1 / 7.1 |
| `limit` 4 | 98 | 96 | 94 | 93 | 4.8 / 5.6 / 6.6 / 6.5 |
| `limit` 4, bar x1.2 | 90 | 94 | 90 | 87 | 5.6 / 6.4 / 7.3 / 7.3 |

`limit` 4 alone makes fights 0.4-0.6 turn shorter and small fights easier (+11). With the bar x1.2 the length comes back and wins drop 2-6 points. The real-choice gain is +3 to +5 points: not worth a retune by itself.

## Recommendation
1. **Keep today's rules.** No lever moves REAL by more than 6 points; 50% would need a different game (several pieces a turn was measured before: `multiplay.md`, also no).
2. **Re-define the target, or drop the gate.** Candidates, measured on base:
   - real at 30% of the spread: 31% (38% with `limit` 5);
   - real decisions a fight: 16.2% x 6.86 turns = 1.1 a fight today; `limit` 4 + bar x1.2 gives 1.4.
   Pick one with Josh; 50% under the current definition is not reachable.
3. **If a rule change is wanted later**, the only candidate with a measured gain is a longer use-up chain (`limit` 4) with a bar x1.2 to keep fights as long: REAL 19.4% (+3), chain bot -2 to -6 points. Needs the full tuner set and a playtest before any decision.
4. **The cause to work on is placement, not values.** 70% of turns have one clearly best piece even when all pieces are equal in value. Ideas not measured: more cells where two pieces link equally well (more wild or flat edges), aims that two different pieces can block. Each needs its own sim.

## Not verified
- One bot (`look`) as the judge of a "real choice"; real players were not measured.
- 2-ply with the creature's real reply (the bot sees what the player does not).
- The hand-size and equal-value runs used scratch copies of the engine; the live game was not changed.
