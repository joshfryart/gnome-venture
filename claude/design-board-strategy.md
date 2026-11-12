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

## DECIDED by Josh 2026-11-12 (answers to section 6)
1. Difficulty at level: a careless "just chain" player wins ~70% (harder than the 85-90% recommended); careful play should clearly beat it. Retune after the build with the sims.
2. Environment: ground cells AND events in v1 (not events later).
3. Chain cost: a chain of 3 or more USES UP the fired pieces (spent/removed after resolving). Limit 3. (Not the extra creature turn.) Re-run the sims with this rule; perks may raise the limit.
4. Show the creature's aim; remove the reply number from lit cells; keep your own chain numbers.
5. Ground works for the creature too, fully.
6. Source sets (pal + tool + crop Teamwork bonus) are in v1 with the rest.
Note: v1 is now bigger (ground + events + spend-on-chain + aim + Teamwork + deckbuilder). Sim before build; ship in steps behind flags.

## Sim results (v1 bundle, spend-on-chain)

Sim only, on a patched copy of the 2.6.67 board engine. No game code or version changed. Scripts: `tools/pfsim/v1bundle/` (README there). All 88 creatures, blank-centre opening, 207-215 fights per cell. Numbers move about 4 points run to run.

### Rules as simulated
- **Ground:** 5 fixed cells per fight, 2-3 steps from the centre: 2 sunny (a Hurt or Charm piece on it plays x1.5), 2 bramble (pricks the owner of the piece on it for 7% of max health each environment turn; a creature piece costs the creature 7% of its health), 1 mud (no link into or out of it). Same for both sides. The creature's search knows bramble costs it.
- **Environment turn** after the creature: bramble, then the announced event. **Events:** one each round, shown one round ahead on a cell on or next to a piece. Rain: every piece on the cell and its 4 neighbours gives its owner guard (5% of max health per piece) through the next turn. Wind: the piece on the cell moves one cell in the shown direction if that cell is free. Thorn burst: every piece on the cell and its 4 neighbours costs its owner 5% of max health.
- **Use-up:** a chain that fires 3 or more pieces removes every piece that fired (yours and the creature's) to its owner's discard. Also for chains the creature starts.
- **Aim:** the creature shows its next piece and cell and commits. Bots can read it. No reply number: the greedy bot sees only its own chain numbers.
- **Teamwork:** a chain that fires a pal, a tool and a crop piece of yours: +25% on your pieces in that chain. Sim deck: 2 pal, 2 tool, 2 crop pieces, the rest knacks.
- **Bots:** random; chain (always the longest chain, ties by the bigger number); greedy (best own-chain numbers); look (best state after its chain, the shown aim and the announced environment turn); smart (two turns: top 6 by look, then its best chain next turn with the pieces it keeps; uses set-aside; does not peek at the draw pile); never3 and smartn3 (look and smart that avoid a use-up chain when another move exists).

### Tuned numbers (recommended)
| Number | Value | Note |
|---|---|---|
| Use-up limit | 3 | Limit 4 is too soft (below) |
| Sunny | x1.5 | Weak lever: x2 changes nothing |
| Bramble | 7% of max health per environment turn | Weak lever |
| Event strength | 5% of max health per piece in the zone | Weak lever |
| Aim fumble | x0.5, **only when its cell is taken** | If only its link is gone it picks again at full value (see "Rules that look broken") |
| Creature piece values | **x1.35** on top of today | This is the knob that sets the difficulty. `PFB_FOE_MULT` 0.62 would become about 0.84 |
| Teamwork | +25% | Almost never happens with a mixed deck |

### Main table (recommended numbers)
Win % / health lost % / turns. `all` = mean of the four sizes. Small creatures are low level, so the gnome is level 1 at both 4 and 8 under.

| Bot | Level | all | small | medium | large | boss |
|---|---|---|---|---|---|---|
| random | at level | 44 / 80 / 10.9 | 51 / 71 / 9.1 | 47 / 79 / 9.1 | 37 / 86 / 10.2 | 39 / 82 / 15.1 |
| random | 4 under | 26 / 87 / 9.3 | 60 / 68 / 5.8 | 13 / 94 / 7.5 | 16 / 93 / 9.4 | 14 / 93 / 14.4 |
| random | 8 under | 20 / 89 / 7.6 | 63 / 65 / 5.6 | 8 / 97 / 5.1 | 6 / 99 / 7.6 | 3 / 98 / 12.1 |
| **chain** | **at level** | **70 / 64 / 6.8** | 84 / 47 / 4.6 | 66 / 64 / 6.1 | 67 / 70 / 6.7 | 63 / 74 / 9.7 |
| chain | 4 under | 49 / 75 / 6.1 | 87 / 45 / 3.0 | 30 / 85 / 5.0 | 39 / 84 / 6.7 | 39 / 88 / 9.7 |
| chain | 8 under | 33 / 81 / 5.6 | 87 / 45 / 3.0 | 17 / 91 / 4.0 | 16 / 94 / 6.2 | 13 / 96 / 9.2 |
| greedy | at level | 85 / 49 / 6.9 | 93 / 35 / 4.8 | 80 / 53 / 6.5 | 80 / 56 / 6.6 | 88 / 54 / 9.6 |
| greedy | 4 under | 66 / 65 / 6.7 | 94 / 37 / 2.7 | 42 / 77 / 5.9 | 61 / 74 / 7.5 | 68 / 70 / 10.5 |
| greedy | 8 under | 46 / 74 / 6.1 | 94 / 37 / 2.7 | 25 / 87 / 4.4 | 29 / 87 / 6.6 | 36 / 87 / 10.5 |
| never3 | at level | 98 / 24 / 8.6 | 98 / 20 / 5.5 | 95 / 25 / 8.5 | 99 / 29 / 8.8 | 99 / 23 / 11.7 |
| never3 | 4 under | 87 / 38 / 9.9 | 99 / 23 / 3.4 | 67 / 53 / 11.3 | 87 / 46 / 10.8 | 96 / 29 / 14.0 |
| never3 | 8 under | 68 / 53 / 10.8 | 99 / 23 / 3.4 | 48 / 73 / 9.2 | 54 / 70 / 12.5 | 72 / 46 / 18.1 |
| look | at level | 97 / 23 / 8.3 | 98 / 18 / 5.1 | 91 / 26 / 8.4 | 98 / 27 / 8.2 | 99 / 21 / 11.6 |
| look | 4 under | 86 / 37 / 9.3 | 97 / 20 / 3.4 | 66 / 54 / 10.0 | 84 / 42 / 9.9 | 97 / 31 / 13.7 |
| look | 8 under | 69 / 51 / 10.3 | 97 / 20 / 3.4 | 45 / 72 / 8.4 | 51 / 69 / 11.7 | 81 / 42 / 17.5 |
| smartn3 | at level | 99 / 22 / 7.1 | 100 / 19 / 4.6 | 98 / 24 / 7.1 | 100 / 24 / 6.7 | 100 / 20 / 10.1 |
| smartn3 | 4 under | 94 / 32 / 8.4 | 100 / 20 / 3.2 | 80 / 50 / 9.4 | 97 / 33 / 9.1 | 100 / 27 / 11.9 |
| smartn3 | 8 under | 80 / 45 / 9.4 | 100 / 20 / 3.2 | 54 / 66 / 8.8 | 73 / 57 / 11.0 | 95 / 37 / 14.5 |
| **smart** | **at level** | **100 / 16 / 6.2** | 100 / 15 / 3.7 | 100 / 18 / 6.1 | 100 / 17 / 6.2 | 100 / 14 / 8.8 |
| smart | 4 under | 97 / 23 / 7.5 | 100 / 16 / 2.7 | 90 / 37 / 8.7 | 99 / 26 / 7.9 | 100 / 15 / 10.6 |
| smart | 8 under | 88 / 35 / 9.0 | 100 / 16 / 2.7 | 65 / 54 / 9.3 | 86 / 43 / 10.7 | 100 / 27 / 13.3 |

**Target met:** at level "just chain" wins 70% and loses 64% of its health; smart wins 100% and loses 16%. A one-turn reader (look) wins 97% and loses 23%.

Today's rules with the same bots and seeds, at level (`all`): random 79 / 55 / 12.1, chain 100 / 25 / 5.1, greedy 100 / 18 / 4.8, look 100 / 6 / 5.2 (it sees the reply), smart 100 / 7 / 4.5.

### What use-up does to the board and the hand (at level)
| Bot | Pieces fired per placement | Placements that use pieces up | Took a 3+ chain when one was open | My pieces out at turn start | Hand at turn start | Progress from re-fires | My pieces used up per fight: by my chains / by the creature's | Fights at the turn cap |
|---|---|---|---|---|---|---|---|---|
| chain, today | 2.91 | (65% fire 3+) | 94% | 2.0 | 4.8 | 71% | - | 0.0% |
| smart, today | 2.65 | (54% fire 3+) | 77% | 2.0 | 4.7 | 75% | - | 0.0% |
| random | 2.25 | 30% | 62% | 0.9 | 4.9 | 32% | 5.4 / 3.1 | 2.6% |
| chain | 2.45 | 42% | 94% | 0.7 | 4.9 | 49% | 5.0 / 1.1 | 0.0% |
| greedy | 2.28 | 34% | 75% | 0.9 | 4.8 | 55% | 4.6 / 1.1 | 0.0% |
| never3 | 2.07 | 13% | 28% | 1.1 | 4.9 | 42% | 2.1 / 3.7 | 0.2% |
| look | 2.25 | 30% | 71% | 0.8 | 4.9 | 47% | 4.5 / 2.5 | 0.8% |
| smartn3 | 2.09 | 12% | 20% | 1.1 | 4.8 | 56% | 1.5 / 2.0 | 0.1% |
| smart | 2.27 | 31% | 57% | 0.9 | 4.8 | 61% | 3.2 / 1.2 | 0.0% |

- **The hand is fine.** Used-up pieces go to the discard and come back, so the hand stays at 4.8-4.9 and no bot ever had a turn with no legal move.
- **The board is nearly empty.** You start a turn with 0.7-1.1 of your own pieces out (2.0 today). Use-up clears clusters before they grow.
- **Blind chaining now pays for itself badly.** The chain bot uses pieces up in 42% of its placements, re-fires give 49% of its progress (71% today) and its fights take 6.8 turns (5.1 today). The longer fight under a x1.35 creature is what costs it the health.
- **Chaining 3+ is still right about half the time.** Smart takes an open 3+ chain 57% of the time (77% today). It pays to finish the fight, to use up the creature's pieces with yours, and to cash in a cluster the creature is about to hit.

### Degenerate play
- **"Never chain 3+" is safe for a one-turn reader, but not best.** never3 equals look (98 / 24 against 97 / 23 at level), only slower. With planning it loses: smartn3 99 / 22 / 7.1 against smart 100 / 16 / 6.2 at level, and 80% against 88% wins at 8 under. So the rule does not make "never chain" the answer, but a casual careful player can ignore long chains at no cost.
- **Stalling:** rare. Turn-cap fights: 0-0.8% at level for every bot but random; never3 6% and look 5% at 8 under. Fights are longer (smart 6.2 turns against 4.5 today; boss 8.8 against 6.3).
- **Hoarding pieces** (look and smart with a bonus for own pieces on the board): no gain (97 / 21, 100 / 16).
- **Blocking the aim cell** is the main trick of the one-turn reader: look makes the creature fumble 1.9 times a fight, smart 1.0, chain 0.9 (by accident).
- **Random play collapses:** 44% wins at level (79% today). A new or careless-and-unlucky player will lose more than half of level fights.

### Variants (at level, `all`, win / health lost / turns)
| Variant | chain | look | smart |
|---|---|---|---|
| **Recommended** (limit 3, creature x1.35, fumble only when blocked) | 70 / 64 / 6.8 | 97 / 23 / 8.3 | 100 / 16 / 6.2 |
| Creature x1.0, all else default, fumble also when the link is gone | 95 / 40 / 7.5 | 100 / 10 / 7.3 | 100 / 9 / 5.7 |
| Creature x1.2 | 80 / 56 / 7.2 | 98 / 17 / 8.0 | 100 / 12 / 6.1 |
| Creature x1.5 | 65 / 67 / 6.5 | 96 / 26 / 8.4 | 100 / 18 / 6.3 |
| Limit 4, creature x1.35 | 89 / 48 / 5.4 | 100 / 14 / 5.7 | 100 / 14 / 4.7 |
| Limit 4, creature x1.7 | 74 / 60 / 5.1 | 99 / 19 / 6.0 | 100 / 19 / 4.8 |
| No use-up, creature x1.35 | 94 / 41 / 4.8 | 100 / 13 / 5.0 | 100 / 14 / 4.2 |
| Fumble also when the link is gone, creature x1.55 | 75 / 63 / 7.2 | 98 / 22 / 8.6 | 100 / 16 / 6.4 |
| Creature's own chains do not use pieces up | 64 / 67 / 6.2 | 98 / 24 / 7.3 | 100 / 17 / 5.7 |
| No ground | 68 / 65 / 7.1 | 96 / 22 / 8.6 | 100 / 14 / 6.6 |
| No events | 68 / 65 / 6.9 | 96 / 23 / 8.6 | 100 / 16 / 6.6 |
| Strong environment (sunny x2, bramble 12%, events x2) | 70 / 62 / 6.3 | 98 / 23 / 7.3 | 100 / 17 / 5.5 |
| Environment only (creature x1.0, bramble 20%, events x4; 63 fights per cell) | 90 / 49 / 6.3 | 100 / 14 / 5.9 | 100 / 12 / 4.8 |
| No Teamwork | 69 / 64 / 6.8 | 97 / 23 / 8.3 | 100 / 16 / 6.2 |
| Every piece has a source, Teamwork +25% | 71 / 62 / 6.7 | 97 / 22 / 8.1 | 100 / 15 / 6.1 |
| Every piece has a source, Teamwork +50% | 72 / 61 / 6.6 | 97 / 21 / 7.8 | 100 / 15 / 5.7 |

- **Use-up at 3 is the strongest single rule:** at creature x1.35 it takes the chain bot from 94% to 70%. Limit 4 only reaches 89% (16% of its placements fire 4 or more), and to hit 70% it needs creature x1.7, which costs careful players more health (19% against 16%).
- **The 70% cannot be reached with ground, bramble or event numbers.** Even bramble 20% and events x4 leave the chain bot at 90%. The creature factor does it: x1.2 gives 80%, x1.35 gives 70%, x1.5 gives 65%.

### Rules that look broken or weak
1. **Ground and events hardly matter once chains use pieces up.** Removing either changes no result by more than the noise. Per fight at level a side fires on a sunny cell about 0.5 times, loses 1-2% health to bramble and 2-3% to thorn bursts, and wind moves 0.1-0.3 of its pieces. Reason: the board holds under one of your pieces between turns, so there is rarely anything on a marked cell. Use-up and "places that matter" work against each other.
2. **Aim fumble "when its link is gone" breaks under use-up.** Chains remove the pieces the creature aimed to link with, so it fumbled 2.6-2.9 times a fight against bots that were not trying (about 40% of its turns at half value). Recommended: it fumbles only when you take its cell; if only its link is gone it picks again at full value.
3. **Teamwork almost never happens** with a mixed deck: 0.04-0.05 times a fight. With every piece sourced it is 0.2-0.5 times a fight and moves results by 1-2 points even at +50%. It needs 3 pieces in one chain, so it always uses them up. It is harmless, but players will not notice it at +25%.
4. **The creature uses your pieces up too.** Its search already prefers long chains, so it removes 1.1-3.7 of your pieces a fight (most against careful players who keep pieces out). Turning this off makes the chain bot do worse (64%), not better, so it is not a balance problem, but it may feel unfair on screen.
5. **Small creatures stay easy for the chain bot** (84% against 63-67% for the rest): their piece values are 1-3, so x1.35 mostly rounds away. Bosses are the hardest for it (63%, 74% health lost).

### Limits
Bots, not people. Default gnome deck with made-up sources (no real pal, tool or crop pieces, no per-piece life 2-4). Ground mix is fixed (no regions). The look and smart bots simulate the creature's aimed move exactly; when it fumbles they also know its second choice, which a player would not. Swift pieces and belt perks that raise the limit were not modelled.

### Questions for Josh
1. Creature x1.35 is what produces the 70%. OK as the difficulty knob, given random play then wins only 44% at level?
2. Aim fumble only when its cell is taken (not when its link is gone)?
3. Do chains the creature starts use pieces up too (simulated: yes)?
4. Ground and events barely register with use-up at 3. Keep them as flavour in v1, or make them bite (more cells, pieces on ground are not used up, events that hit the hand or the gnome instead of pieces)?
5. Teamwork: raise it (for example +50% and the pieces are not used up) so it is worth building for?

## DECIDED by Josh 2026-11-12 (answers to sim questions Q26-Q30)
- Creature values x1.35 as the difficulty knob (retune after the "bite" change below to keep chain bot ~70%).
- Aim: show only; NO fumble.
- Use-up (chain of 3+ spends the fired pieces, limit 3) applies to BOTH sides.
- Ground + events must BITE (proposed start: sunny x2, bramble 10%, events 10% per piece); re-sim and lower creature mult if needed to keep the 70% / 90% targets.
- Teamwork: keep 3 sources (pal + tool + crop), bonus raised to +60%. (Triggers rarely, 0.05/fight at +25%; re-check play feel.)
Next: re-run sim with these settings, then build in steps behind flags.

## Sim results 2 (bite settings)

Sim only, on a patched copy of the 2.6.67 board engine. No game code or version changed. Scripts: `tools/pfsim/v1bundle/` (README there). All 88 creatures, blank-centre opening, 207-215 fights per cell. Numbers move about 4 points run to run.

### What changed from sim 1
- **Aim:** shown and committed, no fumble. If you take its cell, the creature picks again at full value. The bots read the aim cell. No reply number.
- **Use-up** at 3, both sides (as before).
- **Ground and events:** sunny x2, bramble 10%, events 10% per piece. The creature's search now also knows what the announced thorn burst and rain do to a piece it leaves out.
- **Teamwork:** pal + tool + crop pieces of yours in one chain, +60% on your pieces in it.
- **New bots:** `look-ge` and `smart-ge` are look and smart that ignore ground and events when they choose (`look-g`, `look-e`: only one of the two).
- **New measure, "best move changes":** each turn, take the best move by one-turn reading with everything visible, and the best move with ground / events hidden. Count the turn when the blind pick is worse. Also counted: worse by 3+ and by 8+ points (100 points = the creature's whole bar; 120 = all your health).

### The start settings do not bite enough
Start settings as given (5 cells 2-3 steps out, 1 event a round, creature x1.35): chain 64 / 67 / 6.2, look 95 / 29 / 7.8, smart 100 / 20 / 5.6. The best move changes in only **15-18%** of turns (ground 10-12%, events 7-8%). Bigger numbers alone do not do it: the board holds about one of your pieces between turns, so the marked cells are rarely where you can play. What does it is **putting the ground where the pieces are**: cells 1-2 steps from the centre instead of 2-3.

### Recommended numbers
| Number | Value | Note |
|---|---|---|
| Use-up limit | 3, both sides | Unchanged |
| Ground cells | **3 sunny, 3 bramble, 1 mud, 1-2 steps from the centre** | Was 2 / 2 / 1 at 2-3 steps. 7 of the 12 cells around the centre are marked |
| Sunny | x2 for a Hurt or Charm piece on it | x1.5 drops the best-move change to 30-31% |
| Bramble | 10% of max health per environment turn | Owner of the piece pays; creature pieces cost the creature |
| Events | **2 a round**, 10% of max health per piece in the zone | Was 1 a round. Rain: guard. Thorn burst: health. Wind: moves a piece |
| Aim | shown, committed, no fumble | |
| Creature piece values | **x1.3** (was x1.35) | `PFB_FOE_MULT` 0.62 would become about 0.81. x1.35 gives chain 67%, x1.2 gives 76% |
| Teamwork | +60% | Rare, see below |

### Main table (recommended numbers)
Win % / health lost % / turns. `all` = mean of the four sizes. Small creatures are low level, so the gnome is level 1 at both 4 and 8 under.

| Bot | Level | all | small | medium | large | boss |
|---|---|---|---|---|---|---|
| random | at level | 42 / 82 / 6.3 | 39 / 79 / 4.9 | 40 / 82 / 6.0 | 42 / 84 / 5.7 | 45 / 83 / 8.5 |
| random | 4 under | 27 / 88 / 5.5 | 40 / 78 / 4.1 | 14 / 94 / 4.8 | 24 / 91 / 5.4 | 28 / 91 / 7.8 |
| random | 8 under | 18 / 92 / 4.7 | 36 / 79 / 4.0 | 8 / 97 / 3.2 | 12 / 96 / 4.4 | 15 / 96 / 7.2 |
| **chain** | **at level** | 70 / 62 / 4.4 | 70 / 56 / 3.1 | 62 / 62 / 4.2 | 71 / 65 / 4.2 | 75 / 66 / 6.2 |
| chain | 4 under | 53 / 71 / 4.1 | 81 / 46 / 2.2 | 33 / 83 / 3.6 | 42 / 81 / 4.6 | 57 / 75 / 6.0 |
| chain | 8 under | 42 / 78 / 3.8 | 81 / 46 / 2.2 | 21 / 91 / 2.9 | 30 / 88 / 3.9 | 36 / 87 / 6.2 |
| greedy | at level | 85 / 49 / 4.1 | 87 / 44 / 2.9 | 81 / 46 / 3.6 | 83 / 54 / 3.9 | 89 / 53 / 5.9 |
| greedy | 4 under | 70 / 60 / 4.0 | 93 / 34 / 2.0 | 48 / 76 / 3.8 | 60 / 67 / 4.3 | 77 / 62 / 5.9 |
| greedy | 8 under | 56 / 69 / 3.9 | 93 / 34 / 2.0 | 34 / 84 / 3.1 | 43 / 79 / 4.0 | 52 / 79 / 6.3 |
| never3 | at level | 95 / 34 / 4.9 | 93 / 32 / 3.5 | 94 / 36 / 4.8 | 93 / 36 / 4.6 | 99 / 33 / 6.8 |
| never3 | 4 under | 87 / 46 / 5.4 | 97 / 27 / 2.3 | 66 / 65 / 6.0 | 87 / 48 / 5.8 | 96 / 45 / 7.6 |
| never3 | 8 under | 71 / 58 / 5.5 | 97 / 27 / 2.3 | 44 / 78 / 5.2 | 60 / 70 / 6.1 | 83 / 58 / 8.4 |
| look-ge | at level | 89 / 43 / 5.7 | 87 / 37 / 4.2 | 80 / 49 / 5.6 | 92 / 45 / 5.4 | 98 / 39 / 7.6 |
| look-ge | 4 under | 74 / 55 / 6.0 | 89 / 37 / 2.7 | 47 / 76 / 5.9 | 75 / 59 / 6.8 | 87 / 49 / 8.6 |
| look-ge | 8 under | 58 / 67 / 5.8 | 89 / 37 / 2.7 | 32 / 85 / 4.8 | 45 / 78 / 6.2 | 68 / 70 / 9.7 |
| look | at level | 97 / 29 / 4.9 | 97 / 26 / 3.6 | 93 / 32 / 5.0 | 96 / 30 / 4.4 | 100 / 26 / 6.5 |
| look | 4 under | 90 / 40 / 5.2 | 99 / 24 / 2.3 | 74 / 56 / 5.9 | 91 / 45 / 5.7 | 96 / 34 / 6.9 |
| look | 8 under | 76 / 52 / 5.4 | 99 / 24 / 2.3 | 46 / 74 / 5.2 | 68 / 63 / 6.1 | 91 / 48 / 8.2 |
| smartn3 | at level | 96 / 32 / 4.3 | 93 / 32 / 2.9 | 99 / 29 / 4.2 | 95 / 35 / 4.1 | 98 / 33 / 6.0 |
| smartn3 | 4 under | 90 / 41 / 4.6 | 96 / 25 / 2.3 | 74 / 59 / 5.0 | 94 / 41 / 4.8 | 97 / 36 / 6.4 |
| smartn3 | 8 under | 79 / 50 / 5.0 | 96 / 25 / 2.3 | 54 / 71 / 5.0 | 76 / 57 / 5.3 | 89 / 46 / 7.3 |
| smart-ge | at level | 94 / 37 / 4.9 | 92 / 33 / 3.4 | 91 / 42 / 4.7 | 94 / 39 / 4.9 | 99 / 35 / 6.6 |
| smart-ge | 4 under | 85 / 47 / 5.3 | 92 / 34 / 2.3 | 65 / 64 / 5.7 | 87 / 49 / 6.0 | 97 / 40 / 7.3 |
| smart-ge | 8 under | 70 / 59 / 5.3 | 92 / 34 / 2.3 | 39 / 79 / 4.8 | 61 / 68 / 6.1 | 88 / 53 / 8.1 |
| **smart** | **at level** | 100 / 23 / 3.9 | 100 / 24 / 2.7 | 99 / 23 / 3.7 | 100 / 25 / 3.8 | 100 / 18 / 5.4 |
| smart | 4 under | 97 / 31 / 4.4 | 100 / 22 / 2.1 | 88 / 45 / 4.8 | 99 / 33 / 4.8 | 100 / 22 / 5.8 |
| smart | 8 under | 89 / 40 / 4.7 | 100 / 22 / 2.1 | 73 / 63 / 5.0 | 86 / 47 / 5.2 | 99 / 30 / 6.6 |

**Targets met at level:** "just chain" wins 70% and loses 62% of its health; smart wins 100% and loses 23%; a one-turn reader (look) wins 97% and loses 29%.

Today's rules with the same bots and seeds, at level (`all`): chain 100 / 25 / 5.1, look 100 / 6 / 5.2, smart 100 / 7 / 4.5.

### Does strategy matter now
| Gap (win points / health points) | at level | 4 under | 8 under |
|---|---|---|---|
| smart over chain | +30 / 39 less lost | +44 / 40 | +47 / 38 |
| look over chain | +27 / 33 | +37 / 31 | +34 / 26 |
| smart over smart that ignores ground and events | +6 / 14 | +12 / 16 | +19 / 19 |
| look over look that ignores ground and events | +8 / 14 | +16 / 15 | +18 / 15 |
| look over look that ignores only ground | +6 / 12 | | |
| look over look that ignores only events | +1 / 1 | | |
| smart over smart that never uses pieces up | +4 / 9 | +7 / 10 | +10 / 10 |

Best move changes (share of turns, at level; any / costs 3+ points / costs 8+ points):

| Fights played by | ground ignored | events ignored | both ignored | Mean cost of the blind pick, points a turn |
|---|---|---|---|---|
| look | 28% / 24% / 18% | 10% / 8% / 5% | **33%** / 29% / 22% | 15.5 |
| smart | 30% / 26% / 21% | 11% / 8% / 5% | **36%** / 31% / 24% | 18.3 |
| look, start settings | 10% / 8% / 6% | 7% / 5% / 3% | 15% / 12% / 8% | 6.0 |

- **Yes for ground.** It changes the best cell in 28-30% of turns, and a careful player who ignores it loses 6 win points and 12 health points at level, 18-19 win points at 8 under.
- **Not for events.** They change the best move in 1 turn in 10, and ignoring them costs 1 point. Ground and events together reach the 1-in-3 target (33-36%), ground carries it.
- Careful bots stand on a sunny cell in about half the turns they can (chain 50% by accident, the ground-blind bots 17-24%), and step into an open thorn zone in 25-37% of the turns one is open (chain 45%).

### What the rules do in a fight (at level)
| Bot | Health lost to bramble / thorn | Creature health lost to bramble / thorn | My sunny fires per fight (of which re-fires) | Progress from sunny cells | Creature sunny fires | Placements that use pieces up | Took a 3+ chain when one was open | Creature re-aims per fight | Fights at the turn cap |
|---|---|---|---|---|---|---|---|---|---|
| random | 15% / 17% | 10% / 19% | 1.04 (0.52) | 35% | 1.88 | 27% | 60% | 2.36 | 0.0% |
| chain | 7% / 8% | 8% / 13% | 1.46 (0.77) | 46% | 1.30 | 39% | 93% | 1.32 | 0.0% |
| greedy | 8% / 9% | 8% / 12% | 1.68 (0.99) | 54% | 0.95 | 30% | 70% | 1.07 | 0.0% |
| never3 | 9% / 12% | 9% / 16% | 1.68 (0.72) | 58% | 0.80 | 12% | 25% | 1.64 | 0.0% |
| look-ge | 11% / 11% | 9% / 18% | 1.04 (0.70) | 36% | 1.50 | 28% | 71% | 1.57 | 0.0% |
| look | 5% / 8% | 10% / 16% | 1.71 (0.93) | 58% | 0.72 | 29% | 70% | 1.76 | 0.1% |
| smartn3 | 8% / 11% | 10% / 16% | 1.63 (0.78) | 62% | 0.75 | 10% | 17% | 1.05 | 0.0% |
| smart-ge | 11% / 11% | 9% / 17% | 0.82 (0.66) | 32% | 1.32 | 29% | 58% | 0.89 | 0.0% |
| smart | 5% / 7% | 10% / 15% | 1.61 (0.97) | 61% | 0.60 | 29% | 58% | 0.95 | 0.0% |

"Creature re-aims" = its aimed cell was taken or its aimed piece was gone, so it picked again (no penalty).

### Teamwork
| Deck | Teamwork per fight: chain / look / smart | Fights with at least one: chain / look / smart | Result against no Teamwork (chain, look, smart at level) |
|---|---|---|---|
| Mixed (2 pal, 2 tool, 2 crop of 7-14 pieces), +60% | 0.04 / 0.02 / 0.04 | 4% / 2% / 4% | none (70 / 62, 97 / 29, 100 / 23 both ways) |
| At most 4 of each source, +60% | 0.18 / 0.18 / 0.32 | 18% / 17% / 30% | chain 71 / 61, look 97 / 27, smart 100 / 21 |
| Every piece has a source, +60% | 0.22 / 0.23 / 0.38 | 22% / 22% / 35% | chain 71 / 60, look 97 / 27, smart 100 / 21 |
| Every piece has a source, +100% | 0.24 / 0.24 / 0.44 | 24% / 23% / 42% | chain 73 / 58, look 97 / 26, smart 100 / 20 |

- **With a mixed deck it is still under 0.2 a fight (0.02-0.05).** A deck built for it gets 0.2-0.4 a fight, about one fight in three for a planner. By size (every piece sourced, smart): small 0.26, medium 0.40, large 0.38, boss 0.47.
- Reason: it needs 3 of your own pieces in one chain, and use-up leaves about one of your pieces on the board. Every Teamwork chain also uses its pieces up.
- Even at +100% it moves results by 1-3 points. It is safe, and a deck-building goal, but it will not carry a fight.

### Variants (at level, `all`, win / health lost / turns)
| Variant | chain | look | smart | Best move changes (smart) |
|---|---|---|---|---|
| **Recommended** | 70 / 62 / 4.4 | 97 / 29 / 4.9 | 100 / 23 / 3.9 | 36% |
| Start settings, creature x1.35 | 64 / 67 / 6.2 | 95 / 29 / 7.8 | 100 / 20 / 5.6 | 18% |
| Start settings, creature x1.3 | 69 / 65 / 6.4 | 97 / 27 / 7.7 | 100 / 19 / 5.5 | |
| No ground | 74 / 63 / 6.7 | 97 / 24 / 7.4 | 100 / 17 / 5.8 | 15% |
| No events | 68 / 62 / 4.8 | 96 / 26 / 5.4 | 100 / 19 / 4.3 | 30% |
| No ground, no events | 65 / 66 / 7.2 | 94 / 26 / 9.3 | 100 / 15 / 7.2 | 0% |
| Sunny x1.5 | 70 / 64 / 5.1 | 98 / 29 / 5.7 | 100 / 22 / 4.4 | 31% |
| Soft numbers (sunny x1.5, bramble 7%, events 5%) | 69 / 65 / 5.4 | 96 / 29 / 6.4 | 100 / 20 / 5.0 | |
| 1 event a round | 68 / 62 / 4.5 | 97 / 28 / 5.1 | 99 / 21 / 4.0 | 33% |
| 10 cells (4 / 4 / 2) 1-3 steps out | 71 / 63 / 4.8 | 97 / 29 / 5.1 | 100 / 23 / 4.1 | 34% |
| Creature x1.2 | 76 / 58 / 4.6 | 98 / 25 / 4.9 | 100 / 19 / 3.9 | |
| Creature x1.35 | 67 / 64 / 4.3 | 95 / 31 / 4.9 | 100 / 24 / 3.9 | |
| Limit 4 | 75 / 57 / 3.7 | 99 / 25 / 3.9 | 99 / 23 / 3.4 | |

### Degenerate play
- **Never chaining 3+:** now clearly worse. never3 95 / 34 against look 97 / 29; smartn3 96 / 32 against smart 100 / 23, and 79% against 89% at 8 under. Sim 1 had it equal for a one-turn reader. Smart takes an open 3+ chain 58% of the time.
- **Stalling:** none. 0.0-0.2% of fights reach the turn cap for any bot at any level.
- **Ground camping:** mild. A careful player gets about 60% of its progress from sunny cells with 1.6-1.7 sunny fires a fight, about 1.0 of them a re-fire of a piece that stays there. A piece lives 3 rounds and a 3+ chain uses it up, so it cannot be farmed for long. But sunny is the main thing on the board now: the ground-blind bots get half as much from it.
- **A dominant single piece:** no. Over all fights the top piece is Swing with 19-22% of progress, then Pierce 17-19% and Trip 11-18%, the same as today (Swing 22-24%). Inside one fight the top piece gives 63-77% of the progress (55-64% today): fights are shorter, so fewer pieces get to score.
- **Runaway boss:** no. At level the boss is the easiest size for the chain bot (75%) and costs smart the least health (18%). Under level it is too soft for a planner: smart wins 100% at 4 under and 99% at 8 under. The hard size under level is medium (smart 88% and 73%, chain 33% and 21%).
- **Random play:** 42% at level.

### Rules that look broken or weak
1. **Events do not change decisions.** 2 a round at 10% still change the best move in only 1 turn in 10, and a player who never looks at them loses 1 point. They do change the fight length: thorn bursts and bramble together take about 25% of the creature's health in a careful fight (15% + 10%), for free, because the creature has more pieces standing on the board than you do. With no ground, events alone cut fights by 1.5 turns (smart 5.8 against 7.2); on top of the ground, by about half a turn.
2. **Fights are short.** Smart 3.9 turns at level (small 2.7, boss 5.4); today 4.5, sim 1 6.2. Sunny x2 on both sides and the free environment damage do it. There is little room to plan in a 3-turn fight.
3. **Teamwork stays rare** (above).
4. **Small creatures:** the chain bot wins 70% at level but 81% when under level (the gnome is level 1 there). Their piece values are 1-3, so the factor mostly rounds away.
5. **The chain bot stands on bramble and in thorn zones by accident** and loses 15% of its health to them a fight (smart 12%); random loses 32%. For a careless player the environment is now as big a cost as it is a tool for a careful one.

### Limits
Bots, not people. Default gnome deck with made-up sources (no real pal, tool or crop pieces, no per-piece life 2-4). One ground mix (no regions). Events are one of three kinds at random on a cell on or next to a piece. The "best move" is the best by one-turn reading with the bot's state value, not a solved game. Swift pieces and perks that raise the limit were not modelled.

### Questions for Josh
1. Ground cells 1-2 steps from the centre (7 marked of the 12 cells there) is what makes ground decisive. OK on screen, or too busy?
2. Events still do not change decisions. Keep them as they are (they shorten fights and hurt careless players), or change what they do: aim them at the cells you can play next turn, make them bigger (a whole row), or let them hit your hand?
3. Fights are down to about 4 turns (small creatures under 3). Wanted? If not: sunny x1.5 and 1 event a round give 5 turns and cost a little of the ground effect; more creature health is the other lever.
4. The environment takes about 25% of the creature's health for free. Should events hit creature pieces at half strength, or is that the point?
5. Teamwork needs a deck built for it to show up once in three fights. Enough, or should 2 of the 3 sources give a smaller bonus?
6. Bosses under level are easy for a planner (99% at 8 under). Raise `PFB_BOSS_MULT` in the retune?
