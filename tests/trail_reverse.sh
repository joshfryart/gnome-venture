#!/bin/bash
# Walking a route from its b end: run tests/trail_reverse.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/trail_reverse.sh GAME_DIR [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp "$HERE/trail_reverse.php" "$1"
