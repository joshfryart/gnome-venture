#!/bin/bash
# Ruin scenes (2.7.00): tests/ruin_scene.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/ruin_scene.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/ruin_scene.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL ruin_scene did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL ruin_scene printed PHP warnings"; exit 1; }
exit $RC
