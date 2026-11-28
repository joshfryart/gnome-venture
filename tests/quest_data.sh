#!/usr/bin/env bash
# 2026-11-28 Quest content of Wren's Journey v2 (data/journey_chapters.txt, journey_errands.txt, stop_threads_v2.txt, journey_extras.txt, stop_state.txt,
# stop_band_lines.txt; includes/quest_data.php) on a walk.sh-installed copy (player sprout). Usage: quest_data.sh GAME PORT ROUTER
GAME=$1
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp $HERE/quest_data.php $GAME
