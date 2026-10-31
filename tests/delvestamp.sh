#!/bin/bash
# v2.3.1 delve chambers + stamped floors. Pure PHP, no install. Usage: tests/delvestamp.sh [GAME_COPY_DIR]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-$HERE/../game}
php "$HERE/delvestamp.php" "$GAME" || exit 1
php "$HERE/../tools/lint_delve_chambers.php" "$HERE/fixtures/delve_chambers_good.txt" >/dev/null && echo "  ok   chamber lint passes the good fixture" || { echo "  FAIL chamber lint on the good fixture"; exit 1; }
php "$HERE/../tools/lint_delve_chambers.php" "$GAME/includes/data/delve_chambers.txt" | tail -1
