#!/bin/bash
# v2.0.73: fail if the front-page tour screenshots are missing, the wrong size, too big, or older than the last tour-page change.
# The version line in tests/manifests/shots.txt is the build they were taken from: FAIL when it is more than STALE_MINOR releases behind (default 12),
# so a release that restyles a tour page without a re-shoot is caught by the next few releases. Regenerate with: bash tests/shots.sh
ROOT=$(cd "$(dirname "$0")/.." && pwd); D="$ROOT/game/assets/img/landing"; M="$ROOT/tests/manifests/shots.txt"
bad=0; fail() { echo "FAIL $1"; bad=1; }
[ -s "$M" ] || { echo "FAIL no tests/manifests/shots.txt (run bash tests/shots.sh)"; exit 1; }
for s in garden satchel world town games almanac; do for v in "" "-dark"; do
  f="$D/shot-$s$v.png"; [ -s "$f" ] || { fail "missing shot-$s$v.png"; continue; }
  sz=$(stat -c %s "$f"); [ "$sz" -le 220000 ] || fail "shot-$s$v.png is $sz bytes (max 220000)"
  python3 -c "
from PIL import Image; import sys
w,h=Image.open(sys.argv[1]).size
sys.exit(0 if (w,h)==(824,1120) else 1)" "$f" || fail "shot-$s$v.png is not 824x1120"
done; done
shotv=$(sed -n 's/^version //p' "$M"); curv=$(grep -o "APP_VERSION', '[0-9.]*" "$ROOT/game/includes/bootstrap.php" | grep -o '[0-9.]*$')
gap=$(( $(echo "$curv" | cut -d. -f3) - $(echo "$shotv" | cut -d. -f3) ))
[ "$gap" -le "${STALE_MINOR:-12}" ] || fail "shots are from $shotv, build is $curv: re-run bash tests/shots.sh"
[ $bad -eq 0 ] && echo "ok   tour screenshots present, sized, fresh enough ($shotv vs $curv)"
exit $bad
