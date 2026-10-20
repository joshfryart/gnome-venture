#!/bin/bash
# Reward wrapper unit test. Run on a fresh SQLite install that walk.sh made: rewards.sh GAME [PORT] [ROUTER] (port/router unused; no HTTP needed)
HERE=$(cd "$(dirname "$0")" && pwd)
php -d display_errors=1 $HERE/rewards.php "$1"
