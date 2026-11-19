#!/bin/bash
# Trail Sights engine gaps, fifth pass (item checks, villager misses, any-of gives, scoped discounts, Sight kinds, season limit): tests/trail_sights_283.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/trail_sights_283.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/trail_sights_283.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL trail_sights_283 did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL trail_sights_283 printed PHP warnings"; exit 1; }
exit $RC
