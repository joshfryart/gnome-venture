#!/bin/bash
# tools/pfengine.js (the JS port of the board engine) vs the PHP engine: whole fights replayed action by action (needs node).
# 2.7.58: the fights are split by mode into 4 parts that run side by side (PHP writes a trace, node replays it), so the suite fits the 600 s CI limit;
# one part = tests/pfengine_js.php with PFE_MODES set. The header checks (round, crc, decks, tables) run in every part. PFE_PARTS=1 runs everything in one piece.
HERE=$(cd "$(dirname "$0")" && pwd)
if [ "${PFE_PARTS:-4}" = 1 ]; then
  T=$(mktemp); php "$HERE/pfengine_js.php" >"$T" && node "$HERE/pfengine_js.js" "$T"; rc=$?; rm -f "$T"; exit $rc
fi
D=$(mktemp -d); trap 'rm -rf "$D"' EXIT; i=0
for M in single,builder,chaos,blank,v1,v1b,v1chaos,v1d v1old,v1pre,v1preb,v1ab,v1abc,v1st,v1stc,v1wear,v1wearc v1stat,v1luck,v1nimble v1lore,v1sense; do
  i=$((i+1)); ( PFE_MODES=$M php "$HERE/pfengine_js.php" >"$D/$i.trace" && node "$HERE/pfengine_js.js" "$D/$i.trace" >"$D/$i.out" 2>&1; echo $? >"$D/$i.rc" ) &
done
wait; RC=0
for j in 1 2 3 4; do echo "-- part $j"; cat "$D/$j.out" 2>/dev/null | tail -n 40; [ "$(cat "$D/$j.rc" 2>/dev/null)" = 0 ] || RC=1; done
exit $RC
