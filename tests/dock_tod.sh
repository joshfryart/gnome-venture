#!/bin/bash
# Dock time of day (2.8.55): dock_tod_band() bands and dock_tod() on the game clock and the Hollow hour. tests/dock_tod.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/dock_tod.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/dock_tod.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL dock_tod did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL dock_tod printed PHP warnings"; exit 1; }
exit $RC
