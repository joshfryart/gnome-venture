#!/usr/bin/env bash
# World v2 creatures (includes/creatures_v2.php, setting world_v2_open): data lint, off = none, on = 60 creatures, items, lair guardians, board rows. Usage: creatures_v2.sh GAME PORT ROUTER
GAME=$1
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp $HERE/creatures_v2.php $GAME
