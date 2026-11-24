# Handoff prompt: stat pieces (copy everything below into the next AI)

You take over "stat pieces" work in repo joshfryart/gnome-venture, branch `ccr-0f0301f6-22ielh` (the only branch you may push to; no PR unless asked). User style: terse, exact, save tokens.

## Goal
Each gnome auto-owns unique stat pieces by stat points: stats Nimble, Lore, Luck, Sense (NOT Grit/Hardiness/Charm); tiers 0 (everyone), 10, 15, 20, 25, 30. Packed into the deck by choice, like counter knacks. 24 pieces built: 4 base plus 20 shortlisted. Numbers: a = 1 + points/5, b = ceil(a/2). Shared Luck roll = min(90, 50 + 2 x Luck)% rolled once per firing and cached. All behind admin setting `pfight_statpieces` (Off / Admins only / Everyone, default Off). With Off, fights must stay byte-for-byte unchanged (md5 tests in `tests/pfdeck_v1.php`).

## Read first
- `claude/stat-pieces-design/code-brief.md`: full coding brief and rules. Its "SP/..." paths now live in `claude/stat-pieces-design/`.
- `claude/stat-pieces-design/stat24.json`: the 24 piece specs (text, fx, engine_cost, motif).
- `claude/stat-pieces-design/tiers2-<stat>.json`: all 60 designed pieces (36 are reserve, not built).
- `claude/stat-pieces-design/art-brief.md`; art notes in `game/assets/img/pfight/stat/README.md`.
- `claude/stat-pieces-design/motifs/`: draft pfanim edge-effect motif code per stat (`stat_nimble.js`, `luck_pieces.js`, `lore_pieces.js`, `sense_pieces.js`, `stat_pieces.js`). Mockup code, NOT yet in the real build.
- `claude/todo.md`: standing rule is to update it after every change (its header is stale: says main 2.7.47).

## Done and committed (branch, newest first; pushed up to ac4360b6f)
- ac4360b6f Nimble slice (6 pieces); 487ac4a61 Luck slice (6); 027126c66 art (24 icons 32px + 20px `-s`, in `game/assets/img/pfight/pieces/ico-stat-*.png`, `game/assets/img/pfight/stat/`, sources in `aseprite-source/pfight/piece-icons/stat/` and `.../stat-kit/`); 3c29c1fc8 plumbing (setting, `game/includes/data/pf_stat_pieces.txt`, ownership, numbers, shared Luck roll).
- Earlier: test fixes for main 2.7.57 (all pushed).
- Tests: `tests/pf_stat_pieces.{php,sh}`, `tests/pf_stat_luck.php`, `tests/pf_stat_nimble.php`. Run: `PORT_BASE=<20000..29000> bash tests/ci_suites.sh <suite>` (suite names in `.github/workflows/ci.yml`).

## In flight: Lore slice committed as WIP snapshot (pf_stat_pieces and pf_stat_lore tests pass; parity suite and full run not rechecked). A background workflow may still add commits: check `git log` first
A Claude Workflow (run `whtw8o5q3`) was building slices in order: Lore, Sense, UI/layout, anim motifs into real pfanim build, art wiring, 3 reviewers, fixer plus full test run plus docs. At handoff the working tree held UNCOMMITTED Lore work: `game/includes/pfboard.php`, `game/includes/pfdeck.php`, `game/includes/data/pf_stat_pieces.txt`, `tools/pfengine.js`, `game/assets/pfboardv1.js` (1 line), `tests/pf_stat_pieces.*`, `tests/pfengine_js.{js,php}`, untracked `tests/pf_stat_lore.php`. If the workflow is dead or the tree is unchanged for a while, finish the Lore slice yourself (run its tests, `git add` explicit paths, commit). Do not clobber a running agent's edits.

## Unfinished (in order)
1. Lore slice: finish, test, commit.
2. Sense slice (Sharp Eye held shows the creature's next piece after its aim; others per stat24.json).
3. UI/layout: pack/own UI for stat pieces (like counter knacks); board-UI changes for pieces needing them (hand edit `game/assets/pfboardv1.js`, see warning).
4. Anim: port motifs from `claude/stat-pieces-design/motifs/` into `claude/pf-anim/motifs/*.js`, run `tools/build_pfanim.py` (builds `game/assets/pfanim-data.json`); animations should match the approved mockups (dice pops from the piece, trapdoor lid, shake on landing, 32%-opacity empowered overlay).
5. Art wiring: hook `ico-stat-*` icons and kit art into the renderer (`game/assets/pfparts47.js`, kit 48). Redraw weak icons (Knot of Twine, Lucky Streak, Nimble 20px) after seeing them in game. Art ink is `#2a1a10`.
6. Docs: new top section in `claude/todo.md`, write `claude/stat-pieces-spec.md`.
7. Full test run, then push.

## Warnings
- DO NOT run `tools/build_pfboardv1.py`: it overwrites hand edits in `game/assets/pfboardv1.js`. Known failing check `pbox_v1` "pfboardv1.js is what build_pfboardv1.py builds" (pre-existing; fix means porting hand edits back into `game/assets/pfboard.js`; not yet requested).
- `tools/pfengine.js` must stay in parity with `game/includes/pfboard.php` (`tests/pfengine_js.sh`).
- v1 rules: no set-aside/grouping, flipping free, any fitting cell legal, one placement a round, one shared Yield bar. Nothing may be pointless under them.
- Commit with explicit `git add <paths>` (never `-A`). Commit trailers: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>` and `Claude-Session: https://claude.ai/code/session_01PZZqg5mc1uztXauYQagDRB`.
- Browser tests: Playwright, `NODE_PATH=/opt/node-tools/node_modules`, chromium `/opt/pw-browsers/chromium`, args `['--no-sandbox']`. Tests set `pfight_intro` 0.
- Optional later: animate the 36 reserve pieces from `tiers2-*.json`.
