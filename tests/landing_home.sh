#!/bin/bash
# The logged-out front page: run tests/landing_home.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/landing_home.sh GAME_DIR [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp "$HERE/landing_home.php" "$1"
