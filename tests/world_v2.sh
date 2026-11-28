#!/usr/bin/env bash
# World v2 (includes/world_v2.php, setting world_v2_open): unit and integration checks on a walk.sh-installed copy (player sprout). Usage: world_v2.sh GAME PORT ROUTER
GAME=$1
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp $HERE/world_v2.php $GAME
