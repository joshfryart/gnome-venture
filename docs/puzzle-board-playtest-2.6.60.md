# Puzzle board playtest, 2.6.60 (+ blank-centre start variant)

Harness `tests/pf_play.php`, variant opt-in `new ... blank`, agents in `claude/pf-agents/`. Data: 174 haiku fights (87 classic/blank pairs, 30 agents) and six sonnet analyst sweeps (bots, tens of thousands of seeded fights). Everything here is bot or agent play, not human play. Suggestions are untested.

## 1. Headline
- **Matched level (gnome level = creature level) the game is easy:** a 2-ply bot wins 261/264 (99%); plain 1-ply 97%. Hurt-only 99%, charm-only 89% (10.9 turns), group-of-3 only 60%, random 48%.
- **The "L1/L10 ~40% win" haiku result is mostly level mismatch**, caused by my assignment matrix (gnome L1 met creatures up to L37). Not a game cliff.
- **Real cliffs:** gnome level minus creature level (d): large 100% at d0, 90% d-4, 63% d-8 (classic); medium 98%, 64%, 42%. Bosses are the odd one: 100% even at d-8 and 97% at d-12 (bot), cliff at gnome L14-15 vs L26-32 bosses (55% to 97%+ in 2 levels, calling independent).
- **Level scaling is steep:** gnome tile values (+1 per 3 levels + stat mod) and HP outgrow creature scaling; box size/unlocks barely matter.

## 2. Blank-centre start (your variant)
Paired, 61 fights x 20 starts (1,220 blank) vs classic on same creature/level/seed (greedy bot): win 98.0% vs 98.4%, turns 4.43 vs 4.62, HP lost 10.2 vs 14.6, won in round 1: 28/1,220 vs 0/61. All-creature sweep (1,408 fights): HP lost about halves for small/medium/large, turns about 1 lower, 40/288 small+medium blank fights end on turn 1.
- **Start choice matters more than haiku said:** outcome flips win/defeat by start in 21/61 fights; best is "your best Hurt, any side" (-0.46 turns). No dominant side (T -0.19, R +0.15 turns).
- **The creature's start piece fires on every turn-1 placement (14,771/14,771), unavoidable** (connect rule + wild blank). Harmless mostly: trick 41% no effect, heal 33% / guard 22% cost ~1 progress, Hurt 3.3% hits 4.2 HP per fire.
- **Root cause of the turn-1 deaths (tawny-owl L1 seed 1088) is not the blank:** `pfb_anchor_pick` falls back to `hand[0]` (a Hurt) when the creature's whole hand is Hurt (50 creatures, 3.3% of starts). It also kills in classic.
- **Board after the blank vanishes:** 66% of start pieces and 53% of all pieces have no link at turn 2; ~3 disconnected groups vs 1.1 classic. No stuck states, 0 passes in 5,402 turns. The blank's cell is an open site but used in 1% of turn-2 moves.
- **Collision rule** (you keep the side, creature takes next free side in L,R,T,B order) is fine (+0.17 turns, noise). Creature's side roll is deterministic per seed and skewed: L 19, R 28.5, T 29, B 23%.
- Blank is easier than classic for a sane player on nearly every creature, so if it ships it needs creature values raised or the bar multiplier changed in blank.

## 3. Bugs and defects (ranked)
1. **Design bug:** anchor fallback puts a Hurt piece out as the "gentlest non-Hurt" start piece (classic and blank). `pfb_anchor_pick`.
2. **No engine bugs with player impact** from ~2,200 fuzzed fights, 43,200 join combos, odd-input matrix. Illegal inputs refuse cleanly, state unchanged.
3. **Display gaps (engine events):** `pfb_fire` stops at fight end, so linked pieces behind the finisher are silent; expired pieces vanish with no event; reshuffle silent; stall label reads TURN 25 after 24 turns (turn++ before cap check); blank still drawn after a round-1 fight end; `pfb_pass` has no start-phase guard (blocked only because every piece fits the wild centre).
4. **Doc debt:** hostile Charm x0.4 (`pfight.php:271`) not in `plan-puzzle-board.md`; `PF_GENTLE` comment and `pf_temper` docblock say Hurt x0.5, code is 0.8 (`PF_GENTLE_HM`).
5. **Haiku claims checked:** "charm counted twice" = a 5-piece chain, not a bug; "guard 0" = by-design reset at your next turn (now explained in the harness header); "listed cell refused" not reproduced (0 in ~2,200; likely stale hand index after join/add); `join` edge refusals correct; poison tick line was a harness display issue (fixed).

## 4. Balance findings
- **Creature re-fire** (your link onto its older Hurt re-fires it) is the main loss cause: defeats averaged 12.1 damage from it vs 5.5 in wins; worst single turn 33 HP; max single-turn loss 68 (large). Legal-cell lists don't warn. Re-fires are symmetric (~16% extra damage for you, 630 vs 688 per 300 fights).
- **Group of 3 is a trap:** the look-ahead bot used it in 4/352 fights. Costs two turns for one x1.25 play.
- **Charm:** faster only vs gentle (3.64 vs 4.62 turns neutral; spec 2.97 vs 3.27); vs hostile 6.95 vs 3.60 turns, 5 defeats vs 1; charm-only L10 medium hostile is the worst cell. Hurt-only never stalls gentle (max 10 turns). Mixed boxes with a greedy bot are slower than either specialist (meters don't add). Charm reward: full XP + guaranteed gift + befriend credit, but skips seed/guide drops (11 species) and is worse on item count for 18 of 79 species.
- **Bosses are the easiest class per HP lost** (11-13% vs 32% large) and 100% beatable far below their level; pace at d0 is 7.0 classic / 5.2 blank vs target 6.5.
- **Slow outliers at their own level (+1 to +1.5 turns):** red-fox, grey-heron, tawny-owl, beaver-foreman, giant-anteater, orb-spider, bog-leech, paper-wasp, grumpy-lemming, tawny-owl, reef-turtle, cave-glowworm. Classic-only killers: thistle-beast / ember-beetle (59% HP lost classic, 8% blank), orb-spider, tide-crab-knight. Duplicate decks: ~15 creature groups share identical numbers (content point).
- **Too easy:** small creatures at L1 in blank (aphid-swarm, garden-snail: 7/8 end turn 1).
- **Levels above 37:** no creature exists above L37; large/boss data above that is gnome-over-level only.

## 5. Suggestions (untested)
1. Fix anchor fallback: draw until non-Hurt, or put a neutral filler piece out.
2. Blank: raise creature values/chain or change the 0.7 bar multiplier for blank only; show the creature's start piece on the start screen; consider letting start pieces keep links when the blank leaves (e.g. a flat stub).
3. Warn about re-fire in the live preview (`pfb_preview` already dry-runs it); list joins that would fire creature Hurt.
4. Bosses: raise damage or `PFB_FOE_MULT` for the boss class, and soften the L14-15 cliff.
5. Charm: lift hostile charm penalty (0.4 to ~0.6) or give hostile charms a better gift; fix charm skipping seed/guide drops.
6. Group of 3: higher multiplier or a shield on first turn, or accept it as advanced.
7. Tune the slow outliers; differentiate duplicate-deck creatures.
8. Add events: expiry, reshuffle, "chain stopped (fight over)"; fix the TURN 25 label; guard `pfb_pass` with the start flag.
9. Update docs (hostile charm factor, 0.8 gentle Hurt).

## 6. Assumptions I made for the variant (confirm)
Blank fits and links everything, fires nothing; lasts through turn 1 then its cell is open; start tiles expire normally (3 rounds); collision: player keeps the side; creature rolls its side before seeing yours; bosses start two pieces; creature start piece fires like any piece.

## 7. Method limits
One bot family, default gnome build (no pals/upgrades), 6-16 seeds per cell for most sweeps, haiku "random" and "greedy" styles were improvised by agents. Haiku assignment mismatched levels (see section 1). Human play not tested; boss stalls by a human at L10-14 untested.

## 8. Reproduce
`php tests/pf_play.php new STATE SLUG LEVEL SEED [classic|blank]`, then `start/place/join/add/group/pass/show`. Example: `new S tawny-owl 1 1088 blank; start S 3 L; place S 2 4 2`.
