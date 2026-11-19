# Balance: the 42 legend crop pieces (2026-11-19)

Bot sim of the 42 `g:<crop>` pieces (source `legend`, `game/includes/data/pf_pieces.txt`): the same gnome with and without each piece. **No piece is a clear outlier, nothing was changed.** Two pieces sit a little above the field (the two "skip a turn" ones, grains-of-paradise and clove); the rest spread inside +-2 points of each other.

## Method (reproducible)

```
php claude/legend-sim/legend_sim.php run 12,24,34 chain,greedy,look 120 2 SHARD/4 > l_SHARD.jsonl   # 4 shards in parallel, ~50,000 fights
python3 claude/legend-sim/agg.py l_*.jsonl                                                      # the tables below
```

- Real engine and decks (`pfboard.php`, `pfdeck.php`), the bots of `tests/pf_bots.php`, no DB. Engine as of 2.7.30 plus the `firex` rule and the boss tune rows of this branch.
- Gnome: the tuner's gnome of level **12, 24 and 34** (`tv_sources`: starter, belt, pals, crops, crafts, regions, up to 3 knacks); a legend piece is **mastery rank 2** (the gnome's rank in that crop) and switched on in the Larder, which has a free slot at those levels (4 / 5 / 5 slots; the run stops if the piece is not in the deck). One piece at a time.
- Creatures: every creature within 3 levels of the gnome (widened to 6), at their own level, the same creatures and seeds for every piece and for the baseline.
- Bots: chain (always the longest chain; what the tune rows are fitted to), greedy (careless), look (careful, a ceiling). 120 fights a piece, bot and level (+ baseline 480 per bot and level), 49,680 fights, 0 engine errors.
- Numbers are points against the baseline: `dwin` = win % with the piece - baseline (+ is easier), `dhp` = health lost % with the piece - baseline (- is better), mean over the 9 bot x level cells; `se` the standard error of that mean. A deck with the piece has ONE MORE PIECE than the baseline, so it is not paired (another shuffle): that is why the numbers are means over many fights.
- **Outlier rule**: a piece is flagged when its dwin or dhp is more than 3 points from the median of the 42 and more than 2.5 standard errors from it.

## Results

### Baseline (the tuner's gnome, no legend piece)

| level | bot | fights | win % | health lost % | turns |
|---|---|---|---|---|---|
| 12 | chain | 480 | 78.3 | 56.4 | 4.11 |
| 12 | greedy | 480 | 87.5 | 46.9 | 3.57 |
| 12 | look | 480 | 99.2 | 17.2 | 4.34 |
| 24 | chain | 480 | 66.9 | 78.5 | 8.45 |
| 24 | greedy | 480 | 84.2 | 64.8 | 7.03 |
| 24 | look | 480 | 100.0 | 12.9 | 8.68 |
| 34 | chain | 480 | 77.5 | 74.6 | 7.97 |
| 34 | greedy | 480 | 89.6 | 57.7 | 6.47 |
| 34 | look | 480 | 100.0 | 16.3 | 7.66 |


Median over the 42 pieces: dwin -1.13, dhp +1.46. Almost every piece is slightly *worse* than no piece: one more piece in a 20-piece deck dilutes it (the same effect as `claude/balance-2.7.08-notes.md` section 6, about -1 win / +1.5 health). So read the table by the *difference between pieces*, not the sign.

### Per piece (mean over the 3 bots and 3 levels; sorted by health)

| piece | type v tag | dwin | dhp | se win / hp | placed | fires / fight | by level (dwin / dhp) | flag |
|---|---|---|---|---|---|---|---|---|
| clove | hurt 4 trip | +0.3 | -1.8 | 1.1 / 0.9 | 28% | 0.66 | 12: +1.7 -5.3 / 24: +0.2 -1.2 / 34: -1.0 +1.2 | health saves |
| grains-of-paradise | charm 5 lull | +0.9 | -1.7 | 1.1 / 0.9 | 42% | 0.77 | 12: +2.5 -3.4 / 24: -0.1 -3.1 / 34: +0.1 +1.3 | health saves |
| cloudberry | item 7 - | -0.3 | -0.5 | 1.1 / 0.9 | 24% | 0.44 | 12: -1.7 +1.5 / 24: -0.1 -2.9 / 34: +1.0 +0.0 |  |
| yuzu | item 6 - | -0.4 | -0.3 | 1.1 / 0.9 | 24% | 0.44 | 12: -1.9 +1.7 / 24: -0.1 -2.7 / 34: +0.7 +0.1 |  |
| ackee | item 6 - | -0.5 | -0.3 | 1.1 / 0.9 | 24% | 0.44 | 12: -1.9 +1.8 / 24: -0.3 -2.6 / 34: +0.7 +0.1 |  |
| pecan | heal 4 simmer | -0.3 | -0.2 | 1.1 / 0.9 | 22% | 0.37 | 12: -0.3 +1.1 / 24: +0.2 -2.1 / 34: -1.0 +0.4 |  |
| tea | heal 3 simmer | -0.6 | +0.2 | 1.1 / 0.9 | 21% | 0.36 | 12: -1.9 +2.2 / 24: +0.2 -1.8 / 34: -0.1 +0.1 |  |
| finger-lime | heal 4 - | -0.7 | +0.4 | 1.1 / 0.9 | 20% | 0.34 | 12: -1.9 +2.1 / 24: +0.2 -1.5 / 34: -0.4 +0.5 |  |
| blueberry | heal 4 - | -0.8 | +0.5 | 1.1 / 0.9 | 19% | 0.33 | 12: -1.9 +2.4 / 24: -0.1 -1.5 / 34: -0.4 +0.5 |  |
| acai | heal 5 - | -0.8 | +0.5 | 1.1 / 0.9 | 20% | 0.35 | 12: -1.9 +2.1 / 24: -0.1 -1.0 / 34: -0.4 +0.4 |  |
| mangosteen | heal 5 - | -1.1 | +0.7 | 1.1 / 0.9 | 19% | 0.34 | 12: -1.9 +2.4 / 24: -0.6 -0.9 / 34: -0.7 +0.5 |  |
| sea-buckthorn | heal 4 plenty | -1.3 | +0.8 | 1.1 / 0.9 | 19% | 0.33 | 12: -2.2 +2.5 / 24: -0.9 -0.7 / 34: -0.7 +0.8 |  |
| hazelnut | guard 5 hold | -0.9 | +0.8 | 1.1 / 0.8 | 20% | 0.36 | 12: +0.8 +0.5 / 24: -1.5 -0.6 / 34: -2.1 +2.6 |  |
| ginseng | heal 5 - | -1.2 | +0.8 | 1.1 / 0.9 | 14% | 0.24 | 12: -1.4 +1.7 / 24: -1.2 -0.7 / 34: -1.0 +1.5 |  |
| sugarcane | hurt 5 - | -0.9 | +0.9 | 1.1 / 0.8 | 36% | 0.82 | 12: -0.6 +1.5 / 24: -0.9 -0.8 / 34: -1.3 +1.9 |  |
| baobab | guard 6 hold | -1.1 | +1.0 | 1.1 / 0.8 | 21% | 0.43 | 12: -0.6 +1.1 / 24: -1.7 -0.3 / 34: -1.0 +2.2 |  |
| caper | guard 4 evade | -0.8 | +1.1 | 1.1 / 0.8 | 11% | 0.20 | 12: -0.3 +0.1 / 24: -1.5 +0.1 / 34: -0.7 +3.1 |  |
| black-pepper | hurt 4 poison | -0.4 | +1.2 | 1.1 / 0.8 | 28% | 0.58 | 12: +1.1 +1.1 / 24: -1.2 -0.8 / 34: -1.3 +3.3 |  |
| salak | guard 5 evade | -1.1 | +1.3 | 1.1 / 0.9 | 16% | 0.31 | 12: -0.3 +0.5 / 24: -2.6 +0.4 / 34: -0.4 +3.0 |  |
| cashew | soothe 4 - | -1.5 | +1.4 | 1.1 / 0.8 | 14% | 0.24 | 12: -1.9 +1.8 / 24: -0.6 -0.1 / 34: -1.8 +2.4 |  |
| durian | guard 4 thorns | -1.3 | +1.4 | 1.1 / 0.8 | 17% | 0.30 | 12: -1.1 +1.5 / 24: -2.6 +0.4 / 34: -0.1 +2.4 |  |
| gooseberry | guard 5 - | -1.8 | +1.5 | 1.1 / 0.9 | 19% | 0.38 | 12: -1.7 +1.5 / 24: -3.4 +0.5 / 34: -0.4 +2.4 |  |
| nutmeg | charm 6 hum | -1.5 | +1.6 | 1.1 / 0.9 | 37% | 0.68 | 12: -1.1 +1.5 / 24: -3.4 +0.6 / 34: +0.1 +2.7 |  |
| vanilla | charm 6 - | -1.5 | +1.6 | 1.1 / 0.9 | 37% | 0.68 | 12: -1.1 +1.5 / 24: -3.4 +0.6 / 34: +0.1 +2.7 |  |
| saffron | charm 6 bond | -1.4 | +1.6 | 1.1 / 0.9 | 37% | 0.68 | 12: -1.1 +1.6 / 24: -3.4 +0.6 / 34: +0.4 +2.7 |  |
| shea | guard 5 - | -1.2 | +1.7 | 1.1 / 0.8 | 14% | 0.25 | 12: -0.0 +1.4 / 24: -1.7 +0.4 / 34: -1.8 +3.2 |  |
| kava | soothe 5 - | -1.9 | +1.7 | 1.1 / 0.8 | 15% | 0.29 | 12: -2.5 +2.2 / 24: -2.3 +0.7 / 34: -1.0 +2.2 |  |
| pistachio | trick 4 pluck | -1.6 | +1.7 | 1.1 / 0.9 | 16% | 0.24 | 12: -2.5 +2.2 / 24: -0.9 +0.1 / 34: -1.5 +2.9 |  |
| chestnut | hurt 5 - | -1.1 | +1.7 | 1.1 / 0.8 | 39% | 0.86 | 12: -0.6 +2.6 / 24: -0.1 -1.4 / 34: -2.6 +3.9 |  |
| cardamom | charm 5 hum | -1.4 | +1.8 | 1.1 / 0.9 | 35% | 0.65 | 12: -1.1 +1.7 / 24: -3.1 +0.9 / 34: +0.1 +2.9 |  |
| cinnamon | charm 5 - | -1.4 | +1.8 | 1.1 / 0.9 | 35% | 0.65 | 12: -1.1 +1.7 / 24: -3.1 +0.9 / 34: +0.1 +2.9 |  |
| cacao | charm 5 bond | -2.0 | +1.9 | 1.1 / 0.8 | 43% | 0.80 | 12: -1.7 +1.4 / 24: -2.8 +1.8 / 34: -1.5 +2.4 |  |
| carob | guard 6 - | -1.6 | +1.9 | 1.1 / 0.9 | 14% | 0.28 | 12: -1.4 +2.1 / 24: -2.6 +0.4 / 34: -1.0 +3.2 |  |
| wasabi | hurt 3 poison | -1.6 | +1.9 | 1.1 / 0.9 | 29% | 0.56 | 12: -1.7 +2.9 / 24: -1.7 -0.7 / 34: -1.5 +3.6 |  |
| coffee | hurt 5 plenty | -0.5 | +2.0 | 1.1 / 0.8 | 34% | 0.74 | 12: -0.8 +2.8 / 24: -0.1 +0.3 / 34: -0.7 +2.9 |  |
| almond | hurt 5 pierce | -0.6 | +2.2 | 1.1 / 0.8 | 40% | 0.89 | 12: -0.6 +2.9 / 24: +0.2 -0.4 / 34: -1.5 +4.2 |  |
| walnut | hurt 6 pierce | -0.5 | +2.3 | 1.1 / 0.8 | 42% | 1.01 | 12: -0.3 +3.0 / 24: +1.0 -0.9 / 34: -2.4 +4.9 |  |
| brazil-nut | hurt 4 bash | -1.6 | +2.5 | 1.1 / 0.9 | 40% | 0.79 | 12: -2.5 +3.0 / 24: +1.0 +0.8 / 34: -3.2 +3.7 |  |
| macadamia | hurt 6 - | -1.2 | +2.5 | 1.1 / 0.8 | 35% | 0.86 | 12: -1.1 +3.1 / 24: +0.2 -0.4 / 34: -2.6 +4.8 |  |
| kola | hurt 5 - | -1.6 | +2.6 | 1.1 / 0.8 | 34% | 0.78 | 12: -1.4 +3.5 / 24: -0.1 -0.1 / 34: -3.5 +4.5 |  |
| quince | guard 6 keep | -2.8 | +2.7 | 1.1 / 0.9 | 33% | 0.55 | 12: -3.3 +2.8 / 24: -2.6 +0.9 / 34: -2.4 +4.4 |  |
| cranberry | guard 5 keep | -2.9 | +2.8 | 1.1 / 0.9 | 33% | 0.54 | 12: -3.3 +3.0 / 24: -2.8 +1.0 / 34: -2.6 +4.6 |  |


### By type (mean of the pieces)

| type | pieces | dwin | dhp | placed | fires / fight |
|---|---|---|---|---|---|
| charm | 7 | -1.2 | +1.2 | 38% | 0.70 |
| guard | 10 | -1.6 | +1.6 | 20% | 0.36 |
| heal | 8 | -0.9 | +0.5 | 19% | 0.33 |
| hurt | 11 | -0.9 | +1.6 | 35% | 0.78 |
| item | 3 | -0.4 | -0.3 | 24% | 0.44 |
| soothe | 2 | -1.7 | +1.5 | 15% | 0.26 |
| trick | 1 | -1.6 | +1.7 | 16% | 0.24 |


## Findings

1. **Spread is small.** Health lost: from -1.8 (clove) to +2.8 (cranberry), win from +0.9 to -2.9; the standard error of a cell is about 1. Per type the means are within 1.3 win and 1.9 health of each other (item and heal best, guard and soothe worst).
2. **Two pieces flag, both "the creature skips a turn":** `clove` (hurt 4, trip: "It skips its next turn") and `grains-of-paradise` (charm 5, lull: "It loses its next turn"): 3.3 points of health lost below the median piece (flag "health saves"). Played again with 400 fights a bot and level next to a plain Hurt (`macadamia`, hurt 6, no knack) and a Keep guard (`cranberry`): grains-of-paradise **+2.7 win / -3.8 health** against no piece (`macadamia` -0.5 / +1.2), clove **+1.8 / -3.1**, strongest at level 12 (grains +2.7 / -4.8, clove +3.2 / -5.6) and about even at level 34. That is the same Trip effect that made the Common wear pieces `oc-flax-wading-wraps` and `wca-raffia-poncho` the top of their lists, and the same size: about the +3 win / -4 health goal of the wear pieces, for a piece that needs a treasure crop harvested 3 times. **Not changed**: not a clear outlier (the value is already at the formula: hurt 4 = base 4 + 2 legend - 2 trip), and a drop of the value would only move how often the bots place it (28-43% of fights).
3. **The bots under-play the support pieces** (placed in: heal 19%, soothe 15%, guard 20%, trick 16%, against hurt 35% and charm 38% of fights). So the heal / item / guard pieces read as ~0 or slightly negative here whatever they would give a person; item pieces (cloudberry, yuzu, ackee) look best of the support ones because their tag effect works whenever they are placed. Keeper guards (`cranberry`, `quince`, `keep`: -2.9 / +2.8) are the worst for the same reason as the Keeper wear pieces (the bots hold them in hand: see the wear-piece notes, "What the bots cannot judge"). **Not a finding about the pieces.**
4. **Twin pieces behave the same**, as built: `nutmeg` (charm 6 hum) and `vanilla` (charm 6, soft) differ by 0.0 win / 0.0 health, `cardamom` and `cinnamon` (charm 5) the same, `cranberry` / `quince` (keep) the same: the tag does not decide the result, the type and value do. No piece is dead (every piece was placed in at least 11% of fights; `caper` lowest).
5. Rank 2 only: ranks 1 and 3-4 add +0 / +2 / +4-5 to the value (`PFD_RANK_BONUS`); at rank 4 a piece lives 4 rounds (`life`). Not run.

## Caveats

- The baseline deck has one piece fewer, so single-piece numbers have about +-1 win / +-0.9 health of noise even at 9 cells (see `se`); only the 3-point gaps above are readable.
- Bots, not players (see finding 3): a person plays Heal, Guard, Keeper, Simmer and Plenty on purpose. Piece effects that need planning (`plenty`, `keep`, `simmer`, `pluck`: the item lift is worth nothing inside the fight) read low here.
- Larder pieces compete for 3-5 slots with the crop pieces; the sim adds a legend piece on top of the crops the gnome has, as the tuner's gnome does for Larder pieces at these levels.
