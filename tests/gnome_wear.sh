#!/bin/bash
# Gnome wear (2.7.00): tests/gnome_wear.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/gnome_wear.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/gnome_wear.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL gnome_wear did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL gnome_wear printed PHP warnings"; exit 1; }
exit $RC
