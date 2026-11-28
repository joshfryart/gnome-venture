#!/usr/bin/env bash
# Lasting marks, hooks part 2 (includes/stop_mark_charges.php, behind stop_marks_open): place scopes, daily charges A1-A3, flags,
# off = unchanged, caps (tests/stop_marks_hooks2.php). Usage: stop_marks_hooks2.sh GAME PORT ROUTER (a walk.sh install)
GAME=$1
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp $HERE/stop_marks_hooks2.php $GAME
