#!/bin/bash
# v2.0.87: regenerate the README screenshots (docs/screens/) from the CURRENT build:  bash tests/readme_shots.sh   (PHP, Chromium + Playwright, PIL; about a minute)
# Installs a throwaway copy (walk.sh), seeds the demo gnome (shot_seed.php), opens Puzzles + Jigsaw, captures desktop (light) and phone (dark) pages, quantises them.
HERE=$(cd "$(dirname "$0")" && pwd); ROOT=$(dirname "$HERE"); OUT="$ROOT/docs/screens"
T=$(mktemp -d); PORT=${PORT:-8961}; trap 'kill $PID 2>/dev/null; rm -rf "$T"' EXIT
cp -r "$ROOT/game" "$T/game"; rm -rf "$T/game/data" "$T/game/config.php"; mkdir -p "$T/game/data" "$T/raw"
bash "$HERE/walk.sh" "$T/game" $PORT "$HERE/router.php" >"$T/walk.out" 2>&1; grep -q '^installed' "$T/walk.out" || { echo "install failed"; exit 1; }
php "$HERE/shot_seed.php" "$T/game" sprout || exit 1
php -r '$p=new PDO("sqlite:'$T'/game/data/game.sqlite"); foreach (["puzzles_open","jigsaw_open"] as $k) $p->exec("INSERT OR REPLACE INTO settings (name,value) VALUES (\"$k\",\"1\")");'
php -d session.save_path=/tmp -S 127.0.0.1:$((PORT+1)) -t "$T/game" "$HERE/router.php" >"$T/php.log" 2>&1 & PID=$!; sleep 1
NODE_PATH=$(npm root -g) node "$HERE/readme_shots.js" http://127.0.0.1:$((PORT+1)) "$T/raw" || exit 1
mkdir -p "$OUT"
python3 - "$T/raw" "$OUT" <<'PY'
import sys, os, glob
from PIL import Image
raw, out = sys.argv[1:3]
for f in sorted(glob.glob(raw + '/*.png')):
    q = Image.open(f).convert('RGB').quantize(colors=200, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    dst = os.path.join(out, os.path.basename(f)); q.save(dst, optimize=True)
    print(os.path.basename(f), q.size, os.path.getsize(dst) // 1024, 'KB')
PY
