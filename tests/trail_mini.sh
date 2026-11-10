#!/bin/bash
# Extra mini-bosses on the Trail: run tests/trail_mini.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/trail_mini.sh GAME_DIR [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp "$HERE/trail_mini.php" "$1"
