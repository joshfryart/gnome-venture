#!/bin/bash
# Item review leftovers (2.7.58): EC4 yearly festival, Tool Repair Kit text, Job Board part-family rows, family icons on recipe ingredients, augment emoji fallback. ci_suites.sh installs a copy first.
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/item_review_c.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL item_review_c did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL item_review_c printed PHP warnings"; exit 1; }
exit $RC
