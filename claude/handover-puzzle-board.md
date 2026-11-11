# Puzzle board combat: handover (2026-11-11, branch `ccr-8a3c5e8f-zzi5i4` = 2.6.66; main = 2.6.65 without it)

**2.6.66 (this branch, not merged yet)** adds: blank-centre opening live by default (`pfight_blank` setting, 0 = classic), numbers on lit spots (`pfb_cell_preview`, POST `pfb_cells`), `PFB_BLANK_FOE_MULT` 1.0, join/add guard, 3-piece group x2.0. See `claude/plan-puzzle-board.md` "Changed in 2.6.66" and `CHANGELOG.md`. Zip: `releases/GnomeVenture-2.6.66-web-update.zip` (slim, needs 2.6.65+, no DB upgrade). Everything older (2.6.63 rules) is on `main`. Not run: full CI, MySQL, phone, a human play session. Done from the ranked list below: items 1, 2, 3 (item 2 numbers only; the x0.5 hurt-link rule A3 is not built).

## What exists
- **Board mode** (live page, admin settings `pfight_open`, `pfight_mode=board`): rules in `claude/plan-puzzle-board.md` (read it first; its "Changed in 2.6.63" and "Fire budget" sections are the newest rules).
- **2.6.63 rules added:** creature start piece never Hurt; hostile Charm x0.6 (`PF_HOSTILE_CM`); boss pieces x1.2; 3-piece group x1.5; Charm wins also roll seed/guide drops (`win_fight`); **fire budget**: a creature piece falls away after 2 firings (`PFB_FOE_FIRES`), creature values x1.15 (`PFB_FOE_FIRE_MULT`), your pieces unlimited; page shows an "x1" badge on a creature piece's last firing and `fl` (firings left) in the view.
- **Blank-centre opening (live default since 2.6.66; before that opt-in):** `pfb_new($me,$c,$seed,['blank'=>true])` then `pfb_start($s,$handIdx,'L|R|T|B')`. Blank wild piece in the centre: pieces may connect to it but it fires nothing and chains never run through it; both sides put a hidden start piece on a side (collision: yours stays, the creature takes the next free side); blank gone end of turn 1; creature pieces x`PFB_BLANK_FOE_MULT` 1.2. Exists in the PHP engine, the JS engine and the demo page only.

## Where things are
| What | File |
|---|---|
| Board engine | `game/includes/pfboard.php` (tiles, decks, `pf_*`: `pfight.php`; data `pfight_data.php`; page wiring `pfight_game.php`) |
| Page scripts / css | `game/assets/pfboard.js`, `pfparts.js`, `pfight.css` |
| JS port of the engine (demo + parity) | `tools/pfengine.js` |
| Playable demo (Claude artifact) | build `python3 tools/build_pf_artifact.py OUT.html`, publish to the existing artifact (`https://claude.ai/artifact/FjaGvVxbVatzsW4MDy3oCz`, Josh's account) with the Artifact tool and the same URL; sources `tools/pfartifact/glue.js`, `page.html` |
| CLI playtest harness | `tests/pf_play.php` (`new/show/start/place/join/add/group/pass`; shows `!` on cells that fire a creature Hurt piece, fires left, FELL AWAY/EXPIRED/RESHUFFLE notes) |
| Agents | `claude/pf-agents/pf-playtester.md` (haiku), `pf-analyst.md` (sonnet); copy into `.claude/agents/` (gitignored) to register; use `subagent_type` pf-playtester |
| Sims | `tools/pfsim/` (see its README) |
| Playtest data | `docs/playtest-data/round1-2.6.60.tar.gz` (174 fights), `round2-2.6.63.tar.gz` (500 fights, with action logs) |
| Reports | `docs/puzzle-board-playtest-2.6.60.md`, `puzzle-board-playtest-round2.md`, `puzzle-board-proposals.md` (P1-P9) |

## Tests (all pass on main; run from the repo root)
`bash tests/pfboard_fixes.sh` (every 2.6.63 fix; each fails on the 2.6.60 engine), `pfboard_sim.sh` (88 creatures, invariants), `pfengine_js.sh` (JS port == PHP over 352 fights incl. blank), `pfboard_js.sh`, `pfboard.sh` (HTTP page, plays a whole fight; failed once in 12 runs when the random fight did not end, passes on rerun), `pfight_sim.sh`. Balance table: `php tests/pfboard_tune.php 3` (greedy bot, ~6 s; win/turns/HP lost by size at the creature's level and 8 under).
Rule for new fixes: write the regression check first and watch it fail on the previous engine (see `.claude/rules/test-standards.md`).

## Findings so far (details in the docs)
- Agents (haiku, 500 fights): blank plays HARDER than classic: win 69% vs 80% (8 under: 24% vs 50%; bosses 74% vs 96%; random play 32% vs 68%). Cause is mostly `PFB_BLANK_FOE_MULT` 1.2 (bot check: 1.0 is level). The opening pick barely matters.
- Forced hurting moves (every legal cell links into a creature Hurt piece) cause most defeats; creature re-fire through your links is the biggest damage source. Allowing `pass` measured as a trap (skipping gives the creature a free turn).
- Fire budget prototype (P9): limiting BOTH sides slows every fight ~70% and hurts the player; limiting only the creature is a clear win. That is what shipped.
- Set-aside (join/add/group) pays off about half the time; each step costs a turn.

## Next steps (ranked; Opus proposals in `docs/puzzle-board-proposals.md`, numbers in the doc)
1. ~~**P2** `PFB_BLANK_FOE_MULT` 1.2 -> 1.0~~ DONE 2.6.66 (bot table: blank now level with classic or a little easier; re-run an agent round to confirm) (re-run a ~100-fight agent round to confirm; the fire budget changed the baseline, so re-check with `pfboard_tune.php` blank rows first).
2. ~~**P1** show numbers instead of the bare `!`~~ DONE 2.6.66 (page + harness; not in the JS demo): per cell damage dealt, HP cost, chain length, likely creature reply (the page already has `pfb_preview` dry runs). Players who see numbers win 99/91/66% (at level / 4 / 8 under) vs 96/70/47% avoiding `!` blind.
3. ~~**P4** join/add gives guard~~ DONE 2.6.66; join/add gives guard equal to the joined piece's value; 3-piece group x1.5 -> x2.0.
4. Harness/page clarity: `!` marks for group placements, creature guard soaking your Hurt is silent (show guard value), "EXPIRED ... creature Blank" label, "CHAIN STOPPED" wording, `add` ANC/SIDE help, poison tick explained.
5. "Some pieces stick longer": per-tile or boss extra firings (creature guard/Hold, bosses at 3) not built or measured.
6. Real-player session before more tuning: all data so far is bots and haiku agents.

## Decisions for Josh
Hidden or revealed creature start piece (and a start-piece bonus); how dangerous re-fire should be; allow `pass` anyway for agency (measured as a trap); Charm on bosses; difficulty target for weak players (the fire budget now helps them 3-7 points); hostile Charm 0.6 -> 0.75 (also changes the old strip mode); whether the blank-centre opening goes into the live page at all (it is demo-only; the agent data says the opening choice barely matters).

## Caveats
- `PFB_*` constants and the JS port must change together (`tests/pfengine_js.sh` catches drift). New state keys the harness/replay use: `reshuf`, `cut`, `spent` (skipped by the parity compare).
- Treks still use the old fight (`trek_fight.php`).
- Agent play notes: haiku agents rarely sampled join/add/group and their "random"/"greedy" were improvised; some reported bugs were not bugs (large creatures DO have a charm bar; a missing `!` on a cell whose placement ends the fight first is the dry run stopping early).
- Throwaway scratch (sim outputs, the Opus replay data) lived in session `/tmp` and is gone; the repo copies above are what remain.
