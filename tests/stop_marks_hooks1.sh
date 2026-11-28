#!/usr/bin/env bash
# Lasting marks, hooks part 1 (includes/stop_mark_hooks.php, behind stop_marks_open): every number family and the A4 coins at their game sites,
# off = unchanged, caps hold (tests/stop_marks_hooks1.php). Usage: stop_marks_hooks1.sh GAME PORT ROUTER (a walk.sh install)
GAME=$1
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp $HERE/stop_marks_hooks1.php $GAME
