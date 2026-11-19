# Wear pieces: balance (2026-11-18)

The 280 Tailor wear pieces (224 Common / Uncommon, 56 Rare) measured on the real engine with the playtest bots, then tuned through the generators only (`build3.py` -> `outputs2.py` -> `tools/build_wear_items.py`). No effect code, effect meaning or Petal price changed. Scripts: `claude/wear-pieces/sim/` (`wear_sim.php` plays, `agg.py` sums up, `pieces_table.py` lists pieces, `report.py` writes the tables below).

## Short answer

- **One wear piece moves a fight very little.** The bots place it in 7-30% of fights (Commons and Uncommons; a hand of 5 out of a deck of 13-19, one piece a turn, fights of 2-8 turns). The effect alone of a Common or Uncommon piece averages -0.1 to -0.3 health points; 166 of 224 move health and wins by under half a point, and 83 never changed a single fight out of 96. That is structure (how often one piece in the deck is played), not the numbers: raising a and b does not change it (see the trigger bumps below, still 0.00).
- **Goal 1 (no Common / Uncommon over +3 win or about 6 health): met.** Largest Common / Uncommon: +3.2 win (`esa-acacia-frame-pack`, half of it noise from the smoothed piece part), 4.2 health. The two biggest effects alone: `oc-red-dust-poncho` (yHalf>skip) +2.1 win / -3.0 health, `ca-fringed-leather-vest` (edge>evade) -3.5 health.
- **Rares (limit about +6 win / -12 health): met after the fixes, at Common and at Fine.** Worst at Fine now: `mena-goat-hair-tent-cape` +6.8 win / -11.2, `ea-snow-straw-boots` +6.5 / -10.0, `cb-curl-toe-reef-booties` -11.7 health, `sa-striped-leg-wraps` -11.5. Before: MENA cloak +8.7 / -14.4, EA footwear +9.3 / -12.4, SE cloak +6.1 / -12.5. The strong Rares are the Trip (skip) ones, and they are strong for the careless bot (+15 win alone): a skipped creature turn is worth far more than any number on the piece.
- **Goal 2 (no useless piece): not reachable by numbers for most Commons.** I bumped the 10 triggers that almost never fire (+1 on the payoff number, or +1 value; 53 pieces). Their effect stayed at 0.00: those triggers (linked to a Trick / Soothe / Charm / Heal, a pair of the same type, first round, the creature with 0 or 3+ pieces, its last round) hardly ever happen in these fights. Their worth is the extra piece value. Josh may want to look at the triggers themselves (out of my brief: no meaning changes). **Done since: see Trigger redesign** (the ten triggers replaced; the groups now change 9-40% of the fights their pieces are placed in, before 0-11%; one single-piece group still 0%).
- **Goal 3 (later regions stronger): in absolute numbers yes now, in share of health flat.** a and b used to follow the tier and fell from 9% of the gnome's health (NA) to 4% (OC); they now follow the region level (6-9% everywhere). Measured as health points, the Rare effect is -2.4 (NA-SE), -3.1 (SA-CSA), -1.8 (SEA-OC) at Fine: late Rares are not stronger relative to their fights. Commons and Uncommons are too small to show a trend.
- **Goal 4 (no impossible / trivial fight): met.** The careful bot wins 95-100% with or without a wear piece (largest change +6 points, early Rares, where it is not already at 100%); the largest careless-bot change is +12.5 win points after the fixes (`esa-baobab-clogs` at Common), +17 before (the Trip Rares). No piece makes a fight trivial or lost. No engine errors in about 145,000 fights.
- **The two engine readings asked about:** Rare "gain {b} guard" on top of the piece's own guard: the 18 Rares with it measure 0 to -8.1 health at Fine (`csa-turmeric-wrap-coat` -8.1 is the top, it also heals {a} per hand piece; `wca-kapok-jerkin` +4.3 is the Keeper problem below); none is over the limit. Plenty + an extra hand piece = 7: the Plenty Rares (CA, CB, SA, ESA, OC backpacks) measure -0.5 to -0.9 health at Fine; not too strong (the bots get little out of a bigger hand).

## Method

- Engine and bots: the real `pfboard.php` / `pfdeck.php` engine and the bots of `tests/pf_bots.php` (on `tests/pfboard_tune_v1.php`), no DB. Careful = `look` (best state after the whole round), careless = `greedy` (most damage / charm this turn).
- Gnome: level = the region level (`REGION_LEVELS`), the tuner's normal kit (`tv_sources`: starter, belt, pals, crops, crafts, knacks by level). Wear piece: the item switched on in its Keepsake slot (one slot is free at every level; Fine counts as Rare under the 3-Rare cap, never cut in these decks: checked, the run stops if the piece is missing).
- Creatures: every creature within 3 levels of the region level (16-20 of them, 8 at OC), at their own level, all sizes and classes met there.
- Per piece and bot: 48 fights (96 a piece), each played twice on the same creature and seed: **plain** (the piece with its effect taken off: same type, value, edges) and **fx** (the real piece). Same deck size, same shuffle, so **eff = fx - plain is paired** (most fights are identical; only the effect differs).
- Baseline (no wear piece): 480 fights per region and bot. It cannot be paired (one piece fewer, another shuffle), so the "one more piece" part (plain - base) is noisy per piece (about ±5 points). It is smoothed: region mean over all its pieces + type offset over all regions. **est = smoothed piece part + eff** is the per-piece estimate used for the goals. Every piece has its own seeds.
- Runs: all 280 at Common (53,760 fights), the 56 Rares at Fine (10,752), baseline 13,440; again after the changes; the last 4 Rare fixes once more at both ranks.
- Units: points of win % and of health lost % (of max health); negative health = less lost = the piece helps. Noise: eff health about ±0.3 for a Common (±1-2.5 for a Rare), win about ±1-3 per piece (one greedy fight = 2 points).

## Changes (all in `build3.py`, data regenerated)

1. **a and b follow the region level.** a = 1 + level//10 (+1 Rare); b = 2 + level//5 (+1 Uncommon, +2 Rare). Before: a = 1 + tier//5, b = 2 + tier//3. NA and CB unchanged.

| region | level | max health | a old -> new | b Common old -> new | b Uncommon | b Rare | b Common as % of health old -> new |
|---|---|---|---|---|---|---|---|
| NA | 1 | 23 | 1 -> 1 | 2 -> 2 | 3 -> 3 | 4 -> 4 | 9% -> 9% |
| CA | 4 | 32 | 1 -> 1 | 2 -> 2 | 3 -> 3 | 4 -> 4 | 6% -> 6% |
| NWE | 6 | 38 | 1 -> 1 | 2 -> 3 | 3 -> 4 | 4 -> 5 | 5% -> 8% |
| CB | 8 | 44 | 1 -> 1 | 3 -> 3 | 4 -> 4 | 5 -> 5 | 7% -> 7% |
| SE | 10 | 50 | 1 -> 2 | 3 -> 4 | 4 -> 5 | 5 -> 6 | 6% -> 8% |
| SA | 12 | 61 | 2 -> 2 | 3 -> 4 | 4 -> 5 | 5 -> 6 | 5% -> 7% |
| EE | 14 | 67 | 2 -> 2 | 4 -> 4 | 5 -> 5 | 6 -> 6 | 6% -> 6% |
| MENA | 17 | 76 | 2 -> 2 | 4 -> 5 | 5 -> 6 | 6 -> 7 | 5% -> 7% |
| EA | 20 | 85 | 2 -> 3 | 4 -> 6 | 5 -> 7 | 6 -> 8 | 5% -> 7% |
| CSA | 23 | 94 | 2 -> 3 | 5 -> 6 | 6 -> 7 | 7 -> 8 | 5% -> 6% |
| SEA | 26 | 108 | 3 -> 3 | 5 -> 7 | 6 -> 8 | 7 -> 9 | 5% -> 6% |
| WCA | 29 | 117 | 3 -> 3 | 5 -> 7 | 6 -> 8 | 7 -> 9 | 4% -> 6% |
| ESA | 32 | 126 | 3 -> 4 | 6 -> 8 | 7 -> 9 | 8 -> 10 | 5% -> 6% |
| OC | 35 | 135 | 3 -> 4 | 6 -> 9 | 7 -> 10 | 8 -> 11 | 4% -> 7% |

(Max health: the sim gnome at that level. The Rare a is +1 and the Uncommon / Rare b +1 / +2 as before.)

2. **Rarely firing triggers, +1** (superseded by the trigger redesign below: the triggers are replaced and the +1 is gone) (`RARE_TRIG`: linkT, linkS, linkHeal, link2, linkC, pair, r1, foeB0, foeB3, lastRound; each changed a fight in under 6% of the fights its piece was placed): +1 on the payoff's b or a, or +1 value when the payoff has no number or counts rounds (life). 53 pieces.
3. **Rares over the limit** (`RARE_FIX`, value v and numbers): MENA cloak v-5 b-2, EA footwear v-6 b-2, SE cloak v-3, SA footwear v-1, CB footwear v-1, MENA backpack v-1, ESA footwear b-2 (its b x chain grew with the new b). The value cut works through how often the bots pick it (the effect itself is a Trip); the per-slot bonus and the region step of v were left alone.

Before / after per changed piece: last table. 213 pieces changed numbers in all (most only by the new a / b; their text changes with them).

## Trigger redesign (2026-11-18, second pass)

The ten triggers of change 2 were replaced by new conditions (meaning, text and engine clause; `design3.py` TRIG / TRIG_FX, mapped old -> new by `RETRIG` in the same place in TRIG, so every other pairing and every (trigger, payoff) pair stayed unique: 280 codes, 280 texts). The +1 they had got was taken off (it was there only because they did not fire). Effect codes keep their payoff; the trigger part has a new name. No new engine condition was needed: every new trigger is a condition `pfb_wx_cond` / `wxCond` already knew (`fhas`, `hand`, `fpcs`, `round`, `hplt`, `lastturn`, `ygt`), so `pfboard.php` and `pfengine.js` only changed in the data rows. Petal prices unchanged.

**How chosen (measured, not guessed).** A probe (`pfb_wx_fire` hook, removed after) played the 53 pieces with their old codes, 150 fights per piece and bot (15,900 fights, 3,636 placings), and at every firing of the wear piece checked 82 candidate conditions. Kept: true in about 25-60% of the turns the piece is placed, close to even across the group's pieces, one short sentence, and near the old meaning where the data allowed (a type in hand for the "linked to a type" ones, the creature's board for foeB0 / foeB3, early rounds for r1). Rejected with the data: "linked to any piece" (94% when placed), "the creature has a piece on the board" (75%), "round 2 or later" (83%), "its chain has 2 or more pieces" (94%), "Yield past a quarter" (70% over all pieces; kept only for the one SE piece, where it is 46%), "you hold a Hurt" (90%), "a creature piece touches it" (19%), "a Guard of yours in its chain" (always true on a Guard), "a piece of yours touches it" (32-96% by piece).

Rates: from the probe on the same fights (old condition vs new condition when placed, and at any firing in a fight it was placed). "Changed a fight": share of placed fights where the paired fx / plain result differs (`wear_sim.php`, 48 fights a piece and bot, same seeds as the first pass). Effect alone: eff health / eff win, Common rank, mean of the group.

| old trigger | new trigger (code: engine) | pieces | true when placed, before -> after | true at some firing in a fight it was placed, before -> after | changed a fight it was placed in, before -> after | effect alone, health / win, before -> after |
|---|---|---|---|---|---|---|
| `linkT` (linked to a Trick) | `foeHasH` If the creature has a Hurt on the board (`fhas:hurt`) | 12 | 3% -> 42% | 9% -> 80% | 3% -> 29% | -0.05 / +0.0 -> -0.37 / -0.0 |
| `linkC` (linked to a Charm) | `handC` If you hold a Charm in your hand (`hand:charm:1`) | 10 | 6% -> 59% | 9% -> 76% | 5% -> 40% | +0.06 / +0.0 -> -0.76 / +0.6 |
| `pair` (a piece of its own type linked to it) | `foeHasG` If the creature has a Guard on the board (`fhas:guard`) | 6 | 6% -> 29% | 13% -> 45% | 11% -> 20% | -0.30 / +0.2 -> -0.19 / +0.0 |
| `foeB3` (the creature has 3 or more pieces on the board) | `foeB2` If the creature has 2 or more pieces on the board (`fpcs:2`) | 6 | 2% -> 23% | 19% -> 63% | 4% -> 26% | +0.09 / +0.3 -> -0.54 / +0.5 |
| `foeB0` (the creature has no pieces on the board) | `foeNoH` If the creature has no Hurt on the board (`!fhas:hurt`) | 5 | 15% -> 56% | 19% -> 59% | 4% -> 9% | -0.04 / +0.0 -> -0.12 / -0.2 |
| `r1` (in the first round) | `r12` In the first two rounds of the fight (`round:1:2`) | 5 | 13% -> 32% | 17% -> 39% | 1% -> 10% | +0.05 / +0.0 -> -0.12 / +0.0 |
| `lastRound` (in its last round on the board) | `hurtLast` If you played a Hurt last turn (`lastturn:hurt`) | 5 | 0% -> 47% | 12% -> 54% | 5% -> 22% | -0.07 / +0.0 -> -0.21 / +0.0 |
| `linkS` (linked to a Soothe) | `handHeal` If you hold a Heal in your hand (`hand:heal:1`) | 2 | 0% -> 39% | 0% -> 49% | 0% -> 23% | +0.00 / +0.0 -> -0.48 / +0.0 |
| `linkHeal` (linked to a Heal or Item) | `hp75` If you are under three quarters health (`hplt:0.75`) | 1 | 0% -> 26% | 0% -> 46% | 0% -> 26% | +0.00 / +0.0 -> +0.02 / +0.0 |
| `link2` (linked to 2 or more pieces) | `yQuarter` If its Yield bar is past a quarter (`ygt:0.25`) | 1 | 16% -> 46% | 57% -> 86% | 0% -> 0% | +0.00 / +0.0 -> +0.00 / +0.0 |


Still 0% changed: `se-float-net` (`yQuarter>hand`; the trigger is now true 46% of placings, but a bigger next hand changes nothing for the bots), and pieces whose payoff the bots cannot use or rarely place (ward, life, pluck, bond, hand; `ca-bloom-smock`, `sa-bark-cloth-tunic-coat`, `ca-pleated-shirt-jacket`, `na-sap-run-bucket` are placed in 3-4% of fights). Those are payoff / placement limits (see below), not the trigger.

**Over the goal after the change, tuned (`TRIG_FIX` in `build3.py`, value only):** the two Trip Uncommons. `wca-raffia-poncho` (`handC>skip`) v 7 -> 6: -4.3 -> -3.9 health, +2.3 win. `oc-flax-wading-wraps` (`foeB2>skip`) v 8 -> 6: +3.7 -> +2.6 win, health stays -4.6 (v 4 also gave -4.8: the skip itself is -3.1, the value only moves how often the bots pick it). Left at about 0.6 over the -4 health goal; the next step would be a rarer trigger or another payoff for that one piece (a meaning change, not done). **Done 2026-11-19: `foeG>skip`, est -2.3 health; see "`oc-flax-wading-wraps`: a rarer trigger" below.** Largest Common / Uncommon now: +3.2 win (`esa-acacia-frame-pack`, unchanged), -4.6 health (`oc-flax-wading-wraps`), then `oc-red-dust-poncho` -4.1 (unchanged).

Per piece (Common rank; before = with the old trigger and its +1):

| piece | rarity | fx before -> after | v/a/b before -> after | placed | changed a placed fight | eff health | eff win | est win | est health |
|---|---|---|---|---|---|---|---|---|---|
| ca-indigo-leg-wraps | Uncommon | `linkT>life` -> `foeHasH>life` | 5/1/3 -> 4/1/3 | 0.08 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | -3.7 -> -3.7 | +2.6 -> +2.6 |
| csa-chili-cone-basket | Common | `linkT>heal` -> `foeHasH>heal` | 7/3/7 -> 7/3/6 | 0.31 | 0% -> 40% | +0.00 -> -0.50 | +0.0 -> +0.0 | -0.9 -> -0.9 | -1.5 -> -2.0 |
| csa-curl-toe-slippers | Common | `linkT>dmg` -> `foeHasH>dmg` | 6/3/7 -> 6/3/6 | 0.56 | 0% -> 43% | +0.00 -> -0.88 | +0.0 -> -1.0 | -0.4 -> -1.5 | -0.0 -> -0.9 |
| ee-poppy-field-shawl | Common | `linkT>bond` -> `foeHasH>bond` | 6/2/4 -> 5/2/4 | 0.32 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | +1.8 -> +1.8 | +2.2 -> +2.2 |
| nwe-birch-bark-slippers | Uncommon | `linkT>stay` -> `foeHasH>stay` | 5/1/4 -> 4/1/4 | 0.09 | 0% -> 33% | +0.00 -> +0.00 | +0.0 -> +0.0 | -1.5 -> -1.5 | +0.8 -> +0.9 |
| oc-bark-cloth-vest | Uncommon | `linkT>mend` -> `foeHasH>mend` | 8/5/10 -> 8/4/10 | 0.20 | 12% -> 53% | -0.12 -> -1.06 | +0.0 -> +0.0 | -0.1 -> -0.1 | -0.9 -> -1.8 |
| oc-drovers-oilskin | Common | `linkT>thorns` -> `foeHasH>thorns` | 7/5/9 -> 7/4/9 | 0.28 | 5% -> 52% | +0.11 -> -0.93 | +0.0 -> +1.0 | -0.1 -> +0.9 | -0.7 -> -1.6 |
| oc-drovers-pull-ons | Uncommon | `linkT>pierce` -> `foeHasH>pierce` | 9/4/10 -> 8/4/10 | 0.54 | 0% -> 21% | +0.00 -> +0.50 | +0.0 -> -2.1 | +0.6 -> -1.5 | -1.6 -> -1.0 |
| oc-frond-rain-cape | Common | `linkT>soothe` -> `foeHasH>soothe` | 7/5/9 -> 7/4/9 | 0.39 | 3% -> 41% | -0.30 -> -0.39 | +0.0 -> +0.0 | +0.4 -> +0.3 | -1.5 -> -1.5 |
| sa-bark-cloth-tunic-coat | Uncommon | `linkT>shrink` -> `foeHasH>shrink` | 5/3/5 -> 5/2/5 | 0.03 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | -0.8 -> -0.8 | +1.1 -> +1.1 |
| sea-bamboo-ladder-pack | Common | `linkT>hand` -> `foeHasH>hand` | 6/3/7 -> 5/3/7 | 0.28 | 3% -> 37% | +0.04 -> -0.63 | +0.0 -> +2.1 | -0.7 -> +1.4 | +0.3 -> -0.3 |
| sea-rattan-back-basket | Common | `linkT>plenty` -> `foeHasH>plenty` | 8/3/7 -> 7/3/7 | 0.27 | 8% -> 31% | -0.31 -> -0.62 | +0.0 -> +0.0 | -1.6 -> -1.6 | -1.1 -> -1.3 |
| ca-bloom-smock | Common | `linkC>thorns` -> `handC>thorns` | 3/2/2 -> 3/1/2 | 0.03 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | -3.7 -> -3.7 | +2.6 -> +2.6 |
| cb-hibiscus-shawl | Common | `linkC>bond` -> `handC>bond` | 5/1/3 -> 4/1/3 | 0.17 | 0% -> 6% | +0.00 -> +0.02 | +0.0 -> +0.0 | +0.5 -> +0.4 | -0.6 -> -0.5 |
| csa-porters-frame-pack | Uncommon | `linkC>hand` -> `handC>hand` | 9/3/7 -> 8/3/7 | 0.26 | 16% -> 36% | +0.39 -> -0.74 | +0.0 -> +0.0 | -0.9 -> -0.9 | -1.1 -> -2.2 |
| ea-tea-chest | Uncommon | `linkC>mend` -> `handC>mend` | 5/4/7 -> 5/3/7 | 0.31 | 0% -> 73% | +0.00 -> -1.35 | +0.0 -> +0.0 | +0.8 -> +0.8 | -1.9 -> -3.3 |
| esa-check-blanket-wrap | Common | `linkC>soothe` -> `handC>soothe` | 7/5/8 -> 7/4/8 | 0.38 | 0% -> 50% | +0.00 -> -0.86 | +0.0 -> +2.1 | +0.5 -> +2.6 | -0.6 -> -1.4 |
| mena-indigo-wrap-boots | Uncommon | `linkC>guard` -> `handC>guard` | 6/2/7 -> 6/2/6 | 0.22 | 0% -> 29% | +0.00 -> -0.49 | +0.0 -> +0.0 | +0.7 -> +0.7 | -0.5 -> -1.0 |
| oc-flax-basket-pack | Common | `linkC>plenty` -> `handC>plenty` | 9/4/9 -> 8/4/9 | 0.25 | 8% -> 38% | +0.29 -> -0.74 | +0.0 -> +2.1 | +0.1 -> +2.2 | -2.8 -> -3.7 |
| se-olive-quilt-jacket | Uncommon | `linkC>heal` -> `handC>heal` | 5/2/6 -> 5/2/5 | 0.04 | 25% -> 100% | -0.06 -> -0.29 | +0.0 -> +0.0 | +0.2 -> +0.2 | +0.2 -> -0.1 |
| sea-pandan-weave-vest | Common | `linkC>life` -> `handC>life` | 7/3/7 -> 6/3/7 | 0.14 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | -1.8 -> -1.8 | +1.5 -> +1.6 |
| wca-raffia-poncho | Uncommon | `linkC>skip` -> `handC>skip` | 8/3/8 -> 6/3/8 | 0.49 | 0% -> 70% | +0.00 -> -3.17 | +0.0 -> +2.1 | +0.2 -> +2.3 | -0.8 -> -3.9 |
| ea-cloth-bundle | Uncommon | `pair>pluck` -> `foeHasG>pluck` | 6/3/7 -> 5/3/7 | 0.22 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | +1.4 -> +1.4 | -1.5 -> -1.5 |
| ee-stitched-felt-vest | Common | `pair>life` -> `foeHasG>life` | 6/2/4 -> 5/2/4 | 0.11 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | +1.3 -> +1.3 | +2.6 -> +2.6 |
| esa-grain-sack-pack | Uncommon | `pair>heal` -> `foeHasG>heal` | 9/4/10 -> 9/4/9 | 0.33 | 0% -> 9% | +0.00 -> -0.14 | +0.0 -> +0.0 | +0.2 -> +0.2 | -2.4 -> -2.6 |
| na-birch-poncho | Common | `pair>charm` -> `foeHasG>charm` | 3/1/3 -> 3/1/2 | 0.17 | 44% -> 25% | -2.22 -> -0.27 | +1.0 -> +0.0 | -0.1 -> -1.2 | -0.5 -> +1.5 |
| sa-latex-puddle-boots | Common | `pair>evade` -> `foeHasG>evade` | 5/2/4 -> 4/2/4 | 0.10 | 22% -> 60% | +0.41 -> -0.67 | +0.0 -> +0.0 | -0.8 -> -0.8 | +1.5 -> +0.4 |
| sa-thatch-rain-cape | Common | `pair>soothe` -> `foeHasG>soothe` | 2/3/4 -> 2/2/4 | 0.08 | 0% -> 25% | +0.00 -> -0.09 | +0.0 -> +0.0 | +0.2 -> +0.3 | +0.6 -> +0.5 |
| ca-palm-rain-cape | Uncommon | `foeB3>shrink` -> `foeB2>shrink` | 2/2/3 -> 2/1/3 | 0.11 | 0% -> 27% | +0.00 -> -0.10 | +0.0 -> +0.0 | -2.7 -> -2.7 | +2.1 -> +2.0 |
| cb-net-roll-bundle | Uncommon | `foeB3>knock` -> `foeB2>knock` | 5/1/4 -> 4/1/4 | 0.29 | 0% -> 4% | +0.00 -> -0.05 | +0.0 -> +1.0 | +1.1 -> +2.0 | -1.5 -> -1.4 |
| ea-indigo-jacket | Common | `foeB3>ward` -> `foeB2>ward` | 5/3/7 -> 5/3/6 | 0.09 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | +0.3 -> +0.3 | -0.3 -> -0.3 |
| mena-camel-pad-overshoes | Uncommon | `foeB3>dmg` -> `foeB2>dmg` | 6/2/7 -> 6/2/6 | 0.44 | 2% -> 31% | +0.55 -> +0.19 | +0.0 -> -1.0 | +1.4 -> +0.3 | -0.8 -> -1.1 |
| nwe-cable-knit-long-coat | Common | `foeB3>guard` -> `foeB2>guard` | 3/1/4 -> 3/1/3 | 0.06 | 17% -> 50% | -0.08 -> -0.14 | +1.0 -> +1.0 | -1.1 -> -1.2 | +1.6 -> +1.5 |
| oc-flax-wading-wraps | Uncommon | `foeB3>skip` -> `foeB2>skip` | 9/4/10 -> 6/4/10 | 0.45 | 4% -> 47% | +0.08 -> -3.13 | +1.0 -> +2.1 | +1.6 -> +2.6 | -1.5 -> -4.6 |
| ea-felt-poncho | Uncommon | `foeB0>hand` -> `foeNoH>hand` | 6/3/7 -> 5/3/7 | 0.20 | 5% -> 32% | -0.12 -> -0.34 | +0.0 -> -1.0 | +1.4 -> +0.3 | -1.7 -> -1.8 |
| ee-snowdrift-felt-boots | Common | `foeB0>life` -> `foeNoH>life` | 6/2/4 -> 5/2/4 | 0.11 | 9% -> 9% | +0.00 -> +0.00 | +0.0 -> +0.0 | +1.3 -> +1.3 | +2.6 -> +2.6 |
| esa-stripe-weave-vest | Common | `foeB0>ward` -> `foeNoH>ward` | 7/4/9 -> 7/4/8 | 0.19 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | +0.0 -> +0.0 | -0.1 -> -0.2 |
| na-portage-sack | Uncommon | `foeB0>pluck` -> `foeNoH>pluck` | 4/1/3 -> 3/1/3 | 0.06 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | -0.6 -> -0.6 | +0.9 -> +1.0 |
| wca-indigo-hood-mantle | Uncommon | `foeB0>soothe` -> `foeNoH>soothe` | 5/4/8 -> 5/3/8 | 0.24 | 4% -> 4% | -0.10 -> -0.24 | +0.0 -> +0.0 | +0.7 -> +0.7 | -0.9 -> -1.0 |
| ca-pleated-shirt-jacket | Common | `r1>ward` -> `r12>ward` | 3/1/3 -> 3/1/2 | 0.04 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | -3.7 -> -3.7 | +2.6 -> +2.6 |
| esa-highland-shawl | Common | `r1>bond` -> `r12>bond` | 8/4/8 -> 7/4/8 | 0.31 | 3% -> 10% | +0.23 -> -0.04 | +0.0 -> +0.0 | +0.5 -> +0.5 | -0.3 -> -0.6 |
| mena-quilted-night-coat | Uncommon | `r1>cleanse` -> `r12>cleanse` | 6/3/6 -> 6/2/6 | 0.20 | 0% -> 26% | +0.00 -> -0.49 | +0.0 -> +0.0 | +0.7 -> +0.7 | -0.5 -> -1.0 |
| na-sap-run-bucket | Uncommon | `r1>heal` -> `r12>heal` | 5/1/4 -> 5/1/3 | 0.04 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | -1.5 -> -1.5 | -0.1 -> -0.1 |
| se-amphora-frame | Uncommon | `r1>mend` -> `r12>mend` | 4/3/5 -> 4/2/5 | 0.07 | 0% -> 14% | +0.00 -> -0.04 | +0.0 -> +0.0 | +0.7 -> +0.7 | -1.4 -> -1.5 |
| csa-fleece-collar-jacket | Uncommon | `lastRound>mend` -> `hurtLast>mend` | 7/4/7 -> 7/3/7 | 0.25 | 10% -> 46% | -0.07 -> -0.48 | +0.0 -> +0.0 | -1.1 -> -1.1 | +0.7 -> +0.3 |
| esa-banana-leaf-rain-cape | Uncommon | `lastRound>shrink` -> `hurtLast>shrink` | 6/5/9 -> 6/4/9 | 0.18 | 6% -> 18% | -0.21 -> -0.27 | +0.0 -> +0.0 | +1.0 -> +1.0 | -0.8 -> -0.9 |
| mena-rose-madder-mantle | Uncommon | `lastRound>pluck` -> `hurtLast>pluck` | 6/2/6 -> 5/2/6 | 0.23 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | +1.8 -> +1.7 | -1.8 -> -1.7 |
| oc-reef-sail-cloth-jerkin | Uncommon | `lastRound>evade` -> `hurtLast>evade` | 9/4/10 -> 8/4/10 | 0.16 | 8% -> 13% | -0.06 -> +0.12 | +0.0 -> +0.0 | -0.1 -> -0.1 | -0.8 -> -0.6 |
| wca-raffia-cone-basket | Common | `lastRound>heal` -> `hurtLast>heal` | 7/3/8 -> 7/3/7 | 0.29 | 4% -> 32% | -0.02 -> -0.41 | +0.0 -> +0.0 | -0.1 -> -0.1 | -2.6 -> -3.0 |
| oc-reef-sandals | Common | `linkS>hand` -> `handHeal>hand` | 8/4/9 -> 7/4/9 | 0.18 | 0% -> 29% | +0.00 -> -0.56 | +0.0 -> +0.0 | -0.1 -> -0.1 | -0.8 -> -1.3 |
| sea-nipa-thatch-pack | Uncommon | `linkS>heal` -> `handHeal>heal` | 8/3/9 -> 8/3/8 | 0.26 | 0% -> 16% | +0.00 -> -0.41 | +0.0 -> +0.0 | -1.6 -> -1.6 | -0.8 -> -1.1 |
| esa-calabash-carrier | Common | `linkHeal>heal` -> `hp75>heal` | 6/4/9 -> 6/4/8 | 0.20 | 0% -> 26% | +0.00 -> +0.02 | +0.0 -> +0.0 | +0.5 -> +0.5 | -1.8 -> -1.8 |
| se-float-net | Common | `link2>hand` -> `yQuarter>hand` | 4/2/4 -> 3/2/4 | 0.10 | 0% -> 0% | +0.00 -> +0.00 | +0.0 -> +0.0 | +1.3 -> +1.3 | -1.0 -> -1.0 |

Tests after the change: `tests/pf_wear_fx.php` has one true and one false scenario for each new trigger, the dropped ones are gone (a check says so), the payoff checks use `r12>PAY`; `tests/ci_suites.sh wearables pfdeck_v1 pf_wear_fx pfengine_js pf_play_decks pfboard_v1`: 6 suites, 0 failed.

## `oc-flax-wading-wraps`: a rarer trigger (2026-11-19)

The one piece left over the -4 health goal. The value cut could not fix it (the skip alone was -3.1), so its trigger changed, for this piece only: `foeB2>skip` -> **`foeG>skip`**, "If the creature has guard up, the creature skips its next turn." (`PIECE_TRIG` in `build3.py`). `foeG` (`fguard`) is an existing trigger and its pair with `skip` was free: still 280 codes and 280 texts, `wear_fx.txt` and `tools/pfengine.js` unchanged (only this piece's row in `wear_items_pieces.txt`, `wear_pieces.txt`, `pieces.json`, `pieces.md`). Name (Flax Wade Trip), value 6, a / b, Petals and the piece picture are unchanged (the picture shows name, value and rarity, not the effect); the item description follows the piece row (`wear_items()`), so `wear_ensure_items` refreshes it on the next update or Tailor visit. The other five `foeB2` pieces keep their trigger.

How chosen: the piece played with each candidate trigger on the same creatures and seeds as before (`wear_sim.php`, OC, 48 fights a bot, Common rank, value 6). eff = fx - plain, paired.

| trigger (with `skip`) | eff health | careful / careless | eff win | changed a fight | effect actions a fight |
|---|---|---|---|---|---|
| `foeB2` the creature has 2 or more pieces (before) | -3.13 | -3.53 / -2.73 | +2.1 | 21% | 0.40 |
| `foeHasG` the creature has a Guard on the board | -2.97 | -2.84 / -3.10 | +2.1 | 18% | 0.32 |
| `r12` first two rounds | -2.65 | -3.35 / -1.94 | +2.1 | 29% | 0.48 |
| `handG` you hold a Guard | -1.74 (144 fights: -2.19) | -3.39 / -0.08 | +2.1 | 34% | 0.51 |
| `aimNext` next to the aim cell | -1.00 (144: -0.78) | -1.33 / -0.68 | +0.0 | 8% | 0.14 |
| `hit` the creature hit you last turn | -0.94 (144: -1.76) | -0.06 / -1.82 | +2.1 | 27% | 0.32 |
| **`foeG` the creature has guard up (chosen)** | **-0.86** (144: -0.74) | -1.10 / -0.63 | +2.1 | 6% (144: 12%) | 0.12 |
| `onAim` on the aim cell | -0.01 | -0.56 / +0.54 | +0.0 | 23% | 0.27 |
| `foeB3` the creature has 3 or more pieces (the first design) | -0.00 | +0.00 / -0.00 | +1.0 | 2% | 0.06 |

`foeG` was taken because it is clearly rarer, about the creature like the old one, steady at both sample sizes and the same for both bots; `handG` and `hit` land near -3.3 to -3.7 est at 144 fights, too close to the goal for their noise. With value 8 (the cut undone) `foeG` measured -1.23: the cut was kept, so the picture did not change.

Result (est = smoothed piece part + eff): the piece part for an OC Hurt was -1.5 in the full run, so **est health -4.6 -> about -2.3, est win +2.6 -> +2.6**. A fresh run of the whole OC region (20 pieces, 48 fights a bot, baseline 480; smoothing over OC only) gives est +2.9 win / -2.2 health for it. In that OC-only run the type offset rests on few pieces and is noisy: `oc-flax-basket-pack` reads -5.3 est there (its effect alone is -0.74, unchanged; with the smoothing over all regions it was -3.7) and `oc-coconut-string-bag` -4.4 (effect +0.18). Largest effect alone among the OC Commons / Uncommons: `oc-red-dust-poncho` -2.98 (unchanged, est -2.9 here, -4.1 in the full run). A full 280-piece run was not repeated for one changed row. Check: `tests/pf_wear_fx.php` pins the pair (seen failing on the old data).

## Several worn pieces at once (2026-11-19)

Since 2.7.14 a gnome can WEAR 7 items (7 spots), but a worn item only OFFERS its piece: packing it takes a Keepsake slot (`pfd_slots`: 1, 2 from level 15, 3 from 25, 4 from 40) and `pfd_toggle` refuses the next one when they are full; pieces switched on beyond the slots are left out of the deck (`out = slots`), and `pfd_fight_entries` gives the fight only the deck. So at most 4 worn pieces are ever active in a fight, never 7 (`tests/wear_equip.php`, section "all 7 spots worn"). The 280 Tailor items fill four spots (footwear, backpack, coat, cloak), so four of them at once is also the most a gnome can pack.

Measured: `sim/multi_sim.php` (the tuner's gnome, every creature within 3 levels, 480 fights a bot and set, the same creatures and seeds for every set; not paired, noise about +-2 win points for the careless bot). Common rank, OC pieces. Change against no wear piece in brackets.

| level (slots) | set | careful: win / health lost | careless: win / health lost | wear pieces placed a fight (careful / careless) |
|---|---|---|---|---|
| 40 (4) | none | 100.0% / 13.6% | 94.2% / 46.4% | - |
| 40 (4) | the four strongest: `oc-flax-basket-pack`, `oc-mangrove-clog` (Rare), `oc-gum-dyed-cardigan` (Rare), `oc-red-dust-poncho` | 100.0% (+0.0) / 10.8% (-2.8) | 97.3% (+3.1) / 41.6% (-4.8) | 1.73 / 1.15 |
| 40 (4) | four plain Commons: `oc-reef-sandals`, `oc-coconut-string-bag`, `oc-drovers-oilskin`, `oc-frond-rain-cape` | 100.0% (+0.0) / 12.1% (-1.5) | 96.0% (+1.9) / 47.8% (+1.5) | 0.97 / 0.60 |
| 40 (4) | four middling: `oc-flax-wading-wraps` (new trigger), `oc-pouch-pack` (Rare), `oc-bark-cloth-vest`, `oc-hibiscus-pareo` | 100.0% (+0.0) / 11.2% (-2.4) | 96.0% (+1.9) / 47.0% (+0.7) | 0.96 / 0.56 |
| 35 (3) | none | 100.0% / 14.5% | 86.7% / 64.6% | - |
| 35 (3) | the three strongest: `oc-flax-basket-pack`, `oc-mangrove-clog`, `oc-gum-dyed-cardigan` | 100.0% (+0.0) / 10.1% (-4.3) | 92.5% (+5.8) / 58.2% (-6.4) | 2.00 / 1.13 |

Reading: a full set of Keepsake slots is worth +2 to +3 win points and up to 5 health points at level 40, and about +6 win / -6 health for the three strongest at level 35, where the careless bot still loses 13% of its fights. That is less than the sum of the single-piece numbers (the pieces share the same 5-piece hand, one piece a turn), and about what one Rare alone measures at Fine (limit +6 win / -12 health). No fight becomes trivial or lost; no engine errors in 5,760 fights. Not run: Fine rank sets (the 3-Rare cap and the two Rare belt tools of the tuner's gnome leave room for one Fine wear piece from level 28), Lined, the 6 old wearables, regions before OC.

## `oc-red-dust-poncho`: a rarer trigger (2026-11-19)

The last Uncommon over the -4 health goal (est -4.1, `yHalf>skip`: "If its Yield bar is past half, the creature skips its next turn"; the skip itself is the cost, a value cut only moves how often the bots pick it, as with the flax wraps). Fixed the same way: its trigger changed for this piece only, `yHalf>skip` -> **`hpFull>skip`**, "If you are at full health, the creature skips its next turn." (`PIECE_TRIG` in `build3.py`, then `build3.py` -> `outputs2.py` -> `tools/build_wear_items.py`: only this piece's row changed in `wear_items_pieces.txt`, `wear_pieces.txt`, `pieces.json`, `pieces.md`; `wear_fx.txt` and `tools/pfengine.js` untouched, `hpFull` and its pair with `skip` already existed and the pair was free, so still 280 codes and 280 texts).

How chosen: the piece played with each candidate trigger on the same creatures and seeds (`wear_sim.php`, OC, Common rank, 192 fights a bot, effect alone = fx - plain, paired; 480 fights a bot for the four finalists). Health = points of health lost, negative = the piece helps.

| trigger | effect alone, health (192 / 480 fights) | win (192 / 480) | note |
|---|---|---|---|
| `yHalf` (old) | -1.81 / -2.36 | +1.0 / +1.2 | placed 47-52% of fights |
| `foeEvade`, `poisoned`, `g2` | -0.29, -0.17, -0.32 | 0 to +0.5 | almost never true: a dead piece |
| `onAim` | -0.79 / -0.73 | +0.3 / +0.4 | true only when it lands on the aim cell |
| `aimNext` | -0.61 / -0.54 | -0.3 / 0.0 | same |
| **`hpFull`** | **-1.40 / -1.55** | -0.5 / 0.0 | true early in a fight, so the skip still matters; cuts the effect by about a third |
| `hit`, `handH`, `hurtLast`, `noDmg`, `disc5` | -1.1, -2.0, -2.1, -2.7, -2.9 | up to +1.8 | not rarer than `yHalf` |

Result: est health **-4.2 -> -2.2**, est win +2.5 -> -1.5 (OC-only run: baseline 320 fights per region and bot, piece 48 fights a bot, smoothing over OC only, so est carries about +-1.5 of noise; the paired effect alone went -2.4 -> -1.6 health, +1.2 -> 0.0 win). Again at Lined and Fine (240 fights a bot, paired): -2.1 / -1.9 health, -0.2 / 0.0 win.

## Lined and Fine ranks, every piece, and sets (2026-11-19, third pass)

Engine as of this pass (the fire-budget extras `firex`, the boss tune rows x0.94; `PFB_V1_*` unchanged). Method as above: every piece played plain and with its effect, paired (`sim/wear_sim.php`, now with `ONLY=baseline` for baseline fights alone), Lined = rank 2 (+2 value), Fine = rank 3 (+4). **32 fights a bot** a piece and rank (fewer than the 48 of the Common run, so the unpaired "piece" part is noisier: use `eff`, not `est`, to judge a single piece), baseline 320 fights a region and bot (shared), 280 pieces x 2 ranks = 71,680 fights, 0 engine errors. Every piece that looked over a limit was played again at **240 fights a bot** (below).

| rank | | n | est win | est health | eff win | eff health | largest est win / health |
|---|---|---|---|---|---|---|---|
| Lined | Common | 112 | +0.2 | -0.2 | +0.2 | -0.3 | +3.3 / -4.5 |
| Lined | Uncommon | 112 | +0.3 | -0.2 | +0.1 | -0.2 | +3.7 / -4.3 |
| Lined | Rare | 56 | +1.1 | -2.6 | +1.0 | -2.5 | +7.9 / -11.3 |
| Fine | Common | 112 | +0.3 | -0.6 | +0.1 | -0.2 | +3.5 / -4.8 |
| Fine | Uncommon | 112 | +0.4 | -0.7 | +0.1 | -0.3 | +4.2 / -6.4 |
| Fine | Rare | 56 | +1.4 | -3.2 | +1.0 | -2.5 | +9.2 / -13.1 |

Reading: a higher rank barely changes what a piece does (the effects use a and b, which follow the region, not the rank; Lined / Fine add only +2 / +4 to the piece value). Commons and Uncommons: mean effect alone -0.2 to -0.3 health, +0.1 win at both ranks, as at Common. Every Common / Uncommon "over the limit" by est at N=32 had an effect alone near 0 (`cb-mahogany-clogs`, `cb-sisal-sole-slippers`, `cb-market-basket-pack`, `ea-forager-basket`, `cb-calabash-carrier`: -4.1 to -4.5 est, eff 0.0 to -0.3): that is the smoothed piece part of a piece placed in 0-12% of fights, noise, not a piece. The ones with a real effect were played again:

| piece (code) | Lined: eff win / health | Fine: eff win / health | |
|---|---|---|---|
| `wca-raffia-poncho` (`handC>skip`, Unc.) | +2.5 / -2.4 | +2.7 / -2.6 | at the goal (+3 win), as at Common |
| `wca-mudwader-wraps` (`yLow>skip`, Com.) | +0.8 / -3.0 | +1.0 / -3.4 | under -4 |
| `sa-balsa-bark-clogs` (`noDmg>dmg`, Unc.) | +0.4 / -1.4 | +0.4 / -2.3 | est -6.4 was noise |
| `oc-flax-wading-wraps`, `oc-red-dust-poncho` (fixed) | +1.0 / -0.6, -0.2 / -2.1 | +0.8 / -0.7, 0.0 / -1.9 | |
| `sea-paddy-stilt-clogs`, `mena-dune-slippers` | +0.4 / -0.1, 0.0 / 0.0 | +0.8 / -0.7, +0.2 / -0.3 | est +3 win was noise |
| `mena-goat-hair-tent-cape` (Rare) | **+6.2 / -10.1** | **+7.3 / -11.8** | careless bot alone +12.5 / +14.6 win |
| `sea-mudflat-paddles` (Rare) | +4.2 / -11.1 | +3.8 / -11.7 | the largest health effect, inside -12 |
| `cb-curl-toe-reef-booties` (Rare) | +2.5 / -10.6 | +2.3 / -10.3 | |
| `sa-striped-leg-wraps` (Rare) | +3.1 / -9.2 | +2.3 / -8.3 | |
| `csa-turmeric-wrap-coat` (Rare) | +2.3 / -7.1 | +2.3 / -7.1 | |
| `ea-snow-straw-boots` (Rare) | +2.1 / -5.4 | +3.8 / -7.3 | est +9.2 at N=32 was noise |
| `esa-baobab-clogs` (Rare) | +0.8 / -4.3 | +1.0 / -4.8 | est +6.9 at N=32 was noise |

**Outliers.** No Common or Uncommon needs a change at Lined or Fine. One Rare is over the "about +6 win" goal at both ranks and stays there: `mena-goat-hair-tent-cape` (+6.2 Lined, +7.3 Fine; the effect is the skip, a Trip). Tried on it (Fine, 240 fights a bot): value 3 -> 2: +7.5; b 5 -> 4: +7.1 / -11.1; both: +7.5 / -10.5. Numbers do not move it (the value is already cut from 8 to 3 and the Add-Charm part is small); only a different effect would (for example the skip only when the creature has a Hurt out). Left as it is, as in the second pass (+6.8 est at Fine then): the careful bot is at 100% with or without it, and the careless bot's win rate is what moves. Nothing else changed in this pass.

**What rank does to the caps.** At Fine a piece counts as Rare under the 3-Rare cap (`PFD_RARE_CAP`, kit and gear together). The tuner's level-40 gnome can wear **one** Fine piece: four Fine pieces at once leave 3 out of the deck (`cap`). Mixed sets (one Fine, the rest Lined) fit; `multi_sim.php` now takes `slug:2` / `slug:3` per piece and `WEAR_RANK`.

### Sets, again (`sim/multi_sim.php`, 480 fights a bot and set, same creatures and seeds; not paired, noise about +-2 win for the careless bot; change against no wear piece in brackets)

| level (slots) | set | careful: win / health lost | careless: win / health lost | placed (careful / careless) |
|---|---|---|---|---|
| 40 (4) | none | 100.0% / 13.8% | 94.2% / 46.4% | - |
| 40 (4) | the four strongest OC (`oc-flax-basket-pack`, `oc-mangrove-clog`, `oc-gum-dyed-cardigan`, `oc-red-dust-poncho`), Common | 100.0% / 10.7% (-3.1) | 97.1% (+2.9) / 41.8% (-4.5) | 1.75 / 1.12 |
| 40 (4) | the same, Lined | 100.0% / 10.3% (-3.5) | 97.1% (+2.9) / 40.7% (-5.7) | 1.79 / 1.18 |
| 40 (4) | the same, `oc-mangrove-clog` Fine, the rest Lined | 100.0% / 9.9% (-3.8) | 97.9% (+3.7) / 40.4% (-6.0) | 1.77 / 1.16 |
| 40 (4) | four plain OC Commons (`oc-reef-sandals`, `oc-coconut-string-bag`, `oc-drovers-oilskin`, `oc-frond-rain-cape`), Common | 100.0% / 12.3% (-1.4) | 96.2% (+2.1) / 47.2% (+0.9) | 1.00 / 0.61 |
| 40 (4) | the same, Lined | 100.0% / 11.9% (-1.9) | 96.7% (+2.5) / 46.3% (-0.0) | 1.04 / 0.67 |
| 40 (4) | **the four strongest Rares of any region, Lined** (`ea-snow-straw-boots`, `mena-goat-hair-tent-cape`, `esa-baobab-clogs`, `sea-mudflat-paddles`) | 100.0% / 8.5% (-5.2) | 99.4% (+5.2) / 30.0% (-16.4) | 1.55 / 1.35 |
| 35 (3) | none | 100.0% / 14.1% | 87.1% / 64.1% | - |
| 35 (3) | the three strongest OC, Common | 100.0% / 10.2% (-3.8) | 92.1% (+5.0) / 58.4% (-5.7) | 2.02 / 1.14 |
| 35 (3) | the same, Lined | 99.8% / 10.1% (-4.0) | 92.3% (+5.2) / 58.1% (-6.0) | 2.03 / 1.13 |
| 35 (3) | the same, `oc-mangrove-clog` Fine, the rest Lined | 99.8% / 9.7% (-4.4) | 93.5% (+6.5) / 57.4% (-6.6) | 2.05 / 1.06 |

Reading: rank barely matters inside a set (Lined adds 0.2-1 health point over Common, a mixed Fine set about 1 more); what matters is which pieces. Normal sets are worth +2 to +6 win and -2 to -6 health. The one extreme set, four of the strongest Rares from four regions at once (a gnome who bought them all), takes the careless bot's health lost at level 40 from 46% to 30% and its win rate to 99.4%: strong, not a trivial game (the careless bot was already at 94% there and the careful one at 100%), and it costs four Rare Tailor crafts. No engine errors in 10,560 set fights.

## What the bots cannot judge (untested or under-measured)

- **Pluck** (12 Commons / Uncommons, EE and OC Rares): it lifts an item, worth nothing inside the fight. Measured 0; not tuned.
- **Keeper** (`keep`, the Keeper Rares NA cloak, NWE / SA / MENA / CSA / WCA / OC coats and backpack): the careful bot gets a small bonus for holding a Keeper and the careless one never plays guards, so a Keeper often clogs the hand. `wca-kapok-jerkin` measures harmful (+4.3 health, -3 win at Fine) for that reason, not because the numbers are low. A player who plays it will do better than the bots.
- **Next round / next piece / hand effects** (`plenty`, `hand`, `ward`, `focus`, `next:*`, `recycle`, `keep1`, `held` auras such as NWE backpack): the bots do not plan for the next hand, so these read near 0.
- **Placement triggers the bots never aim for**: on / next to the creature's aim cell, corner, edge, inner cells, linked to a given type. They fire when they happen, never on purpose.
- **Evade against poison, bond, life, stay**: the bots do not value them; measured as they happen.
- **Win rate for the careful bot**: it wins 95-100% at every region with no wear piece, so every win change comes from the careless bot.
- **Early regions** (NA-NWE): fights last about 2 turns, the wear piece is placed in 7-10% of them; the effects there are close to unmeasurable.
- Not run (until the third pass above): Lined rank (now run), the 6 old wearables (more than one wear piece at once: run 2026-11-19 for 3 and 4 OC pieces, see "Several worn pieces at once"), the JS engine (`tools/pfengine.js`: same rules, parity checked by `pf_wear_fx.sh`).
- The engine logs a wear action in the replay event (`wfx`) for every action but `dmg` and `pierce` (they change the hit before it is logged): the per-fight fire counts in the sim miss those two. Not a rule bug; a replay could not show "+b damage from the wear piece".

## Tests

After the final data: `tests/ci_suites.sh wearables pfdeck_v1 pf_wear_fx pfengine_js pf_play_decks pfboard_v1`: 6 suites, 0 failed (also before the last Rare fixes).

## Tables

### Baseline (no wear piece)

| region | level | careful win % | careful health lost % | careful turns | careless win % | careless health lost % | careless turns |
|---|---|---|---|---|---|---|---|
| NA | 1 | 95.0 | 34.0 | 1.8 | 84.2 | 52.8 | 1.8 |
| CA | 4 | 95.2 | 37.5 | 2.4 | 84.6 | 49.2 | 2.1 |
| NWE | 6 | 95.8 | 33.0 | 2.6 | 85.2 | 48.0 | 2.3 |
| CB | 8 | 93.8 | 35.1 | 2.3 | 86.5 | 44.8 | 2.1 |
| SE | 10 | 98.1 | 25.6 | 3.2 | 79.6 | 53.1 | 2.6 |
| SA | 12 | 99.4 | 17.4 | 4.3 | 87.7 | 48.0 | 3.5 |
| EE | 14 | 99.4 | 20.8 | 5.1 | 85.0 | 53.2 | 4.2 |
| MENA | 17 | 100.0 | 18.1 | 7.8 | 76.2 | 68.7 | 6.0 |
| EA | 20 | 100.0 | 19.6 | 8.0 | 81.5 | 65.5 | 6.5 |
| CSA | 23 | 100.0 | 14.2 | 9.0 | 79.4 | 70.3 | 7.1 |
| SEA | 26 | 100.0 | 19.5 | 7.6 | 87.9 | 64.8 | 6.5 |
| WCA | 29 | 99.8 | 16.2 | 8.3 | 85.4 | 67.4 | 6.8 |
| ESA | 32 | 100.0 | 19.7 | 7.3 | 88.1 | 65.0 | 6.5 |
| OC | 35 | 100.0 | 15.7 | 7.9 | 85.8 | 65.7 | 6.9 |

### Per region, Common rank (every piece): mean delta against the baseline, after the changes (before in brackets)

est = smoothed piece + effect (points; health: negative = less lost). eff = the effect alone. play = share of fights the piece was placed.

| region | rarity | n | est win | est health | eff win | eff health | play |
|---|---|---|---|---|---|---|---|
| NA | Common | 8 | -1.1 (-1.2) | +1.1 (+1.3) | +0.1 (+0.0) | -0.20 (+0.02) | 0.07 |
| NA | Uncommon | 8 | -1.0 (-1.0) | +1.2 (+1.2) | +0.3 (+0.3) | -0.34 (-0.34) | 0.09 |
| NA | Rare | 4 | -0.2 (-0.2) | -1.1 (-1.0) | +1.0 (+1.0) | -2.91 (-2.91) | 0.15 |
| CA | Common | 8 | -3.3 (-3.3) | +1.9 (+1.9) | +0.1 (+0.1) | -0.04 (-0.04) | 0.10 |
| CA | Uncommon | 8 | -3.3 (-3.2) | +1.4 (+1.4) | +0.0 (+0.0) | -0.56 (-0.56) | 0.12 |
| CA | Rare | 4 | -0.8 (-0.8) | -1.5 (-1.6) | +2.6 (+2.6) | -3.51 (-3.51) | 0.11 |
| NWE | Common | 8 | -1.7 (-1.7) | +0.7 (+0.7) | +0.1 (+0.1) | -0.39 (-0.38) | 0.07 |
| NWE | Uncommon | 8 | -1.6 (-1.7) | +0.8 (+0.8) | +0.3 (+0.1) | -0.48 (-0.46) | 0.11 |
| NWE | Rare | 4 | -1.7 (-1.8) | +1.0 (+0.9) | +0.0 (+0.0) | -0.18 (-0.23) | 0.18 |
| CB | Common | 8 | +0.6 (+0.5) | -1.0 (-1.0) | +0.3 (+0.3) | -0.05 (-0.05) | 0.09 |
| CB | Uncommon | 8 | +0.4 (+0.4) | -0.9 (-0.9) | +0.0 (+0.0) | -0.05 (-0.05) | 0.13 |
| CB | Rare | 4 | +1.2 (+1.1) | -5.3 (-5.2) | +0.8 (+0.8) | -4.37 (-4.21) | 0.18 |
| SE | Common | 8 | +0.6 (+0.5) | -0.7 (-0.6) | +0.0 (+0.0) | -0.24 (-0.20) | 0.11 |
| SE | Uncommon | 8 | +0.7 (+0.6) | -0.8 (-0.8) | +0.1 (+0.1) | -0.26 (-0.25) | 0.10 |
| SE | Rare | 4 | +1.4 (+1.8) | -3.8 (-3.6) | +0.8 (+1.3) | -3.29 (-3.09) | 0.16 |
| SA | Common | 8 | -0.5 (-0.4) | +0.4 (+0.5) | +0.0 (+0.0) | +0.05 (+0.11) | 0.10 |
| SA | Uncommon | 8 | -0.1 (+0.0) | +0.4 (+0.4) | +0.1 (+0.1) | +0.09 (+0.08) | 0.17 |
| SA | Rare | 4 | +1.5 (+1.3) | -3.5 (-3.7) | +1.8 (+1.6) | -3.86 (-3.99) | 0.29 |
| EE | Common | 8 | +1.7 (+1.7) | +1.9 (+1.9) | +0.1 (+0.1) | -0.16 (-0.16) | 0.19 |
| EE | Uncommon | 8 | +1.8 (+1.8) | +1.3 (+1.3) | +0.0 (+0.0) | -0.48 (-0.48) | 0.20 |
| EE | Rare | 4 | +1.9 (+1.9) | +1.0 (+1.1) | +0.0 (+0.0) | -0.64 (-0.64) | 0.23 |
| MENA | Common | 8 | +1.0 (+0.9) | -1.4 (-1.3) | +0.0 (+0.0) | -0.13 (-0.13) | 0.28 |
| MENA | Uncommon | 8 | +1.2 (+1.2) | -1.1 (-1.1) | +0.0 (+0.0) | +0.08 (+0.08) | 0.24 |
| MENA | Rare | 4 | +2.9 (+3.3) | -5.0 (-6.3) | +1.8 (+2.3) | -3.57 (-4.90) | 0.53 |
| EA | Common | 8 | +0.5 (+0.1) | -1.1 (-0.8) | -0.1 (-0.3) | -0.04 (+0.10) | 0.23 |
| EA | Uncommon | 8 | +0.6 (+0.4) | -0.9 (-0.8) | -0.1 (-0.1) | +0.06 (+0.06) | 0.24 |
| EA | Rare | 4 | +1.2 (+3.3) | -3.1 (-4.2) | +0.5 (+2.9) | -2.10 (-3.32) | 0.40 |
| CSA | Common | 8 | -0.6 (-0.6) | +0.1 (+0.2) | +0.1 (+0.1) | -0.04 (+0.01) | 0.28 |
| CSA | Uncommon | 8 | -0.3 (-0.3) | -0.3 (-0.2) | +0.3 (+0.3) | -0.16 (-0.13) | 0.29 |
| CSA | Rare | 4 | +0.9 (+0.9) | -2.4 (-2.1) | +1.8 (+1.8) | -2.65 (-2.45) | 0.49 |
| SEA | Common | 8 | -1.6 (-1.6) | +0.7 (+0.8) | -0.3 (-0.3) | -0.10 (-0.10) | 0.25 |
| SEA | Uncommon | 8 | -1.7 (-1.7) | +0.6 (+0.6) | -0.3 (-0.3) | -0.14 (-0.14) | 0.27 |
| SEA | Rare | 4 | +0.2 (+0.2) | -3.0 (-2.8) | +1.6 (+1.6) | -3.79 (-3.64) | 0.40 |
| WCA | Common | 8 | -0.0 (-0.2) | -1.5 (-1.3) | +0.0 (-0.1) | -0.35 (-0.24) | 0.30 |
| WCA | Uncommon | 8 | +0.3 (+0.3) | -1.0 (-1.0) | +0.1 (+0.1) | -0.11 (-0.09) | 0.27 |
| WCA | Rare | 4 | -0.5 (-0.2) | -0.9 (-0.8) | -0.5 (-0.3) | +0.08 (+0.12) | 0.39 |
| ESA | Common | 8 | +0.2 (+0.2) | -0.9 (-0.9) | +0.0 (+0.0) | -0.12 (-0.15) | 0.22 |
| ESA | Uncommon | 8 | +0.9 (+0.9) | -1.0 (-1.0) | +0.4 (+0.4) | -0.11 (-0.06) | 0.32 |
| ESA | Rare | 4 | +2.2 (+2.2) | -2.8 (-2.8) | +1.6 (+1.6) | -1.69 (-1.73) | 0.30 |
| OC | Common | 8 | +0.0 (+0.0) | -1.4 (-1.3) | +0.0 (+0.0) | +0.08 (+0.11) | 0.26 |
| OC | Uncommon | 8 | +0.8 (+0.8) | -2.0 (-2.0) | +0.4 (+0.4) | -0.51 (-0.50) | 0.32 |
| OC | Rare | 4 | +2.0 (+2.0) | -3.5 (-3.6) | +1.6 (+1.6) | -1.82 (-1.92) | 0.44 |

By region band (mean of the regions), effect alone in health points, after (before):

- NA-SE (1-10): Common -0.19 (-0.13), Uncommon -0.34 (-0.33), Rare -2.85 (-2.79)
- SA-CSA (12-23): Common -0.06 (-0.01), Uncommon -0.08 (-0.08), Rare -2.56 (-3.06)
- SEA-OC (26-35): Common -0.12 (-0.09), Uncommon -0.22 (-0.20), Rare -1.80 (-1.79)

### Per region, Fine rank (+4), the Rares: mean delta against the baseline, after the changes (before in brackets)

est = smoothed piece + effect (points; health: negative = less lost). eff = the effect alone. play = share of fights the piece was placed.

| region | rarity | n | est win | est health | eff win | eff health | play |
|---|---|---|---|---|---|---|---|
| NA | Rare | 4 | +0.1 (+0.1) | +0.0 (+0.0) | +1.0 (+1.0) | -0.96 (-0.96) | 0.18 |
| CA | Rare | 4 | -2.6 (-2.5) | -0.4 (-0.4) | +0.5 (+0.5) | -1.49 (-1.49) | 0.12 |
| NWE | Rare | 4 | -0.9 (-0.9) | -1.0 (-0.8) | +0.5 (+0.5) | -1.24 (-1.10) | 0.20 |
| CB | Rare | 4 | +1.8 (+1.7) | -6.3 (-6.1) | +1.0 (+1.0) | -4.46 (-4.33) | 0.19 |
| SE | Rare | 4 | +2.3 (+3.0) | -5.3 (-5.8) | +1.3 (+2.1) | -3.91 (-4.43) | 0.17 |
| SA | Rare | 4 | +1.6 (+1.7) | -4.7 (-4.8) | +1.6 (+1.6) | -4.19 (-4.26) | 0.31 |
| EE | Rare | 4 | +2.2 (+2.3) | +0.1 (+0.2) | +0.0 (+0.0) | -0.64 (-0.64) | 0.24 |
| MENA | Rare | 4 | +3.2 (+3.6) | -6.5 (-7.5) | +1.8 (+2.3) | -4.21 (-5.22) | 0.57 |
| EA | Rare | 4 | +3.1 (+3.7) | -5.3 (-5.5) | +2.1 (+2.9) | -3.41 (-3.77) | 0.43 |
| CSA | Rare | 4 | +1.8 (+1.6) | -3.8 (-3.4) | +2.3 (+2.1) | -3.17 (-2.88) | 0.51 |
| SEA | Rare | 4 | +0.3 (+0.3) | -3.8 (-3.5) | +1.3 (+1.3) | -3.73 (-3.51) | 0.42 |
| WCA | Rare | 4 | +0.1 (+0.1) | -1.9 (-1.7) | -0.3 (-0.3) | -0.08 (+0.08) | 0.40 |
| ESA | Rare | 4 | +2.0 (+2.0) | -3.4 (-3.5) | +1.0 (+1.0) | -1.48 (-1.51) | 0.29 |
| OC | Rare | 4 | +2.3 (+2.4) | -4.5 (-4.5) | +1.6 (+1.6) | -1.93 (-1.88) | 0.46 |

By region band (mean of the regions), effect alone in health points, after (before):

- NA-SE (1-10): Rare -2.41 (-2.46)
- SA-CSA (12-23): Rare -3.12 (-3.35)
- SEA-OC (26-35): Rare -1.81 (-1.70)

### Outliers after the changes, Common rank

Strongest 15 (by est health, most health saved):

| piece | region | rarity | type | fx | v/a/b | est win | est health | eff win | eff health | play |
|---|---|---|---|---|---|---|---|---|---|---|
| sa-striped-leg-wraps | SA | Rare | hurt | `R:SA:footwear` | 6/3/6 | +4.1 | -11.6 | +4.2 | -11.88 | 0.32 |
| cb-curl-toe-reef-booties | CB | Rare | hurt | `R:CB:footwear` | 6/2/5 | +1.7 | -11.5 | +1.0 | -10.42 | 0.14 |
| mena-bottle-gourd-sling | MENA | Rare | item | `R:MENA:backpack` | 8/3/7 | +2.0 | -9.1 | +1.0 | -6.33 | 0.47 |
| se-sea-squall-capelet | SE | Rare | charm | `R:SE:cloak` | 4/3/6 | +1.8 | -8.0 | +1.0 | -7.79 | 0.29 |
| csa-turmeric-wrap-coat | CSA | Rare | guard | `R:CSA:coat` | 9/4/8 | +3.0 | -7.4 | +4.2 | -8.17 | 0.61 |
| na-toboggan-pack | NA | Rare | hurt | `R:NA:backpack` | 6/2/4 | +3.2 | -6.9 | +4.2 | -8.29 | 0.12 |
| esa-baobab-clogs | ESA | Rare | hurt | `R:ESA:footwear` | 10/5/8 | +7.0 | -6.8 | +6.2 | -5.88 | 0.57 |
| mena-goat-hair-tent-cape | MENA | Rare | charm | `R:MENA:cloak` | 3/3/5 | +5.4 | -6.6 | +4.2 | -5.61 | 0.64 |
| sea-mudflat-paddles | SEA | Rare | hurt | `R:SEA:footwear` | 9/4/9 | +2.0 | -6.5 | +3.1 | -7.15 | 0.45 |
| ca-market-platform-clogs | CA | Rare | hurt | `R:CA:footwear` | 6/2/4 | +1.1 | -6.3 | +4.2 | -8.04 | 0.07 |
| oc-gum-dyed-cardigan | OC | Rare | guard | `R:OC:coat` | 10/5/11 | +3.0 | -5.9 | +3.1 | -5.15 | 0.65 |
| cb-sunset-batik-vest | CB | Rare | guard | `R:CB:coat` | 7/2/5 | +1.1 | -5.2 | +1.0 | -4.97 | 0.20 |
| sea-monsoon-poncho | SEA | Rare | charm | `R:SEA:cloak` | 9/4/9 | +2.9 | -5.1 | +4.2 | -6.17 | 0.73 |
| ea-snow-straw-boots | EA | Rare | hurt | `R:EA:footwear` | 2/4/6 | +1.0 | -4.6 | +0.0 | -3.48 | 0.38 |
| wca-bamboo-frame-pack | WCA | Rare | heal | `R:WCA:backpack` | 8/4/9 | +1.2 | -4.3 | +1.0 | -2.38 | 0.32 |

Strongest 15 by est win:

| piece | region | rarity | type | fx | v/a/b | est win | est health | eff win | eff health | play |
|---|---|---|---|---|---|---|---|---|---|---|
| esa-baobab-clogs | ESA | Rare | hurt | `R:ESA:footwear` | 10/5/8 | +7.0 | -6.8 | +6.2 | -5.88 | 0.57 |
| mena-goat-hair-tent-cape | MENA | Rare | charm | `R:MENA:cloak` | 3/3/5 | +5.4 | -6.6 | +4.2 | -5.61 | 0.64 |
| sa-striped-leg-wraps | SA | Rare | hurt | `R:SA:footwear` | 6/3/6 | +4.1 | -11.6 | +4.2 | -11.88 | 0.32 |
| esa-acacia-frame-pack | ESA | Uncommon | trick | `yHalf>boost` | 7/4/9 | +3.2 | -1.8 | +2.1 | -0.43 | 0.28 |
| na-toboggan-pack | NA | Rare | hurt | `R:NA:backpack` | 6/2/4 | +3.2 | -6.9 | +4.2 | -8.29 | 0.12 |
| csa-turmeric-wrap-coat | CSA | Rare | guard | `R:CSA:coat` | 9/4/8 | +3.0 | -7.4 | +4.2 | -8.17 | 0.61 |
| oc-gum-dyed-cardigan | OC | Rare | guard | `R:OC:coat` | 10/5/11 | +3.0 | -5.9 | +3.1 | -5.15 | 0.65 |
| sea-monsoon-poncho | SEA | Rare | charm | `R:SEA:cloak` | 9/4/9 | +2.9 | -5.1 | +4.2 | -6.17 | 0.73 |
| csa-stilt-clogs | CSA | Uncommon | hurt | `h2>knock` | 7/3/7 | +2.7 | -1.2 | +3.1 | -1.21 | 0.47 |
| oc-mangrove-clog | OC | Rare | hurt | `R:OC:footwear` | 10/5/11 | +2.6 | -3.5 | +2.1 | -1.94 | 0.61 |
| oc-red-dust-poncho | OC | Uncommon | charm | `yHalf>skip` | 8/4/10 | +2.5 | -4.2 | +2.1 | -2.98 | 0.48 |
| ee-birchbark-pester | EE | Common | trick | `linkG>pluck` | 4/2/4 | +2.4 | +1.3 | +0.0 | +0.00 | 0.17 |
| ee-fox-collar-capelet | EE | Rare | trick | `R:EE:cloak` | 7/3/6 | +2.4 | +1.2 | +0.0 | -0.12 | 0.20 |
| mena-cedar-bath-clogs | MENA | Rare | hurt | `R:MENA:footwear` | 8/3/7 | +2.4 | -2.3 | +1.0 | -1.00 | 0.47 |
| ea-ramie-jacket | EA | Rare | guard | `R:EA:coat` | 8/4/8 | +2.4 | -2.5 | +2.1 | -2.22 | 0.24 |

Weakest 15 (by the effect alone, health; positive = the effect costs health):

| piece | region | rarity | type | fx | v/a/b | est win | est health | eff win | eff health | play |
|---|---|---|---|---|---|---|---|---|---|---|
| wca-kapok-jerkin | WCA | Rare | guard | `R:WCA:coat` | 9/4/9 | -3.4 | +4.5 | -3.1 | +4.85 | 0.44 |
| ee-riders-red-boots | EE | Uncommon | hurt | `combo3>dmg` | 6/2/5 | +2.0 | +2.9 | +0.0 | +1.13 | 0.28 |
| esa-sisal-slippers | ESA | Uncommon | hurt | `linkEnv>pierce` | 8/4/9 | +0.7 | +0.1 | +0.0 | +1.10 | 0.47 |
| ea-rain-clogs | EA | Common | hurt | `noHurt>dmg` | 5/3/6 | -0.1 | +0.0 | -1.0 | +1.08 | 0.43 |
| sa-balsa-bark-clogs | SA | Uncommon | hurt | `noDmg>dmg` | 5/2/5 | -0.1 | +1.0 | +0.0 | +0.79 | 0.28 |
| nwe-woad-mist-cloak | NWE | Rare | trick | `R:NWE:cloak` | 5/2/5 | -2.1 | +1.1 | -1.0 | +0.71 | 0.24 |
| na-maple-mantle | NA | Common | trick | `linkH>boost` | 2/1/2 | -0.6 | +1.5 | +0.0 | +0.59 | 0.12 |
| ca-dappled-rebozo | CA | Common | charm | `mid4>soothe` | 3/1/2 | -4.3 | +2.7 | -1.0 | +0.59 | 0.12 |
| sa-fleece-vest | SA | Common | guard | `hit>life` | 4/2/4 | -0.8 | +1.7 | +0.0 | +0.58 | 0.09 |
| oc-storm-petrel-hood | OC | Rare | trick | `R:OC:cloak` | 9/5/11 | +2.0 | -1.5 | +1.0 | +0.56 | 0.20 |
| mena-camel-pad-overshoes | MENA | Uncommon | hurt | `foeB3>dmg` | 6/2/7 | +1.4 | -0.8 | +0.0 | +0.55 | 0.43 |
| se-corkbark-clogs | SE | Uncommon | hurt | `foeG>pierce` | 5/2/5 | +0.9 | -0.1 | +0.0 | +0.50 | 0.20 |
| ea-felt-boots | EA | Uncommon | guard | `g2>evade` | 6/3/7 | +0.3 | +0.2 | +0.0 | +0.43 | 0.16 |
| sa-latex-puddle-boots | SA | Common | guard | `pair>evade` | 5/2/4 | -0.8 | +1.5 | +0.0 | +0.41 | 0.09 |
| na-loon-down-slippers | NA | Rare | soothe | `R:NA:footwear` | 4/2/4 | -1.7 | +2.1 | -1.0 | +0.41 | 0.10 |

### Outliers after the changes, Fine rank (Rares)

Strongest 15 (by est health, most health saved):

| piece | region | rarity | type | fx | v/a/b | est win | est health | eff win | eff health | play |
|---|---|---|---|---|---|---|---|---|---|---|
| cb-curl-toe-reef-booties | CB | Rare | hurt | `R:CB:footwear` | 6/2/5 | +3.1 | -11.7 | +2.1 | -9.78 | 0.12 |
| sa-striped-leg-wraps | SA | Rare | hurt | `R:SA:footwear` | 6/3/6 | +1.3 | -11.5 | +1.0 | -10.91 | 0.33 |
| mena-goat-hair-tent-cape | MENA | Rare | charm | `R:MENA:cloak` | 3/3/5 | +6.8 | -11.2 | +5.2 | -9.35 | 0.73 |
| mena-bottle-gourd-sling | MENA | Rare | item | `R:MENA:backpack` | 8/3/7 | +2.3 | -10.5 | +1.0 | -6.85 | 0.47 |
| ea-snow-straw-boots | EA | Rare | hurt | `R:EA:footwear` | 2/4/6 | +6.5 | -10.0 | +5.2 | -8.05 | 0.47 |
| se-sea-squall-capelet | SE | Rare | charm | `R:SE:cloak` | 4/3/6 | +4.2 | -9.9 | +3.1 | -8.79 | 0.30 |
| csa-turmeric-wrap-coat | CSA | Rare | guard | `R:CSA:coat` | 9/4/8 | +3.4 | -8.2 | +4.2 | -8.12 | 0.61 |
| sea-mudflat-paddles | SEA | Rare | hurt | `R:SEA:footwear` | 9/4/9 | +1.3 | -7.6 | +2.1 | -7.44 | 0.47 |
| oc-gum-dyed-cardigan | OC | Rare | guard | `R:OC:coat` | 10/5/11 | +3.3 | -7.1 | +3.1 | -5.48 | 0.65 |
| esa-baobab-clogs | ESA | Rare | hurt | `R:ESA:footwear` | 10/5/8 | +5.2 | -6.8 | +4.2 | -4.96 | 0.53 |
| sea-monsoon-poncho | SEA | Rare | charm | `R:SEA:cloak` | 9/4/9 | +2.2 | -6.3 | +3.1 | -6.46 | 0.77 |
| cb-sunset-batik-vest | CB | Rare | guard | `R:CB:coat` | 7/2/5 | +0.3 | -6.0 | +0.0 | -4.90 | 0.20 |
| wca-bamboo-frame-pack | WCA | Rare | heal | `R:WCA:backpack` | 8/4/9 | +1.6 | -5.4 | +1.0 | -2.58 | 0.32 |
| se-harvest-treaders | SE | Rare | hurt | `R:SE:footwear` | 7/3/6 | +3.3 | -4.9 | +2.1 | -3.40 | 0.14 |
| oc-mangrove-clog | OC | Rare | hurt | `R:OC:footwear` | 10/5/11 | +3.0 | -4.5 | +2.1 | -2.00 | 0.69 |

Strongest 15 by est win:

| piece | region | rarity | type | fx | v/a/b | est win | est health | eff win | eff health | play |
|---|---|---|---|---|---|---|---|---|---|---|
| mena-goat-hair-tent-cape | MENA | Rare | charm | `R:MENA:cloak` | 3/3/5 | +6.8 | -11.2 | +5.2 | -9.35 | 0.73 |
| ea-snow-straw-boots | EA | Rare | hurt | `R:EA:footwear` | 2/4/6 | +6.5 | -10.0 | +5.2 | -8.05 | 0.47 |
| esa-baobab-clogs | ESA | Rare | hurt | `R:ESA:footwear` | 10/5/8 | +5.2 | -6.8 | +4.2 | -4.96 | 0.53 |
| se-sea-squall-capelet | SE | Rare | charm | `R:SE:cloak` | 4/3/6 | +4.2 | -9.9 | +3.1 | -8.79 | 0.30 |
| csa-indigo-dot-cloak | CSA | Rare | charm | `R:CSA:cloak` | 9/4/8 | +3.9 | -3.1 | +4.2 | -2.65 | 0.80 |
| csa-turmeric-wrap-coat | CSA | Rare | guard | `R:CSA:coat` | 9/4/8 | +3.4 | -8.2 | +4.2 | -8.12 | 0.61 |
| se-harvest-treaders | SE | Rare | hurt | `R:SE:footwear` | 7/3/6 | +3.3 | -4.9 | +2.1 | -3.40 | 0.14 |
| oc-gum-dyed-cardigan | OC | Rare | guard | `R:OC:coat` | 10/5/11 | +3.3 | -7.1 | +3.1 | -5.48 | 0.65 |
| ea-blossom-capelet | EA | Rare | charm | `R:EA:cloak` | 8/4/8 | +3.2 | -4.5 | +2.1 | -2.91 | 0.76 |
| cb-curl-toe-reef-booties | CB | Rare | hurt | `R:CB:footwear` | 6/2/5 | +3.1 | -11.7 | +2.1 | -9.78 | 0.12 |
| oc-mangrove-clog | OC | Rare | hurt | `R:OC:footwear` | 10/5/11 | +3.0 | -4.5 | +2.1 | -2.00 | 0.69 |
| cb-shell-scallop-capelet | CB | Rare | charm | `R:CB:cloak` | 7/2/5 | +2.9 | -4.2 | +2.1 | -2.65 | 0.34 |
| ee-fox-collar-capelet | EE | Rare | trick | `R:EE:cloak` | 7/3/6 | +2.8 | +0.2 | +0.0 | -0.26 | 0.24 |
| oc-storm-petrel-hood | OC | Rare | trick | `R:OC:cloak` | 9/5/11 | +2.4 | -2.3 | +1.0 | +0.65 | 0.20 |
| ee-sunflower-straw-sandals | EE | Rare | hurt | `R:EE:footwear` | 8/3/6 | +2.3 | -0.7 | +0.0 | -1.55 | 0.31 |

Weakest 15 (by the effect alone, health; positive = the effect costs health):

| piece | region | rarity | type | fx | v/a/b | est win | est health | eff win | eff health | play |
|---|---|---|---|---|---|---|---|---|---|---|
| wca-kapok-jerkin | WCA | Rare | guard | `R:WCA:coat` | 9/4/9 | -3.1 | +3.1 | -3.1 | +4.30 | 0.45 |
| mena-cedar-bath-clogs | MENA | Rare | hurt | `R:MENA:footwear` | 8/3/7 | +1.7 | -1.4 | +0.0 | +0.77 | 0.52 |
| oc-storm-petrel-hood | OC | Rare | trick | `R:OC:cloak` | 9/5/11 | +2.4 | -2.3 | +1.0 | +0.65 | 0.20 |
| wca-scaleleaf-mantle | WCA | Rare | guard | `R:WCA:cloak` | 9/4/9 | +0.0 | -1.0 | +0.0 | +0.21 | 0.16 |
| na-toboggan-pack | NA | Rare | hurt | `R:NA:backpack` | 6/2/4 | -0.7 | +0.5 | +0.0 | +0.00 | 0.21 |
| esa-beaded-tunic-coat | ESA | Rare | guard | `R:ESA:coat` | 10/5/10 | +0.3 | -1.0 | +0.0 | -0.01 | 0.19 |
| sea-mangrove-oilcloth | SEA | Rare | guard | `R:SEA:coat` | 9/4/9 | -1.5 | +0.5 | +0.0 | -0.14 | 0.17 |
| ee-hedgehog-knit-cardigan | EE | Rare | guard | `R:EE:coat` | 8/3/6 | +1.6 | +1.5 | +0.0 | -0.25 | 0.25 |
| csa-wrapped-hide-boots | CSA | Rare | guard | `R:CSA:footwear` | 9/4/8 | +0.2 | -0.3 | +1.0 | -0.25 | 0.31 |
| ee-fox-collar-capelet | EE | Rare | trick | `R:EE:cloak` | 7/3/6 | +2.8 | +0.2 | +0.0 | -0.26 | 0.24 |
| esa-indigo-dot-shawl | ESA | Rare | trick | `R:ESA:cloak` | 9/5/10 | +1.5 | -2.7 | +0.0 | -0.41 | 0.21 |
| ee-fleece-drawsack | EE | Rare | heal | `R:EE:backpack` | 7/3/6 | +2.2 | -0.4 | +0.0 | -0.48 | 0.16 |
| se-lemon-satchel | SE | Rare | heal | `R:SE:backpack` | 6/3/6 | +1.1 | -2.8 | +0.0 | -0.50 | 0.10 |
| ea-quilted-satchel | EA | Rare | heal | `R:EA:backpack` | 7/4/8 | +1.1 | -3.3 | +0.0 | -0.51 | 0.27 |
| cb-bamboo-frame-pack | CB | Rare | heal | `R:CB:backpack` | 6/2/5 | +0.8 | -3.3 | +0.0 | -0.52 | 0.09 |

### Before / after of the pieces changed beyond the new a / b formula (trigger bumps and Rare fixes; effect alone at Common, Rares also at Fine)

| piece | region | rarity | fx | v/a/b before | after | eff health before | after | eff win before | after | Fine eff health before | after |
|---|---|---|---|---|---|---|---|---|---|---|---|
| na-portage-sack | NA | Uncommon | `foeB0>pluck` | 3/1/3 | 4/1/3 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| na-sap-run-bucket | NA | Uncommon | `r1>heal` | 5/1/3 | 5/1/4 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| na-birch-poncho | NA | Common | `pair>charm` | 3/1/2 | 3/1/3 | -0.45 | -2.22 | +0.0 | +1.0 |  |  |
| ca-indigo-leg-wraps | CA | Uncommon | `linkT>life` | 4/1/3 | 5/1/3 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| ca-bloom-smock | CA | Common | `linkC>thorns` | 3/1/2 | 3/2/2 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| ca-pleated-shirt-jacket | CA | Common | `r1>ward` | 3/1/2 | 3/1/3 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| ca-palm-rain-cape | CA | Uncommon | `foeB3>shrink` | 2/1/3 | 2/2/3 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| nwe-birch-bark-slippers | NWE | Uncommon | `linkT>stay` | 4/1/3 | 5/1/4 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| nwe-cable-knit-long-coat | NWE | Common | `foeB3>guard` | 3/1/2 | 3/1/4 | -0.03 | -0.08 | +1.0 | +1.0 |  |  |
| cb-curl-toe-reef-booties | CB | Rare | `R:CB:footwear` | 7/2/5 | 6/2/5 | -9.78 | -10.42 | +1.0 | +1.0 | -9.26 | -9.78 |
| cb-net-roll-bundle | CB | Uncommon | `foeB3>knock` | 4/1/4 | 5/1/4 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| cb-hibiscus-shawl | CB | Common | `linkC>bond` | 4/1/3 | 5/1/3 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| se-float-net | SE | Common | `link2>hand` | 3/1/3 | 4/2/4 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| se-amphora-frame | SE | Uncommon | `r1>mend` | 4/1/4 | 4/3/5 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| se-olive-quilt-jacket | SE | Uncommon | `linkC>heal` | 5/1/4 | 5/2/6 | -0.02 | -0.06 | +0.0 | +0.0 |  |  |
| se-sea-squall-capelet | SE | Rare | `R:SE:cloak` | 7/2/5 | 4/3/6 | -8.35 | -7.79 | +3.1 | +1.0 | -11.46 | -8.79 |
| sa-latex-puddle-boots | SA | Common | `pair>evade` | 4/2/3 | 5/2/4 | +0.41 | +0.41 | +0.0 | +0.0 |  |  |
| sa-striped-leg-wraps | SA | Rare | `R:SA:footwear` | 7/3/5 | 6/3/6 | -12.19 | -11.88 | +3.1 | +4.2 | -11.03 | -10.91 |
| sa-bark-cloth-tunic-coat | SA | Uncommon | `linkT>shrink` | 5/2/4 | 5/3/5 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| sa-thatch-rain-cape | SA | Common | `pair>soothe` | 2/2/3 | 2/3/4 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| ee-snowdrift-felt-boots | EE | Common | `foeB0>life` | 5/2/4 | 6/2/4 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| ee-stitched-felt-vest | EE | Common | `pair>life` | 5/2/4 | 6/2/4 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| ee-poppy-field-shawl | EE | Common | `linkT>bond` | 5/2/4 | 6/2/4 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| mena-indigo-wrap-boots | MENA | Uncommon | `linkC>guard` | 6/2/5 | 6/2/7 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| mena-camel-pad-overshoes | MENA | Uncommon | `foeB3>dmg` | 6/2/5 | 6/2/7 | +0.55 | +0.55 | +0.0 | +0.0 |  |  |
| mena-bottle-gourd-sling | MENA | Rare | `R:MENA:backpack` | 9/3/6 | 8/3/7 | -6.87 | -6.33 | +1.0 | +1.0 | -7.32 | -6.85 |
| mena-quilted-night-coat | MENA | Uncommon | `r1>cleanse` | 6/2/5 | 6/3/6 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| mena-rose-madder-mantle | MENA | Uncommon | `lastRound>pluck` | 5/2/5 | 6/2/6 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| mena-goat-hair-tent-cape | MENA | Rare | `R:MENA:cloak` | 8/3/6 | 3/3/5 | -10.07 | -5.61 | +6.2 | +4.2 | -12.62 | -9.35 |
| ea-snow-straw-boots | EA | Rare | `R:EA:footwear` | 8/3/6 | 2/4/6 | -10.06 | -3.48 | +8.3 | +0.0 | -10.53 | -8.05 |
| ea-cloth-bundle | EA | Uncommon | `pair>pluck` | 5/2/5 | 6/3/7 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| ea-tea-chest | EA | Uncommon | `linkC>mend` | 5/2/5 | 5/4/7 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| ea-indigo-jacket | EA | Common | `foeB3>ward` | 5/2/4 | 5/3/7 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| ea-felt-poncho | EA | Uncommon | `foeB0>hand` | 5/2/5 | 6/3/7 | -0.12 | -0.12 | +0.0 | +0.0 |  |  |
| csa-curl-toe-slippers | CSA | Common | `linkT>dmg` | 6/2/5 | 6/3/7 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| csa-chili-cone-basket | CSA | Common | `linkT>heal` | 7/2/5 | 7/3/7 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| csa-porters-frame-pack | CSA | Uncommon | `linkC>hand` | 8/2/6 | 9/3/7 | +0.38 | +0.39 | +0.0 | +0.0 |  |  |
| csa-fleece-collar-jacket | CSA | Uncommon | `lastRound>mend` | 7/2/6 | 7/4/7 | -0.02 | -0.07 | +0.0 | +0.0 |  |  |
| sea-rattan-back-basket | SEA | Common | `linkT>plenty` | 7/3/5 | 8/3/7 | -0.32 | -0.31 | +0.0 | +0.0 |  |  |
| sea-bamboo-ladder-pack | SEA | Common | `linkT>hand` | 5/3/5 | 6/3/7 | +0.04 | +0.04 | +0.0 | +0.0 |  |  |
| sea-nipa-thatch-pack | SEA | Uncommon | `linkS>heal` | 8/3/6 | 8/3/9 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| sea-pandan-weave-vest | SEA | Common | `linkC>life` | 6/3/5 | 7/3/7 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| wca-raffia-cone-basket | WCA | Common | `lastRound>heal` | 7/3/5 | 7/3/8 | -0.02 | -0.02 | +0.0 | +0.0 |  |  |
| wca-indigo-hood-mantle | WCA | Uncommon | `foeB0>soothe` | 5/3/6 | 5/4/8 | -0.10 | -0.10 | +0.0 | +0.0 |  |  |
| wca-raffia-poncho | WCA | Uncommon | `linkC>skip` | 7/3/6 | 8/3/8 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| esa-baobab-clogs | ESA | Rare | `R:ESA:footwear` | 10/4/8 | 10/5/8 | -5.88 | -5.88 | +6.2 | +6.2 | -4.96 | -4.96 |
| esa-calabash-carrier | ESA | Common | `linkHeal>heal` | 6/3/6 | 6/4/9 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| esa-grain-sack-pack | ESA | Uncommon | `pair>heal` | 9/3/7 | 9/4/10 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| esa-stripe-weave-vest | ESA | Common | `foeB0>ward` | 7/3/6 | 7/4/9 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| esa-check-blanket-wrap | ESA | Common | `linkC>soothe` | 7/3/6 | 7/5/8 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| esa-highland-shawl | ESA | Common | `r1>bond` | 7/3/6 | 8/4/8 | +0.23 | +0.23 | +0.0 | +0.0 |  |  |
| esa-banana-leaf-rain-cape | ESA | Uncommon | `lastRound>shrink` | 6/3/7 | 6/5/9 | +0.00 | -0.21 | +0.0 | +0.0 |  |  |
| oc-reef-sandals | OC | Common | `linkS>hand` | 7/3/6 | 8/4/9 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| oc-drovers-pull-ons | OC | Uncommon | `linkT>pierce` | 8/3/7 | 9/4/10 | +0.00 | +0.00 | +0.0 | +0.0 |  |  |
| oc-flax-wading-wraps | OC | Uncommon | `foeB3>skip` | 8/3/7 | 9/4/10 | +0.08 | +0.08 | +1.0 | +1.0 |  |  |
| oc-flax-basket-pack | OC | Common | `linkC>plenty` | 8/3/6 | 9/4/9 | +0.29 | +0.29 | +0.0 | +0.0 |  |  |
| oc-drovers-oilskin | OC | Common | `linkT>thorns` | 7/3/6 | 7/5/9 | +0.00 | +0.11 | +0.0 | +0.0 |  |  |
| oc-bark-cloth-vest | OC | Uncommon | `linkT>mend` | 8/3/7 | 8/5/10 | -0.07 | -0.12 | +0.0 | +0.0 |  |  |
| oc-reef-sail-cloth-jerkin | OC | Uncommon | `lastRound>evade` | 8/3/7 | 9/4/10 | -0.06 | -0.06 | +0.0 | +0.0 |  |  |
| oc-frond-rain-cape | OC | Common | `linkT>soothe` | 7/3/6 | 7/5/9 | +0.00 | -0.30 | +0.0 | +0.0 |  |  |
