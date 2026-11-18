# Engine / fight UI notes, 2.7.08 (fight engine agent, 2026-11-17)

Scope: the 2.7.07 STILL OPEN fight items and section 4 "Puzzle combat not done" clarity items. Sections 1, 2, 5, 6: no engine rule changed (text, harness and checks). Sections 3 and 4 (reopened by Josh) add pal targeting and counter pieces.

## 1. Teamwork tuning: checked, NO change
- Bots (chain + look, std + pals builds, 88 tune creatures, 1 seed; scratch script, numbers below): Teamwork fires in 11-35% of your turns (chain std: small 30%, medium 32%, large 14%, boss 11%); x1.6 in 0-4%.
- Teamwork off (team2 = team3 = 1.0) vs on: chain std medium 62 -> 69% win, large 60 -> 65%, small / boss unchanged; look bot 92-100% either way; fights 0.1-0.6 turns shorter. Reachable, not dominant: +30% / +60% kept (Josh).
- Guard added: `tests/pf_bots.php edge` (suite `pf_bots`) now checks on 30 creatures, chain bot: Teamwork in 5-50% of your turns and x1.6 in at most 10% (seen: 27% / 2%). Watched failing with Teamwork off (`pb_aim_stats($cr, ['team2'=>1,'team3'=>1])` gives 0%).

## 2. Re-aim count and bait aims: checked, NO engine change
- Re-aims per fight: chain bot 0.1-0.8 (max 4), look bot 0.5-2.6 (max 6 in an 8-turn boss fight, the look bot blocks aims on purpose). No pathological counts; Josh accepted re-aim ("?" sheet explains it).
- Bait (the creature's committed aim fires YOUR pieces into itself): 3% of creature turns for the chain bot, 5% greedy, 7% look; median 5-9% of its bar, max 16% (chain) / 43% (look, 4 of 529 turns over 25%). The creature's own search already scores firing your pieces as a loss (`pfb_score` -0.8 x bar), so bait only comes from the player changing the board after the aim is shown: the designed, visible counterplay (aim panel "fires your X: N to it"). Left as is (Josh: "not changed on purpose; reopen only if bots show a problem"): they do not.
- Guard added in `pf_bots edge`: re-aims at most 2 a fight on average, bait at most 50% of its bar in one turn (seen 0.50 / 26%).

## 3. Pal targeting: DONE (Josh reopened it, 2026-11-17 goal: "both required")
Smallest design taken from the docs (design-board-strategy "a pal trick can move the aim marker" was the only proposal; a strongest-piece target is simpler to read and needs no new aim state):
- **Rule.** A pal piece (`pal:` key or `src` pal, Boon pals too) that YOU PLACE, after its chain has fired and used up what it uses up, knocks the creature's **strongest piece** off the board: the highest value that is **not above the pal piece's own value** (a bigger piece is left alone); a tie goes to the piece **fewest steps** (|dx| + |dy|) from the pal's cell, then the **oldest** (lowest id). No dice: same board, same target. The piece goes to the creature's discard and shows as used up by you (gone list `used: me`); a Reptile still leaves its venom. A pal piece that only fires in a later chain does nothing extra. A **boss shrugs it off** (like Charm can never win a boss): without this the boss median rose 77.8 -> 83.3 (18 seeds).
- **Engine.** `pfb_pal_target($s, $x, $y, $pv)` / `pfb_pal_nip` in `game/includes/pfboard.php`, called from `pfb_place`; rule key `paltgt` (PRE 0: fights saved before keep playing without it; new fights 1). Notice event `note: palaim` (`tid`, `x`, `y`, `pal`, `tv`; no `id`, so no chain glow). Mirrored in `tools/pfengine.js` (`palTarget`, `palNip`, `PFB_V1_PRE` / `v1Cfg`, `noteLine`, `chipEvent`); the parity trace fires it 500+ times (`tests/pfengine_js.sh` passes; watched failing with the JS boss check removed).
- **Shown.** `pfb_cell_preview` gives each lit cell `pal: {id, n, x, y}` (the target from that cell); the page puts a paw on that lit spot (title / aria "Your pal knocks off its X") and, once placed, a chip "🐾 knocks off X" in the row above the board (`tools/pfboardv1_part.js`, `tools/build_pfboardv1.py` -> `game/assets/pfboardv1.js`). Log line "🐾 Wolf goes for the Owl's strongest piece: its C3 is knocked off the board.", history chip "🐾 knocks off C3".
- **Help.** "?" sheet row "Pal targeting" (only in fights with the rule); the pal / Boon tag words (`PF_SPECIAL`) say it too.
- **Tests.** `tests/pfboard_v1_paltgt.php` (section 31 of `pfboard_v1`, 19 checks; watched failing on HEAD before the engine change): value, steps, oldest, cap, no target, only yours, only pal pieces, key-only pal piece, old fights, boss, preview per cell, notice / line / chip, view key. `tests/pfboard_v1.php` compat checks now count 22 PRE keys.
- **Bots (chain bot at level, std build = Bark Badger from lv 3, Samara Spin from lv 8, 88 creatures, 18 seeds; same creature data both runs).** Win-rate medians before -> after: small 88.9 -> 88.9, medium 83.3 -> 83.3, large 72.2 -> 72.2, boss 77.8 -> 77.8 (means 85.0 / 81.6 / 68.9 / 79.0 -> 85.0 / 82.1 / 70.0 / 79.0). Pal-heavy build (4 pals, 6 seeds): large mean 63.6 -> 70.9, medium 86.5 -> 87.8, small / boss unchanged. Inside the 3-point band on every size median.

## 4. Counter piece per type: DONE (Josh reopened it)
- **Pieces** (`game/includes/data/pf_pieces.txt`, source `knack`, ref `LEVEL:CLASS`, rarity 0, value on the curve of `claude/piece-audit-2.7.07.md` = type base - tag cost; the knob is never the class's lean family so it rarely links into that creature's pieces):

| class (PFB_AB_RANGE / pfb_kind) | piece | level | type, value, tag | why it answers |
|---|---|---|---|---|
| critter (Swarm) | Pest Ring | 6 | guard 2, Thorns | many small bites get pricked |
| bird (Two aims) | Scarecrow Flap | 8 | hurt 2, Trip | it skips its next turn, both aims with it |
| beast (Grudge) | Honey Pot | 10 | soothe 2 | its hard hits land softer |
| water (Current) | Sandbag | 12 | guard 3, Hold | guard that stays through the tide |
| plant (Grows) | Billhook | 14 | hurt 3, Pierce | cuts through its thick guard |
| reptile (Venom trail) | Antivenom | 16 | guard 2, Evade | its next hit misses and poison ticks do nothing |

- **Source.** Existing knack acquisition (owned by level in `pfd_build`), no new system. Like every newly earned piece it arrives switched off ("New") until the gnome packs it in the Puzzle box, so the tuner's and the bots' decks and the tune rows do not move. `ref` with a colon keeps them out of the old tile library (`pf_tiles`, `pf_unlocks`), as the calling tier III pieces. The box says "Knack, learned at level N; good against Birds" (`pfv_from`). `PFD_COUNTER_CLASSES`, `pfd_counter_of()` in `pfdeck.php`.
- **Engine (small).** The class rides on the tile (`cnt`, kept by `pf_make_tile` / `pfd_tiles`); in `pfb_fire` a piece of yours whose `cnt` is the fight's class (`pfb_kind`, new fights) counts `PFB_COUNTER_ADD` = +2. Event `cntr`, log bit "🎯 counter +2". Mirrored in `tools/pfengine.js` (parity trace puts `cnt` on 1 piece in 5: 200+ counter firings match; watched failing with the JS line removed).
- **Tests.** `tests/pfdeck_v1.php` lint: one per class, on the curve, out of `pf_tiles` / `pf_unlocks`, owned by level and off by default, in the fight deck with their tag once on; knack lint skips `LEVEL:CLASS` refs. `tests/pfboard_v1_counter.php` (section 32 of `pfboard_v1`): +2 against its class only, not in kinds-0 fights, never for the creature, log line, deck model carries `cnt`.
- **Measured (std deck + the class's counter switched on vs std, same seeds, 12 per creature, 79 non-boss creatures).** Chain bot win: water 66.7 -> 75.8, reptile 76.9 -> 78.8, bird 77.1 -> 75.0, beast 75.6 -> 72.2, critter 82.8 -> 78.4, plant 83.3 -> 75.0 (3 creatures); all 76.6 -> 75.4. Look bot (already ~99% wins) health lost: reptile 20 -> 14%, critter 32 -> 29%, water 20 -> 18%, beast / bird +0.5, plant 8 -> 19% (3 creatures). The +2 changed no win in the chain-bot sample (same results with and without it): the chain bot ignores tags and one more low-value piece dilutes its hand. So: real answers to Water and Reptiles, roughly neutral elsewhere for a bot; a player who plays the Trip / Evade on purpose gets more. Open for Josh: raise `PFB_COUNTER_ADD` (or make it x1.5) if counters should be a clear pick.
- **Tune rows:** untouched (std medians above are with the counters owned but off, exactly as before).

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
