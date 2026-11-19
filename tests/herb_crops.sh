#!/bin/bash
# The six tea crops (herb_crops.php): data, a new world, a live world, the boot trigger. ci_suites.sh installs a copy with walk.sh first.
# Usage: tests/herb_crops.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/herb_crops.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL herb_crops did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL herb_crops printed PHP warnings"; exit 1; }
exit $RC
