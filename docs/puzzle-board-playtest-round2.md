# Puzzle board playtest, round 2 (2.6.61 rules, 499 fights)

50 haiku agents, 250 classic/blank pairs on the same creature, level and seed (one fight unreported). Gnome level = creature level (50%), -4 (30%), -8 (20%); all 88 creatures; styles greedy, chain, charm, careful, random. Blank = blank centre piece that fires nothing, chains never run through it, creature pieces x1.2. Agent play, not human play; random/greedy were improvised by the agents (join/add/group were mostly not sampled).

## Headline
- **Blank plays harder than classic for the agents:** win 69% vs 80%, defeat 30% vs 18%, turns 7.6 vs 7.0. Paired: both win 160, only classic wins 40, only blank wins 11, both lose 38.
- By level offset (blank vs classic win): at level 87% vs 93%; -4: 68% vs 80%; -8: 24% vs 50%.
- By size (blank vs classic win): boss 74% vs 96%; large 70% vs 81%; medium 59% vs 70%; small 82% vs 89%.
- By style (blank vs classic win): random 32% vs 68%; careful 64% vs 74%; greedy 67% vs 80%; chain 88% vs 84%; charm 95% vs 98%.
- Fair 3.03 vs 3.35 and fun 2.92 vs 3.10 (1-5, agent ratings).
- The opening choice barely mattered ("little/no effect" in nearly every blank fight): the blank vanishes after turn 1 and nothing links through it.

## Why (and a tuning check)
The bot tuning (`tests/pfboard_tune.php`, greedy bot) said blank x1.2 is about equal to classic. Weaker players lose more to x1.2 creature pieces than a greedy bot does. Bot check of the multiplier: x1.0 gives blank 100% win at level (medium HP lost 16% vs classic 31%) and 51/76/100% at -8 (medium/large/boss) vs classic 46/66/81%; x1.1 gives 48/69/74%. Suggestion: set `PFB_BLANK_FOE_MULT` to 1.0 and re-run a smaller human/agent round. Not applied.

## Other findings
- **Forced hurting moves:** `pass` is refused while any piece has a legal cell, so a careful player with only `!` cells must place and self-hurt (single placements cost 20-46 HP). Most careful/greedy/random defeats were this plus creature combos. `!` flags only the placement's own link to a creature Hurt piece, not the creature's reply or chain depth.
- **Set-aside** (join/add/group, group x1.5): tried in ~110 blank fights; each step costs a full creature turn. Paid off when HP was high and the group had a legal cell (about half); lost fights when started at low HP or when the group had no legal cell. `show` does not list joins, so agents rarely sampled them.
- **Display gaps (harness/engine notes):** group placements are not `!`-marked; creature guard silently absorbs your Hurt (guard value not shown); "EXPIRED ... creature Blank" labels the blank as a creature piece and prints on turn 1; "CHAIN STOPPED" reads like an error on a win; `add` refusals do not say what ANC/SIDE mean; poison tick not in the brief; overshoot shown unclamped; `show` guard reads 0 after the creature moves.
- **Checked and not bugs:** "boss charm bar" on mangrove-crab-king / salt-sea-lion / wolverine / lichen-reindeer (all large); missing `!` on cells whose placement ends the fight first (the dry run stops before the creature piece fires); expiry counts from placement; group x1.5 is the 2.6.61 rule.
- 2 report files did not parse (recovered from logs); 1 fight unreported.
