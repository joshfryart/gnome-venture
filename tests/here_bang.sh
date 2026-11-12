#!/bin/bash
# The ! over a villager follows the Orders board: tests/here_bang.php on an installed copy.
# Usage: tests/here_bang.sh GAME_DIR [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/here_bang.php" "$1" 2>&1); RC=$?
echo "$OUT"
# the test must reach its own last line: the bootstrap swallows a fatal error and exits 0, which once hid half of this suite
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL here_bang did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL here_bang printed PHP warnings"; exit 1; }
exit $RC
