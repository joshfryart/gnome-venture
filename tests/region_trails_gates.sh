#!/bin/bash
# Side-trail heading rule, region map art sync, gates outside the Maplewold (2.7.08): tests/region_trails_gates.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/region_trails_gates.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/region_trails_gates.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL region_trails_gates did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL region_trails_gates printed PHP warnings"; exit 1; }
exit $RC
