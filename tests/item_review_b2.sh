#!/bin/bash
# Item review group B part 2 (2.7.58): uA-1/2 drop twins, R3 edelweiss, R4 stop acts, E2 tool prices, E5 dish pricing, E8 buff confirm, EC4/E7 festival, EC11 hovel decor label. ci_suites.sh installs a copy first.
# Item review group B part 2 (2.7.58): uA-1/2 drop twins, R3 edelweiss, R4 stop acts, E2 tool prices, E5 dish pricing, E8 buff confirm, EC4/E7 festival, EC11 hovel decor label. ci_suites.sh installs a copy first.
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/item_review_b2.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL item_review_b2 did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL item_review_b2 printed PHP warnings"; exit 1; }
exit $RC
