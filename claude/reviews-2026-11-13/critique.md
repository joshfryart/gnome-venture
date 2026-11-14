# Puzzle combat v1 as a game: critique (2.6.94 plus 3e76b2f4)

Read-only review. No repo file was changed. Lines marked **(opinion)** are judgement; everything else is quoted from a sim, a playtest report, the code, or my own four fights.

## Verdict

- **It is not fun yet.** It is a well-instrumented prototype of a good idea, buried under about 20 rules, most of which measure as doing nothing.
- **The player does not solve a puzzle. The page solves it and the player taps the biggest number.** In my 31 turns, about 5 held a real decision.
- **Anyone who reads the numbers cannot lose.** The look bot wins 99-100% at level, 93-100% at 4 under, and 100% against a boss at 8 under. I won 4 of 4 and never dropped below 52% health.
- **Anyone who does not read them wins anyway** (76-90%), loses half their health, and cannot tell why.
- **The best play in the game is one the game never shows or teaches**: put a Hurt piece next to the creature's aim and its own move fires your piece for you. I found it by accident in fight 3.
- **Do not kill the board. Kill half the rules and the whole collection layer on top of it**, then spend the saved effort on the two things that are missing: a board that lasts, and creatures that differ.

## What I played

CLI harness (`tests/pf_play.php`, v1 rules), four fights, state files in `scratchpad/fable/crit/`. I played to win, reading every cell number.

| Fight | Creature (gnome level) | Result | Turns | Health at end | Lowest health |
|---|---|---|---|---|---|
| A | Bullfrog, medium (7) | charmed | 6 | 29 / 41 | 29 |
| B | Sun Lizard, medium (8); the sims' hardest medium | seen off | 6 | 38 / 44 | 38 |
| C | Old Bramblehorn, boss level 30 (gnome 26, 4 under) | seen off | 7 | 108 / 108 | 91 |
| D | Grass Snake, large level 14 (gnome 10, 4 under); the sims' hardest large | seen off | 12 | 26 / 50 | 26 |

How my 31 turns divide (my own judgement of each turn, as I played it):

| Kind of turn | Turns | Share |
|---|---|---|
| A real decision (two lines with different futures, and I had to think) | 5 | 16% |
| A search, not a decision (one best number, sometimes hidden behind a flip) | 6 | 19% |
| Obvious, or only one productive move | 18 | 58% |
| Dead (no move made progress on either bar) | 2 | 6% |

The five real ones:
- A turn 2: Charm for 18 of 39 on the charm bar, or Hide for 9 damage and a blocked aim. This committed the fight to charm.
- B turn 2: Thorn Cut for 12 and lose my two pieces, or Brace and hold.
- C turn 1: three cells all showing d21. I picked the one under the aim cell. The boss's Lunge linked into my Thorn Cut and fired it again: 42 damage of 145 in round one.
- C turn 2: Trip (12, and the boss loses its turn) or Jab next to the aim (12 now, 12 more when the boss fires it). I took the bait line; it worked again.
- C turn 4: Trip for 12 with no reply, or Swing for 14 and take a Crush plus Slam chain.

What I remember a day later **(opinion)**: the bait on the boss, and one Sun-doubled finisher. I do not remember any creature. I could not tell you one thing the Grass Snake did that the Bullfrog did not.

## 1. The core idea and the fantasy

**The idea is good.** A shared jigsaw board where both sides' pieces link into one chain, a creature that shows where it will play, and a neutral environment whose pieces work for whoever fires them. That is three strong ideas, and the third is one clean sentence.

**The fantasy is not delivered (opinion).** A jigsaw is about building something that stays. Here nothing stays:
- At the start of my turn I have no piece of my own on the board in 40-46% of turns as a careful player and 60-68% as a careless one (`rules.md`).
- Four separate rules remove pieces: use-up at 3 or more, life in rounds, the creature's two-firing limit, the blank after round 1.
- In fight D the board was wiped by a chain of 3 or more on 9 of 12 turns.

So the picture never forms. Each turn is a new, small question: which hand piece touches what the creature and the environment left behind. The game is closer to a slot machine with a legal-move filter than to a jigsaw.

**The cosy fantasy is actively punished.** PRODUCT.md says "cosy, gentle, no-pressure". The on-brand way to win is Charm. It is the worst strategy in the game:
- The core Charm piece is the worst piece in the catalogue: -6.3 win points (`deck.md`).
- Charm wins 0% of fights against large creatures and bosses have no charm bar (`rules.md`).
- 1 Hurt plus 7 Charm wins 56%; 8 Hurt wins 94%.
- Progress on the bar you do not finish is thrown away. In fight D, 14 charm sat on the bar for 8 turns and did nothing.

The kind gnome loses. The gnome who hits things wins. That is the opposite of the game's tone.

## 2. Moment-to-moment decisions

- **The cell numbers are the game.** Every lit cell shows damage, charm, health cost and END. The right move is the largest `d` with `h-0`. One rule, "never play a cell that costs health", moves the careless bot from 76-90% to 90-99% wins (`rules.md`).
- **Without the numbers the board cannot be read (opinion).** To predict a chain by eye you need: three knob families, four edges per piece, flip, who owns each piece, six environment effects, Mud's -25%, five unnamed combos, creature guard, and the x0.8 or x0.6 bar factor. Nobody will do that on a phone. So the page computes it, and the player complies.
- **That is the central design failure**: the rules are too complicated to reason about and the interface too helpful to leave anything to reason about. The player is squeezed out from both sides.
- **Clever moments exist, and they are accidents.** My fight A ended on a chain of 7 that I did not build; I tapped the cell marked END. Fight D ended on a Guard piece whose only job was to touch a Bramble.
- **Dead and forced turns are common.** Sims: 6-14% of turns have no move that makes progress; 14-17% of hand pieces have no legal cell (`rules.md`). Playtests name it again and again (r5, r7, r9, r16, r19, r22, r24, r29).
- **The hand clogs.** Pieces you do not play stay; you draw only what you spent. In fight D, Hum, Rest and Charm sat in my hand from turn 2 or 3 to turn 12. My real hand was two pieces. r19 saw the same: "T5 hand: Lull, Hide, Snack, Rest, Hum".
- **Blocking the aim is weak counterplay.** "Take the cell and it has to pick again (no penalty for it)". In fight D turn 7 I took the aim cell (shown: hurt 5). It picked again and hit for 10 through a Sun, and healed 4. Blocking swaps a known threat for an unknown one.
- **Tension: none for a reader.** The look bot loses 12-15% health at level (changelog). Over my four fights I lost 29%, 14%, 0% and 48%, the last at 4 levels under the hardest large creature.
- **Comebacks: none.** No rule lets a losing side recover. The fights that were close in the playtests were close because of a Sun the environment dropped, not a play.

## 3. Depth against complexity

A new player must hold about 20 rules (`rules.md`). What each one buys, measured:

| System | Measured effect | Verdict |
|---|---|---|
| Set aside, join, add, group | Smart bot with it removed: 100% wins both ways, health lost within 3 points. Used in 2 of 29 playtests. | Dead. Costs the most interface of any rule. |
| Teamwork | 0.34 chains a fight. Off: -0.2 / -1.1 points. Doubled: under +1.5. | Dead. |
| Must-link rule | Dropped for the player: careless bot identical to the decimal. | Dead. |
| Refused pass | Free pass for the careful bot: no change. Five playtests complain. | Dead, and annoying. |
| Flip "once a turn" | You place one piece a turn, so the limit limits nothing. | Dead as a limit. Flip itself is fine. |
| Per-piece life (2, 3, 4 rounds) | Whole deck at 2 against 4: 77.5% against 79.6%, se 1.8. | Dead. |
| Knob families (body, mind, craft) | Right knob family: +0.1 / +0.9 / -0.2. Every pattern links 79-94% of hand-turns. | Texture only. Three families could be one. |
| Harmony meter | "Hand links" 99.9-100% and "link rate" 33-36% for every deck built. | Cannot tell decks apart. |
| Heavy tag | No rule on the board; the card still shows it. | Bug-level dead. |
| Wind | 0.1-0.55 pushes a fight; "nothing moves" in 8 playtests and once in mine. | Dead. |
| Mud | Never fires. | Near dead. |
| Creature AI | Random moves instead of greedy: +3 to +8 points for the careless bot. Two-ply: nothing. | The opponent's choices do not matter. |
| Two bars | Charm bar 8-25% full and thrown away in fights won by damage. | Wasteful. |
| Thornburst | 7-15% of the careless bot's health loss; careful bot unchanged without it. | A tax on people who do not read. |
| Crop, craft and region pieces (30) | Average +0.3 / -0.1 / +0.7 points. | Names only. |
| Use-up at 3 or more | Off: fights last 3.4-5.2 turns, careless bot 98-100%. | Load-bearing, and the reason nothing persists. |
| Hurt share of the deck | 8 Hurt 94%, typical deck 73-79%, 1 Hurt 56%. | The only deck variable. |
| Environment (Sun, Bramble, Rain) | Bramble gives 9-26% of the bar; half of the bar in my fight D. | The real weapon and the real threat. |
| The aim | Taking or baiting it is the play testers liked most. | The real game. |

**Count:** of roughly 20 rules, four carry the game (the aim, linking, use-up, the three working environment pieces). Ten measure as inert. That ratio is the problem **(opinion)**: it is high complexity bought for low depth.

## 4. Difficulty and fairness: who is this for?

- **A new player:** not this. About 20 rules; the two that decide fights (a creature piece in your chain fires for the creature; Thornburst hurts whoever fires it) are the ones nobody guesses. The default kit is the worst one: Steady wins 63% at creature levels 1-4 and 39% at 5-10, against 79% and 56% for Bold, and its fights last 10 turns (`deck.md`). A quarter of small fights end in 1-2 turns (r1, r21: "nothing in the fight made the player think").
- **A casual player:** wins most fights by tapping large numbers, loses 49-62% of health doing it, and gets hit for double the shown aim on 22-37% of Hurt aims. Playtest fairness averages 3.2 of 5; ten reports call the aim number unfair. This player feels cheated, not challenged.
- **A puzzle fan:** solves it in two fights ("largest d, h-0, take END"), then wins 100% forever. No mastery curve after that. The deck cannot make it harder or more interesting: the look bot wins 95-100% with every deck tested.
- **So it sits in a gap (opinion):** too opaque for the cosy audience, too shallow for the puzzle audience. The skill gap that exists (careless 76-90%, careful 100%) is not skill at chains. It is the habit of reading one number.
- **Fairness defects that are simply wrong, not hard:**
  - The aim shows one piece's face value. Mean shown against actual: 5.7 / 8.8 medium, 7.3 / 11.8 large, 8.9 / 14.3 boss. I saw 5 shown, 10 dealt, twice running.
  - The creature's guard is not on the status line. In fights C and D every cell read d0 for a turn and nothing said why.
  - The preview rounds: a cell said d29 and left the boss at 145.1 of 145.4.
  - Bosses are easier than mediums for a reader (100% wins, 15% health lost). My boss fight at 4 under ended at full health.

## 5. The creature as an opponent

- **There is one creature, in 88 skins.** Every size and class runs the same one-ply greedy search; temperament only sets a bar multiplier; no creature ever flips, blocks, or values the board (`strategy.md`).
- **Its decisions do not matter.** Swap in random moves and the careless player gains 3-8 points. Swap in two-ply search and nothing changes. An opponent whose choices are worth nothing is a damage clock.
- **Difference today is stats and names.** By class, win at level runs from Bird 72% to Plant/Fungus 92%, because Bird decks carry more Hurt. That is a number, not a personality.
- **The data exists and is wasted.** There are 265 unique creature pieces and six class base sets with tags (poison, trip, evade, thorns, quick, bash). All of it feeds the same greedy search.
- **The real opponent is the environment (opinion).** What hurt me was a Sun landing beside the aim, twice. What hurt the playtesters was the same (r11, r14, r20, r23, r24, r28). A random third party that decides fights, in a game about reading an opponent, is the wrong way round.
- **The creature is exploitable, and that is its best feature.** Its aim is committed, so it will play into your Hurt piece and fire it for you. That is the one moment where it feels like I outwitted something. The game should be built on it and is not: no cell number counts it, no text mentions it.

## 6. Progression and reward

- **The deck has one dial: how many Hurt pieces.** 74 of 90 pieces are inside the noise. Hurt base 2, 3 and 4 are the same piece. Every piece gets a flat `level / 3`, so a level 12 starter screen shows twelve pieces valued 6 to 9.
- **Collecting is invisible and worthless.** No page says a crop, craft or guide earned a piece. The average earned piece is worth zero.
- **"No maximum" is a trap.** New pieces arrive switched on. All knacks on costs 8.5 points. The reward for playing more of the game is a worse deck.
- **Three of six callings get a calling piece that lowers their win rate** (Bloom -2.3, Sow Doubt -2.4, Slip Past).
- **What does the player want next? Nothing (opinion).** There is no piece I saw and wanted. Nothing I could add would change how a fight plays, only how long it takes. A deckbuilder lives on "I can't wait to draw that". This one has no such piece, except possibly a rare Hurt pal (+8.9), which is just a bigger number.
- **One thing does give fights a stake:** health carries through the expedition (`pfight_game.php` line 56-59). Attrition across fights is the real cost of sloppy play. The fight screen never says so.

## 7. Pacing, waiting and the phone

- **Forced wait: median 14.6 s a turn at 1x**, with input dead; 6.4 s of each wait is banners and environment placement that carry no decision (`turnflow.md`).
- **A 13-turn fight had 184 s of pure waiting.** My fight D would be about 3 minutes of watching, for a result that was never in doubt, to deliver 8 damage a turn from Brambles.
- **Ratio (opinion):** about 2 seconds of deciding to 15 of watching. Good phone games run the other way.
- **Skip is 48 x 34 px at the top of the screen**; End turn is at the bottom. A tap on the board does not skip. `prefers-reduced-motion` changes nothing, though PRODUCT.md promises it is honoured.
- **Every pick, placement and flip is a POST.** Measured on localhost only. On shared hosting over a phone network this will be felt on every tap. Not measured.
- **Fight length is wrong at both ends:** 24-25% of small fights last 1-2 turns; under-level or Steady-kit fights last 10-12.
- **Session fit:** a cosy daily game wants a fight to be a 60-90 second treat between garden chores. This is a 2-5 minute sit-down with one finger idle.

## 8. Presentation and clarity

- **The look is good (opinion).** The stitched jigsaw pieces, the aim marker and the dark board (`s4_lit.png`) are charming and on brand. Three taps a turn is right.
- **The screen is crowded:** I count nine bands at 390 px: header, fighters, log line, chips, board, environment strip, choice panel, hint, buttons, hand. PRODUCT.md principle 3 is "calm over busy".
- **Words fight each other.** "health" means the creature's damage bar and "hp" means yours (8 reports). Ground, terrain and environment are three words for one thing. Bramble hurts them, Thornburst hurts you.
- **The piece lies about its value.** "hurt 6 is printed, the bar moved 1.0" (5 reports).
- **Combos are invisible.** Ambush, Riposte, Double Swing, Bait: I benefited from three of them and still cannot state their rules. They are behind 46-74% of the creature's larger-than-shown hits.
- **Spoilers and stale state:** round chip one ahead during the replay, "over" shown 8 s before the result card.
- **A tap on a hand piece after placing silently drops the placement.** On a phone that is the most likely slip.

## 9. Genre peers, and what to steal

| Game | What it does better | Steal |
|---|---|---|
| **Slay the Spire** | Intent shows the true number, with every modifier. You discard and redraw the whole hand each turn, so no clog. Three energy means several plays a turn and real sequencing. Every enemy has one readable gimmick (Gremlin Nob punishes Skills, the Cultist ramps). Relics change how you play, not how big the number is. | The honest intent. A full redraw, or one free discard a turn. One gimmick per creature class. |
| **Into the Breach** | Perfect information. The whole game is making enemy attacks land on the wrong thing. Five turns, no dead ones. | This is the bait play. Make "its piece fires what it touches" the headline rule, show it on the board before End turn, and count it in the cell number. |
| **Dominion** | The deck is the game: thinning, engines, a card you gain is a card you will feel. | A deck cap, and a way to remove pieces. "No maximum" has to go. |
| **Puzzle Quest** | A shared board where every move also sets up or denies the opponent. Opponents differ by their spells. Match-3 is readable in half a second. | Readable at a glance without computed numbers. One signature move per creature. |
| **Dicey Dungeons** | Each enemy has its own equipment with one distinct rule. Fights are 60-90 seconds. Six classes play differently. | Fight length. One rule per creature class. Callings that change the rules, not the values. |
| **Triple Town** | Every placement lasts and narrows the future. The bears are obstacles with behaviour. | Persistence. The board is the save state of your plan. |
| **Tetris, Puyo Puyo** | Build, then release. The long chain is set up over many moves and fired on purpose. | Here use-up fires and wipes the setup the moment three pieces touch. Let the player choose when to fire. |
| **Carcassonne, Dorfromantik** | Edge matching where the built thing stays and scores at completion. The nearest relative to a jigsaw. | Reward completing a shape (a row, a 2x2), not only touching a neighbour. |
| **Marvel Snap** | Six turns, three minutes, no waiting, one sharp decision a turn. | The session budget. |

**The pattern (opinion):** every peer picks one of two things, a lasting board or a lasting deck engine, and makes the opponent legible. This game has neither a lasting board nor a deck that matters, and its opponent is an understated number.

## 10. Ranking

### The five biggest problems

1. **There is nothing to decide and nothing at stake.** The cell numbers pick the move; a reader wins 100% with every deck, at 4 and 8 levels under. 58% of my turns were obvious. Everything else on this list feeds this one.
2. **The board does not last.** Use-up, life, the firing limit and the blank clear it faster than anyone can build. No plan survives two turns, so there is no setup, no payoff, and no jigsaw.
3. **The creature is not an opponent, and the environment is.** Eighty-eight identical one-ply bots whose choices are worth 3-8 points; an aim that understates by half; fights decided by where a random Sun or Bramble lands.
4. **The deck and the collection are decoration.** One dial (Hurt share), 74 of 90 pieces in the noise, Charm and Trick as traps, earned pieces worth zero, a hand that clogs. Progression has nothing to offer.
5. **Complexity and waiting far above what the depth earns.** About 20 rules, ten of them inert; 15 s of forced watching for 2 s of choosing; a default kit that produces 10-turn fights.

### Three things that are good and must be protected

1. **The committed aim on a shared board where chains cross sides.** Deny it, guard against it, or bait it into firing your own piece. This is the one place the player can be clever. AIMSTICK made it reliable; keep it.
2. **"An environment piece works for whoever fires it."** One sentence, and it produced the moments testers enjoyed: the Sun-doubled finisher, running a chain into Bramble. Keep the rule; cut the pieces that do not work (Wind, Mud).
3. **The look, the three-tap turn, and the test bench.** The art is the best argument for the feature. The sim harness, the bots and the parity tests mean any rule change can be measured in an hour. Most hobby games never have this. The honest per-cell preview belongs here too, once there is something left to think about after reading it.

### The next two weeks, if it were mine

**Week 1: cut, and tell the truth.** Nothing here needs new design.
- Kill outright: set aside / join / add / group, Teamwork, the must-link rule, the refused pass, the flip limit, per-piece life (3 for all), the harmony meter, the Heavy tag, Wind and Mud.
- Kill for now: the crop, craft and region pieces and rank as fight content. Thirty pieces with an average value of zero are thirty things to explain. Bring them back one at a time, each with a rule.
- One bar. Damage and charm fill the same bar; the larger share names the ending. The prototype held win rates (`rules.md`). The kind gnome stops losing.
- The aim shows the real total on the board as it stands, with the reason. Show the creature's guard.
- The cell number counts what the creature's aim will fire. That turns the bait from a secret into the game.
- Hand: redraw the whole hand every turn, or one free discard a turn. Test both.
- Kits: Bold is the default; every kit has 4 Hurt.
- Replay: 5 s at most, tap anywhere to skip, honour reduced motion.

**Week 2: two bets, both through the existing bench.**
- **A board that lasts.** Sim three variants and pick one: (a) a chain of 3 or more uses up only creature and environment pieces; (b) only the piece you placed is spent; (c) the creature's Hurt lands on the piece in its aimed cell and breaks it, and hits you only if the cell is empty. Variant (c) is Into the Breach on a jigsaw and gives Guard pieces a job **(opinion: my pick)**.
- **Six creatures instead of one.** One readable rule per class, no smarter search (the sims show search buys nothing): Bird shows two aim cells; Beast hits harder each time you block it; Plant/Fungus grows a Bramble; Water pushes a piece; Reptile poisons the cell it leaves; Critter plays two small pieces. A boss shows two turns of aim.
- **A new success measure.** Win rate cannot see the problem, because the look bot is at 100% whatever changes. Add: the share of turns where the two best moves differ in kind but sit within 10% in value two turns out. Today I would guess under 20%. Aim for half.
- Then five real people on real phones. Every number in this review is a bot or a language model.

### Should a whole system be killed?

- **The fight board: no.** It is two days old (`pfboard.php` first commit 2026-11-12, 14 commits, off behind `pfight_v1`). Judge it as a prototype; as one, it found its good idea.
- **The deckbuilder layer around it: yes, for now (opinion).** Puzzle box tabs, belts, ranks, sources, 77 player pieces and 265 creature pieces were built before the fight was fun, and the sims say none of it changes a fight. PRODUCT.md already names the risk: "The risk is breadth" and "polish should make the game feel smaller and calmer, not add surface". Freeze it. A fixed 10-piece kit per calling is enough until one fight is worth playing twice.
- **The bigger question the owner should answer:** does a cosy garden game want a 3-minute tactical fight at all, or a 60-second one? Everything in PRODUCT.md points to the second **(opinion)**.

## What I did not verify

- **The live page.** I played the CLI harness only. Page findings come from `turnflow.md`, two screenshots and the playtest reports.
- **Layered creature decks in play.** The harness builds the old archetype deck (`pf_foe_deck`: Lunge, Snap, Feint, Recover, Rend), so in my four fights, and as far as I can tell in all 30 haiku fights, every creature played the same named pieces. The live game uses `pfd_foe_row` (class base, region, size extras, three unique). So "they all behave the same" is verified for the search code and the sims, and for names only in the harness. A real player will see different names and tags. This is also a gap in the playtest tool.
- **Real players, a real phone, a real network.** None.
- **My turn classification** is one person's judgement over 31 turns, with full knowledge of the sim results. A new player would find more turns hard, mostly for reasons of clarity.
- **The bait play's size.** It worked on 2 of 3 tries (the third re-picked because my edge did not fit). I did not sim it. With AIMSTICK it may be a dominant strategy, or the sims' look bot may already find it through the round preview.
- **The hand rule.** I saw unplayed pieces stay for ten turns and did not read the refill code to the end.
- **Whether 3e76b2f4 fixed the level 8-9 wall.** The changelog says medium levels 6-10 went from 60% to 77% for the careless bot; I did not re-run it. Variant sims in `rules.md` predate that commit.
- **None of my week 1 or week 2 proposals was simulated**, except the ones the earlier reports already ran (one bar, free pass, no must-link, no set-aside, Teamwork off, life sweep, kits).
- **Rewards, defeat and what a fight is worth to the rest of the game.** I confirmed only that health carries through the expedition.
