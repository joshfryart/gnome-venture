# Puzzle Combat rule book: changes from the 2.6.986 edition to the 2.6.990 edition

Second edition, 15 November 2026. Code read from `origin/main` (merge `33b0f9af`, version 2.6.990). 58 pages (was 42).
No game file was changed. All work was done on a throwaway copy of `game/includes`, `tests/` and the rule book folder.

Line numbers below are those of `origin/main` at 2.6.990.

## How it was checked

| What | How | Where |
|---|---|---|
| Code since the first edition | `git diff dd65aae0 origin/main` over `game/`, `tests/pf_play.php`, `tools/pfboardv1_part.js` (dd65aae0 is the commit that added the first edition) | n/a |
| Four appendix fights | Replayed by hand on the 2.6.990 engine with `tests/pf_play.php`, same creatures and seeds | `play/f1..f4.json`, `.log`; old states in `play/old986/` |
| 684 policy fights | `play/sim.php` re-run, same six policies, 19 creatures, seeds 1 to 6 | `play/runs.jsonl` (old: `play/runs_986.jsonl`) |
| Keeper, Plenty, Simmer | Two short fights with a copy of the harness whose gnome owns three legendary pieces | `play/pf_play_legend.php`, `play/lmv.sh`, `play/L1`, `play/L2` |
| Slots, knacks, creature heal, Evade and poison, venom cap, Swarm table, flat poison | Calls of the real engine functions on set-up positions (not whole fights; tagged "code" in the book) | `play/checks.php`, output in `play/checks.out` |
| 42 legendary pieces | Read from `data/pf_pieces.txt`, matched to the 14 treasure rows of `region_crops.txt` | `play/legend.json` (feeds appendix C) |

Changes to the play drivers: `mv.sh` and `pp.sh` find the repository root from their own path (they had `/home/user/gnome-venture` hard-coded). `sim.php` gained two counters (`poisonLost`, `aimOverNP`) and on a pass now compares the loss with the chip as it stood before the pass (it read the next round's chip). `agg.py` prints the two new columns. The policies themselves are unchanged. `make.sh` accepts a state label after a chapter 10 heading. `render.js`: footer version.

## Sections changed

| Section | Change |
|---|---|
| Cover, title, footer | 2.6.990, 15 November 2026, second edition, what was replayed |
| Contents | 97 entries (was 80), still one page |
| 1 intro, 1.2 | Version; bar can go down (creature heal); table of four creatures re-dealt; Critter hits 4 to 5 |
| 1.3 | Tags split honestly (Bramble played, Thornburst and poison code) |
| 1.4 | Keeper exception to "you cannot save a piece" |
| 1.5 | "larger share" made exact (a tie backs off) |
| **1.6 (new)** | What is new since the 2.6.986 edition |
| 2.1, 2.2 | Knack on a piece; creature heal empties hurt then charm; legendary Item pieces eat no snack |
| 2.3 | Legendary pieces have mind tops and bottoms; legendary Heal pieces are hard to place |
| 2.4 | Keeper keeps its flip; new flip example |
| 2.5 | Rows for Keeper, Plenty, Simmer; Quick text; Poison flat; Evade stops a poison tick; Trip and Evade downgraded to "code" |
| 2.6 | All "seen in play" examples replaced by 2.6.990 ones; Bait combo now seen |
| 2.7 | Note on the fixed "stays 3" texts |
| 2.8 | Level third is rounded down; legendary rank |
| **2.9 (new)** | Keeper, Plenty and Simmer, with figure 5 |
| **2.10 (new)** | Poison, in full |
| **2.11 (new)** | Built-in knacks |
| 3 intro, 3.1 | New pieces arrive off with NEW; crown filter; at least 1 Hurt in any deck; default kit fallback |
| 3.2 | Tool pieces are not slotted |
| 3.5 | New Swarm sentence; Heal tag; "stays 3 rounds" is right now |
| **3.6 (new)** | Slots: the Larder and the Keepsakes |
| **3.7 (new)** | Legendary crop pieces |
| 4 (all) | Figure 6 redrawn; Blank cells seen; both examples replaced |
| 5.1 to 5.10 | Every example and number replaced by 2.6.990 ones; new rows in 5.1, 5.8 (count a Critter's pieces), 5.9 (poison, Rain, Swarm); figures 7 and 8 redrawn |
| 6.1 | Order list: no Critter second piece, Evade and poison, Simmer, Keeper and Plenty in the redraw |
| 6.2 | The number is the whole turn; what it still leaves out; new measured shares |
| 6.3, 6.4 | Small creatures' pieces are not small any more; poison numbers; heal; examples |
| 6.5.1 | Rewritten for the new Swarm, with figure 9 |
| 6.5.2 to 6.5.7 | New measured numbers and examples; venom cap; Lull does not change a boss's forced piece; figure 10 redrawn |
| 7.1 to 7.4 | Examples and tags; aim pointed at an environment piece on 21 of 32 turns |
| 8.1 to 8.5 | Healing touches charm; new charm shares; boss numbers; Simmer and Leech |
| 9.1 to 9.5 | New tags, knacks, Swarm, chips (Simmer, NEW, Larder, crown) |
| 9.6 cheat sheet | Updated, new block "New tags and slots", still one page |
| 10 (all) | Every old item marked resolved / changed / still open with evidence; seven new items 10.15 to 10.21 |
| A.1 to A.4 | Rewritten from the replays; comparison table |
| **A.5 (new)** | The two fights with legendary pieces |
| B | All numbers re-measured |
| **C (new)** | Table of the 42 legendary crop pieces |
| Figures | 1 (clean-up text), 5 (new), 6, 7, 8, 10 redrawn from the replays, 9 (new). 2, 3, 4, 11 unchanged |

## Claims that were wrong for 2.6.990 (old text -> new text)

### Rules

| # | Old text (2.6.986 edition) | New text | Code |
|---|---|---|---|
| 1 | Critter Swarm: "It plays two small pieces a turn. The aim shows the first." Each piece x0.6. | One piece a turn at full value. Its Hurt +1 per 2 of its other pieces on the board, max +2. Also inside your chain. | `pfboard.php` 73, 84, 681, 1001; the x0.6 line of `pfb_new` is gone |
| 2 | Earwig: "a typical hit of its: 3 (two a turn)" | 4 to 5, plus 1 or 2 from Swarm | replay f1 |
| 3 | Poison: "half of what the piece hit for", after combos and Sun | Half the printed number, flat | `pfight.php` 464 |
| 4 | Creature poison: "a third of the hit each" | A third of the printed number for a Hurt, half for a Trick | `pfight.php` 453, 510 |
| 5 | (not stated) | Your unused Evade stops a poison tick on you | `pfboard.php` 1392 |
| 6 | Creature Heal "empties part of the hurt on the Yield bar"; "Guard, Evade and the creature's healing do not touch charm" | Heal empties hurt first, then charm | `pfight.php` 687 to 692 |
| 7 | "Your whole hand is thrown away and redrawn every round. You cannot save a piece." | True except Keeper pieces | `pfboard.php` 1413 |
| 8 | "You draw a new hand of 5 (4 if you were tripped)" | Filled to 5 around Keeper pieces; one more after Plenty | `pfboard.php` 1412 to 1414 |
| 9 | 6.1 step 5 "Extras: a Critter's second piece" | Removed | `pfboard.php` 1001 |
| 10 | Aim number: "covers only the first piece"; leaves out "the second piece of a Critter and the extra piece after a Quick piece" | The number is the whole turn; leaves out poison, venom, "no aim" turns | `pfboard.php` 1265 to 1267 |
| 11 | Quick (your piece): "Draws you one piece when you place it" (game text) | Game text: "no extra effect for you (one piece a turn)". Engine unchanged | `pfight.php` 58, 466 |
| 12 | "Some screens still print other numbers" for stays N rounds; card "rounds number is not used" | NEXT strip and creature card print 3 | `pfboard.php` 1467; `pfdeck_view.php` 262 |
| 13 | "The help sheet still describes" the aim strike | Only when the switch is on | `tools/pfboardv1_part.js` 387 |
| 14 | Later pieces: "crop pieces, craft pieces, region pieces" are switched on | New pieces arrive off, marked NEW | `pfdeck.php` 284 |
| 15 | Deck limits: kit, Hurt, Rare, Masterwork | Plus Larder slots (3 / 4 at level 10 / 5 at 20) and Keepsake slots (2 / 3 at 15) | `pfdeck.php` 19 to 22, 298, 299, 321 |
| 16 | Venom: no cap stated | Poison on you never above 3 ticks, venom included | `pfboard.php` 770 |
| 17 | 14 tags | 17 tags (Keeper, Plenty, Simmer) and 7 built-in knacks | `pfight.php` 55 to 57, 98 to 118, 526 |
| 18 | Piece sources end with region | Plus 42 legendary crop pieces, after 3 harvests | `pfdeck.php` 15, 16, 501 to 507; `data/pf_pieces.txt` |
| 19 | Harness prints "on side ?" | Fixed | `tests/pf_play.php` 159 |
| 20 | "It backs off: hurt is the larger share" | Charm must be strictly larger to win it over; a tie backs off | `pfight.php` `pf_check_end` |

### Numbers (all re-measured on 2.6.990)

| Where | Old | New |
|---|---|---|
| Careful: wins / health lost / turns / own chains / passes | 99% / 24% / 8.2 / 5% / 0.05 | 99% / 29% / 7.8 / 6% / 0.05 |
| Never breaks the aim | 99% / 26% / 9.4 / 7% / 0.19 | 100% / 38% / 8.6 / 8% / 0.13 |
| Charmer | 99% / 31% / 8.1 / 6% / 0.04 | 100% / 32% / 7.8 / 8% / 0.04 |
| Turtle | 100% / 17% / 11.1 / 4% / 0.29 | 100% / 24% / 10.2 / 5% / 0.25 |
| Biggest number | 89% / 62% / 6.8 / 13% / 0 | 89% / 63% / 6.6 / 12% / 0.04 |
| Longest chain | 64% / 79% / 8.0 / 24% / 0 | 63% / 80% / 7.7 / 25% / 0.02 |
| Careful by size: wins | 100 / 97 / 100 / 100 | 100 / 97 / 100 / 100 |
| Careful by size: health lost | 28 / 28 / 22 / 18 | 31 / 32 / 25 / 28 |
| Careful by size: turns | 7.2 / 8.0 / 8.2 / 9.2 | 6.6 / 8.1 / 7.4 / 8.7 |
| Biggest number: wins by size | 83 / 89 / 93 / 90 | 94 / 81 / 93 / 90 |
| Biggest number: health lost by size | 71 / 62 / 58 / 62 | 64 / 68 / 53 / 66 |
| Longest chain: wins by size | 67 / 61 / 60 / 70 | 72 / 56 / 73 / 57 |
| Real loss above the chip (share of turns) | 40 / 51 / 20 / 21 | 1 / 39 / 19 / 16; poison taken out: 1 / 1 / 2 / 2 |
| Turns starting with none of my pieces out | 58 / 53 / 49 / 48; overall 51%; chain 68% | 50 / 49 / 51 / 49; overall 50%; chain 67% |
| Charm endings, careful | 56 / 6 / 3 / 0 | 50 / 6 / 3 / 0 |
| Charm endings, charmer | 67 / 6 / 10 / 0 | 50 / 11 / 7 / 0 |
| By class, health lost: Beast, Boss, Bird, Plant, Critter, Water, Reptile | 9, 18, 19, 21, 27, 32, 46 | 24, 28, 40, 19, 28, 19, 47 |
| The one lost careful fight | Sun Lizard, seed 5 (Reptile) | Carrion Crow, seed 1 (Bird) |
| Longest boss fight / careful | 16 / 14 turns | 15 / 13 turns |
| A.1 Earwig | won turn 3, 26 of 32 | won turn 8, 21 of 32 |
| A.2 Crow | won turn 7, 45 of 47 | won turn 10, 39 of 47 |
| A.3 Boar | won turn 6, 54 of 88 | won turn 7, 71 of 88 |
| A.4 Hawk | won turn 4, 105 of 114 | won turn 7, 98 of 114 |

Every worked example that quoted the old fights (about 40 places in chapters 2, 4, 5, 6, 7, 10) was replaced by one from the replays.

### Tags lowered from "played" to "code"

Not seen again on 2.6.990, so no longer claimed as played: Trip and Evade on my own pieces; "poison that fills the bar wins before it acts"; "bait fails into an Evade"; the chip wording "fires your X: N to it" (page text); the no-Grudge-after-use-up case on a Beast.

## Chapter 10: state of each old item

| Item | State | Evidence |
|---|---|---|
| 10.1 Aim number leaves out the second piece | Resolved | `pfboard.php` 1265 to 1267, 1001; Crow turn 10 chip; 1% to 2% of turns above the chip once poison is taken out |
| 10.2 Quick on your pieces | Changed | Text fixed (`pfight.php` 58); engine still draws and discards (466) |
| 10.3 Stays N rounds | Resolved | `pfboard.php` 1467, `pfdeck_view.php` 262 |
| 10.4 Help sheet and aim strike | Resolved | `tools/pfboardv1_part.js` 387 |
| 10.5 Trip and Lull | Still open | Kept by the owner; Lull was my best move four times in two fights |
| 10.6 Poison | Changed | Flat ticks (`pfight.php` 464); Evade on your side (`pfboard.php` 1392); still lands through the creature's Evade; text still has no number |
| 10.7 Rain | Still open | `pfboard.php` 282; Hawk 17 against 32 |
| 10.8 Grudge | Still open | `pfboard.php` 1063; Boar turns 5 and 6 |
| 10.9 Hidden multipliers | Still open | plus Warm, Spiky, poison on gentle creatures |
| 10.10 Not guessable | Still open | Boar turn 4 (own Thornburst), Hawk turn 5 (bait) |
| 10.11 Board does not last | Still open | 50% / 67% |
| 10.12 Charm route | Changed | Heal now eats charm (`pfight.php` 687) |
| 10.13 Smaller slips | Changed | "on side ?" fixed; five others open; five new |
| 10.14 Not verified | Changed | rewritten |

New items: 10.15 Finisher counts only the hurt part (`pfight.php` 439 against the text at 116). 10.16 What the Swarm sentence leaves out. 10.17 Existing gnomes lose their crop, craft and region pieces from the deck without notice; the Bold kit's Oat Cake takes a Larder slot. 10.18 Keeper, Plenty, Simmer small print. 10.19 The aim chip when its chain heals you ("does no damage" on the page, "-2" in the harness). 10.20 Legendary Item pieces are called snacks and eat none. 10.21 Legendary Heal pieces often have no legal cell.

## Left NOT VERIFIED (or code only)

- The live pages: layout, chips, rings, replay, NEW mark, Larder pips, crown filter, the three new tag marks, a hand of 6 on a phone. Everything about pages is read from source.
- `pfd_sources` (3 harvests, mastery rank, saved switches) and `pfd_toggle`: need the database; read only. The pure deck builder under them was run.
- Rewards, knock-out, health carry-over (`adventure.php`, `pfight_game.php`): read in the first edition; those parts did not change, not played.
- That each legendary piece "matches its crop's stat" (changelog claim).
- 39 of the 42 legendary pieces: data file only. The seven knacks, a creature heal on a charm-filled bar, Evade stopping a poison tick, the venom cap: run on set-up positions, not in a whole fight.
- Trip, Evade, Bash, Thorns, Mend, Bond, Pluck on my pieces; Calm Charm and Win Over; the Water push: code only.
- The JS twin `tools/pfengine.js`: not run.
- Why the per-class numbers moved (Beast 9% to 24%, Bird 19% to 40%): thinner harness deck, new rules or chance; 12 fights a class cannot tell. How much of the careful player's 24% to 29% is the thinner deck.
- How often a legendary Heal piece has no legal cell; how much harder the charm route is with the new heal rule; the owner's old "43% of rounds" environment figure.
- The test gnome is the harness gnome. Since 2.6.989 the harness deals its crop, craft and region pieces off, so every fight in this edition was played with a thinner deck than in the first edition (13, 16, 19, 19 pieces against 14, 19, 27, 27).
