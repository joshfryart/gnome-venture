#!/bin/bash
# 2.7.05: the Puzzle box finish (belt level check, upgrade offer on the v1 box, one-request swap, old-box carry-over, lair guardian unique layer, fading ground patch): tests/pbox_205.php on an installed copy.
# Usage: tests/pbox_205.sh GAME_DIR   (ci_suites.sh installs it with walk.sh first)
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/pbox_205.php" "$1" 2>&1); RC=$?
echo "$OUT"
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL pbox_205 printed PHP warnings"; exit 1; }
[ $RC -eq 0 ] || { echo "FAIL pbox_205 exit $RC"; exit 1; }
