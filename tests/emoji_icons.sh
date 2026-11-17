#!/bin/bash
# Emoji to drawn icon swap (tests/emoji_icons.php). Needs no install: ci_suites.sh passes a copy of game/.
# Usage: tests/emoji_icons.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 "$HERE/emoji_icons.php" "${1:-$HERE/../game}" 2>&1); RC=$?
echo "$OUT"
[ $RC -eq 0 ] || { echo "FAIL emoji_icons exit $RC"; exit 1; }
