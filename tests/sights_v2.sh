#!/bin/bash
# Sights v2 (2.8.99, setting sights_v2_open): tests/sights_v2.php (the card, a tap on the picture, no fail, the result card, rest in sleeps) and tests/sights_v2_sim.php
# (the balance sim: every Sight row at full and half pay, v1 against v2) on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/sights_v2.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
RC=0
for t in sights_v2 sights_v2_sim; do
  OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/$t.php" "$1" 2>&1); R=$?
  echo "$OUT"
  LAST=$(echo "$OUT" | tail -1)
  case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL $t did not finish (last line: $LAST)"; RC=1;; esac
  echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL $t printed PHP warnings"; RC=1; }
  [ $R -ne 0 ] && RC=1
done
exit $RC
