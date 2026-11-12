#!/bin/bash
# Trail Sights spike: run tests/trail_sights.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/trail_sights.sh GAME_DIR [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp "$HERE/trail_sights.php" "$1"
