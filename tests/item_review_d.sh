#!/bin/bash
# Item review group C, second pass (2.7.58): R5 stop-craft dupes, R16 plank and rope yields, R18 wearable pairs, R9 creature-part families. ci_suites.sh installs a copy first.
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/item_review_d.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL item_review_d did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL item_review_d printed PHP warnings"; exit 1; }
exit $RC
