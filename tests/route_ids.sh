#!/bin/bash
# Route ids (2.8.74): tests/route_ids.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/route_ids.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/route_ids.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL route_ids did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL route_ids printed PHP warnings"; exit 1; }
exit $RC
