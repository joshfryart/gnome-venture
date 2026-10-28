#!/bin/bash
# v2.0.73: regenerate the front-page tour screenshots from the CURRENT build. Run after any release that changes the look of a tour page:
#   bash tests/shots.sh            (needs PHP, Chromium + Playwright, PIL; takes about a minute)
# Installs a throwaway copy (walk.sh), seeds the demo gnome (shot_seed.php), captures 6 pages x dark/light at 412 px, quantises them and writes
# game/assets/img/landing/shot-<stop>[-dark].png + tests/manifests/shots.txt (version + sizes; tests/shots_stale.sh checks it).
HERE=$(cd "$(dirname "$0")" && pwd); ROOT=$(dirname "$HERE"); OUT="$ROOT/game/assets/img/landing"
T=$(mktemp -d); PORT=${PORT:-8951}; trap 'kill $PID 2>/dev/null; rm -rf "$T"' EXIT
cp -r "$ROOT/game" "$T/game"; rm -rf "$T/game/data" "$T/game/config.php"; mkdir -p "$T/game/data" "$T/raw"
bash "$HERE/walk.sh" "$T/game" $PORT "$HERE/router.php" >"$T/walk.out" 2>&1; grep -q '^installed' "$T/walk.out" || { echo "install failed"; exit 1; }
php "$HERE/shot_seed.php" "$T/game" sprout || exit 1
php -d session.save_path=/tmp -S 127.0.0.1:$((PORT+1)) -t "$T/game" "$HERE/router.php" >"$T/php.log" 2>&1 & PID=$!; sleep 1
NODE_PATH=$(npm root -g) node "$HERE/shots.js" http://127.0.0.1:$((PORT+1)) "$T/raw" || exit 1
python3 - "$T/raw" "$OUT" "$ROOT/tests/manifests/shots.txt" "$(grep -o "APP_VERSION', '[0-9.]*" "$ROOT/game/includes/bootstrap.php" | grep -o '[0-9.]*$')" <<'PY'
import sys, os, glob
from PIL import Image
raw, out, man, ver = sys.argv[1:5]
os.makedirs(out, exist_ok=True)
lines = ['version ' + ver]
for f in sorted(glob.glob(raw + '/raw-*.png')):
    name = os.path.basename(f)[4:]
    im = Image.open(f).convert('RGB')
    q = im.quantize(colors=160, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    dst = os.path.join(out, 'shot-' + name)
    q.save(dst, optimize=True)
    lines.append('%s %dx%d %d' % ('shot-' + name, q.width, q.height, os.path.getsize(dst)))
open(man, 'w').write('\n'.join(lines) + '\n')
print('\n'.join(lines))
PY
