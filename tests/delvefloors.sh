#!/bin/bash
# v2.3.1 delve floor format + lint. Pure PHP, no install. Usage: tests/delvefloors.sh [GAME_COPY_DIR]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-$HERE/../game}
php "$HERE/delvefloors.php" "$GAME" || exit 1
php "$HERE/../tools/lint_delve_floors.php" "$HERE/fixtures/delve_floors_good.txt" >/dev/null && echo "  ok   lint tool passes the good fixture" || { echo "  FAIL lint tool on the good fixture"; exit 1; }
php "$HERE/../tools/lint_delve_floors.php" "$GAME/includes/data/delve_floors.txt" | tail -1
