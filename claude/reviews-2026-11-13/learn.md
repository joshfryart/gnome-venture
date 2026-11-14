# Easier to play and learn: puzzle combat v1 (2.6.94 plus 3e76b2f4)

No repo file was changed. Everything here is a proposal.

## Verdict

- **There is no teaching at all today.** A new gnome gets three screens of choices before the first move, then the full rule set, with the rules behind a "?" chip.
- **The cheapest large win is a "learner rules" setting for the first fights.** Environment deck of Sun, Bramble and Rain only, creature tags off, creature pieces x0.8. A careless level 1-2 player goes from 76% to 98% wins, a random one from 60% to 87%, and fights stay the same length (6.2 against 6.6 turns).
- **Taking the environment away makes the game harder, not easier.** With no environment pieces the careless bot falls from 76% to 63% at level 1-2, and the careful bot from 99% to 88%. The environment is the new player's best weapon. Hold back the three pieces that hurt or confuse (Thornburst, Mud, Wind), not the whole system.
- **One habit is worth more than any rule cut:** "do not play a cell that costs you health". It is worth +10 points at level 1-2 and +22 at level 3 and at level 5 for the careless bot. The page shows the cost as a small number in a dark red chip with no cause and no warning.
- **The first creature is a lottery.** A level 1 gnome can meet a level 3 Sand Flea Pack: the careless bot wins 27% of those (n=30), against 97% for Garden Snail and Aphid Swarm.
- **A defeat feeds the next defeat.** Health carries from fight to fight. Starting at half health, the careless bot wins 55% at level 1-2 instead of 76%, and the random bot 37% instead of 60%.

## How I tested

- Real engine, read from the repo: `tests/pfboard_tune_v1.php` plus a scratch driver, `scratchpad/fable/learn/lv2.php` (copies `lv3.php`, `lv4.php` add a kit and a starting-health switch).
- **Pool:** for a gnome of level L, every non-boss creature of level L-6 to L+2. This is the band `pick_creature` uses; I ignored landscape. Level 1 meets 8 small creatures of level 1-3. Level 3 and up also meet Orb Spider (medium, level 5).
- **Fights:** 30 seeds per creature and gnome level for the random and careless bots, 10 for the careful bot. So n = 240 at level 1, 510 at level 1-2, 330 at level 3, 480 at level 5 (careful: 80, 170, 110, 160).
- **Noise:** about 3 points on a win % at n=240, about 2 at n=510, about 4-5 for the careful bot. Per-creature rows (n=30) are plus or minus 8.
- **Bots:**
  - `rand`: a random legal placement, never flips unless nothing else fits. My stand-in for a player who does not understand the board.
  - `chain`: always the longest chain (the tuner's careless player).
  - `randp`, `chainp`: the same two, but they refuse a cell whose own chain costs health when a free cell exists.
  - `look`: the tuner's careful player (best state after the whole round).
- **Decks:**
  - "bare": the 10-piece Steady starter kit only, no tools, no pals, stats 0, health 20 + 3 per level. This is my guess at a brand new gnome.
  - "tuner": the tuner's gnome (starter plus 2 belt tools, a pal from level 3).
- **Variants** use the engine's own overrides (`V1='{"envn":0}'` and so on). The "Sun, Bramble, Rain only" deck is not an override: I ran it on a scratch copy of the engine with Wind, Mud and Thornburst deleted from `data/pf_env.txt` (`scratchpad/fable/learn/eng/`).
- Raw rows: `scratchpad/fable/learn/out_*.jsonl`, `o2_*` to `o6_*`. Tables: `agg.py`, `agg2.py`.
- One bug caught and fixed: my first random bot stopped when only a flipped piece fitted. Those rows are discarded; every `rand` number below is from the fixed driver. A second mistake (the overrides were not applied in the first batch) was also caught and re-run; the discarded rows are in `learn/bad/`.

## What a new gnome meets today

Read from `pfight_game.php`, `pfdeck_view.php` and the built page script. I did not open the page in a browser.

1. A creature appears. The page shows **"Pack your box"**: 4 fixed pieces, 12 more on offer, pick 6 or tap a kit (Bold, Steady, Kind). The note says "A creature is waiting. Pack your first Puzzle box, then you meet it."
2. **The pre-fight screen:** the creature card with its 8 pieces in four layers, chips ("wary", "leans body", "small 4x4"), your deck, a bench, an Auto deck switch, then "Let's fight".
3. **The opening:** "pick a piece, then a side of the blank. Nothing fires; the creature picks its side too, hidden."
4. **Turn 1** with everything on: 2 environment pieces a round from six kinds, flip, set aside, creature tags, combos, piece life, use-up.

What is said about the rules:
- One line on turn 1: "Hurt empties its health, Charm fills the bar."
- A bar hint: "Empty its health or fill the charm bar, tap for more".
- The "?" sheet, "How the board works": the round, the aim, chains, guard, flip, the six environment pieces, animation speed.

What the sheet does not say:
- How to win or lose.
- What the numbers on a lit cell mean.
- That a creature piece in your chain fires for the creature.
- What a combo is (the word "combo" does not occur in the page script; the names only show as a sparkle in the plan lines).
- Anything about set aside.

There is no tutorial, tip or first-fight flag anywhere in `game/` for fights. The Trek comment "the tutorial: the first fight finds you quickly" is only an encounter rate.

Cost of a defeat (`knock_out`): you wake at the start village with 50% health and 2 energy less, and the walk is over.

## Engine results

### Today, by gnome level (bare deck unless said)

| gnome level | random: win / defeat / turn cap, turns | random, avoids cost | careless: win, turns | careless, avoids cost | careful: win, turns | careless, tuner deck |
|---|---|---|---|---|---|---|
| 1 | 77 / 23 / 0, 8.9 | 81 | 81, 4.9 | 87 | 100, 5.2 | 72 |
| 1-2 | 60 / 35 / 5, 11.3 | 70 | 76, 6.2 | 86 | 99, 6.0 | 72 |
| 3 | 37 / 44 / 20, 16.9 | 44 | 52, 10.7 | 74 | 97, 11.3 | 83 |
| 5 | 40 / 31 / 29, 18.9 | 50 | 60, 12.6 | 82 | 97, 13.2 | 68 |

- The careless bot at level 1 loses 47% of its health in an average fight (55% with the tuner deck).
- 15% of its level 1 fights contain one turn that takes 40% or more of its maximum health (21% with the tuner deck).
- 22% of its level 1 fights are over in 1 or 2 turns.
- A random player at level 3-5 mostly does not lose: it runs into the 24-turn cap (20-29% of fights). The fight gives no push toward finishing.
- A gnome that reaches level 3 with only the starter kit is in trouble (52%); the tuner's gnome with two tools and a pal is fine (83%). Whether real gnomes have tools by level 3 I did not check.

### One rule held back at a time (win %, gnome level 1-2)

| variant | careless, bare | careless, tuner | random | careful |
|---|---|---|---|---|
| today | 76 | 72 | 60 | 99 |
| no environment pieces (`envn:0`) | 63 | 57 | 47 | 88 |
| no environment at all (`env:0`) | 65 | 58 | 47 | 86 |
| 1 environment piece a round (`envn:1`) | 68 | 63 | 50 | 99 |
| Thornburst does nothing (`thorn:0`) | 80 | 76 | 64 | 100 |
| **Sun, Bramble, Rain only** (scratch data) | 85 | 87 | 70 | 100 |
| no flip (`flip:0`) | 69 | 73 | 57 | 99 |
| no creature tags (`tags:0`) | 86 | 82 | 75 | 100 |
| creature pieces x0.8 (`foe_x:0.8`) | 82 | 77 | 68 | 98 |
| creature pieces x0.7 | 88 | 87 | 76 | 100 |
| bar x1.3 (longer fight) | 60 | 51 | 46 | 98 |
| no environment, no tags, no flip | 69 | 66 | 54 | 86 |

- **Fewer environment pieces is worse.** Bramble is free damage and every environment piece is something to link to. Without them the careful bot starts to stall (16% turn cap at level 3, 36% at level 5).
- **The three "bad" pieces are the cost.** Dropping Wind, Mud and Thornburst gives +9 to +15 at level 1-2, and at level 3 the careless bot goes 52 to 76.
- **Creature tags are the other cost** (Quick, Poison, Trip, Evade, Bash, Thorns): +10 to +15 without them. Sand Flea Pack's deck has two Quick pieces and a Poison.
- **Flip:** with it off the choices drop from 15.8 to 7.1 legal moves a turn, and the careless bot loses 7 points with the bare deck (no change with the tuner deck). It simplifies the screen but does not make the fight easier.
- **A longer bar is the wrong fix for 1-2 turn fights** at this level: it costs 16-21 points.

### Learner bundles

Win % for careless bare / careless tuner / random / careful.

| bundle | level 1-2 | level 3 | level 5 | turns, careless bare, level 1-2 |
|---|---|---|---|---|
| today | 76 / 72 / 60 / 99 | 52 / 83 / 37 / 97 | 60 / 68 / 40 / 97 | 6.2 |
| Sun, Bramble, Rain only | 85 / 87 / 70 / 100 | 76 / 92 / 50 / 100 | 85 / 92 / 51 / 98 | 6.3 |
| plus no creature tags | 94 / 94 / 84 / 100 | 85 / 95 / 58 / 98 | 96 / 99 / 59 / 99 | 6.5 |
| plus creature x0.8 | 98 / 96 / 87 / 100 | 94 / 99 / 65 / 100 | 99 / 100 / 64 / 99 | 6.6 |
| that, plus no flip (bare deck only) | 94 / - / 84 / 100 | 89 / - / 61 / 99 | not run | 7.0 |
| no tags, creature x0.8 (full environment) | 90 / 88 / 80 / 99 | 81 / 99 / 55 / 98 | 94 / 95 / 52 / 99 | 6.7 |
| no tags, Thornburst off, creature x0.8 | 94 / 91 / 84 / 100 | 89 / 100 / 50 / 99 | 96 / 99 / 45 / 98 | 6.8 |

- With the full bundle, fights with a one-turn hit of 40% or more fall from 15% to 2% (careless, level 1), and health lost from 47% to 27%.
- The share of 1-2 turn fights stays at about 20%. That is fine for a first win; it is the later small fights that need the fix in rules.md item 11.

### Other measurements

- **First creature, level 1 gnome, careless bot, bare deck (n=30 each):** Leopard Slug 100, Dusk Moth 100, Aphid Swarm 97, Garden Snail 97, Dung Beetle 87, Ant Scouts 73, Gnat Cloud 70, Sand Flea Pack 27 (worst one-turn hit 43% of health on average).
- **Starting a fight at half health (level 1-2):** careless 55% (76% at full), random 37% (60%), careful 96%. With the full learner bundle, still at half health: careless 85%, random 74%.
- **Starter kits (level 1-2, careless):** Bold 82, Steady 76, Kind 79; random 71 / 60 / 68. The kit choice moves the result by 6-11 points, about the size of one rule, so it does not need to be the first screen.
- **Opening step:** with the creature simply anchoring the board (`blank` off) the results are within noise (level 1: random 78 against 77, careless 77 against 81, careful 99 against 100). The opening choice can be skipped in the first fights without a retune.
- **"Follow the hint" ceiling:** the careful bot is what a player who took a perfect hint every turn would do: 99-100% at level 1-2 and 8-11% health lost. A hint on every turn would play the game for the player.

## Recommendations by topic

### 1. First-fight onboarding

- **Fight first, box later.** Start fight 1 on the default kit (`PFD_KIT_DEFAULT`, which the code already plays "while no starter is chosen yet") and skip the pre-fight screen. Offer "Pack your box" as the reward after the first win, and show the pre-fight screen from fight 3.
- **Skip the opening step** in fights 1-3 (the `blank` option is already per fight).
- **A 30-second rules card** before fight 1, three lines, in the Old Wizard's voice (PRODUCT.md: he gives hints):
  1. "Put one piece on a lit spot each turn. It fires, and so does every piece linked to it."
  2. "Empty the creature's bar, or fill the charm bar, before your health runs out."
  3. "The red mark shows where the creature plays next. A red number on a spot means that move hurts you."
- **Guided first turns**, one bubble each, no blocking:
  - turn 1: "Tap a piece" then "Tap a lit spot" then "End turn";
  - after the creature's first move: "It played where the red mark was. The mark has moved: that is its next move";
  - first time a cell has a health cost: "This spot would fire its piece too. It costs you N".
  Reuse the tour's bird-box look (`tour.php`). One flag per gnome.
- **A fixed first fight.** The engine takes a seed (`pfb_new(..., $seed)`), so fixed creature (Garden Snail or Aphid Swarm) plus fixed kit plus fixed seed gives the same deal every time, and the bubbles can point at real cells. Choose the seed with the harness: a link on turn 1, a costly cell by turn 3, a careful win in 4-6 turns. I did not search for one.
- **What to show when:**
  - fight 1: board, hand, two bars, the aim;
  - fight 2: the Next strip and the three kind pieces;
  - fight 3: the box, the pre-fight screen, and the "?" sheet pointed out once.

### 2. Progressive disclosure

Hold a rule back by not putting it in the fight, then announce it once with a one-line card at the start of the first fight that has it ("New today: Thornburst. It hurts whoever fires it.").

| Stage | Trigger (proposal) | In the fight | Measured |
|---|---|---|---|
| A | fights 1-3, or gnome level 1-2 | Sun, Bramble, Rain; creature tags off; creature x0.8; no opening; set aside hidden; flip hidden in fight 1 only | careless 98%, random 87%, careful 100% at level 1-2 |
| B | level 3-4 | creature tags on, creature at full value | level 3: careless 76-92%, random 50% (Sun, Bramble, Rain only) |
| C | level 5 | Thornburst and Mud join the deck | today's numbers at level 5: careless 60-68% |
| D | level 8 or first medium creature | Wind; set aside if it is kept at all | not tested |
| any | first pal, tool and crop pieces in one chain | Teamwork chip, already shown only when it applies; add a one-time line | not tested |

- Stage C is where today's difficulty starts, and it is harsh for a bare deck. Pair it with the "costly cell" warning below, which is worth +22 points there.
- Tags are already per piece; the pre-fight card can keep listing them from stage B.
- Engine work: one new filter for the environment kinds (a cfg key, or a per-level column in `pf_env.txt`). `tags`, `foe_x`, `flip` and `blank` exist. The stage must be stored in the fight state like the other `v1` values, so a fight under way keeps its rules.

### 3. In-fight guidance

- **Costly cell, loud and named** (rules.md item 1). Today: a small number in a dark red chip. Proposal: a red edge on the cell and, once the piece is placed, a line above End turn: "This fires its Snap. You lose 4 health." The plan lines already carry the cause ("Your chain fires the Garden Snail's ...").
- **Warning before End turn** when the planned move costs health and a free lit cell exists: "This move costs you 4 health. Play it anyway?" On for the first 5 fights, then a setting. This is the `chainp` and `randp` behaviour: +6 at level 1, +10 at level 1-2, +22 at level 3 and at level 5 (careless); +4 to +10 (random).
- **Warning when the move leaves the aim open and your guard is under the aim's value:** "The Snail still hits for about 4." Not simulated.
- **Hint button, not auto-hint.** "Ask the Old Wizard": lights one cell and says why in one line. Three a fight in fights 1-5, then one a fight or off. It must use public information only (your chain and the shown aim): the tuner's careful bot plays the creature's real reply, which a hint must not see. A hint on every turn is the 99-100% ceiling above, so ration it.
- **Undo:** keep it before End turn and fix the two accidents in turnflow.md (a hand tap drops the placement; Undo keeps the flip). No undo after End turn: it would show the creature's reply and the environment's placement for free.
- **Stall guard for lost players.** A random player hits the turn cap in 20-29% of fights at level 3-5. From turn 8 without progress, show one line: "Stuck? Link to the Bramble, or ask the Wizard."
- **After a defeat, say why:** "You lost 9 health to your own chains and 6 to poison." The events are already in the fight log. Not built, not tested.

### 4. Vocabulary and icons

All from the page script and PHP; I did not see the page.

- **Creature's bar:** "its health" (bar hint, Bramble text), "the bar" (turn 1 hint), "damage" (cell label, plan lines). Pick "its health" for the creature and "your health" for you, and never a bare "health".
- **Piece against tile:** the page says piece; the tag texts in `PF_TAGS` say tile, and three of them describe the old strip game ("Quick: draw a tile when played", "Heavy: has to be the last tile of a chain", "Trip: the creature plays one tile fewer next turn"). The creature's Trip says "you draw 1 fewer". Whether the old texts still match what the v1 engine does for the player's tags I did not check.
- **Fires, plays, scores, counts:** "fires" in the help, "You play" in the plan lines, "each piece is scored in turn" in the replay note, "plays x2" on the creature card. Use "fires".
- **Leaving the board has five wordings:** "uses up", "falls away", "leaves the board", "goes after N rounds", "stays N rounds" (plus "expire" in the old terrain text). Use "used up" for chains and "fades after N rounds" for age.
- **Round against turn:** the chip says R3, the blank is "gone at the end of turn 1", guard "fades when your turn starts", Hold "lasts a turn longer". Use round for the cycle and turn for one side's move.
- **Environment against terrain:** history chips and two labels still say Terrain in the old path. Use "environment piece" only (rules.md).
- **Aim against intent:** the creature's portrait bubble says "Likely next move" and shows only a type; the row chip says "Aims Nip hurt 4". Keep one, the aim.
- **Link, connect, fit, touch:** "No spot links", "Nothing can connect", "No piece fits". Use "fits" for legal and "links" for chain.
- **Box, deck, kit, book, bench, belt:** the draw pile is "Puzzle book", the collection "Puzzle box", the fight set "deck", the starter "kit". Three is enough: box (what you own), deck (what you bring), pile (what is left).
- **Three prickly names:** Bramble (hurts the other side), Thornburst (hurts whoever fires it; its chip label is "Thorn"), Thorns (a creature guard tag). Rename Thornburst (for example "Nettle") or cut it.
- **Icons:**
  - the help sheet uses the same wind glyph for the Chains, Guard and Flip rows (`g: 'gust'` three times);
  - Bash and Guard share the shield;
  - lit-cell marks are sword, flower, heart-minus, and a dash when nothing is counted (a Heal piece shows a dash, turnflow.md). Add guard and heal marks.
- **Stale copy:**
  - "No piece fits. Tap End turn to pass." while the button is "Pass (nothing fits)";
  - the static hint "Up to 4 a turn; the newest plays first." in `pfight_board_html` (the script replaces it with "One piece a turn");
  - the pre-fight chips "leans body", "wary" and "plays x2" are not explained where they appear.

### 5. Difficulty ramp and forgiving options

- **Cap the first creatures.** For the first 3 fights use `pick_creature`'s existing `$cap` at the gnome's level (no creature above it). Sand Flea Pack at level 1 is 27% for the careless bot.
- **No knock-out in the first 3 fights.** On defeat use the existing soft ending ("loses interest and wanders off") in place of `knock_out`. The walk goes on and no energy is lost.
- **Full health at the start of fights 1-3,** or heal to full after each. Half health turns 76% into 55%.
- **A "gentle fights" setting after that** (creature x0.8 for the player who wants it): careless 76 to 82 at level 1-2, 60 to 78 at level 5 (bare deck). It fits the product's "no-pressure" position. Whether it should cut rewards is Joshua's call.
- **Free retry:** after a defeat in fights 1-5 offer "Try again" against the same creature with a new deal. Glue only; not tested.
- **Telegraph more.**
  - Show the aim's total, not the face value (rules.md item 2, turnflow.md item 3).
  - In stage A say it as a sentence: "Next: Nip here, about 4 damage."
  - Mark the aim as blocked as soon as the planned move takes or cuts off its cell (turnflow.md item 4).
  - Name creature combos on the creature's piece card before the fight, not only after they land.

### 6. Rules to simplify or merge

I agree with rules.md items 4-8 and 10-12 and add nothing measured to them. From this review:

- **Thornburst** is the best single cut for learning: it reads like Bramble, it is the main source of self-damage, and without it the careless bot gains 4 points at level 1-2 and 4-13 at level 3-5 (`thorn:0`). If kept, hold it to stage C and rename it.
- **Wind and Mud** add two rules for effects the playtests mostly saw as "nothing moves" and a tag. Hold both to stage C or D. Sun, Bramble and Rain share one sentence: "it works for whoever fires it".
- **Set aside:** hide in stage A to C whatever is decided about cutting it.
- **Opening choice:** merge into "the creature starts" for learners; no measurable effect.
- **Removal rules:** teach only "a chain of 3 or more uses its pieces up" in stage A. The other three (age, the creature's 2 firings, the blank) can stay unexplained until a piece actually fades, then one line.
- **Combos:** teach none in stage A. With creature tags off and Sun present the aim number is still wrong when a combo fires; I did not measure how often at level 1-2.

## Ranked: learning value against cost

Kind: UI = page, copy or PHP glue with no rule change; ENG = engine or data (needs the JS port and parity tests re-run).

| # | Change | Kind | Learning value | Cost | Evidence |
|---|---|---|---|---|---|
| 1 | Costly cell loud and named, with a warning before End turn | UI | very high | low | +10 at level 1-2, +22 at level 3 and 5 (careless); +4 to +10 (random) |
| 2 | Learner rules, stage A (Sun, Bramble, Rain; no creature tags; creature x0.8) | ENG, small | very high | low to medium | 76 to 98 careless, 60 to 87 random, same length |
| 3 | First 3 fights: creature no higher than the gnome, no knock-out, full health | UI (glue) | high | low | Sand Flea 27%; half health 55% against 76% |
| 4 | Rules card (3 lines) and guided first turns | UI | high | low to medium | no teaching exists; 9 confusion themes in 29 playtests |
| 5 | Fight first: default kit, no pre-fight screen, no opening in fight 1 | UI (glue) | high | low | kits differ 6-11 points; opening within noise |
| 6 | Vocabulary and icon pass, stale copy | UI | medium to high | low | section 4; "health" confusion in 8 reports |
| 7 | "?" sheet rewritten: goal first, cell numbers, "its piece in your chain fires for it" | UI | medium | low | sheet has none of the three |
| 8 | Staged unlocks B to D with a one-line card each | ENG, small, plus UI | high | medium | level 3: 52 to 76 with three kinds only |
| 9 | Aim shows the total; blocked aim marked live | UI plus a dry run | high | medium | rules.md: hit at least 2x the shown number on 22% of small Hurt aims |
| 10 | Hint button (rationed, public information only) | UI plus a server call | medium to high | medium | ceiling 99-100% if unrationed |
| 11 | Stall nudge from turn 8; defeat recap | UI | medium | low to medium | random bot: 20-29% turn cap at level 3-5 |
| 12 | Fixed first fight (creature, kit, seed) | UI (glue), plus a seed search | medium | medium | not tested |
| 13 | Gentle fights setting; free retry | UI (glue) | medium | low | creature x0.8: +6 to +18 |
| 14 | Cut or rename Thornburst; one bar; cut set aside (rules.md) | ENG | medium | medium, retune | +4 to +13 without Thornburst |

## Phased plan

**Phase 1 (this week; no rule change, no retune):**
1. Costly cell: red edge, cause line, End turn warning in the first 5 fights (item 1).
2. First 3 fights: creature level cap, soft defeat, full health (item 3).
3. Fight 1 on the default kit, no pre-fight screen, no opening; "Pack your box" after the first win (item 5).
4. Rules card and the "?" sheet rewrite (items 4 and 7, text only).
5. Copy pass: one word list, the three stale lines, help-sheet icons (item 6).
6. From turnflow.md, because a learner sits through every replay: tap the board to skip, shorter banners.

**Phase 2 (next; small engine change behind the `v1` config, then re-run the tuner and the JS parity tests):**
1. An environment-kind filter and the stage A bundle for fights 1-3 or level 1-2 (item 2).
2. Guided first turns with the bird-box bubbles (item 4).
3. Stages B and C with their "New today" cards (item 8).
4. Stall nudge and defeat recap (item 11).

**Phase 3 (larger):**
1. Aim total and live blocked-aim mark (item 9).
2. Hint button (item 10).
3. Fixed first fight (item 12).
4. Gentle setting and retry (item 13).
5. The rule cuts in rules.md (item 14), each with a retune.

## Not verified

- **The live page.** I read the page copy from the code and the built script; no browser run. The first-fight path is from `pfight_html` (starter, then pre-fight, then board), not from playing it.
- **Real new gnomes.** The "bare" deck is my guess (Steady kit, no tools, stats 0). I did not check what tools, calling or stats a real level 1-5 gnome has, how fast they level, or which creatures the first road's landscape allows. The sim gives a level 1 gnome a calling piece (Bloom, charm 10), which is why most level 1 wins are by charm; that share is an artefact of the sim's calling choice.
- **Bots are not people.** `rand` is a floor, not a model of a beginner. The haiku playtests were read for confusions only; none was re-run.
- **Staged rules were tested one stage at a time,** not as a player's path through them with health carried between fights (except the one half-health run).
- **"Sun, Bramble, Rain only"** was run on a scratch copy with three lines removed from the data file. The engine has no such switch yet. Region bonuses for the removed kinds were left in the file.
- **`tags:0`** switches the creature's tags off. I did not check whether it touches the player's own tag pieces.
- **The learner bundle with flip off** was run with the bare deck only, levels 1-3.
- **Not simulated:** the End turn warning as a real interface (only as bot behaviour), any hint that uses public information only, the stall nudge, the defeat recap, retry, the fixed first fight, the "aim still hits you" warning.
- **Replay time for small fights.** turnflow.md measured 14.6 s a turn on one medium fight; I did not measure a level 1 fight.
- **JS port, parity tests, page tests:** not run. No game file was edited.
