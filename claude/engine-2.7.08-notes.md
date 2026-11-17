# Engine / fight UI notes, 2.7.08 (fight engine agent, 2026-11-17)

Scope: the 2.7.07 STILL OPEN fight items and section 4 "Puzzle combat not done" clarity items. No engine rule changed; text, harness and checks only.

## 1. Teamwork tuning: checked, NO change
- Bots (chain + look, std + pals builds, 88 tune creatures, 1 seed; scratch script, numbers below): Teamwork fires in 11-35% of your turns (chain std: small 30%, medium 32%, large 14%, boss 11%); x1.6 in 0-4%.
- Teamwork off (team2 = team3 = 1.0) vs on: chain std medium 62 -> 69% win, large 60 -> 65%, small / boss unchanged; look bot 92-100% either way; fights 0.1-0.6 turns shorter. Reachable, not dominant: +30% / +60% kept (Josh).
- Guard added: `tests/pf_bots.php edge` (suite `pf_bots`) now checks on 30 creatures, chain bot: Teamwork in 5-50% of your turns and x1.6 in at most 10% (seen: 27% / 2%). Watched failing with Teamwork off (`pb_aim_stats($cr, ['team2'=>1,'team3'=>1])` gives 0%).

## 2. Re-aim count and bait aims: checked, NO engine change
- Re-aims per fight: chain bot 0.1-0.8 (max 4), look bot 0.5-2.6 (max 6 in an 8-turn boss fight, the look bot blocks aims on purpose). No pathological counts; Josh accepted re-aim ("?" sheet explains it).
- Bait (the creature's committed aim fires YOUR pieces into itself): 3% of creature turns for the chain bot, 5% greedy, 7% look; median 5-9% of its bar, max 16% (chain) / 43% (look, 4 of 529 turns over 25%). The creature's own search already scores firing your pieces as a loss (`pfb_score` -0.8 x bar), so bait only comes from the player changing the board after the aim is shown: the designed, visible counterplay (aim panel "fires your X: N to it"). Left as is (Josh: "not changed on purpose; reopen only if bots show a problem"): they do not.
- Guard added in `pf_bots edge`: re-aims at most 2 a fight on average, bait at most 50% of its bar in one turn (seen 0.50 / 26%).

## 3. Pal targeting: SKIPPED
- DROPPED by Josh (todo section 0, 2.7.06 bullet and JOSH ANSWERS). Nothing built.

## 4. Counter piece per type: SKIPPED
- Josh's "my defaults" answer (todo section 4, STEP 3 DECISIONS): not changed on purpose, adding pieces resets the tune rows (a balance agent is refitting them now). No bot data shows a type without an answer. Needs Josh to reopen.

## 5. Boon tag on pal pieces: already DONE (2.7.07)
- `pf_boon_tag` passes (ci_suites). Nothing to add.

## 6. Puzzle clarity (docs/puzzle-board-proposals.md P7)
- Creature guard readout: your Hurt into its guard now says so. History chip: "-5 hp · 4 blocked"; log line: "You play Jab for 5 (4 blocked by its guard)." (`pfight_chip_event`, `pfight_line` in `game/includes/pfight_game.php`; mirrored in `tools/pfengine.js` chipEvent / line). The page already had the "its guard N" chip. Harness `tests/pf_play.php`: TURN line shows `creature guard N`, event lines add "(N blocked by its guard)".
- Expiry label: harness prints "The blank centre is gone (turn 1 is over)." (the blank was already kept out of EXPIRED).
- Group `!` marks: harness SET-ASIDE line numbers the group pieces (#0, #1 = ANC for `add`) and gives each spot the hand-cell numbers (d c h n r END) plus `!` when your chain there fires a creature Hurt piece (`pp_fires_foe_hurt`, dry run).
- `add` help: harness lists the legal moves as commands (JOIN ... `join A B SIDE`, ADD ... `add B ANC SIDE`) and a refused join / add prints a HELP line with the argument meanings and the legal moves (`pp_aside_moves`). Setting aside is out of v1 fights, so the v1 page needs none of this.
- Tests (watched failing first): `tests/pfboard_v1_guard.php` (4 checks, in `pfboard_v1`), `tests/pf_play_decks.sh` (e) x8.

## Test runs (2026-11-17)
- pass: pfboard_v1, pfboard_sim, pfight_sim, pfboard_fixes, pfboard_js, pf_play_decks, pf_bots (edge), ci_suites: pfdeck_v1 pfv1_belt pf_boon_tag pfboard_v1_page pfight_js pf_bots pfight fight_events pfboard pfboard_combo_set pfv1_costly pfboard_v1_abil pfboard_v1_ai pf_learner.
- pfengine_js: passes with my changes on HEAD data (checked in a copy); FAILS in the shared tree on the data agent's uncommitted calling tier III pieces (`Deep Roots` ... `Slow Brew` in pf_pieces.txt / pfdeck.php: the JS tiles table lacks them). That agent must sync `tools/pfengine.js`.
- pfv1_charm: FAILS on clean HEAD 1c3912ed too (scripted charm win no longer ends the fight: "the winning turn ends the fight (got null)"), so not from this work; likely the tune / piece data changes. Not fixed here.
