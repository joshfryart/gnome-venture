# Puzzle board: design proposals after playtest round 2 (2.6.61 rules)

Proposals only. No game files changed. Inputs: `claude/plan-puzzle-board.md`, `docs/puzzle-board-playtest-2.6.60.md`, `docs/puzzle-board-playtest-round2.md`, the engine (`game/includes/pfboard.php`, `pfight.php`) and two new measurements:

- **Round-2 replay.** All 500 round-2 fights were rebuilt from their `state-*.json.log` action logs on the current engine. HP matched the logs on every move (0 mismatches). At each decision the replay records every legal cell and its dry-run self-hurt, whether a `join` was legal, and where the damage came from.
- **Rule sims.** Seeded bots ran on a scratchpad copy of the engine with switches for each proposed rule: 88 creatures x 3 seeds per level offset, so n=264 per offset (bosses n=27). Results move by about ±4 points between runs; read the boss rows as directional.

| Bot | Plays like |
|---|---|
| greedy | `pfb_search`, same as `tests/pfboard_tune.php` |
| careful | best cell with no `!`; if every cell has `!`, the least harmful one |
| mark-only | first cell with no `!`; if none, the least self-hurt cell (a player who has the `!` marks but no numbers) |
| noisy | greedy, but 35% of moves are a random legal cell |
| random | random legal cell |
| look | whole-turn lookahead, including the creature's reply (the upper bound for a numeric preview) |
| builder | makes a 3-piece group whenever HP is at least 60%, otherwise plays greedy |
| charm-first / hurt-first | weights its own bar 1.0 and the other 0.2 |

Win % is given as d0 / d-4 / d-8 (gnome level minus creature level). Classic start unless a row says blank.

## Round-2 facts the proposals rest on (replay)

| Fact | Value |
|---|---|
| Forced-hurt placements (every legal cell fires a creature Hurt) | 161 of 3,515 (5%); classic 7%, blank 2% |
| HP lost on a forced turn (whole turn) | mean 16.9 (27% of max HP) vs 4.9 on other turns; 68/161 lost 20 or more; max 60 |
| Fights with at least one forced turn | defeats 72% classic / 20% blank; wins 25% / 13% |
| Forced turn was the last move | 33 of 121 defeats; forced turns account for 16% of all HP lost in defeats |
| A `join` was legal on a forced turn | 151 of 161 (a "skip" already exists; see P1) |
| Self-hurt taken although a safe cell existed | 355 placements, 3,228 HP (about twice the HP lost on forced turns) |
| Where HP went in a defeat (per fight) | your own chain 16.5 (21%), the creature's new piece 22.2 (28%), **creature re-fire 39.6 (51%)** |
| Blank vs classic: creature-turn damage per defeat | 67.5 vs 52.4 (the x1.2 multiplier) |
| Your Hurt absorbed by the creature's guard (not shown) | 5.1 per defeat, 8.2 per win |
| Your guard fired after a hit in the same chain (ordering loss) | 0.8 HP per fight |
| Poison ticks (not explained) | 5.1 damage per win |
| Set-aside use | 61 fights: 64 joins, 35 adds, **25 refused adds**, 46 groups; joined at HP ≥60% won 43/60, below 60% won 2/4; 27% of decisions while holding a group had no legal spot for it |

---

## P1. Forced hurting moves: a hurt-link safety rule plus a numeric preview (finding 2)

**Problem.** A pass is refused while any cell is legal. On 5% of placements every legal cell fires a creature Hurt, at a cost of 16.9 HP for the turn (max 60). 72% of classic defeats contain such a turn. The `!` mark shows only the placement's own link to a creature Hurt; it says nothing about how much damage, how deep the chain runs, or the creature's reply.

**Alternatives measured** (careful bot unless noted; baseline careful 99/91/66, look 100/94/80, noisy 92/72/53):

| Option | Rule | Result | Verdict |
|---|---|---|---|
| A1 Pass any time | `pfb_pass` without the "still fits" checks | careful 96/77/51 (passes on 7-25% of actions); look unchanged 100/93/80 | **skip**: a trap; a skipped turn gives the creature a free piece |
| A1b Pass at a cost | pass, lose 5% of max HP | careful 93/75/48 | skip |
| A2 Brace | pass, discard one hand piece, gain guard equal to its value | careful 100/88/61 (x0.5 guard: 98/84/56); look 100/94/80 | skip: never better than placing |
| **A3 Hurt-link safety** | a creature Hurt piece fired by **your** chain hits at x0.5 | careful 100/93/73, greedy 100/92/74, noisy 97/80/62, random 90/63/31 (was 79/45/25), look 100/97/87 | **do** |
| A3b Safety: skip | creature Hurt never fires in your chain | careful 100/96/81, look 100/100/92 | too strong |
| A3c Echo | every creature Hurt **re-fire** (not its new piece) at x0.5, in both turns | greedy 100/98/91, noisy 99/98/85 | skip: removes the main threat (51% of defeat HP) |
| **A4 Numeric preview** | replace `!` with numbers per cell | mark-only 96/70/47 (8.96 turns) → careful 99/91/66 (5.06 turns) → look 100/94/80 | **do** (UI only) |

**Change.**
- A3: add `const PFB_LINK_HURT_MULT = 0.5;` to `pfboard.php`. In `pfb_fire`, when the chain's root piece is `me` and the piece firing is a `foe` Hurt piece, use `$val = round($val * PFB_LINK_HURT_MULT)` after the group multiplier. The creature's own turn is unchanged.
- A4: per legal cell, show `+dmg / +charm / -hp now (n pieces fire) / creature reply ~-hp`. The figures come from a `pfb_play(..., $dry)` copy plus `pfb_search($w, 'foe')` on the result. Wire it into `pp_show` in `tests/pf_play.php` and into the page's `pfb_preview`.
- Keep the pass rule as it is.
- Do not present `join` as an escape: the careful bot that joins instead of hurting itself scored 99/85/58, worse than 99/91/66.

**Expected effect.** Weaker players gain the most: careful +2/+7 at d-4/d-8, random +11 to +18. Greedy players gain 2-8. A4 turns "avoid `!`" into "is this trade worth it", which is the gap between mark-only and careful (+21 at d-4).

**Risk.** Asymmetric rule (only your chain is softened); the game gets about 3-8 points easier, so retune (P8). A4 costs roughly 1 creature search per legal cell, so check the page's preview latency.

**Test.**
- Add a case to `tests/pfboard_fixes.php`: a placement linking into a creature Hurt of value v costs `round(v*0.5)` HP, and fails on the current engine.
- Run `pfboard_tune.php 3` and the noisy/random sims. Pass if greedy d0 HP lost stays at or above 22% (currently 28%), noisy d-4 defeats drop by at least 5 points, and no size reaches 100% win at d-8.

**Recommendation: do** A3 + A4.

## P2. Blank-centre multiplier (finding 1)

**Problem.** Agents won 69% on blank vs 80% on classic (random play 32% vs 68%). The bots reproduce the gap only for weaker play: at `PFB_BLANK_FOE_MULT` = 1.2, random wins 52/25/15 on blank vs 79/45/25 on classic.

| Blank multiplier | greedy | noisy | careful | random |
|---|---|---|---|---|
| classic (reference) | 98/89/66 | 92/72/53 | 99/91/66 | 79/45/25 |
| 1.2 (now) | 100/88/64 | 90/69/41 | 100/88/63 | 52/25/15 |
| 1.1 | – | 96/73/44 | 100/88/67 | 55/34/20 |
| **1.0** | 100/91/74 | 97/79/53 | 100/91/73 | 68/39/24 |

**Change.** `PFB_BLANK_FOE_MULT` 1.2 → **1.0**, or 1.05 if P1/P4/P5 ship together (see P8).

**Expected effect.** Blank lands within ±7 points of classic for the noisy and careful bots. Random play is still 11 points behind at d0 (the blank opening is harder to play badly).

**Risk.** Greedy players find blank slightly easier (HP lost 16% vs 28% at d0).

**Test.** Run `pfboard_tune.php 3` plus a noisy-bot sim for classic and blank. Pass if blank is within ±5 points of classic at every offset for noisy and careful, and within 12 for random. Then run a small agent round (50 pairs).

**Recommendation: do.**

## P3. A blank opening where the choice matters (finding 1)

**Problem.** The start pick does change outcomes: across all 20 starts per fight (5 hand pieces x 4 sides), the outcome flips in 35% of fights, and the best start wins 100% vs 85% for a random start. But no simple rule finds the good start: "best Hurt, any side" wins 84%, no better than random. The choice is chaotic, not legible, which matches the agents saying it had "little/no effect".

| Variant (blank, mult 1.0, greedy bot, d0 and d-8) | random start | best Hurt | readable pick* | oracle |
|---|---|---|---|---|
| now (hidden simultaneous pick) | 85% | 84% | (90%, needs the reveal) | 100% |
| blank lasts 2 rounds | 85% | 84% | – | 100% |
| **reveal + anchor x1.5** | 87% | 90% | **95%** | 100% |
| noisy bot, reveal only / with anchor | 73% / 75% | 77% / 80% | 78% / 84% | 97% / 98% |

\* Readable pick: choose the start whose best turn-1 move scores highest. A player can do this only if the creature's start piece and side are shown first.

**Change.**
1. **Reveal:** the creature puts its start piece out face up first; you then choose your piece and side. Its piece and side are already rolled before your pick in `pfb_start`, so move that roll into `pfb_new` and store it as `$s['fstart']` for display. The collision rule goes away because that side is visibly taken.
2. **Anchor:** both start pieces get `'anc' => true` in `pfb_start`'s `$put`, and `pfb_fire` multiplies an anchor piece's value by `PFB_ANCHOR_MULT = 1.5` for its whole life.
3. Do not extend the blank's life: blank lasting 2 rounds changed nothing measurable.

**Expected effect.** A thought-out opening is worth +8 points (greedy) and +9 (noisy) over a random one, against about +5 today with the reveal alone and about 0 without it.

**Risk.** Drops the hidden-pick flavour (Josh's design). The creature also gets an anchor, but its start piece is its gentlest non-Hurt piece, so that is small.

**Test.** Rerun the start-choice sweep (every start, every fight). Pass if a readable pick beats a random start by at least 6 points and "best Hurt" beats random by at least 3. Then an agent round asking "did the start matter": target at least half "yes".

**Recommendation: try** (needs a human decision: see the end).

## P4. Set-aside: make building a group a real option (finding 3)

**Problem.** Every join or add costs a full turn. Agents who joined at 60% HP or more won 43/60; below 60% they won 2/4. 25 adds were refused, and 27% of turns spent holding a group had no legal spot for it. The builder bot loses 5/16/20 points to plain greedy.

| Rule | builder bot | turns d0 |
|---|---|---|
| greedy (never builds), reference | 98/89/66 | 4.60 |
| builder, now (3-group x1.5) | 93/73/46 | 6.18 |
| 3-group x2.0 | 94/75/50 | 5.78 |
| join/add gives guard equal to the joined piece's value | 97/86/62 | 6.39 |
| **guard on join/add + 3-group x2.0** | **97/86/66** | 5.91 |
| guard x0.5 + 3-group x1.75 | 95/81/58 | 6.05 |

**Change.** In `pfb_play`'s `'j'`/`'h'` branch, after `pfb_connect` succeeds, add `$w['me']['block'] += ceil(newest group piece value * PFB_SETASIDE_GUARD)`, with `PFB_SETASIDE_GUARD = 1.0`. Set `PFB_GROUP_MULT[3]` 1.5 → **2.0** (the 2-group multiplier is never the deciding factor; leave it at 1.0). Card text: "Set aside: no effect now, but you brace (+guard)."

**Expected effect.** Building a group comes within 3 points of not building; it is still about 1.3 turns slower and still not dominant. It also gives careful players a non-hurting turn that is not a trap: the careful bot that joins instead of hurting itself improves from 99/85/58 to 100/87/63.

**Risk.** Guard stacking with Hold guards. Turn-1 joins against small creatures.

**Test.** Run the builder-bot sim (`pfboard_tune.php` with a builder bot added). Pass if builder win is within 4 points of greedy at every offset, builder turns are within 1.5 of greedy, and builder never beats greedy by more than 3 points.

**Recommendation: do.** Pair it with the UI items in P7 (join list, add help).

## P5. Guard against hits that arrive through your own chain (finding 4)

**Problem.** Agents report that guard does not soak hits that come through their own chain. Firing order is not the cause: guard firing after a hit in the same chain cost 0.8 HP per fight, and "guard pieces fire first" measured greedy 98/89/65 and careful 99/92/67 (no change). The real cause is that your guard resets at the start of your turn (`pfb_end_round`), so last turn's leftover guard is already gone when your own chain fires a creature Hurt.

| Rule | greedy | noisy | careful | look | HP lost (greedy, d-8) |
|---|---|---|---|---|---|
| now | 98/89/66 | 92/72/53 | 99/91/66 | 100/94/80 | 60% |
| guard pieces fire first | 98/89/65 | 91/72/52 | 99/92/67 | 100/94/80 | 61% |
| **leftover guard lasts through your next chain** | 98/90/67 | 92/79/55 | 99/92/71 | 100/95/82 | 59% |

**Change.** In `pfb_end_round`, carry leftover guard (`me.carry = me.block`, `me.block = keep + block`) instead of resetting it. In `pfb_play` and `pfb_pass`, after your action resolves, remove whatever carried guard was not used before the creature moves. Rule text: "Guard lasts until the end of your next action." This also fixes "`show` guard reads 0 after the creature moves".

**Expected effect.** Small: +1 to +7 win, -1 to -6 points of HP lost. The main gain is that guard behaves the way players expect.

**Risk.** Interaction with Hold (`keep`): document which guard is used first.

**Test.** Add a case to `pfboard_fixes.php`: guard 6 left after the creature's turn, then your placement links into a creature Hurt 8, and you lose 2 HP. It fails on the current engine. Then run the tune table; pass if no cell moves by more than 6 points.

**Recommendation: try.** Skip reordering by firing order.

## P6. Charm vs Hurt (finding 5)

**Problem.** Charm-first is level with Hurt-first against gentle creatures but slow against hostile ones and bosses (bosses have no charm bar, so Charm pieces are dead). Round 2: charm-style agents beat hostile creatures in 8.9 turns vs 6.1 against gentle ones, and only 27/52 of those wins were by charm.

| d0, turns (win) | Hurt-first | Charm-first | Charm-first, hostile Charm x0.75 | x0.8 |
|---|---|---|---|---|
| gentle | 4.27 (97%) | 4.19 (100%) | – | – |
| hostile | 4.38 (98%) | 5.75 (99%) | 5.03 (100%) | 4.86 (100%) |
| boss | 7.26 (100%) | 8.52 (100%) | – | – |

Boss options (n=27, noisy):

| Option | greedy on bosses | charm-first on bosses |
|---|---|---|
| now | 100/100/81, HP lost 22% at d0 | turns 8.52 at d0 |
| Charm counts as Soothe x1.0 (cuts the boss's next Hurt) | 100/100/100, HP lost 14% | – |
| Soothe x0.5 | 100/100/100, HP lost 17% | – |
| **Soothe x0.5 + `PFB_BOSS_MULT` 1.3** | 100/100/89, HP lost 14% | 8.56 / 8.93 / 10.74 turns, HP lost 19/32/46% |

**Change.**
- `PF_HOSTILE_CM` 0.6 → **0.75** (`pfight.php`).
- Bosses: in `pf_apply` case `'charm'`, when `$s['cm'] <= 0`, add `round(val * 0.5)` to `$s['foe']['agg']` ("Calm"), and set `PFB_BOSS_MULT` 1.2 → 1.3.
- Always show "No charm bar: Charm calms its next hit" on boss fights.

**Expected effect.** Charm-first against hostile creatures is about 0.65 turns slower than Hurt-first, against 1.37 now. Charm pieces are not dead against bosses.

**Risk.** `PF_HOSTILE_CM` is shared with strip mode. The boss sample is small (27).

**Test.** Run `tests/pfight_sim.php` for strip mode with the new 0.75. Run the charm-first/Hurt-first sim with 5 seeds. Pass if hostile charm-first is within 0.8 turns of Hurt-first, boss greedy win at d-8 is 80-92%, and boss HP lost at d0 is 15-25%.

**Recommendation:** hostile Charm 0.75 **do**; boss Calm **try** (needs a human decision).

## P7. UI and harness clarity (findings 2-4)

| Item | Change | Where | Check |
|---|---|---|---|
| Numeric preview | replace `!` per P1-A4 | `pp_show` (`tests/pf_play.php`), `pfb_preview` | transcript test: numbers match `pfb_play` |
| Group `!` marks / numbers | dry-run each group spot with `['c', x, y]` and mark it the same way | `pp_show` SET-ASIDE line; page `held.spots` | same as above |
| Creature guard readout | header shows `creature guard N`; events show "Hurt 9 (4 blocked by its guard)" from `e['blocked']` | `pp_show`, `pp_events`, page chip | 5.1-8.2 absorbed per fight is now visible |
| Expiry label | skip `by === 'none'` in the EXPIRED note; print "The blank centre is gone (turn 1 over)" | `tests/pf_play.php` notes; page `gone` | blank never listed as a creature piece |
| Join/add help | `show` lists legal joins (`join A B SIDE`) and adds (`add B ANC SIDE`, from `pfb_group_options`); refusals say "ANC = group piece number in the SET-ASIDE line; SIDE = side of that piece" | `pp_show`, `pfb_connect` messages | add refusals (25/60 now) under 10% in the next agent round |
| Combos | footer lists `PF_COMBOS`; events read "COMBO Ambush: x1.5 + previous value" | `pp_show`, `pp_events`, piece card | – |
| Poison | brief line plus event "Sting poison: +N, M tick(s) left" | `pp_events`, rules brief | – |
| Chain stopped on a win | "Fight won; N linked pieces did not need to fire" (not an error) | `tests/pf_play.php` notes | – |
| Overshoot | clamp bar display to its max | `pp_show`, page | – |
| Boss charm | "No charm bar" banner, plus a warning on the box screen for an all-Charm box | page | – |

**Recommendation: do.** Cheap, and the next agent round needs it to be readable.

## P8. Retune after the package

**Problem.** Shipping P1-A3 + P4 + P5 + P3 anchor + blank 1.0 together makes the game easier: greedy classic goes from 98/89/66 to 100/93/77, and blank greedy loses 12% HP at d0.

| Package + `PFB_FOE_MULT` 0.62 → 0.66 (blank mult 1.05) | greedy | noisy | random |
|---|---|---|---|
| classic now | 98/89/66 | 92/72/53 | 79/45/25 |
| classic with package | 99/92/70 | 95/81/62 | 83/61/29 |
| blank with package | 100/90/74 | 98/81/53 | 76/47/30 |

**Change.** `PFB_FOE_MULT` 0.62 → **0.66**, and `PFB_BLANK_FOE_MULT` = 1.05 if the whole package ships. Greedy play stays about where it is; noisy and random play gain 4-16 points (the skill gap narrows, which is the intent).

**Test.** `pfboard_tune.php 3`: classic greedy within ±4 points of today at every offset and size.

**Recommendation: do**, but only together with the package.

---

## Ranked shortlist (do first)

1. **P1: hurt-link safety x0.5 + numeric preview.** Biggest effect on the most-reported loss cause; a one-line engine change plus a preview.
2. **P2: `PFB_BLANK_FOE_MULT` 1.2 → 1.0.** A constant; closes most of the blank gap for non-greedy play.
3. **P4: set-aside guard + 3-group x2.0.** Turns a trap into an option and gives cautious players a non-hurting move.

Then P7 (UI, before the next agent round), P8 (retune once 1-3 land), P5, P6 (hostile Charm), P3.

## Needs a human decision

- **Hidden or revealed creature start (P3).** A reveal plus an anchor makes the opening matter; keeping it hidden keeps it chaotic.
- **How dangerous re-fire should be.** Re-fire is 51% of HP lost in defeats. P1-A3 softens only your own chain; A3c (all re-fires x0.5) would change the game's identity.
- **Passing.** All pass variants measured as traps for cautious players. Allowing it anyway for agency is a feel call.
- **Charm on bosses (P6).** Should Charm do anything against a boss, and is "Calm" the right fiction?
- **Difficulty target for weak players.** The package lifts random play by up to 16 points at d-4. Confirm that is wanted.
- **`PF_HOSTILE_CM`** also changes strip mode.

## Reproduce

All scratch code is in the session scratchpad, `/tmp/claude-0/-home-user-gnome-venture/8b4d4b94-cd53-5117-bf6a-320e9e085f12/scratchpad/sim/`:
- `replay.php` + `agg.py`: the round-2 replay.
- `run.php BOT MODE N OFFS`: the rule sims, run on the patched engine copy in `eng/`. Switches are environment variables: `BFM`, `SAFE=half|skip|echo`, `PASS=free|cost|brace`, `GF`, `GKEEP`, `SAG`, `G3`, `HCM`, `BOSSCH`, `BM`, `FM`, `ANCHOR`, `BLIFE`.
- `opening.php`: the start-choice sweep.
- `out/*.txt`: raw results.
