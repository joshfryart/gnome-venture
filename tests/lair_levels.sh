#!/bin/bash
# Lair levels (2.7.00): tests/lair_levels.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/lair_levels.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/lair_levels.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL lair_levels did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL lair_levels printed PHP warnings"; exit 1; }
exit $RC
