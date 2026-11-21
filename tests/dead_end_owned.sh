#!/bin/bash
# Dead-end road villages belong to the Maplewold (2.7.50): tests/dead_end_owned.php on an installed copy.
# Usage: tests/dead_end_owned.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/dead_end_owned.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL dead_end_owned did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL dead_end_owned printed PHP warnings"; exit 1; }
exit $RC
