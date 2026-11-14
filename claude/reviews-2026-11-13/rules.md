# Gameplay and rules review: puzzle combat v1 (4x4 board)

Reviewed: the rule set as built at commit 3e76b2f4 (2.6.94 plus AIMSTICK, the level curve and the boss retune). No repo file was changed.

## Verdict

- **Coherent:** mostly. The core loop (place one piece, a chain fires, read the creature's aim) holds together. Three rules work against it: two win bars that do not add up, an aim number that is wrong about a third of the time, and a set-aside system that changes nothing.
- **Learnable:** not yet. A new player must hold about 20 rules, and the two that decide fights are the least visible ones (see "What decides a fight").
- **Fun:** the good moments are real and repeat in the playtests: a Sun-doubled finisher, running a chain into Bramble, taking the aim cell. The bad moments also repeat: a hit two to three times the shown number, a turn where every move costs health, a hand with nothing to do.
- **Biggest single finding:** one habit, "never play a cell that costs you health", takes the careless bot from 76-90% wins to 90-99%. The game is currently a test of reading one number (`h`), not of chain building.

## How I tested

- All sims use the real engine through `tests/pfboard_tune_v1.php` (88 creatures, layered decks, the tuner's gnome), with my own counters added in a scratch driver.
- **Current-engine runs** (commit 3e76b2f4): 207-215 fights per size, gnome at the creature's level. These are the numbers in "What decides a fight", "Charm against damage", "Aim" and "Board".
- **Variant runs** (pass, must-link, use-up limit, Sun, Thornburst, one bar, set-aside): done on the 2.6.94 commit, before AIMSTICK and the level curve, 126-130 fights per size (set-aside: 63-86). Each variant is compared with a baseline on the same seeds.
- Noise: about 3 points on a win % with 210 fights, about 4-5 with 130.
- Bots: `chain` = always the longest chain (a careless player); `look` = best state after the round (a careful reader); `smart` = two turns ahead, may set aside.
- Playtests: the 30 haiku reports in `scratchpad/hk/` (results: 15 seen off, 8 charmed, 7 defeats; mean fairness 3.2 of 5 over the 29 that parsed).
- Files: `scratchpad/fable/rv.php`, `rv2.php`, `rv3.php`, `aim.php`, `aim3.php`, `agg.py`; raw rows in `scratchpad/fable/out/` (2.6.94) and `out2/` (current). Engine copies in `eng/` (2.6.94, with three test switches added) and `eng2/` (current, unmodified).

## What decides a fight

Careless bot (`chain`) against the same bot that refuses any cell with a health cost and passes when every cell has one (`chainp`), current engine, at level:

| | small | medium | large | boss |
|---|---|---|---|---|
| chain: win % / health lost % | 84 / 49 | 76 / 61 | 83 / 59 | 90 / 62 |
| chainp: win % / health lost % | 90 / 41 | 93 / 44 | 99 / 40 | 98 / 44 |
| chain: health lost to creature pieces fired in its OWN chain | 12% | 10% | 12% | 13% |
| chain: health lost to Thornburst in its own chain | 7% | 13% | 15% | 14% |
| look: the same two, together | 6% | 5% | 6% | 5% |

- The careless player loses 19-27% of its maximum health to its own moves. That is a third to almost half of everything it loses.
- The cause is two rules that a new player will not guess:
  - a creature piece linked into YOUR chain fires for the creature (5-8 such pieces a fight for the careless bot, 2.6.94 run);
  - Thornburst costs the side that fires it.
- The lit-cell number `h` already shows both. So the fix is presentation (make a costly cell look dangerous and say why), not a new rule.
- Removing Thornburst altogether gave the careless bot +2 to +10 points and added 0.3-0.6 turns. The careful bot's health lost moved 0-5 points (12-14% against 13-19%).

## Where rules fight each other

### 1. Charm against damage: two bars that do not add up
- The damage bar and the charm bar are the same length and independent. Progress on the bar you do not finish is thrown away.
- Share of fights won by charm, current engine, at level:

| bot | small | medium | large | boss |
|---|---|---|---|---|
| chain | 18% | 6% | 0% | 0% (no bar) |
| look | 26% | 9% | 0% | 0% |
| look that values only charm (`lookc`) | 39% | 12% | 0% | 0% |

- Even the charm-only bot wins by damage most of the time, and it pays for trying: 9.5 / 10.3 / 11.8 turns against 5.6 / 5.7 / 6.8, and 16-25% health lost against 12-15%.
- Charm that is thrown away: the charm bar stands at 8-14% full on average when a fight against a large creature ends (none of those fights was won by charm), and at 19-25% against medium creatures (all fights, including the 6-9% won by charm).
- About 14% of the sim gnome's deck is Charm or Soothe pieces. Against a boss (no charm bar) they do nothing except their tag effects. Playtest r26: "the boss has no charm bar so Charm and Lull were dead cards".
- Playtests agree: all 8 charm wins were against creatures of level 7 or lower. The three "charm" style runs ended as one win by damage (charm bar at 83 of 107, unused), one defeat at 54.0 of 55.6, and one defeat.
- Why charm loses above small: hostile creatures count Charm x0.6, and Bramble (10% of the bar per firing) only feeds the damage bar. Bramble gives 9% / 16% / 21% / 26% of the bar by size for the careless bot.
- Charm does have one hidden advantage: creature guard, Evade and healing do not touch it. No text says so.
- **Prototype, one shared bar** (the fight ends when damage plus charm fills the bar; the larger share names the result; 2.6.94 engine): fights get 0.7-1.6 turns shorter. With bars x1.15 the length returns (large 7.7 against 7.8 turns, medium 6.5 against 7.0) and win rates stay within noise for large (83 / 83) and rise for medium (82 against 74). Charm wins stay rare (21% / 8% / 0%) under the "larger share" rule. Not tested: any reward difference between the two results, and the careful bot at other levels.

### 2. The aim number is wrong about a third of the time
- AIMSTICK fixed WHERE the piece lands. The number is still the face value of one piece.
- Current engine, at level, creature turns with a Hurt aim: what actually hit me (before my guard), against the shown number:

| | small | medium | large | boss |
|---|---|---|---|---|
| careless: hit at least 2x the shown number | 22% | 33% | 37% | 35% |
| careless: mean shown / mean actual | 3.7 / 4.9 | 5.7 / 8.8 | 7.3 / 11.8 | 8.9 / 14.3 |
| careful: hit at least 2x the shown number | 16% | 31% | 33% | 34% |
| a non-Hurt aim that still cost health | 27-29% | 25-27% | 23-30% | 41-43% |

- When the hit was larger, the cause was a combo in 46-74% of cases, two or more Hurt pieces in the chain in 57-81%, and Sun in 6-18%.
- The combos (Ambush x1.5 plus the piece before, Riposte x1.5, Double Swing +2, Bait) are named nowhere in the fight text. Playtests r2, r6 and r8 each met "COMBO Ambush" or "COMBO Bait" with no explanation; r2 lost 35% of its health to one.
- This is the most common "unfair" note in the playtests (r2, r6, r7, r11, r14, r20, r23, r24, r27, r28).
- Josh decided "no reply number on lit cells". A total on the AIM itself, computed on the board as it stands, does not break that decision.

### 3. Sun doubling for the creature
- It is a feel problem, not a balance problem.
- Current engine: the creature fires a Sun on 4-8% of its turns, in 16-35% of fights.
- With Sun never doubling the creature (2.6.94 engine): careless bot 89 / 80 / 86 / 92 against 88 / 74 / 83 / 90; careful bot unchanged (health lost 13-16% against 13-19%). Only medium moves beyond noise.
- It reads as unfair because the aim number does not show it (point 2). Fix the number, keep the rule: "the piece works for whoever fires it" is the one clean idea behind every environment piece.

### 4. Forced hurting moves and the refused pass
- Smaller than in the old board. Turns where EVERY legal move costs health: 0.6-2.9% of turns, in 3-17% of fights; the cheapest such move costs about 9-10% of maximum health.
- Turns with no legal move at all: 0.1-0.6%.
- Letting the careful bot pass whenever it likes (2.6.94 engine) changed nothing: 100% wins either way, health lost within 1 point, 0.10-0.23 passes a fight.
- So the refusal protects nobody and costs agency. Five playtests name it as the dull moment (r5, r9, r19, r24, r29), and r24, a defeat, describes it: "Pass was refused twice, so the only legal action was 'place Swing 2,0' costing 4 HP".
- The must-link rule ("a piece must make a linked joint unless nothing can") is also near-inert. Dropping it for the player (2.6.94 engine): the careless bot's results were identical to the decimal; the careful bot's health lost moved 0-3 points; legal moves rose from 14 to 16-18 a turn.

### 5. Use-up at 3+ and the empty board
- Use-up carries the fight length. With it off, fights last 3.4-5.2 turns and the careless bot wins 98-100%. With the limit at 4: 4.9-7.2 turns, careless 95 / 86 / 94 / 92. Keep the rule.
- Its cost: at the start of my turn I have NO piece of my own on the board in 60-68% of turns (careless) and 40-46% (careful). The board holds about 5 pieces of 16.
- So "building" does not happen. Each turn is a fresh question: which hand piece links to what the creature and the environment left. Teamwork, piece life (2-4 rounds) and set-aside were all designed for pieces that stay, and mostly do not get the chance.
- A creature chain of 3+ also uses up YOUR pieces. Playtests r18 and r26 were surprised by it ("my 11 hurt piece and guard were lost without any choice of mine").
- Four different rules now remove a piece: use-up at 3+, life in rounds (2, 3 or 4 by piece), the creature's 2-firing limit, and the blank after round 1. That is a lot for one board.

### 6. Join, add and group
- Almost unused, and worth nothing measurable.
- The smart bot sets aside 0.21-0.30 times a fight and places a group 0.02-0.10 times. So more than half of its set-asides never become a group: it uses the join as a guard move.
- The same bot with set-aside removed (2.6.94 engine, 63-86 fights per size): 100% wins both ways; health lost 10 / 17 / 13 / 13 against 9 / 14 / 12 / 12; same fight length.
- Playtests: used in 2 of 29 fights. The run told to use it (r7) could not find out how ("join/add/group are not discoverable from the show output"). The one clear success (r17) had to find the group's footprint "by trial".
- It costs the most interface of any rule: a two-row choice panel, a held-group display, a multi-cell placement.

### 7. Bosses
- No charm bar, so one win path and dead Charm pieces (point 1).
- The environment does much of the work: Bramble gives 26% of the boss's bar for the careless bot and 21% for the careful one. Playtests r19, r20, r26 and r30 all name Bramble as the real damage source ("Bramble and poison did most of the boss damage").
- Careful bot: 100% wins, 15% health lost, 5.9 turns. A boss is no harder than a medium creature for a reader.

### 8. Other dead or near-dead things
- **Flip "once a turn":** you place one piece a turn and can flip back, so the limit limits nothing. The real cost is that every piece has two shapes to check: 1.5-2.6 flips a fight. Playtest r10 won on a cell "I could only see after using my once-a-turn flip".
- **Teamwork:** 0.2-0.46 times a fight in the tuner (its sources are made up). Rare enough that most players will never learn it from play.
- **Wind:** "nothing moves" in r5, r10, r11, r12, r18, r25, r27 and r30. The design doc measured 0.1-0.55 pushes a fight.
- **Mud:** never fired; -25% to neighbours. The playtests only noticed it as a tag on the creature's pieces.
- **Turns with no move that makes progress on either bar:** 6-14% of turns.
- **Hand pieces with no legal cell:** 14-17% of hand pieces each turn.
- **Small fights that end in 1 or 2 turns:** 24-25% at level (playtests r1 and r21: "over in 2 player turns", "nothing made the player think").

## What a new player will not understand

Counted from the 29 playtest reports that parsed. These are the harness's words; I did not check the page.

| Unclear thing | Reports | Example |
|---|---|---|
| "health" means the creature's damage bar, "hp" means yours | 8 (r7, r9, r14, r20, r21, r24, r25, r30) | "Two meanings of 'health' on one line" |
| A negative `d` on a cell (the creature heals inside your chain) | 6 (r10, r13, r15, r18, r19, r29) | "negative damage was not explained anywhere" |
| "CHAIN STOPPED ... linked piece(s) did not fire" | 6 (r1, r2, r6, r16, r21, r22) | |
| The piece shows its face value; the bar moves by value x a hidden multiplier (Hurt x0.8 or Charm x0.6) | 5 (r3, r11, r12, r14, r21) | "hurt 6 is printed, the bar moved 1.0" |
| "tripped" is never explained | 4 (r5, r13, r15, r30) | |
| The cell's `d` includes Bramble, not only your piece | 3 (r11, r20, r30) | "Hide showed d19 on a trick piece" |
| Combo names with no rule text | 3 (r2, r6, r8) | |
| Creature guard: is it absorbing my damage? | 3 (r10, r20, r30) | |
| `h-5` sign and what it includes | 4 (r4, r9, r14, r15) | |

Ground against terrain against environment:
- The harness footer still says "then the terrain (events land, bramble pricks, old pieces expire)" and "SUN = fires on a sunny cell". Both describe the 2.6.74 ground cells, which the environment pieces replaced.
- Three words are in use for one thing (ground, terrain, environment), and Bramble and Thornburst are easy to confuse: one hurts the other side, one hurts you.
- Use "environment piece" everywhere and drop the other two words.

## What I would change, ranked by value for cost

| # | Change | Kind | Value | Cost | Evidence |
|---|---|---|---|---|---|
| 1 | Make a cell that costs health loud, and name the cause ("fires its Snap: -6", "fires Thornburst: -5") | clarity | very high | low (page only) | chainp against chain: +6 to +17 points |
| 2 | The AIM shows the total it would do on the board now, with the reason (Sun, combo, pieces it re-fires) | clarity | high | low to medium (one dry run a view) | hit at least 2x the shown number on 16-37% of Hurt aims |
| 3 | One word list: "damage bar" and "charm bar" never "health"; show bar points on lit cells and the face value only on the piece; remove "terrain" and "ground" | clarity | high | low | 8 + 5 reports |
| 4 | Allow pass at any time | simplify | medium | very low | no change for the careful bot; 5 playtest complaints |
| 5 | Cut join, add and group from v1 | cut | medium (less interface, fewer rules) | low to remove; it is already built | no measurable gain with it; used in 2 of 29 playtests |
| 6 | One shared bar for damage and charm, bars about x1.15; a boss keeps the bar and can only be seen off unless charm is the larger share | simplify | high | medium (retune, rewards, page) | charm wins 0% above medium; 14% of the deck dead against bosses |
| 7 | Drop the must-link rule for the player (keep "must touch and fit") | simplify | low to medium | very low | results identical for the careless bot |
| 8 | Flip without a limit, shown as a second set of lit cells | simplify | medium | low to medium (page) | the limit never binds |
| 9 | Say the combos on the piece card, or cut them on the creature's side | clarity or cut | medium | low | a combo is behind 46-74% of the "larger than shown" hits |
| 10 | Thornburst hurts only the creature's side when the creature fires it and is a wall for you, or cut it | simplify | low to medium | low, plus a retune | careless bot +2 to +10 points without it; careful bot unchanged |
| 11 | Small creatures: no fight under 3 turns (a longer bar or a lower Charm value at level 1-3) | tune | medium (first impression) | low | 24-25% of small fights last 1-2 turns |
| 12 | One removal rule less: give creature pieces a life in rounds like yours and drop the 2-firing limit | simplify | low to medium | medium (retune) | not tested |

Do not change:
- **Use-up at 3+.** It sets the fight length.
- **Sun for both sides.** Balance is not affected; fix the aim number instead.
- **The aim itself.** Taking or blocking the aim cell is the play the playtests enjoyed most.

Things I would add, after the cuts:
- **A reason to keep a piece on the board.** Today 40-68% of my turns start with none of my pieces out. A cheap candidate: a chain of exactly 2 uses nothing up (as now) and gives the placed piece +1 life. Not tested.
- **A boss identity rule in place of the missing charm bar,** as the strategy review proposed (a boss shows two turns of aim). Not tested here.

## Not verified

- The live page. Every clarity finding comes from the CLI harness text and the haiku reports; the page words may already differ.
- Real players. Everything is bots and haiku agents.
- The variant runs (pass, must-link, use-up limit, Sun, Thornburst, one bar, set-aside) were made on the 2.6.94 commit, before AIMSTICK and the level curve. I did not repeat them on the current engine.
- The aim comparison counts turns where the creature re-picked its aim; on the current engine that is 6-11% of turns by the changelog's figure, which I did not re-measure.
- Offsets other than "at level" for the current engine. The 2.6.94 runs at 4 under showed the same patterns (chainp against chain: medium 57 against 38, large 87 against 63, boss 93 against 76).
- The one-bar prototype is a single rule ("damage plus charm fills the bar"). I did not test rewards, the JS port, or the careful bot under level.
- The tuner's gnome (deck, 14% charm pieces, made-up Teamwork sources) may not match real decks.
- Items 8, 10 (the "wall" form), 11 and 12 and both "add" ideas were not simulated.
- JS port, parity tests and the page tests were not run. No game file was edited.
