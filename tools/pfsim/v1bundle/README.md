# v1bundle: sims for the v1 board bundle (spend-on-chain)

Scratch quality. Sim only: nothing here is loaded by the game. Results are in `claude/design-board-strategy.md` ("Sim results (v1 bundle, spend-on-chain)").

- `mkengine.py` builds `pfboard_v1.php`, a patched copy of `game/includes/pfboard.php` with the v1 rules behind switches: ground cells (sunny, bramble, mud) for both sides, an environment turn with forecast events (rain, wind, thorn burst), chains of 3+ use up the fired pieces, the creature's aim (commit and fumble), Teamwork. Re-run it after the real engine changes: `python3 tools/pfsim/v1bundle/mkengine.py`.
- Switches: env `V1` holds JSON over `V1_DEFAULTS` (top of `pfboard_v1.php`), e.g. `V1='{"foe":1.35,"fumble_on":"blocked","limit":3}'`. Today's rules: `V1='{"ground":0,"events":0,"limit":0,"aim":0,"team":1}'`.
- `php run.php BOT OFFSETS [SHARD/N] [MULT]` plays fights and prints one JSON line per fight. Bots: random, chain (always the longest chain), greedy (best own-chain numbers), look (best state after the shown aim and the announced environment turn), smart (two turns ahead, with set-aside), never3 and smartn3 (look and smart that avoid using pieces up). OFFSETS = gnome level minus creature level (`0,-4,-8`). MULT 1 = 200+ fights per size and level.
- `bash par.sh LABEL 'V1-JSON' "bots" OFFSETS [MULT]` runs 4 shards per bot in parallel into `out/LABEL.jsonl` (`out/` is not committed).
- `php agg.php out/LABEL.jsonl [--detail]` prints the markdown tables (bot x size x level: win %, health lost %, turns; `--detail` adds chain and board numbers).
- `bash sweep.sh "bots" OFFSETS MULT label=json ...` compares rule variants. `bash side.sh > out/side.txt` re-runs the side experiments of the write-up (about 10 minutes on 4 cores).
- Env `SRC=thirds` gives every piece a source (pal, tool, crop in turn) for Teamwork tests; default is 2 pal, 2 tool, 2 crop pieces per deck. Env `HOARD=0.05` makes look and smart value their own pieces on the board.

The main table: `bash par.sh final '{"foe":1.35,"fumble_on":"blocked"}' "random chain greedy never3 look smart" 0,-4,-8 1 && php agg.php out/final.jsonl --detail` (about 2 minutes).
Numbers move about 4 points run to run at 200 fights per cell.
