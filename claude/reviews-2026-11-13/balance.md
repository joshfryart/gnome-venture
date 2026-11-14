# Puzzle combat v1 (2.6.94, 4x4 board), early gnome levels 1-10: balance review

Engine at HEAD 662920d1 (2.6.94). No repo file was changed. Sim scripts and raw JSON lines are in this folder:
`early.php` (driver), `myplayer.php` (tuner's player builder, with the calling/kit/home rotated per seed), `run.sh`, `agg.py`, `short.py`, `percr.py`, and result folders `base/`, `rot/`, `va vb vc vd r1 r2 r3 r4 t2 th nopal nopal2/`.

## Method
- `early.php` requires `tests/pfboard_tune_v1.php` and reuses its bots (`tv_choose`), `tv_places`, `tv_act`, `pfd_foe_row` layered creature decks (region rotates by seed), blank-centre opening, 40-turn cap. Same win rule (seen_off or charmed).
- Cells: gnome level L = 1..10 against every creature in `creatures.txt` with |creature level - L| <= 3 (levels 1-13: 10 small at 1-5, 19 medium at 5-13; no large or boss below 14).
- Seeds per creature per L: 48 (baseline `rot/`), 32 (variants). n per gnome level 288-768.
- The tuner's `tv_sources` ties calling, kit and home to the level (`lv % 6`, etc.). That made levels look different because of the calling (L4 wayfinder and L5 brewroot decks have only 4 Hurt pieces). `myplayer.php` rotates them with the seed so each level averages over all 6 callings. Without that rotation (`base/`, 40 seeds) the numbers are similar but noisier: chain at level was 95/82/78/82/59/71/78/36/54/75 for L1-10.
- The cell format is win % / health lost % / turns. Noise is about +-4-5 points for "all" cells and +-10 for "creature = L" cells (n 32-144).

## Baseline 2.6.94 (rotated callings, 48 seeds)
| gnome L | chain all +-3 | chain creature = L | chain medium foes | look all +-3 | look medium foes |
|---|---|---|---|---|---|
| 1 | 66% / 66% / 6.5 (n=432) | 71% / 61% / 7.5 (n=96) | - | 99% / 17% / 6.6 (n=432) | - |
| 2 | 63% / 65% / 7.4 (n=528) | 80% / 52% / 6.6 (n=144) | 27% / 89% / 7.6 (n=48) | 99% / 16% / 7.7 (n=528) | 98% / 20% / 10.5 (n=48) |
| 3 | 70% / 60% / 7.4 (n=672) | 82% / 51% / 6.9 (n=144) | 34% / 89% / 8.6 (n=192) | 100% / 14% / 7.1 (n=672) | 99% / 21% / 10.5 (n=192) |
| 4 | 73% / 58% / 7.9 (n=768) | 85% / 58% / 6.9 (n=48) | 43% / 84% / 9.1 (n=288) | 100% / 13% / 7.6 (n=768) | 100% / 18% / 10.6 (n=288) |
| 5 | 61% / 65% / 7.7 (n=768) | 68% / 66% / 8.9 (n=96) | 32% / 89% / 8.7 (n=384) | 97% / 21% / 8.2 (n=768) | 94% / 32% / 10.7 (n=384) |
| 6 | 67% / 61% / 6.7 (n=720) | 74% / 67% / 8.3 (n=144) | 51% / 78% / 7.4 (n=480) | 98% / 19% / 7.0 (n=720) | 98% / 25% / 8.5 (n=480) |
| 7 | 56% / 72% / 7.4 (n=672) | 68% / 73% / 10.1 (n=96) | 49% / 79% / 7.7 (n=576) | 97% / 25% / 8.1 (n=672) | 97% / 28% / 8.6 (n=576) |
| 8 | 58% / 71% / 7.0 (n=720) | 29% / 90% / 6.4 (n=96) | 55% / 74% / 7.1 (n=672) | 98% / 25% / 7.3 (n=720) | 98% / 26% / 7.5 (n=672) |
| 9 | 65% / 70% / 6.8 (n=768) | 50% / 79% / 6.1 (n=96) | 65% / 70% / 6.8 (n=768) | 99% / 21% / 6.6 (n=768) | 99% / 21% / 6.6 (n=768) |
| 10 | 74% / 66% / 7.0 (n=720) | 82% / 63% / 5.9 (n=96) | 74% / 66% / 7.0 (n=720) | 100% / 19% / 6.6 (n=720) | 100% / 19% / 6.6 (n=720) |


Per creature, chain bot, gnome at the creature's level (`percr.py chain rot/*`): small creatures 58-85% (aphid-swarm 58% is the low one). First mediums: orb-spider (5) 56%, bog-leech 75%, grumpy-lemming 77%, paper-wasp 71%, bullfrog 79%, shore-crab 56%. Then **barn-rat (8) 33%, sun-lizard (8) 25%, carrion-crow (9) 48%, tunnel-mole (9) 52%**. From level 10 it recovers: dune-scorpion 81%, herring-gull 83%. Sun-lizard is still 38% with the gnome 1 level above it and 54% with the gnome 2 above. Even the look bot loses 37-43% health against barn-rat and sun-lizard at level, against 13-21% for the level 5-7 mediums.

## Where it breaks
1. **Level 8-9 mediums are a wall (worst spot).** Chain wins 29% at L8 and 50% at L9 against creatures of the same level. Cause: the creature's `dmg_bonus = intdiv(level, 4)` (`adventure_data.php:343`, fed into `pfd_foe_v`) steps from 1 to 2 at level 8, so piece values jump (Beast h6,h7 at 6 -> h8,h9 at 8; Reptile h5,h5 at 7 -> h7,h7 at 8). The gnome has no matching step: its stats `intdiv(lv+3,14)` stay 0 until 11, its tools stay tier 1 until 10, and its health goes up by +3 a level. Level 10 is fine again (82%) because of the third tool slot. Moving tool tier 2 to level 8 (`TSHIFT=2`, `t2/`) did NOT fix it: L8 at level stayed 34%.
2. **The first mediums when the gnome is under level.** A gnome at L2-5 against mediums of level 5-8 wins 27/34/43/32% with chain and loses 84-89% of its health. Orb-spider (level 5, habitat "any") has a 41 bar, against 24 for the small cave-glowworm at the same level, and the L5 gnome has 35 health. That is a 1.7x jump from small to medium at the same level.
3. **Starter deck (L1-3) is fine against small creatures.** Chain wins 66-70% overall and 71-82% at level, close to the ~70% target. But chain loses 60-66% of its health even when it wins. Look wins 99-100% and loses 13-17%.
4. **Pal unlocks are not felt.** With no pals at all (`nopal/`), chain overall at L3-7 is 73/76/61/70/59%, against 70/73/61/67/56% with pals: the same within noise. Removing only the second pal (`nopal2/`) costs about 3-5 points at L8-10 (55/60/72% against 58/65/74%). The modelled pals (Bark Badger guard 5, Samara Spin hurt 5) are too small to mark a milestone.
5. **Fight length.** Small fights run 6.5-7.4 turns (chain) and 5.7-7.4 (look) at L1-5, against the 4-5 target. Medium fights at L2-5 run 10.5-10.7 turns for look, against the 6-8 target. That is the "under level" grind.
6. **Skill gap.** Look wins 94-100% in every row with 13-25% health lost; chain wins 56-74% with 58-72% lost. Reading the numbers matters a lot, as designed. The "smart 90%+" target was not run (smart is slow), but look already meets it.
7. **Environment self-damage is not what decides the wins.** Chain losses took 26.8% of max health from environment pieces, chain wins 15.0%, look wins 8.5%. Halving Thornburst and Bramble (`V1 thorn 0.06, bramble 0.06`, `th/`) cut the self-damage from 19.1% to 13.0% of max health but did not move chain win % (L8 at level 27%, medium foes the same). The creature also loses its environment damage.

## What I tested (chain bot, 32 seeds)
| Variant | L2-5 medium win | L8 at level | L9 at level | L10 all |
|---|---|---|---|---|
| baseline | 27 / 34 / 43 / 32 | 29 | 50 | 74 |
| medium FOE 0.52 (was 0.60) | 28 / 38 / 43 / 37 | 45 | 69 | 83 |
| medium BAR 0.80 (was 0.994) | 53 / 53 / 58 / 47 | 42 | 64 | 87 |
| medium BAR 0.70 | 56 / 66 / 64 / 56 | 50 | 75 | 91 |
| medium FOE 0.52 + BAR 0.85 | 50 / 45 / 52 / 46 | 56 | 78 | 91 |
| tool tier 2 from L8 | 28 / 38 / 49 / 34 | 34 | 58 | 74 |
| ramp r1: bar x by creature level only | 62 / 55 / 57 / 48 | 38 | 58 | 77 |
| ramp r2: r1 + foe x 0.85/0.90 at 8/9 | 62 / 55 / 57 / 52 | 58 | 69 | 79 |
| **ramp r4 (recommended)** | 62 / 55 / 57 / 52 | **67** | **78** | 81 |

A flat medium change cannot fix this. Every bar or foe cut big enough to help L8 pushes L10 to 83-91% (and, by inference, all 26 mediums above the 76% at-level figure you already have). The trouble is tied to the creature's level, not its size.

## Recommendation (tested as r4; numbers in `r4/`)
Add an early-level factor for MEDIUM creatures by creature level, applied where `pfb_v1_cfg` sets `foe` and `bar` (new constant, for example `PFB_V1_EARLY`). Size and level 10+ stay unchanged:
- bar x: level 5 **0.75**, 6 **0.80**, 7 **0.85**, 8 **0.80**, 9 **0.85**
- foe x: level 8 **0.80**, 9 **0.85**
In absolute terms, medium bar mult 0.994 becomes 0.745 / 0.795 / 0.845 / 0.795 / 0.845, and medium foe mult 0.60 becomes 0.48 / 0.51 at levels 8 / 9.

Result (r4, rotated callings, 32 seeds):
| gnome L | chain all +-3 | chain creature = L | chain medium foes | look all +-3 | look medium foes |
|---|---|---|---|---|---|
| 1 | 69% / 65% / 6.5 (n=288) | 69% / 63% / 7.5 (n=64) | - | 100% / 16% / 6.4 (n=288) | - |
| 2 | 64% / 65% / 7.3 (n=352) | 78% / 52% / 6.7 (n=96) | 62% / 75% / 6.4 (n=32) | 99% / 16% / 7.5 (n=352) | 100% / 22% / 8.0 (n=32) |
| 3 | 76% / 55% / 7.1 (n=448) | 84% / 51% / 7.0 (n=96) | 55% / 74% / 7.8 (n=128) | 100% / 13% / 6.4 (n=448) | 100% / 17% / 8.2 (n=128) |
| 4 | 78% / 55% / 7.8 (n=512) | 88% / 59% / 7.1 (n=32) | 57% / 73% / 8.5 (n=192) | 100% / 13% / 6.9 (n=512) | 99% / 17% / 8.8 (n=192) |
| 5 | 71% / 60% / 7.5 (n=512) | 75% / 62% / 8.1 (n=64) | 52% / 80% / 8.3 (n=256) | 100% / 15% / 7.4 (n=512) | 99% / 21% / 9.2 (n=256) |
| 6 | 80% / 53% / 6.3 (n=480) | 83% / 59% / 6.9 (n=96) | 71% / 65% / 6.8 (n=320) | 100% / 15% / 6.0 (n=480) | 100% / 19% / 7.0 (n=320) |
| 7 | 69% / 63% / 6.9 (n=448) | 80% / 64% / 8.8 (n=64) | 64% / 69% / 7.1 (n=384) | 98% / 21% / 7.0 (n=448) | 98% / 23% / 7.4 (n=384) |
| 8 | 68% / 62% / 6.5 (n=480) | 67% / 68% / 7.2 (n=64) | 65% / 65% / 6.6 (n=448) | 100% / 19% / 6.4 (n=480) | 100% / 20% / 6.5 (n=448) |
| 9 | 75% / 61% / 6.3 (n=512) | 78% / 59% / 6.0 (n=64) | 75% / 61% / 6.3 (n=512) | 100% / 18% / 5.8 (n=512) | 100% / 18% / 5.8 (n=512) |
| 10 | 81% / 59% / 6.5 (n=480) | 78% / 65% / 6.0 (n=64) | 81% / 59% / 6.5 (n=480) | 100% / 16% / 6.0 (n=480) | 100% / 16% / 6.0 (n=480) |

Chain by gnome level for creatures at its level: 69/78/84/88/75/83/80/67/78/78 (was 71/80/82/85/68/74/68/29/50/82). Medium foes 2-3 levels above the gnome are still hard at L7-8 (43% / 37%), because creature levels 10-11 are not ramped. That fits "under level is risky". Look stays 98-100% with 13-21% lost. Medium fight length for look at L2-5 drops from 10.5-10.7 to 8.0-9.2 turns (still above 8).

Optional, NOT tested: a smoother creature damage bonus (`level / 4` as a float instead of `intdiv`) would remove the level-4 and level-8 steps at the source. It is game-wide (`adventure_data.php:343` also feeds the old combat), so it needs its own sim. The small-fight length (6.5-7.4 turns, target 4-5) has no fix tested here.

## What I did NOT verify
- The smart bot (the "90%+" target). Only chain and look were run.
- The r4 change in the real game, the JS port (`tools/pfengine.js`) or the parity test. The ramp is only an override in the sim (`foe_x` / `bar_x` per creature in `early.php`); no engine code was written.
- Large and boss creatures (none below level 14), and the global 0/-4/-8 tables for creature levels 10+ (unchanged by r4 by construction; not re-run).
- Whether the tuner's `tv_sources` matches real early players: pals, tool tiers, starter kit picks, crops, knacks. The gnome model is the tuner's, with calling, kit and home rotated.
- Health carried between fights (chain loses 55-72% of its health a fight, which may matter more than the win %), the creature level spread a gnome really meets, and whether orb-spider ("any" habitat) really reaches L2-4 gnomes.
- Region/weather Sun doubling of specific creatures (sun-lizard `we=sun,heat`): the sim rotates the region but does not model the weather.
