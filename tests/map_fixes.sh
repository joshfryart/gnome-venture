#!/bin/bash
# Map fixes (2.8.53): hat follows the road curve, card compass = region map, clamped stops spread along the road. tests/map_fixes.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/map_fixes.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/map_fixes.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL map_fixes did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL map_fixes printed PHP warnings"; exit 1; }
exit $RC
