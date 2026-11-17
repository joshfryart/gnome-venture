#!/bin/bash
# Pal tends the Pantry (2.7.06): tests/pal_pantry.php on an installed copy (ci_suites.sh installs it with walk.sh first).
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/pal_pantry.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL pal_pantry did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL pal_pantry printed PHP warnings"; exit 1; }
exit $RC
