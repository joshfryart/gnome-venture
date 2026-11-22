# Creature playtest: final review (Fable)

Run `pfc-full-20261122`, engine 2.7.48 (sha 97041103; `game/` is unchanged at HEAD). 238,116 bot fights, 319 creatures, 957 Sonnet fights.
Sources: workbook README / Creature_rollup / Flags / Sonnet_findings, `collect3/all_fights.csv`, `collect3/full/*` (729 sampled turns), `pfs/<slug>/<slug>.json`.
Ground truth = engine state. Sonnet = judgement. No retune below is to be applied by hand: every number goes through `tests/pfboard_tune_v1.php`.

Notation: `C0` / `Cm4` = chain bot win at offset 0 / -4, pooled over 8 profiles x 3 builds (72 fights per creature per offset).
`Lm4` = look bot at -4 (same pool). `t` = chain bot mean turns at offset 0. `S` = Sonnet wins / 3. `hp` = Sonnet mean HP left.

## 1. Verdict per size class

Balanced, std build, chain+look bots (the sheet's reference cell):

| size | creatures | target | turns off 0 | turns off -4 | win -8 / -4 / 0 / +4 | fights in target (off 0) | under | turn-1 wins (off 0) |
|---|---|---|---|---|---|---|---|---|
| small | 67 | 4-5 | 1.97 | 2.10 | 73.4 / 89.1 / 96.3 / 98.8 | 7.5% | 91.8% | 35.3% |
| medium | 146 | 6-8 | 4.60 | 5.15 | 70.9 / 85.6 / 94.6 / 97.5 | 28.3% | 65.4% | 2.9% |
| large | 95 | 6-8 | 7.67 | 8.34 | 70.5 / 79.6 / 89.3 / 94.2 | 57.4% | 11.8% | 0 |
| boss | 11 | 6-8 | 7.65 | 8.21 | 72.7 / 81.8 / 98.5 / 100 | 56.1% | 13.6% | 0 |

Chain bot alone (tuner target about 70-80% at level): small 93.5, medium 89.5, large 78.6, boss 97.0 (Balanced std); at -4: 83.1 / 72.8 / 59.3 / 63.6.
Sonnet (3 fights each): small 96% win, 2.50 turns, fun 2.81; medium 98%, 5.10, 3.29; large 99%, 7.92, 3.50; boss 100%, 6.88, 3.61. Overall 934 / 957 = 97.6%.
Creature means in target (chain+look, off 0): small 1 / 67, medium 41 / 146, large 52 / 95 (37 over), boss 9 / 11 (2 over).

- **Small: FAIL on length.** 66 of 67 creatures average under 4 turns; 2 turns is the norm and a third of fights end on turn 1. Bots and Sonnet agree (Sonnet under target on 55 / 67, "too easy" on 65% of fights, lowest fun). Win rate is fine; the bar is too short. Tune: bar up (about x2 at level 1-20), foe values down to hold the win rate. The level split shows where: turns 1.37 (lv 1-5), 1.56 (6-11), 1.62 (12-15), 1.80 (16-20), 2.69 (21-26), 3.39 (27-30), 3.32 (31+).
- **Medium: FAIL below level 16, PASS above.** Turns by creature level: 2.06 (lv 1-11, 25 creatures), 2.67 (12-15, 23), 4.13 (16-20, 25), 5.74 (21-26), 6.81 (27-30), 6.37 (31+). The cause is the bar ease (`PFB_V1_BAR_EASE_MEDIUM` floor 0.30 until level 12, 1.0 at 26; `_SMALL` 0.30 until 14, 1.0 at 30). Tune: raise the ease floor / start it earlier, refit foe_x for lv 1-15.
- **Large: PASS on length, slightly hard and slightly long.** 7.67 turns; 37 creatures average over 8 (19 of them also over 8 for Sonnet). Chain bot 78.6% at level is on target but 59.3% at -4 and newbie 66.7% at level are low. Tune: per-creature only (lists below); consider a 5-10% shorter bar for the 19 long ones.
- **Boss: PASS.** 7.65 turns, 98.5% at level, look bot 100% at every offset. Chain 63.6% at -4 is acceptable for a boss. Only 11 creatures (66 reference fights): no class change.
- **Level 11-14 cliff (all sizes):** `Cm4` 0.61 for the 34 creatures at lv 11-14 against 0.79-0.81 at lv 5-10 and 0.74 at lv 15-18; large lv 11-14 `Cm4` 0.37 (5 creatures). foe_x stays about 2.3 while the ease keeps the bar short, so a gnome 4 under dies to burst before the short bar helps. 7 of the 12 agreed-hard creatures below sit at lv 12-14.

## 2. Stat balance

std build, chain+look, offsets 0 and -4 pooled, n = 3,828 per profile:

| profile | win | off 0 / -4 | chain bot 0 / -4 | turns | vs Balanced |
|---|---|---|---|---|---|
| Grit+Hardiness | 96.1 | 98.4 / 93.7 | 96.9 / 88.2 | 4.34 | +7.1 |
| Grit | 95.1 | 97.8 / 92.4 | 95.7 / 85.7 | 3.77 | +6.1 |
| Hardiness | 92.6 | 95.7 / 89.5 | 91.5 / 79.9 | 5.98 | +3.6 |
| Balanced | 89.0 | 93.5 / 84.4 | 87.4 / 70.6 | 5.32 | 0 |
| Charm | 88.7 | 93.8 / 83.6 | 87.9 / 69.5 | 5.18 | -0.3 |
| Nimble | 83.8 | 90.2 / 77.4 | 80.7 / 57.5 | 5.84 | -5.2 |
| Lore | 83.2 | 89.8 / 76.5 | 79.9 / 56.9 | 5.72 | -5.8 |
| Luck | 82.8 | 89.5 / 76.1 | 79.4 / 56.1 | 5.75 | -6.2 |

Controls (Balanced, off 0, one stat +-2, n = 384 each, base 94.0% / 4.84 turns): grit +1.0 / -1.0 pts and -0.31 / +0.32 turns; hardiness+2 +1.0; charm -0.5 at -2; nimble 0.0 / -0.3; lore 0.0 / 0.0; luck 0.0 / 0.0.

- **Grit dominance: acceptable for win rate, not for fight length.** +6.1 pts is inside "Grit stronger is fine", and the look bot wins 99-100% with every profile, so skill outweighs stats. The problem is turns: Grit ends fights 29% sooner (3.77 vs 5.32; medium 3.31, small 1.57, large 5.76, boss 5.97), so a Grit gnome is under target in every size. Grit at -4 (92.4%) is about equal to Balanced at level (93.5%): max Grit is worth about 4 levels. Cap the piece bonus from Grit (or scale bars with the gnome's hurt bonus) if length matters more than power fantasy.
- **Luck is dead in combat. Verified in code.** The only read is `pfboard.php:1718`, the once-a-fight pluck chance `min(35, 8 + 3 x luckmod)`. Luck and Lore profiles give the same result in 98.8% of paired fights (same creature, bot, offset, seed); luck+-2 moves nothing.
- **Lore is near dead.** `PF_STAT` maps only trick and item pieces to Lore: 5,376 of 130,424 deck pieces (4.1%), and trick pieces add 0 to either bar. Lore 30 raises those pieces from 13.8 to 22.2 and nothing else.
- **Nimble is a third weak stat** (-5.2). Guard is 22.6% of the deck but guard fades at the start of your turn, and guard pieces are played 4,916 times against 30,169 for hurt.
- **Charm 30 = Balanced** (-0.3 pts, -0.14 turns): a full charm investment buys nothing measurable.
- Low stats are a trap, not a choice: Luck / Lore / Nimble builds lose 5-6 pts at level and 8-14 pts on the chain bot at -4 (56-57% vs 70.6%).

Fix proposal (design change, then refit; none of it from Sonnet opinion):
1. Luck: give it one combat read. Cheapest: the per-fight redraw budget that `pfight.php:382` already defines (`luckmod / 3`, max 3) is not used by the board engine; wire it into `pfboard` as "redraw one hand piece" charges. Alternative: +luckmod% chance a chain piece fires twice.
2. Lore: trick pieces add `lore mod` to the next piece that fires in the chain, or widen `PF_STAT` so environment pieces you chain (Sun, Rain, Bramble) scale with Lore.
3. Nimble: Hold on guard at `nimble mod >= 5`, or part of unspent guard carries over (mod x 5%).
4. Re-run the 12 controls plus the 8 profiles on the 64 control creatures after each change; target every single-stat profile within +-3 pts of Balanced, Grit allowed up to +6.

## 3. Creature retune lists

Caveat: the sheet's retune-hard rule uses 6 fights per creature (Balanced chain+look at -4), where 0.50 means "look won 3, chain lost 3". The lists below use the pooled chain bot (72 fights per offset) and require a Sonnet signal.

### Retune-hard: bots AND Sonnet agree (12)
Rule: `Cm4` <= 0.55 or `C0` <= 0.75, and Sonnet lost a fight or rated a fight too hard. fly-swarm is in on Sonnet's 2 losses with mild bot numbers (borderline).

| creature | size lv | abilities | foe_x | C0 | Cm4 | Lm4 | S | hp | note |
|---|---|---|---|---|---|---|---|---|---|
| sea-otter-bandit | medium 13 | current | 2.83 | 0.82 | 0.32 | 0.61 | 2 | 55 | sheet cell 1 / 6 at -4, 0 / 6 at -8 |
| whiteout-fox | medium 13 | grudge-slow, D10 | 2.12 | 0.69 | 0.40 | 0.47 | 2 | 42 | look bot loses 53% at -4: hardest for a good player |
| caribou-bull | large 12 | stagger2 | 1.15 | 0.76 | 0.36 | 1.00 | 3 | 43 | one Sonnet fight ran 20 turns |
| frost-beetle | medium 12 | swarm-dense, D4 | 2.23 | 0.94 | 0.43 | 0.92 | 2 | 43 | fine at level, cliff at -4 |
| dawn-skipper-flutter | small 17 | D3 | 2.90 | 0.65 | 0.44 | 1.00 | 1 | 14 | Sonnet lost 2 of 3 at level; 53% turn-1 kills |
| marsh-spark-swarm | small 22 | D6 | 2.19 | 0.74 | 0.46 | 0.86 | 2 | 48 | newbie bot 33% at level |
| conger-brute | large 38 | current-hard, drain2 | 1.08 | 0.62 | 0.46 | 1.00 | 3 | 49 | 11-turn Sonnet mean |
| jungle-tiger | large 26 | grudge | 0.90 | 0.58 | 0.49 | 1.00 | 3 | 50 | newbie 33% |
| grass-snake | large 14 | venom-trail | 0.89 | 0.71 | 0.53 | 1.00 | 3 | 35 | newbie 33%; venom cells unmarked (section 4) |
| banana-slug | small 13 | swarm-dense, D2 | 3.08 | 0.89 | 0.53 | 0.75 | 3 | 23 | Sonnet "too hard" 2 of 3; 75% turn-1 kills: win fast or die |
| fly-swarm | small 12 | swarm-dense, D2 | 2.88 | 0.89 | 0.64 | 0.97 | 1 | 18 | Sonnet lost 2 of 3; bots mild: opener burst |
| honey-badger-brute | large 32 | grudge | 0.94 | 0.75 | 0.65 | 1.00 | 2 | 38 | Sonnet tune_suspect too_hard |

### Hard for the chain bot only (Sonnet won 3 / 3, look bot 100%): refit candidates, lower priority
reef-turtle (large 12, `Cm4` 0.11), will-o-wisp (medium 13, 0.12; Sonnet "too easy" 3 / 3), prairie-bison (large 26, 0.15), wolverine (0.24), emerald-python (0.25), grey-heron (0.32), black-jaguar (0.32), cliff-ram (0.33), alpha-dingo (0.35, `C0` 0.58), jaguar-cub-pair (0.36), midge-cloud (0.38), coconut-crab-titan (boss 26, 0.38), vine-snake (0.38, `C0` 0.43: lowest at level), tide-crab-paladin (0.39, `C0` 0.53), salt-sea-lion (0.40, `C0` 0.47).
Weakest abilities by mean `Cm4`: grows 0.47 (3 creatures), enrage2 0.52 (5), ambush2 0.56 (2), venom-trail 0.62 (17). Poisoner AI on large: 0.46 (8).

### Retune-easy: bots AND Sonnet agree (17 named; the class-wide problem is section 1)
Rule: `C0` >= 0.95, `Cm4` >= 0.90, chain turns under the size minimum; Sonnet tune_suspect too_easy with >= 2 of 3 fights "too easy" and 3 / 3 wins.

| creature | size lv | t | turn-1 wins | Sonnet turns | hp |
|---|---|---|---|---|---|
| lemming-kit-scurry | small 1 | 1.19 | 71% | 1.00 | 100 |
| dung-beetle | small 3 | 1.19 | 55% | 2.00 | 64 |
| aphid-swarm | small 1 | 1.25 | 67% | 2.00 | 81 |
| tundra-vole-swarm | small 3 | 1.28 | 68% | 2.00 | 82 |
| gnat-cloud | small 2 | 1.32 | 59% | 2.33 | 92 |
| snow-flea-swarm | small 2 | 1.36 | 42% | 1.33 | 100 |
| sand-fleas | small 3 | 1.40 | 52% | 1.33 | 94 |
| snowshoe-leveret-dash | small 3 | 1.40 | 50% | 1.67 | 100 |
| garden-snail | small 1 | 1.43 | 52% | 1.33 | 83 |
| cave-glowworm | small 5 | 1.71 | 23% | 2.33 | 70 |
| thorny-devil | small 19 | 1.78 | 17% | 2.00 | 91 |
| tree-frog-chorus | small 9 | 1.83 | 50% | 1.33 | 70 |
| muskrat-crew | medium 10 | 1.72 | 12% | 2.33 | 81 |
| shore-crab | medium 7 | 2.10 | 4% | 2.00 | 73 |
| bog-leech | medium 6 | 2.33 | 19% | 2.00 | 65 |
| fennec | medium 17 | 5.11 | 0 | 3.33 | 87 |
| storm-wisp | medium 24 | 5.56 | 0 | 4.33 | 50 |

Level 1-3 smalls may be meant as tutorial fodder; if so exempt them and start the refit at level 4.
Wider count: Sonnet marked 183 / 319 creatures too_easy (small 45, medium 94, large 38, boss 6); both sources under the turn target on 54 small, 75 medium, 2 large.

### Swingy / opener burst
- Turn-1 kill >= 30% of chain / newbie / charm fights at level: 37 creatures (34 small, 3 medium). Top: banana-slug 75%, lemming-kit-scurry 71%, stoat 69%, tundra-vole-swarm 68%, aphid-swarm 67%, dusk-moth 66%, snow-bunting-flurry 64%, piglet-squeal 59%, gnat-cloud 59%, shore-earwig 56%, earwig 56%, dune-snail 56%, dung-beetle 55%, dawn-skipper-flutter 53%. Medium: tiger-leech 32%, sun-lizard 32%, reindeer-calf-herd 30%.
- Sonnet tune_suspect swingy: 91 creatures (small 20, medium 41, large 28, boss 2); 43 had a turn range >= 4 over its 3 fights.
- Swingy by both (Sonnet swingy and chain-bot HP-lost stdev in the top quartile, 23): marsh-spark-swarm, mite-swarm, dawn-skipper-flutter, sandfish-skink-shoal, sea-urchin-bed, shore-earwig, weaver-ant-nest, tiger-leech, stickleback-shoal, barn-rat, carrion-beetle-crew, snow-moth, bramble-pup-pack, luna-moth (chain turns 4-15), cloud-kite (2-9), jumping-spider, whiteout-fox, zorilla-stink-squad, booby-colony (2-11), poison-dart-frog, mudskipper-troop, fishing-spider, cassowary-chick-creche.
- "Win turn 1-2 or die" (high foe_x, short bar; both outcomes common): banana-slug, dawn-skipper-flutter, fly-swarm, sea-urchin-bed (newbie 33%, hp 31), jumping-spider (`C0` 0.60, bar_x 1.90, look bot 69% at level), mite-swarm.
- Opener driver (Sonnet notes, not measured by bots): the start piece plus a turn-1 Double Swing / Ambush chain fills 40-65% of a small or low-level medium bar before the creature acts.

## 4. Text, clarity and bug items (ranked)

Sonnet logged 935 confusion notes on 294 creatures (619 tagged harness, 316 rule) and 44 bug reports on 32 creatures. The harness changed during the run (commits 41f90c25 23:36 and 6a957ce9 00:24): the 48 pilot creatures played the old text, the 271 wave creatures the new one.

Already fixed, no action (0 reports after the fix): `palaim` PHP warning (6), FELL AWAY label "creature" on your own Heavy piece (3), AIM line "your pieces it fires deal 0 to it" (5 bugs + 15 notes), "creature health +N" wording for the damage bar (29).

| # | item | evidence | where | status |
|---|---|---|---|---|
| 1 | Class-rule text is generic for ability variants. Chip says Grudge "25% harder (up to 3 times)" on every beast; grudge-slow is 15% x 5, grudge-fury 35% x 2. Same for swarm-dense, venom-long, current-hard, grows-twin. | dingo-pup-pack F3: "GRUDGE x4", 37 -> 59. 106 creatures carry a variant (25 fury, 15 slow, 23 swarm-dense, 22 venom-long, 15 current-hard, 6 grows-twin). | game text: `PFB_KIND_TEXT` (pfboard.php:343) is used by the page (`pfdeck_view.php:471`) and the harness (`pf_play.php:116`); the variant text exists at pfboard.php:114-116 but is not shown there | **verified in code** |
| 2 | Venom cells are not marked on the board, so a player steps on them blind. | 18 notes, 17 after the fix (night-adder, emerald-python, rock-viper, water-monitor, turtle-hatchling-dash). | harness: `pf_play` board list. The engine exports `ven` (pfboard.php:2170); check the page draws it | harness gap; page unchecked |
| 3 | The creature's chain fires your pieces and fills your bar or ends the fight, with no notice before it happens. | 127 notes on 100 creatures (47 after the fix). In the turn sample the creature fired the player's pieces on 11.9% of turns. | game text (one rule line + a log tag) and harness AIM line | by design, undocumented |
| 4 | Per-cell preview `d` / `h` reads wrong: `d` is net of creature guard, includes Bramble / Thornburst, and `h` mixes Thornburst cost with creature pieces your chain fires. | 209 notes on 154 creatures; 166 more on unexplained bar jumps (Bramble / Thornburst). Sample: predicted damage off on 15.0% of turns, charm 12.8%, hp 0.8%. | harness text; engine preview numbers are right for hp | harness |
| 5 | `a-N` is labelled EXACT but misses the second hit on a Quick turn. | 6 bug reports after the fix: marsh-spark-swarm F2 (a-42, lost 61; a-0, lost 26), ice-floe-seal F1 (a-16, lost 32), cane-toad F3 (a-14, lost 35), bombardier-beetle F3, red-fox F3. | harness `pp_cellx` (`pf_play.php:73`). The engine's whole-turn forecast is exact (see 6) | harness bug, open |
| 6 | Bot flag "forecast-error" (67 creatures) is a metric artefact. | In the 392 sampled turns with a forecast, every error sits on a Quick turn (15 of 32 Quick turns, mean 8.1 HP; 0 of 360 others) and on each of those the forecast equals the damage of the whole creature turn (`aim_forecast_after == cr_dmg_dealt`). The collector compares the forecast with the FIRST chain only. | harness: `tests/pf_collect.php` (compare with the whole turn), then regenerate Flags | **verified in data; engine correct** (`pfb_aim_total`, pfboard.php:1946) |
| 7 | Win condition text: "DAMAGE x / max (full = it backs off)" contradicts the shared bar; players do not expect seen_off after charm play or charmed after hurt play. | 54 notes on 53 creatures (52 after the fix). Sonnet charm intent: 79 charmed, 17 seen_off, 7 lost of 103; win intent ended charmed 29 times. | game text (bar label) and harness header | text |
| 8 | Guard: your guard seems not to absorb the hit; creature guard shown but damage goes through; Rain hands the creature 39-84 guard from your own chain. | 117 notes on 97 creatures; about 11 bug reports (cloud-leopard F3 guard 67 and HP 0; whiteout-fox F2; barn-rat F2; desert-tortoise F1 guard 84; snowshoe-leveret-dash F3). | unknown. Guard fades at turn start (pfboard.php:2095) and the header may show a later state | **not verified**: replay cloud-leopard F3 and whiteout-fox F2 from the saved state files before calling it an engine bug |
| 9 | Creature skips with no reason ("creature intends: -", "AIM: none shown (it is tripped, or has no move)"), then sometimes plays anyway. | 42 notes (35 after the fix): condor, mole-rat-gang, golden-orb-weaver, camel-calf, lammergeier F3 (bug). | harness log line; name the cause (Lull, Slow, trip, no legal cell) | harness |
| 10 | "cells: none" for every hand piece: place is REFUSED and only pass works; the rule line still says a piece must link "unless nothing can". | 23 notes after the fix (ice-bear, tree-snake, jackrabbit), 1 bug (kelp-fly-swarm F2). | harness text. Engine is consistent: with v1 `must` = 0 any fitting cell is legal (`pfb_must_link`, pfboard.php:885); "none" means no cell fits by edges | **verified: not an engine bug** |
| 11 | Trip / stagger and SLOW lines do not name the piece that caused them. | about 12 notes (horned-viper, marmot-bruiser, giant-otter-gang, kraken-spawn, giant-mire-leech). | harness log (the engine event carries the name) | harness |
| 12 | Combo names (Riposte, Ambush, Double Swing) are never explained; AIM "hurt 10" becomes 60-78 through Sun, Quick or Ambush. | about 20 notes (carpenter-ant-gang, banana-slug, caracal). | game text: combo glossary on the chip | text |
| 13 | Poison lines: "The poison works on you." with no amount; poison ticks without a log line. | about 10 notes, 1 bug (leatherback F3, fern-cassowary F3, sun-lizard F2). | harness log | harness |
| 14 | Placed-piece line missing when the fight ends mid-chain; one Chop logged as placed and chained (40, preview d20). | 4 bugs (army-ant-column F2, bog-pike F1 / F2, scarab-roller F3) + yellowjacket-mob F3. | harness log; yellowjacket-mob needs a replay (possible Wind loop double fire) | cosmetic; 1 unverified |
| 15 | Stale AIM or creature piece shown after FIGHT OVER; 0.1 rounding gap between the log line and the BAR header. | 6 notes (fly-swarm F3, rock-agama F3, moss-golem F2). | harness | cosmetic |

Engine bugs confirmed: none. Game-text bug confirmed: #1. Possible engine issues to replay: #8 (guard), #14 (yellowjacket-mob double fire), evade still applied after its piece was used up (pack-rat F2, golden-mantella F2).

## 5. Where bots and Sonnet disagree

- **Skill level.** Sonnet wins 97.6% (98.1% at level, 96.5% at -4): it plays like the look bot (99.7 / 98.2), not like the chain bot (87.4 / 70.6) or newbie (79.0 / 61.0). Sonnet cannot detect "too hard for an average player": it flagged 3 creatures too_hard against the sheet's 18-19 bot flags, and only 23 of 957 fights were lost.
- **Too easy.** Sonnet: 183 creatures; sheet bot rule: 40; pooled rule here: 23. Sonnet's flag barely tracks the bots: 32 of its too_easy creatures have `C0` 0.6-0.8 and 28 have `Cm4` under 0.6. It reads "short fight, little HP lost" as easy (r = -0.59 with its own turns, +0.35 with `C0`).
- **14 creatures Sonnet calls too easy while the chain bot wins under 50% at -4:** will-o-wisp (0.12), cliff-ram (0.33), alpha-dingo (0.35), jaguar-cub-pair (0.36), midge-cloud (0.38), macaque-troop, dune-wyrmling, condor, dune-wyrm, mountain-hare, burrowing-owl, badger-cub-gang, fisher, pelican-parliament. The look bot wins 86-100% on all but will-o-wisp (72%). These are skill checks: the longest-chain habit feeds the creature (Bramble from Grows, Grudge from blocking, Swarm). Do not buff them from Sonnet and do not nerf them from the chain bot alone: add the newbie bot at level as the guard rail (will-o-wisp 67%, alpha-dingo 33%, condor 33%).
- **Agreement that matters.** Fight length: r = 0.86 between chain-bot turns and Sonnet turns per creature. Both put small and low-level medium far under target and 19 large over 8 turns. Fun rises with length: Sonnet fun 2.59 at <= 2 turns, 2.99 at 2-3, 3.30 at 3-5, 3.52 at 5-8, 3.39 above 8.
- **Forecast.** Bots flag 67 creatures (metric artefact, item 6). Sonnet's real complaint is the per-cell `a-N` on Quick turns (item 5). Different faults, both in the harness.
- **Truly hard for good play** (look bot under 90% at -4, 21 creatures, all small or medium, level 22 or lower): whiteout-fox 0.47, sea-otter-bandit 0.61, rock-earwig 0.64, sea-urchin-bed 0.72, will-o-wisp 0.72, banana-slug 0.75, sea-slug-drift 0.75, ant-scouts 0.75, dune-scorpion 0.75, piglet-squeal 0.78. Sonnet called 5 of these 10 too easy from 3 fights at mostly offset 0: its sample is too small to see a 25% loss rate.
- **Builds.** Bots: pals / norare within 3 pts of std (chain+newbie+charm, small 79.4 / 80.7 / 82.0, large 72.5 / 71.6 / 72.2). Sonnet: 98 / 99 / 97%. No disagreement and no build problem.

## 6. Data-quality caveats

- Sheet Fights is an aggregate (8,932 rows); bots random / greedy / defensive, offsets -8 / +4 and controls exist only in `all_fights.csv` and Creature_rollup. Workbook cell cap 500,000, about 288,000 lost to deleted sheets; the `imp_*` and `n_*` tabs are empty staging tabs.
- Turns, Options_summary and Regret are a sample: 729 turns from 120 fights (30 per size, 101 creatures, seed 0, std build). Pieces is a roll-up (480 rows). Per-option rows exist only as CSV.
- Per-creature reference cells are thin: Balanced chain+look at one offset is 6 fights, so the sheet's retune-hard threshold (under 60%) moves in steps of 16.7 pts. Use pooled cells (72 chain fights per offset) for any decision.
- Local `collect3/xlsx/Flags.xlsx` holds the 389 bot-era flags; the live Flags tab has 671 rows (adds 133 retune-easy, 75 swingy, 58 clarity, 17 bug from the wave, bots_agree = n/a). Sonnet-only flags are not cross-checked.
- Offsets: gnome level is floored at 1, so for level 1-4 creatures -4 and -8 are the same level-1 gnome (14 creatures).
- Stat model is assumed (points in pairs, Balanced spreads over 7 stats including Sense, no food / tea / wearables / calling perks). Luck / Lore conclusions hold for the engine reads, not for those unmodelled systems.
- Sonnet: 3 fights per creature, 641 at level, 305 at -4, 11 other; 103 charm-intent; builds std 740, pals 115, norare 102. Two harness versions (48 pilot creatures before the text fixes, 271 after). In the workbook the wave rows keep only the first confusion note and first bug per fight and texts are cut to 250-300 characters: use `pfs/*.json` for counts (this review did).
- The harness is not the live page: all "harness" items in section 4 need a check on the page before any game-text change. Learner fights, staged rules and wearables are not modelled.
- Turn-cap stalls: 155 fights, 154 by the defensive bot (4% of its fights); no stall with any other policy.
- forecast_error_hp in Creature_rollup and the 67 forecast-error flags are invalid as a text-accuracy measure (item 6).
- stat-flat (133 flags) mostly restates section 2 plus ceiling cases; ignore per creature.

## 7. Top 10 next actions

1. Refit small bars and foe values with the chain bot (`tests/pfboard_tune_v1.php`): target 4-5 turns at 75-80% chain win. Start with `PFB_V1_BAR_EASE_SMALL` (floor 0.30 to level 14) and `PFB_V1_BAR_MULT['small']`.
2. Refit medium level 1-15 (48 creatures at 2.1-2.7 turns): raise `PFB_V1_BAR_EASE_MEDIUM`, then foe_x to hold about 80%.
3. In the same refit, check the level 11-14 band at offset -4 (`Cm4` 0.61; large 0.37): this covers 7 of the 12 agreed-hard creatures.
4. Per-creature refit of the 12 agreed-hard creatures; add a tuner guard "newbie bot at level >= 50%" and "look bot at -4 >= 85%" (whiteout-fox, sea-otter-bandit fail the second).
5. Fix the class-rule chip text so each ability variant shows its own numbers (item 1; 106 creatures). Game text, no balance effect.
6. Give Luck a combat read and widen Lore (section 2), then re-run controls and profiles on the 64 control creatures.
7. Fix the collector's forecast metric (compare with the whole creature turn), regenerate Flags, drop the 67 forecast-error flags; fix `a-N` on Quick turns in `pf_play`.
8. Replay the unverified engine suspects from the saved state files: guard not absorbing (cloud-leopard F3, whiteout-fox F2, barn-rat F2), double fire (yellowjacket-mob F3), evade after use-up (pack-rat F2).
9. Harness and page text pass: mark venom cells, name the cause of skip / trip / slow, explain "the creature's chain can fire your pieces", shared-bar wording, combo glossary (items 2, 3, 7, 9, 11, 12). Check each on the live page first.
10. Decide the Grit length question (cap or bar scaling), and after actions 1-4 re-run the full grid plus a Sonnet pass at offset -4 only on the retuned creatures, with a weaker-play instruction so it can see "too hard".
