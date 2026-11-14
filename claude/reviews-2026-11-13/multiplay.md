# Play more than one piece a turn? (Opus research, 2026-11-14, on 2.6.95 rules)

Verdict: **no for now.** If wanted, the only candidate is R2, "up to 2 pieces a turn", behind a switch, after the week-2 "board that lasts" work.

Method: engine copy with `pfb_mstep` (place one piece mid-turn) and `pfb_mend` (end the turn); each bot keeps placing while a placement scores better than ending the turn; `multi:1` reproduces today (chain 79/80/82/78%). MULT 1, 4 shards, at level and 4 under, look with CHOICE=1. Noise about +-3 points. Raw tables: `multiplay-sim-tables.txt`, prototype diff: `multiplay-engine-prototype.patch`.

Findings (chain bot at level, small/medium/large/boss, unretuned):
- up to 2 pieces: 99/100/100/100%, 3.8-4.8 turns (today 6.4-7.9). Up to 3 and unlimited: 100%, 2.5-3.8 turns. Extra piece costs 1 health: 100%. Extra piece costs a hand piece: 100%. Stop when your chain fires a creature piece: 88/93/93/90%.
- look and smart win 100% in every variant; their health lost falls from 14-20% to 7-9% (up to 2) and 2-3% (unlimited).
- Real choices (look): each step is a real choice slightly less often (13-19% vs 17-23%); turns with at least one rise to 27-42% but fights are shorter, so real decisions per fight barely move. Only the retuned "up to 2" gains (medium about 1.4 to 2.0 a fight). "Which pieces to use up" has no tension because redraw discards unplayed pieces.
- The 4x4 board never fills (7-11 of 16); the hand jams instead: 13-18% of look turns (unlimited) end with pieces that fit no cell; use-up wipes 1.0-1.3 a turn (today 0.4-0.5).
- Taps a turn: 3.3 today, 5.0 (up to 2), 5.3-5.8 (stop rule), 7.8-8.3 (unlimited). Replay events 7.0-7.8 to 9-12. The aim breaks more often and is stale unless re-shown after each piece.
- A smaller hand does not fix it (up to 2 with a hand of 4: 97-100%).
- Retunes that put chain at 75-84%: R2 (up to 2): bar_x 1.7, foe_x 1.2/1.45/1.6/1.35 -> 76/83/77/78%, 5.7-6.5 turns. Stop rule: bar_x 1.15, foe_x 1.05/1.15/1.3/1.05 -> 82/81/76/76%. Unlimited: bar_x 2.0, foe_x 1.7/2.1/2.5/2.0 -> 75/78/75/84%, 4-5 turns. In all, look and smart still win 100% and lose only 6-10% health, so the gap between careful and careless players grows.

Rule text for R2: "On your turn you may place up to two pieces, one after the other; each fires its chain when it lands. Then tap End turn."

Work for R2: engine small (`pfb_play` already takes a list of moves, refuses `count !== 1`); JS port small-medium (the same gate in `tools/pfengine.js` play(), plus parity); page medium-large (lit cells and plan text on the board after pending pieces, undo per piece, live aim, "1 of 2" counter); balance medium. Risks: easier for careful players, stale aim, denser replay.

Not verified: bots plan one piece at a time (no two-piece sequences or bait setups; real careful play likely easier still), charm-kit decks, boss at 8 under, level bands, combination with week-2 rules, any UI or phone test. Taps are a formula, not measured.
