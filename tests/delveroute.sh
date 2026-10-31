#!/bin/bash
# v2.3.1 delve route generator + floor draw. Pure PHP, no install. Usage: tests/delveroute.sh [GAME_COPY_DIR]
HERE=$(cd "$(dirname "$0")" && pwd)
php "$HERE/delveroute.php" "${1:-$HERE/../game}"
