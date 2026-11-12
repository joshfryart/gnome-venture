#!/bin/bash
# The ! over a villager follows the Orders board: tests/here_bang.php on an installed copy.
# Usage: tests/here_bang.sh GAME_DIR [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp "$HERE/here_bang.php" "$1"
