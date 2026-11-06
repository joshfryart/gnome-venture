#!/bin/bash
# Walking back along the Trail: run tests/trail_back.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/trail_back.sh GAME_DIR [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp "$HERE/trail_back.php" "$1"
