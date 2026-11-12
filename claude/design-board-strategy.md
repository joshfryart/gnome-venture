# Board combat: making the board need strategy (2026-11-12)

Design and sim analysis only. No game code or version changed. Builds on `claude/design-deckbuilder-combat.md` (DECIDED list: decks from pals, tools and crops; piece life 2-4 rounds; creature layers base 4 + region + rarity/boss + 3 unique; unlimited swaps before a fight).
Josh's problem: in board mode you can just chain pieces and win most fights.

All numbers below are bot play on the 2.6.67 engine, blank-centre opening (the live default), all 88 creatures. Scratch scripts were session-only (section 7 says how to rebuild them). Numbers move about 4 points run to run.

## 1. Diagnosis

### 1.1 The bots
| Bot | What it does | Stands for |
|---|---|---|
| random | any legal placement | no thought at all |
| chain | always the placement that fires the most pieces; never looks at health or the creature | "just chain" |
| greedy | best own-chain result this turn (`pfb_search`); does not see the creature's answer | a player who reads their own numbers |
| look | best result after the creature's answer (what the numbers on lit cells show since 2.6.66, including the `rp` reply number) | a player who reads every number |
| smart | plans two turns with set-aside groups, top 6 moves. It knows the creature's hand and both draw piles, so it is an upper bound, not a fair player | perfect play |

### 1.2 Baseline (3 seeds per creature, 264 fights per cell)
Win % / health lost %, by gnome level minus creature level:

| Bot | at level | 4 under | 8 under | turns at level |
|---|---|---|---|---|
| random | 80 / 53 | 50 / 74 | 25 / 88 | 11.8 |
| chain | 98 / 23 | 87 / 41 | 65 / 62 | 6.0 |
| greedy | 100 / 17 | 96 / 32 | 77 / 50 | 4.8 |
| look | 100 / 5 | 99 / 10 | 95 / 21 | 5.2 |
| smart | 100 / 2 | 100 / 4 | 100 / 8 | 4.3 |

Chain bot at level by size: small 97%, medium 96%, large 100%, boss 100%.

### 1.3 What the numbers say
1. **At your own level nothing is at stake.** "Always chain longest" wins 98%, and even random play wins 80%. The only thing better play buys is health (23% lost down to 5%).
2. **Chaining is not a choice, it is what every move does.** The connect rule forces a linked joint, so 92% of *random* placements already fire 2 or more pieces (average 2.4; chain bot 3.0). About **70% of your progress comes from pieces that were already on the board firing again** (the piece you place gives 28-31%). Your pieces fire again for free, with no limit, for 3 rounds.
3. **Cells do not differ in kind.** A turn has 9.4 legal placements but only 5.4 different results. The board has no geography: no cell is good or bad except through what it links to.
4. **The skill that pays is one-turn defence, and the page now does it for you.** Greedy to look (seeing the creature's answer) is the big step: 17% to 5% health lost at level, 77% to 95% wins at 8 under. That is "do not link into its Hurt piece, do not set up its reply", and the lit-cell numbers print exactly that. So the best move is "tap the best number".
5. **Planning ahead adds little that a fair player can reach.** Smart beats look by 3 points of health at level and about 1 turn, and it gets there with hidden knowledge and by set-aside (0.9 groups a fight).
6. **Strategy already matters when the fight is hard.** At 8 under, chain wins 65% and look 95%. The loop is not empty; at level it is simply never asked.

So three things are missing: **stakes** at level, **costs** for a long chain, and **places** on the board that matter.

## 2. Candidate mechanics (14)

Engine cost: small = under 30 lines in `pfboard.php` plus the JS port; medium = new state and view fields plus page work; large = new content tables and new screens. Every engine change must be mirrored in `tools/pfengine.js` (`tests/pfengine_js.sh`).

| # | Mechanic | Rule in one line | Decision it creates |
|---|---|---|---|
| 1 | **Overreach** | A chain that fires 4 or more pieces lets the creature place 2 pieces this turn. | Take the big chain now, or stop at 3 and stay safe. Worth it to finish the fight or behind a guard. |
| 2 | **Ground** (environment A) | Each fight seeds about 5 marked cells from the region: Sunny patch (piece on it plays x1.5), Bramble (pricks the owner of the piece on it every environment turn), Mud (a piece on it fires alone; no chain runs through it). The environment acts after the creature. | Race the creature for the sunny patch, use mud as a firebreak against its Hurt piece, pay bramble for a link you need. |
| 3 | **Forecast** (environment B) | The environment shows next round's event one round ahead: a marked cell or row ("Gust: pieces in this row leave", "Sunbeam: the piece here fires twice", "Rockfall: this cell is closed"). | Build toward the beam, keep long-life pieces out of the gust, bait the creature into it. |
| 4 | **Nests** (environment C, closest to Josh's seed) | Some cells hold a sleeping thing (wasp nest, mushroom ring, spring). Placing a piece there wakes it; on each environment turn it acts on the pieces next to it (wasps prick both sides' neighbours, spring heals the owner, ring grows a neutral blocker). | Wake it or not, and which side stands next to it when it acts. |
| 5 | **Aim** (intent with a target) | The creature shows its next piece and the cell it is aiming at. It commits. If the cell is taken or its link is gone, it fumbles: the piece it plays counts half. | Block the cell, or put your Guard or Heal next to it so its own chain fires your pieces for you. |
| 6 | **Tired pieces** | Your piece fires fully when placed and on its first re-fire; later re-fires count half. | When to cash in a cluster; fresh pieces matter more. |
| 7 | **Source sets** | A chain that fires pieces from 3 sources (pal, tool, crop, knack) gets Teamwork: +25% on the last piece. Two pieces of the same pal fire its Boon once. | Deck building and chain order: which sources to bring, which piece ends the chain. |
| 8 | **Neighbours** (adjacency, not links) | Touching without linking still matters: your Guard shields the pieces touching it from being fired by the creature's chain; a pal piece gives +1 to crops touching it. | Shape of your cluster, not only its links. Flat edges become useful. |
| 9 | **Wedge and pin** | A creature piece with your pieces on two opposite sides is pinned: it does not fire. | Spend a turn to shut down its best piece instead of dealing damage. |
| 10 | **Press on** | After your placement you may place a second piece; the creature then also gets a second piece and you draw 1 fewer next round. | Push your luck when ahead or to finish; costly when its hand is strong. |
| 11 | **Brace and pocket** | Draw 2 instead of 3. Instead of placing, discard a piece for guard equal to its value (a real pass). Keep one piece in a pocket across rounds. | Hand management; an answer to "every legal cell hurts me". |
| 12 | **Ripening** | A crop piece gains +1 each round it stays; a piece on its last round fires x1.5. | Place early and protect, or hold. Ties straight into life 2-4. |
| 13 | **Rising temper** | From the pace turn on (small 4, medium 5, large 6, boss 8) the creature's pieces gain +10% a round. | Guard and heal stall less well; speed has a price. |
| 14 | **Heart cell** | When the blank centre leaves, its cell becomes the Heart: the side holding it gets +2 guard at each environment turn. | One contested cell from turn 2 on, which also makes the opening choice matter. |

### Detail per candidate

**1. Overreach.** Deck: the existing Swift upgrade already reads "does not count towards a four-tile chain (no extra foe move)"; strip mode had this rule (`PF_CHAIN_MAX`) and board mode lost it. Tools or pals can raise the limit to 5 (a belt perk). Expiry: long-life pieces build longer chains, so life 4 is no longer a pure bonus. Creature layers: a boss or Beast base piece can lower your limit to 3 while it is out. Engine: small. `pfb_play` counts fired pieces and passes 1 to the unused `$extra` of `pfb_foe_turn`; `pfb_foe_len`; `pfb_cell_preview` adds an "over" flag; page shows a chain meter. Risk: reads as a punishment for the fun part. Counter: show the meter before you place, and let a finishing chain ignore it (it already does, the fight is over).

**2. Ground.** Deck: crops can ignore bramble; a tool piece can clear a mud cell; a pal piece on a sunny patch keeps the bonus one round longer. Expiry: a piece on bramble costs you every round it lives, so a life 2 piece is the right one to put there. Creature layers: the region layer decides the mix (marsh: more mud; steppe: more sun; tangle: more bramble), and a creature's class can be at home on one kind (Water ignores mud, Plant ignores bramble). The creature uses the same cells with its normal search, so it races you with no new AI. Engine: medium. New `pfb_terrain` (seed `$s['ter']` in `pfb_new`), new `pfb_env_turn` called from `pfb_end_round`, three lines in `pfb_place`, `pfb_place_group` and `pfb_links`, `ter` in `pfb_view`, cell art, a replay step for the environment. Risk: clutter on a 390 px board; too much random start. Counter: at most 5 cells, drawn as ground under the pieces, never within 1 cell of the centre.

**3. Forecast.** Deck: quick pieces (life 2) fit a doomed row; a tool can anchor a piece against gusts. Expiry: a gust is an early expiry, so the hourglass badge can show it. Creature layers: region gives the event table; bosses bring their own event (the Old Bramblehorn grows a bramble cell each round). Engine: medium to large. `$s['env']` queue, `pfb_env_turn`, events in the replay, an event table per region. Risk: content cost (events for every region), and a third actor to explain. Build it on top of 2, later.

**4. Nests.** Deck: a crop piece can feed a nest (calms it), a tool can smash it. Expiry: the nest sleeps again when the piece on it expires. Creature layers: nests come from the region layer; a Critter creature starts with its nest awake. Engine: medium. Like 2 plus per-nest effects on neighbours. Risk: the least predictable of the three; a player may never choose to wake a bad nest, so each nest needs a reason (it also hits the creature, or it guards a strong cell).

**5. Aim.** Deck: Trip and Lull already make the creature skip; a pal trick can move the aim marker. Expiry: you can see whether its target link will have expired before it plays. Creature layers: the 3 unique pieces can break the rule in a readable way (a Bird piece has two aim cells; a boss shows two turns ahead). Engine: small to medium. `pfb_intent` already runs the search; store piece and cell in `$s['foe']['plan']`, honour it in `pfb_foe_turn`, show it in `pfb_view`. Risk: a committed creature is weaker (measured, section 4), so its values need a raise of about 10-15%. This also lets the page drop the `rp` reply number: you see the threat and work it out, instead of reading the answer.

**6. Tired pieces.** Engine: small (one line in `pfb_fire`, a badge). Measured: with 3-round life most pieces fire again once or twice anyway, so the re-fire share only moves 31% to 35% and the best move is unchanged. Low value. Not recommended.

**7. Source sets.** Deck: this is the direct reward for a mixed deck, and for deck order. Expiry: a set needs its pieces on the board together, so short-life crops must go last. Creature layers: creature classes get the mirror (two Beast base pieces linked: Pack bonus), which tells creatures apart. Engine: medium. Tiles need a `src` field (comes with the deckbuilder build), a check in `pfb_fire` like the combo check in `pf_value`. Risk: one more bonus on top of 6 combos; keep it to one set bonus and one pal Boon.

**8. Neighbours.** Engine: medium (`pfb_chain` skips shielded pieces; aura values in `pfb_fire`). Risk: hard to see on screen; needs a clear mark on the shared edge. Good second layer for 2.

**9. Wedge and pin.** Engine: small (`pfb_chain` skips pinned pieces). Creature layers: large and boss pieces need 3 sides. Risk: creature pieces already fall away after 2 firings, so a pin often buys little.

**10. Press on.** Engine: small (`PFB_MAX_PLACE` exists; cost through `$extra`). Risk: overlaps with 1; pick one of the two.

**11. Brace and pocket.** Engine: small to medium (`pfb_pass` with a discard; hand rules in `pfb_end_round`). Past data: plain pass measured as a trap; brace was not conclusive. Risk: slower fights. Fixes forced self-hurt more than it adds strategy.

**12. Ripening.** Engine: small (`age` is already tracked; value bonus in `pfb_fire`). Good fit with the DECIDED per-piece life. Risk: makes re-fires even stronger unless paired with 1.

**13. Rising temper.** Engine: small (a factor in `pfb_fire` for creature pieces). Risk: on its own it is only a difficulty knob.

**14. Heart cell.** Engine: small (one cell of 2 with its own effect). Risk: one cell for all fights gets stale; fold it into Ground as a fixed sixth cell.

## 3. Ranking

| Rank | Mechanic | Strategy gained | Cost | Why here |
|---|---|---|---|---|
| 1 | 2 Ground + environment turn | high | medium | Gives the board places. Carries the region layer. Josh's idea in its simplest form. |
| 2 | 1 Overreach | high | small | The only direct cost on chaining. Rule and upgrade text already exist. |
| 3 | 5 Aim | high | small-medium | Turns the creature's turn into something you plan around. Lets the reply number go. |
| 4 | 7 Source sets | medium-high | medium | Makes the deck show on the board. Needs the deckbuilder sources first. |
| 5 | 3 Forecast | medium-high | medium-large | Best version of the environment turn, but only after 2 is proven. |
| 6 | 12 Ripening | medium | small | Cheap, fits life 2-4. |
| 7 | 8 Neighbours | medium | medium | Second layer for cluster shape. |
| 8 | 11 Brace and pocket | medium | small-medium | Fixes forced hurting moves. |
| 9 | 4 Nests | medium | medium | Fun flavour, least predictable. |
| 10 | 14 Heart cell | low-medium | small | Fold into 2. |
| 11 | 13 Rising temper | low | small | Tuning knob only. |
| 12 | 9 Wedge and pin | low | small | Overlaps the fire budget. |
| 13 | 10 Press on | low | small | Overlaps 1. |
| 14 | 6 Tired pieces | low | small | Measured: little effect. |

## 4. Prototype results (scratch copy of the engine, not in the repo)

Built behind switches in a scratch copy of `pfboard.php`: Ground (2 sunny x1.5, 2 bramble at 7% of max health or creature health per environment turn, 1 mud; cells 2-3 steps from the centre; both sides affected), Overreach (4 or more fired pieces: creature places 2), Aim (commit, fumble at half), Tired (x0.5 from the second re-fire, bar x0.85). 2 seeds per creature, 176 fights per cell. Win % / health lost %, at level and 4 under:

| Rules | chain | greedy | look | smart |
|---|---|---|---|---|
| Today | 99 / 25, 86 / 43 | 100 / 18, 97 / 33 | 100 / 5, 99 / 10 | 100 / 2, 100 / 4 |
| Overreach | 95 / 33, 83 / 50 | 99 / 22, 95 / 38 | 100 / 6, 99 / 10 | 100 / 2, 100 / 5 |
| Ground | 94 / 34, 87 / 46 | 99 / 22, 94 / 32 | 100 / 7, 99 / 12 | 100 / 3, 100 / 5 |
| **Ground + Overreach** | **94 / 40, 76 / 56** | 99 / 25, 88 / 39 | 100 / 8, 99 / 13 | 100 / 3, 100 / 6 |
| Aim alone | 99 / 22, 95 / 35 | 100 / 15, 98 / 28 | 100 / 4, 99 / 7 | 100 / 2, 100 / 4 |
| Ground + Overreach + Aim | 97 / 34, 82 / 51 | 99 / 22, 94 / 35 | 100 / 7, 98 / 9 | 100 / 3, 100 / 5 |
| Ground + Overreach + Aim, creature x1.2 | 91 / 43, 69 / 59 | 98 / 28, 85 / 43 | 100 / 10, 98 / 13 | 100 / 4, 100 / 7 |
| Control: today, creature x1.25 | 90 / 36, 74 / 54 | 99 / 25, 88 / 46 | 100 / 6, 97 / 17 | 100 / 3, 100 / 7 |
| Tired + Overreach + Ground (no smart run) | 92 / 42, 73 / 59 | 100 / 27, 89 / 38 | 100 / 8, 98 / 16 | – |

What this shows, and what it does not:
- **Blind chaining now costs.** With Ground + Overreach the chain bot loses 40% of its health at level (was 25%) and wins 76% at 4 under (was 86%). A player who reads the board pays 3 points. The gap between "just chain" and "read the board" grows from 20 to 32 points of health at level and from 13 to 23 points of wins at 4 under.
- **It is about as strong as making creatures 25% tougher** (control row), but kinder to careful play (look at 4 under: 99% / 13% against 97% / 17%), and the cost comes from rules you can see and avoid, not from bigger numbers.
- **Aim alone makes fights easier** (the creature no longer reacts to your move), so it needs the x1.2. With it, the full bundle is the widest spread: chain 91% / 43% against look 100% / 10% at level.
- **Not shown:** that planning two turns ahead beats reading one turn. Look stays within 4-6 points of smart in every row. As long as the page prints the creature's reply on every cell, one-turn reading is close to perfect play. That is a display decision as much as a rules one (question 4).
- **Not shown:** that the best move stops being a chain. The longest chain is still the best move in 62-65% of turns in every variant (random picks it 52% of the time). These rules add a price and places; they do not remove chaining, which is what the board is.
- Limits: bots, default gnome build without pals, tools or crops, 2 seeds, static terrain only. Forecast, Nests and Source sets were not prototyped.

## 5. Recommended v1 bundle

1. **Ground with an environment turn** (candidate 2, with the Heart cell folded in later). Three cell kinds only: Sunny patch, Bramble, Mud. Mix from the region. The creature uses them too.
2. **Overreach** at 4 fired pieces. A chain meter on screen. Swift pieces do not count.
3. **Aim**: the creature shows its next piece and target cell, commits, fumbles at half if blocked. Creature values up about x1.2 to pay for it. The `rp` reply number leaves the lit cells.

Then retune so a careless player feels it at level (question 1). Next step after v1: Source sets (4) once pal, tool and crop pieces exist, then Forecast (5).

Build order, each step behind `pfight_open`: Overreach (small, one day of engine and page), Ground, Aim, retune with `tests/pfboard_tune.php` plus a chain-bot row.

### On screen (390 px, sketch)

```
+--------------------------------------------------+
| Tawny Owl  L6   health [#######---]  charm [##---]|
| Aims: Snap (Hurt 5) at the paw mark               |
+--------------------------------------------------+
|  .    .    .   [m]   .    .    .                  |
|                                                   |
|  .   {S}  [o1]-[o2]  ^^   .    .       {S} sunny  |
|            |                           ^^  bramble|
|  .   [m] -[M1]-[M2]  @    .    .       ~~  mud    |
|            |                           @   owl aim|
|  .    .   [M3]  ~~   .   {S}   .       [m] lit    |
|                                            spot   |
|  .    .    .    .    .    .    .                  |
+--------------------------------------------------+
| Chain  (o)(o)(o)( )   4 = the owl plays twice     |
| Ground: bramble pricks M? no piece on it  -0      |
+--------------------------------------------------+
| Hand:  [Swing 4] [Dodge 3] [Carrot 2] [Mole 5]    |
+--------------------------------------------------+
```
M = your pieces, o = the owl's, `-` and `|` = linked joints. The owl aims at `@`, next to M2: put Dodge there to block it (it fumbles), or put Dodge under `@` so its chain fires your guard. The left `[m]` links M1 and reaches toward `{S}` for next turn. The chain meter fills as you hover a spot; the fourth dot is red.

Turn order shown in the status line: You, Creature, Ground.

## 6. Open questions for Josh (recommendation first)

1. **How hard should a fight at your own level be for a careless player?** Recommend: "just chain" wins about 85-90% and loses about 40% health; a careful player wins 98% or more and loses 10-15%. Today both win 98-100%.
2. **Environment: fixed ground cells first, events later?** Recommend yes. v1 = 5 fixed cells of 3 kinds from the region, acting after the creature. Forecast events and Nests come in v2 on the same environment turn.
3. **Overreach: limit 4, penalty "the creature places 2 pieces"?** Recommend yes, with a meter, and deck perks that raise the limit to 5. The alternative (a hard cap on chain length) is simpler but removes the push-your-luck.
4. **Show the creature's aim and remove the reply number from lit cells?** Recommend yes. Keep your own chain numbers (damage, charm, health cost). The reply number is what makes one-turn reading near perfect.
5. **Does the ground work for the creature too?** Recommend yes, fully. It makes sunny patches contested with no new creature AI, and bramble can be used against it.
6. **Source sets (pal + tool + crop bonus) in v1 or v2?** Recommend v2, right after the deck sources ship, as one bonus (Teamwork) plus the pal Boon. It is the mechanic that ties this to the deckbuilder most directly.

## 7. Rebuild the sims

Scratch only, nothing in the repo. A runner like `tools/pfsim/run.php` with: blank opening, bots as in 1.1 (chain = most pieces fired via `pfb_play(..., dry)`; look = best state after a full `pfb_play`; smart = top 6 by look, then the best look value one turn later, with `j`, `h`, `c` actions), state value = progress share + 1.2 x health share. Prototype switches in a copy of `pfboard.php`: terrain map `$s['ter']` seeded in `pfb_new` (`cm` 1.5 on a sunny cell in `pfb_place` and `pfb_place_group`, `pfb_links` returns nothing on or into mud, bramble tick at the top of `pfb_end_round`); Overreach in `pfb_play` and `pfb_foe_len`; Aim in `pfb_intent` and `pfb_foe_turn`; creature factor in `pfb_new`.
