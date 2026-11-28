#!/usr/bin/env bash
# 2.8.85 Seals and Expedition Standing (includes/seals.php): unit and integration checks on a walk.sh-installed copy (player sprout). Usage: seals_standing.sh GAME PORT ROUTER
GAME=$1
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp $HERE/seals_standing.php $GAME
