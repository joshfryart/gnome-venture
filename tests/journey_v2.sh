#!/usr/bin/env bash
# 2026-11-28 Wren's Journey v2 (includes/journey_v2.php, data/journey_chapters.txt) on a walk.sh-installed copy (player sprout). Usage: journey_v2.sh GAME PORT ROUTER
GAME=$1
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp $HERE/journey_v2.php $GAME
