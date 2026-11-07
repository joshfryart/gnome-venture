#!/bin/bash
# v2.6.06 crafted satchels (tests/satchel.php). Run after walk.sh has installed.
GAME=$1
php -d display_errors=1 -d error_reporting=-1 "$(dirname "$0")/satchel.php" "$GAME"
