#!/bin/bash
# Swap the staged rigs into a SCRATCH copy of game/ and run every test that reads rig sheets. The repo's game/ is never written.
#   1. rigkit checks on each staged sheet (size/mode = shipped, alpha 0/255, parts inside their columns, ink row = ring, pivots on parts)
#   2. tools/fight/smoke.js  (engine lint, every rigged creature mounts, loads a sheet cols x fw wide, attacks, is hit, is knocked out, no NaN)
#   3. tests/fight_scene.sh  (the fight page end to end in PHP + Chromium; uses whatever creature the test fight draws)
# Usage: art-review/rigs/swap_test.sh [slug ...]   (default: every out/rig-*.png)
set -u
HERE=$(cd "$(dirname "$0")" && pwd); ROOT=$(cd "$HERE/../.." && pwd)
SLUGS=${*:-$(cd "$HERE/out" && ls rig-*.png | sed 's/^rig-//;s/\.png$//')}
T=$(mktemp -d); trap "rm -rf $T" EXIT
mkdir -p "$T/tools/fight"; cp -r "$ROOT/game" "$T/game"; cp "$ROOT/tools/fight/smoke.js" "$T/tools/fight/"
FAIL=0
echo "== 1. sheet checks"
for s in $SLUGS; do
  python3 -c "import sys; sys.path.insert(0, '$HERE'); import rigkit; b = rigkit.check('$s', '$HERE/out/rig-$s.png'); print('$s', 'OK' if not b else 'FAIL ' + '; '.join(b)); sys.exit(1 if b else 0)" || FAIL=1
  cp "$HERE/out/rig-$s.png" "$T/game/assets/img/fight/rig-$s.png"
done
echo "== 2. tools/fight/smoke.js (scratch copy, staged sheets swapped in)"
(cd "$T" && NODE_PATH=$(npm root -g) node tools/fight/smoke.js) 2>&1 | grep -vE '^ok ' ; [ "${PIPESTATUS[0]}" = 0 ] || FAIL=1
echo "== 3. tests/fight_scene.sh (scratch copy)"
OUTP=$(bash "$ROOT/tests/fight_scene.sh" "$T/game" 8799 2>&1); echo "$OUTP" | tail -4
echo "$OUTP" | grep -q FAIL && FAIL=1
echo "== result: $([ $FAIL = 0 ] && echo PASS || echo FAIL)"; exit $FAIL
