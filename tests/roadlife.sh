#!/bin/bash
# v1.9.3 road life: ring, cond tags, ambient lines, data lint. Usage: tests/roadlife.sh [GAME_COPY_DIR] [PORT] [ROUTER]
# Installs a fresh copy (walk.sh) and runs tests/roadlife.php on it. Pass a COPY that has no data/ yet; it is installed here.
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8793}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
bash "$HERE/walk.sh" "$GAME" "$PORT" "$ROUTER" >/dev/null 2>&1
php -d display_errors=1 -d error_reporting=-1 "$HERE/roadlife.php" "$GAME"
