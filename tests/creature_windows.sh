#!/bin/bash
# 2.7.08 creature region windows + the creature_windows_2708 boot step: tests/creature_windows.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/creature_windows.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/creature_windows.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL creature_windows did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL creature_windows printed PHP warnings"; exit 1; }
exit $RC
