#!/bin/bash
# Trail Sights items with engine uses (sights_items.php): rain charm, map scrap, star chart, chalk, message bottle, hv= swap. ci_suites.sh installs a copy first.
# Usage: tests/sights_items.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/sights_items.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL sights_items did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL sights_items printed PHP warnings"; exit 1; }
exit $RC
