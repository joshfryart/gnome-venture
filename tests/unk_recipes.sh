#!/bin/bash
# Unknown recipes show their name and ingredients (2.7.06): tests/unk_recipes.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/unk_recipes.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/unk_recipes.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in "all ok") ;; *FAILED) ;; *) echo "FAIL unk_recipes did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL unk_recipes printed PHP warnings"; exit 1; }
exit $RC
