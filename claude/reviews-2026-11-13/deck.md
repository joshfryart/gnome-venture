# Deck (Puzzle box) and pieces review: puzzle combat v1, 2.6.94

Code read and simulated: committed HEAD `6b823f9c` only (a `git archive` copy in `scratchpad/fable/head/`), not the uncommitted work in the repo. No repo file was changed.

## Verdict

1. **For a simple player the deck has one variable that matters: the share of Hurt pieces.** 8 pieces that are all Hurt win 94%; the same gnome with everything it owns (32 pieces) wins 73%; 1 Hurt + 7 Charm wins 56%. Deck size does not matter by itself (12 to 33 pieces: 68-73%).
2. **For a good player the deck barely matters at all.** The look bot wins 95-100% with every deck tested, most of them 3 levels under the creature. The deck only changes fight length (4.2 to 12.3 turns) and health lost (9-40%).
3. **Pieces do not differ enough.** 74 of the 90 pieces tested are inside the noise (within 2 standard errors of zero). What separates them is the type, not the knob family, column, life or base value.
4. **Charm and Trick pieces cost wins** (-2.4 and -2.3 points each on average). The core Charm piece is the worst piece in the catalogue (-6.3).
5. **Teamwork, per-piece life, the knob families and the harmony meter have no measurable effect.** Each is a rule the player has to learn.
6. **The collect loop is invisible and pays almost nothing.** No page tells you that a crop, craft or guide gave you a piece, and the average crop / craft / region piece is worth +0.3 / -0.1 / +0.7 points.

## What I ran

Scripts and raw sums are in `scratchpad/fable/deckrev/` (`piece.php`, `size.php`, `mix.php`, `kits.php`, `life.php`, `static.php`, `dagg.py`, `comb.py`, `groups.py`) and `scratchpad/fable/out/` (`piece_*`, `deck_*`, `size_*`, `mix_*`, `life_*`, `kits_*`).

- They require the committed `tests/pfboard_tune_v1.php` and reuse its bots, the 88 real creatures, the layered creature decks (region rotates with the seed), the blank-centre opening and the 40-turn cap.
- The gnome is the tuner's typical gnome (`tv_sources`), with calling, kit and home rotated by seed, as the opus report did.
- **Per piece:** for each fight the piece is forced into the deck (added at rank 1 if the gnome does not have it) and the same fight is run without it. 88 creatures x 12 seeds x 2 level offsets (gnome at the creature's level, and 3 under) = 2112 fights with and 2112 without per piece, chain bot. 90 pieces: the 77 in `pf_pieces.txt`, a second Swing, 10 made-up pal pieces and the tuner's two pals.
- **Bots:** chain = always the longest chain (a simple player). Look = best state after the whole round (a good player).
- **Noise:** one piece's win delta has a standard error of 1.4 points, so under about 3 points is noise. Group averages (by type, tag, knob) have 0.3-1.0.
- Baseline, chain bot: 79.1% wins at level, 61.2% under 3 levels.

## Is the loop understandable and rewarding?

**Understandable: partly.**
- The starter pick is clear: 4 fixed pieces, pick 6 of 12, three one-tap kits. I saw it rendered at 390 px in another agent's screenshot (`scratchpad/fable/s0_pre.png`).
- The link from the world to the box is missing. Only `adventure.php`, `crafting.php` (the belt and repair items), `pfight*.php` and `puzzlebox.php` call the deck model. Farming, cooking, crafting and the guides never say "you earned a piece".
- The Kit tab lists only pieces you own (`pfd_build`, `$owned`). There is no list of what you could earn or how.
- Knacks unlock by level, start switched off, and are labelled "Starter" in the box (`pfv1box.js` line 40). Crop, craft and region pieces start switched on, so the deck grows without the player choosing.

**Rewarding: no, except early Hurt tools and rank.**

| What you collect | Win delta, chain bot |
|---|---|
| Average crop piece (9) | +0.3 (se 0.5) |
| Average craft piece (7) | -0.1 (se 0.5) |
| Average region piece (14) | +0.7 (se 0.4) |
| Average tool piece (18) | +0.7 (se 0.3) |
| Hoe Hook or Chop, creature levels 1-10 | +8.7 / +8.9 |
| Hoe Hook or Chop, creature levels 11+ | +1.2 / -0.1 |
| Tools at Rare and crops at Uncommon, levels 1-10 | +11.9 at level, +26.1 at 3 under |
| The same, all levels | +4.1 at level, +9.2 at 3 under |

Rank is the only reward that is felt, and only at low level, because +2 / +4 is large next to base values of 2-6.

## Do pieces differ enough?

### By type (chain bot, both offsets pooled)

| Type | Pieces | Win delta (se) | Levels 1-10 | Levels 11+ | Turns delta |
|---|---|---|---|---|---|
| Hurt | 22 | +2.0 (0.3) | +3.9 | +1.4 | -0.31 |
| Guard | 23 | +0.6 (0.3) | +0.8 | +0.6 | +0.20 |
| Heal | 10 | +0.2 (0.4) | -0.6 | +0.4 | +0.29 |
| Item | 3 | -0.4 (0.8) | -0.2 | -0.5 | +0.30 |
| Soothe | 2 | -0.6 (1.0) | -1.9 | -0.2 | +0.28 |
| Trick | 9 | -2.3 (0.5) | -3.8 | -1.8 | -0.04 |
| Charm | 9 | -2.4 (0.5) | -2.5 | -2.4 | +0.11 |

### By type for a good player (look bot, gnome 3 under, 264 fights with and without per piece)

Baseline: 98.1% wins, 20.6% health lost, 8.0 turns. Wins do not move (every type within +-0.9 points), so the measure is health lost and turns.

| Type | Health lost delta | Turns delta |
|---|---|---|
| Item | -2.4 | +0.25 |
| Heal | -2.0 | +0.37 |
| Soothe | -1.8 | +0.44 |
| Guard | -1.7 | +0.17 |
| Trick | -0.8 | +0.02 |
| Charm | -0.1 | +0.28 |
| Hurt | 0.0 | -0.44 |

- For a good player the trade is real but small: a Guard, Heal or Item piece saves about 2 points of health, a Hurt piece saves about half a turn.
- Charm gives neither. The look bot plays Charm pieces least of all (0.09-0.10 plays per hand-turn; Hurt and Guard pieces 0.28-0.36).
- Single pieces range from -4.2 to +4.5 points of health lost, which at 264 fights is mostly noise (spread 1.65). I draw no per-piece conclusions from this run.
- Knob family again does nothing: body -0.8, craft -1.3, mind -1.1.

### Dominant pieces (chain bot)

| Piece | Win delta (se 1.4) | Note |
|---|---|---|
| Pal Hurt, base 12 (a rare pal at its cap) | +8.9 | +19.5 at levels 1-10 |
| Pal Hurt, base 9 | +7.3 | +15.5 at levels 1-10 |
| Thorn Cut (Thornblade calling, Hurt 7) | +5.4 | |
| Net Toss (tool, Hurt 2, trip) | +4.7 | |
| Trip (knack, Hurt 2, trip) | +4.5 | |
| Windfall (crop, Hurt 5) | +4.0 | |
| Smash (knack, Hurt 6) | +3.2 | +8.7 at levels 1-10 |

Trip and Net Toss are strong at base value 2 because Trip takes the creature's whole turn in v1: it plays one piece a turn and `pfb_foe_len` returns `1 - slow`. The card says "plays one tile fewer". Lull has the same rule but measures -0.9, because it is a Charm piece.

### Useless or harmful pieces (chain bot)

| Piece | Win delta (se 1.4) | Health lost delta |
|---|---|---|
| Charm (core, cannot be left out of the starter) | -6.3 | +4.2 |
| Hum (knack, in the Kind kit) | -4.6 | +3.6 |
| Sweep (staff tool, Guard, evade) | -3.2 | +1.7 |
| Wind Chime (decor craft) | -3.1 | +2.4 |
| Soothe | -2.6 | +2.4 |
| Hide, Taunt, Dry Spell (plain Tricks) | -2.6 each | +1.8 |
| Pluck, Sow Doubt, Reel In, Slip Past, Steam, Probe (Tricks) | -1.9 to -2.4 | +1.1 to +2.1 |
| Bloom (Bloomcaller calling piece) | -2.3 | +1.9 |

- A player Trick does nothing by itself (`pf_apply`: it only pays through Ambush or Bait, when the next piece in the chain is your own Hurt or Guard). Your own pieces link to each other on only 12-42% of plays, so the Trick usually fires for nothing.
- Two calling pieces (Bloom, Sow Doubt) and Slip Past are negative, so three of six callings get a calling piece that makes the deck worse. Thorn Cut is +5.4, Bark Wall +2.1, Steep +0.9.
- Sweep's -3.2 may be partly noise: the other Guard / evade pieces (Roll +1.8, Mist Veil 0.0, Heat Shimmer 0.0) do not show it.

### Things that look like choices but are not

| Axis | Measured | Reading |
|---|---|---|
| Right knob family | body +0.1, craft +0.9, mind -0.2 (se 0.3) | No choice. |
| Column family | body +1.4, craft -0.1, mind -0.7 | Follows the type (Hurt and Guard are body). |
| Hurt base value 2 / 3 / 4 / 5 / 6 / 7 | +1.8 / +1.8 / +1.2 / +3.0 / +3.2 / +5.4 | 2, 3 and 4 are the same piece. Only 5+ is felt. |
| Guard base value 2 / 3 / 4 / 6 | +1.8 / +0.6 / -0.1 / +2.1 | No trend. |
| Life: every piece in the deck at 2 rounds vs 4 rounds | 77.5% vs 79.6% (se 1.8); look bot 22.1% vs 20.7% health lost | No effect, even applied to the whole deck. |
| Heavy tag (Smash, Fork Lift, Windfall) | No rule on the board | The "last tile of a chain" rule is only in the strip engine (`pfight.php` line 538). The card still shows it. |
| Hurt tags: plain / pierce / bash / quick / poison / heavy / trip | +1.8 / +1.8 / +1.1 / +0.2 / +2.4 / +3.1 / +4.6 (se 0.6-1.0) | Trip stands out. Quick is the weakest: base 2 and life 2. |

Values are compressed by the level term: every piece gets `level / 3` flat (`pf_make_tile`). Jab 2 vs Smash 6 at level 1 is 12 vs 16 at level 30. On the rendered starter screen of a level 12 gnome the 12 offered pieces show 6 to 9.

### Edge patterns and link rate

**No edge pattern is dead in play.** Each turn I checked whether each hand piece had any cell where it links (flip allowed).

| Pattern (right knob / column) | Can link, share of hand-turns | Examples |
|---|---|---|
| body / craft | 91-94% | Snack, Compost Lob, Hoe Hook, Hide |
| body / body | 89-91% | Dodge, Smash, Roll, Frost Bark |
| body / mind | 88-89% | Hum, Spud Shield, Windfall, Herb Poultice |
| mind / craft | 86-89% | Cool Shower, Sweep, Probe |
| craft / craft | 85-87% | Dibber Poke, Net Toss, Glare, Hot Soup |
| craft / body | 82-85% | Jab, Trip, Brace, Thorn Cut |
| mind / body | 82-84% | Swing, Pierce, Thorn Hide |
| mind / mind | 85-86% | Soothe, Bond, Bloom, Nut Crack |
| craft / mind | 79-81% | Rest, Charm, Lull, Oat Cake, Steep |

- The spread is 79% to 94%, and it does not show in the win rates.
- When a piece is played it starts a chain of 2 or more on 78-100% of plays (the must-link rule forces it).
- Static check against the 817 creature pieces: 81% are Hurt or Guard (body holes), 18% Trick (craft), 2% Heal (mind). So a mind right knob links to a creature piece on that side 2% of the time, craft 18%, body 81%. The environment pieces and the columns make up for it.
- **The harmony meter cannot tell decks apart.** "Hand links" was 99.9-100% for every deck built (13 variants x 1408 fights) and "link rate" was 33-36% for all of them. The meter's "good" threshold is 30%.

## Deck size and capacity by level

There is no capacity. The design's "kit max 10 + level / 6" was replaced by "no maximum" (DECIDED 2). The only limits are kit minimum 8, 1 Hurt, 3 Rare and 1 Masterwork. The belt gives 2 / 3 / 4 tool slots (Belt II 600 Petals at level 8, Belt III 2500 at level 18). The tuner's typical deck is 14 pieces at level 3, 23 at level 12 and 27 at level 25.

**Size alone is neutral.** The same shuffled pool cut to the first N pieces (3 Hurt kept in front), chain bot at level:

| Pieces | 6 | 8 | 10 | 12 | 14 | 17 | 20 | 24 | 28 | 33 | all (32.2) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Win % | 83.8 | 79.6 | 74.4 | 71.8 | 70.8 | 67.9 | 68.6 | 72.5 | 70.1 | 70.2 | 71.8 |

The small decks win because 3 of their pieces are Hurt, not because they are small.

**Composition is everything** (random pieces of each kind from what the gnome owns):

| Deck | Chain bot at level: win % / health lost % / turns | Look bot 3 under: win % / health lost % / turns |
|---|---|---|
| 8 pieces, 8 Hurt | 93.9 / 50 / 4.5 | 100 / 29 / 4.2 |
| 8 pieces, 6 Hurt | 88.9 / 56 / 5.2 | 100 / 25 / 4.9 |
| 8 pieces, 4 Hurt + 4 Guard or Heal | 89.3 / 53 / 6.3 | 99.4 / 18 / 6.7 |
| 8 pieces, 4 Hurt | 81.7 / 62 / 6.2 | 99.4 / 24 / 6.5 |
| 8 pieces, 4 Hurt + 4 Charm | 79.4 / 65 / 6.3 | 100 / 34 / 6.5 |
| 8 pieces, 2 Hurt | 69.3 / 70 / 8.7 | 97.2 / 18 / 10.1 |
| 8 pieces, 3 Hurt + 5 Charm | 69.1 / 73 / 7.2 | 99.1 / 35 / 7.1 |
| 8 pieces, 1 Hurt + 7 Charm | 56.1 / 78 / 8.7 | 94.7 / 40 / 10.2 |
| 16 pieces, 12 Hurt | 91.1 / 55 / 5.6 | 100 / 23 / 5.1 |
| 16 pieces, 8 Hurt | 82.6 / 60 / 6.6 | 99.2 / 23 / 6.4 |
| 16 pieces, 4 Hurt | 62.7 / 75 / 9.6 | 99.3 / 18 / 10.1 |
| Everything owned (30-32 pieces) | 72.6 / 67 / 8.2 | 99.4 / 23 / 8.7 |

Cells with many Hurt pieces exist only where the gnome owns that many, so they lean to higher levels (n 469-880 chain, 75-176 look).

**Levels 1-10.** The choice that matters is made once, on the starter screen, and the default is the worst option. Kits alone, no gear, chain bot at level:

| Kit | Hurt pieces of 10 | Creature levels 1-4: win % / turns | Creature levels 5-10: win % / turns |
|---|---|---|---|
| Bold | 4.2 | 79.3 / 6.9 | 56.4 / 7.9 |
| Kind | 2.2 | 74.1 / 8.1 | 39.7 / 9.4 |
| Steady (also `PFD_KIT_DEFAULT`, played until a starter is chosen) | 2.2 | 63.3 / 10.1 | 39.2 / 10.3 |

n = 270 and 390 per cell. The look bot wins 95-100% with all three, but Steady takes 9.4-12.3 turns against 5.7-8.4 for Bold. The starter check asks for only 2 Hurt pieces.

**Levels 10-30.** More pieces arrive, switched on (crops, crafts, regions) or off (knacks), and no choice between them changes much: removing all crop, craft or region pieces moves wins by -1.2 / -1.6 / -0.6 at level (se 1.5). Switching every knack on (deck 32) costs -8.5 at level and -9.3 at 3 under, because 7 of the 17 knacks are Charm, Trick or Soothe. "No maximum" is a trap for a player who packs everything.

## Are the sources and Teamwork worth the complexity?

| Change to the typical deck | Chain at level, win delta (se 1.5) | Chain 3 under (se 1.8) | Look 3 under, health lost delta |
|---|---|---|---|
| No pals | +1.5 | -0.4 | -2.2 |
| No tools | -2.2 (levels 1-10: -9.7, se 3.6) | -3.4 | -2.4 |
| No crops | -1.2 | -2.1 | +3.1 |
| No crafts | -1.6 | -1.6 | -0.6 |
| No region pieces | -0.6 | +1.1 | -0.6 |
| No gear (tools and pals) | -2.5 (levels 1-10: -9.9) | -2.6 | -2.3 |
| Teamwork off | -0.2 | -1.1 | +0.7 |
| Teamwork at x1.6 / x2.2 (now x1.3 / x1.6) | +0.9 | +1.3 | -0.9 |

- **Tools: yes at levels 1-10, no later.** The two modelled tools are both Hurt pieces, which is why they count.
- **Pals: not as modelled.** The tuner's first pal is a Guard 5 piece (-1.9). A Hurt pal of the same value is +4.7 (+9.1 at levels 1-10) and a rare Hurt pal is +8.9 (+19.5). The pal unlock is not felt because of the piece's type and value, not because pals cannot matter. I did not check which types real pals produce (`pfd_pal_pieces` derives them from skills and Boon).
- **Crops, crafts, regions: no.** 30 authored pieces whose average value is zero and whose only visible difference is the name.
- **Teamwork: no.** It fires in 0.34 chains a fight (0.47 for the look bot), and switching it off costs nothing measurable. Doubling the bonus still gives under 1.5 points. Two causes:
  - A chain holds two or more of your own pieces on only 12-42% of plays; most links are to creature and environment pieces.
  - Pal, tool and crop pieces have different column families (body, craft, mind), so two Teamwork pieces can never stack. 65-67% of pairs can link side by side, 0% above or below (`static.php`).
  - None of the 29 playtest reports in `scratchpad/hk/` mentions Teamwork. Three (r9, r18, r29) report dull turns with no Hurt piece in hand.

## Recommendations, ranked

Cost: S = data or text and a test, under half a day. M = engine rule in PHP and JS with parity tests, 1-2 days. L = more. None of these was tested as a fix unless it says so.

| # | Change | Kind | Evidence | Cost |
|---|---|---|---|---|
| 1 | Give every one-tap kit 4 Hurt pieces, make Bold the default kit, and raise the starter minimum from 2 Hurt to 3 or 4. | Buff | Steady 63% / 39% vs Bold 79% / 56%; Steady fights last 10 turns | S |
| 2 | Make Trick do something when it fires alone (for example: weaken the creature's aimed piece by its value, or mark the creature so your next Hurt this round counts x1.5 wherever it is). | Buff | 9 Tricks at -2.3; plain Tricks -2.6 | M |
| 3 | Make Charm worth choosing: let the core Charm be swapped out in the starter, and either raise the Charm factor on hostile creatures (x0.5 now) or let Charm also lower the creature's next hit. Rework Bloom, Sow Doubt and Slip Past so no calling piece is negative. | Buff | Charm -6.3, Hum -4.6, Charm type -2.4; 1 Hurt + 7 Charm wins 56% | S for the swap, M for the rule |
| 4 | Cut Teamwork from the fight, or turn it into a box-level bonus ("pieces from 2 / 3 sources in the deck: +x% to all") so the sources matter where the player builds. | Cut | Off: -0.2 / -1.1 points; 0.34 chains a fight; 0 of 29 playtests mention it | S to cut, S-M for the box bonus |
| 5 | Make the pal piece a milestone: a floor on its value, a Hurt or tagged piece for the first pal, and the Boon as its tag (design gap 7). | Buff | Guard 5 pal -1.9; Hurt 5 pal +4.7; Hurt 12 pal +8.9 | M |
| 6 | Tell the player when a piece is earned (a line after the harvest, craft, guide or level-up, with a link to the box), show unearned pieces as locked cells with "grow a tuber", and label knacks "Knack", not "Starter". | UI | No hook exists outside the fight pages | S for the lines, M for the locked cells |
| 7 | New pieces start switched off with a "New" mark, or bring back a kit maximum (the design's 10 + level / 6). | UI | All knacks on: -8.5 / -9.3; the deck grows without a choice | S |
| 8 | Replace the harmony meter and the Knobs bar with a Hurt count and a plain warning ("3 Hurt in 22: fights will be long"). | UI / cut | Hand links 100% and link rate 33-36% for every deck | S |
| 9 | Fix the tag texts: Heavy has no rule on the board; Trip and Lull take the creature's whole turn. Give Heavy a board rule (for example: it is not used up by a chain of 3+) or drop the tag. | Fix | `pfight.php` 538, `pfb_foe_len` | S for the text, M for a rule |
| 10 | Drop per-piece life from the cards (keep 3 for all), or give it teeth (Hold pieces survive use-up). | Cut | Whole deck at life 2 vs 4: 77.5% vs 79.6% (se 1.8) | S to cut, M for a rule |
| 11 | Nerf nothing now. Trip and Net Toss (+4.5 / +4.7) are the only cheap outliers; fix their text first and watch them. | Nerf | Table above | none |
| 12 | Spread the values: scale by a factor per level instead of a flat `level / 3`, or widen the base values (Hurt 2-4 are one piece today). | Rebalance | Hurt base 2 / 3 / 4: +1.8 / +1.8 / +1.2 | M-L, needs a full retune |
| 13 | Cut the crop, craft and region pieces to one piece per source with a real effect, or give each a tag that touches the rules that decide fights. | Cut / rework | 30 pieces averaging +0.3 / -0.1 / +0.7 | M |

**New piece ideas** (not tested; each is M). They touch the three rules that decide fights today: use-up, the environment, and the creature's aim.
- **Anchor** (Guard): is not used up by a chain of 3 or more.
- **Lightning rod** (Trick): fires an environment piece next to it for you.
- **Feint** (Trick): the creature's aimed piece plays at half value this round.
- **Second wind** (Heal): returns one used-up Hurt piece to your hand.
- **Lure** (Charm): on a gentle creature, also counts on the damage bar, so a mixed deck stops splitting its effort between two bars.

## What I did not verify

- **No human play.** The chain bot stands in for a simple player. It scores damage and charm progress together and plays Guard and Heal pieces rarely (0.10-0.16 plays per hand-turn against 0.3-0.5 for Hurt), so the values of Guard, Heal, Charm and Trick are lower bounds for a thinking player.
- **The look bot per piece** has only 264 fights a piece (3 seeds), enough for the type averages and not for single pieces.
- **The smart bot** (set-aside, two turns) was not run.
- **The box pages.** I read `pfdeck_view.php` and `pfv1box.js`. I saw only the starter screen rendered, in another agent's screenshot. `tests/pbox_v1_shots.js` was not run; the Kit, Belt and Pals tabs were not seen in a browser.
- **The gnome model** is the tuner's: stats 0 until level 11, tool tiers by level, two fixed pals, knacks by level. Real players' tools, pals, crops and stats were not sampled. On the rendered screen a level 12 gnome's Swing shows 8.
- **Pieces were added at rank 1.** Upgrades (`user_pmod`), tool wear and Snack running out were off.
- **Per-piece noise.** One piece's delta has se 1.4; deltas under 3 points are not findings. Adding a piece also changes the shuffle, so fights are not paired draw for draw.
- **Gentle vs hostile creatures** were not split (30 of 88 species are gentle; Charm counts x1 on them, x0.5 on the rest, and bosses cannot be charmed).
- **None of the recommended fixes was simulated**, apart from the kit comparison, the Teamwork multipliers and the life sweep above.
- The JS engine, MySQL and a phone were not touched.

## Appendix: every piece, ranked

Chain bot, 88 creatures x 12 seeds x 2 offsets. "Can link" = share of hand-turns with a linking cell (flip allowed). "Played" = plays per hand-turn. Pal pieces `pal:TYPE+VALUE` are made up for the test (`m` / `c` = mind / craft right knob); Bark Badger and Samara Spin are the tuner's pals and were only removed where present.

| # | piece | fights | win delta (se) | at level | 3 under | hp lost delta | turns delta | lv 1-10 | lv 11+ | can link | played / hand-turn |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | pal:hurt12 | 2112 | +8.9 (1.3) | +6.2 | +11.6 | -7.9 | -0.96 | +19.5 | +5.4 | 89% | 0.54 |
| 2 | pal:hurt9 | 2112 | +7.3 (1.3) | +5.2 | +9.5 | -5.7 | -0.76 | +15.5 | +4.6 | 89% | 0.51 |
| 3 | thorn | 2112 | +5.4 (1.4) | +4.8 | +5.9 | -3.2 | -0.47 | +8.1 | +4.4 | 82% | 0.42 |
| 4 | t:net | 2112 | +4.7 (1.4) | +4.1 | +5.3 | -2.7 | -0.09 | +4.2 | +4.9 | 87% | 0.24 |
| 5 | pal:hurt5 | 2112 | +4.7 (1.4) | +3.9 | +5.5 | -2.7 | -0.45 | +9.1 | +3.2 | 90% | 0.44 |
| 6 | pal:hurt5c | 2112 | +4.6 (1.4) | +3.8 | +5.5 | -2.6 | -0.36 | +8.1 | +3.5 | 85% | 0.38 |
| 7 | trip | 2112 | +4.5 (1.4) | +4.1 | +4.8 | -2.4 | -0.01 | +4.0 | +4.6 | 85% | 0.22 |
| 8 | c:tree | 2112 | +4.0 (1.4) | +3.1 | +4.8 | -2.2 | -0.37 | +4.7 | +3.7 | 88% | 0.35 |
| 9 | pal:hurt5m | 2112 | +3.5 (1.4) | +2.5 | +4.5 | -1.9 | -0.37 | +6.1 | +2.7 | 83% | 0.37 |
| 10 | smash | 2112 | +3.2 (1.4) | +1.1 | +5.2 | -2.5 | -0.54 | +8.7 | +1.3 | 89% | 0.43 |
| 11 | t:till | 2112 | +3.1 (1.4) | +3.5 | +2.7 | -0.3 | -0.42 | +8.7 | +1.2 | 93% | 0.51 |
| 12 | k:garden | 2112 | +2.8 (1.4) | +4.2 | +1.5 | -1.3 | -0.56 | +6.2 | +1.7 | 94% | 0.35 |
| 13 | c:spice | 2112 | +2.6 (1.4) | +1.5 | +3.7 | -3.0 | -0.62 | +6.4 | +1.3 | 88% | 0.31 |
| 14 | swing#2 | 2112 | +2.5 (1.4) | +2.5 | +2.6 | -0.7 | -0.32 | +6.4 | +1.2 | 82% | 0.31 |
| 15 | r:WCA | 2112 | +2.2 (1.4) | +2.0 | +2.4 | -0.0 | +0.14 | +4.0 | +1.6 | 84% | 0.14 |
| 16 | r:ESA | 2112 | +2.2 (1.4) | +2.0 | +2.4 | -0.0 | +0.14 | +4.0 | +1.6 | 84% | 0.14 |
| 17 | t:axe | 2112 | +2.2 (1.4) | +2.3 | +2.1 | -0.2 | -0.41 | +8.9 | -0.1 | 92% | 0.47 |
| 18 | bark | 2112 | +2.1 (1.4) | +2.8 | +1.3 | -0.4 | +0.06 | +3.4 | +1.6 | 91% | 0.14 |
| 19 | t:water | 2112 | +2.0 (1.4) | +1.8 | +2.3 | -0.9 | +0.24 | -0.4 | +2.8 | 86% | 0.15 |
| 20 | t:broadfork | 2112 | +2.0 (1.4) | +1.8 | +2.3 | -1.0 | -0.40 | +4.5 | +1.2 | 93% | 0.46 |
| 21 | pal:heal5 | 2112 | +1.8 (1.4) | +2.2 | +1.4 | -1.4 | +0.26 | +1.3 | +2.0 | 88% | 0.17 |
| 22 | mending | 2112 | +1.8 (1.4) | +1.8 | +1.8 | -0.1 | +0.23 | +1.9 | +1.8 | 84% | 0.11 |
| 23 | sting | 2112 | +1.8 (1.4) | +1.7 | +1.9 | -1.1 | -0.53 | +4.7 | +0.8 | 90% | 0.27 |
| 24 | roll | 2112 | +1.8 (1.4) | +2.2 | +1.3 | -0.6 | +0.21 | +0.8 | +2.1 | 90% | 0.15 |
| 25 | thornhide | 2112 | +1.7 (1.4) | +2.1 | +1.3 | -0.2 | +0.11 | +2.8 | +1.3 | 84% | 0.14 |
| 26 | r:OC | 2112 | +1.7 (1.4) | +2.6 | +0.8 | -0.8 | +0.21 | +0.9 | +1.9 | 90% | 0.15 |
| 27 | r:EE | 2112 | +1.7 (1.4) | +1.3 | +2.0 | -0.6 | +0.25 | +0.8 | +2.0 | 85% | 0.11 |
| 28 | t:bucket | 2112 | +1.4 (1.4) | +1.3 | +1.5 | +0.2 | +0.21 | -0.4 | +2.0 | 86% | 0.15 |
| 29 | r:CSA | 2112 | +1.4 (1.4) | +1.2 | +1.6 | -0.4 | +0.26 | -1.5 | +2.4 | 88% | 0.12 |
| 30 | r:CB | 2112 | +1.4 (1.4) | +1.1 | +1.7 | -0.6 | +0.24 | +0.6 | +1.7 | 85% | 0.11 |
| 31 | pal:guard5 | 2112 | +1.4 (1.4) | +1.4 | +1.4 | +0.2 | +0.21 | +1.3 | +1.5 | 84% | 0.11 |
| 32 | pal:guard9 | 2112 | +1.4 (1.4) | +1.4 | +1.3 | +0.2 | +0.21 | +1.7 | +1.3 | 84% | 0.11 |
| 33 | pierce | 2112 | +1.4 (1.4) | +1.3 | +1.4 | +0.5 | -0.29 | +5.7 | -0.1 | 83% | 0.32 |
| 34 | bash | 2112 | +1.3 (1.4) | +1.2 | +1.4 | +0.3 | -0.16 | +0.0 | +1.8 | 84% | 0.21 |
| 35 | t:lantern | 2112 | +1.3 (1.4) | -0.3 | +2.9 | +0.4 | +0.15 | +3.4 | +0.6 | 87% | 0.29 |
| 36 | r:SE | 2112 | +1.3 (1.4) | +1.3 | +1.3 | -0.4 | +0.10 | -1.7 | +2.3 | 84% | 0.11 |
| 37 | t:prune | 2112 | +1.3 (1.4) | +1.1 | +1.4 | -0.3 | -0.34 | +2.3 | +0.9 | 93% | 0.43 |
| 38 | k:cooking | 2112 | +1.2 (1.4) | +1.4 | +0.9 | -0.5 | +0.22 | +0.2 | +1.5 | 85% | 0.14 |
| 39 | pal:Samara Spin | 1656 | +1.1 (1.5) | +0.2 | +2.1 | -0.8 | -0.33 | +5.6 | +0.9 | 91% | 0.48 |
| 40 | c:grain | 2112 | +1.1 (1.4) | +0.8 | +1.5 | +0.1 | +0.13 | +4.5 | +0.0 | 79% | 0.10 |
| 41 | t:plant | 2112 | +1.1 (1.4) | +1.5 | +0.7 | +0.3 | -0.13 | -1.1 | +1.8 | 87% | 0.24 |
| 42 | k:pantry | 2112 | +1.1 (1.4) | +1.4 | +0.8 | +0.5 | -0.12 | -1.1 | +1.8 | 87% | 0.24 |
| 43 | r:SA | 2112 | +1.0 (1.4) | +1.6 | +0.5 | -0.1 | +0.20 | +0.4 | +1.3 | 90% | 0.15 |
| 44 | brace | 2112 | +1.0 (1.4) | +1.5 | +0.5 | +0.4 | +0.32 | -2.3 | +2.1 | 82% | 0.11 |
| 45 | brew | 2112 | +0.9 (1.4) | +1.9 | -0.1 | -0.7 | +0.38 | +2.5 | +0.4 | 80% | 0.09 |
| 46 | t:pick | 2112 | +0.9 (1.4) | +0.6 | +1.1 | -0.3 | -0.34 | +0.2 | +1.1 | 93% | 0.38 |
| 47 | c:nut | 2112 | +0.8 (1.4) | -0.2 | +1.8 | +0.0 | -0.25 | +2.1 | +0.4 | 85% | 0.29 |
| 48 | c:tuber | 2112 | +0.8 (1.4) | +0.8 | +0.8 | -0.0 | +0.17 | -1.5 | +1.5 | 89% | 0.14 |
| 49 | t:weed | 2112 | +0.7 (1.4) | +0.8 | +0.6 | +0.3 | -0.22 | +0.9 | +0.6 | 89% | 0.32 |
| 50 | r:NA | 2112 | +0.7 (1.4) | +1.9 | -0.6 | +0.5 | +0.21 | +1.5 | +0.4 | 90% | 0.15 |
| 51 | t:spread | 2112 | +0.5 (1.4) | +0.5 | +0.5 | +0.2 | +0.24 | -0.8 | +0.9 | 89% | 0.16 |
| 52 | r:EA | 2112 | +0.4 (1.4) | +0.8 | +0.0 | +0.6 | +0.27 | +1.9 | -0.1 | 84% | 0.12 |
| 53 | t:harvest | 2112 | +0.2 (1.4) | +0.5 | -0.1 | +0.8 | +0.20 | -0.8 | +0.5 | 87% | 0.14 |
| 54 | r:MENA | 2112 | +0.0 (1.4) | +0.2 | -0.1 | +0.1 | +0.14 | +1.3 | -0.4 | 84% | 0.11 |
| 55 | r:NWE | 2112 | -0.0 (1.4) | +0.9 | -1.0 | -0.2 | +0.25 | -0.2 | +0.0 | 84% | 0.12 |
| 56 | pal:trick5 | 2112 | -0.0 (1.4) | -0.7 | +0.6 | +1.3 | +0.01 | -2.3 | +0.7 | 80% | 0.17 |
| 57 | t:forage | 2112 | -0.2 (1.4) | -0.8 | +0.4 | +0.1 | +0.28 | -2.3 | +0.5 | 93% | 0.19 |
| 58 | c:fruit | 2112 | -0.5 (1.4) | -1.2 | +0.2 | -0.5 | +0.26 | +0.9 | -1.0 | 80% | 0.13 |
| 59 | snack | 2112 | -0.5 (1.4) | +0.1 | -1.1 | +0.9 | +0.36 | +0.8 | -0.9 | 94% | 0.21 |
| 60 | t:basket | 2112 | -0.6 (1.4) | -0.8 | -0.4 | +0.9 | +0.20 | -2.7 | +0.1 | 92% | 0.19 |
| 61 | k:building | 2112 | -0.6 (1.4) | -1.0 | -0.2 | +1.5 | +0.24 | -1.9 | -0.2 | 92% | 0.18 |
| 62 | k:tools | 2112 | -0.6 (1.4) | -1.4 | +0.2 | +0.6 | +0.21 | +0.8 | -1.1 | 89% | 0.16 |
| 63 | lull | 2112 | -0.9 (1.4) | -0.8 | -1.1 | +0.6 | +0.17 | +0.6 | -1.5 | 80% | 0.22 |
| 64 | dodge | 2112 | -1.1 (1.4) | +0.3 | -2.5 | +1.1 | +0.26 | +2.5 | -2.3 | 90% | 0.16 |
| 65 | swing | 2112 | -1.2 (1.4) | -0.5 | -1.9 | +0.5 | -0.23 | +4.0 | -2.9 | 82% | 0.31 |
| 66 | k:potions | 2112 | -1.3 (1.4) | -0.8 | -1.9 | -0.0 | +0.25 | -0.8 | -1.5 | 86% | 0.15 |
| 67 | jab | 2112 | -1.6 (1.4) | +0.6 | -3.7 | +1.3 | -0.08 | -1.9 | -1.5 | 84% | 0.22 |
| 68 | rest | 2112 | -1.6 (1.4) | -0.2 | -3.0 | +0.6 | +0.29 | +1.9 | -2.8 | 80% | 0.08 |
| 69 | c:vegetable | 2112 | -1.7 (1.4) | -1.3 | -2.0 | +0.8 | +0.41 | -3.8 | -0.9 | 88% | 0.13 |
| 70 | t:soiltest | 2112 | -1.9 (1.4) | -0.9 | -2.9 | +1.9 | +0.00 | -4.2 | -1.1 | 89% | 0.19 |
| 71 | c:legume | 2112 | -1.9 (1.4) | -1.9 | -1.9 | +2.0 | +0.07 | -3.2 | -1.5 | 85% | 0.24 |
| 72 | bond | 2112 | -1.9 (1.4) | -1.9 | -1.9 | +2.0 | +0.07 | -3.4 | -1.4 | 85% | 0.24 |
| 73 | pal:Bark Badger | 1920 | -1.9 (1.5) | -2.0 | -1.8 | +1.2 | +0.22 | -1.8 | -2.0 | 85% | 0.13 |
| 74 | offer | 2112 | -1.9 (1.4) | -1.7 | -2.2 | +1.8 | +0.03 | -1.7 | -2.0 | 85% | 0.31 |
| 75 | r:SEA | 2112 | -2.1 (1.4) | -1.0 | -3.1 | +1.9 | +0.00 | -4.2 | -1.4 | 89% | 0.19 |
| 76 | c:herb | 2112 | -2.2 (1.4) | -0.8 | -3.6 | +1.1 | +0.41 | -5.3 | -1.1 | 89% | 0.13 |
| 77 | wayfind | 2112 | -2.2 (1.4) | -1.6 | -2.8 | +1.1 | -0.11 | -1.9 | -2.3 | 93% | 0.23 |
| 78 | t:rod | 2112 | -2.3 (1.4) | -1.4 | -3.1 | +1.6 | -0.06 | -4.0 | -1.7 | 93% | 0.23 |
| 79 | bloom | 2112 | -2.3 (1.4) | -1.9 | -2.7 | +1.9 | +0.01 | -3.0 | -2.0 | 85% | 0.35 |
| 80 | sow | 2112 | -2.4 (1.4) | -2.0 | -2.8 | +2.1 | +0.00 | -3.8 | -2.0 | 89% | 0.19 |
| 81 | pluck | 2112 | -2.4 (1.4) | -1.5 | -3.3 | +1.9 | -0.03 | -3.8 | -2.0 | 93% | 0.22 |
| 82 | taunt | 2112 | -2.6 (1.4) | -1.7 | -3.4 | +1.8 | -0.05 | -4.2 | -2.0 | 93% | 0.23 |
| 83 | r:CA | 2112 | -2.6 (1.4) | -1.7 | -3.4 | +1.8 | -0.05 | -4.2 | -2.0 | 93% | 0.23 |
| 84 | hide | 2112 | -2.6 (1.4) | -1.7 | -3.4 | +1.8 | -0.05 | -4.2 | -2.0 | 93% | 0.23 |
| 85 | soothe | 2112 | -2.6 (1.4) | -1.0 | -4.2 | +2.4 | +0.34 | -3.4 | -2.3 | 86% | 0.12 |
| 86 | pal:charm5 | 2112 | -2.7 (1.4) | -2.5 | -2.9 | +2.4 | -0.06 | -3.0 | -2.6 | 90% | 0.40 |
| 87 | k:decor | 2112 | -3.1 (1.4) | -3.1 | -3.0 | +2.4 | +0.04 | -3.4 | -3.0 | 91% | 0.34 |
| 88 | t:staff | 2112 | -3.2 (1.4) | -4.6 | -1.7 | +1.7 | +0.26 | -1.7 | -3.7 | 88% | 0.17 |
| 89 | hum | 2112 | -4.6 (1.4) | -2.2 | -7.0 | +3.6 | +0.32 | -6.6 | -3.9 | 89% | 0.30 |
| 90 | charm | 2112 | -6.3 (1.4) | -4.3 | -8.4 | +4.2 | +0.10 | -5.1 | -6.8 | 81% | 0.27 |
