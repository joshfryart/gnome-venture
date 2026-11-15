# Tailor sims (review-tailor-2.7.00.md section 5), on the built 2.7.00 wearables

2026-11-15. Driver: `tools/sims/tailor_sims_2701.php` (uses the tuner's gnome and bots from `tests/pfboard_tune_v1.php`). No game file changed.

## How
- Real engine, real layered creature decks, the tuner's deck-model gnome (`tv_sources`), new-fight rules (`v1` true).
- A wearable is added as the built game adds it: `$src['wears']`, switched on, through `pfd_build` (Keepsake slots, Rare cap apply).
- Bots: `chain` (careless: longest chain) and `look` (careful). `look` wins 100% at level in every run, so its win % says nothing; its turns and health lost do.
- Paired seeds: every variant of a sim plays the same creatures with the same seeds. Noise on a win %: about 2 points at n=252, 4 at n=78, 8 at n=46.
- "hit" = the largest rise of the creature's bar from one of your pieces in a fight (bar points, after Sun, combos, Teamwork). hitavg = mean over fights; hitmax = the run's largest.
- Raw lines: scratchpad only (not kept). Re-run: `php tools/sims/tailor_sims_2701.php SIM BOT MULT > x.jsonl; php tools/sims/tailor_sims_2701.php agg < x.jsonl`.

## Verdict
- **Pass (sim 1):** no single wearable moves the careless bot's win % by more than 1.6 points or its fight length by more than 0.45 turns. Within the review's rule (3 points, half a turn).
- **Guard wearables are almost never played** by either bot (0.07-0.2 plays a fight for Puddle Hop, Sure Foot, Wrap Up, Hood Up, Brim Down with `chain`). The Hurt and Charm ones are played 0.5-0.7 times a fight.
- **The Rare cap drops belt tools, not wearables (sim 6).** `pfd_build` counts Rares in deck order: kit and owned pieces, then wearables, then belt tools, then pals. Two or three Fine wearables push the gnome's Rare tools (Chop, Hoe Hook: its strongest Hurt) out of the deck, with no warning. The review assumed the opposite.
- **Pluck (sim 2):** about 0% at luck 0 with one Pluck piece, 14-18% at luck 5-9; three Pluck pieces at luck 9 reach 30% (careless bot).
- **Evade does not cut poison in practice (sim 8):** Puddle Hop does not lower poison taken against Reptiles (chain 6.73 vs 6.63 none; look 5.70 vs 5.32). The bots do not time it; a player would have to.
- **Sim 3 (Bond) cannot run:** the built Hat is Brim Down (Guard, thorns) / Tip Back (Soothe). No wearable carries Bond.

## 1. Each cut alone, Common (r1) and Fine (r3), against no wearable
`chain`, gnome at the creature's level, every creature, n = 252 each.

| run | win % | turns | health lost % | hitavg | plays a fight |
|---|---|---|---|---|---|
| none | 92.9 | 6.48 | 62.2 | 23.7 | 0 |
| Puddle Hop r1 / r3 | 92.9 / 92.5 | 6.69 / 6.71 | 62.7 / 62.6 | 23.2 | 0.19 / 0.18 |
| Sure Foot r1 / r3 | 92.5 / 92.5 | 6.69 / 6.71 | 62.9 / 62.3 | 23.2 | 0.19 / 0.18 |
| Brim Down r1 / r3 | 92.9 / 92.5 | 6.65 / 6.66 | 63.0 / 62.5 | 23.2 | 0.23 / 0.22 |
| Tip Back r1 / r3 | 91.3 / 91.3 | 6.68 / 6.71 | 63.0 / 62.4 | 23.1-23.2 | 0.21 |
| Firm Grip r1 / r3 | 92.1 / 94.0 | 6.56 / 6.29 | 62.4 / 55.4 | 23.0 / 23.4 | 0.36 / 0.66 |
| Knuckle Down r1 / r3 | 92.1 / 93.7 | 6.43 / 6.04 | 63.8 / 60.7 | 23.7 / 25.9 | 0.48 / 0.72 |
| Wrap Up r1 / r3 | 92.9 / 92.5 | 6.69 / 6.71 | 62.6 / 62.1 | 23.2 | 0.19 / 0.18 |
| Hood Up r1 / r3 | 92.5 / 92.5 | 6.65 | 63.0 / 62.4 | 23.2 | 0.23 / 0.21 |
| Rummage r1 / r3 | 91.7 / 92.5 | 6.64 / 6.58 | 64.2 / 62.7 | 24.4 / 25.8 | 0.38 / 0.46 |
| Tidy Up r1 / r3 | same as Rummage (no item to lift in this run) | | | | |
| Yarn Wrap r1 / r3 | 91.3 / 91.3 | 6.50 / 6.24 | 64.1 / 62.4 | 22.9 / 23.3 | 0.48 / 0.71 |

`look` (half the creatures, n = 124): health lost 18.8-24.4% against 20.9% with none; turns 6.43-7.25 against 6.96. Firm Grip Fine is the only clear gain (19.9%, 6.68 turns); Knuckle Down Fine costs health (24.4%) but ends fights soonest (6.43).

## 2. Pluck stacking
Level 16 gnome with Trail Pack (Rummage) plus 0-2 extra Rummage copies, creatures level 12-20, the creature has an item. % of fights with a lift. n = 78 (`chain`), 46 (`look`).

| luck | 1 Pluck | 2 Pluck | 3 Pluck |
|---|---|---|---|
| 0 | 0 / 0 | 5 / 2 | 4 / 4 |
| 5 | 14 / 4 | 13 / 4 | 17 / 9 |
| 9 | 18 / 7 | 19 / 4 | 30 / 17 |

(chain / look.) The chance per placed Pluck is `min(35, 8 + 3 x luck)`%, halved on a boss; the bots place it as a root only 0.2-0.85 times a fight, which is what limits the rate. Extra Pluck pieces cost the careless bot 1-4 win points (dilution; within noise at n=78).

## 3. Bond stacking
Not run: no built wearable has Bond (see Verdict).

## 4. A Fine Trick before the biggest Hurt (Ambush)
Fine Trail Pack (Tidy Up, Trick 2 + rank), creatures within 6 levels below the gnome.

| level | run | n | win % chain | hitavg chain / look | hitmax chain / look |
|---|---|---|---|---|---|
| 28 | none | 195 / 110 | 91.3 | 39.8 / 34.7 | 98 / 92 |
| 28 | Tidy Up Fine | | 88.2 | 38.5 / 36.8 | 98 / 98 |
| 28 | Tidy Up Fine + Firm Grip Fine | | 88.7 | 38.2 / 35.3 | 98 / 98 |
| 40 | none | 13 / 8 | 100 | 54.2 / 44.2 | 122 / 70 |
| 40 | Tidy Up Fine | | 84.6 | 43.5 / 58.6 | 61 / 120 |

- The Pack does not raise the largest hit for the careless bot; for the careful bot at 28 the mean largest hit rises 6% (34.7 to 36.8).
- At level 28 the careless bot loses 2.6-3.1 win points with a Fine Trick in the deck (dilution); borderline against the 3-point rule.
- Level 40 has only 13 / 8 fights (creatures go up to level 39): not conclusive.

## 5. Level 40, four Keepsake slots, four belt slots
Creatures level 30 and up, gnome 40, n = 46.

| run | win % chain | turns chain / look | health lost chain / look |
|---|---|---|---|
| none | 100 | 6.13 / 5.96 | 52.1 / 19.0 |
| one Fine cut (each of 11) | 93.5-97.8 | 5.93-6.24 / 5.65-5.87 | 49.2-54.4 / 18.6-21.1 |
| four Fine (Boots, Gloves, Cloak, Pack) | 95.7 | 6.85 / 6.70 | 51.4 / 14.8 |

- With four Fine wearables the 4th (Pack) is out by the Rare cap AND two Rare belt tools are out (sim 6): fights are 0.7 turn longer for both bots. Fails the half-turn rule.
- The harness itself has no limit at 32; it was the creature list (top level 39).

## 6. The 3 Rare cap: what is left out
`pfd_build` on the tuner's gnome with two Fine wearables switched on (Firm Grip, Wrap Up):
- level 16 (2 Keepsake slots): both worn; no Rare tool yet. Nothing out.
- level 28 and 40: Rares in deck order: Firm Grip, Wrap Up, Chop (tool), Hoe Hook (tool) -> **Hoe Hook out (cap)**.
- level 40 with four Fine wearables: Puddle Hop, Firm Grip, Wrap Up in; Rummage out (cap); **Chop and Hoe Hook out**. Deck: 20 pieces, no Rare Hurt tool left.
- The wearable is left out only when 3 Rare kit or owned pieces (knacks, legends) come first. A Rare tool on the belt is always left out first.
- The page lists the out piece (`out = cap`), but the player picked the wearable and loses a tool. Josh to decide: order wearables after belt tools, or warn.

## 7. All-body columns against one family per type
Firm Grip and Wrap Up, both Lined, level 16 (two pals), creatures 12-20. Per-type: Hurt body, Guard craft, Charm / Soothe / Trick mind.

| family | win % chain | turns chain / look | health lost chain / look |
|---|---|---|---|
| all body (built) | 96.2 | 6.69 / 7.11 | 55.8 / 19.8 |
| per type | 96.2 | 6.64 / 7.13 | 55.9 / 21.4 |

No measurable difference (n = 78 / 46).

## 8. Evade against Reptiles
Reptile class only, gnome at the creature's level, n = 252 (chain) / 126 (look). Poison = your health lost to poison ticks a fight.

| run | win % chain | poison chain / look | health lost chain / look |
|---|---|---|---|
| none | 94.0 | 6.63 / 5.32 | 61.3 / 22.2 |
| Puddle Hop (evade), Lined | 97.2 | 6.73 / 5.70 | 59.1 / 22.0 |
| Sure Foot (hold), Lined | 97.2 | 6.77 / 5.97 | 58.2 / 21.2 |

Both Boots cuts give the careless bot +3 points; Evade gives no poison benefit over Hold. The bot was not taught that Evade stops a tick (the review's item); a player who times it could do better.

## 9. Tailor economy (Monte Carlo, 20,000 runs)
Lining attempts to take wearables Common -> Lined -> Fine (2 steps each). Each attempt: 2 energy and Cottongrass 2 + Butterfly Scales 1 (to Lined) or Seed Pearl 1 + Snow Moth Dust 1 (to Fine). The base craft (Common) is separate: 4 energy and its materials.

| power | chance | pity | attempts, 1 wearable (mean / 90th pct) | attempts, 3 wearables (mean / 90th pct) | energy, 3 |
|---|---|---|---|---|---|
| 1 | 38% | no | 5.2 / 9 | 15.8 / 23 | 31.6 |
| 1 | 38% | yes | 4.8 / 7 | 13.8 / 18 | 27.5 |
| 3 | 54% | no | 3.7 / 6 | 11.2 / 15 | 22.3 |
| 3 | 54% | yes | 3.7 / 6 | 10.6 / 14 | 21.3 |
| 6 | 78% | no | 2.6 / 4 | 7.7 / 10 | 15.4 |
| 6 | 78% | yes | 2.6 / 4 | 7.7 / 10 | 15.3 |

- Pity matters only at power 1 (saves 2 attempts in 3 Fine, and cuts the bad 10% from 23 to 18).
- Power 1 to 6 halves the attempts (15.8 to 7.7). Petals for the buildings are not in this table (power 3 = one level 3 Tailor, 9,900 Petals, or three level 1 Tailors, 5,400).

## 10. "Shove" (built: Knuckle Down, Hurt 3 bash) after a Hold guard (Sure Foot)
Level 28, creatures 22+, n = 195 (chain) / 110 (look).

| run | win % chain | hitavg chain / look | hitmax chain / look |
|---|---|---|---|
| none | 91.3 | 39.8 / 34.7 | 98 / 92 |
| Knuckle Down Fine | 87.2 | 37.6 / 38.5 | 98 / 98 |
| Knuckle Down Fine + Sure Foot Fine | 85.6 | 36.6 / 38.2 | 98 / 90 |

- No runaway hit: the largest single hit stays at 98 (the deck's own best). Hold before Bash adds nothing measurable.
- Two Fine wearables cost the careless bot 5.7 win points at level 28 (dilution of the deck with pieces it plays badly). More than the review's 3-point rule.

## Not done / not verified
- Sim 1 with `look` covers half the creatures (stopped for time); `look` wins 100% everywhere, so only turns and health lost are read from it.
- Appendix-fight and policy sims were not re-run on 2.7.00 rules (not cheap).
- The bots do not value Evade, Hold, Thorns or Mend timing; real players may get more from the Guard cuts than shown.
- Decks: the tuner's gnome (`tv_sources`), not real players' boxes.

## 11. Retune (Josh: retune the Guard wearables and Evade now), re-run of sims 1, 5, 7, 8, 10
2026-11-15, same driver and seeds; engine and `WEAR_DEFS` changed, nothing else.

### Why Evade did not cut poison
- The tick (`pfb_end_round`) skipped when `me.evade > 0`. But your Evade is used up by the creature's first Hurt in its turn (`pf_apply`: `evade--`), which comes before the tick. So the tick only skipped in rounds where the creature hit nothing: almost never.
- Fix (PHP `pfight.php` / `pfboard.php`, JS `tools/pfengine.js`): your Evade also sets `me.evd` for the round; the tick reads `evade > 0 || evd`; `evd` is cleared when the round ends. The tag text ("its first hit misses and poison ticks do nothing") is now true. Test: `tests/pfboard_v1_kinds.php` (seen failing on the old code).

### Why the Guard wearables were rarely played
- `chain` scores a move as chain length x 1000 + bar gained. A Guard piece gains no bar, so it is only played when it makes the strictly longest chain: 0.18-0.23 plays a fight whatever its value. `look` plays them more (0.45-0.78) but they saved little health; the two Thorns cuts saved none.
- Value does not help: base 3 -> 5 for all five (Brim Down 2 -> 5) moved nothing for either bot (chain plays 0.18-0.22, wins 92.5-93.3; look health lost within 0.5).
- Change: every Guard cut carries the existing Spiky knack (2 on the creature's bar when played), as Firm Grip carries Leech. Base values unchanged (Brim Down stays 2). Texts say so; Puddle Hop now says poison does nothing that round.

### Sim 1 after (chain n = 252 / look n = 252)
| run | win % chain | turns chain / look | health lost chain / look | plays chain / look (before) |
|---|---|---|---|---|
| none | 92.9 | 6.48 / 6.87 | 62.2 / 19.5 | 0 |
| Puddle Hop r1 / r3 | 93.7 / 93.3 | 6.65 / 7.01 | 60.9-60.4 / 17.4 | 0.35 / 0.70 (0.19 / 0.44) |
| Sure Foot r1 / r3 | 92.9 / 93.3 | 6.65 / 7.08-7.10 | 61.6-59.6 / 18.7-17.5 | 0.35 / 0.78-0.98 (0.19 / 0.57-0.78) |
| Brim Down r1 / r3 | 94.0 / 93.7 | 6.60-6.62 / 6.82-6.92 | 62.0-60.4 / 19.9-19.1 | 0.37 / 0.60-0.67 (0.23 / 0.45-0.55) |
| Wrap Up r1 / r3 | 93.3 / 92.9 | 6.65 / 7.06-7.10 | 61.2-59.9 / 18.1-16.6 | 0.35 / 0.74-0.80 (0.19 / 0.54-0.59) |
| Hood Up r1 / r3 | 93.7 | 6.60-6.62 / 6.81-6.85 | 61.7-60.2 / 19.6-18.8 | 0.36 / 0.62-0.68 (0.23 / 0.49-0.58) |

- Guard cuts are now played as often as the Common Hurt cuts by `chain` (0.35-0.37 against Firm Grip 0.36), twice as often by `look`, and cut health lost by up to 2.6 (chain) / 2.9 (look) points.
- **Rule holds:** no single wearable moves `chain` wins by more than +1.1 points (92.9 -> 94.0). Fight length +0.12-0.18 turns (was +0.17-0.23). The other six cuts did not change (same numbers as section 1).

### Sim 8 after (Reptiles; chain n = 252, look n = 126)
| run | win % chain | poison chain / look | health lost chain / look |
|---|---|---|---|
| none | 94.0 | 6.42 / 4.60 | 61.1 / 22.4 |
| Puddle Hop (evade), Lined | 98.0 | **5.93 / 4.34** | 58.2 / 19.9 |
| Sure Foot (hold), Lined | 98.0 | 6.43 / 5.39 | 57.7 / 20.0 |

- Evade now cuts poison: 8% (chain) / 20% (look) less than Sure Foot, the same deck with a Hold piece. Against no wearable the cut looks smaller for `look` because a worn piece makes fights longer (more ticks).
- Both Boots cuts give `chain` +4.0 win points on Reptiles (was +3.2 before the retune). Noise is about 2 points at n = 252; over every creature (sim 1) the gain is +0.4-0.8. Open for Josh: this Reptile-only number is past the 3-point line.

### Sims 5, 7, 10 after
- **Sim 7** (Firm Grip + Wrap Up, Lined, n = 46): all-body 97.8% / per-type 97.8% (chain); still no measurable difference.
- **Sim 10** (level 28): Knuckle Down Fine 90.0% vs none 92.7%. Knuckle Down Fine + Sure Foot Fine gives the same numbers: with the Rare cap now counting wearables last, Sure Foot Fine is the 4th Rare and is left out (`out` in all 110 fights). The Hold-then-Bash question cannot be tested at level 28 with two Fine wearables any more.
- **Sim 5** (level 40, n = 46): each single Fine cut 93.5-97.8% (chain) against 100% with none, as before the retune (n = 46: noise 8 points). The four Guard cuts give identical rows here (0.11 plays a fight).
