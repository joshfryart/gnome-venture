#!/bin/bash
# Fight events: run tests/fight_events.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/fight_events.sh GAME_DIR [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp -d disable_functions=random_int "$HERE/fight_events.php" "$1" "${@:4}"
