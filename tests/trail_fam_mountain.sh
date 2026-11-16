#!/bin/bash
# Coast family (2.7.01): tests/trail_fam_mountain.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/trail_fam_mountain.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/trail_fam_mountain.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL trail_fam_mountain did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL trail_fam_mountain printed PHP warnings"; exit 1; }
exit $RC
