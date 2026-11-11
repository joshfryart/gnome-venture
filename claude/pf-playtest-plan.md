# Puzzle board playtest plan (2.6.60 + blank-centre start variant)

Harness: `tests/pf_play.php` (CLI, no DB/server; state in a json file; every action logged to `STATE.log`). Variant: `new ... blank` = blank wild centre piece + hidden simultaneous start (`start HANDIDX SIDE`), blank vanishes at end of turn 1; engine support is opt-in in `pfboard.php` (`$opt['blank']`, `pfb_start`), the page never uses it.
Agents: `claude/pf-agents/pf-playtester.md` (haiku, volume), `claude/pf-agents/pf-analyst.md` (copy into `.claude/agents/` to register) (sonnet, six foci).

Waves
1. Smoke: 2 playtesters (1 classic, 1 blank) to prove the loop. Fix harness text if they misread it.
2. Volume: playtesters across creature x level x seed x playstyle x mode (matrix: 5 playstyles, 4 sizes, levels 1/10/25/50, paired classic/blank on same seed).
3. Analysts: 6 foci, one each, after wave 2 so they can read its results.
4. Synthesis report in `docs/`.

Rule assumptions to confirm with Josh: blank fits AND links everything, fires nothing; blank lasts through turn 1 then its cell is an open site; start tiles expire normally (3 rounds); on a same-side collision the player keeps the side and the creature takes the next free side; creature's start side is rolled before it sees yours; bosses start two pieces.
