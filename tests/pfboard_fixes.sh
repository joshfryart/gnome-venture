#!/bin/bash
# 2.6.61 board fixes: regression checks (anchor, reshuffle, cut chain, pass guard, hostile charm, boss and blank values). No DB, no server.
php "$(cd "$(dirname "$0")" && pwd)/pfboard_fixes.php"
