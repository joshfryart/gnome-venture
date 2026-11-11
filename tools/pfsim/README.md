# pfsim: throwaway puzzle-board sims (from the 2.6.60 / 2.6.63 playtests)
Run from the repo root. They use the real engine (`game/includes/pfboard.php`); nothing writes into the repo.
- `php tools/pfsim/run.php BOT MODE N OFFSETS [startpolicy]` e.g. `greedy classic 2 0,-4,-8`. Bots: greedy, careful, noisy, random, look, lookj, builder, charmb, hurtb. MODE classic|blank. Offsets = gnome level minus creature level. Prints win/defeat/turns/HP lost by size and temperament. Env `PASS=1|brace` tries the pass proposals.
- `bash tools/pfsim/par.sh jobs.txt` runs many in parallel (`label|ENV=..|args` per line; output in `out/`; `SCRIPT=run.php`).
- `php tools/pfsim/opening.php` the blank-opening experiments (start-side/piece policies).
- `php tools/pfsim/replay.php DIR` rebuilds the 500 round-2 agent fights from their `*.log` action files (unpack `docs/playtest-data/round2-2.6.63.tar.gz` into DIR) and reports self-hurt per move and where damage came from.
- `python3 tools/pfsim/agg.py` aggregates `out/*.txt`.
Numbers move about +-4 points run to run; read boss rows as rough.
