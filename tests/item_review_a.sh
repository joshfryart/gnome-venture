#!/bin/bash
# Item review group A (2.7.58): data rows only (alt recipes, sinks, soup stock, dish buffs, keepsakes) and the boot step item_review_data_2758. ci_suites.sh installs a copy first.
# Usage: tests/item_review_a.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/item_review_a.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL item_review_a did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL item_review_a printed PHP warnings"; exit 1; }
exit $RC
