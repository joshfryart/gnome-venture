# "The enemy gets random plays": what the owner saw (after 2.6.96)

Owner: "Enemy is getting random plays it seems. Sometimes it shows and wiggles but I think that's supposed to happen, I just can't tell why. Other times it like makes a piece show up and then the enemy plays it and gets a free activate and I wasn't aware that piece was there."

Short answer: the creature never plays at random. It plays exactly one piece a round, the one its aim shows, unless something on this list happens. The page used to show most of these without saying what they were.

## How it was measured
- Engine: `rounds.php` (here) plays 40 seeded fights with the rules a new fight has now (4 x 4 board, every size, the blank opening), a greedy player, and lists every creature round in order. The full list is in `rounds-40-fights.txt`: 223 creature rounds. A first pass of 16 fights gave similar shares (spawn 43%, environment fired 34%, re-pick 22% of 79 rounds).
- Browser: `tests/pfv1_enemy.sh` / `tests/pfv1_enemy.js` (Playwright, 390 x 844, speed 1x) plays one turn of each case from a seeded state (`tests/pfv1_enemy_seed.php`, Orb Spider), samples the page every 300 ms and saved a frame each time. The frames here are a selection, `before-*` from 2.6.96 and `after-*` with the fix.

## What each thing is

| What the owner saw | What it is | By design? | How often (223 creature rounds) |
|---|---|---|---|
| **A piece "shows and wiggles"** | When the creature has fewer than 2 pieces on the board after its turn, the board puts one of its gentlest pieces out for it for free (`pfb_spawn`, `PFB_FOE_MIN = 2`). Nothing fires. It grew in with a 2.2 s wiggle (`pfb-spawn` in `pfight.css`) **after** the replay, under the "Your turn" banner, with no words (`before-spawn-wiggle.png`). | Yes (the creature always has pieces out to link to). Not explained anywhere. | **105 rounds (47%)** |
| **"Makes a piece show up, then the enemy plays it and gets a free activate"** (1) | That spawned piece is the creature's own. Next round its chain can link into it and fire it. | Yes | 26 rounds (12%) |
| (2) | The environment places 2 pieces at the end of every round (Sun, Rain, Bramble, Thornburst). They belong to nobody and work for **whoever's chain fires them**. The creature's chain fired one in **95 rounds (43%)**, 121 firings: Rain gives it guard, Sun doubles it, Bramble hurts you. Every one of them was on the board before you moved. 106 of 121 were named in the aim's reasons, but only behind a tap on the aim chip (`before-envfire-chip.png`: "Aims Chitin Shell: guard 2"; the reason "Sun x2" was folded). The other 15: 5 after a re-pick, 10 where your own move changed its chain or it had shown no aim. | Yes (the rules say so) | 95 rounds (43%) |
| (3) | **The replay said "plays" for pieces that were already on the board.** A creature piece that fires in its own chain read "💥 The Orb Spider plays Silk Wrap (+2 guard)", the same words as the piece it placed (`before-chain-plays.png`). Your linked pieces read "You play ..." too. So one placement plus a chain looked like 2-4 plays. | No: a wording bug in `pfight_line` (and the JS port) | **116 of the creature's older pieces fired in 223 rounds** |
| "Random plays" (4) | **Re-pick**: your piece took the aimed cell, or left the aimed piece with no fit, so it picks again (no penalty). The replay still said "The Orb Spider aims Venom Fang at the marked cell" (`before-repick.png`), then played something else. | Yes (the aim is a promise only while its cell stays free) | 38 rounds (17%) |
| (5) | **Quick**: the aimed piece has Quick, so a second piece follows that was never shown. The chip said "hits you for 2"; "Quick: plays again" was folded (`before-quick-chip.png`). The replay already named it ("Quick. ... plays a second piece"). | Yes | 13 rounds (6%) |
| (6) | **No aim shown, yet it plays**: the chip says "no aim" when it had no fitting spot at the end of the round; your move can open one. | Yes | 7 rounds (3%) |
| **The other wiggle** | The first NEXT environment piece shakes (`pfv-nope`, red border) when the environment cannot place it (no free cell where it fits, or the board is too full). It stays NEXT for the next round. The line under the board already said so; the chip had no words. | Yes | 9 rounds (4%) |
| The pop-in | Each environment piece pops in with a small turn (`pfv-envin`) and its name ("The environment places Sun"). | Yes, and named | 408 placements |

The aim itself was played as shown in 158 rounds (71%). The hidden start piece and the blank centre are part of the opening only (round 1). They were not behind any of this.

## What changed (smallest changes, UI and text only; the engine's rules are untouched)
1. **Lines**: a piece already on the board that fires in its own side's chain now reads "The Orb Spider's chain fires its Silk Wrap" / "Your chain fires your Oat Cake". Only the placed piece "plays" (`pfight_line`, and `line()` in `tools/pfengine.js`: same words, parity test green). `after-chain-fires-its.png`.
2. **The board's free piece for the creature** is now the replay's last step, with a line: "The board puts out Chitin Shell for the Orb Spider (it had under 2 pieces out). Its chain can use it next turn." It grows in without the wiggle, then keeps a dashed red ring and a "+1" tag, a title, and a "Last plays" line until your move (`after-spawn-step.png`, `after-spawn-mark.png`). The step counts toward the 8.46 s cap.
3. **The aim chip** names the environment pieces its chain fires and a Quick second piece: "Chitin Shell: guard 2 · fires Sun", "Venom Fang: hits you for 2 · 2 pieces" (it drops "Aims" then, to stay on one line). `after-envfire-chip.png`, `after-quick-chip.png`.
4. **The creature's step** says what it does with its aim: "plays its aim, Venom Fang, on the marked cell" / "cannot play its aim (Venom Fang): its cell was taken or it no longer fits there. It picks again" / "showed no aim" / "loses its turn". `after-repick.png`.
5. **An environment piece that fires** says whose chain it was: "The Orb Spider's chain links into the Sun and fires it, for the Orb Spider."
6. **The shaking NEXT piece** has a title and label: "Thornburst could not be placed: no free cell where it fits, or the board is too full. It waits here for the next round." `after-pass-shake.png`.

Not done (no evidence it matters most): a ghost of the aimed piece with its edges on the aimed cell, live "your move breaks its aim" before End turn (the plan line already says "Its aim is broken: it will pick again" after you place), and marking on the board which environment pieces the aim would fire.

## Open questions for the owner
- Should the free piece for the creature stay at all? It is 47% of rounds. Without it a creature with no pieces out has nothing to link to; with it the creature gets a free piece the player did not see coming. Now it is at least named.
- Is "fires Sun" on the aim chip enough, or should the aimed chain light the environment pieces it would fire on the board?
