# Turn flow review: puzzle combat v1 (2.6.94, HEAD 6b823f9c)

Scope: everything between "my turn starts" and "my next turn starts". Code read from `git show HEAD:` (the uncommitted edits to `pfboard.php`, `pfengine.js`, `tests/pfboard_v1.php` are NOT covered). Nothing in the repo was touched.

## How it was measured
- Game served from a temp copy of HEAD (`git archive HEAD game tests`), set up as `tests/pfv1_charm.sh` does (sqlite, user sprout, `pfight_v1=1`), PHP built-in server on localhost.
- Playwright, Chromium, 390 x 844, touch taps, fight on `adventure.php` (not the Trail pop-up). Creature: Orb Spider (medium, level 5), seed 7, 4x4 board. A 30 ms poll in the page logged banner, step chip, health numbers, result card.
- One whole fight at 1x (13 turns, won), plus scenario runs for mistaps, flip, set-aside, speeds and Skip.
- Scripts and raw logs: `scratchpad/fable/measure.js`, `measure2.js`, `spd0.js`, `dbg.js`, `run_full_1x.txt`, `run2.txt`, screenshots `s1`-`s11`.

## Taps per turn (measured)
| Turn type | Taps | What they are |
|---|---|---|
| Normal | 3 | piece, lit cell, End turn |
| Flip | 4 | piece, Flip, lit cell, End turn |
| Set aside (join or add) | 3 | piece, "+ Name arrow" choice, End turn |
| Place the group | 3 | group chip, lit cell, End turn |
| Pass | 1 | "Pass (nothing fits)" (by code; no pass state came up in the browser) |
| Opening | 3 | piece, side of the blank, Confirm start |
| End of fight | 1 | Collect the reward, after the last replay |

## Seconds per turn (measured, localhost)
Machine response while you decide (13 turns):
- Piece tap to lit cells: 90-170 ms (one outlier 838 ms). The numbers on the cells need one POST (`pfb_cells`): there 100-320 ms after the tap.
- Cell tap to End turn enabled: 96-378 ms. Plan text (POST `pfb_preview`): 306-588 ms after the cell tap.
- Flip (POST `pfb_flip`): new lit cells after 141-275 ms.
- End turn to the new turn in the page: 150-480 ms (one 1066 ms).

The wait after End turn, with no control, at 1x:
- 13 turns: 10.8, 14.4, 17.9, 11.8, 16.3, 10.9, 14.6, 15.4, 15.5, 17.4, 14.5, 16.4 s, and 8.4 s for the final turn. Median 14.6 s, total 184 s for the fight.
- Flip turn 9.8 s and set-aside turn 10.8 s in the scenario runs: the same replay, because the creature and the environment still play.
- Same turn at other speeds (9 replay events): 1x 14.5 s, 2x 7.5 s, speed "skip" 0.33 s. Skip button tapped 0.9 s into the replay: control back 1.9 s after End turn.
- `prefers-reduced-motion` at 1x: 14.48 s, the same as without it. The 2.6.78 changelog says reduced motion shortens or skips the replay; it does not (only CSS animations stop).

Where the seconds go (`maybeReplay` in `pfboardv1.js`, checked against the log):
- 0.3 s start, then 1.5 s banner per side (you, creature, environment), 0.95 s per event, 0.85 s per use-up step, 0.8 s for leaving pieces (this last one is not scaled by the speed setting).
- Every turn has 3 banners (4.5 s) and 2 environment placements (1.9 s): 6.4 s of a 10.8-17.9 s wait carries no decision information. Over this fight that is about 77 of 184 s.
- The first banner is "Your turn" over a replay of the chain you just chose (1.5 s).

Not measured: a human's thinking time. So "seconds per turn" here is machine time plus the forced wait only.

## Where the player waits without control
1. The replay: median 14.6 s a turn at 1x. During it the hand, board, Undo and End turn do nothing (taps on all three were ignored, one `pfb_play` post for a double tap on End turn). The new hand is already visible but cannot be picked.
2. The only ways out are the Skip button and the speed chip. Skip is 48 x 34 px at the top right (y 128 of 844), far from End turn (y 651). A tap on the board does not skip. The 2.6.78 changelog says "Skip (tap)"; only the button works.
3. After the replay, input is open but the page is stale for 0.8 s when pieces leave: the chip still reads "Environment" and "no aim" (screenshot `s6_after.png`).

## Information given too late, or wrong
1. **The aim is the only forecast of the creature's turn, and it shows the face value of one piece.** In v1 the cell numbers have no reply number (`pfb_cell_preview`: "no reply number: the creature shows its aim instead"). Measured: chip "Aims Sting hurt 3", the creature's turn took health 57 to 46 (Sting, then Nip in its chain). Haiku reports 2, 24 and 27 say the same (aim hurt 4, hit 8 with a combo; hurt 6, hit 12 on a Sun).
2. **The aim does not happen on many turns.** Opus sims: 39-46% of creature turns (chain bot); most because the aimed cell was left touching nothing. In my one fight the page flagged "picked again" on 3 of 12 creature turns. The page never tells you before End turn that your move breaks the aim; "(picked again)" appears afterwards. Haiku reports 12, 20 and 25 did not understand it.
3. **Cell numbers leave out heal, guard and what the creature gains.** A Heal 8 piece showed "–" on all lit cells (`s4_lit.png`). "Your chain fires the Orb Spider's Frost Bark (+3 guard)" appears only in the plan text after placing, in a list that is folded until tapped.
4. **Set aside says nothing about what it gives or whether the group will fit.** No plan text (`plan: null`); the hint is "Set aside for a later turn". The guard it gives (the piece's value) shows only as "Your guard fades (-4)" a round later. After setting aside, tapping the group lit 0 cells while the hint said "pick a lit spot to place the whole group".
5. **Things shown too early.** The page arrives with the new state and only the bars are walked back:
   - the round chip reads R(n+1) while round n replays;
   - the "poisoned 1" chip is up before the creature's piece is shown (`s7_replay.png`);
   - on the final turn the chip reads "R13 · over" 0.3 s after End turn, 8.1 s before the result card.
   - The new health is in the page for 150-250 ms too, but under the frozen snapshot, so it is not visible (checked). The 2.6.88 fix holds.
6. **Poison and Trip are shown inside the Environment turn.** Events `env:poison` and `env:trip` play under the banner "the environment places 2 pieces, not the creature" and the note "Nothing fires on its turn", while your health drops (56 from 57 at 8.1 s in turn 1).

## Decisions repeated or reversible by accident
- **After placing, a tap on any hand piece drops the placement without asking** (measured: End turn disabled again, piece back in hand). Since a tap on a piece is also how you read its card, looking at another piece costs the placement.
- **To change the cell you must pick the piece again**: Undo, piece, cell (3 taps) or piece, cell (2). Tapping another cell does nothing.
- **Flip is taken back in one case and kept in another.** Picking another piece takes the flip back (1 extra POST, measured). Undo and deselect keep it: after Undo the button read "Flip used", disabled, with nothing picked. Getting the flip back then takes piece, Flip.
- **End turn moved 27 px on turn 1** (top 645 to 672 px) when the plan text arrived about 0.3-0.6 s after the cell tap. A tap aimed at the old centre lands on the plan line, which opens the list. Later turns: no shift.
- Double tap on End turn: safe (one post). A second tap during the replay: ignored.

## What a mistap costs
| Mistap | Cost |
|---|---|
| Wrong piece | 1 tap (tap the right one) |
| Wrong cell, seen before End turn | 2-3 taps |
| Wrong cell, End turn tapped | the whole turn; no undo after End turn |
| Hand piece tapped after placing | placement lost, 2 taps to redo |
| Flip on the wrong piece | 0 if you then pick another piece; 2 taps after Undo |
| Set-aside choice (up to 6 small buttons, 2 rows) | 1 tap (Undo) before End turn; a whole turn after |

## Turn order and whose turn it is
- Good: the chip "R n · You / creature name / Environment" and a banner per side; the help sheet says "Every round goes: you, the creature, then the environment".
- Unclear: "Your turn" is used both for "watch your chain" (cannot act) and "now act". The chip shows the next round's number during the replay. Poison, Trip and the guard-fade notice are filed under the Environment step.
- Copy: with nothing playable the hint says "No piece fits. Tap End turn to pass." but End turn is disabled and the button is "Pass (nothing fits)" (by code).
- Opening: the same sentence is on screen three times (log line, Last plays, hint; `s1_open.png`). During replays the note is shown twice (dock and hint line).

## Pass rules
- Pass is allowed only when no piece fits, flipped or not, and the group fits nowhere. Haiku reports 19, 22 and 24 call the result forced self-damage ("Pass was refused twice, so the only legal action cost 4 HP").
- By code only, not reproduced: `pfb_pass` does not clear `gone` as `pfb_play` does since 2.6.88. A pass on which the creature ends the fight would replay last round's leaving pieces again. One line; worth passing to whoever is editing `pfboard.php`.

## End of fight
- Final turn: result card 8.4 s after End turn, after the full replay of that turn only (5 events). Skip was offered. Then 1 tap, "Collect the reward".
- Not checked: defeat, charm win, stall, reload after the end (covered by `tests/pfv1_charm.js`, not re-run here).

## Steps that could merge or go
- **End turn: keep it.** It is the only undo point, and the plan text exists only after placing. Removing it makes every wrong cell cost a turn.
- **Flip button: can go.** The server already previews a flipped piece (`pfb_cell_preview(..., $flip)`). Light the flipped-only cells in a second colour; a tap on one flips and places. A flip turn becomes 3 taps.
- **Pass button: merge into End turn** (label "Pass" when nothing fits).
- **Environment step: merge.** Both pieces land at once, no banner, as the tail of the creature's step.
- **"Your turn" banner before your own chain: drop.**
- **Aim plus environment preview:** the Next strip names the kinds but not the cells, so there is nothing to merge yet.

## Recommendations, ranked
| # | Change | Gain | Cost |
|---|---|---|---|
| 1 | Shorten the replay: no banner before your own chain, environment places both pieces in one step without a banner, creature banner 0.7 s, scale the 0.8 s leaving step | about 14.6 s to 10 s median at 1x (computed from the timings: 4.75 s less a turn; not measured) | Low: timings in `maybeReplay` / `tools/pfboardv1_part.js` |
| 2 | Tap on the board during the replay = skip to the end; honour `prefers-reduced-motion` (2x or skip) | Skip within thumb reach; the changelog claim becomes true | Low |
| 3 | AIMSTICK (Opus), and show the creature's expected total (its chain, Sun) instead of the face value | The one forecast becomes right more often (Opus: broken aims 6-9% instead of 39-46%) and stops understating | Rule: low (PHP and JS port). Total: medium (a dry run at intent time) |
| 4 | Mark the aim as broken live when the planned placement takes or isolates its cell | The player sees the block before End turn | Low to medium, client only |
| 5 | Cell numbers include heal, guard and what the creature gains; say what set aside gives; say "the group fits nowhere now" | Decide before placing, not after | Medium (`pfb_cell_preview` fields, labels) |
| 6 | Walk the round number, status chips and "over" with the replay; file Poison, Trip and guard fade under the right step | No spoilers, order reads true | Low to medium |
| 7 | One flip rule: Undo takes the flip back too (or nothing auto-reverts) | No "Flip used" with nothing picked | Low |
| 8 | A tap on a hand piece after placing should not drop the placement silently (keep it until a new cell is chosen) | Removes the cheapest accident | Low |
| 9 | Fold Flip into the lit cells | Flip turn 4 to 3 taps | Medium |
| 10 | Reserve the plan row (no 27 px shift), "Pass" on the End turn button and matching hint, opening text once | Small mistap and copy fixes | Low |
| 11 | Do not send `pfb_preview` after End turn (one stray POST per turn, measured); clear `gone` in `pfb_pass` | One request less; closes the 2.6.88 case for pass | Low |

## Not verified
- A real phone (touch latency, a mobile network: each piece pick, placement and flip is one POST; localhost hides the round trip).
- Real players: thinking time, whether they find Skip or the speed chip, whether the aim is read as a promise.
- The Trail pop-up (modal) variant, large and boss creatures, desktop drag and drop, the 2.6.74 terrain path.
- Quick and "loses its turn" banners (none came up), a pass in the browser, defeat and charm endings.
- One seed, one creature, one fight for the timings; the aim counts for that fight are an anecdote, the 39-46% is Opus's sim figure.
- The uncommitted engine edits.
